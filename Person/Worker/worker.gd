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

# 0 = FE, 1 = BE, 2 = Doc
var metricType: int
var metricName: String
var progressBars: Array[CanvasItem] = []

func _ready() -> void:
	$HoverArea.mouse_entered.connect(_on_hover_area_mouse_entered)
	$HoverArea.mouse_exited.connect(_on_hover_area_mouse_exited)
	TimeTool.timer.timeout.connect(work)
	_cache_progress_bars(self)
	
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
		
func set_progress_bars_visible(should_show: bool) -> void:
	for progress_bar in progressBars:
		progress_bar.visible = should_show

func _cache_progress_bars(node: Node) -> void:
	if node is ProgressBar or node is TextureProgressBar:
		progressBars.append(node)
	for child in node.get_children():
		_cache_progress_bars(child)
