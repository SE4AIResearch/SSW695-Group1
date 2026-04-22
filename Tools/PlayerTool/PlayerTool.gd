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
signal officeTierChanged
signal upgradesChanged

const LOOP_NO_PROJECT := "no_project"
const LOOP_PLANNING_WEEK := "planning_week"
const LOOP_ACTIVE_WEEK := "active_week"
const LOOP_RESOLVING_WEEK := "resolving_week"
const OFFICE_CAPACITY_BY_TIER := [6, 8, 10, 12, 14]
const DESKTOP_PC_SCENE_PROP_KEY := "desktop_pc"
const DESKTOP_PC_SKILL_MULTIPLIER := 1.05
const DESKTOP_PC_BOOST_APPLIED_META_KEY := "desktop_pc_skill_boost_applied"
const DESKTOP_PC_BASE_FRONTEND_META_KEY := "desktop_pc_base_frontend"
const DESKTOP_PC_BASE_BACKEND_META_KEY := "desktop_pc_base_backend"
const COFFEE_MACHINE_SCENE_PROP_KEY := "coffee_machine"
const COFFEE_MACHINE_STAMINA_MULTIPLIER := 1.1
const COFFEE_MACHINE_BOOST_APPLIED_META_KEY := "coffee_machine_stamina_boost_applied"
const COFFEE_MACHINE_BASE_STAMINA_META_KEY := "coffee_machine_base_stamina"
const MIN_WORKER_STAMINA := 1
const WORKER_LEVEL_SCALE := Vector2(2.5, 2.5)

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
var has_viewed_methodology_learning_center: bool = false
var office_tier: int = 0
var max_worker_capacity: int = 6
var remaining_project_choice_names: Array = []

var loopPhase: String = LOOP_NO_PROJECT
var weekResults: Dictionary = {}
var selectedAssignments: Dictionary = {}
var backlogItems: Array = []
var pendingProjectSummary: Dictionary = {}
var sprintGoal: Dictionary = {}
var shouldShowWeekResultsModal: bool = false

var _backlogItemIdCounter: int = 0

func initializeNewSave():
	resetData()
	var freeWorker1 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(0))
	var freeWorker2 = PersonConstructor.generateWorker(PersonConstructor.getStartingWorkerStats(1))
	$workerHoldover.add_child(freeWorker1)
	$workerHoldover.add_child(freeWorker2)
	newHire(freeWorker1)
	newHire(freeWorker2)

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
	var updatedValue := int(metrics.get(metricName)) + amount
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
	currency = 100.0
	score = 0
	weekResults = {}
	selectedAssignments = {}
	backlogItems = []
	pendingProjectSummary = {}
	sprintGoal = {}
	shouldShowWeekResultsModal = false
	weekTime = 0
	projWeek = 0
	projSprint = 0
	totalEvents = 0
	FEBacklogStep = 0
	BEBacklogStep = 0
	docBacklogStep = 0
	_backlogItemIdCounter = 0
	loopPhase = LOOP_NO_PROJECT
	currencyChanged.emit()
	scoreChanged.emit()
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
	_prepare_sprint_context(projSprint)
	loopPhase = LOOP_PLANNING_WEEK
	projectSelected.emit()
	backlogUpdated.emit()
	loopStateChanged.emit()
	statsChanged.emit()

func newHire(worker) -> bool:
	if workers.size() >= max_worker_capacity:
		return false
	_apply_active_upgrade_effects_to_worker(worker)
	worker.name = worker.personName
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
	var category := str(upgrade_data.get("category", ""))
	var target_tier := int(upgrade_data.get("tier", 0))
	var cost := int(upgrade_data.get("cost", 0))

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
	_apply_standard_upgrade_purchase_effects(purchased_upgrade)
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
	for workerName in assignmentKeys:
		var item := getBacklogItemById(int(selectedAssignments.get(workerName, -1)))
		var worker = getWorkerByName(str(workerName))
		if item.is_empty() or worker == null:
			continue
		if !worker.resting: _resolve_assignment(worker, item)

	clearAssignments()
	weekTime = 0

	var sprintFinished: bool = projWeek >= int(project.sprintLength)
	if sprintFinished:
		if projSprint >= int(project.sprintAmount) or _allBacklogItemsComplete():
			projectCompleted.emit()
			deadlineReached.emit()
			completed_project_count += 1
			project = null
			backlogItems = []
			sprintGoal = {}
			projWeek = 0
			projSprint = 0
			loopPhase = LOOP_NO_PROJECT
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

