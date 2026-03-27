extends State
class_name EtatCombat  # Classe nommée pour pouvoir être référencée par type dans d'autres scripts

func enter() -> void:
	# Arrête tout mouvement au début du combat (évite les glissades en entrant dans l'état)
	personnage.velocity = Vector2.ZERO  # Utilise personnage hérité de State

func update(_delta: float) -> void:
	personnage.velocity = Vector2.ZERO
	personnage.move_and_slide()         # Utilise move_and_slide() via Personnage


func exit() -> void:
	pass
