extends Button

signal selected(project)
var heldProject: Node

func prepProject(project):
	heldProject = project
	$ProjectDetails.text = "[b]Project:[/b] " +project.projectName + "\n" + "Description: " + project.projectDescription + "\n" + "Client: " + project.clientName + "\n" + "Sprint Amount: " + str(project.sprintAmount) + "\n"+"Weeks per Sprint: " + str(project.sprintLength)
	$ProjectDetails.text += "\nProject Constraints:"
	for constraint in project.constraints:
		$ProjectDetails.text +="\n	-" + constraint.get("name")
func _on_pressed() -> void:
	selected.emit(heldProject)
	pass
