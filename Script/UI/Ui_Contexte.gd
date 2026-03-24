extends CanvasLayer

const MENU_SCENE = preload("res://Scène/Menu_Contexte.tscn")
var menu_instance = null
var cible_actuelle = null


func _ready():
	EventBus.menu_contexte_ouvert.connect(ouvrir)
	
	
func ouvrir(position_ecran: Vector2, cible):
	if menu_instance:
		menu_instance.queue_free()
	cible_actuelle = cible
	EventBus.hud_chat_visible.emit(true, cible)
	menu_instance = MENU_SCENE.instantiate()
	add_child(menu_instance)
	menu_instance.position = position_ecran
	menu_instance.action_choisie.connect(func(action): _on_action(action, cible))
	visible = true

func _on_action(action: String, cible):
	fermer()
	match action:
		"entrainer":
			CreatureManager.entrainer(cible)
		"caresser":
			CreatureManager.caresser(cible)

func _input(event):
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed:
		if menu_instance and not menu_instance.get_global_rect().has_point(get_viewport().get_mouse_position()):
			fermer()

func fermer():
	if cible_actuelle:
		cible_actuelle = null
	EventBus.hud_chat_visible.emit(false, null)
	visible = false
