extends Node

var projects = [
# ============ AGILE PROJECTS ============
{
"name":"Food Delivery App",
"description":"Build a food delivery platform that allows users to order food from restaurants from wherever they are. Must ship an MVP on time even if scope shifts.",
"frontEndScalar":1.3,
"backEndScalar":1.3,
"documentingScalar":0.5,
"baseSprintAmount":5,
"baseSprintLength":3,
"baseSprintMetricAmount":3,
"preferredMethodology":"Agile",
"frontEndMetrics":{0:"Restaurant Page",1:"User Page",2:"Order from restaurant functionality",3:"Order tracking with map integration",4:"Push notification UI"},
"backEndMetrics":{0:"Database for restaurants",1:"Database for users",2:"Database for delivery drivers",3:"Secure Payment Processing",4:"Dispatch and routing logic"},
"documentingMetrics":{0:"API documentation for restaurant onboarding",1:"User guide for ordering flow"}
},
{
"name":"Customer Support Ticketing Tool",
"description":"Develop a ticketing system for a support center. Usability beats feature completeness, and visible improvements must ship every sprint.",
"frontEndScalar":1.2,
"backEndScalar":1.0,
"documentingScalar":0.5,
"baseSprintAmount":6,
"baseSprintLength":3,
"baseSprintMetricAmount":3,
"preferredMethodology":"Agile",
"frontEndMetrics":{0:"Ticket creation form",1:"Agent dashboard",2:"Ticket search and filtering",3:"Customer-facing status portal",4:"Tag and priority management UI"},
"backEndMetrics":{0:"Ticket database and state management",1:"Search and indexing engine",2:"Role-based permissions system",3:"Email notification service"},
"documentingMetrics":{0:"Agent workflow guide",1:"Training documentation for new agents"}
},
# ============ WATERFALL PROJECTS ============
{
"name":"Government Tax Filing Portal",
"description":"Build a secure tax filing portal for a government agency. Scope is fixed by policy, documentation is mandatory, and phase gates are strict.",
"frontEndScalar":1.0,
"backEndScalar":1.5,
"documentingScalar":1.5,
"baseSprintAmount":10,
"baseSprintLength":4,
"baseSprintMetricAmount":3,
"preferredMethodology":"Waterfall",
"frontEndMetrics":{0:"Tax form input pages",1:"Filing status dashboard",2:"Document upload interface",3:"Confirmation and receipt page"},
"backEndMetrics":{0:"Identity verification system",1:"Tax calculation engine",2:"Audit logging and tracking",3:"Secure data storage and encryption",4:"Government API integration"},
"documentingMetrics":{0:"Requirements specification document",1:"Security compliance report",2:"Test report and sign-off records",3:"User-facing filing instructions"}
},
{
"name":"Medical Device Control Software",
"description":"Develop control software for a medical device manufacturer. Safety and regulation require full documentation and traceability. Failures are unacceptable.",
"frontEndScalar":0.8,
"backEndScalar":1.8,
"documentingScalar":1.8,
"baseSprintAmount":11,
"baseSprintLength":4,
"baseSprintMetricAmount":3,
"preferredMethodology":"Waterfall",
"frontEndMetrics":{0:"Device status display panel",1:"Alarm and alert interface",2:"Operator control dashboard"},
"backEndMetrics":{0:"Real-time sensor data processing",1:"Alarm trigger and safety logic",2:"Device state machine controller",3:"Data logging for clinical records",4:"Failsafe and recovery routines"},
"documentingMetrics":{0:"Regulatory compliance documentation",1:"Requirements traceability matrix",2:"Verification and validation report",3:"Safety risk analysis document",4:"Clinical usage manual"}
},
# ============ HYBRID PROJECTS ============
{
"name":"Banking System Upgrade",
"description":"Upgrade the core banking system and mobile app for a bank. Core transaction logic must be stable and documented, while mobile UI iterates based on usability tests.",
"frontEndScalar":1.3,
"backEndScalar":1.5,
"documentingScalar":1.2,
"baseSprintAmount":8,
"baseSprintLength":3,
"baseSprintMetricAmount":3,
"preferredMethodology":"Hybrid",
"frontEndMetrics":{0:"Mobile account dashboard",1:"Transaction history view",2:"Fund transfer interface",3:"Push notification preferences",4:"Biometric login screen"},
"backEndMetrics":{0:"Core transaction processing engine",1:"Fraud detection module",2:"Audit trail and compliance logging",3:"Third-party payment gateway integration",4:"Account security and encryption"},
"documentingMetrics":{0:"Security compliance documentation",1:"API integration guide",2:"Rollout and migration plan",3:"Incident response procedures"}
},
{
"name":"ERP Rollout",
"description":"Roll out an ERP system for a manufacturing company. Core workflows must be defined early, while dashboards and reports iterate as leaders review them.",
"frontEndScalar":1.2,
"backEndScalar":1.4,
"documentingScalar":1.3,
"baseSprintAmount":9,
"baseSprintLength":3,
"baseSprintMetricAmount":3,
"preferredMethodology":"Hybrid",
"frontEndMetrics":{0:"Inventory management dashboard",1:"Purchase order interface",2:"Sales reporting views",3:"Finance and accounting panels",4:"Warehouse tracking display"},
"backEndMetrics":{0:"Core data model and permissions engine",1:"Inventory and warehouse logic",2:"Purchasing and vendor integration",3:"Financial transaction processing",4:"Data migration pipeline"},
"documentingMetrics":{0:"Data dictionary and schema documentation",1:"User role and permission guide",2:"Migration and cutover plan",3:"Vendor integration specifications"}
}
]

#The constraint influences add or subtract onto the project's metrics.
var constraints = [
{
"name":"Moderate Complexity",
"frontEndScaling":1.2,
"backEndScaling":1.2,
"documentingScaling":1.1,
"sprintAmount":1,
"sprintLength":2,
"sprintMetricAmount":0,
"randomEventChance":1.15
},
{
"name":"High Complexity",
"frontEndScaling":1.4,
"backEndScaling":1.4,
"documentingScaling":1.3,
"sprintAmount":2,
"sprintLength":3,
"sprintMetricAmount":1,
"randomEventChance":1.35
},
{
"name":"Confusing Client",
"frontEndScaling":1,
"backEndScaling":1,
"documentingScaling":1.5,
"sprintAmount":0,
"sprintLength":0,
"sprintMetricAmount":0,
"randomEventChance":1.75
}
]
