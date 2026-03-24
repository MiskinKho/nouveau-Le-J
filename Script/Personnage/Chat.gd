extends Personnage



@export var gamelle: StaticBody2D
@export var coussin: Mobilier
@export var statss: Creature
@onready var nav_agent = $NavigationAgent2D
@onready var state_machine: StateMachine = $StateMachine

var direction := Vector2.ZERO
var mange := false

var epuise := false
signal chat_clique



func _choisir_direction():
	var directions = [
		Vector2(1, 1), Vector2(-1, 1),
		Vector2(1, -1), Vector2(-1, -1)
	]
	directions.shuffle()
	for dir in directions:
		var iso = Vector2(dir.x, dir.y * 0.5).normalized()
		$Raycast.target_position = iso * 50
		$Raycast.force_raycast_update()
		if not $Raycast.is_colliding():
			direction = dir
			return
	direction = Vector2.ZERO



func _ready():
	add_to_group("chats")
	$ZoneClick.input_event.connect(_on_click)
	$ZoneClick.mouse_exited.connect(_on_survol_entrer)
	$ZoneClick.mouse_entered.connect(_on_survol_sortir)

func _on_survol_entrer():
	modulate = Color(1.5, 1.5, 1.5)

func _on_survol_sortir():
	modulate = Color(1, 0, 0)

func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if en_combat:
			chat_clique.emit()
		else:
			EventBus.menu_contexte_ouvert.emit(get_viewport().get_mouse_position(), self)

func _se_deplacer_vers(cible_position: Vector2):
	nav_agent.target_position = cible_position
	var direction_nav = nav_agent.get_next_path_position() - global_position
	if direction_nav.length() > 1:
		var iso = Vector2(direction_nav.x, direction_nav.y * 0.5).normalized()
		velocity = iso * speed
		move_and_slide()
		_play_walk(_dir8_from_vector(direction_nav))
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		_play_idle()
