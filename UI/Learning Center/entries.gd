extends Node

var groups = [
	{
		"id": "foundations",
		"title": "Foundations",
		"topics": ["sdlcOverview", "tutorials"]
	},
	{
		"id": "methodologies",
		"title": "Methodologies",
		"topics": ["agile", "waterfall", "vModel", "spiral"]
	},
	{
		"id": "projectManagement",
		"title": "Project Management",
		"topics": ["projectConstraints", "stakeholderManagement", "sprintPlanning", "riskManagement"]
	}
]

var topic_pages = {
	"sdlcOverview": {
		0: "Software Development Life Cycle (SDLC)\n\nThe Software Development Life Cycle is a structured framework that defines the stages involved in developing a software application from start to finish. These stages typically include Planning, Requirements Analysis, Design, Implementation, Testing, Deployment, and Maintenance.",
		1: "SDLC Phases\n\nPlanning: Define the project scope, goals, and feasibility.\n\nRequirements Analysis: Gather and document what the software must do.\n\nDesign: Create the architecture and technical blueprint.\n\nImplementation: Write the actual code.\n\nTesting: Verify the software works as intended.\n\nDeployment: Release the software to end users.\n\nMaintenance: Fix bugs and add improvements over time.",
		2: "How It Affects the Game\n\nIn Software Development Tycoon, you manage a project through the full SDLC. Your decisions during each phase directly impact your project's Key Performance Indicators (KPIs): Front End, Back End, Documentation, Reliability, and Stakeholder Satisfaction. Understanding the SDLC helps you plan sprints, allocate workers, and respond to events more effectively."
	},
	"tutorials": {
		0: "Tutorials\n\nRevisit this page anytime if you need a refresher on how to play and navigate the game. Use Reset Tutorials if you want the tutorial popups to appear again.",
		1: "How To Play\n\nStart a new project: From the office view, click the computer and choose Start New Project. Pick a project card, confirm your choice, then choose a methodology. Use Learn More if you want to compare methodologies before locking in your choice.\n\nHow to hire workers: From the office view, click the computer, then choose Hiring. Set the budget bar first, then search. A search costs $75. Higher budgets can find stronger workers, but those workers also cost more to hire. After the search, choose one of the available candidates if you can afford them.\n\nPurchase upgrades: Click the computer and open Upgrades. Available upgrades show a Buy button with their cost. Some upgrades are locked until earlier tiers are purchased or requirements are met.\n\nAssign workers to backlog items: Open the backlog during sprint planning. Drag a worker onto a backlog or in-progress card to assign them for the week. Workers make progress when the week runs.\n\nRemove workers from backlog items: During sprint planning, drag an already assigned worker away from their card and release them without dropping onto another valid item. That frees the worker. You can also drag the worker onto a different backlog item to move their assignment.\n\nView previous projects in the portfolio: Click the computer and open Project Portfolio. Completed projects appear there with their project results, earned currency, and KPI information.",
		2: "Stamina Bar\n\nThe stamina bar shows whether a worker is ready, working, or recovering. Yellow means the worker is working and stamina is ticking down. Blue means the worker is recovering until the bar fills again.\n\nAssigned workers spend stamina while the week is active. If a worker runs out of stamina mid-week, they begin resting. Resting workers cannot be assigned again until their stamina is full, so spread work across the team when possible."
	},
	"agile": {
		0: "Agile\n\nAgile is an iterative and incremental approach to software development. Instead of delivering the entire product at the end, Agile teams work in short cycles called sprints, continuously delivering small pieces of functionality and adapting based on feedback.",
		1: "Key Principles\n\nIndividuals and interactions over processes and tools.\n\nWorking software over comprehensive documentation.\n\nCustomer collaboration over contract negotiation.\n\nResponding to change over following a plan.\n\nAgile emphasizes flexibility, continuous improvement, and close collaboration with stakeholders throughout the project.",
		2: "How It Affects the Game\n\nWhen you choose Agile as your methodology, the project is broken into shorter sprints with more frequent delivery milestones. Random events may occur more often, simulating the dynamic nature of Agile projects. Stakeholder Satisfaction can improve faster due to frequent feedback loops, but you need to stay adaptable to shifting requirements."
	},
	"waterfall": {
		0: "Waterfall\n\nThe Waterfall model is a linear and sequential approach to software development. Each phase must be fully completed before the next one begins, and there is little room for revisiting earlier stages once they are finished.",
		1: "Waterfall Phases\n\nRequirements: All requirements are gathered upfront.\n\nDesign: The full system architecture is planned before coding.\n\nImplementation: Development follows the design exactly.\n\nTesting: Testing occurs only after implementation is complete.\n\nDeployment: The finished product is delivered as a whole.\n\nThis model works best for projects with well-defined, stable requirements.",
		2: "How It Affects the Game\n\nChoosing Waterfall means longer sprints with more structured planning. Changes mid-project are costly and harder to manage. Documentation metrics tend to be stronger since Waterfall emphasizes thorough upfront planning, but Reliability may suffer if defects are discovered late. You must plan carefully from the start since backtracking is expensive."
	},
	"vModel": {
		0: "V-Model\n\nThe V-Model (Verification and Validation Model) is an extension of the Waterfall model where each development phase has a corresponding testing phase. The left side of the 'V' represents development stages (requirements, design, implementation), while the right side represents their matching test stages (unit testing, integration testing, system testing, acceptance testing).",
		1: "V-Model Phases\n\nRequirements Analysis <-> Acceptance Testing: User requirements are defined and matched with acceptance criteria.\n\nSystem Design <-> System Testing: The overall system architecture is designed and later validated as a whole.\n\nDetailed Design <-> Integration Testing: Individual modules are designed and later tested for how they work together.\n\nImplementation <-> Unit Testing: Code is written and each unit is tested against its specification.\n\nThe key principle is that test planning happens in parallel with each development phase, not as an afterthought.",
		2: "How It Affects the Game\n\nWhen you choose V-Model, documentation requirements are higher because every feature must have a corresponding test case planned from the start. Sprints are more structured with phase gates. Reliability tends to improve since testing is tightly coupled with development, but the rigid structure means changes mid-project are costly. Projects like medical systems or hardware-software integrations benefit from this approach where accuracy and traceability are critical."
	},
	"spiral": {
		0: "Spiral Model\n\nThe Spiral Model is a risk-driven development methodology that combines elements of iterative development with systematic risk analysis. Development proceeds in cycles (spirals), and each cycle includes four key activities: Planning, Risk Analysis, Engineering, and Evaluation. The model is especially suited for large, complex, and high-risk projects.",
		1: "Spiral Phases (Per Cycle)\n\nPlanning: Define objectives, alternatives, and constraints for the current cycle.\n\nRisk Analysis: Identify and evaluate risks, then develop strategies to mitigate them. This is the most distinctive feature of the Spiral Model.\n\nEngineering: Develop and test a prototype or increment of the product.\n\nEvaluation: Review the results with stakeholders and plan the next cycle.\n\nEach spiral builds on the previous one, progressively refining the product while continuously managing risk.",
		2: "How It Affects the Game\n\nWhen you choose the Spiral methodology, each sprint cycle includes a dedicated risk assessment phase. Back End complexity tends to be high because Spiral projects often involve cutting-edge or uncertain technology (such as AI algorithms or real-time systems). Random events may have greater impact since the project operates in a high-uncertainty environment. Successful risk management across cycles is key to keeping the project on track. Documentation includes risk analysis reports for each iteration."
	},
	"projectConstraints": {
		0: "Project Constraints\n\nProject constraints refer to the limitations that affect how a project can be executed. The most common framework is the Triple Constraint, also known as the Iron Triangle: Scope, Time, and Cost. Changing one constraint inevitably impacts the others.",
		1: "The Triple Constraint\n\nScope: The features and functionality the project must deliver.\n\nTime: The schedule or deadline for project completion.\n\nCost: The budget and resources available, including team size.\n\nBalancing these three factors is one of the most critical skills in project management. Expanding scope without adjusting time or cost leads to overworked teams and lower quality.",
		2: "How It Affects the Game\n\nIn Software Development Tycoon, project constraints directly shape your gameplay experience. Each project comes with predefined constraints that affect sprint length, the number of sprints, and the difficulty of meeting your KPI targets. Choosing to hire more workers increases cost but can improve speed. Reducing scope may hurt Stakeholder Satisfaction but improve Reliability."
	},
	"stakeholderManagement": {
		0: "Stakeholder Management\n\nStakeholder management is the process of identifying, analyzing, and strategically engaging with individuals or groups who have an interest in or influence over a project. Stakeholders can include clients, end users, team members, and management.",
		1: "Key Practices\n\nIdentification: Know who your stakeholders are and what they care about.\n\nCommunication: Keep stakeholders informed with regular updates.\n\nExpectation Management: Set realistic expectations about deliverables and timelines.\n\nFeedback Integration: Incorporate stakeholder feedback into project decisions.\n\nPoor stakeholder management is one of the leading causes of project failure.",
		2: "How It Affects the Game\n\nStakeholder Satisfaction is one of your five KPIs. Random events such as clients requesting feature changes or project scope reductions require you to balance stakeholder needs against project constraints. Ignoring stakeholder concerns lowers satisfaction, while proactively addressing their requests can boost it. Your methodology choice also influences how often you interact with stakeholders."
	},
	"sprintPlanning": {
		0: "Sprint Planning Basics\n\nSprint planning is a key ceremony in Agile development where the team decides what work to accomplish during the upcoming sprint. A sprint is a fixed time period (usually 1 to 4 weeks) during which a set of tasks must be completed.",
		1: "Sprint Planning Process\n\nDefine Sprint Goal: What do we want to achieve this sprint?\n\nSelect Backlog Items: Choose tasks from the product backlog that align with the goal.\n\nEstimate Effort: Assess how much work each task requires.\n\nAssign Resources: Allocate team members to tasks based on skills and availability.\n\nCapacity Planning: Ensure the team is not overloaded.\n\nEffective sprint planning leads to predictable delivery and better team morale.",
		2: "How It Affects the Game\n\nIn Software Development Tycoon, each sprint gives you a fixed window to allocate your workers to tasks. Assigning workers based on their strengths (Front End, Back End, Documentation skills) improves your KPI metrics more efficiently. Overloading workers reduces their stamina and effectiveness. Good sprint planning means balancing workload across your team to maximize output each sprint."
	},
	"riskManagement": {
		0: "Risk Management\n\nRisk management is the process of identifying, assessing, and controlling threats to a project. Risks can come from many sources: technical challenges, resource shortages, requirement changes, or external factors like market shifts.",
		1: "Risk Management Process\n\nIdentify: List potential risks that could affect the project.\n\nAssess: Evaluate the probability and impact of each risk.\n\nPrioritize: Focus on high-probability, high-impact risks first.\n\nMitigate: Develop strategies to reduce risk likelihood or impact.\n\nMonitor: Continuously track risks throughout the project lifecycle.\n\nCommon strategies include risk avoidance, risk transfer, risk reduction, and risk acceptance.",
		2: "How It Affects the Game\n\nRandom events in Software Development Tycoon represent real-world project risks. Events like code review failures, lost documentation, scope changes, and new feature requests all test your risk management skills. Your methodology choice and passive upgrades can influence the frequency and severity of random events. Making informed decisions when events occur is key to keeping your project on track."
	}
}

