extends PNJ    # Les animaux sauvages héritent de PNJ (Chat.gd) pour les animations et le déplacement
class_name Mob

@export var zone_deplacement: float = 100.0  # Rayon max de déambulation autour de la position initiale

var position_depart: Vector2   # Position initiale mémorisée au _ready() pour le leash
var temps_changement := 0.0   # Timer avant le prochain changement de direction

signal creature_cliquee(creature)  # Émis au clic : déclenche le combat automatique dans Monde.gd

func _ready():
	super()  # Appelle PNJ._ready() pour les signaux ZoneClick, survol
	add_to_group("creatures_sauvages")  # Groupe utilisé par Monde.gd pour connecter le signal de clic combat auto
	if stats == null:
		stats = Personnage_Data_Mob.new()  # Instancie la Resource specifique mob
	_appliquer_race()  # Branche la race depuis race_id (renseigné dans la scène) + remplit les PV au max
	
func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		creature_cliquee.emit(self)  # Envoie la référence à l'animal pour le combat auto
