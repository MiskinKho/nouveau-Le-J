extends Personnage  # Base commune pour tous les personnages IA (chats, mobs, humains)
class_name PNJ      # Classe nommée PNJ (utilisée par Chat, Mob, Humain)

@onready var nav_agent = $NavigationAgent2D          # Agent de navigation pour path-finding
@onready var state_machine: StateMachine = $StateMachine  # Machine à états enfant

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

# Choisit une direction de marche libre (sans obstacle).
# Délègue à CompDeplacementIA si disponible, sinon effectue le raycast directement.
func _choisir_direction():
	var directions = [
		Vector2(1, 1), Vector2(-1, 1),
		Vector2(1, -1), Vector2(-1, -1)
	]
	directions.shuffle()  # Ordre aléatoire pour ne pas favoriser une diagonale
	for dir in directions:
		var iso = Vector2(dir.x, dir.y * 0.5).normalized()
		$Raycast.target_position = iso * 50        # Projette le rayon à 50px dans la direction iso
		$Raycast.force_raycast_update()             # Calcul immédiat (pas d'attente de frame physique)
		if not $Raycast.is_colliding():
			direction = dir                         # Aucun obstacle : direction retenue
			return
	direction = Vector2.ZERO  # Toutes directions bloquées : reste immobile

# Déplace le personnage vers une position cible via NavigationAgent2D (évite les obstacles).
func _se_deplacer_vers(cible_position: Vector2):
	nav_agent.target_position = cible_position                         # Définit la destination
	var direction_nav = nav_agent.get_next_path_position() - global_position  # Prochain waypoint du chemin
	if direction_nav.length() > 1:
		# Encore loin du waypoint : applique la vitesse iso
		var iso = Vector2(direction_nav.x, direction_nav.y * 0.5).normalized()
		velocity = iso * speed
		move_and_slide()
		_play_walk(_dir8_from_vector(direction_nav))  # Animation de marche dans la bonne direction
	else:
		# Arrivé au waypoint : s'arrête et joue idle
		velocity = Vector2.ZERO
		move_and_slide()
		_play_idle()
