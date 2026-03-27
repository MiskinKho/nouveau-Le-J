extends CanvasLayer  # Couche UI au-dessus de tout : garantit que le fondu couvre l'intégralité de l'écran

@onready var fondu = $Fondu  # ColorRect ou Sprite noir qui couvre tout l'écran

signal transition_terminee  # Émis après le fondu retour : le callback post-transition peut s'exécuter

# Lance une transition en trois phases : fondu au noir → repositionnement → fondu retour.
# Utilisé pour les combats (repositionner joueur et chat face à face) et les scènes de transition.
func lancer_transition(joueur: CharacterBody2D, chat: CharacterBody2D):
	# Phase 1 : fondu au noir en 0.5 seconde
	var tween = create_tween()
	tween.tween_property(fondu, "modulate:a", 1.0, 0.5)  # Alpha 0 → 1
	await tween.finished

	# Phase 2 : repositionnement face à face pendant que l'écran est noir
	var centre = (joueur.global_position + chat.global_position) / 2  # Point médian entre les deux
	joueur.global_position = centre + Vector2(-60, 0)  # Joueur à gauche
	chat.global_position = centre + Vector2(60, 0)     # Chat à droite

	# Phase 3 : fondu retour en 0.5 seconde
	var tween2 = create_tween()
	tween2.tween_property(fondu, "modulate:a", 0.0, 0.5)  # Alpha 1 → 0
	await tween2.finished

	emit_signal("transition_terminee")  # Informe Monde.gd que la transition est terminée
