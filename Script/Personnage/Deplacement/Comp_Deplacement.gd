extends Node
class_name CompDeplacement

@export var speed := 100.0
var personnage: CharacterBody2D

func _ready() -> void:
	personnage = get_parent()

func deplacer(direction: Vector2) -> void:
	var iso := Vector2(direction.x, direction.y * 0.5).normalized()
	personnage.velocity = iso * speed
	personnage.move_and_slide()

func arreter() -> void:
	personnage.velocity = Vector2.ZERO
	personnage.move_and_slide()

func dir8_from_vector(v: Vector2) -> String:
	var ang := v.angle()
	var idx := int(round(ang / (PI / 4.0))) & 7
	var dirs := ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]
	return dirs[idx]
