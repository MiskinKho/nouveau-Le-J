extends State  # Hérite de State, implémente l'état "déplacement aléatoire"





func enter() -> void:
	duree = randf_range(1.0, 3.0)   # Durée plus courte qu'Idle : le chat marche par courtes séquences
	personnage._choisir_direction()  # Choisit une direction libre (sans mur devant, via raycast)

func update(delta: float) -> void:
	if _verifier_vitaux():   # Vérifie faim/énergie — priorité absolue sur tout déplacement
		return

	duree -= delta           # Décompte le temps de marche
	if duree <= 0:
		personnage.state_machine._changer_etat(_choisir_prochain(POIDS))
		return

	# Applique la projection isométrique : y divisé par 2 pour aplatir le mouvement vertical
	var iso := Vector2(personnage.direction.x, personnage.direction.y * 0.5)
	personnage.velocity = iso.normalized() * personnage.speed  # Normalise pour vitesse constante en diagonale
	personnage.move_and_slide()                                 # Déplace avec gestion des collisions
	# Met à jour l'animation de marche selon la direction en 8 directions
	personnage._play_walk(personnage._dir8_from_vector(personnage.direction))

func exit() -> void:
	personnage.velocity = Vector2.ZERO  # Arrête tout mouvement en quittant l'état
