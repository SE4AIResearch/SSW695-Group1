extends Node2D

signal hover_started(worker)
signal hover_ended(worker)

@export var restingColor: Color
@export var workingColor: Color

var personName: String
var workerId: String

var headSpritePath: String
var hairSpritePath: String
var mouthSpritePath: String
var noseSpritePath: String
var eyeSpritePath: String

var frontEndStat: int
var backEndStat: int
var documentingStat: int
var speedStat: int
var staminaStat: int
var upgradeStatBonuses: Dictionary = {}

var firable: bool = true

var resting: bool = false

# 0 = FE, 1 = BE, 2 = Doc
var metricType: int
var metricName: String
var progressBars: Array[CanvasItem] = []
var progress_bars_visible: bool = true

func _ready() -> void:
	$staminaBar.max_value = staminaStat
	$staminaBar.value = staminaStat
	$HoverArea.mouse_entered.connect(_on_hover_area_mouse_entered)
	$HoverArea.mouse_exited.connect(_on_hover_area_mouse_exited)
	TimeTool.timer.timeout.connect(work)
	_cache_progress_bars(self)
	set_progress_bars_visible(progress_bars_visible)
	
func _on_hover_area_mouse_entered() -> void:
	if get_tree().paused:
		return
	hover_started.emit(self)

func _on_hover_area_mouse_exited() -> void:
	hover_ended.emit(self)

func work():
	if PlayerTool.project != null && PlayerTool.isWeekActive():
		var hasBacklogItem: bool = PlayerTool.selectedAssignments.has(workerId)
		if not hasBacklogItem:
			$staminaBar.value += 3
			if $staminaBar.value > staminaStat:
				$staminaBar.value = staminaStat
			if resting and $staminaBar.value >= staminaStat:
				$staminaBar.value = staminaStat
				$staminaBar.tint_under = workingColor
				$staminaBar.tint_progress = workingColor
				resting = false
				AudioManager.notify_worker_resting_ended()
			return
		match resting:
			false:
					$staminaBar.value -= 2
					if $staminaBar.value <= 0:
						resting = true
						$staminaBar.tint_under = restingColor
						$staminaBar.tint_progress = restingColor
						AudioManager.notify_worker_stamina_depleted()
	
			true:
				$staminaBar.value += 6
				if $staminaBar.value >= staminaStat:
					$staminaBar.value = staminaStat
					$staminaBar.tint_under = workingColor
					$staminaBar.tint_progress = workingColor
					resting = false
					AudioManager.notify_worker_resting_ended()

func _exit_tree() -> void:
	if resting:
		AudioManager.notify_worker_resting_ended()

func set_progress_bars_visible(should_show: bool) -> void:
	progress_bars_visible = should_show
	for progress_bar in progressBars:
		if is_instance_valid(progress_bar):
			progress_bar.visible = should_show

func _cache_progress_bars(node: Node) -> void:
	if node is ProgressBar or node is TextureProgressBar:
		progressBars.append(node)
	for child in node.get_children():
		_cache_progress_bars(child)
