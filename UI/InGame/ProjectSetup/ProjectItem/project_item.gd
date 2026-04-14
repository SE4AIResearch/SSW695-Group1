extends Button

signal selected(project)
var heldProject: Node

func prepProject(project):
	heldProject = project
	$ProjectDetails.text = "[b]Project:[/b] " +project.projectName + "\n" + "[b]Description:[/b] " + project.projectDescription + "\n" + "[b]Client:[/b] " + project.clientName + "\n" + "[b]Sprint Amount:[/b] " + str(project.sprintAmount) + "\n"+"[b]Weeks per Sprint:[/b] " + str(project.sprintLength)
	$ProjectDetails.text += "\nProject Constraints:"
	for constraint in project.constraints:
		$ProjectDetails.text +="\n	-" + constraint.get("name")
func _on_pressed() -> void:
	selected.emit(heldProject)
	pass
