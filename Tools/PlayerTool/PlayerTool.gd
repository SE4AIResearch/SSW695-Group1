extends Node

signal projectSelected
signal deadlineReached
signal sprintComplete
signal hireSelected
signal levelLoaded
signal statsChanged
signal backlogUpdated
signal loopStateChanged
signal weekResolved
signal weekTimerUpdated
signal projectCompleted
signal currencyChanged
signal scoreChanged
signal projectPortfolioChanged
signal officeTierChanged
signal upgradesChanged

const LOOP_NO_PROJECT := "no_project"
const LOOP_PLANNING_WEEK := "planning_week"
const LOOP_ACTIVE_WEEK := "active_week"
const LOOP_RESOLVING_WEEK := "resolving_week"
const OFFICE_CAPACITY_BY_TIER := [6, 8, 10, 12, 14]
const WORKER_UPGRADE_STAT_PROPERTIES := {
	"front_end": "frontEndStat",
	"back_end": "backEndStat",
	"documenting": "documentingStat",
	"speed": "speedStat",
	"stamina": "staminaStat",
}
const LEGACY_STANDARD_UPGRADE_EFFECTS := {
	"Hardware:1": [{"stat": "front_end", "multiplier": 1.05}, {"stat": "back_end", "multiplier": 1.05}, {"stat": "speed", "multiplier": 1.2}],
	"Hardware:2": [{"stat": "front_end", "multiplier": 1.05}, {"stat": "documenting", "multiplier": 1.1}],
	"Hardware:3": [{"stat": "back_end", "multiplier": 1.1}, {"stat": "speed", "multiplier": 1.2}],
	"Hardware:4": [{"stat": "front_end", "multiplier": 1.1}, {"stat": "back_end", "multiplier": 1.1}, {"stat": "speed", "multiplier": 1.3}],
	"Software:1": [{"stat": "front_end", "multiplier": 1.1}, {"stat": "back_end", "multiplier": 1.1}, {"stat": "speed", "multiplier": 1.1}],
	"Software:2": [{"stat": "front_end", "multiplier": 1.15}, {"stat": "back_end", "multiplier": 1.15}],
	"Software:3": [{"stat": "back_end", "multiplier": 1.2}, {"stat": "speed", "multiplier": 1.15}],
	"Software:4": [{"stat": "front_end", "multiplier": 1.2}],
	"Software:5": [{"stat": "front_end", "multiplier": 1.15}, {"stat": "back_end", "multiplier": 1.15}, {"stat": "documenting", "multiplier": 1.15}, {"stat": "speed", "multiplier": 1.3}],
	"Software:6": [{"stat": "front_end", "multiplier": 1.2}, {"stat": "back_end", "multiplier": 1.2}, {"stat": "documenting", "multiplier": 1.2}],
	"Quality of Life:1": [{"stat": "stamina", "multiplier": 1.1}, {"stat": "speed", "multiplier": 1.1}],
	"Quality of Life:2": [{"stat": "stamina", "multiplier": 1.2}],
	"Quality of Life:3": [{"stat": "documenting", "multiplier": 1.05}, {"stat": "stamina", "multiplier": 1.15}],
	"Quality of Life:4": [{"stat": "documenting", "multiplier": 1.15}, {"stat": "stamina", "multiplier": 1.15}],
}
const MIN_WORKER_STAMINA := 1
const WORKER_LEVEL_SCALE := Vector2(2.5, 2.5)
const WORKLOAD_METRIC_KEYS: Array = ["frontEnd", "backEnd", "documenting"]
const WORKLOAD_TARGET_COMPLETION_RATIO: float = 0.85
const WORKLOAD_CAPACITY_ELASTICITY: float = 0.85
const WORKLOAD_REFERENCE_CAPACITY: float = 2.0
const WORKLOAD_WEEK_DURATION_SECONDS: int = 10
const WORKLOAD_STAMINA_DRAIN_PER_SECOND: float = 2.0
const WORKLOAD_STAMINA_RECOVERY_PER_SECOND: float = 6.0
const WORKLOAD_MIN_STAMINA_AVAILABILITY: float = 0.25
const MIN_BACKLOG_EFFORT: float = 0.25
const BACKLOG_EFFORT_EPSILON: float = 0.001

var level

var project: Node
var methodology: Dictionary = {}
var projectName: String = ""
var clientName: String = ""
var sprintLength: int = 0
var sprintAmount: int = 0
var projectRatedDifficulty: float
var eventChance: float = 0.45
var metrics = {
	"frontEnd": 0,
	"backEnd": 0,
	"documenting": 0,
	"reliability": 0,
	"stakeholderSatisfaction": 0
}
var MetricProgress = {}
var completedMetrics = []
var weekTime: int = 0
var projWeek: int = 0
var projSprint: int = 0
var FEBacklogStep: int = 0
var BEBacklogStep: int = 0
var docBacklogStep: int = 0
var totalEvents: int = 0

var teamRank: int = 1
var workers: Array = []
var upgrades: Array = []
var currency: float = 0.0
var score: int = 0
var projectAmount: int = 0
var completed_project_count: int = 0
var completed_project_portfolio: Array = []
var has_viewed_methodology_learning_center: bool = false
var office_tier: int = 0
var max_worker_capacity: int = 6
var workerIdCounter: int = 0
var remaining_project_choice_names: Array = []

var loopPhase: String = LOOP_NO_PROJECT
var weekResults: Dictionary = {}
var selectedAssignments: Dictionary = {}
var backlogItems: Array = []
var projectWorkloadSnapshot: Dictionary = {}
var pendingProjectSummary: Dictionary = {}
var sprintGoal: Dictionary = {}
var shouldShowWeekResultsModal: bool = false
var tutorial_seen: Dictionary = {}

var _backlogItemIdCounter: int = 0

func initializeNewSave():
	resetData()
	var freeWorker1 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(0))
	var freeWorker2 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(1))
	$workerHoldover.add_child(freeWorker1)
	$workerHoldover.add_child(freeWorker2)
	newHire(freeWorker1)
	newHire(freeWorker2)

func set_new_player_tutorials_enabled(enabled: bool) -> void:
	tutorial_seen = _default_tutorial_seen(not enabled)

