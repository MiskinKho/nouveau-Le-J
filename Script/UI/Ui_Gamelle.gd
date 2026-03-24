extends CanvasLayer

@onready var grille = $Panel_Gamelle/Grille_Items
@onready var btn_fermer = $Panel_Gamelle/Btn_Fermer

const ITEM_SCENE = preload("res://Scène/Item_Slot.tscn")

var gamelle_cible = null

func _ready():
	EventBus.menu_gamelle_ouvert.connect(ouvrir)
	visible = false
	btn_fermer.pressed.connect(fermer)


func ouvrir(gamelle):
	gamelle_cible = gamelle
	visible = true
	_afficher_items()

func fermer():
	gamelle_cible = null
	visible = false

func _afficher_items():
	for enfant in grille.get_children():
		enfant.queue_free()
	
	var inventaire = InventoryManager.get_inventaire()
	print("Taille inventaire : ", inventaire.size())
	print("Contenu : ", inventaire)
	for item in inventaire.keys():
		if item == null:
			continue
		print("Item : ", item.nom, " type : ", item.type)
		if item.type == Item.Type.NOURRITURE_CHAT:
			var slot = ITEM_SCENE.instantiate()
			grille.add_child(slot)
			slot.set_item(item, inventaire[item])
			slot.slot_clique.connect(func(i): _on_item_selectionne(i))
			
func _on_item_selectionne(item: Item):
	print("item sélectionné : ", item.nom)
	if InventoryManager.retirer_item(item):
		gamelle_cible.remplir(item)
		fermer()
