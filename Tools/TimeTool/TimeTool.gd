extends Node

signal weekPassed
signal sprintPassed

var timer = Timer.new()
var totalSeconds: int = 0
const WEEK_DURATION_SECONDS := 10

func _ready() -> void:
	add_child(timer)
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(trackSeconds)
	PlayerTool.levelLoaded.connect(addTimer)
	
func trackSeconds() -> void:
	totalSeconds += 1
	if not PlayerTool.isWeekActive():
		return
	PlayerTool.weekTime = mini(PlayerTool.weekTime + 1, WEEK_DURATION_SECONDS)
	PlayerTool.weekTimerUpdated.emit()
	if PlayerTool.weekTime < WEEK_DURATION_SECONDS:
		return
	var previousSprint := PlayerTool.projSprint
	var resolved := PlayerTool.resolveWeek()
	if not resolved:
		return
	weekPassed.emit()
	if PlayerTool.project == null or PlayerTool.projSprint != previousSprint:
		sprintPassed.emit()

func addTimer() -> void:
	timer.reparent(PlayerTool.level)
	timer.start(1)
	
func reset() -> void:
	totalSeconds = 0
	timer.reparent(self)
	timer.stop()
