extends Personnage


@onready var pas_bois: AudioStreamPlayer2D = $AudioListener2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var tilemap_sol: TileMapLayer
@export var chat: CharacterBody2D
