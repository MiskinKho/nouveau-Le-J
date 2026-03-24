extends CanvasLayer

@onready var label_nom_chat = $Panel_Chat/Label_Nom_Chat
@onready var barre_pv = $Panel_Chat/Barre_PV
@onready var label_pv = $Panel_Chat/Label_PV
@onready var barre_energie = $Panel_Chat/Barre_Energie
@onready var label_energie = $Panel_Chat/Label_Energie
@onready var barre_faim = $Panel_Chat/Barre_Faim
@onready var label_faim = $Panel_Chat/Label_Faim

@export var chat: CharacterBody2D

func _ready():
	TimeManager.heure_change.connect(_on_heure_change)

func _process(_delta):
	if chat and chat.stats:
		_mettre_a_jour_hud()

func _on_heure_change(_heure):
	get_node("Label_Heure").text = TimeManager.get_date_formatee()

func _mettre_a_jour_hud():
	var stats = chat.stats
	label_nom_chat.text = stats.nom
	barre_pv.max_value = stats.combat.pv_max
	barre_pv.value = stats.combat.pv_actuel
	label_pv.text = "%d / %d" % [stats.combat.pv_actuel, stats.combat.pv_max]
	barre_energie.max_value = 100
	barre_energie.value = stats.bien_etre.energie
	label_energie.text = "%d / 100" % stats.bien_etre.energie
	barre_faim.max_value = 100
	barre_faim.value = stats.bien_etre.faim
	label_faim.text = "%d / 100" % stats.bien_etre.faim

func _on_btn_sauvgarder_pressed() -> void:
	EventBus.sauvegarde_demandee.emit()

func _on_inventaire_pressed():
	EventBus.inventaire_ouvert.emit()

func _on_menu_pressed() -> void:
	EventBus.menu_pause_ouvert.emit()
	
	EventBus.hud_chat_visible.connect(_on_hud_chat_visible)

func _on_hud_chat_visible(p_visible: bool, cible):
	if cible:
		chat = cible
	get_node("Panel_Chat").visible = p_visible
