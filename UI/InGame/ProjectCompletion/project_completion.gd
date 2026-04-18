extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void: calculateCompletion()

func calculateCompletion():
	prepMenu()
	calculateStakeholderSatisfaction()
	calculateCurrencyEarned()
	

func prepMenu():
	$projectInfo.text = "Project Name:"+PlayerTool.project.projectName + "\nClient: " + PlayerTool.project.clientName 
	pass

func calculateStakeholderSatisfaction():

	pass

func calculateCurrencyEarned():
	
	pass