func should_show_tutorial(tutorial_key: String) -> bool:
	return !bool(tutorial_seen.get(tutorial_key, true))

func mark_tutorial_seen(tutorial_key: String) -> void:
	tutorial_seen[tutorial_key] = true

func _default_tutorial_seen(seen: bool = true) -> Dictionary:
	return {
		"office_intro": seen,
		"methodology_intro": seen,
		"hiring_intro": seen,
		"kanban_exit_intro": seen,
		"first_sprint_reward_intro": seen,
	}

# Type : 0 = Front End | 1 = Back End | 2 = Documenting | 3 = Reliability | 4 = Stakeholder Satisfaction
func changeProjectStats(type, amount):
	match type:
		0:
			metrics.set("frontEnd", metrics.get("frontEnd") + amount)
		1:
			metrics.set("backEnd", metrics.get("backEnd") + amount)
		2:
			metrics.set("documenting", metrics.get("documenting") + amount)
		3:
			metrics.set("reliability", clampi(metrics.get("reliability") + amount, 0, 100))
		4:
			metrics.set("stakeholderSatisfaction", clampi(metrics.get("stakeholderSatisfaction") + amount, 0, 100))
	statsChanged.emit()

func changeMetricByName(metricName: String, amount: int) -> void:
	if not metrics.has(metricName):
		return
	var updatedValue: int = int(metrics.get(metricName)) + amount
	if metricName in ["reliability", "stakeholderSatisfaction"]:
		updatedValue = clampi(updatedValue, 0, 100)
	metrics.set(metricName, updatedValue)
	statsChanged.emit()

func resetData():
	project = null
	projectName = ""
	clientName = ""
	sprintLength = 0
	sprintAmount = 0
	projectRatedDifficulty = 0
	projectAmount = 0
	completed_project_count = 0
	completed_project_portfolio = []
	has_viewed_methodology_learning_center = false
	office_tier = 0
	remaining_project_choice_names = []
	_sync_office_capacity()
	metrics = {
		"frontEnd": 0,
		"backEnd": 0,
		"documenting": 0,
		"reliability": 0,
		"stakeholderSatisfaction": 0
	}
	MetricProgress = {}
	completedMetrics = []
	workers = []
	upgrades = []
	currency = 0.0
	score = 0
	weekResults = {}
	selectedAssignments = {}
	backlogItems = []
	projectWorkloadSnapshot = {}
	pendingProjectSummary = {}
	sprintGoal = {}
	shouldShowWeekResultsModal = false
	tutorial_seen = _default_tutorial_seen(true)
	weekTime = 0
	projWeek = 0
	projSprint = 0
	totalEvents = 0
	FEBacklogStep = 0
	BEBacklogStep = 0
	docBacklogStep = 0
	workerIdCounter = 0
	_backlogItemIdCounter = 0
	loopPhase = LOOP_NO_PROJECT
	currencyChanged.emit()
	scoreChanged.emit()
	projectPortfolioChanged.emit()
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()
	officeTierChanged.emit()
	upgradesChanged.emit()

func resetProjectStats():
	projectRatedDifficulty = 0
	project = null
	methodology = {}
	projectName = ""
	clientName = ""
	sprintLength = 0
	sprintAmount = 0
	eventChance = 0.45
	metrics = {
		"frontEnd": 0,
		"backEnd": 0,
		"documenting": 0,
		"reliability": 0,
		"stakeholderSatisfaction": 0
	}
	MetricProgress = {}
	completedMetrics = []
	weekResults = {}
	selectedAssignments = {}
	backlogItems = []
	projectWorkloadSnapshot = {}
	pendingProjectSummary = {}
	sprintGoal = {}
	shouldShowWeekResultsModal = false
	weekTime = 0
	totalEvents = 0
	projWeek = 0
	projSprint = 0
	FEBacklogStep = 0
	BEBacklogStep = 0
	docBacklogStep = 0
	_backlogItemIdCounter = 0
	loopPhase = LOOP_NO_PROJECT
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()

func _ready() -> void:
	var workerNode := Node2D.new()
	workerNode.name = "workerHoldover"
	add_child(workerNode)

func get_unique_project_choices(all_projects: Array, count: int = 3) -> Array:
	var selected_projects: Array = []
	var selected_names: Array = []
	var target_count: int = mini(count, all_projects.size())

	while selected_projects.size() < target_count:
		if remaining_project_choice_names.is_empty():
			_refill_project_choice_pool(all_projects)

		var project_name: String = _pop_next_project_choice_name(selected_names)
		if project_name.is_empty():
			_refill_project_choice_pool(all_projects)
			project_name = _pop_next_project_choice_name(selected_names)
			if project_name.is_empty():
				break

		var project_choice: Dictionary = _find_project_choice(all_projects, project_name)
		if project_choice.is_empty():
			continue

		selected_names.append(project_name)
		selected_projects.append(project_choice)

	return selected_projects

func _refill_project_choice_pool(all_projects: Array) -> void:
	remaining_project_choice_names.clear()
	for project_choice in all_projects:
		var project_name: String = str(project_choice.get("name", ""))
		if !project_name.is_empty():
			remaining_project_choice_names.append(project_name)
	remaining_project_choice_names.shuffle()

func _pop_next_project_choice_name(excluded_names: Array) -> String:
	var deferred_names: Array = []

	while !remaining_project_choice_names.is_empty():
		var project_name: String = str(remaining_project_choice_names.pop_back())
		if excluded_names.has(project_name):
			deferred_names.append(project_name)
			continue

		remaining_project_choice_names.append_array(deferred_names)
		return project_name

	remaining_project_choice_names.append_array(deferred_names)
	return ""

func _find_project_choice(all_projects: Array, project_name: String) -> Dictionary:
	for project_choice in all_projects:
		if str(project_choice.get("name", "")) == project_name:
			return project_choice
	return {}

func newProject(newProject) -> void:
	resetProjectStats()
	_apply_active_upgrade_effects_to_all_workers()
	project = newProject
	methodology = newProject.methodology
	projectName = newProject.projectName
	clientName = newProject.clientName
	sprintLength = int(newProject.sprintLength)
	sprintAmount = int(newProject.sprintAmount)
	projectRatedDifficulty = float(newProject.projectDifficulty)
	eventChance = float(newProject.eventChance)
	projWeek = 1
	projSprint = 1
	projectAmount += 1
	_build_backlog_for_project(project)
	_build_project_workload_snapshot()
	_scale_backlog_effort_for_project()
	_prepare_sprint_context(projSprint)
	loopPhase = LOOP_PLANNING_WEEK
	projectSelected.emit()
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()

