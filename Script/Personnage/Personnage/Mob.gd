extends PNJ    # Les animaux sauvages héritent de PNJ (Chat.gd) pour les animations et le déplacement
class_name Mob

@export var zone_deplacement: float = 100.0  # Rayon max de déambulation autour de la position initiale

@onready var sprite_node: Sprite2D = $Sprite2D  # Sprite (non animé — Mob utilise Sprite2D, pas AnimatedSprite2D)

var position_depart: Vector2   # Position initiale mémorisée au _ready() pour le leash
var temps_changement := 0.0   # Timer avant le prochain changement de direction

signal creature_cliquee(creature)  # Émis au clic : déclenche le combat automatique dans Monde.gd

func _ready():
	position_depart = global_position
	add_to_group("creatures_sauvages")  # Groupe pour connexion des signaux dans Monde.gd
	$Zone_Click.input_event.connect(_on_click)

func _physics_process(delta):
	temps_changement -= delta
	if temps_changement <= 0:
		_choisir_direction()                      # Change de direction quand le timer expire
		temps_changement = randf_range(1.0, 3.0)  # Recharge le timer aléatoirement



	# Leash : si trop loin de la position initiale, oriente vers elle
	if global_position.distance_to(position_depart) > zone_deplacement:
		direction = (position_depart - global_position).normalized()

# Choisit une direction aléatoire parmi 4 diagonales + immobile (20% de chance d'arrêt).
func _choisir_direction():
	var choix := randi() % 5
	match choix:
		0: direction = Vector2(1, 1)
		1: direction = Vector2(-1, 1)
		2: direction = Vector2(1, -1)
		3: direction = Vector2(-1, -1)
		4: direction = Vector2.ZERO    # S'immobilise brièvement (1 chance sur 5)

func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		creature_cliquee.emit(self)  # Envoie la référence à l'animal pour le combat auto
