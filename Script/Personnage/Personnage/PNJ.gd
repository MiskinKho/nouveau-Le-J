extends Personnage  # Base commune pour tous les personnages IA (chats, mobs, humains)
class_name PNJ      # Classe nommée PNJ (utilisée par Chat, Mob, Humain)

@onready var nav_agent = $NavigationAgent2D          # Agent de navigation pour path-finding
@onready var bt_player: BTPlayer = $StateMachine   # BTPlayer a remplacé la StateMachine

var direction := Vector2.ZERO  # Direction de déplacement actuelle (choisie par _choisir_direction)
var mange := false             # True pendant Etat_Manger : bloque l'accumulation de faim
var epuise := false            # True quand épuisé : modifie la logique de Etat_Dormir


func _ready():
	# Connexion des signaux de la zone de clic (Area2D enfant)
	$ZoneClick.input_event.connect(_on_click)
	$ZoneClick.mouse_entered.connect(_on_survol_entrer)   # Survol entrant : éclaircit le sprite
	$ZoneClick.mouse_exited.connect(_on_survol_sortir)   # Survol sortant : remet la couleur normale

	# Crée des stats par défaut si aucune ressource n'est assignée dans l'éditeur
	if stats == null:
		stats = Creature.new()

# Survol souris : éclaircit le sprite pour indiquer l'interactivité
func _on_survol_entrer():
	modulate = Color(1.5, 1.5, 1.5)   # Teinte lumineuse (blanc amplifié)

# Fin de survol : remet la couleur par défaut (blanc normal)
func _on_survol_sortir():
	modulate = Color(1, 1, 1)

func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		# Ouvre le menu contextuel à la position de la souris
		EventBus.menu_contexte_ouvert.emit(get_viewport().get_mouse_position(), self)
