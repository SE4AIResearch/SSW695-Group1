extends Node

signal projectSelected
signal deadlineReached
signal sprintComplete
signal hireSelected
signal levelLoaded
signal weekPassed
signal statsChanged
signal backlogUpdated
signal loopStateChanged
signal weekResolved
signal weekTimerUpdated
signal projectCompleted
signal currencyChanged
signal scoreChanged

const LOOP_NO_PROJECT := "no_project"
const LOOP_PLANNING_WEEK := "planning_week"
const LOOP_ACTIVE_WEEK := "active_week"
const LOOP_RESOLVING_WEEK := "resolving_week"
const LOOP_SPRINT_REVIEW := "sprint_review"
const LOOP_PROJECT_SUMMARY := "project_summary"
const WEEK_DURATION_SECONDS := 10

var level

var currentProject
var projectAmount: int = 0
var currentMetrics := {
	"frontEnd": 0,
	"backEnd": 0,
	"documenting": 0,
	"reliability": 0,
	"stakeholderSatisfaction": 0,
}
var currentMetricProgress := {}
var completedMetrics := []
var currentWeekTime: int = 0
var currentProjWeek: int = 0
var currentProjSprint: int = 0
var currentFEBacklogStep: int = 0
var currentBEBacklogStep: int = 0
var currentDocBacklogStep: int = 0
var workers: Array = []
var upgrades: Array = []

var loopPhase: String = LOOP_NO_PROJECT
var currency: int = 0
var score: int = 0
var weekResults: Dictionary = {}
var sprintGrade: String = ""
var selectedAssignments: Dictionary = {}
var backlogItems: Array = []
var pendingProjectSummary: Dictionary = {}
var currentSprintGoal: Dictionary = {}
var scenarioFlags: Dictionary = {}
var shouldShowWeekResultsModal: bool = false

var _backlogItemIdCounter: int = 0

func initializeNewSave():
	resetData()
	var freeWorker1 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(0))
	var freeWorker2 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(1))
	$workerHoldover.add_child(freeWorker1)
	$workerHoldover.add_child(freeWorker2)
	freeWorker1.scale = Vector2(2.5, 2.5)
	freeWorker2.scale = Vector2(2.5, 2.5)
	newHire(freeWorker1)
	newHire(freeWorker2)

# Type : 0 = Front End | 1 = Back End | 2 = Documenting | 3 = Reliability | 4 = Stakeholder Satisfaction
func changeProjectStats(type, amount):
	match type:
		0:
			currentMetrics.set("frontEnd", currentMetrics.get("frontEnd") + amount)
		1:
			currentMetrics.set("backEnd", currentMetrics.get("backEnd") + amount)
		2:
			currentMetrics.set("documenting", currentMetrics.get("documenting") + amount)
		3:
			currentMetrics.set("reliability", clampi(currentMetrics.get("reliability") + amount, 0, 100))
		4:
			currentMetrics.set("stakeholderSatisfaction", clampi(currentMetrics.get("stakeholderSatisfaction") + amount, 0, 100))
	statsChanged.emit()

func changeMetricByName(metricName: String, amount: int) -> void:
	if not currentMetrics.has(metricName):
		return
	var value = int(currentMetrics.get(metricName, 0)) + amount
	if metricName in ["reliability", "stakeholderSatisfaction"]:
		value = clampi(value, 0, 100)
	currentMetrics.set(metricName, value)
	statsChanged.emit()

func applyMetricDeltas(metricDeltas: Dictionary) -> void:
	for metricName in metricDeltas.keys():
		changeMetricByName(str(metricName), int(metricDeltas.get(metricName, 0)))

func addCurrency(amount: int) -> void:
	currency = maxi(0, currency + amount)
	currencyChanged.emit()

func addScore(amount: int) -> void:
	score = maxi(0, score + amount)
	scoreChanged.emit()

