extends Node
class_name CompDeplacement  # Composant réutilisable de déplacement, attaché comme enfant d'un CharacterBody2D

@export var speed := 100.0   # Vitesse de déplacement en pixels/seconde, configurable dans l'éditeur
var personnage: CharacterBody2D  # Référence au parent CharacterBody2D, assignée au _ready()

func _ready() -> void:
	personnage = get_parent()  # Récupère le CharacterBody2D parent au démarrage


# Applique un déplacement isométrique dans la direction donnée.
# La projection Y * 0.5 simule la perspective isométrique (sol en angle 30°).
func deplacer(direction: Vector2) -> void:
	var iso := Vector2(direction.x, direction.y * 0.5).normalized()  # Compression iso + normalisation
	personnage.velocity = iso * speed                                 # Applique la vitesse au personnage
	personnage.move_and_slide()                                       # Déplace avec gestion des collisions

# Arrête complètement le personnage (velocity = 0 + move_and_slide pour effacer le momentum)
func arreter() -> void:
	personnage.velocity = Vector2.ZERO  # Annule toute vélocité
	personnage.move_and_slide()          # Applique l'arrêt via le moteur physique

# Positionne le personnage à un endroit donné et l'oriente vers un point de regard.
func positionner(destination: Vector2, regard_vers: Vector2) -> void:
	personnage.global_position = destination                             # Applique la position cible
	var direction = (regard_vers - destination).normalized()             # Vecteur du personnage vers le point à regarder
	var dir = personnage.comp_anim.vector_to_dir(direction)              # Conversion vecteur → direction 8 points
	personnage.comp_anim.jouer_idle(dir)                                 # Idle orienté face au point de regard