func newHire(worker, apply_active_upgrades: bool = true) -> bool:
	if workers.size() >= max_worker_capacity:
		return false
	if worker == null:
		return false
	if apply_active_upgrades:
		_apply_active_upgrade_effects_to_worker(worker)
	_ensure_worker_identity(worker)
	workers.append(worker)
	var worker_parent: Node = worker.get_parent()
	if worker_parent == null:
		$workerHoldover.add_child(worker)
	elif worker_parent != $workerHoldover:
		worker.reparent($workerHoldover, false)
	worker.scale = WORKER_LEVEL_SCALE
	worker.position = Vector2.ZERO
	hireSelected.emit()
	return true

func can_purchase_hire(hire_cost: int) -> Dictionary:
	if workers.size() >= max_worker_capacity:
		return {"ok": false, "reason": "You cannot hire more workers right now."}
	if hire_cost < 0:
		return {"ok": false, "reason": "That hire cost is invalid."}
	if int(currency) < hire_cost:
		return {"ok": false, "reason": "You do not have enough money for this hire."}
	return {"ok": true, "reason": "Ready to hire this worker."}

func purchase_hire(worker, hire_cost: int) -> Dictionary:
	var validation: Dictionary = can_purchase_hire(hire_cost)
	if not bool(validation.get("ok", false)):
		return validation
	if not newHire(worker):
		return {"ok": false, "reason": "You cannot hire more workers right now."}

	addCurrency(-hire_cost)
	return {
		"ok": true,
		"reason": "Hired %s." % str(worker.personName)
	}

func newUpgrade(upgrade) -> void:
	upgrades.append(_normalize_upgrade_record(upgrade))
	upgradesChanged.emit()

func has_upgrade(category: String, tier: int) -> bool:
	for upgrade in upgrades:
		if str(upgrade.get("category", "")) == category and int(upgrade.get("tier", 0)) == tier:
			return true
	return false

func can_purchase_standard_upgrade(upgrade_data: Dictionary) -> Dictionary:
	var category: String = str(upgrade_data.get("category", ""))
	var target_tier: int = int(upgrade_data.get("tier", 0))
	var cost: int = int(upgrade_data.get("cost", 0))

	if category.is_empty():
		return {"ok": false, "reason": "That upgrade category is invalid."}
	if target_tier < 1:
		return {"ok": false, "reason": "That upgrade tier is invalid."}
	if has_upgrade(category, target_tier):
		return {"ok": false, "reason": "That upgrade has already been purchased."}
	if target_tier > 1 and not has_upgrade(category, target_tier - 1):
		return {"ok": false, "reason": "Purchase the previous %s upgrade first." % category}
	if int(currency) < cost:
		return {"ok": false, "reason": "You do not have enough money for this upgrade."}
	return {"ok": true, "reason": "Ready to purchase this upgrade."}

func purchase_standard_upgrade(upgrade_data: Dictionary) -> Dictionary:
	var validation: Dictionary = can_purchase_standard_upgrade(upgrade_data)
	if not bool(validation.get("ok", false)):
		return validation

	var purchased_upgrade: Dictionary = _normalize_upgrade_record(upgrade_data)
	addCurrency(-int(upgrade_data.get("cost", 0)))
	newUpgrade(purchased_upgrade)
	if project == null:
		_apply_standard_upgrade_purchase_effects(purchased_upgrade)
	statsChanged.emit()
	return {
		"ok": true,
		"reason": "Purchased %s." % str(upgrade_data.get("name", "Upgrade"))
	}

func addCurrency(amount: int) -> void:
	currency = maxf(0.0, currency + amount)
	currencyChanged.emit()

func addScore(amount: int) -> void:
	score = maxi(0, score + amount)
	scoreChanged.emit()

func record_completed_project(completion_data: Dictionary, currency_earned: int, stakeholder_satisfaction: float) -> void:
	if completion_data.is_empty():
		return

	var raw_metrics: Variant = completion_data.get("metrics", {})
	var source_metrics: Dictionary = {}
	if raw_metrics is Dictionary:
		source_metrics = raw_metrics

	var total_events: int = int(completion_data.get("total_events", 0))
	var portfolio_record := {
		"project_name": str(completion_data.get("project_name", "")),
		"client_name": str(completion_data.get("client_name", "")),
		"completed_at": Time.get_datetime_dict_from_system(false),
		"currency_earned": int(currency_earned),
		"metrics": {
			"stakeholderSatisfaction": float(stakeholder_satisfaction),
			"frontEnd": int(source_metrics.get("frontEnd", 0)),
			"backEnd": int(source_metrics.get("backEnd", 0)),
			"reliability": int(source_metrics.get("reliability", 0)),
			"documenting": int(source_metrics.get("documenting", 0)),
		},
		"metric_maxes": {
			"stakeholderSatisfaction": 4,
			"frontEnd": maxi(1, int(completion_data.get("front_end_target", 0))),
			"backEnd": maxi(1, int(completion_data.get("back_end_target", 0))),
			"reliability": maxi(1, total_events),
			"documenting": maxi(1, int(completion_data.get("documenting_target", 0))),
		},
	}

	completed_project_portfolio.append(portfolio_record)
	projectPortfolioChanged.emit()

func canAdvanceWeek() -> bool:
	return project != null and loopPhase == LOOP_PLANNING_WEEK

func isWeekActive() -> bool:
	return project != null and loopPhase == LOOP_ACTIVE_WEEK

func startWeek() -> bool:
	if not canAdvanceWeek():
		return false
	weekTime = 0
	loopPhase = LOOP_ACTIVE_WEEK
	backlogUpdated.emit()
	loopStateChanged.emit()
	weekTimerUpdated.emit()
	return true

