extends Node2D

signal hover_started(worker)
signal hover_ended(worker)

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

var currentMetric: Dictionary = {
	"metricType": null,
	"metricName": null,
}

func _ready() -> void:
	$HoverArea.mouse_entered.connect(_on_hover_area_mouse_entered)
	$HoverArea.mouse_exited.connect(_on_hover_area_mouse_exited)
	TimeTool.timer.timeout.connect(work)
	
func _on_hover_area_mouse_entered() -> void:
	hover_started.emit(self)

func _on_hover_area_mouse_exited() -> void:
	hover_ended.emit(self)

func work() -> void:
	pass