func resetData():
	currentProject = null
	projectAmount = 0
	completedMetrics = []
	currentMetricProgress = {}
	currentMetrics = {
		"frontEnd": 0,
		"backEnd": 0,
		"documenting": 0,
		"reliability": 0,
		"stakeholderSatisfaction": 0,
	}
	workers = []
	upgrades = []
	currency = 0
	score = 0
	weekResults = {}
	pendingProjectSummary = {}
	selectedAssignments = {}
	backlogItems = []
	scenarioFlags = {}
	currentSprintGoal = {}
	sprintGrade = ""
	shouldShowWeekResultsModal = false
	currentWeekTime = 0
	currentProjWeek = 0
	currentProjSprint = 0
	currentFEBacklogStep = 0
	currentBEBacklogStep = 0
	currentDocBacklogStep = 0
	_backlogItemIdCounter = 0
	loopPhase = LOOP_NO_PROJECT
	currencyChanged.emit()
	scoreChanged.emit()
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()

func resetProjectStats():
	currentProject = null
	completedMetrics = []
	currentMetricProgress = {}
	currentMetrics = {
		"frontEnd": 0,
		"backEnd": 0,
		"documenting": 0,
		"reliability": 0,
		"stakeholderSatisfaction": 0,
	}
	weekResults = {}
	pendingProjectSummary = {}
	selectedAssignments = {}
	backlogItems = []
	scenarioFlags = {}
	currentSprintGoal = {}
	sprintGrade = ""
	shouldShowWeekResultsModal = false
	currentWeekTime = 0
	currentProjWeek = 0
	currentProjSprint = 0
	currentFEBacklogStep = 0
	currentBEBacklogStep = 0
	currentDocBacklogStep = 0
	_backlogItemIdCounter = 0
	loopPhase = LOOP_NO_PROJECT
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()

func _ready() -> void:
	var workerNode = Node2D.new()
	workerNode.name = "workerHoldover"
	add_child(workerNode)

func newProject(project) -> void:
	resetProjectStats()
	currentProject = project
	currentProjWeek = 1
	currentProjSprint = 1
	projectAmount += 1
	currentMetrics.set("reliability", 50)
	currentMetrics.set("stakeholderSatisfaction", 50)
	_build_backlog_for_project(project)
	_prepare_sprint_context(currentProjSprint)
	loopPhase = LOOP_PLANNING_WEEK
	projectSelected.emit()
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()

func newHire(worker) -> void:
	worker.name = worker.personName
	workers.append(worker)
	worker.reparent($workerHoldover)
	hireSelected.emit()

func newUpgrade(upgrade) -> void:
	upgrades.append(upgrade)

func canAdvanceWeek() -> bool:
	return currentProject != null and loopPhase == LOOP_PLANNING_WEEK and not selectedAssignments.is_empty()

func isWeekActive() -> bool:
	return currentProject != null and loopPhase == LOOP_ACTIVE_WEEK

func startWeek() -> bool:
	if not canAdvanceWeek():
		return false
	currentWeekTime = 0
	loopPhase = LOOP_ACTIVE_WEEK
	backlogUpdated.emit()
	loopStateChanged.emit()
	weekTimerUpdated.emit()
	return true

func assignWorkerToItem(workerName: String, itemId: int) -> Dictionary:
	if currentProject == null or loopPhase != LOOP_PLANNING_WEEK:
		return {"ok": false, "reason": "You can only assign work while planning the week."}
	var item = getBacklogItemById(itemId)
	if item.is_empty():
		return {"ok": false, "reason": "That backlog item no longer exists."}
	if item.get("status") == "done":
		return {"ok": false, "reason": "That item is already complete."}
	var previousWorkerName = str(item.get("assigned_worker_name", ""))
	if previousWorkerName != "" and previousWorkerName != workerName:
		return {"ok": false, "reason": "%s is already assigned to that card." % previousWorkerName}
	unassignWorker(workerName)
	item.set("assigned_worker_name", workerName)
	if item.get("status") == "backlog":
		item.set("status", "in_progress")
	selectedAssignments.set(workerName, itemId)
	backlogUpdated.emit()
	return {"ok": true, "reason": "%s is now assigned to %s." % [workerName, item.get("name")]}

