extends Node2D


func _physics_process(delta: float) -> void:
	moveNumb()

func setupVisual(amount,color):
	$numberLabel.text = "[color="+color+"]"+"+"+str(amount)

func moveNumb():
	print("Moving")
	position.y -= .4
	modulate -= Color(0,0,0,.02)
	if modulate.a <= 0:
		queue_free()
	pass
