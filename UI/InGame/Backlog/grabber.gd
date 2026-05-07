extends Node2D

var heldWorker: Node = null

@onready var heldPerson: Node2D = $Person

func _ready() -> void:
	heldPerson.visible = false
	z_index = 100

func _process(delta: float) -> void:
	if heldWorker == null:
		return
	global_position = get_global_mouse_position()

func beginGrab(worker: Node) -> void:
	if worker == null:
		clearGrab()
		return
	heldWorker = worker
	heldPerson.visible = true
	heldPerson.setVisuals(
		worker.get_node("headSprite").texture,
		worker.get_node("hairSprite").texture,
		worker.get_node("mouthSprite").texture,
		worker.get_node("noseSprite").texture,
		worker.get_node("eyeSprite").texture,
	)
	heldPerson.get_node("headSprite").modulate = worker.get_node("headSprite").modulate
	heldPerson.get_node("hairSprite").modulate = worker.get_node("hairSprite").modulate
	heldPerson.get_node("noseSprite").modulate = worker.get_node("noseSprite").modulate
	global_position = get_global_mouse_position()

func clearGrab() -> void:
	heldWorker = null
	heldPerson.visible = false