func unassignWorker(workerName: String) -> void:
	if not selectedAssignments.has(workerName):
		return
	var item = getBacklogItemById(int(selectedAssignments.get(workerName)))
	if not item.is_empty():
		item.set("assigned_worker_name", "")
		if item.get("status") == "in_progress" and int(item.get("effort_remaining", 0)) >= int(item.get("total_effort", 0)):
			item.set("status", "backlog")
	selectedAssignments.erase(workerName)
	backlogUpdated.emit()

func clearAssignments() -> void:
	for workerName in selectedAssignments.keys():
		var item = getBacklogItemById(int(selectedAssignments.get(workerName)))
		if not item.is_empty():
			item.set("assigned_worker_name", "")
	selectedAssignments.clear()

func getWorkerByName(workerName: String):
	for worker in workers:
		if worker.personName == workerName:
			return worker
	return null

func getBacklogItemById(itemId: int) -> Dictionary:
	for item in backlogItems:
		if int(item.get("id", -1)) == itemId:
			return item
	return {}

func getBacklogItemsByStatus(status: String) -> Array:
	var filtered: Array = []
	for item in backlogItems:
		if item.get("status") == status:
			filtered.append(item)
	return filtered

func getActiveBacklogItemCount() -> int:
	var count = 0
	for item in backlogItems:
		if item.get("status") != "done":
			count += 1
	return count

func advanceWeek() -> bool:
	return startWeek()

func resolveWeek() -> bool:
	if currentProject == null or loopPhase != LOOP_ACTIVE_WEEK:
		return false

	loopPhase = LOOP_RESOLVING_WEEK
	loopStateChanged.emit()

	var resolvedSprint = currentProjSprint
	var resolvedWeek = currentProjWeek
	var results = {
		"title": "Sprint %d, Week %d Results" % [resolvedSprint, resolvedWeek],
		"subtitle": str(currentSprintGoal.get("title", "")),
		"entries": [],
		"summary_text": "",
		"reward_summary": "",
		"learn_more_topic": str(currentSprintGoal.get("learnMoreTopic", "agile")),
		"continue_label": "Continue",
	}
	var completedThisWeek: Array = []

	for worker in workers:
		var assignmentId = selectedAssignments.get(worker.personName, null)
		if assignmentId == null:
			results["entries"].append({
				"player_action": "%s was left unassigned." % worker.personName,
				"outcome_summary": "No task progress was made with that worker this week.",
				"teaching_message": "Leaving capacity idle is sometimes acceptable, but every unassigned worker is delivery time you are choosing not to use.",
			})
			continue
		var item = getBacklogItemById(int(assignmentId))
		if item.is_empty():
			continue
		var resolution = _resolve_assignment(worker, item, resolvedSprint)
		results["entries"].append(resolution)
		if resolution.get("completed", false):
			completedThisWeek.append(item)

	var scenarioEntries = _apply_scenario_feedback(resolvedSprint, completedThisWeek)
	for entry in scenarioEntries:
		results["entries"].append(entry)

	clearAssignments()

	var sprintEnded = resolvedWeek >= currentProject.sprintLength
	if sprintEnded:
		var review = _build_sprint_review(resolvedSprint, completedThisWeek)
		results["reward_summary"] = review.get("reward_summary", "")
		results["entries"].append({
			"player_action": "Sprint review completed with grade %s." % review.get("grade", "C"),
			"outcome_summary": "You earned $%d and %d score." % [review.get("currency", 0), review.get("score", 0)],
			"teaching_message": str(review.get("teaching_message", "")),
		})
		sprintGrade = str(review.get("grade", "C"))
		loopPhase = LOOP_SPRINT_REVIEW
		sprintComplete.emit()
		if resolvedSprint >= currentProject.sprintAmount or _allBacklogItemsComplete():
			var finalProject = currentProject
			var projectSummary = _build_project_summary(finalProject)
			pendingProjectSummary = projectSummary
			results["continue_label"] = "View Project Summary"
			results["summary_text"] = "The project has ended. Review the final score and methodology lesson."
			currentProject = null
			backlogItems = []
			currentWeekTime = 0
			currentProjWeek = 0
			currentProjSprint = 0
			currentSprintGoal = {}
			selectedAssignments = {}
			loopPhase = LOOP_PROJECT_SUMMARY
			deadlineReached.emit()
			projectCompleted.emit()
		else:
			currentWeekTime = 0
			currentProjSprint += 1
			currentProjWeek = 1
			var nextSprintEntries = _prepare_sprint_context(currentProjSprint)
			for entry in nextSprintEntries:
				results["entries"].append(entry)
			results["summary_text"] = "Sprint %d is complete. Re-open the backlog to plan Sprint %d." % [resolvedSprint, currentProjSprint]
			loopPhase = LOOP_PLANNING_WEEK
			weekPassed.emit()
	else:
		currentWeekTime = 0
		currentProjWeek += 1
		results["summary_text"] = "Week %d is complete. Re-open the backlog to plan Week %d." % [resolvedWeek, currentProjWeek]
		loopPhase = LOOP_PLANNING_WEEK
		weekPassed.emit()

	if results.get("summary_text", "") == "":
		results["summary_text"] = _build_default_week_summary(completedThisWeek)

	weekResults = results
	shouldShowWeekResultsModal = false
	backlogUpdated.emit()
	loopStateChanged.emit()
	weekTimerUpdated.emit()
	statsChanged.emit()
	weekResolved.emit()
	return true

