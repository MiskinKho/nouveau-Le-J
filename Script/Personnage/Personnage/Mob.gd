extends PNJ    # Les animaux sauvages héritent de PNJ (Chat.gd) pour les animations et le déplacement
class_name Mob

@export var zone_deplacement: float = 100.0  # Rayon max de déambulation autour de la position initiale

@onready var sprite_node: Sprite2D = $Sprite2D  # Sprite (non animé — Mob utilise Sprite2D, pas AnimatedSprite2D)

var position_depart: Vector2   # Position initiale mémorisée au _ready() pour le leash
var temps_changement := 0.0   # Timer avant le prochain changement de direction

signal creature_cliquee(creature)  # Émis au clic : déclenche le combat automatique dans Monde.gd

func _ready():


	# Leash : si trop loin de la position initiale, oriente vers elle
	if global_position.distance_to(position_depart) > zone_deplacement:
		direction = (position_depart - global_position).normalized()



func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		creature_cliquee.emit(self)  # Envoie la référence à l'animal pour le combat auto
