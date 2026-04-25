extends Node2D

@onready var worker_details = $UI/WorkerDetails

const EXTRA_OFFICE_SLOT_POSITIONS := {
	7: Vector2(231, 243),
	8: Vector2(452, 243),
	9: Vector2(120, 243),
	10: Vector2(673, 243),
	11: Vector2(231, 113),
	12: Vector2(452, 113),
	13: Vector2(120, 113),
	14: Vector2(673, 113),
}
const PLACED_UPGRADE_VISUALS := {
	"coffee_machine": {
		"texture_path": "res://UI/Theme/MainLevel/coffee/coffee_machine.png",
		"position": Vector2(600, 285),
		"scale": Vector2(4, 4),
	}
}

const DESKTOP_PC_WORKER_Y_OFFSET := -15

var _laptop_sprite_frames: SpriteFrames = null
var _desktop_sprite_frames: SpriteFrames = null

func _ready() -> void:
	TimeTool.weekPassed.connect(rollEvent)
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	PlayerTool.officeTierChanged.connect(setupDeskVisuals)
	PlayerTool.upgradesChanged.connect(setupUpgradeVisuals)
	PlayerTool.upgradesChanged.connect(setupDeskVisuals)
	initializeSave()
	PlayerTool.level = self
	_ensure_office_slots()
	setupDeskVisuals()
	setupUpgradeVisuals()
	PlayerTool.levelLoaded.emit()
func initializeSave():
	pass

func setupDeskVisuals():
	_ensure_office_slots()
	var has_desktop_pc := PlayerTool.has_upgrade("Hardware", 1)
	var worker_slots := _get_worker_slots()
	for slot in worker_slots:
		var slot_index := int(slot.name)
		var is_visible := slot_index <= PlayerTool.max_worker_capacity
		slot.visible = is_visible
		var computer := slot.get_node("computer") as AnimatedSprite2D
		computer.sprite_frames = _get_computer_sprite_frames(has_desktop_pc)
		computer.animation = "off"

	var workerCount = 1
	for worker in PlayerTool.workers:
		if workerCount > PlayerTool.max_worker_capacity:
			break
		worker.set_progress_bars_visible(true)
		if not worker.hover_started.is_connected(_on_worker_hover_started):
			worker.hover_started.connect(_on_worker_hover_started)
		if not worker.hover_ended.is_connected(_on_worker_hover_ended):
			worker.hover_ended.connect(_on_worker_hover_ended)
		var slot_node := $Level/workers.get_node(str(workerCount))
		var desk = slot_node.get_node("worker")
		var computer := slot_node.get_node("computer") as AnimatedSprite2D
		computer.sprite_frames = _get_computer_sprite_frames(has_desktop_pc)
		computer.animation = "on"
		if desk.get_child_count() == 0:
			worker.reparent(desk)
		var worker_y := DESKTOP_PC_WORKER_Y_OFFSET if has_desktop_pc else 0
		worker.position = Vector2(0, worker_y)
		workerCount += 1

func _get_computer_sprite_frames(use_desktop: bool) -> SpriteFrames:
	if use_desktop:
		if _desktop_sprite_frames == null:
			_desktop_sprite_frames = SpriteFrames.new()
			_desktop_sprite_frames.add_animation("on")
			_desktop_sprite_frames.set_animation_loop("on", false)
			_desktop_sprite_frames.add_frame("on", load("res://UI/Theme/MainLevel/computer/desktop/on.png"), 1.0)
			_desktop_sprite_frames.add_animation("off")
			_desktop_sprite_frames.set_animation_loop("off", false)
			_desktop_sprite_frames.add_frame("off", load("res://UI/Theme/MainLevel/computer/desktop/off.png"), 1.0)
		return _desktop_sprite_frames
	else:
		if _laptop_sprite_frames == null:
			_laptop_sprite_frames = SpriteFrames.new()
			_laptop_sprite_frames.add_animation("on")
			_laptop_sprite_frames.set_animation_loop("on", false)
			_laptop_sprite_frames.add_frame("on", load("res://UI/Theme/MainLevel/computer/laptop/on.png"), 1.0)
			_laptop_sprite_frames.add_animation("off")
			_laptop_sprite_frames.set_animation_loop("off", false)
			_laptop_sprite_frames.add_frame("off", load("res://UI/Theme/MainLevel/computer/laptop/off.png"), 1.0)
		return _laptop_sprite_frames

func _ensure_office_slots() -> void:
	var workers_node: Node = $Level/workers
	var template_slot: Node2D = workers_node.get_node("1")

	for slot_number in EXTRA_OFFICE_SLOT_POSITIONS.keys():
		var slot_name := str(slot_number)
		if workers_node.has_node(slot_name):
			continue
		var new_slot := template_slot.duplicate() as Node2D
		new_slot.name = slot_name
		new_slot.position = EXTRA_OFFICE_SLOT_POSITIONS[slot_number]
		new_slot.get_node("computer").animation = "off"
		workers_node.add_child(new_slot)

func setupUpgradeVisuals() -> void:
	var upgrade_props := _ensure_upgrade_props_container()

	for child in upgrade_props.get_children():
		child.queue_free()

	for upgrade in PlayerTool.upgrades:
		var scene_prop_key := str(upgrade.get("scene_prop_key", ""))
		if scene_prop_key.is_empty() or not PLACED_UPGRADE_VISUALS.has(scene_prop_key):
			continue

		var visual_config: Dictionary = PLACED_UPGRADE_VISUALS[scene_prop_key]
		var prop_sprite := Sprite2D.new()
		var texture_path := str(visual_config.get("texture_path", ""))

		if texture_path.is_empty():
			continue

		prop_sprite.name = scene_prop_key
		prop_sprite.texture = load(texture_path)
		prop_sprite.position = visual_config.get("position", Vector2.ZERO)
		prop_sprite.scale = visual_config.get("scale", Vector2.ONE)
		upgrade_props.add_child(prop_sprite)

func _ensure_upgrade_props_container() -> Node2D:
	var level_node: Node2D = $Level
	var upgrade_props := level_node.get_node_or_null("UpgradeProps") as Node2D

	if upgrade_props == null:
		upgrade_props = Node2D.new()
		upgrade_props.name = "UpgradeProps"
		level_node.add_child(upgrade_props)

	var background_index := level_node.get_node("background").get_index()
	level_node.move_child(upgrade_props, background_index + 1)
	return upgrade_props

func _get_worker_slots() -> Array:
	var worker_slots := []
	for child in $Level/workers.get_children():
		if child.name.is_valid_int():
			worker_slots.append(child)
	worker_slots.sort_custom(func(a, b): return int(a.name) < int(b.name))
	return worker_slots

func _on_worker_hover_started(worker) -> void:
	worker_details.show_worker(worker)

func _on_worker_hover_ended(worker) -> void:
	worker_details.hide_worker()

func rollEvent():
	var chance = randf_range(0,1)
	if chance <= PlayerTool.project.eventChance: $UI.startEvent()
	# Demo override: always trigger a random event each week.
	# $UI.startEvent()
	pass

func checkProjectCompletion():

	pass
