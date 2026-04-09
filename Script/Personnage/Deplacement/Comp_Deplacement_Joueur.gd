extends CompDeplacement           # Hérite de CompDeplacement : accès à speed, personnage, deplacer(), arreter()
class_name CompDeplacementJoueur  # Composant de déplacement spécifique au joueur (input clavier/manette)

# _physics_process() gère tout le cycle de déplacement du joueur chaque frame physique
func _physics_process(_delta: float) -> void:
	var input := get_direction()                                          # Lit l'input clavier/manette

	# Guard : bloque tout mouvement en combat, menu ou repositionnement
	if personnage.en_combat or personnage.menu_ouvert or personnage.en_repositionnement:
		if not personnage.en_repositionnement:                            # Le repositionnement gère son propre mouvement
			personnage.velocity = Vector2.ZERO                            # Arrête le personnage
			personnage.move_and_slide()                                   # Applique la physique
			if not personnage.sprite.animation.begins_with("ATK"):        # Ne coupe pas une animation d'attaque en cours
				personnage._play_idle(personnage.last_dir)                # Joue l'idle dans la dernière direction
		return                                                            # Bloqué → on sort

	# Mode escalier (sas) : restreint aux directions NE/SO uniquement
	if personnage.sas:
		if input != Vector2.ZERO:
			if input.x > 0:                                               # Input vers la droite → monte (NE)
				personnage.last_dir = "NE"
				personnage._play_walk("NE")
			elif input.x < 0:                                             # Input vers la gauche → descend (SO)
				personnage.last_dir = "SO"
				personnage._play_walk("SO")
			else:
				personnage._play_idle(personnage.last_dir)                # Input vertical pur → idle
		else:
			personnage._play_idle(personnage.last_dir)                    # Pas d'input → idle
		deplacer(input)                                                   # Applique le déplacement iso via CompDeplacement
		return                                                            # Sas géré → on sort

	# Déplacement normal au sol
	if input == Vector2.ZERO:                                             # Pas d'input → arrêt
		arreter()                                                         # Stoppe via CompDeplacement (velocity = 0 + move_and_slide)
		personnage._play_idle(personnage.last_dir)                        # Joue l'idle dans la dernière direction
		return

	personnage.last_dir = personnage._dir8_from_vector(input)             # Met à jour la direction pour les animations
	deplacer(input)                                                       # Applique le déplacement iso via CompDeplacement
	personnage._play_walk(personnage.last_dir)                            # Joue l'animation de marche

# Retourne le vecteur d'input clavier/manette sans l'appliquer
# Utilisé par _physics_process et disponible pour d'autres systèmes (animations, checks)
func get_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")    # Vecteur normalisé automatiquement par Godot