func setTransientResults(title: String, entries: Array, learnMoreTopic: String = "", summaryText: String = "", rewardSummary: String = "", continueLabel: String = "Continue") -> void:
	weekResults = {
		"title": title,
		"subtitle": "",
		"entries": entries,
		"summary_text": summaryText,
		"reward_summary": rewardSummary,
		"learn_more_topic": learnMoreTopic,
		"continue_label": continueLabel,
	}
	shouldShowWeekResultsModal = true
	weekResolved.emit()

func addEventBacklogItem(metricKey: String, itemName: String, effort: int = 5, reward: int = 2, isScopeChange: bool = true) -> void:
	_addBacklogItem(itemName, metricKey, effort, reward, isScopeChange, false)
	backlogUpdated.emit()

func _build_backlog_for_project(project) -> void:
	backlogItems.clear()
	_backlogItemIdCounter = 0
	_appendMetricItems(project.frontEndMetrics, "frontEnd", project.frontEndProjectMin)
	_appendMetricItems(project.backEndMetrics, "backEnd", project.backEndProjectMin)
	_appendMetricItems(project.documentingMetrics, "documenting", project.documentingProjectMin)

func _appendMetricItems(metricDictionary: Dictionary, requiredSkill: String, targetTotal: int) -> void:
	var itemCount = maxi(1, metricDictionary.size())
	for index in metricDictionary.keys():
		var itemName = str(metricDictionary.get(index, "Unnamed Task"))
		_addBacklogItem(
			itemName,
			requiredSkill,
			clampi(int(round(float(targetTotal) / itemCount)) + 2, 4, 8),
			maxi(1, int(round(float(targetTotal) / itemCount))),
			false,
			false
		)

func _addBacklogItem(itemName: String, requiredSkill: String, effort: int, metricReward: int, isScopeChange: bool, isReliabilityCritical: bool) -> void:
	_backlogItemIdCounter += 1
	backlogItems.append({
		"id": _backlogItemIdCounter,
		"name": itemName,
		"required_skill": requiredSkill,
		"effort_remaining": effort,
		"total_effort": effort,
		"status": "backlog",
		"assigned_worker_name": "",
		"metric_reward": metricReward,
		"is_scope_change": isScopeChange,
		"is_reliability_critical": isReliabilityCritical,
		"completed_in_sprint": 0,
	})

