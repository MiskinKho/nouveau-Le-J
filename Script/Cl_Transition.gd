extends CanvasLayer

@onready var fondu = $Fondu

signal transition_terminee

func lancer_transition(joueur: CharacterBody2D, chat: CharacterBody2D):
	# Étape 1 : fondu au noir
	var tween = create_tween()
	tween.tween_property(fondu, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# Étape 2 : repositionnement face à face
	var centre = (joueur.global_position + chat.global_position) / 2
	joueur.global_position = centre + Vector2(-60, 0)
	chat.global_position = centre + Vector2(60, 0)
	
	# Étape 3 : fondu retour
	var tween2 = create_tween()
	tween2.tween_property(fondu, "modulate:a", 0.0, 0.5)
	await tween2.finished
	
	emit_signal("transition_terminee")
