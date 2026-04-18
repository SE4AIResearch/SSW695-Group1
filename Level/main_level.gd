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

func _ready() -> void:
	TimeTool.weekPassed.connect(rollEvent)
	PlayerTool.hireSelected.connect(setupDeskVisuals)
	PlayerTool.officeTierChanged.connect(setupDeskVisuals)
	initializeSave()
	PlayerTool.level = self
	_ensure_office_slots()
	setupDeskVisuals()
	PlayerTool.levelLoaded.emit()
func initializeSave():
	pass

func setupDeskVisuals():
	_ensure_office_slots()
	var worker_slots := _get_worker_slots()
	for slot in worker_slots:
		var slot_index := int(slot.name)
		var is_visible := slot_index <= PlayerTool.max_worker_capacity
		slot.visible = is_visible
		slot.get_node("computer").animation = "off"

	var workerCount = 1
	for worker in PlayerTool.workers:
		if workerCount > PlayerTool.max_worker_capacity:
			break
		if not worker.hover_started.is_connected(_on_worker_hover_started):
			worker.hover_started.connect(_on_worker_hover_started)
		if not worker.hover_ended.is_connected(_on_worker_hover_ended):
			worker.hover_ended.connect(_on_worker_hover_ended)
		var desk = $Level/workers.get_node(str(workerCount)).get_node("worker")
		$Level/workers.get_node(str(workerCount)).get_node("computer").animation = "on"
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