func get_learning_groups() -> Array:
	return groups

func get_topic(topic_id: String) -> Dictionary:
	var raw_topic: Dictionary = topic_pages.get(topic_id, {})
	if raw_topic.is_empty():
		return {}

	var overview: Dictionary = _split_section(str(raw_topic.get(0, "")))
	var key_concepts: Dictionary = _split_section(str(raw_topic.get(1, "")))
	var game_impact: Dictionary = _split_section(str(raw_topic.get(2, "")))

	if topic_id == "tutorials":
		return {
			"id": topic_id,
			"title": str(overview.get("heading", "")),
			"sections": [
				{
					"heading": "Overview",
					"body": str(overview.get("body", ""))
				},
				{
					"heading": str(key_concepts.get("heading", "How To Play")),
					"body": str(key_concepts.get("body", ""))
				},
				{
					"heading": str(game_impact.get("heading", "Stamina Bar")),
					"body": str(game_impact.get("body", ""))
				}
			]
		}

	return {
		"id": topic_id,
		"title": str(overview.get("heading", "")),
		"sections": [
			{
				"heading": "Overview",
				"body": str(overview.get("body", ""))
			},
			{
				"heading": str(key_concepts.get("heading", "Key Concepts")),
				"body": str(key_concepts.get("body", ""))
			},
			{
				"heading": "How It Affects the Game",
				"body": str(game_impact.get("body", ""))
			}
		]
	}

func get_default_topic_id() -> String:
	for group in groups:
		var topic_ids: Array = group.get("topics", [])
		if !topic_ids.is_empty():
			return str(topic_ids[0])
	return ""

func get_article_text(topic_id: String) -> String:
	var topic: Dictionary = get_topic(topic_id)
	if topic.is_empty():
		return ""

	var lines: Array = [str(topic.get("title", ""))]
	for section in topic.get("sections", []):
		var heading: String = str(section.get("heading", ""))
		var body: String = str(section.get("body", ""))
		if heading != "":
			lines.append("")
			lines.append(heading)
		if body != "":
			lines.append(body)
	return "\n".join(lines).strip_edges()

func _split_section(section_text: String) -> Dictionary:
	var parts: PackedStringArray = section_text.split("\n\n", false, 1)
	if parts.size() == 0:
		return {"heading": "", "body": ""}
	if parts.size() == 1:
		return {"heading": parts[0], "body": ""}
	return {
		"heading": parts[0],
		"body": parts[1]
	}
