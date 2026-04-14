extends Node

signal weekPassed

var timer = Timer.new()
var totalSeconds: int = 0

func _ready() -> void:
	add_child(timer)
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(trackSeconds)
	PlayerTool.levelLoaded.connect(addTimer)
	
func trackSeconds(): totalSeconds += 1

func addTimer():
	timer.reparent(PlayerTool.level)
	timer.start(1)
	
func reset():
	timer.reparent(self)
	timer.stop()
	pass
