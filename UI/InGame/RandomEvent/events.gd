extends Node

#Types: BackEnd, FrontEnd, Documenting, Stakeholder, Backlog
var events = [
{
"name":"CodeReviewBE1",
"type":"BackEnd",
"description":"Review this code and find the error.\n [img=600x250]res://UI/InGame/RandomEvent/eventResources/CodeReviewBE1/codeInQuestion.png[/img]",
"choices":["Offset answer if 0","Silent Error Supression","Length check array","LINQ Approach to handle iteration of array"],
"outcomes":[-.075,-.1,.05,.1],
"reliabilityInfluence":[-1,-1,1,1]
},
{
"name":"CodeReviewFE1",
"type":"FrontEnd",
"description":"Review this code and find the error.\n [img = ]",
"choices":["","","",""],
"outcomes":[0,0,0,0],
"reliabilityInfluence":[-1,-1,1,1]
},
{
"name":"forgotToSave",
"type":"Documenting",
"description":"The document's autosave feature is not working! Some progress is lost!",
"choices":["Lose Documentation."],
"outcomes":[-.15],
"reliabilityInfluence":[-1]
},
{ #Stakeholder outcomes impact the Project sprint length, sprint amount,and metrics per sprint, and appear in the outcomes array in the same order.
"name":"scaleDownProject",
"type":"Stakeholder",
"description":"The client is asking for the project to be scaled down!",
"choices":["Propose a reason why it should stay?","Scale down project?"],
"outcomes":[0,[0,-1,1]],
"reliabilityInfluence":[-1,1]
},
{ #Backlog outcomes are in arrays, outcomes[0] is the backlog item name, outcomes[1] is the metric it is based on, outcomes[2] is the amount of the metric.
"name":"newBacklog1",
"type":"Backlog",
"description":"The client is asking for a mobile front end for the project!",
"choices":["Propose that it is unfeasible","Add mobile front end to the backlog"],
"outcomes":[0,["Mobile Front End","frontEnd",8]],
"reliabilityInfluence":[-1,1]
}
]
