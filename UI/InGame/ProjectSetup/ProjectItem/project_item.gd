extends Button

signal selected(project)
var heldProject: Node

func prepProject(project):
	heldProject = project
	$ProjectDetails.text = "Project:" +project.projectName + "\n" + "Description: " + project.projectDescription + "\n" + "Client: " + project.clientName + "\n" + "Sprint Amount: " + str(project.sprintAmount) + "\n"+"Weeks per Sprint: " + str(project.sprintLength) +"\n"+"Metrics Per Sprint: "+str(project.sprintMetricAmount)+ "\n"+"Front End: " + str(project.frontEndProjectMin) + "\n"+"Back End: " + str(project.backEndProjectMin) + "\n"+"Documenting: "+str(project.documentingProjectMin)
	if project.recommendedMethodology != "":
		$ProjectDetails.text += "\nRecommended: " + project.recommendedMethodology
	if project.learningObjective != "":
		$ProjectDetails.text += "\nLearning Goal: " + project.learningObjective
	$ProjectDetails.text += "\nProject Constraints:"
	for constraint in project.constraints:
		$ProjectDetails.text +="\n	-" + constraint.get("name")
func _on_pressed() -> void:
	selected.emit(heldProject)
	pass
