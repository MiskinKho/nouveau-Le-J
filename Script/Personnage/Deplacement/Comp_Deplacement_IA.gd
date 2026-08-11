extends CompDeplacement       # Hérite de CompDeplacement : accès à speed, personnage, deplacer(), arreter()
class_name CompDeplacementIA  # Composant de déplacement pour tous les PNJ contrôlés par l'IA

var direction := Vector2.ZERO  # Direction courante de déplacement IA (choisie par choisir_direction)

# Choisit une direction de marche libre (sans obstacle).
# Teste les 8 directions dans un ordre aléatoire via raycast.
# Retient la première direction sans collision, sinon reste immobile.
func choisir_direction():
	var directions = [                                      # Les 8 directions possibles
		Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 1),
		Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)
	]
	directions.shuffle()                                    # Ordre aléatoire pour ne pas favoriser une direction
	for dir in directions:
		var iso = Vector2(dir.x, dir.y * 0.5).normalized()  # Projette en isométrique avant le raycast
		$Raycast.target_position = iso * 50                  # Projette le rayon à 50px dans la direction iso
		$Raycast.force_raycast_update()                      # Calcul immédiat (pas d'attente de frame physique)
		if not $Raycast.is_colliding():
			direction = dir                                 # Aucun obstacle : direction retenue
			return
	direction = Vector2.ZERO                                # Toutes directions bloquées : reste immobile

# Déplace le personnage vers une position cible via NavigationAgent2D (évite les obstacles).
# Appelle les animations de marche/idle via le composant d'animation (qui pilote l'AnimationTree).
func se_deplacer_vers(cible_position: Vector2):
	$NavigationAgent2D.target_position = cible_position      # Définit la destination
	var direction_nav = $NavigationAgent2D.get_next_path_position() - personnage.global_position  # Prochain waypoint du chemin
	if direction_nav.length() > 1:
		# Encore loin du waypoint : applique la vitesse iso
		var iso = Vector2(direction_nav.x, direction_nav.y * 0.5).normalized()
		personnage.velocity = iso * speed                    # Utilise speed hérité de CompDeplacement
		personnage.move_and_slide()                          # Déplace avec gestion des collisions
		personnage.comp_anim.jouer_walk(direction_nav)       # Anim Walk via Comp_Animation (gère direction + last_dir)
	else:
		# Arrivé au waypoint : s'arrête et joue idle
		personnage.velocity = Vector2.ZERO
		personnage.move_and_slide()
		personnage.comp_anim.jouer_idle()                    # Anim Idle dans la dernière direction connue (last_dir)
