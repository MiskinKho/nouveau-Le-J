extends Camera2D

@export var target: CharacterBody2D  # Cible à suivre, assignée dans l'éditeur (généralement le Joueur)

# Suit la cible en arrondissant la position pour éviter le sub-pixel rendering (évite le flou).
func _physics_process(_delta):
	global_position = target.global_position.round()  # .round() = aligne sur les pixels entiers

func _ready() -> void:
	pass

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
