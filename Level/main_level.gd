extends Node2D

@onready var worker_details = $UI/WorkerDetails

const DESK_COMPUTER_VISUALS := {
	"default": {
		"textures": {
			"off": "res://UI/Theme/MainLevel/computer/laptop/off.png",
			"on": "res://UI/Theme/MainLevel/computer/laptop/on.png",
		},
		"position": Vector2(0, -48),
	},
	"desktop_pc": {
		"textures": {
			"off": "res://UI/Theme/MainLevel/computer/desktop/off.png",
			"on": "res://UI/Theme/MainLevel/computer/desktop/on.png",
		},
		"position": Vector2(0, -60),
	},
}
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

func _ready() -> void:
	TimeTool.weekPassed.connect(rollEvent)
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	PlayerTool.officeTierChanged.connect(setupDeskVisuals)
	PlayerTool.upgradesChanged.connect(setupDeskVisuals)
	PlayerTool.upgradesChanged.connect(setupUpgradeVisuals)
	initializeSave()
	PlayerTool.level = self
	_ensure_office_slots()
	setupDeskVisuals()
	setupUpgradeVisuals()
	PlayerTool.levelLoaded.emit()
func initializeSave():
	if PlayerTool.projectName == "":
		return
	
	var projectList = load("res://Projects/projectList.gd").new()
	var projectItem = preload("res://Projects/projectBase.tscn")
	var project_data: Dictionary = {}
	
	for p in projectList.projects:
		if p.name == PlayerTool.projectName:
			project_data = p
			break
	
	var project_node = projectItem.instantiate()
	project_node.projectName = PlayerTool.projectName
	project_node.clientName = PlayerTool.clientName
	project_node.sprintAmount = PlayerTool.sprintAmount
	project_node.sprintLength = PlayerTool.sprintLength
	project_node.projectDifficulty = PlayerTool.projectRatedDifficulty
	project_node.methodology = PlayerTool.methodology
	project_node.eventChance = PlayerTool.eventChance
	
	if project_node.methodology.is_empty() and not project_data.is_empty():
		project_node.methodology = {"name": project_data.get("preferredMethodology", "Standard")}
	
	if not project_data.is_empty():
		project_node.frontEndProjectMin = project_data.get("frontEndMetrics", {}).size()
		project_node.backEndProjectMin = project_data.get("backEndMetrics", {}).size()
		project_node.documentingProjectMin = project_data.get("documentingMetrics", {}).size()
	
	PlayerTool.project = project_node
	PlayerTool.projectSelected.emit()
	PlayerTool.statsChanged.emit()
	PlayerTool.backlogUpdated.emit()
	PlayerTool.loopStateChanged.emit()

func setupDeskVisuals():
	_ensure_office_slots()
	var computer_visual_config := _get_active_desk_computer_visual_config()
	var worker_slots := _get_worker_slots()
	for slot in worker_slots:
		var slot_index := int(slot.name)
		var is_visible := slot_index <= PlayerTool.max_worker_capacity
		slot.visible = is_visible
		var computer := slot.get_node("computer") as AnimatedSprite2D
		_apply_desk_computer_visual_config(computer, computer_visual_config)
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
		var worker_slot := $Level/workers.get_node(str(workerCount))
		var desk = worker_slot.get_node("worker")
		var computer := worker_slot.get_node("computer") as AnimatedSprite2D
		computer.animation = "on"
		if desk.get_child_count() == 0:
			worker.reparent(desk)
		worker.position = Vector2(0,0)
		workerCount += 1
		pass

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

func _get_active_desk_computer_visual_config() -> Dictionary:
	for upgrade in PlayerTool.upgrades:
		var scene_prop_key := str(upgrade.get("scene_prop_key", ""))
		if DESK_COMPUTER_VISUALS.has(scene_prop_key):
			return DESK_COMPUTER_VISUALS[scene_prop_key]
	return DESK_COMPUTER_VISUALS["default"]

func _apply_desk_computer_visual_config(computer: AnimatedSprite2D, visual_config: Dictionary) -> void:
	if computer == null:
		return

	computer.position = visual_config.get("position", Vector2(0, -48))
	var texture_paths: Dictionary = visual_config.get("textures", {})
	var sprite_frames := SpriteFrames.new()
	sprite_frames.add_animation("off")
	sprite_frames.set_animation_loop("off", false)
	sprite_frames.set_animation_speed("off", 5.0)
	sprite_frames.add_frame("off", load(str(texture_paths.get("off", ""))))

	sprite_frames.add_animation("on")
	sprite_frames.set_animation_loop("on", false)
	sprite_frames.set_animation_speed("on", 5.0)
	sprite_frames.add_frame("on", load(str(texture_paths.get("on", ""))))

	computer.sprite_frames = sprite_frames

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
