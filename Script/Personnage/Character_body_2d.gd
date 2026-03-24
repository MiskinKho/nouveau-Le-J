extends CharacterBody2D
class_name Personnage

@onready var pas_bois: AudioStreamPlayer2D = $AudioListener2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var tilemap_sol: TileMapLayer
@export var chat: CharacterBody2D
@export var stats: PlayerStats
@export var speed := 100.0

var last_dir := "S"
var en_combat := false
var en_attaque = false
var menu_ouvert := false
var en_repositionnement := false
var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
var etage := 0:
	set(value):
		etage = value
		if value == 1 and sas:
			EventBus.faux_etage_change.emit(true)
		if value == 0 and sas:
			z_index = 2
			EventBus.faux_etage_change.emit(false)

var sas := false:
	set(value):
		sas = value
		if not sas and etage == 0:
			z_index = 0
		elif sas and etage == 0:
			z_index = 2
		elif not sas and etage == 1:
			z_index = 3
			EventBus.faux_etage_change.emit(false)
			EventBus.etage_change.emit(true)
		elif sas and etage == 1:
			z_index = 2
			EventBus.etage_change.emit(false)
			EventBus.faux_etage_change.emit(true)

func _physics_process(_delta: float) -> void:
	if en_combat or menu_ouvert or en_repositionnement:
		if not en_repositionnement:
			velocity = Vector2.ZERO
			move_and_slide()
			if not sprite.animation.begins_with("ATK"):
				_play_idle(last_dir)
		return


	if sas:
		if input != Vector2.ZERO:
			if input.x > 0:
				last_dir = "NE"
				_play_walk("NE")
			elif input.x < 0:
				last_dir = "SO"
				_play_walk("SO")
			else:
				_play_idle(last_dir)
		else:
			_play_idle(last_dir)
		_deplacer(input)
		return

	if input == Vector2.ZERO:
		velocity = Vector2.ZERO
		_play_idle(last_dir)
		move_and_slide()
		return

	last_dir = _dir8_from_vector(input)
	_deplacer(input)
	_play_walk(last_dir)

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and not en_combat:
		if global_position.distance_to(chat.global_position) < 50:
			EventBus.menu_contexte_ouvert.emit(
				get_viewport().get_canvas_transform() * chat.global_position, chat)

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
	
func _on_animated_sprite_2d_frame_changed():
	if sprite.animation.begins_with("Walk"):
		if sprite.frame == 2 or sprite.frame == 5:
			_play_footstep()

func _play_footstep():
	var tile_pos = tilemap_sol.local_to_map(tilemap_sol.to_local(global_position))
	var _tile_data = tilemap_sol.get_cell_tile_data(tile_pos)
	pas_bois.play()

func fin_combat():
	en_combat = false
