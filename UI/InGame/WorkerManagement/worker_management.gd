extends Node2D

@onready var name_label: Label = %WorkerName
@onready var rank_label: Label = %WorkerRank
@onready var upgrade_button: Button = %UpgradeButton
@onready var fire_button: Button = %FireButton
@onready var confirm_dialog: ConfirmationDialog = %ConfirmFireDialog

@onready var fe_bar: TextureProgressBar = %FEBar
@onready var be_bar: TextureProgressBar = %BEBar
@onready var doc_bar: TextureProgressBar = %DocBar
@onready var speed_bar: TextureProgressBar = %SpeedBar
@onready var stamina_bar: TextureProgressBar = %StaminaBar
@onready var fe_value: Label = %FEValue
@onready var be_value: Label = %BEValue
@onready var doc_value: Label = %DocValue
@onready var speed_value: Label = %SpeedValue
@onready var stamina_value: Label = %StaminaValue

var current_worker = null

func _ready() -> void:
	visible = false
	if not confirm_dialog.confirmed.is_connected(_on_fire_confirmed):
		confirm_dialog.confirmed.connect(_on_fire_confirmed)

func show_worker(worker) -> void:
	current_worker = worker
	name_label.text = worker.personName
	rank_label.text = "Rank: " + str(worker.rank)
	
	fe_bar.value = worker.frontEndStat
	be_bar.value = worker.backEndStat
	doc_bar.value = worker.documentingStat
	speed_bar.value = worker.speedStat
	stamina_bar.value = worker.staminaStat
	
	fe_value.text = str(worker.frontEndStat) + " / " + str(int(fe_bar.max_value))
	be_value.text = str(worker.backEndStat) + " / " + str(int(be_bar.max_value))
	doc_value.text = str(worker.documentingStat) + " / " + str(int(doc_bar.max_value))
	speed_value.text = str(worker.speedStat) + " / " + str(int(speed_bar.max_value))
	stamina_value.text = str(worker.staminaStat) + " / " + str(int(stamina_bar.max_value))
	
	_update_upgrade_button()
	visible = true

func _update_upgrade_button() -> void:
	if current_worker == null:
		return
	
	var validation = PlayerTool.can_upgrade_worker(current_worker)
	if bool(validation.get("ok", false)):
		upgrade_button.disabled = false
		upgrade_button.text = "Upgrade ($" + str(validation.get("cost", 0)) + ")"
	else:
		upgrade_button.disabled = true
		if current_worker.rank >= 10:
			upgrade_button.text = "Max Rank"
		else:
			upgrade_button.text = 'Cannot \n Afford'

func _on_upgrade_button_pressed() -> void:
	if current_worker == null:
		return
	
	var result = PlayerTool.upgrade_worker(current_worker)
	if bool(result.get("ok", false)):
		AudioManager.play_sfx("cash_register")
		show_worker(current_worker) # Refresh UI
	else:
		AudioManager.play_sfx("buzzer_error")

func _on_fire_button_pressed() -> void:
	confirm_dialog.popup_centered()

func _on_fire_confirmed() -> void:
	if current_worker == null:
		return
	PlayerTool.fire_worker(current_worker)
	visible = false

func _on_close_button_pressed() -> void:
	visible = false
