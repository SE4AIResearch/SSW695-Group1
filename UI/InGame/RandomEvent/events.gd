extends Node

#Types: BackEnd, FrontEnd, Documenting
# outcomes are Dictionaries that modify PlayerTool.currentMetrics
var events = [
{
"name":"backendBug",
"type":"BackEnd",
"description":"A critical bug has been discovered in the backend API! Users are reporting failed transactions. How do you want to handle this?",
"choices":["Assign extra developers to fix it quickly","Apply a temporary hotfix","Ignore it for now and hope it resolves itself"],
"outcomes":[{"backEnd":3,"frontEnd":-1},{"backEnd":1},{"backEnd":-2,"reliability":-1}]
},
{
"name":"uiRedesignRequest",
"type":"FrontEnd",
"description":"The client has requested a redesign of the user interface. They feel the current layout is confusing for end users. What is your decision?",
"choices":["Commit to a full UI redesign","Make minor adjustments to address key concerns","Decline the request and keep the current design"],
"outcomes":[{"frontEnd":3,"documenting":-1},{"frontEnd":1,"stakeholderSatisfaction":1},{"frontEnd":-1}]
},
{
"name":"outdatedDocumentation",
"type":"Documenting",
"description":"Your team has noticed that the project documentation is severely outdated. New team members are struggling to onboard. How do you proceed?",
"choices":["Dedicate time this sprint to fully update all docs","Update documentation incrementally alongside development","Skip it and focus on feature development"],
"outcomes":[{"documenting":3,"frontEnd":-1,"backEnd":-1},{"documenting":1},{"documenting":-2}]
},
{
"name":"databasePerformance",
"type":"BackEnd",
"description":"Database queries are running significantly slower than expected, causing timeouts in production. What approach do you take?",
"choices":["Optimize the database queries directly","Implement a caching layer to reduce database load","Scale up server resources to handle the load"],
"outcomes":[{"backEnd":2},{"backEnd":3,"documenting":-1},{"backEnd":1}]
},
{
"name":"frontendFrameworkUpdate",
"type":"FrontEnd",
"description":"A major update for your frontend framework has been released with important security patches and new features. What do you do?",
"choices":["Update immediately to the latest version","Schedule the update for the next sprint","Stay on the current version for stability"],
"outcomes":[{"frontEnd":3,"backEnd":-1},{"frontEnd":1},{"frontEnd":-1,"documenting":1}]
}
]
