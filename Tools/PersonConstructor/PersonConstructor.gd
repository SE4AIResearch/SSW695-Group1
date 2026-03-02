extends Node

var nameList = load("res://Person/names.gd").new()
var textureList = load("res://Person/Textures/textures.gd").new()

var skinColors: Array[Color]

func generateName() -> String:
	var fName: String
	match randi_range(0,1):
		0: fName = nameList.maleFirstNames[randi_range(0,nameList.maleFirstNames.size()-1)]
		1: fName = nameList.femaleFirstNames[randi_range(0,nameList.femaleFirstNames.size()-1)]
	return (fName +" "+nameList.lastNames[randi_range(0,nameList.lastNames.size()-1)])
	
func generateVisuals(person):
	person.headSpritePath = textureList.head[randi_range(0,textureList.head.size()-1)]
	person.hairSpritePath = textureList.hair[randi_range(0,textureList.hair.size()-1)]
	person.mouthSpritePath = textureList.mouth[randi_range(0,textureList.mouth.size()-1)]
	person.noseSpritePath = textureList.nose[randi_range(0,textureList.nose.size()-1)]
	person.eyeSpritePath = textureList.eyes[randi_range(0,textureList.eyes.size()-1)]
	person.get_node("hairSprite").texture = load(person.hairSpritePath)
	person.get_node("headSprite").texture = load(person.headSpritePath)
	person.get_node("noseSprite").texture = load(person.noseSpritePath)
	person.get_node("eyeSprite").texture = load(person.eyeSpritePath)
	person.get_node("mouthSprite").texture = load(person.mouthSpritePath)
	
	#Random Colors for now, Will replace later!
	person.get_node("headSprite").modulate = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	person.get_node("noseSprite").modulate = person.get_node("headSprite").modulate
	person.get_node("hairSprite").modulate = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	pass

func generateWorkerStats(worker):
	worker.frontEndWorkerStat = 1
	worker.backEndWorkerStat = 1
	worker.documentingWorkerStat = 1
	worker.speedWorkerStat = 1
	worker.staminaWorkerStat = 1
	pass
