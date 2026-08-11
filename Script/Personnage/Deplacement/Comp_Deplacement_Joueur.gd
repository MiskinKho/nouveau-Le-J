extends CompDeplacement           # Hérite de CompDeplacement : accès à speed, personnage, deplacer(), arreter()
class_name CompDeplacementJoueur  # Composant de déplacement spécifique au joueur (input clavier/manette)

# _physics_process() gère tout le cycle de déplacement du joueur chaque frame physique
func _physics_process(_delta: float) -> void:
	var input := get_direction()                                          # Lit l'input clavier/manette

	# Guard : bloque tout mouvement en combat, menu ou repositionnement
	if personnage.bloque:
		if not personnage.en_repositionnement:                            # Le repositionnement gère son propre mouvement
			personnage.velocity = Vector2.ZERO                            # Arrête le personnage
			personnage.move_and_slide()                                   # Applique la physique
			if not personnage.en_attaque:                                 # Ne coupe pas une animation d'attaque en cours
				personnage.comp_anim.jouer_idle()                         # Joue l'idle dans la dernière direction (last_dir interne)
		return                                                            # Bloqué → on sort

	# Mode escalier (sas) : restreint aux directions NE/SO uniquement
	var joueur := personnage as Joueur
	if joueur.sas:
		if input != Vector2.ZERO:
			if input.x > 0:                                               # Input vers la droite → monte (NE)
				personnage.comp_anim.jouer_walk(Vector2(1, -1))           # Anim Walk NE (last_dir mis à jour automatiquement)
			elif input.x < 0:                                             # Input vers la gauche → descend (SO)
				personnage.comp_anim.jouer_walk(Vector2(-1, 1))           # Anim Walk SO (last_dir mis à jour automatiquement)
			else:
				personnage.comp_anim.jouer_idle()                         # Input vertical pur → idle dans last_dir
		else:
			personnage.comp_anim.jouer_idle()                             # Pas d'input → idle dans last_dir
		deplacer(input)                                                   # Applique le déplacement iso via CompDeplacement
		return                                                            # Sas géré → on sort

	# Déplacement normal au sol
	if input == Vector2.ZERO:                                             # Pas d'input → arrêt
		arreter()                                                         # Stoppe via CompDeplacement (velocity = 0 + move_and_slide)
		personnage.comp_anim.jouer_idle()                                 # Joue l'idle dans la dernière direction (last_dir interne)
		return

	deplacer(input)                                                       # Applique le déplacement iso via CompDeplacement
	personnage.comp_anim.jouer_walk(input)                                # Anim Walk dans la direction de l'input (last_dir mis à jour automatiquement)

# Retourne le vecteur d'input clavier/manette sans l'appliquer
# Utilisé par _physics_process et disponible pour d'autres systèmes (animations, checks)
func get_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")    # Vecteur normalisé automatiquement par Godot