func _prepare_sprint_context(sprintNumber: int) -> Array:
	var entries: Array = []
	currentSprintGoal = {}
	if currentProject == null:
		return entries
	if currentProject.projectName == "Food Delivery App" and currentProject.tutorialSprintPlan.size() >= sprintNumber:
		currentSprintGoal = currentProject.tutorialSprintPlan[sprintNumber - 1]
		match sprintNumber:
			2:
				if not scenarioFlags.get("food_delivery_scope_change_added", false):
					_addBacklogItem("Restaurant Partner Onboarding Wizard", "frontEnd", 5, 3, true, false)
					scenarioFlags.set("food_delivery_scope_change_added", true)
				entries.append({
					"player_action": "A restaurant partner requested a late onboarding change.",
					"outcome_summary": "A new front-end scope item was added to the backlog for Sprint 2.",
					"teaching_message": "This sprint is about methodology fit: Agile absorbs volatile scope changes more gracefully than Waterfall.",
				})
			3:
				if not scenarioFlags.get("food_delivery_reliability_added", false):
					_addBacklogItem("Traffic Surge Load Test", "backEnd", 6, 4, false, true)
					scenarioFlags.set("food_delivery_reliability_added", true)
				entries.append({
					"player_action": "A traffic surge exposed scalability risk ahead of launch.",
					"outcome_summary": "A reliability-critical backend item was added to Sprint 3.",
					"teaching_message": "Fast-moving teams still need to invest in quality work before scale punishes them.",
				})
		return entries
	currentSprintGoal = {
		"title": "Sprint %d" % sprintNumber,
		"goal": "Complete the most valuable remaining work.",
		"lesson": "Balance delivery, quality, and stakeholder expectations each sprint.",
		"learnMoreTopic": "sprintPlanning",
	}
	return entries

func _resolve_assignment(worker, item: Dictionary, resolvedSprint: int) -> Dictionary:
	var metricKey = str(item.get("required_skill", "frontEnd"))
	var workerSkill = _get_worker_skill(worker, metricKey)
	var progress = maxi(1, workerSkill)
	var matchedSkill = true
	var methodologyModifier = 0

	if not _worker_is_specialist_for_item(worker, item):
		matchedSkill = false
		progress = maxi(1, int(floor(progress * 0.5)))

	if currentProject != null and currentProject.projectName == "Food Delivery App":
		methodologyModifier = _get_food_delivery_progress_modifier(metricKey, item)
		progress = maxi(1, progress + methodologyModifier)

	var previousEffort = int(item.get("effort_remaining", 0))
	item.set("effort_remaining", maxi(0, previousEffort - progress))
	var completed = int(item.get("effort_remaining", 0)) <= 0
	if completed:
		item.set("status", "done")
		item.set("completed_in_sprint", resolvedSprint)
		_apply_backlog_item_completion(item)
	else:
		item.set("status", "in_progress")

	var outcome = ""
	if completed:
		outcome = "%s completed \"%s\" and contributed +%d %s progress." % [
			worker.personName,
			item.get("name"),
			item.get("metric_reward", 0),
			_metric_label(metricKey),
		]
	else:
		outcome = "%s reduced \"%s\" from %d to %d effort." % [
			worker.personName,
			item.get("name"),
			previousEffort,
			item.get("effort_remaining"),
		]

	var teachingMessage = ""
	if matchedSkill:
		teachingMessage = "You matched a %s-focused worker to a %s task, so progress stayed efficient." % [
			_metric_label(metricKey),
			_metric_label(metricKey),
		]
	else:
		teachingMessage = "This was a skill mismatch. The worker helped, but slower than a %s specialist would have." % _metric_label(metricKey)

	if methodologyModifier > 0:
		teachingMessage += " %s made this kind of work easier this sprint." % str(currentProject.methodology.get("name", "Your methodology"))
	elif methodologyModifier < 0:
		teachingMessage += " %s made this work harder under the current project pressure." % str(currentProject.methodology.get("name", "Your methodology"))

	return {
		"player_action": "Assigned %s to %s." % [worker.personName, item.get("name")],
		"outcome_summary": outcome,
		"teaching_message": teachingMessage,
		"completed": completed,
	}

