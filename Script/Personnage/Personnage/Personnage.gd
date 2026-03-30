extends CharacterBody2D  # Physique 2D avec détection de collisions et move_and_slide()
class_name Personnage    # Classe de base partagée par Joueur et PNJ (Chat)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # Sprite animé enfant, chargé au _ready()

@export var stats: Creature  # Ressource contenant toutes les stats (combat + bien-être)
@export var speed := 100.0   # Vitesse de déplacement en pixels/seconde (configurable dans l'éditeur)

var last_dir := "S"            # Dernière direction regardée (utilisée pour l'animation idle)
var en_combat := false         # Bloque les déplacements et inputs pendant un combat
var en_attaque = false         # Indique qu'une animation d'attaque est en cours
var menu_ouvert := false       # Bloque les actions quand un menu contextuel est affiché
var en_repositionnement := false  # Bloque le joueur pendant le repositionnement avant un combat

# Lance l'animation idle dans la direction donnée.
# Évite de relancer l'animation si elle est déjà la bonne (évite le clignotement).
func _play_idle(dir: String = "S") -> void:
	var anim_name := "Idle " + dir            # Ex: "Idle S", "Idle NE"
	if sprite.animation != anim_name:          # Guard : ne remet pas à zéro si déjà correcte
		sprite.play(anim_name)

# Applique un déplacement isométrique : l'axe Y est compressé à 0.5 pour simuler la perspective.
func _deplacer(input: Vector2) -> void:
	var iso := Vector2(input.x, input.y * 0.5).normalized()  # Normalise après compression
	velocity = iso * speed
	move_and_slide()

# Lance l'animation de marche dans la direction donnée (même guard que _play_idle).
func _play_walk(dir: String) -> void:
	var anim_name := "Walk " + dir
	if sprite.animation != anim_name:
		sprite.play(anim_name)

# Convertit un vecteur de direction en nom de direction sur 8 points cardinaux.
# Utilisé pour choisir la bonne animation (E, SE, S, SO, O, NO, N, NE).
func _dir8_from_vector(v: Vector2) -> String:
	var ang := v.angle()                              # Angle en radians (-π à π)
	var idx := int(round(ang / (PI / 4.0))) & 7       # Quantifie en 8 secteurs, modulo 8 avec masque binaire
	var dirs := ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]  # Ordre correspondant aux angles
	return dirs[idx]

# Réinitialise le flag de combat (appelé depuis CombatManager après la fin d'un combat)
func fin_combat():
	en_combat = false