func assignWorkerToItem(workerName: String, itemId: int) -> Dictionary:
	if project == null or loopPhase != LOOP_PLANNING_WEEK:
		return {"ok": false, "reason": "You can only assign work while planning the week."}
	var item := getBacklogItemById(itemId)
	if item.is_empty():
		return {"ok": false, "reason": "That backlog item no longer exists."}
	if item.get("status") == "done":
		return {"ok": false, "reason": "That item is already complete."}
	var previousWorkerName := str(item.get("assigned_worker_name", ""))
	if previousWorkerName != "" and previousWorkerName != workerName:
		return {"ok": false, "reason": "%s is already assigned to that card." % previousWorkerName}
	unassignWorker(workerName)
	item.set("assigned_worker_name", workerName)
	if item.get("status") == "backlog":
		item.set("status", "in_progress")
	selectedAssignments.set(workerName, itemId)
	backlogUpdated.emit()
	return {"ok": true, "reason": "%s is now assigned to %s." % [workerName, str(item.get("name", ""))]}

func unassignWorker(workerName: String) -> void:
	if not selectedAssignments.has(workerName):
		return
	var item := getBacklogItemById(int(selectedAssignments.get(workerName, -1)))
	if not item.is_empty():
		item.set("assigned_worker_name", "")
		if item.get("status") == "in_progress" and int(item.get("effort_remaining", 0)) >= int(item.get("total_effort", 0)):
			item.set("status", "backlog")
	selectedAssignments.erase(workerName)
	backlogUpdated.emit()

func clearAssignments() -> void:
	for workerName in selectedAssignments.keys():
		var item := getBacklogItemById(int(selectedAssignments.get(workerName, -1)))
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
		var metricData = metricDictionary.get(index)
		if metricData is Dictionary and metricData.has("required_skill"):
			var existingItem: Dictionary = metricData.duplicate(true)
			_backlogItemIdCounter += 1
			existingItem.set("id", _backlogItemIdCounter)
			existingItem.set("name", str(existingItem.get("name", "Backlog Item")))
			existingItem.set("required_skill", str(existingItem.get("required_skill", requiredSkill)))
			var totalEffort := maxi(1, int(existingItem.get("total_effort", existingItem.get("effort_remaining", 1))))
			existingItem.set("total_effort", totalEffort)
			existingItem.set("effort_remaining", clampi(int(existingItem.get("effort_remaining", totalEffort)), 0, totalEffort))
			existingItem.set("status", str(existingItem.get("status", "backlog")))
			existingItem.set("assigned_worker_name", str(existingItem.get("assigned_worker_name", "")))
			existingItem.set("metric_reward", maxi(1, int(existingItem.get("metric_reward", 2))))
			existingItem.set("is_scope_change", bool(existingItem.get("is_scope_change", false)))
			existingItem.set("is_reliability_critical", bool(existingItem.get("is_reliability_critical", false)))
			backlogItems.append(existingItem)
			continue
		var itemName := str(metricData)
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
		"effort_remaining": maxi(1, effort),
		"total_effort": maxi(1, effort),
		"status": "backlog",
		"assigned_worker_name": "",
		"metric_reward": maxi(1, metricReward),
		"is_scope_change": isScopeChange,
		"is_reliability_critical": isReliabilityCritical,
	})