func _apply_backlog_item_completion(item: Dictionary) -> void:
	var metricKey = str(item.get("required_skill", "frontEnd"))
	changeMetricByName(metricKey, int(item.get("metric_reward", 0)))
	completedMetrics.append(item.get("name"))

func _apply_scenario_feedback(resolvedSprint: int, completedThisWeek: Array) -> Array:
	var entries: Array = []
	if currentProject == null:
		return entries
	if currentProject.projectName != "Food Delivery App":
		return entries

	var methodologyName = str(currentProject.methodology.get("name", ""))
	var completedScopeChange = false
	var completedCritical = false
	var completedFrontEnd = false
	var completedBackEnd = false

	for item in completedThisWeek:
		if bool(item.get("is_scope_change", false)):
			completedScopeChange = true
		if bool(item.get("is_reliability_critical", false)):
			completedCritical = true
		if str(item.get("required_skill")) == "frontEnd":
			completedFrontEnd = true
		if str(item.get("required_skill")) == "backEnd":
			completedBackEnd = true

	match resolvedSprint:
		1:
			if completedFrontEnd and completedBackEnd:
				var deltas = {
					"Agile": 6,
					"Hybrid": 3,
					"Waterfall": 1,
				}
				var satisfactionBonus = int(deltas.get(methodologyName, 2))
				changeMetricByName("stakeholderSatisfaction", satisfactionBonus)
				entries.append({
					"player_action": "You shipped visible MVP work in Sprint 1.",
					"outcome_summary": "Stakeholder Satisfaction rose by %d because the client saw usable progress early." % satisfactionBonus,
					"teaching_message": "Short feedback loops are especially valuable on products like Food Delivery where the MVP changes as users react to it.",
				})
		2:
			var scopeItemOutstanding = _has_open_scope_change_items()
			if completedScopeChange:
				var scopeBonuses = {
					"Agile": 5,
					"Hybrid": 2,
					"Waterfall": -2,
				}
				var scopeDelta = int(scopeBonuses.get(methodologyName, 0))
				changeMetricByName("stakeholderSatisfaction", scopeDelta)
				entries.append({
					"player_action": "You responded to the late restaurant onboarding request.",
					"outcome_summary": _format_metric_delta_sentence({"stakeholderSatisfaction": scopeDelta}),
					"teaching_message": _food_delivery_scope_change_teaching(methodologyName, true),
				})
			elif scopeItemOutstanding:
				var missedDeltas = {
					"Agile": -2,
					"Hybrid": -5,
					"Waterfall": -10,
				}
				var missedDelta = int(missedDeltas.get(methodologyName, -4))
				changeMetricByName("stakeholderSatisfaction", missedDelta)
				entries.append({
					"player_action": "You left the late onboarding change unresolved in Sprint 2.",
					"outcome_summary": _format_metric_delta_sentence({"stakeholderSatisfaction": missedDelta}),
					"teaching_message": _food_delivery_scope_change_teaching(methodologyName, false),
				})
		3:
			var criticalOutstanding = _has_open_reliability_items()
			if completedCritical:
				var reliabilityBonuses = {
					"Agile": 8,
					"Hybrid": 6,
					"Waterfall": 4,
				}
				var reliabilityDelta = int(reliabilityBonuses.get(methodologyName, 5))
				changeMetricByName("reliability", reliabilityDelta)
				entries.append({
					"player_action": "You addressed the traffic-surge reliability risk.",
					"outcome_summary": _format_metric_delta_sentence({"reliability": reliabilityDelta}),
					"teaching_message": "Scaling pressure punished teams that ignored technical quality. You invested in reliability before launch.",
				})
			elif criticalOutstanding:
				var reliabilityPenalties = {
					"Agile": -8,
					"Hybrid": -10,
					"Waterfall": -12,
				}
				var penalty = int(reliabilityPenalties.get(methodologyName, -9))
				changeMetricByName("reliability", penalty)
				entries.append({
					"player_action": "The team entered launch pressure without finishing the critical load work.",
					"outcome_summary": _format_metric_delta_sentence({"reliability": penalty}),
					"teaching_message": "Feature delivery alone was not enough. In volatile products, scaling and reliability work still need explicit time.",
				})
	return entries

