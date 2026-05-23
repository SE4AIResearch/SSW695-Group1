extends RefCounted

const DEFAULT_WORKER_STATS := {
	"front_end": 3,
	"back_end": 3,
	"documenting": 3,
	"speed": 100,
	"stamina": 100,
	"rank": 1,
}
const DEFAULT_UPGRADE_STAT_BONUSES := {
	"front_end": 0.0,
	"back_end": 0.0,
	"documenting": 0.0,
	"speed": 0.0,
	"stamina": 0.0,
}

# Change this for testing to force starter workers into a specific tier.
const STARTING_WORKER_TIER := 1

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

const TIER_MIDPOINT_THRESHOLD := 50
const LOWER_HALF_UPPER_VALUE_CHANCE := 0.3
const UPPER_HALF_UPPER_VALUE_CHANCE := 0.7

static func get_default_worker_stats() -> Dictionary:
	return DEFAULT_WORKER_STATS.duplicate(true)

static func get_default_upgrade_stat_bonuses() -> Dictionary:
	return DEFAULT_UPGRADE_STAT_BONUSES.duplicate(true)

static func get_starting_worker_stats(_worker_index: int) -> Dictionary:
	return roll_worker_stats_for_tier(STARTING_WORKER_TIER)

static func get_hiring_budget_tiers() -> Array:
	return HIRING_BUDGET_TIERS.duplicate(true)

static func get_hiring_tier_by_rank(rank: int) -> Dictionary:
	var clamped_rank := clampi(rank, 1, HIRING_BUDGET_TIERS.size())
	for tier in HIRING_BUDGET_TIERS:
		if int(tier.get("rank", 0)) == clamped_rank:
			return tier.duplicate(true)
	return HIRING_BUDGET_TIERS[HIRING_BUDGET_TIERS.size() - 1].duplicate(true)

static func get_hiring_tier_for_budget(budget: int) -> Dictionary:
	var clamped_budget = clampi(budget, 0, 1000)
	for tier in HIRING_BUDGET_TIERS:
		if clamped_budget >= tier["min_budget"] and clamped_budget <= tier["max_budget"]:
			return tier.duplicate(true)
	return HIRING_BUDGET_TIERS[HIRING_BUDGET_TIERS.size() - 1].duplicate(true)

static func get_budget_progress_in_tier(budget: int, tier: Dictionary) -> int:
	return clampi(budget - tier["min_budget"], 0, tier["max_budget"] - tier["min_budget"])

static func roll_weighted_range_value(min_value: int, max_value: int, budget_progress_in_tier: int) -> int:
	if min_value >= max_value:
		return min_value

	var values = range(min_value, max_value + 1)
	var upper_half_chance = LOWER_HALF_UPPER_VALUE_CHANCE
	if budget_progress_in_tier >= TIER_MIDPOINT_THRESHOLD:
		upper_half_chance = UPPER_HALF_UPPER_VALUE_CHANCE

	var roll = randf()
	if roll < upper_half_chance:
		var upper_start = mini(values.size() - 1, int(ceil(values.size() / 2.0)))
		return values[randi_range(upper_start, values.size() - 1)]

	var lower_end = maxi(0, int(floor((values.size() - 1) / 2.0)))
	return values[randi_range(0, lower_end)]

static func roll_uniform_range_value(min_value: int, max_value: int) -> int:
	if min_value >= max_value:
		return min_value
	return randi_range(min_value, max_value)

static func roll_worker_stats_for_tier(rank: int) -> Dictionary:
	var tier := get_hiring_tier_by_rank(rank)
	return {
		"front_end": roll_uniform_range_value(int(tier["skill_floor"]), int(tier["skill_ceiling"])),
		"back_end": roll_uniform_range_value(int(tier["skill_floor"]), int(tier["skill_ceiling"])),
		"documenting": roll_uniform_range_value(int(tier["skill_floor"]), int(tier["skill_ceiling"])),
		"speed": roll_uniform_range_value(int(tier["speed_floor"]), int(tier["speed_ceiling"])),
		"stamina": roll_uniform_range_value(int(tier["stamina_floor"]), int(tier["stamina_ceiling"])),
		"rank": rank,
	}

static func roll_hiring_worker_stats(budget: int) -> Dictionary:
	var tier = get_hiring_tier_for_budget(budget)
	var budget_progress_in_tier = get_budget_progress_in_tier(clampi(budget, 0, 1000), tier)
	return {
		"front_end": roll_weighted_range_value(tier["skill_floor"], tier["skill_ceiling"], budget_progress_in_tier),
		"back_end": roll_weighted_range_value(tier["skill_floor"], tier["skill_ceiling"], budget_progress_in_tier),
		"documenting": roll_weighted_range_value(tier["skill_floor"], tier["skill_ceiling"], budget_progress_in_tier),
		"speed": roll_weighted_range_value(tier["speed_floor"], tier["speed_ceiling"], budget_progress_in_tier),
		"stamina": roll_weighted_range_value(tier["stamina_floor"], tier["stamina_ceiling"], budget_progress_in_tier),
		"rank": tier["rank"],
	}

static func apply_to_worker(worker, stats: Dictionary = {}) -> void:
	var resolved_stats = get_default_worker_stats()
	resolved_stats.merge(stats, true)
	worker.frontEndStat = resolved_stats["front_end"]
	worker.backEndStat = resolved_stats["back_end"]
	worker.documentingStat = resolved_stats["documenting"]
	worker.speedStat = resolved_stats["speed"]
	worker.staminaStat = resolved_stats["stamina"]
	worker.rank = resolved_stats["rank"]
	worker.upgradeStatBonuses = get_default_upgrade_stat_bonuses()
