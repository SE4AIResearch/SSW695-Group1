extends Node

signal secondPassed

var elapsedTime: float = 0.0
var second: int

var inGame: bool = false

func _physics_process(delta: float) -> void:
	if inGame:
		passTime()
	
func passTime() -> void:
	elapsedTime += get_physics_process_delta_time()
	second = int(elapsedTime) % 60
	if int(elapsedTime) % 60 == 0:
		secondPassed.emit()
	
