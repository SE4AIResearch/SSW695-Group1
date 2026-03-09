extends Node2D


func _process(delta: float) -> void:
	timeUpdate()
	pass

func timeUpdate() -> void:
	$TimeLabel.text =str(TimeTool.second)
	pass