func resolveWeek() -> bool:
	if project == null or loopPhase != LOOP_ACTIVE_WEEK:
		return false

	loopPhase = LOOP_RESOLVING_WEEK
	loopStateChanged.emit()

	var assignmentKeys := selectedAssignments.keys().duplicate()
	for workerId in assignmentKeys:
		var item: Dictionary = getBacklogItemById(int(selectedAssignments.get(workerId, -1)))
		var worker = getWorkerById(str(workerId))
		if item.is_empty() or worker == null:
			continue
		if !worker.resting: _resolve_assignment(worker, item)

	clearAssignments()
	weekTime = 0

	var sprintFinished: bool = projWeek >= int(project.sprintLength)
	if sprintFinished:
		if projSprint >= int(project.sprintAmount) or _allBacklogItemsComplete():
			completed_project_count += 1
			projectCompleted.emit()
			deadlineReached.emit()
			resetProjectStats()
		else:
			earnSprintMoney()
			sprintComplete.emit()
			projSprint += 1
			projWeek = 1
			_prepare_sprint_context(projSprint)
			loopPhase = LOOP_PLANNING_WEEK
	else:
		projWeek += 1
		loopPhase = LOOP_PLANNING_WEEK

	backlogUpdated.emit()
	loopStateChanged.emit()
	weekTimerUpdated.emit()
	statsChanged.emit()
	weekResolved.emit()
	return true

func assignWorkerToItem(workerId: String, itemId: int) -> Dictionary:
	if project == null or loopPhase != LOOP_PLANNING_WEEK:
		return {"ok": false, "reason": "You can only assign work while planning the week."}
	var worker = getWorkerById(workerId)
	if worker == null:
		return {"ok": false, "reason": "That worker no longer exists."}
	if bool(worker.resting):
		return {"ok": false, "reason": "%s is resting until their stamina is full." % worker.personName}
	var item := getBacklogItemById(itemId)
	if item.is_empty():
		return {"ok": false, "reason": "That backlog item no longer exists."}
	if item.get("status") == "done":
		return {"ok": false, "reason": "That item is already complete."}
	var previousWorkerId: String = str(item.get("assigned_worker_id", ""))
	if previousWorkerId != "" and previousWorkerId != workerId:
		var previousWorker = getWorkerById(previousWorkerId)
		var previousWorkerLabel := "Another worker"
		if previousWorker != null:
			previousWorkerLabel = str(previousWorker.personName)
		return {"ok": false, "reason": "%s is already assigned to that card." % previousWorkerLabel}
	unassignWorker(workerId)
	item.set("assigned_worker_id", workerId)
	if item.has("assigned_worker_name"):
		item.erase("assigned_worker_name")
	if item.get("status") == "backlog":
		item.set("status", "in_progress")
	selectedAssignments.set(workerId, itemId)
	backlogUpdated.emit()
	return {"ok": true, "reason": "%s is now assigned to %s." % [str(worker.personName), str(item.get("name", ""))]}

func unassignWorker(workerId: String) -> void:
	if not selectedAssignments.has(workerId):
		return
	var item: Dictionary = getBacklogItemById(int(selectedAssignments.get(workerId, -1)))
	if not item.is_empty():
		item.set("assigned_worker_id", "")
		if item.has("assigned_worker_name"):
			item.erase("assigned_worker_name")
		if item.get("status") == "in_progress" and float(item.get("effort_remaining", 0.0)) >= float(item.get("total_effort", 0.0)):
			item.set("status", "backlog")
	selectedAssignments.erase(workerId)
	backlogUpdated.emit()

func clearAssignments() -> void:
	for workerId in selectedAssignments.keys():
		var item: Dictionary = getBacklogItemById(int(selectedAssignments.get(workerId, -1)))
		if not item.is_empty():
			item.set("assigned_worker_id", "")
			if item.has("assigned_worker_name"):
				item.erase("assigned_worker_name")
	selectedAssignments.clear()

func getWorkerById(workerId: String):
	for worker in workers:
		if str(worker.workerId) == workerId:
			return worker
	return null

func getWorkerByName(workerName: String):
	for worker in workers:
		if worker.personName == workerName:
			return worker
	return null

func getWorkerIdByName(workerName: String) -> String:
	var worker = getWorkerByName(workerName)
	if worker == null:
		return ""
	return str(worker.workerId)

func getBacklogItemById(itemId: int) -> Dictionary:
	for item in backlogItems:
		if int(item.get("id", -1)) == itemId:
			return item
	return {}

func getProjectWorkerSnapshot(workerId: String) -> Dictionary:
	var worker_snapshots: Variant = projectWorkloadSnapshot.get("workers", {})
	if worker_snapshots is not Dictionary:
		return {}
	var snapshot: Variant = worker_snapshots.get(workerId, {})
	if snapshot is Dictionary:
		return snapshot
	return {}

func addEventBacklogItem(metricKey: String, itemName: String, effort: int = 5, reward: int = 2, isScopeChange: bool = true) -> void:
	_addBacklogItem(itemName, metricKey, effort, reward, isScopeChange, false)
	backlogUpdated.emit()

func _build_backlog_for_project(projectNode: Node) -> void:
	backlogItems.clear()
	_backlogItemIdCounter = 0
	_appendMetricItems(projectNode.frontEndMetrics, "frontEnd", projectNode.frontEndProjectMin)
	_appendMetricItems(projectNode.backEndMetrics, "backEnd", projectNode.backEndProjectMin)
	_appendMetricItems(projectNode.documentingMetrics, "documenting", projectNode.documentingProjectMin)

