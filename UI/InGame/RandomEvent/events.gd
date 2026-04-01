extends Node

#Types: BackEnd, FrontEnd, Documenting, Stakeholder, Backlog
var events = [
{
"name":"backendBug",
"type":"BackEnd",
"description":"A critical bug has been discovered in the backend API! Users are reporting failed transactions. How do you want to handle this?",
"choices":["Assign extra developers to fix it quickly","Apply a temporary hotfix","Ignore it for now and hope it resolves itself"],
"outcomes":[0,0,0,0],
"reliabilityInfluence":[-1,-1,1,1]
},
{
"name":"uiRedesignRequest",
"type":"FrontEnd",
"description":"The client has requested a redesign of the user interface. They feel the current layout is confusing for end users. What is your decision?",
"choices":["Commit to a full UI redesign","Make minor adjustments to address key concerns","Decline the request and keep the current design"],
"outcomes":[0,0,0,0],
"reliabilityInfluence":[-1,-1,1,1]
},
{
"name":"outdatedDocumentation",
"type":"Documenting",
"description":"Your team has noticed that the project documentation is severely outdated. New team members are struggling to onboard. How do you proceed?",
"choices":["Dedicate time this sprint to fully update all docs","Update documentation incrementally alongside development","Skip it and focus on feature development"],
"outcomes":[0,0,0,0],
"reliabilityInfluence":[-1,-1,1,1]
},
{
"name":"databasePerformance",
"type":"BackEnd",
"description":"Database queries are running significantly slower than expected, causing timeouts in production. What approach do you take?",
"choices":["Optimize the database queries directly","Implement a caching layer to reduce database load","Scale up server resources to handle the load"],
"outcomes":[0,0,0,0],
"reliabilityInfluence":[-1,-1,1,1]
},
{
"name":"frontendFrameworkUpdate",
"type":"FrontEnd",
"description":"A major update for your frontend framework has been released with important security patches and new features. What do you do?",
"choices":["Update immediately to the latest version","Schedule the update for the next sprint","Stay on the current version for stability"],
"outcomes":[0,0,0,0],
"reliabilityInfluence":[-1,-1,1,1]
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
