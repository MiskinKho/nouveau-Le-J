extends State
class_name EtatCombat

func enter() -> void:
	get_parent().get_parent().velocity = Vector2.ZERO

func update(_delta: float) -> void:
	get_parent().get_parent().velocity = Vector2.ZERO
	get_parent().get_parent().move_and_slide()

func exit() -> void:
	pass
