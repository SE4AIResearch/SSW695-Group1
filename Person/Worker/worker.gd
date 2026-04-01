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

var currentMetric={
"metricType":null,
"metricName":null
}

func _ready() -> void:
	$HoverArea.mouse_entered.connect(_on_hover_area_mouse_entered)
	$HoverArea.mouse_exited.connect(_on_hover_area_mouse_exited)
	TimeTool.timer.timeout.connect(work)
	
func _on_hover_area_mouse_entered() -> void:
	hover_started.emit(self)

func _on_hover_area_mouse_exited() -> void:
	hover_ended.emit(self)

func work():
	if PlayerTool.currentProject != null:
		var type: int = randi_range(0,2)
		var amount: int
		match type:
			0: 
				amount = 1#frontEndStat
				PlayerTool.changeProjectStats(type,amount)
			1: 
				amount = 1#backEndStat
				PlayerTool.changeProjectStats(type,amount)
			2: 
				amount = 1#documentingStat
				PlayerTool.changeProjectStats(type,amount)

		NumberVisualizer.createNumber(amount,type,self.global_position+Vector2(randf_range(-30,30),randf_range(-20,-40)))
		
