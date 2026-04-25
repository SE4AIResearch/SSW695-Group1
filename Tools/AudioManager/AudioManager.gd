extends Node
##
## AudioManager — 集中管理 BGM、SFX、Ambient 的 autoload 单例。
##
## 设计原则：
##   * 文件缺失时 **不报错、不崩溃**，相应的 play_* 调用会被静默忽略。
##     这样队伍可以一边补音频文件一边运行游戏。
##   * 所有音频按 “逻辑 key” 调用，文件实际放在 res://Audio/{Music,SFX,Ambient}/ 下，
##     文件名见下面的 MUSIC_FILES / SFX_FILES / AMBIENT_FILES 字典。
##   * 详细的下载与放置说明：res://Audio/README.md
##
## 公共 API：
##   AudioManager.play_music(key)              # 切换 BGM（自动 loop）
##   AudioManager.stop_music()
##   AudioManager.play_sfx(key, pitch_random)  # 一次性音效
##   AudioManager.start_random_ambient()       # 进入关卡时调用
##   AudioManager.stop_random_ambient()        # 离开关卡时调用
##   AudioManager.notify_worker_stamina_depleted()
##   AudioManager.notify_worker_resting_started()
##   AudioManager.notify_worker_resting_ended()
##

signal music_changed(track_key: String)
signal volume_changed(channel: String, value: float)

const MUSIC_DIR := "res://Audio/Music/"
const SFX_DIR := "res://Audio/SFX/"
const AMBIENT_DIR := "res://Audio/Ambient/"
const AUDIO_SETTINGS_PATH := "user://audio_settings.cfg"
const AUDIO_SETTINGS_SECTION := "Audio"
const VOLUME_CHANNELS: Array[String] = ["master", "music", "sfx", "ambient"]

const SFX_POOL_SIZE := 8
const SUPPORTED_EXTENSIONS: Array[String] = [".mp3", ".ogg", ".wav"]

@export_range(0.0, 1.0) var master_volume: float = 1.0
@export_range(0.0, 1.0) var music_volume: float = 0.55
@export_range(0.0, 1.0) var sfx_volume: float = 1.0
@export_range(0.0, 1.0) var ambient_volume: float = 0.45

# 音乐：背景音乐（循环播放）
const MUSIC_FILES := {
	"main_menu": "bgm_main_menu",
	"gameplay": "bgm_gameplay_loop",
	"relaxed": "bgm_relaxed",
}

# SFX：一次性音效（按事件触发）
const SFX_FILES := {
	"paper_rustle": "paper_rustle",
	"pc_click": "pc_click",
	"cash_register": "cash_register",
	"buzzer_error": "buzzer_error",
	"worker_sigh": "worker_sigh",
}

# Ambient：环境音（gibberish 循环；coffee / keyboard 由内部计时器随机触发）
const AMBIENT_FILES := {
	"coffee_brew": "coffee_brew",
	"keyboard_typing": "keyboard_typing",
	"gibberish_chat": "gibberish_chat",
}

# 哪些 key 需要循环
const LOOP_KEYS := {
	"music::main_menu": true,
	"music::gameplay": true,
	"music::relaxed": true,
	"ambient::gibberish_chat": true,
}

# 随机环境音的间隔（秒）
const COFFEE_INTERVAL_RANGE := Vector2(45.0, 120.0)
const KEYBOARD_INTERVAL_RANGE := Vector2(8.0, 25.0)

var _music_player: AudioStreamPlayer
var _gibberish_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _next_sfx_index: int = 0

var _coffee_timer: Timer
var _keyboard_timer: Timer

