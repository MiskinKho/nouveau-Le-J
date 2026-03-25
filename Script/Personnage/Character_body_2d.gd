extends CharacterBody2D
class_name Personnage

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var stats: Creature
@export var speed := 100.0
var last_dir := "S"
var en_combat := false
var en_attaque = false
var menu_ouvert := false
var en_repositionnement := false

func _play_idle(dir: String = "S") -> void:
	var anim_name := "Idle " + dir
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _deplacer(input: Vector2) -> void:
	var iso := Vector2(input.x, input.y * 0.5).normalized()
	velocity = iso * speed
	move_and_slide()

func _play_walk(dir: String) -> void:
	var anim_name := "Walk " + dir
	if sprite.animation != anim_name:
		sprite.play(anim_name)

func _dir8_from_vector(v: Vector2) -> String:
	var ang := v.angle()
	var idx := int(round(ang / (PI / 4.0))) & 7
	var dirs := ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]
	return dirs[idx]

func fin_combat():
	en_combat = false
