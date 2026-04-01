extends RefCounted

const DEFAULT_WORKER_STATS := {
	"front_end": 3,
	"back_end": 3,
	"documenting": 3,
	"speed": 100,
	"stamina": 100,
}

const STARTING_WORKER_STATS := [
	{
		"front_end": 5,
		"back_end": 5,
		"documenting": 5,
		"speed": 100,
		"stamina": 100,
	},
	{
		"front_end": 5,
		"back_end": 5,
		"documenting": 5,
		"speed": 100,
		"stamina": 100,
	},
]

# Edit these tiers to rebalance hiring without changing any generation logic.
const HIRING_BUDGET_TIERS := [
	{
		"rank": 1,
		"min_budget": 0,
		"max_budget": 99,
		"skill_floor": 1,
		"skill_ceiling": 2,
		"speed_floor": 35,
		"speed_ceiling": 50,
		"stamina_floor": 50,
		"stamina_ceiling": 65,
	},
	{
		"rank": 2,
		"min_budget": 100,
		"max_budget": 199,
		"skill_floor": 1,
		"skill_ceiling": 3,
		"speed_floor": 40,
		"speed_ceiling": 55,
		"stamina_floor": 55,
		"stamina_ceiling": 70,
	},
	{
		"rank": 3,
		"min_budget": 200,
		"max_budget": 299,
		"skill_floor": 2,
		"skill_ceiling": 4,
		"speed_floor": 45,
		"speed_ceiling": 65,
		"stamina_floor": 60,
		"stamina_ceiling": 75,
	},
	{
		"rank": 4,
		"min_budget": 300,
		"max_budget": 399,
		"skill_floor": 3,
		"skill_ceiling": 5,
		"speed_floor": 55,
		"speed_ceiling": 75,
		"stamina_floor": 65,
		"stamina_ceiling": 80,
	},
	{
		"rank": 5,
		"min_budget": 400,
		"max_budget": 499,
		"skill_floor": 4,
		"skill_ceiling": 6,
		"speed_floor": 65,
		"speed_ceiling": 85,
		"stamina_floor": 70,
		"stamina_ceiling": 85,
	},
	{
		"rank": 6,
		"min_budget": 500,
		"max_budget": 599,
		"skill_floor": 5,
		"skill_ceiling": 7,
		"speed_floor": 75,
		"speed_ceiling": 95,
		"stamina_floor": 75,
		"stamina_ceiling": 90,
	},
	{
		"rank": 7,
		"min_budget": 600,
		"max_budget": 699,
		"skill_floor": 6,
		"skill_ceiling": 8,
		"speed_floor": 85,
		"speed_ceiling": 105,
		"stamina_floor": 80,
		"stamina_ceiling": 94,
	},
	{
		"rank": 8,
		"min_budget": 700,
		"max_budget": 799,
		"skill_floor": 7,
		"skill_ceiling": 9,
		"speed_floor": 92,
		"speed_ceiling": 112,
		"stamina_floor": 84,
		"stamina_ceiling": 97,
	},
	{
		"rank": 9,
		"min_budget": 800,
		"max_budget": 899,
		"skill_floor": 7,
		"skill_ceiling": 10,
		"speed_floor": 98,
		"speed_ceiling": 120,
		"stamina_floor": 88,
		"stamina_ceiling": 100,
	},
	{
		"rank": 10,
		"min_budget": 900,
		"max_budget": 1000,
		"skill_floor": 8,
		"skill_ceiling": 10,
		"speed_floor": 105,
		"speed_ceiling": 125,
		"stamina_floor": 92,
		"stamina_ceiling": 100,
	},
]

static func get_default_worker_stats() -> Dictionary:
	return DEFAULT_WORKER_STATS.duplicate(true)

static func get_starting_worker_stats(worker_index: int) -> Dictionary:
	if worker_index >= 0 and worker_index < STARTING_WORKER_STATS.size():
		return STARTING_WORKER_STATS[worker_index].duplicate(true)
	return get_default_worker_stats()

static func get_hiring_budget_tiers() -> Array:
	return HIRING_BUDGET_TIERS.duplicate(true)

static func get_hiring_tier_for_budget(budget: int) -> Dictionary:
	var clamped_budget = clampi(budget, 0, 1000)
	for tier in HIRING_BUDGET_TIERS:
		if clamped_budget >= tier["min_budget"] and clamped_budget <= tier["max_budget"]:
			return tier.duplicate(true)
	return HIRING_BUDGET_TIERS[HIRING_BUDGET_TIERS.size() - 1].duplicate(true)

static func roll_hiring_worker_stats(budget: int) -> Dictionary:
	var tier = get_hiring_tier_for_budget(budget)
	return {
		"front_end": randi_range(tier["skill_floor"], tier["skill_ceiling"]),
		"back_end": randi_range(tier["skill_floor"], tier["skill_ceiling"]),
		"documenting": randi_range(tier["skill_floor"], tier["skill_ceiling"]),
		"speed": randi_range(tier["speed_floor"], tier["speed_ceiling"]),
		"stamina": randi_range(tier["stamina_floor"], tier["stamina_ceiling"]),
	}

static func apply_to_worker(worker, stats: Dictionary = {}) -> void:
	var resolved_stats = get_default_worker_stats()
	resolved_stats.merge(stats, true)
	worker.frontEndStat = resolved_stats["front_end"]
	worker.backEndStat = resolved_stats["back_end"]
	worker.documentingStat = resolved_stats["documenting"]
	worker.speedStat = resolved_stats["speed"]
	worker.staminaStat = resolved_stats["stamina"]
