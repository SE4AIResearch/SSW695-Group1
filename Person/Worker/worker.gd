extends Node2D

signal hover_started(worker)
signal hover_ended(worker)

@export var restingColor: Color
@export var workingColor: Color

var personName: String

var headSpritePath: String
var hairSpritePath: String
var mouthSpritePath: String
var noseSpritePath: String
var eyeSpritePath: String

var frontEndStat: int
var backEndStat: int
var documentingStat: int
var speedStat: int
var staminaStat: int

var firable: bool = true

var resting: bool = false

# 0 = FE, 1 = BE, 2 = Doc
var metricType: int
var metricName: String

func _ready() -> void:
	$staminaBar.max_value = staminaStat
	$staminaBar.value = staminaStat
	$HoverArea.mouse_entered.connect(_on_hover_area_mouse_entered)
	$HoverArea.mouse_exited.connect(_on_hover_area_mouse_exited)
	TimeTool.timer.timeout.connect(work)
	
func _on_hover_area_mouse_entered() -> void:
	hover_started.emit(self)

func _on_hover_area_mouse_exited() -> void:
	hover_ended.emit(self)

func work():
	match resting:
		false:
			$staminaBar.value -= 1
			if $staminaBar.value <= 0:
				resting = true
				$staminaBar.tint_under = restingColor
				$staminaBar.tint_progress = restingColor
				
		true:
			$staminaBar.value += 5
			if $staminaBar.value >= staminaStat:
				$staminaBar.value = staminaStat
				$staminaBar.tint_under = workingColor
				$staminaBar.tint_progress = workingColor
				resting = false