extends Node2D

const PCWindowLayout = preload("res://UI/InGame/PCWindow/pc_window_layout.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PCWindowLayout.apply(self)
	_apply_content_layout()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _apply_content_layout() -> void:
	var content_rect: Rect2 = PCWindowLayout.content_rect()
	var scroll_width: float = minf(360.0, content_rect.size.x)

	$ScrollContainer.offset_left = content_rect.position.x + (content_rect.size.x - scroll_width) / 2.0
	$ScrollContainer.offset_top = content_rect.position.y + 10.0
	$ScrollContainer.offset_right = $ScrollContainer.offset_left + scroll_width
	$ScrollContainer.offset_bottom = content_rect.position.y + content_rect.size.y - 10.0

func _on_pc_back_pressed() -> void: get_parent().get_parent().endMenu()
