extends Node



var projects = [
{
"name":"Project 1",
"description":"This is a description of the project",
"frontEndScalar":1,
"backEndScalar":1,
"documentingScalar":1,
"baseSprintAmount":5,
"baseSprintLength":3,
"baseSprintMetricAmount":3,
"preferredMethodology":"Agile",
#The total amount of Metrics should be a multiple of "baseSprintMetricAmount" times "baseSprintAmount".
"frontEndMetrics":{},
"backEndMetrics":{},
"documentingMetrics":{}
},
{
"name":"Food Delivery App",
"description":"To allow for users to order food from restaurants from wherever!",
"frontEndScalar":1.3,
"backEndScalar":1.3,
"documentingScalar":.3,
"baseSprintAmount":3,
"baseSprintLength":4,
"baseSprintMetricAmount":3,
"preferredMethodology":"Agile",
"frontEndMetrics":{0:"Restaurant Page",1:"User Page",2:"Order from restaurant functionality",3:"Order tracking"},
"backEndMetrics":{0:"Database for restaurants",1:"Database for users",2:"Database for delivery drivers",3:"Secure Payment Processing"},
"documentingMetrics":{0:"Guide on how a restaurant can be added to the database"}
}
]

#The constain influences add or subtract onto the project's metrics.
var constraints = [
{
"name":"Moderate Complexity",
"influence":{
"frontEndScaling":.2,
"backEndScaling":.2,
"documentingScaling":.1,
"sprintAmount":1,
"sprintLength":2,
"sprintMetricAmount":0,
"randomEventChance":.3
}
}
]