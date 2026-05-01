extends Button

signal selected(project)
var heldProject: Node

func prepProject(project):
	heldProject = project
	$ProjectDetails.text = "[b]Project:[/b] " + project.projectName
	$ProjectDetails.text += "\n[b]Sprint Amount:[/b] " + str(project.sprintAmount)
	$ProjectDetails.text += "\n[b]Weeks per Sprint:[/b] " + str(project.sprintLength)
	$ProjectDetails.text += "\n[b]Description:[/b] " + project.projectDescription
	$ProjectDetails.text += "\n[b]Client:[/b] " + project.clientName
	$ProjectDetails.text += "\nProject Constraints:"
	for constraint in project.constraints:
		$ProjectDetails.text += "\n\t-" + constraint.get("name")
func _on_pressed() -> void:
	selected.emit(heldProject)
	pass
