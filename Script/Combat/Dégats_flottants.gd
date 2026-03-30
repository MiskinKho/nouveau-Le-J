extends Label

func afficher(valeur: int, position_monde: Vector2):
	text = "-" + str(valeur)
	global_position = position_monde
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)
