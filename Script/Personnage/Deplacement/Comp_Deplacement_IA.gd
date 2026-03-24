extends CompDeplacement
class_name CompDeplacementIA

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func se_deplacer_vers(cible: Vector2) -> void:
	nav_agent.target_position = cible
	var direction_nav = nav_agent.get_next_path_position() - personnage.global_position
	if direction_nav.length() > 1:
		deplacer(direction_nav)
	else:
		arreter()

func choisir_direction() -> Vector2:
	var directions = [
		Vector2(1, 1), Vector2(-1, 1),
		Vector2(1, -1), Vector2(-1, -1)
	]
	directions.shuffle()
	for dir in directions:
		var iso = Vector2(dir.x, dir.y * 0.5).normalized()
		var raycast = personnage.get_node("Raycast")
		raycast.target_position = iso * 50
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			return dir
	return Vector2.ZERO
