extends Node

#Types: BackEnd, FrontEnd, Documenting, Stakeholder, Backlog
var events = [
{
"name":"CodeReviewBE1",
"type":"BackEnd",
"description":"Review this code and find the error.\n [img=600x250]res://UI/InGame/RandomEvent/eventResources/CodeReviewBE1/codeInQuestion.png[/img]",
"choices":["Offset answer if 0","Silent Error Supression","Length check array","LINQ Approach to handle iteration of array"],
"outcomes":["","","",""]
},
{
"name":"CodeReviewFE1",
"type":"FrontEnd",
"description":"Review this code and find the error.\n [img = ]",
"choices":["","",""],
"outcomes":["","",""]
},
{
"name":"forgotToSave",
"type":"Documenting",
"description":"The document's autosave feature is not working! Some progress is lost!",
"choices":["Lose Documentation."],
"outcomes":[-.15]
},
{
"name":"scaleDownProject",
"type":"Stakeholder",
"description":"The client is asking for the project to be scaled down!",
"choices":["Propose a reason why it should stay?","Scale down project?"],
"outcomes":["",""]
},
{
"name":"newFeature",
"type":"Backlog",
"description":"The client is asking for a new feature!",
"choices":["",""],
"outcomes":["",""]
}
]
