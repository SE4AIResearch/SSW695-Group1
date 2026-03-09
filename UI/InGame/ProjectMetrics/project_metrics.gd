extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func getCurrentMetrics(project,currentMetrics):
	$methodologyLabel.text = "Methodology: " + project.methodology.get("name")
	$frontEndBar.max_value = project.frontEndProjectMin
	$frontEndBar.value = currentMetrics.get("frontEnd")
	$backEndBar.max_value = project.backEndProjectMin
	$backEndBar.value = currentMetrics.get("backEnd")
	$documentationBar.max_value = project.documentingProjectMin
	$documentationBar.value = currentMetrics.get("documenting")
	$reliabilityBar.max_value = 100
	$reliabilityBar.value = currentMetrics.get("reliability")
	$stakeholderSatisfactionBar.max_value = 100
	$stakeholderSatisfactionBar.value = currentMetrics.get("stakeholderSatisfaction")
	pass
