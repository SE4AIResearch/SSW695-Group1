extends Button

signal MetricChosen(button)

#0 = front end, 1 = back end, 2 = documentation
var metricType: int
var metricName: String

var requiresPredicessor: bool = true
var sprintUnlock: int = 0

func prepItem(metric,type):
	match type:
		0: 
			metricType = 0
			$metricName.text = "[color=#fc2403]" + metric
			$metricDetails.text = "[color=#fc2403]Front End"
		1:
			metricType = 1
			$metricName.text = "[color=#30c4ff]" + metric
			$metricDetails.text = "[color=#30c4ff]Back End"
		2:
			metricType = 2
			$metricName.text = "[color=#03fc41]" + metric
			$metricDetails.text = "[color=#03fc41]Documentation"


func _on_pressed() -> void:
	MetricChosen.emit(self)
