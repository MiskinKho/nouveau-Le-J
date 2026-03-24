extends CompDeplacement
class_name CompDeplacementJoueur

func traiter_deplacement() -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input == Vector2.ZERO:
		arreter()
	else:
		deplacer(input)

func get_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