func _prepare_sprint_context(sprintNumber: int) -> void:
	sprintGoal = {
		"title": "Sprint %d" % sprintNumber
	}

func _resolve_assignment(worker, item: Dictionary) -> void:
	var metricKey := str(item.get("required_skill", "frontEnd"))
	var workerSkill := _get_worker_skill(worker, metricKey)
	var progress := workerSkill
	# if not _worker_is_specialist_for_item(worker, item):
	# 	progress = int(floor(progress * 0.5))
	progress = maxi(1, int(floor(float(progress) * (float(worker.speedStat) / 100.0))))

	var previousEffort := int(item.get("effort_remaining", 0))
	item.set("effort_remaining", maxi(0, previousEffort - progress))
	if int(item.get("effort_remaining", 0)) <= 0:
		item.set("status", "done")
		_apply_backlog_item_completion(item)
	else:
		item.set("status", "in_progress")

func _apply_backlog_item_completion(item: Dictionary) -> void:
	var metricKey := str(item.get("required_skill", "frontEnd"))
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
	var metricKey := str(item.get("required_skill", "frontEnd"))
	var workerSkill := _get_worker_skill(worker, metricKey)
	var bestSkill := maxi(int(worker.frontEndStat), maxi(int(worker.backEndStat), int(worker.documentingStat)))
	return workerSkill >= bestSkill

func earnSprintMoney():
	if project != null:
		addCurrency(floorf((30 * project.projectDifficulty) + (5 * projectAmount) + (50 * (teamRank - 1))))

func earnProjectMoney(SatisfactionAmount):
	addCurrency(floorf((500 * projectRatedDifficulty) + (25 * projectAmount) + (650 * (teamRank - 1))*SatisfactionAmount))

func returnSprintMoney(SatisfactionAmount):
	return floorf(((500 * projectRatedDifficulty) + (25 * projectAmount) + (650 * (teamRank - 1)))*SatisfactionAmount)

func get_office_capacity_for_tier(tier: int) -> int:
	var clamped_tier := clampi(tier, 0, OFFICE_CAPACITY_BY_TIER.size() - 1)
	return int(OFFICE_CAPACITY_BY_TIER[clamped_tier])

func can_purchase_office_upgrade(upgrade_data: Dictionary) -> Dictionary:
	var target_tier := int(upgrade_data.get("tier", 0))
	var required_projects := int(upgrade_data.get("required_projects", 0))
	var required_workers := int(upgrade_data.get("required_workers", 0))
	var cost := int(upgrade_data.get("cost", 0))

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

	var target_tier := int(upgrade_data.get("tier", 0))
	var cost := int(upgrade_data.get("cost", 0))
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
	var normalized_upgrade := {
		"category": str(upgrade_data.get("category", "")),
		"tier": int(upgrade_data.get("tier", 0)),
		"name": str(upgrade_data.get("name", "")),
	}

	if upgrade_data.has("scene_prop_key"):
		normalized_upgrade["scene_prop_key"] = str(upgrade_data.get("scene_prop_key", ""))
	if upgrade_data.has("capacity"):
		normalized_upgrade["capacity"] = int(upgrade_data.get("capacity", 0))

	return normalized_upgrade

func _apply_standard_upgrade_purchase_effects(upgrade_data: Dictionary) -> void:
	if _is_desktop_pc_upgrade(upgrade_data):
		_apply_desktop_pc_skill_boost_to_all_workers()
	if _is_coffee_machine_upgrade(upgrade_data):
		_apply_coffee_machine_stamina_boost_to_all_workers()

func _apply_active_upgrade_effects_to_worker(worker) -> void:
	if _has_active_upgrade_with_scene_prop_key(DESKTOP_PC_SCENE_PROP_KEY):
		_apply_worker_desktop_pc_boost(worker, DESKTOP_PC_SKILL_MULTIPLIER)
	if _has_active_upgrade_with_scene_prop_key(COFFEE_MACHINE_SCENE_PROP_KEY):
		_apply_worker_stamina_boost(worker, COFFEE_MACHINE_STAMINA_MULTIPLIER)