func _appendMetricItems(metricDictionary: Dictionary, requiredSkill: String, targetTotal: int) -> void:
	var itemCount := maxi(1, metricDictionary.size())
	for index in metricDictionary.keys():
		var metricData: Variant = metricDictionary.get(index)
		if metricData is Dictionary and metricData.has("required_skill"):
			var existingItem: Dictionary = metricData.duplicate(true)
			_backlogItemIdCounter += 1
			existingItem.set("id", _backlogItemIdCounter)
			existingItem.set("name", str(existingItem.get("name", "Backlog Item")))
			existingItem.set("required_skill", str(existingItem.get("required_skill", requiredSkill)))
			var totalEffort: float = maxf(MIN_BACKLOG_EFFORT, float(existingItem.get("total_effort", existingItem.get("effort_remaining", 1.0))))
			var effortRemaining: float = clampf(float(existingItem.get("effort_remaining", totalEffort)), 0.0, totalEffort)
			existingItem.set("base_effort", maxf(MIN_BACKLOG_EFFORT, float(existingItem.get("base_effort", totalEffort))))
			existingItem.set("total_effort", totalEffort)
			existingItem.set("effort_remaining", effortRemaining)
			existingItem.set("status", str(existingItem.get("status", "backlog")))
			existingItem.set("assigned_worker_id", str(existingItem.get("assigned_worker_id", "")))
			if existingItem.has("assigned_worker_name"):
				existingItem.erase("assigned_worker_name")
			existingItem.set("metric_reward", maxi(1, int(existingItem.get("metric_reward", 2))))
			existingItem.set("is_scope_change", bool(existingItem.get("is_scope_change", false)))
			existingItem.set("is_reliability_critical", bool(existingItem.get("is_reliability_critical", false)))
			backlogItems.append(existingItem)
			continue
		var itemName: String = str(metricData)
		_addBacklogItem(
			itemName,
			requiredSkill,
			clampi(int(round(float(targetTotal) / itemCount)) + 2, 4, 8),
			maxi(1, int(round(float(targetTotal) / itemCount))),
			false,
			false
		)

func _addBacklogItem(itemName: String, requiredSkill: String, effort: float, metricReward: int, isScopeChange: bool, isReliabilityCritical: bool) -> void:
	_backlogItemIdCounter += 1
	var normalizedEffort: float = maxf(MIN_BACKLOG_EFFORT, effort)
	backlogItems.append({
		"id": _backlogItemIdCounter,
		"name": itemName,
		"required_skill": requiredSkill,
		"base_effort": normalizedEffort,
		"effort_remaining": normalizedEffort,
		"total_effort": normalizedEffort,
		"status": "backlog",
		"assigned_worker_id": "",
		"metric_reward": maxi(1, metricReward),
		"is_scope_change": isScopeChange,
		"is_reliability_critical": isReliabilityCritical,
	})

func _build_project_workload_snapshot() -> void:
	var total_project_weeks: int = _get_total_project_weeks()
	var worker_snapshots: Dictionary = {}
	var eligible_worker_ids: Array = []

	for worker in workers:
		if worker == null:
			continue
		var workerId: String = str(worker.workerId)
		if workerId.is_empty():
			continue
		eligible_worker_ids.append(workerId)
		worker_snapshots[workerId] = _build_worker_workload_snapshot(worker, total_project_weeks)

	projectWorkloadSnapshot = {
		"version": 1,
		"eligible_worker_ids": eligible_worker_ids,
		"workers": worker_snapshots,
		"total_project_weeks": total_project_weeks,
		"settings": {
			"target_completion_ratio": WORKLOAD_TARGET_COMPLETION_RATIO,
			"capacity_elasticity": WORKLOAD_CAPACITY_ELASTICITY,
			"reference_capacity": WORKLOAD_REFERENCE_CAPACITY,
			"week_duration_seconds": WORKLOAD_WEEK_DURATION_SECONDS,
			"stamina_drain_per_second": WORKLOAD_STAMINA_DRAIN_PER_SECOND,
			"stamina_recovery_per_second": WORKLOAD_STAMINA_RECOVERY_PER_SECOND,
			"minimum_stamina_availability": WORKLOAD_MIN_STAMINA_AVAILABILITY,
			"minimum_backlog_effort": MIN_BACKLOG_EFFORT,
		},
		"metric_capacity": {},
		"metric_effective_capacity": {},
		"metric_budget": {},
		"metric_item_counts": {},
	}

func _build_worker_workload_snapshot(worker, total_project_weeks: int) -> Dictionary:
	var starting_stamina: float = _get_worker_current_stamina_value(worker)
	var stamina_availability: float = _estimate_worker_stamina_availability(worker, total_project_weeks)
	var weekly_progress: Dictionary = {}
	for metricKey in WORKLOAD_METRIC_KEYS:
		weekly_progress[metricKey] = _calculate_worker_weekly_progress(
			_get_worker_skill(worker, metricKey),
			int(worker.speedStat)
		)

	return {
		"worker_id": str(worker.workerId),
		"frontEnd": int(worker.frontEndStat),
		"backEnd": int(worker.backEndStat),
		"documenting": int(worker.documentingStat),
		"speed": int(worker.speedStat),
		"stamina": int(worker.staminaStat),
		"starting_stamina": starting_stamina,
		"starting_resting": bool(worker.resting),
		"stamina_availability": stamina_availability,
		"weekly_progress": weekly_progress,
	}

func _scale_backlog_effort_for_project() -> void:
	if backlogItems.is_empty():
		return

	var metric_item_counts: Dictionary = {}
	var metric_base_effort_totals: Dictionary = {}
	for item in backlogItems:
		var metricKey: String = str(item.get("required_skill", "frontEnd"))
		var base_effort: float = maxf(
			MIN_BACKLOG_EFFORT,
			float(item.get("base_effort", item.get("total_effort", item.get("effort_remaining", 1.0))))
		)
		item.set("base_effort", base_effort)
		metric_item_counts[metricKey] = int(metric_item_counts.get(metricKey, 0)) + 1
		metric_base_effort_totals[metricKey] = float(metric_base_effort_totals.get(metricKey, 0.0)) + base_effort

	_update_project_workload_metric_budgets(metric_item_counts, backlogItems.size())

	var raw_metric_budgets: Variant = projectWorkloadSnapshot.get("metric_budget", {})
	var metric_budgets: Dictionary = {}
	if raw_metric_budgets is Dictionary:
		metric_budgets = raw_metric_budgets
	for item in backlogItems:
		var metricKey: String = str(item.get("required_skill", "frontEnd"))
		var base_effort: float = maxf(MIN_BACKLOG_EFFORT, float(item.get("base_effort", 1.0)))
		var metric_base_total: float = maxf(MIN_BACKLOG_EFFORT, float(metric_base_effort_totals.get(metricKey, base_effort)))
		var metric_budget: float = maxf(MIN_BACKLOG_EFFORT, float(metric_budgets.get(metricKey, metric_base_total)))
		var scaled_effort: float = maxf(MIN_BACKLOG_EFFORT, metric_budget * base_effort / metric_base_total)
		item.set("total_effort", scaled_effort)
		item.set("effort_remaining", scaled_effort)
		item.set("status", str(item.get("status", "backlog")))

