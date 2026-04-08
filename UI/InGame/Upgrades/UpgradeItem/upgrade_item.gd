extends PanelContainer

var tier_label: Label
var lock_label: Label
var upgrade_name: Label
var description_label: Label
var action_button: Button

func _ready() -> void:
	_cache_nodes()

func _cache_nodes() -> void:
	if tier_label != null:
		return

	tier_label = get_node_or_null("MarginContainer/VBoxContainer/HeaderRow/TierLabel")
	lock_label = get_node_or_null("MarginContainer/VBoxContainer/HeaderRow/LockLabel")
	upgrade_name = get_node_or_null("MarginContainer/VBoxContainer/UpgradeName")
	description_label = get_node_or_null("MarginContainer/VBoxContainer/Description")
	action_button = get_node_or_null("MarginContainer/VBoxContainer/ActionButton")

func setup_upgrade(upgrade_data: Dictionary) -> void:
	_cache_nodes()

	if tier_label == null or lock_label == null or upgrade_name == null or description_label == null or action_button == null:
		return

	var locked: bool = upgrade_data.get("locked", false)
	var card_style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat

	tier_label.text = "TIER %d" % int(upgrade_data.get("tier", 1))
	lock_label.visible = locked
	upgrade_name.text = str(upgrade_data.get("name", "Upgrade"))
	description_label.text = str(upgrade_data.get("description", ""))
	action_button.text = "Locked" if locked else "Buy - $%s" % str(upgrade_data.get("cost", 0))
	action_button.disabled = locked

	if locked:
		card_style.bg_color = Color("0a1020")
		card_style.border_color = Color("233250")
		tier_label.modulate = Color("6f87b6")
		lock_label.modulate = Color("6f87b6")
		upgrade_name.modulate = Color("cfd8ee")
		description_label.modulate = Color("8aa1cd")
	else:
		card_style.bg_color = Color("131d34")
		card_style.border_color = Color("32476f")
		tier_label.modulate = Color("8aa1cd")
		lock_label.modulate = Color("8aa1cd")
		upgrade_name.modulate = Color(1, 1, 1)
		description_label.modulate = Color("9cb8ea")

	add_theme_stylebox_override("panel", card_style)
