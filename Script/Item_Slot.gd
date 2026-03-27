extends NinePatchRect  # NinePatchRect : fond d'UI extensible sans déformation (bordures fixes)

signal slot_clique(item)  # Émis quand l'utilisateur clique sur un slot occupé

@onready var icone = $Icone       # TextureRect enfant affichant l'icône de l'item
@onready var quantite = $Quantite # Label enfant affichant "x3", "x12", etc.

var item_actuel: Item = null  # Item actuellement dans ce slot (null si slot vide)

# Configure le slot avec un item et sa quantité.
func set_item(item: Item, p_quantite: int):
	item_actuel = item
	quantite.text = "x" + str(p_quantite)
	if item.icone:
		icone.texture = item.icone  # Affiche l'icône si définie dans la ressource
	modulate.a = 1.0  # Slot plein : opaque

# Vide visuellement le slot (slot disponible mais inoccupé).
func vider():
	icone.texture = null
	quantite.text = ""
	modulate.a = 0.5  # Slot vide : semi-transparent (feedback visuel)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("clic sur slot")
		if item_actuel != null:
			slot_clique.emit(item_actuel)  # N'émet que si le slot est occupé
