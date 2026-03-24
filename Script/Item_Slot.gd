extends NinePatchRect

signal slot_clique(item)

@onready var icone = $Icone
@onready var quantite = $Quantite

var item_actuel: Item = null


func set_item(item: Item, p_quantite: int):
	item_actuel = item
	quantite.text = "x" + str(p_quantite)
	if item.icone:
		icone.texture = item.icone
	modulate.a = 1.0

func vider():
	icone.texture = null
	quantite.text = ""
	modulate.a = 0.5

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("clic sur slot")
		if item_actuel != null:
			slot_clique.emit(item_actuel)
