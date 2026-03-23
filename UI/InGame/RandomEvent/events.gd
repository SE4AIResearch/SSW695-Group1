extends Node

#Types: BackEnd, FrontEnd, Documenting, Stakeholder, Backlog
var events = [
{
"name":"CodeReviewBE1",
"type":"BackEnd",
"description":"Review this code and find the error.\n [img = ]",
"choices":["","","",""],
"outcomes":["","","",""]
},
{
"name":"CodeReviewFE1",
"type":"FrontEnd",
"description":"Review this code and find the error.\n [img = ]",
"choices":["","","",""],
"outcomes":["","","",""]
},
{
"name":"forgotToSave",
"type":"Documenting",
"description":"The autosave feature is not working! Some progress is lost from the documentation!",
"choices":["Suffer the consequences"],
"outcomes":[-.15]
},
{
"name":"scaleDownProject",
"type":"Stakeholder",
"description":"The client is asking for the project to be scaled down!",
"choices":["","","",""],
"outcomes":["","","",""]
},
{
"name":"newFeature",
"type":"Backlog",
"description":"The client is asking for a new feature!",
"choices":["","","",""],
"outcomes":["","","",""]
}
]
