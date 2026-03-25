extends PNJ
class_name Mob

@export var zone_deplacement: float = 100.0
 
@onready var sprite_node: Sprite2D = $Sprite2D
 
var position_depart: Vector2

var temps_changement := 0.0
 
signal creature_cliquee(creature)
 
func _ready():
	position_depart = global_position
	add_to_group("creatures_sauvages")
	$Zone_Click.input_event.connect(_on_click)
 
	if stats == null:
		stats = Creature.new()
		stats.combat = Stats_Combat.new()
		stats.combat.nom = "Souris"
		stats.combat.pv_max = 20
		stats.combat.pv_actuel = 20
		stats.combat.force = 5
		stats.combat.defense = 2
		stats.combat.agilite = 8
		stats.combat.precision = 8
 
func _physics_process(delta):
	temps_changement -= delta
	if temps_changement <= 0:
		_choisir_direction()
		temps_changement = randf_range(1.0, 3.0)
 
	var iso := Vector2(direction.x, direction.y * 0.5)
	velocity = iso.normalized() * speed if direction != Vector2.ZERO else Vector2.ZERO
	move_and_slide()
 
	if global_position.distance_to(position_depart) > zone_deplacement:
		direction = (position_depart - global_position).normalized()
 
func _choisir_direction():
	var choix := randi() % 5
	match choix:
		0: direction = Vector2(1, 1)
		1: direction = Vector2(-1, 1)
		2: direction = Vector2(1, -1)
		3: direction = Vector2(-1, -1)
		4: direction = Vector2.ZERO
 
func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		creature_cliquee.emit(self)
