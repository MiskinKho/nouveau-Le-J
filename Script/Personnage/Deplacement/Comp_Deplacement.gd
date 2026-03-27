extends Node
class_name CompDeplacement  # Composant réutilisable de déplacement, attaché comme enfant d'un CharacterBody2D

@export var speed := 100.0   # Vitesse configurable dans l'éditeur
var personnage: CharacterBody2D  # Référence au parent CharacterBody2D, assignée au _ready()

func _ready() -> void:
	personnage = get_parent()  # Récupère le CharacterBody2D parent au démarrage

# Applique un déplacement isométrique dans la direction donnée.
# La projection Y * 0.5 simule la perspective isométrique (sol en angle 30°).
func deplacer(direction: Vector2) -> void:
	var iso := Vector2(direction.x, direction.y * 0.5).normalized()  # Compression iso
	personnage.velocity = iso * speed
	personnage.move_and_slide()

# Arrête complètement le personnage (velocity = 0 + move_and_slide pour effacer le momentum)
func arreter() -> void:
	personnage.velocity = Vector2.ZERO
	personnage.move_and_slide()

# ⚠️ DOUBLON : cette méthode existe déjà dans Character_body_2d.gd (_dir8_from_vector).
# À supprimer ici et utiliser personnage._dir8_from_vector() si nécessaire depuis ce composant.
# func dir8_from_vector(v: Vector2) -> String: ...  (supprimée)