func _build_sprint_review(resolvedSprint: int, completedThisWeek: Array) -> Dictionary:
	var completedCount = completedThisWeek.size()
	var openCriticalCount = 0
	for item in backlogItems:
		if item.get("status") != "done" and (
			bool(item.get("is_scope_change", false)) or bool(item.get("is_reliability_critical", false))
		):
			openCriticalCount += 1

	var reviewScore = int(completedCount * 20)
	reviewScore += int(round(float(currentMetrics.get("reliability", 0)) * 0.3))
	reviewScore += int(round(float(currentMetrics.get("stakeholderSatisfaction", 0)) * 0.3))
	reviewScore -= openCriticalCount * 8

	var grade = "C"
	if reviewScore >= 95:
		grade = "A"
	elif reviewScore >= 80:
		grade = "B"
	elif reviewScore >= 65:
		grade = "C"
	elif reviewScore >= 50:
		grade = "D"
	else:
		grade = "F"

	var currencyEarned = maxi(25, 40 + (completedCount * 15))
	match grade:
		"A":
			currencyEarned += 40
		"B":
			currencyEarned += 20
		"D":
			currencyEarned -= 10
		"F":
			currencyEarned -= 15
	addCurrency(currencyEarned)
	addScore(maxi(10, reviewScore))

	return {
		"grade": grade,
		"currency": currencyEarned,
		"score": maxi(10, reviewScore),
		"reward_summary": "Sprint %d Grade: %s | Reward: $%d | Score: %d" % [resolvedSprint, grade, currencyEarned, maxi(10, reviewScore)],
		"teaching_message": "Sprint rewards now come from delivery quality, not just raw progress. Reliable work and stakeholder trust both mattered.",
	}

func _build_project_summary(finishedProject) -> Dictionary:
	var completedCount = 0
	var totalCount = completedMetrics.size() + getActiveBacklogItemCount()
	if totalCount <= 0:
		totalCount = 1
	for metricName in completedMetrics:
		if metricName != null:
			completedCount += 1

	var completionRatio = float(completedCount) / float(totalCount)
	var finalScore = int(round(completionRatio * 50.0))
	finalScore += int(round(float(currentMetrics.get("reliability", 0)) * 0.25))
	finalScore += int(round(float(currentMetrics.get("stakeholderSatisfaction", 0)) * 0.25))
	addScore(finalScore)

	var projectPayout = 100 + int(round(completionRatio * 100.0))
	projectPayout += int(round(float(currentMetrics.get("stakeholderSatisfaction", 0)) * 0.2))
	addCurrency(projectPayout)

	return {
		"title": "%s Summary" % str(finishedProject.projectName),
		"summary": "Completed %d of %d backlog items. Reliability ended at %d and Stakeholder Satisfaction ended at %d." % [
			completedCount,
			totalCount,
			currentMetrics.get("reliability", 0),
			currentMetrics.get("stakeholderSatisfaction", 0),
		],
		"score_earned": finalScore,
		"currency_earned": projectPayout,
		"methodology": str(finishedProject.methodology.get("name", "")),
		"methodology_fit": _build_methodology_fit_summary(finishedProject),
		"learning_objective": str(finishedProject.learningObjective),
		"success_criteria": str(finishedProject.successCriteria),
	}

func _build_methodology_fit_summary(project) -> String:
	if project.projectName != "Food Delivery App":
		return "You completed the project. Review the sprint feedback to see how your decisions affected delivery, quality, and stakeholder trust."

	match str(project.methodology.get("name", "")):
		"Agile":
			return "Agile was the best fit here because the product changed midstream and stakeholders needed visible progress every sprint."
		"Hybrid":
			return "Hybrid absorbed some volatility, but you still paid for balancing structured planning with changing delivery needs."
		"Waterfall":
			return "Waterfall remained playable, but the late change request and launch pressure made it an expensive fit for a volatile MVP project."
	return "Methodology fit depends on how well your process matched the project's volatility and stakeholder feedback needs."

