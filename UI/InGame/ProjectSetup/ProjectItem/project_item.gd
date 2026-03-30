extends Button

signal selected(project)
var heldProject: Node

func prepProject(project):
	heldProject = project
	$ProjectDetails.text = "Project:" +project.projectName + "\n" + "Description: " + project.projectDescription + "\n" + "Client: " + project.clientName + "\n" + "\n" + "Sprint Amount: " + str(project.sprintAmount) + "\n"+"Sprint Length" + str(project.sprintLength) + "\n"+"Front End: " + str(project.frontEndProjectMin) + "\n"+"Back End: " + str(project.backEndProjectMin) + "\n"+"Documenting: "+str(project.documentingProjectMin)

func _on_pressed() -> void:
	selected.emit(heldProject)
	pass
