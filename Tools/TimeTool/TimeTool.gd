extends Node

signal weekPassed
signal sprintPassed

var timer = Timer.new()
var totalSeconds: int = 0

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
	PlayerTool.currentWeekTime = mini(PlayerTool.currentWeekTime + 1, PlayerTool.WEEK_DURATION_SECONDS)
	PlayerTool.weekTimerUpdated.emit()
	if PlayerTool.currentWeekTime >= PlayerTool.WEEK_DURATION_SECONDS:
		PlayerTool.resolveWeek()

func addTimer() -> void:
	timer.reparent(PlayerTool.level)
	timer.start(1)
	
func reset() -> void:
	totalSeconds = 0
	timer.reparent(self)
	timer.stop()