func _build_default_week_summary(completedThisWeek: Array) -> String:
	if completedThisWeek.is_empty():
		return "No backlog cards were completed this week. Re-open the backlog and rebalance assignments next turn."
	return "Completed %d backlog card(s) this week. Re-open the backlog and decide what to push next." % completedThisWeek.size()

func _allBacklogItemsComplete() -> bool:
	for item in backlogItems:
		if item.get("status") != "done":
			return false
	return true

func _get_worker_skill(worker, metricKey: String) -> int:
	match metricKey:
		"frontEnd":
			return int(worker.frontEndStat)
		"backEnd":
			return int(worker.backEndStat)
		"documenting":
			return int(worker.documentingStat)
	return 1

func _worker_is_specialist_for_item(worker, item: Dictionary) -> bool:
	var metricKey = str(item.get("required_skill", "frontEnd"))
	var workerSkill = _get_worker_skill(worker, metricKey)
	var bestSkill = maxi(int(worker.frontEndStat), maxi(int(worker.backEndStat), int(worker.documentingStat)))
	return workerSkill >= bestSkill

func _metric_label(metricKey: String) -> String:
	match metricKey:
		"frontEnd":
			return "Front End"
		"backEnd":
			return "Back End"
		"documenting":
			return "Documentation"
		"stakeholderSatisfaction":
			return "Stakeholder Satisfaction"
		"reliability":
			return "Reliability"
	return metricKey.capitalize()

func _get_food_delivery_progress_modifier(metricKey: String, item: Dictionary) -> int:
	if currentProject == null or currentProject.projectName != "Food Delivery App":
		return 0
	var methodologyName = str(currentProject.methodology.get("name", ""))
	if bool(item.get("is_scope_change", false)):
		match methodologyName:
			"Agile":
				return 1
			"Hybrid":
				return 0
			"Waterfall":
				return -2
	if bool(item.get("is_reliability_critical", false)) and methodologyName == "Agile":
		return 1
	if metricKey == "frontEnd" and methodologyName == "Agile":
		return 1
	return 0

func _has_open_scope_change_items() -> bool:
	for item in backlogItems:
		if bool(item.get("is_scope_change", false)) and item.get("status") != "done":
			return true
	return false

func _has_open_reliability_items() -> bool:
	for item in backlogItems:
		if bool(item.get("is_reliability_critical", false)) and item.get("status") != "done":
			return true
	return false

func _food_delivery_scope_change_teaching(methodologyName: String, handledChange: bool) -> String:
	match methodologyName:
		"Agile":
			if handledChange:
				return "Agile rewarded you here because the team could absorb a late request without collapsing delivery momentum."
			return "Agile can absorb change better, but only if you actually make room for the change in the sprint plan."
		"Hybrid":
			if handledChange:
				return "Hybrid managed the change, but not as smoothly as a fully iterative approach."
			return "Hybrid softened the impact, but the late change still created friction because planning and iteration competed."
		"Waterfall":
			if handledChange:
				return "Waterfall stayed playable, but this late request still cost you because rigid plans handle volatile scope poorly."
			return "This is the key methodology lesson of the slice: Waterfall is not wrong in general, but it is a poor fit for a changing MVP product."
	return "Methodology fit changes how expensive late changes become."

func _format_metric_delta_sentence(metricDeltas: Dictionary) -> String:
	var parts: Array = []
	for metricName in metricDeltas.keys():
		var amount = int(metricDeltas.get(metricName, 0))
		var prefix = "+"
		if amount < 0:
			prefix = ""
		parts.append("%s%s %s" % [prefix, amount, _metric_label(str(metricName))])
	if parts.is_empty():
		return "No tracked metrics changed."
	return "Metrics changed: %s." % ", ".join(parts)