func _update_project_workload_metric_budgets(metric_item_counts: Dictionary, total_item_count: int) -> void:
	if projectWorkloadSnapshot.is_empty():
		return

	var metric_capacity: Dictionary = {}
	var metric_effective_capacity: Dictionary = {}
	var metric_budget: Dictionary = {}
	var total_project_weeks: int = _get_total_project_weeks()
	var safe_total_item_count: int = maxi(1, total_item_count)

	for metricKey in WORKLOAD_METRIC_KEYS:
		var raw_capacity: float = _calculate_metric_raw_capacity(metricKey)
		var effective_capacity: float = _calculate_effective_capacity(raw_capacity)
		var demand_weight: float = float(metric_item_counts.get(metricKey, 0)) / float(safe_total_item_count)
		var budget: float = effective_capacity * float(total_project_weeks) * WORKLOAD_TARGET_COMPLETION_RATIO * demand_weight
		metric_capacity[metricKey] = raw_capacity
		metric_effective_capacity[metricKey] = effective_capacity
		metric_budget[metricKey] = maxf(MIN_BACKLOG_EFFORT, budget)

	projectWorkloadSnapshot["metric_capacity"] = metric_capacity
	projectWorkloadSnapshot["metric_effective_capacity"] = metric_effective_capacity
	projectWorkloadSnapshot["metric_budget"] = metric_budget
	projectWorkloadSnapshot["metric_item_counts"] = metric_item_counts.duplicate(true)

func _calculate_metric_raw_capacity(metricKey: String) -> float:
	var worker_snapshots: Variant = projectWorkloadSnapshot.get("workers", {})
	if worker_snapshots is not Dictionary:
		return 0.0

	var raw_capacity: float = 0.0
	for workerId in worker_snapshots.keys():
		var worker_snapshot: Variant = worker_snapshots.get(workerId, {})
		if worker_snapshot is not Dictionary:
			continue
		var weekly_progress: Variant = worker_snapshot.get("weekly_progress", {})
		if weekly_progress is not Dictionary:
			continue
		raw_capacity += float(weekly_progress.get(metricKey, 1.0)) * float(worker_snapshot.get("stamina_availability", 1.0))
	return raw_capacity

func _calculate_effective_capacity(raw_capacity: float) -> float:
	if raw_capacity <= WORKLOAD_REFERENCE_CAPACITY:
		return raw_capacity
	return WORKLOAD_REFERENCE_CAPACITY * pow(raw_capacity / WORKLOAD_REFERENCE_CAPACITY, WORKLOAD_CAPACITY_ELASTICITY)

func _calculate_worker_weekly_progress(worker_skill: int, worker_speed: int) -> int:
	return maxi(1, int(floor(float(worker_skill) * (float(worker_speed) / 100.0))))

func _get_total_project_weeks() -> int:
	return maxi(1, int(sprintAmount) * int(sprintLength))

func _get_worker_current_stamina_value(worker) -> float:
	var stamina_bar = worker.get_node_or_null("staminaBar")
	if stamina_bar != null:
		return clampf(float(stamina_bar.value), 0.0, maxf(1.0, float(worker.staminaStat)))
	return maxf(1.0, float(worker.staminaStat))

func _estimate_worker_stamina_availability(worker, total_project_weeks: int) -> float:
	if total_project_weeks <= 0:
		return 1.0

	var max_stamina: float = maxf(1.0, float(worker.staminaStat))
	var stamina_value: float = clampf(_get_worker_current_stamina_value(worker), 0.0, max_stamina)
	var is_resting: bool = bool(worker.resting)
	var available_weeks: int = 0

	for _week in range(total_project_weeks):
		for _second in range(WORKLOAD_WEEK_DURATION_SECONDS):
			if is_resting:
				stamina_value += WORKLOAD_STAMINA_RECOVERY_PER_SECOND
				if stamina_value >= max_stamina:
					stamina_value = max_stamina
					is_resting = false
			else:
				stamina_value -= WORKLOAD_STAMINA_DRAIN_PER_SECOND
				if stamina_value <= 0.0:
					stamina_value = 0.0
					is_resting = true
		if !is_resting:
			available_weeks += 1

	return clampf(float(available_weeks) / float(total_project_weeks), WORKLOAD_MIN_STAMINA_AVAILABILITY, 1.0)

func _ensure_worker_identity(worker, preferredId: String = "") -> void:
	var candidateId := preferredId
	if candidateId.is_empty():
		candidateId = str(worker.workerId)
	if candidateId.is_empty() or _worker_id_belongs_to_other_worker(candidateId, worker):
		candidateId = _next_worker_id()
	else:
		_track_existing_worker_id(candidateId)
	worker.workerId = candidateId
	worker.name = candidateId

func _worker_id_belongs_to_other_worker(workerId: String, worker) -> bool:
	var existingWorker = getWorkerById(workerId)
	return existingWorker != null and existingWorker != worker

func _next_worker_id() -> String:
	workerIdCounter += 1
	return "worker_%d" % workerIdCounter

func _track_existing_worker_id(workerId: String) -> void:
	if !workerId.begins_with("worker_"):
		return
	var suffix := workerId.trim_prefix("worker_")
	if suffix.is_valid_int():
		workerIdCounter = maxi(workerIdCounter, int(suffix))

func _prepare_sprint_context(sprintNumber: int) -> void:
	sprintGoal = {
		"title": "Sprint %d" % sprintNumber
	}

func _resolve_assignment(worker, item: Dictionary) -> void:
	var metricKey: String = str(item.get("required_skill", "frontEnd"))
	var progress: float = _get_worker_project_progress(str(worker.workerId), worker, metricKey)
	_apply_progress_with_overflow(item, metricKey, progress)

func _get_worker_project_progress(workerId: String, worker, metricKey: String) -> float:
	var worker_snapshot: Dictionary = getProjectWorkerSnapshot(workerId)
	if !worker_snapshot.is_empty():
		var weekly_progress: Variant = worker_snapshot.get("weekly_progress", {})
		if weekly_progress is Dictionary:
			return maxf(1.0, float(weekly_progress.get(metricKey, 1.0)))

	var workerSkill: int = _get_worker_skill(worker, metricKey)
	return float(_calculate_worker_weekly_progress(workerSkill, int(worker.speedStat)))

