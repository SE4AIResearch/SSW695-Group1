extends Node

# Types: BackEnd, FrontEnd, Documenting, Stakeholder, Backlog
# General FE/BE/Doc outcomes are dictionaries of metric deltas.
# Stakeholder outcomes are [sprint_amount_delta, sprint_length_delta, sprint_metric_amount_delta].
# Backlog outcomes are [metric_key, backlog_label, amount].

var general_events = [
{
"name":"backendBug",
"type":"BackEnd",
"description":"A critical bug has been discovered in the backend API! Users are reporting failed transactions. How do you want to handle this?",
"choices":["Assign extra developers to fix it quickly","Apply a temporary hotfix","Ignore it for now and hope it resolves itself"],
"outcomes":[{"backEnd":2,"reliability":1},{"backEnd":1,"reliability":1},{"backEnd":-2,"reliability":0}]
},
{
"name":"uiRedesignRequest",
"type":"FrontEnd",
"description":"The client has requested a redesign of the user interface. They feel the current layout is confusing for end users. What is your decision?",
"choices":["Commit to a full UI redesign","Make minor adjustments to address key concerns","Decline the request and keep the current design"],
"outcomes":[{"frontEnd":1,"reliability":1},{"frontEnd":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"outdatedDocumentation",
"type":"Documenting",
"description":"Your team has noticed that the project documentation is severely outdated. New team members are struggling to onboard. How do you proceed?",
"choices":["Dedicate time this sprint to fully update all docs","Update documentation incrementally alongside development","Skip it and focus on feature development"],
"outcomes":[{"documenting":3,"reliability":1},{"documenting":1,"reliability":1},{"documenting":-2,"reliability":0}]
},
{
"name":"databasePerformance",
"type":"BackEnd",
"description":"Database queries are running significantly slower than expected, causing timeouts in production. What approach do you take?",
"choices":["Optimize the database queries directly","Implement a caching layer to reduce database load","Scale up server resources to handle the load"],
"outcomes":[{"backEnd":2,"reliability":1},{"backEnd":3,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"frontendFrameworkUpdate",
"type":"FrontEnd",
"description":"A major update for your frontend framework has been released with important security patches and new features. What do you do?",
"choices":["Update immediately to the latest version","Schedule the update for the next sprint","Stay on the current version for stability"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"teamMemberSickLeave",
"type":"BackEnd",
"description":"One of your key developers has called in sick and will be out for the rest of the sprint. How do you adjust?",
"choices":["Redistribute their tasks among the remaining team","Reduce the sprint scope to match reduced capacity","Push the team to work overtime to cover the gap"],
"outcomes":[{"backEnd":1,"reliability":1},{"reliability":1,"documenting":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"securityVulnerability",
"type":"BackEnd",
"description":"A security audit has revealed a vulnerability in your application. User data could be at risk if it is not addressed. What do you do?",
"choices":["Stop all development and fix the vulnerability immediately","Schedule a fix for the next sprint","Apply a temporary workaround and document it"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":-1,"reliability":0},{"backEnd":1,"documenting":1,"reliability":1}]
},
{
"name":"clientFeedbackSession",
"type":"FrontEnd",
"description":"The client wants to schedule an unplanned feedback session to review the current state of the product. How do you respond?",
"choices":["Prepare a full demo and present to the client","Show a quick informal walkthrough","Postpone the meeting until the next milestone"],
"outcomes":[{"frontEnd":2,"reliability":1},{"frontEnd":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"technicalDebtAccumulating",
"type":"BackEnd",
"description":"Your team reports that technical debt is piling up. Code quality is declining and new features are taking longer to build. What is your plan?",
"choices":["Dedicate this sprint to refactoring","Allocate 20% of each sprint to address tech debt gradually","Ignore it and keep shipping features"],
"outcomes":[{"backEnd":3,"documenting":1,"reliability":1},{"backEnd":1,"documenting":1,"reliability":1},{"backEnd":-2,"reliability":0}]
},
{
"name":"newTeamToolProposal",
"type":"Documenting",
"description":"A team member suggests adopting a new project management tool that could improve workflow efficiency but requires migration effort. What do you decide?",
"choices":["Adopt the new tool immediately and migrate everything","Run a trial alongside the current tool this sprint","Stick with the current tool to avoid disruption"],
"outcomes":[{"documenting":2,"reliability":1},{"documenting":1,"reliability":1},{"documenting":-1,"reliability":0}]
},
{
"name":"scaleDownProject",
"type":"Stakeholder",
"description":"The client is asking for the project to be scaled down!",
"choices":["Propose a reason why it should stay?","Scale down project?"],
"outcomes":[{"stakeholderSatisfaction":1,"reliability":1},{"stakeholderSatisfaction":-1,"reliability":0}]
},
{
"name":"newBacklog1",
"type":"Backlog",
"description":"The client is asking for a mobile front end for the project!",
"choices":["Propose that it is unfeasible","Add mobile front end to the backlog"],
"outcomes":[{"stakeholderSatisfaction":-1,"reliability":0},["frontEnd","Mobile Front End",1]]
}
]

var project_events = {
"Food Delivery App":[
{
"name":"deliveryDriverGPS",
"type":"BackEnd",
"description":"Delivery drivers are reporting inaccurate GPS tracking, causing late deliveries and customer complaints. How do you handle this?",
"choices":["Rebuild the location tracking module from scratch","Integrate a third-party GPS service","Add manual location correction for drivers"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"paymentGatewayOutage",
"type":"BackEnd",
"description":"Your payment gateway provider is experiencing intermittent outages, blocking users from completing orders. What do you do?",
"choices":["Integrate a backup payment provider immediately","Implement a retry mechanism with user notification","Wait for the provider to resolve the issue"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"frontEnd":1,"reliability":1},{"backEnd":-2,"reliability":0}]
},
{
"name":"restaurantOnboarding",
"type":"FrontEnd",
"description":"Restaurant partners are complaining that the onboarding process is too complicated and they are dropping out. What is your approach?",
"choices":["Redesign the entire restaurant registration flow","Add a step-by-step guided wizard","Provide video tutorials instead of changing the UI"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"documenting":1,"reliability":1},{"documenting":-2,"reliability":0}],
"learn_more_topic":"stakeholderManagement",
"teaching_message":"This event is about feedback fit: the right choice is not universal, but volatile products reward teams that can adapt without losing control of scope.",
"methodology_effects":{
	"Agile":{
		"metric_deltas":{"stakeholderSatisfaction":3,"reliability":1},
		"outcome_summary":"Stakeholder Satisfaction improved because Agile made it easier to react to partner feedback without freezing the plan.",
		"teaching_message":"Agile fits this situation well because customer-facing changes can be absorbed into the next increment instead of treated as a project disruption."
	},
	"Waterfall":{
		"metric_deltas":{"stakeholderSatisfaction":-4,"reliability":0},
		"outcome_summary":"Stakeholder Satisfaction fell because the requested change arrived after the plan had already hardened.",
		"teaching_message":"Waterfall is still playable, but late UX changes are expensive in a rigid plan. That is the methodology-fit lesson the slice is trying to teach."
	}
}
},
{
"name":"orderTrackingUX",
"type":"FrontEnd",
"description":"User feedback shows that the order tracking page is confusing. Customers cannot tell where their food is. How do you improve it?",
"choices":["Add a real-time map with driver location","Simplify the status display with clear progress steps","Add push notifications for each delivery stage"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"reliability":1},{"frontEnd":-1,"reliability":0}],
"learn_more_topic":"agile",
"teaching_message":"The player should see that visible user feedback is part of the job, not a warning message to avoid.",
"methodology_effects":{
	"Agile":{
		"metric_deltas":{"stakeholderSatisfaction":2,"reliability":1},
		"outcome_summary":"Stakeholder Satisfaction increased because the team could turn feedback into a visible UX improvement quickly.",
		"teaching_message":"Agile reinforces short learning loops: feedback changes the product, and the product teaches the player why process fit matters."
	},
	"Waterfall":{
		"metric_deltas":{"stakeholderSatisfaction":-3,"reliability":0},
		"outcome_summary":"Stakeholder Satisfaction slipped because even a reasonable UX fix competed with a rigid pre-committed plan.",
		"teaching_message":"On a stable compliance-heavy project that rigidity can help. On a changing consumer MVP, it becomes a cost."
	}
}
},
{
"name":"deliveryAppSurge",
"type":"BackEnd",
"description":"A marketing campaign has gone viral and orders have tripled overnight! The system is struggling under the load. What do you do?",
"choices":["Scale infrastructure and optimize queries urgently","Implement rate limiting to control the load","Temporarily disable the promotion to stabilize"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}],
"learn_more_topic":"riskManagement",
"teaching_message":"This event is about just-in-time consequence feedback. The player should feel how ignored technical risk turns into user-facing pain.",
"methodology_effects":{
	"Agile":{
		"metric_deltas":{"reliability":1},
		"outcome_summary":"Reliability improved because the team had already been iterating and could react quickly to the surge.",
		"teaching_message":"Agile did not remove the problem, but it shortened the feedback and response loop."
	},
	"Waterfall":{
		"metric_deltas":{"reliability":0,"stakeholderSatisfaction":-2},
		"outcome_summary":"Reliability and Stakeholder Satisfaction fell because a rigid plan left less room for quick operational response.",
		"teaching_message":"This is the consequence-based lesson your professor described: the game should let the player choose the poor fit, then feel the cost."
	}
}
}
],
"Customer Support Ticketing Tool":[
{
"name":"agentWorkflowChange",
"type":"FrontEnd",
"description":"After testing the prototype, support agents say the ticket workflow does not match how they actually work. They want major changes. What do you do?",
"choices":["Redesign the workflow based on agent feedback","Make targeted adjustments to the most painful steps","Explain the design rationale and keep the current flow"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"ticketSearchSlow",
"type":"BackEnd",
"description":"Agents report that searching for tickets is painfully slow, especially when filtering by tags and date ranges. How do you address this?",
"choices":["Rebuild the search engine with proper indexing","Add caching for common search queries","Limit search results and add pagination"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"permissionConfusion",
"type":"BackEnd",
"description":"The IT team reports that the role-based permission system is allowing agents to see tickets they should not have access to. What do you do?",
"choices":["Audit and rebuild the entire permissions model","Add a quick fix for the specific access violations","Document the known issues and plan a fix next sprint"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"customerPortalRequest",
"type":"FrontEnd",
"description":"The support manager wants a customer-facing portal so users can check ticket status themselves, reducing call volume. This was not originally scoped. How do you respond?",
"choices":["Add it to the current sprint","Schedule it for the next sprint with proper planning","Decline and suggest it as a future enhancement"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"trainingGapDiscovered",
"type":"Documenting",
"description":"New agents are making frequent errors because there is no training documentation for the ticketing system. The training team is asking for help. What do you do?",
"choices":["Write comprehensive training docs this sprint","Create a quick-start guide covering the basics","Record a video walkthrough instead of written docs"],
"outcomes":[{"documenting":3,"reliability":1},{"documenting":2,"reliability":1},{"documenting":-1,"reliability":0}]
}
],
"Government Tax Filing Portal":[
{
"name":"complianceAuditSurprise",
"type":"Documenting",
"description":"The compliance team has scheduled an unplanned audit and needs full documentation of all requirements and design decisions immediately. How do you respond?",
"choices":["Halt development and prepare all audit documents","Assign a dedicated person to compile docs while others continue","Request a delay on the audit"],
"outcomes":[{"documenting":3,"reliability":1},{"documenting":2,"reliability":1},{"documenting":-1,"reliability":0}]
},
{
"name":"taxCalculationError",
"type":"BackEnd",
"description":"Testers have discovered that the tax calculation engine produces incorrect results for certain edge cases involving multiple deductions. What do you do?",
"choices":["Rewrite the calculation logic with comprehensive test coverage","Fix only the identified edge cases","Add warnings for edge cases and document known limitations"],
"outcomes":[{"backEnd":3,"documenting":1,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"identityVerificationFailure",
"type":"BackEnd",
"description":"The identity verification system is rejecting valid users at a high rate, blocking them from filing their taxes. What is your approach?",
"choices":["Overhaul the verification algorithm","Add a manual override process for rejected users","Adjust the sensitivity threshold to reduce false rejections"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":1,"frontEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"accessibilityRequirement",
"type":"FrontEnd",
"description":"A government accessibility review has flagged that the portal does not meet required accessibility standards. Changes are mandatory. What do you do?",
"choices":["Conduct a full accessibility overhaul of all pages","Fix the critical accessibility issues first","Hire an accessibility consultant to guide the remediation"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":-1,"reliability":0},{"frontEnd":2,"documenting":1,"reliability":1}]
},
{
"name":"dataEncryptionUpgrade",
"type":"BackEnd",
"description":"The security team requires an upgrade to the data encryption standard before launch. This was not in the original plan. How do you proceed?",
"choices":["Implement the new encryption standard immediately","Request a formal change approval and schedule it","Push back and propose the upgrade for the next release"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":1,"documenting":2,"reliability":1},{"backEnd":-1,"reliability":0}]
}
],
"Medical Device Control Software":[
{
"name":"sensorCalibrationDrift",
"type":"BackEnd",
"description":"Clinical testing reveals that sensor readings drift over time, producing inaccurate measurements. This is a safety-critical issue. What do you do?",
"choices":["Redesign the calibration algorithm with redundancy checks","Add periodic auto-recalibration routines","Document the drift range and add manual calibration instructions"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"alarmFalsePositives",
"type":"BackEnd",
"description":"The alarm system is triggering too many false positives, causing alarm fatigue among clinical staff. How do you address this?",
"choices":["Retune the alarm thresholds based on clinical data","Implement a smart filtering algorithm to reduce noise","Add an alarm acknowledgment system to reduce disruption"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"regulatoryDocGap",
"type":"Documenting",
"description":"The regulatory team has identified gaps in your requirements traceability matrix. Submission cannot proceed without it. What do you do?",
"choices":["Stop development and complete the traceability matrix","Assign a dedicated team member to work on it in parallel","Request an extension from the regulatory body"],
"outcomes":[{"documenting":3,"reliability":1},{"documenting":2,"reliability":1},{"documenting":-1,"reliability":0}]
},
{
"name":"failsafeTestFailure",
"type":"BackEnd",
"description":"During verification testing, the failsafe recovery routine did not activate correctly under simulated power loss. What is your response?",
"choices":["Redesign the failsafe mechanism and rerun all tests","Debug the specific failure scenario and patch it","Add redundant failsafe layers as a backup"],
"outcomes":[{"backEnd":3,"documenting":1,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"clinicalTrialFeedback",
"type":"FrontEnd",
"description":"Feedback from a clinical trial indicates that the operator interface is difficult to read under bright operating room lights. What do you do?",
"choices":["Redesign the display with high-contrast medical-grade visuals","Add a brightness and contrast adjustment setting","Provide anti-glare screen covers as a hardware solution"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"reliability":1},{"frontEnd":-1,"reliability":0}]
}
],
"Hospital Appointment Booking System":[
{
"name":"patientDataValidation",
"type":"BackEnd",
"description":"Unit testing reveals that the patient data validation module accepts invalid date formats, which could corrupt medical records. What do you do?",
"choices":["Rewrite the validation logic with comprehensive test cases","Add input masks on the frontend to prevent invalid entries","Fix the specific failing test cases only"],
"outcomes":[{"backEnd":3,"documenting":1,"reliability":1},{"frontEnd":2,"backEnd":1,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"schedulingConflict",
"type":"BackEnd",
"description":"Integration testing shows that the scheduling engine allows double-booking of doctors in certain edge cases. What is your approach?",
"choices":["Redesign the booking algorithm with conflict detection","Add a validation check before confirming each appointment","Lock the time slot immediately when a booking starts"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"documenting":1,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"receptionStaffUsability",
"type":"FrontEnd",
"description":"Reception staff report that the appointment management interface requires too many clicks to complete common tasks. What do you do?",
"choices":["Redesign the interface with fewer steps for common workflows","Add keyboard shortcuts for frequent actions","Create a quick-action toolbar for the most used functions"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"notificationDeliveryFailure",
"type":"BackEnd",
"description":"Acceptance testing reveals that appointment reminder notifications are not being delivered reliably. Some patients are missing their appointments. What do you do?",
"choices":["Switch to a more reliable notification service provider","Implement a retry mechanism with delivery confirmation","Add SMS as a backup channel alongside email"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"privacyComplianceGap",
"type":"Documenting",
"description":"A review reveals that the system's handling of patient data does not fully comply with healthcare privacy regulations. Documentation of data flows is incomplete. What do you do?",
"choices":["Conduct a full privacy audit and update all documentation","Fix the critical compliance gaps and document them","Hire a compliance consultant to guide remediation"],
"outcomes":[{"documenting":3,"reliability":1},{"documenting":2,"backEnd":1,"reliability":1},{"documenting":-1,"reliability":0}]
}
],
"Supermarket Self-Checkout System":[
{
"name":"barcodeScanFailure",
"type":"BackEnd",
"description":"Testing reveals that the barcode scanner fails to read damaged or wrinkled barcodes, requiring manual entry for 15% of items. What do you do?",
"choices":["Implement image recognition as a fallback for failed scans","Add a quick manual product search by name or category","Improve the scanning algorithm to handle damaged barcodes"],
"outcomes":[{"backEnd":3,"reliability":1},{"frontEnd":2,"backEnd":1,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"paymentIntegrationError",
"type":"BackEnd",
"description":"During integration testing, the payment terminal intermittently fails to communicate with the checkout software, leaving transactions in a pending state. What is your plan?",
"choices":["Rebuild the hardware communication layer with better error handling","Implement a transaction recovery mechanism","Add a timeout with automatic retry logic"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"customerConfusionAtCheckout",
"type":"FrontEnd",
"description":"Store managers report that customers frequently get stuck on the payment screen and need assistance. The checkout flow is not intuitive enough. What do you do?",
"choices":["Redesign the payment flow with larger buttons and clearer instructions","Add animated step-by-step guidance on screen","Place a help button that summons a staff member"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"documenting":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"receiptPrinterJam",
"type":"BackEnd",
"description":"The receipt printing module crashes when handling long receipts with many items, causing the entire checkout session to freeze. What do you do?",
"choices":["Fix the printer driver and add receipt length handling","Switch to digital receipts via email as the primary option","Add error recovery so checkout can complete even if printing fails"],
"outcomes":[{"backEnd":3,"reliability":1},{"frontEnd":2,"documenting":1,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"inventoryMismatch",
"type":"Documenting",
"description":"Acceptance testing shows discrepancies between the checkout system's inventory counts and the actual warehouse stock. The traceability matrix for inventory updates is incomplete. What do you do?",
"choices":["Audit the entire inventory update pipeline and fix the data flow","Add real-time inventory sync verification after each transaction","Update the traceability matrix and document all inventory touchpoints"],
"outcomes":[{"backEnd":2,"documenting":1,"reliability":1},{"backEnd":3,"reliability":1},{"documenting":-1,"reliability":0}]
}
],
"Cybersecurity Threat Detection Platform":[
{
"name":"newThreatVector",
"type":"BackEnd",
"description":"A previously unknown attack vector has been discovered in the wild. Your current detection algorithms do not cover it. What do you do?",
"choices":["Develop a new detection module specifically for this threat","Update existing algorithms to include patterns from this attack","Add the threat to the monitoring watchlist and analyze in the next cycle"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"documenting":-1,"reliability":0}]
},
{
"name":"falsePositiveOverload",
"type":"BackEnd",
"description":"Security analysts are overwhelmed by false positive alerts. The anomaly detection algorithm is flagging normal traffic as suspicious. How do you adjust?",
"choices":["Retrain the detection model with better baseline data","Implement a confidence scoring system to prioritize alerts","Add analyst feedback loops to improve detection over time"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"frontEnd":1,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"monitoringIntegrationIssue",
"type":"BackEnd",
"description":"Integration with the existing security monitoring systems is producing data format mismatches, causing some events to be dropped. What is your approach?",
"choices":["Build a data normalization layer between systems","Work with the existing system team to align data formats","Log dropped events and process them in batch later"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"riskAssessmentUpdate",
"type":"Documenting",
"description":"The latest prototype cycle has revealed new risks that were not accounted for in the original risk assessment. The compliance team needs an updated report. What do you do?",
"choices":["Conduct a comprehensive risk reassessment for the entire platform","Update the risk report with only the newly discovered risks","Schedule a risk review workshop with all stakeholders"],
"outcomes":[{"documenting":3,"reliability":1},{"documenting":2,"reliability":1},{"documenting":-1,"reliability":0}]
},
{
"name":"algorithmPerformanceDrop",
"type":"BackEnd",
"description":"After the latest iteration, the threat detection algorithm's accuracy has dropped significantly when processing high-volume network traffic. What do you do?",
"choices":["Roll back to the previous version and investigate the regression","Optimize the algorithm for high-volume scenarios specifically","Scale up processing infrastructure to handle the load"],
"outcomes":[{"backEnd":2,"reliability":1},{"backEnd":3,"reliability":1},{"backEnd":-1,"reliability":0}]
}
],
"Smart City Traffic Management Platform":[
{
"name":"sensorDataInconsistency",
"type":"BackEnd",
"description":"Real-time traffic sensors at several intersections are sending inconsistent data, causing the prediction model to generate unreliable forecasts. What do you do?",
"choices":["Add data validation and anomaly filtering at the ingestion layer","Recalibrate the sensors and establish baseline readings","Build a fallback model that works with incomplete data"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
},
{
"name":"predictionModelBias",
"type":"BackEnd",
"description":"Testing reveals that the traffic prediction model performs well in urban areas but poorly in suburban zones due to different traffic patterns. How do you address this?",
"choices":["Train separate models for urban and suburban areas","Collect more suburban data and retrain the unified model","Add manual override capabilities for suburban predictions"],
"outcomes":[{"backEnd":3,"reliability":1},{"backEnd":2,"documenting":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"publicSafetyConflict",
"type":"FrontEnd",
"description":"The public safety department wants emergency vehicle priority controls added to the signal management dashboard, but this was not in the current cycle's scope. What do you do?",
"choices":["Add it to the current cycle given its safety importance","Prototype it in this cycle and implement fully in the next","Document the requirement and schedule it for the next cycle"],
"outcomes":[{"frontEnd":3,"reliability":1},{"frontEnd":2,"backEnd":1,"reliability":1},{"frontEnd":-1,"reliability":0}]
},
{
"name":"deploymentRiskEscalation",
"type":"Documenting",
"description":"A risk assessment during the current spiral reveals that deploying signal timing changes to a busy district without testing could cause gridlock. What is your approach?",
"choices":["Deploy to a low-traffic test zone first and measure impact","Run a simulation before any live deployment","Proceed with deployment but have a rapid rollback plan ready"],
"outcomes":[{"documenting":2,"reliability":1},{"documenting":3,"reliability":1},{"documenting":-1,"reliability":0}]
},
{
"name":"cameraIntegrationDelay",
"type":"BackEnd",
"description":"The IoT camera vendor is behind schedule on delivering the API for camera integration. Your current cycle depends on camera data for testing the analytics module. What do you do?",
"choices":["Build a camera data simulator to unblock testing","Shift focus to other modules and revisit cameras next cycle","Negotiate with the vendor to deliver a partial API sooner"],
"outcomes":[{"backEnd":2,"documenting":1,"reliability":1},{"backEnd":1,"frontEnd":2,"reliability":1},{"backEnd":-1,"reliability":0}]
}
]
}

func get_event_pool(project_name: String) -> Array:
	var pool: Array = general_events.duplicate(true)
	if project_events.has(project_name):
		pool.append_array(project_events.get(project_name).duplicate(true))
	return pool