var _streams: Dictionary = {}
var _current_music_key: String = ""
var _resting_workers: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_volume_settings()

	_music_player = _make_player("MusicPlayer")
	add_child(_music_player)

	_gibberish_player = _make_player("GibberishPlayer")
	add_child(_gibberish_player)

	for i in SFX_POOL_SIZE:
		var sfx_player := _make_player("SFXPlayer%d" % i)
		add_child(sfx_player)
		_sfx_pool.append(sfx_player)

	_coffee_timer = Timer.new()
	_coffee_timer.one_shot = true
	_coffee_timer.timeout.connect(_on_coffee_timer_timeout)
	_coffee_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_coffee_timer)

	_keyboard_timer = Timer.new()
	_keyboard_timer.one_shot = true
	_keyboard_timer.timeout.connect(_on_keyboard_timer_timeout)
	_keyboard_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_keyboard_timer)

	_preload_all()


# ============================================================
#  Public API
# ============================================================

func play_music(key: String) -> void:
	if key == _current_music_key and _music_player.playing:
		return
	var stream := _get_stream("music", key)
	if stream == null:
		_music_player.stop()
		_current_music_key = ""
		return
	_current_music_key = key
	_music_player.stream = stream
	_music_player.volume_db = _music_db()
	_music_player.play()
	music_changed.emit(key)


func stop_music() -> void:
	_music_player.stop()
	_current_music_key = ""


func play_sfx(key: String, pitch_random: float = 0.0) -> void:
	_play_oneshot("sfx", key, _sfx_db(), pitch_random)


func start_random_ambient() -> void:
	if _streams.get("ambient::coffee_brew") != null:
		_coffee_timer.start(randf_range(COFFEE_INTERVAL_RANGE.x, COFFEE_INTERVAL_RANGE.y))
	if _streams.get("ambient::keyboard_typing") != null:
		_keyboard_timer.start(randf_range(KEYBOARD_INTERVAL_RANGE.x, KEYBOARD_INTERVAL_RANGE.y))


func stop_random_ambient() -> void:
	_coffee_timer.stop()
	_keyboard_timer.stop()


func reset_resting_workers() -> void:
	_resting_workers = 0
	_refresh_gibberish()


func notify_worker_stamina_depleted() -> void:
	play_sfx("worker_sigh", 0.05)
	notify_worker_resting_started()


func notify_worker_resting_started() -> void:
	_resting_workers += 1
	_refresh_gibberish()


func notify_worker_resting_ended() -> void:
	_resting_workers = maxi(0, _resting_workers - 1)
	_refresh_gibberish()


func set_volume(channel: String, value: float, save: bool = true) -> void:
	var normalized_channel := channel.strip_edges().to_lower()
	if not VOLUME_CHANNELS.has(normalized_channel):
		push_warning("Unknown audio volume channel: " + channel)
		return

	var clamped_value := clampf(value, 0.0, 1.0)
	match normalized_channel:
		"master":
			master_volume = clamped_value
		"music":
			music_volume = clamped_value
		"sfx":
			sfx_volume = clamped_value
		"ambient":
			ambient_volume = clamped_value

	_refresh_audio_player_volumes()
	volume_changed.emit(normalized_channel, clamped_value)
	if save:
		save_volume_settings()


func get_volume(channel: String) -> float:
	match channel.strip_edges().to_lower():
		"master":
			return master_volume
		"music":
			return music_volume
		"sfx":
			return sfx_volume
		"ambient":
			return ambient_volume
	return 0.0


func get_volume_settings() -> Dictionary:
	return {
		"master": master_volume,
		"music": music_volume,
		"sfx": sfx_volume,
		"ambient": ambient_volume,
	}


func load_volume_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(AUDIO_SETTINGS_PATH)
	if err != OK:
		_refresh_audio_player_volumes()
		return

	for channel in VOLUME_CHANNELS:
		var current_value := get_volume(channel)
		var saved_value = config.get_value(AUDIO_SETTINGS_SECTION, channel, current_value)
		set_volume(channel, _coerce_volume(saved_value, current_value), false)