func _apply_progress_with_overflow(startingItem: Dictionary, metricKey: String, progress: float) -> void:
	var remaining_progress: float = maxf(0.0, progress)
	var current_item: Dictionary = startingItem
	var last_item_id: int = int(current_item.get("id", -1))

	while remaining_progress > BACKLOG_EFFORT_EPSILON and !current_item.is_empty():
		if current_item.get("status") == "done":
			current_item = _find_next_overflow_backlog_item(metricKey, int(current_item.get("id", last_item_id)))
			if !current_item.is_empty():
				last_item_id = int(current_item.get("id", last_item_id))
			continue

		var effort_remaining: float = maxf(0.0, float(current_item.get("effort_remaining", 0.0)))
		if effort_remaining <= BACKLOG_EFFORT_EPSILON:
			_complete_backlog_item(current_item)
			current_item = _find_next_overflow_backlog_item(metricKey, int(current_item.get("id", last_item_id)))
			if !current_item.is_empty():
				last_item_id = int(current_item.get("id", last_item_id))
			continue

		if remaining_progress + BACKLOG_EFFORT_EPSILON >= effort_remaining:
			remaining_progress -= effort_remaining
			current_item.set("effort_remaining", 0.0)
			_complete_backlog_item(current_item)
			current_item = _find_next_overflow_backlog_item(metricKey, int(current_item.get("id", last_item_id)))
			if !current_item.is_empty():
				last_item_id = int(current_item.get("id", last_item_id))
		else:
			current_item.set("effort_remaining", effort_remaining - remaining_progress)
			current_item.set("status", "in_progress")
			remaining_progress = 0.0

func _complete_backlog_item(item: Dictionary) -> void:
	if item.get("status") == "done":
		return
	item.set("status", "done")
	item.set("effort_remaining", 0.0)
	_apply_backlog_item_completion(item)

func _find_next_overflow_backlog_item(metricKey: String, afterItemId: int) -> Dictionary:
	var wrapped_candidate: Dictionary = {}
	var found_after_item: bool = afterItemId < 0
	for item in backlogItems:
		if item is not Dictionary:
			continue
		var item_id: int = int(item.get("id", -1))
		if item_id == afterItemId:
			found_after_item = true
			continue
		if str(item.get("required_skill", "frontEnd")) != metricKey:
			continue
		if item.get("status") == "done":
			continue
		if found_after_item:
			return item
		if wrapped_candidate.is_empty():
			wrapped_candidate = item
	return wrapped_candidate

func _apply_backlog_item_completion(item: Dictionary) -> void:
	var metricKey: String = str(item.get("required_skill", "frontEnd"))
	changeMetricByName(metricKey, int(item.get("metric_reward", 0)))
	completedMetrics.append(item.get("name"))

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
	var metricKey: String = str(item.get("required_skill", "frontEnd"))
	var workerSkill: int = _get_worker_skill(worker, metricKey)
	var bestSkill: int = maxi(int(worker.frontEndStat), maxi(int(worker.backEndStat), int(worker.documentingStat)))
	return workerSkill >= bestSkill

func earnSprintMoney():
	if project != null:
		addCurrency(floorf((30 * project.projectDifficulty) + (5 * projectAmount) + (50 * (teamRank - 1))))

func returnSprintMoney(SatisfactionAmount):
	return floorf(((500 * projectRatedDifficulty) + (25 * projectAmount) + (650 * (teamRank - 1)))*SatisfactionAmount)

func get_office_capacity_for_tier(tier: int) -> int:
	var clamped_tier := clampi(tier, 0, OFFICE_CAPACITY_BY_TIER.size() - 1)
	return int(OFFICE_CAPACITY_BY_TIER[clamped_tier])

func can_purchase_office_upgrade(upgrade_data: Dictionary) -> Dictionary:
	var target_tier: int = int(upgrade_data.get("tier", 0))
	var required_projects: int = int(upgrade_data.get("required_projects", 0))
	var required_workers: int = int(upgrade_data.get("required_workers", 0))
	var cost: int = int(upgrade_data.get("cost", 0))

	if target_tier < 1 or target_tier >= OFFICE_CAPACITY_BY_TIER.size():
		return {"ok": false, "reason": "That office tier is invalid."}
	if target_tier <= office_tier:
		return {"ok": false, "reason": "That office has already been purchased."}
	if target_tier != office_tier + 1:
		return {"ok": false, "reason": "Purchase the previous office upgrade first."}
	if completed_project_count < required_projects:
		return {"ok": false, "reason": "Complete more projects to unlock this office."}
	if workers.size() < required_workers:
		return {"ok": false, "reason": "Hire more workers to unlock this office."}
	if int(currency) < cost:
		return {"ok": false, "reason": "You do not have enough money for this office upgrade."}
	return {"ok": true, "reason": "Ready to purchase this office upgrade."}

func purchase_office_upgrade(upgrade_data: Dictionary) -> Dictionary:
	var validation: Dictionary = can_purchase_office_upgrade(upgrade_data)
	if not bool(validation.get("ok", false)):
		return validation

	var target_tier: int = int(upgrade_data.get("tier", 0))
	var cost: int = int(upgrade_data.get("cost", 0))
	addCurrency(-cost)
	office_tier = target_tier
	_sync_office_capacity()
	newUpgrade({
		"category": "Office Space",
		"tier": office_tier,
		"capacity": max_worker_capacity,
	})
	officeTierChanged.emit()
	return {
		"ok": true,
		"reason": "Purchased %s. Office capacity is now %d workers." % [
			str(upgrade_data.get("name", "Office Upgrade")),
			max_worker_capacity
		]
	}

func _sync_office_capacity() -> void:
	max_worker_capacity = get_office_capacity_for_tier(office_tier)

