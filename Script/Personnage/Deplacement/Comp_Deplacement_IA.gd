extends CompDeplacement       # Spécialise CompDeplacement pour les PNJ contrôlés par l'IA
class_name CompDeplacementIA

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D  # Agent de navigation (path-finding A*)

# Déplace le personnage vers une position cible en suivant le chemin calculé par NavigationAgent2D.
# Gère automatiquement l'évitement des obstacles via la navigation 2D de Godot.
func se_deplacer_vers(cible: Vector2) -> void:
	nav_agent.target_position = cible                                        # Définit la destination
	var direction_nav = nav_agent.get_next_path_position() - personnage.global_position  # Prochain waypoint
	if direction_nav.length() > 1:
		deplacer(direction_nav)  # Encore loin : se déplace vers le waypoint
	else:
		arreter()                # Arrivé : s'arrête

# Choisit la première direction libre (sans obstacle) parmi les 4 diagonales isométriques.
# Utilisé par les états IA (Marcher, Fatigue) pour choisir une direction de déambulation.
# ⚠️ Logique quasi-identique à _choisir_direction() dans Chat.gd — Chat.gd devrait déléguer ici.
func choisir_direction() -> Vector2:
	var directions = [
		Vector2(1, 1), Vector2(-1, 1),
		Vector2(1, -1), Vector2(-1, -1)
	]
	directions.shuffle()  # Mélange pour ne pas toujours tester dans le même ordre
	for dir in directions:
		var iso = Vector2(dir.x, dir.y * 0.5).normalized()
		var raycast = personnage.get_node("Raycast")  # Raycast enfant du personnage
		raycast.target_position = iso * 50            # Portée de détection : 50px
		raycast.force_raycast_update()                # Force le calcul immédiat
		if not raycast.is_colliding():
			return dir  # Direction libre trouvée
	return Vector2.ZERO  # Toutes directions bloquées
