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
"name": "Moderate Complexity",
"influence":{
"frontEndScaling":.2,
"backEndScaling":.2,
"documentingScaling":.1,
"sprintAmount":1,
"sprintLength":2,
"sprintMetricAmount":0,
"randomEventChance":.3
},

}

# -------------------- NEW CONSTRAINTS ADDED --------------------

# Confusing Client:
# Requirements are unclear, frequently changing, or poorly communicated.
# Leads to rework, more documentation, and higher uncertainty during development.
{
"name": "Confusing Client",
"influence":{
"frontEndScaling":.1,
"backEndScaling":.1,
"documentingScaling":.3,
"sprintAmount":2,
"sprintLength":2,
"sprintMetricAmount":1,
"randomEventChance":.5
},
},

# Nonchalant Client:
# Very relaxed and not actively involved. Slow responses and low urgency.
# Causes longer timelines but fewer sudden disruptions or change requests.
{
"name": "Nonchalant Client",
"influence":{
"frontEndScaling":0,
"backEndScaling":0,
"documentingScaling":-.1,
"sprintAmount":1,
"sprintLength":3,
"sprintMetricAmount":0,
"randomEventChance":-.2
},
},

# Savvy Client:
# Technically knowledgeable and detail-oriented.
# Places strong emphasis on high-quality front-end and back-end implementation.
{
"name": "Savvy Client",
"influence":{
"frontEndScaling":.4,
"backEndScaling":.4,
"documentingScaling":0,
"sprintAmount":0,
"sprintLength":0,
"sprintMetricAmount":1,
"randomEventChance":.1
},
},

# Business Client:
# Focused on documentation, reporting, and overall business value.
# Prioritizes clear documentation over deep technical complexity.
{
"name": "Business Client",
"influence":{
"frontEndScaling":0,
"backEndScaling":0,
"documentingScaling":.5,
"sprintAmount":1,
"sprintLength":1,
"sprintMetricAmount":1,
"randomEventChance":.1
},
},

# Impatient Client:
# Wants quick results and fast delivery with little tolerance for delays.
# Shortens timelines but increases pressure and unexpected issues.
{
"name": "Impatient Client",
"influence":{
"frontEndScaling":.2,
"backEndScaling":.2,
"documentingScaling":-.2,
"sprintAmount":-1,
"sprintLength":-1,
"sprintMetricAmount":0,
"randomEventChance":.6
},
}

]