func _normalize_upgrade_record(upgrade_data: Dictionary) -> Dictionary:
	var category: String = str(upgrade_data.get("category", ""))
	var tier: int = int(upgrade_data.get("tier", 0))
	var normalized_upgrade := {
		"category": category,
		"tier": tier,
		"name": str(upgrade_data.get("name", "")),
	}

	if upgrade_data.has("description"):
		normalized_upgrade["description"] = str(upgrade_data.get("description", ""))
	var effects := _get_upgrade_effects(upgrade_data)
	if effects.is_empty():
		effects = _get_legacy_upgrade_effects(category, tier)
	if not effects.is_empty():
		normalized_upgrade["effects"] = effects
	if upgrade_data.has("scene_prop_key"):
		normalized_upgrade["scene_prop_key"] = str(upgrade_data.get("scene_prop_key", ""))
	if upgrade_data.has("capacity"):
		normalized_upgrade["capacity"] = int(upgrade_data.get("capacity", 0))

	return normalized_upgrade

func _apply_standard_upgrade_purchase_effects(upgrade_data: Dictionary) -> void:
	for worker in workers:
		_apply_worker_upgrade_effects(worker, upgrade_data)

func _apply_active_upgrade_effects_to_all_workers() -> void:
	for worker in workers:
		_apply_active_upgrade_effects_to_worker(worker)

func _apply_active_upgrade_effects_to_worker(worker) -> void:
	for upgrade_data in upgrades:
		_apply_worker_upgrade_effects(worker, upgrade_data)

func _apply_worker_upgrade_effects(worker, upgrade_data: Dictionary) -> void:
	if worker == null:
		return
	var category: String = str(upgrade_data.get("category", ""))
	var tier: int = int(upgrade_data.get("tier", 0))
	var effects := _get_upgrade_effects(upgrade_data)
	if effects.is_empty():
		effects = _get_legacy_upgrade_effects(category, tier)
	if effects.is_empty():
		return
	var applied_meta_key := _get_upgrade_applied_meta_key(category, tier)
	if bool(worker.get_meta(applied_meta_key, false)):
		return

	for effect in effects:
		if effect is Dictionary:
			_apply_worker_stat_multiplier(worker, str(effect.get("stat", "")), float(effect.get("multiplier", 1.0)))
	worker.set_meta(applied_meta_key, true)

func _get_upgrade_effects(upgrade_data: Dictionary) -> Array:
	if upgrade_data.has("effects"):
		return upgrade_data.get("effects", []).duplicate(true)
	return _parse_upgrade_effects_from_description(str(upgrade_data.get("description", "")))

func _get_legacy_upgrade_effects(category: String, tier: int) -> Array:
	var upgrade_key := "%s:%d" % [category, tier]
	return LEGACY_STANDARD_UPGRADE_EFFECTS.get(upgrade_key, []).duplicate(true)

func _parse_upgrade_effects_from_description(description: String) -> Array:
	var effects := []
	for raw_token in description.split(","):
		var token := str(raw_token).strip_edges()
		if not token.begins_with("+"):
			continue
		var percent_end := token.find("%")
		if percent_end <= 1:
			continue
		var percent_text := token.substr(1, percent_end - 1).strip_edges()
		if not percent_text.is_valid_float():
			continue
		var stat_key := _normalize_upgrade_stat_name(token.substr(percent_end + 1).strip_edges())
		if stat_key.is_empty():
			continue
		effects.append({
			"stat": stat_key,
			"multiplier": 1.0 + (float(percent_text) / 100.0),
		})
	return effects

func _normalize_upgrade_stat_name(stat_name: String) -> String:
	var normalized_name := stat_name.to_lower().replace(" ", "").replace("_", "")
	match normalized_name:
		"frontend":
			return "front_end"
		"backend":
			return "back_end"
		"documentation", "documenting":
			return "documenting"
		"speed":
			return "speed"
		"stamina":
			return "stamina"
	return ""

func _get_upgrade_applied_meta_key(category: String, tier: int) -> String:
	return "upgrade_effects_applied_%s_%d" % [_sanitize_meta_key(category), tier]

func _sanitize_meta_key(value: String) -> String:
	return value.to_lower().replace(" ", "_").replace("-", "_").replace(":", "_").replace("/", "_")

func _apply_worker_stat_multiplier(worker, stat_key: String, multiplier: float) -> void:
	if not WORKER_UPGRADE_STAT_PROPERTIES.has(stat_key):
		return
	var property_name: String = str(WORKER_UPGRADE_STAT_PROPERTIES.get(stat_key))
	var current_value: int = int(worker.get(property_name))
	var updated_value := maxi(0, int(floorf(float(current_value) * multiplier)))
	_track_worker_upgrade_bonus(worker, stat_key, float(updated_value - current_value))
	if stat_key == "stamina":
		_apply_worker_stamina_value(worker, updated_value)
	else:
		worker.set(property_name, updated_value)

func _track_worker_upgrade_bonus(worker, stat_key: String, bonus: float) -> void:
	if bonus <= 0.0:
		return
	if typeof(worker.get("upgradeStatBonuses")) != TYPE_DICTIONARY:
		worker.upgradeStatBonuses = {}
	_ensure_worker_upgrade_bonus_keys(worker)
	worker.upgradeStatBonuses[stat_key] = float(worker.upgradeStatBonuses.get(stat_key, 0.0)) + bonus

func _ensure_worker_upgrade_bonus_keys(worker) -> void:
	if typeof(worker.get("upgradeStatBonuses")) != TYPE_DICTIONARY:
		worker.upgradeStatBonuses = {}
	for stat_key in WORKER_UPGRADE_STAT_PROPERTIES.keys():
		if not worker.upgradeStatBonuses.has(stat_key):
			worker.upgradeStatBonuses[stat_key] = 0.0

func _apply_worker_stamina_value(worker, updated_stamina: int) -> void:
	var stamina_bar = worker.get_node_or_null("staminaBar")
	var previous_stamina_max := int(worker.staminaStat)
	var previous_stamina_value := previous_stamina_max
	if stamina_bar != null:
		previous_stamina_max = int(stamina_bar.max_value)
		previous_stamina_value = int(stamina_bar.value)
	worker.staminaStat = max(MIN_WORKER_STAMINA, updated_stamina)

	if stamina_bar != null:
		stamina_bar.max_value = worker.staminaStat
		if previous_stamina_max > 0:
			var stamina_ratio := float(previous_stamina_value) / float(previous_stamina_max)
			stamina_bar.value = clampi(int(round(stamina_ratio * float(worker.staminaStat))), 0, worker.staminaStat)
		else:
			stamina_bar.value = 0 if previous_stamina_value <= 0 else worker.staminaStat