func save_volume_settings() -> void:
	var config := ConfigFile.new()
	for channel in VOLUME_CHANNELS:
		config.set_value(AUDIO_SETTINGS_SECTION, channel, get_volume(channel))
	config.save(AUDIO_SETTINGS_PATH)


# ============================================================
#  Internal
# ============================================================

func _make_player(player_name: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = player_name
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	return p


func _refresh_audio_player_volumes() -> void:
	if _music_player != null:
		_music_player.volume_db = _music_db()
	if _gibberish_player != null:
		_gibberish_player.volume_db = _ambient_db()


func _coerce_volume(value, fallback: float) -> float:
	var value_type := typeof(value)
	if value_type != TYPE_FLOAT and value_type != TYPE_INT:
		return clampf(fallback, 0.0, 1.0)
	return clampf(float(value), 0.0, 1.0)


func _play_oneshot(category: String, key: String, volume_db: float, pitch_random: float) -> void:
	var stream := _get_stream(category, key)
	if stream == null:
		return
	var player := _sfx_pool[_next_sfx_index]
	_next_sfx_index = (_next_sfx_index + 1) % SFX_POOL_SIZE
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + (randf_range(-pitch_random, pitch_random) if pitch_random > 0.0 else 0.0)
	player.play()


func _refresh_gibberish() -> void:
	if _resting_workers >= 2:
		if not _gibberish_player.playing:
			var stream := _get_stream("ambient", "gibberish_chat")
			if stream == null:
				return
			_gibberish_player.stream = stream
			_gibberish_player.volume_db = _ambient_db()
			_gibberish_player.play()
	elif _gibberish_player.playing:
		_gibberish_player.stop()


func _on_coffee_timer_timeout() -> void:
	_play_oneshot("ambient", "coffee_brew", _ambient_db(), 0.05)
	_coffee_timer.start(randf_range(COFFEE_INTERVAL_RANGE.x, COFFEE_INTERVAL_RANGE.y))


func _on_keyboard_timer_timeout() -> void:
	_play_oneshot("ambient", "keyboard_typing", _ambient_db(), 0.07)
	_keyboard_timer.start(randf_range(KEYBOARD_INTERVAL_RANGE.x, KEYBOARD_INTERVAL_RANGE.y))


# ============================================================
#  Resource preload
# ============================================================

func _preload_all() -> void:
	for key: String in MUSIC_FILES.keys():
		_try_load("music", key, MUSIC_DIR, str(MUSIC_FILES[key]))
	for key: String in SFX_FILES.keys():
		_try_load("sfx", key, SFX_DIR, str(SFX_FILES[key]))
	for key: String in AMBIENT_FILES.keys():
		_try_load("ambient", key, AMBIENT_DIR, str(AMBIENT_FILES[key]))


func _try_load(category: String, key: String, dir: String, base_name: String) -> void:
	var combined_key: String = "%s::%s" % [category, key]
	for ext: String in SUPPORTED_EXTENSIONS:
		var path: String = dir + base_name + ext
		if ResourceLoader.exists(path, "AudioStream"):
			var stream := load(path) as AudioStream
			if stream != null:
				_configure_stream_loop(stream, combined_key)
				_streams[combined_key] = stream
				return
	_streams[combined_key] = null


func _configure_stream_loop(stream: AudioStream, combined_key: String) -> void:
	var should_loop: bool = bool(LOOP_KEYS.get(combined_key, false))
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = should_loop
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = should_loop
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED


func _get_stream(category: String, key: String) -> AudioStream:
	return _streams.get("%s::%s" % [category, key], null) as AudioStream


# ============================================================
#  Volume helpers
# ============================================================

func _music_db() -> float:
	return linear_to_db(maxf(0.0001, master_volume * music_volume))


func _sfx_db() -> float:
	return linear_to_db(maxf(0.0001, master_volume * sfx_volume))


func _ambient_db() -> float:
	return linear_to_db(maxf(0.0001, master_volume * ambient_volume))
