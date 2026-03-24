extends CanvasLayer

@onready var grille = $Panel_Inventaire/Grille_Items
@onready var btn_fermer = $Panel_Inventaire/Btn_Fermer
const ITEM_SCENE = preload("res://Scène/Item_Slot.tscn")

func _ready():

	visible = false
	btn_fermer.pressed.connect(fermer)
	EventBus.inventaire_ouvert.connect(ouvrir)

func ouvrir():
	InventoryManager.est_ouvert = true
	visible = true
	_afficher_items()

func fermer():
	InventoryManager.est_ouvert = false
	visible = false

func _afficher_items():
	for enfant in grille.get_children():
		enfant.queue_free()
	
	var inventaire = InventoryManager.get_inventaire()
	var items_list = inventaire.keys()
	
	for i in range(InventoryManager.capacite_max):
		var slot = ITEM_SCENE.instantiate()
		grille.add_child(slot)
		if i < items_list.size():
			slot.set_item(items_list[i], inventaire[items_list[i]])
		else:
			slot.vider()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action("ui_cancel") and visible:
				fermer()
				get_viewport().set_input_as_handled()
