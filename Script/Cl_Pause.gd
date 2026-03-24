extends CanvasLayer

@onready var btn_reprendre = $Panel_Pause/Btn_Reprendre
@onready var btn_inventaire = $Panel_Pause/Btn_Inventaire
@onready var btn_sauvegarder = $Panel_Pause/Btn_Sauvegarder
@onready var btn_quitter = $Panel_Pause/Btn_Quitter
@onready var btn_menu = $Menu

func _ready():
	EventBus.menu_pause_ouvert.connect(ouvrir)
	visible = false
	btn_reprendre.pressed.connect(fermer)
	btn_inventaire.pressed.connect(_on_inventaire)
	btn_sauvegarder.pressed.connect(_on_sauvegarder)
	btn_quitter.pressed.connect(_on_quitter)

func ouvrir():
	visible = true
	get_tree().paused = true

func fermer():
	visible = false
	get_tree().paused = false

func _on_inventaire():
	fermer()
	EventBus.inventaire_ouvert.emit()

func _on_sauvegarder():
	EventBus.sauvegarde_demandee.emit()
	fermer()

func _on_quitter():
	get_tree().quit()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action("ui_cancel"):
			if InventoryManager.est_ouvert:
				return
			if visible:
				fermer()
			else:
				ouvrir()
