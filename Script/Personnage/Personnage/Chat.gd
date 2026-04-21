extends PNJ  # Le chat du joueur hérite de PNJ pour les animations, navigation et state machine
class_name Chat

@export var coussin: Mobilier   # True quand le PNJ a atteint physiquement le coussin (utilisé par Chat)

@export var gamelle: StaticBody2D  # Surcharge la var gamelle de PNJ (assignée dans l'éditeur)
var mange := false             # True pendant Etat_Manger : bloque l'accumulation de faim
var epuise := false            # True quand épuisé : modifie la logique de Etat_Dormir
signal chat_clique  # Émis quand on clique sur le chat EN COMBAT (déclenche l'attaque du joueur)

func _ready():
	super()  # Appelle PNJ._ready() pour initialiser nav_agent, state_machine, stats, survol
	add_to_group("chats")  # Groupe utilisé par la gamelle pour détecter l'entrée du chat

# Surcharge le clic : en combat émet chat_clique, hors combat ouvre le menu contextuel
func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if en_combat:
			chat_clique.emit()  # En combat : signal direct pour l'UI de combat
		else:
			# Hors combat : ouvre le menu contextuel à la position de la souris
			EventBus.menu_contexte_ouvert.emit(get_viewport().get_mouse_position(), self)