func _apply_desktop_pc_skill_boost_to_all_workers() -> void:
	for worker in workers:
		_apply_worker_desktop_pc_boost(worker, DESKTOP_PC_SKILL_MULTIPLIER)

func _apply_coffee_machine_stamina_boost_to_all_workers() -> void:
	for worker in workers:
		_apply_worker_stamina_boost(worker, COFFEE_MACHINE_STAMINA_MULTIPLIER)

func _has_active_upgrade_with_scene_prop_key(scene_prop_key: String) -> bool:
	for upgrade_data in upgrades:
		if str(upgrade_data.get("scene_prop_key", "")) == scene_prop_key:
			return true
	return false

func _is_coffee_machine_upgrade(upgrade_data: Dictionary) -> bool:
	return str(upgrade_data.get("scene_prop_key", "")) == COFFEE_MACHINE_SCENE_PROP_KEY

func _is_desktop_pc_upgrade(upgrade_data: Dictionary) -> bool:
	return str(upgrade_data.get("scene_prop_key", "")) == DESKTOP_PC_SCENE_PROP_KEY

func _apply_worker_desktop_pc_boost(worker, multiplier: float) -> void:
	if worker == null:
		return
	if bool(worker.get_meta(DESKTOP_PC_BOOST_APPLIED_META_KEY, false)):
		return
	if not worker.has_meta(DESKTOP_PC_BASE_FRONTEND_META_KEY):
		worker.set_meta(DESKTOP_PC_BASE_FRONTEND_META_KEY, int(worker.frontEndStat))
	if not worker.has_meta(DESKTOP_PC_BASE_BACKEND_META_KEY):
		worker.set_meta(DESKTOP_PC_BASE_BACKEND_META_KEY, int(worker.backEndStat))

	worker.frontEndStat = max(0, int(round(float(worker.get_meta(DESKTOP_PC_BASE_FRONTEND_META_KEY)) * multiplier)))
	worker.backEndStat = max(0, int(round(float(worker.get_meta(DESKTOP_PC_BASE_BACKEND_META_KEY)) * multiplier)))
	worker.set_meta(DESKTOP_PC_BOOST_APPLIED_META_KEY, true)

func _apply_worker_stamina_boost(worker, multiplier: float) -> void:
	if worker == null:
		return
	if bool(worker.get_meta(COFFEE_MACHINE_BOOST_APPLIED_META_KEY, false)):
		return
	var stamina_bar = worker.get_node_or_null("staminaBar")
	var previous_stamina_max := int(worker.staminaStat)
	var previous_stamina_value := previous_stamina_max
	if stamina_bar != null:
		previous_stamina_max = int(stamina_bar.max_value)
		previous_stamina_value = int(stamina_bar.value)
	if not worker.has_meta(COFFEE_MACHINE_BASE_STAMINA_META_KEY):
		var base_stamina := int(worker.staminaStat)
		worker.set_meta(COFFEE_MACHINE_BASE_STAMINA_META_KEY, base_stamina)
	var boosted_stamina := int(round(float(worker.get_meta(COFFEE_MACHINE_BASE_STAMINA_META_KEY)) * multiplier))
	worker.staminaStat = max(MIN_WORKER_STAMINA, boosted_stamina)
	worker.set_meta(COFFEE_MACHINE_BOOST_APPLIED_META_KEY, true)

	if stamina_bar != null:
		stamina_bar.max_value = worker.staminaStat
		if previous_stamina_max > 0:
			var stamina_ratio := float(previous_stamina_value) / float(previous_stamina_max)
			stamina_bar.value = clampi(int(round(stamina_ratio * float(worker.staminaStat))), 0, worker.staminaStat)
		else:
			stamina_bar.value = 0 if previous_stamina_value <= 0 else worker.staminaStat
