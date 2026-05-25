extends CharacterBody2D  # Physique 2D avec détection de collisions et move_and_slide()
class_name Personnage    # Classe de base partagée par Joueur et PNJ (Chat)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  # Sprite animé enfant, chargé au _ready()

@export var stats: Resource  # Personnage_Data_Chat / Mob / Joueur selon la sous-classe (duck typing : combat, etc.)
@export var race_id: String = ""  # Id de race (clé RaceManager), renseigné par scène — permet le multi-races sans dupliquer le script


var last_dir := "S"            # Dernière direction regardée (utilisée pour l'animation idle)
var en_combat := false         # Bloque les déplacements et inputs pendant un combat
var en_attaque = false         # Indique qu'une animation d'attaque est en cours
var menu_ouvert := false       # Bloque les actions quand un menu contextuel est affiché
var en_repositionnement := false  # Bloque le joueur pendant le repositionnement avant un combat

# Connecte les signaux globaux de combat dès le démarrage du personnage.
# Chaque sous-classe (Joueur, PNJ) doit appeler super() dans son _ready() pour bénéficier de cette connexion.
func _ready():
	EventBus.combat_demarre.connect(_on_combat_demarre_global)    # Pose en_combat = true si ce personnage est un des combattants
	EventBus.combat_termine.connect(_on_combat_termine_global)    # Retire en_combat = false à la fin du combat

# Branche l'archétype de race sur les stats de combat depuis race_id. Appelée par chaque sous-classe après création de son stats.
func _appliquer_race() -> void:
	var race = RaceManager.get_race(race_id)  # Récupère l'archétype de race (null si id vide ou inconnu)
	if race == null:  # Garde-fou : race_id non renseigné dans la scène ou faute de frappe
		push_warning("Personnage '%s' : race_id '%s' inconnu, setup ignoré" % [name, race_id])  # Avertit sans crasher
		return  # Sortie anticipée : évite un setup(null) qui planterait
	stats.combat.setup(race)  # Branche la race + remplit les PV au max

# Callback global combat_demarre : pose en_combat = true uniquement si ce personnage participe au combat.
# Comparaison par référence sur stats.combat (chaque Resource est unique par personnage instancié).
func _on_combat_demarre_global(combattant_1, combattant_2, _mode):
	if stats != null and (stats.combat == combattant_1 or stats.combat == combattant_2):
		en_combat = true

# Callback global combat_termine : retire en_combat = false pour tous les personnages (pas de check d'identité nécessaire).
# Les personnages non concernés avaient déjà en_combat = false, le set est idempotent.
func _on_combat_termine_global(_victoire, _mode, _gain_pv_max, _gain_force):
	en_combat = false

# Lance l'animation idle dans la direction donnée.
# Évite de relancer l'animation si elle est déjà la bonne (évite le clignotement).
func _play_idle(dir: String = "S") -> void:
	var anim_name := "Idle " + dir            # Ex: "Idle S", "Idle NE"
	if sprite.animation != anim_name:          # Guard : ne remet pas à zéro si déjà correcte
		sprite.play(anim_name)

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
