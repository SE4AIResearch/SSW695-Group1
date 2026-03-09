extends Button

signal MethodChosen(heldMetric)

var method: Dictionary

func _on_pressed() -> void:
	MethodChosen.emit(method)
	pass

func setupMetric(newMethod: Dictionary):
	method = newMethod
	$MetricInfo.text = method.get("name")
	pass
