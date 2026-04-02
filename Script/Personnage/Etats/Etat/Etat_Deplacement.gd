extends State  # État de déplacement du joueur : surcharge la direction pour utiliser l'input clavier

# Contrairement à Etat_Marcher (direction IA aléatoire), cet état lit l'input du joueur.
# Utilisé par le Joueur via sa StateMachine (si activée).

func enter() -> void:
	pass  # Pas de durée ni de direction aléatoire : le joueur contrôle directement

func update(_delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")  # Axes WASD/flèches
	if input == Vector2.ZERO:
		personnage.velocity = Vector2.ZERO
		personnage._play_idle(personnage.last_dir)
		personnage.move_and_slide()
		return
	# Projection isométrique + déplacement
	personnage.last_dir = personnage._dir8_from_vector(input)
	personnage._deplacer(input)
	personnage._play_walk(personnage.last_dir)

func exit() -> void:
	personnage.velocity = Vector2.ZERO  # Arrête tout mouvement en quittant l'état
