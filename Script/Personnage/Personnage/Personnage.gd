extends CharacterBody2D  # Physique 2D avec détection de collisions et move_and_slide()
class_name Personnage    # Classe de base partagée par Joueur et PNJ (Chat)

@onready var comp_anim: CompAnimation = $Comp_Animation  # Composant d'animation — pilote l'AnimationTree, expose jouer_idle/walk/atk et mémorise last_dir
@onready var comp_deplacement: CompDeplacement = _trouver_comp_deplacement()  # Composant de déplacement 
@export var stats: Resource  # Personnage_Data_Chat / Mob / Joueur selon la sous-classe (duck typing : combat, etc.)
@export var race_id: String = ""  # Id de race (clé RaceManager), renseigné par scène — permet le multi-races sans dupliquer le script


var en_combat := false         # Bloque les déplacements et inputs pendant un combat
var en_attaque = false         # Indique qu'une animation d'attaque est en cours
var menu_ouvert := false       # Bloque les actions quand un menu contextuel est affiché
var en_repositionnement := false  # Bloque le joueur pendant le repositionnement avant un combat
var bloque: bool:
	get:
		return en_combat or en_attaque or menu_ouvert


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

# Récupère le composant de déplacement parmi les enfants directs, quel que soit son nom de nœud.
func _trouver_comp_deplacement() -> CompDeplacement:
	for enfant in get_children():           # Parcourt les enfants directs du personnage
		if enfant is CompDeplacement:       # Test de type : couvre les deux sous-classes par héritage
			return enfant                   # Premier composant trouvé, un personnage n'en a qu'un
	return null                             # Aucun composant : personnage statique, l'appelant doit vérifier

# Callback global combat_demarre : pose en_combat = true uniquement si ce personnage participe au combat.
# Comparaison par référence sur stats.combat (chaque Resource est unique par personnage instancié).
func _on_combat_demarre_global(combattant_1, combattant_2, _mode):
	if stats != null and (stats.combat == combattant_1 or stats.combat == combattant_2):
		en_combat = true

# Callback global combat_termine : retire en_combat = false pour tous les personnages (pas de check d'identité nécessaire).
# Les personnages non concernés avaient déjà en_combat = false, le set est idempotent.
func _on_combat_termine_global(_victoire, _mode, _gain_pv_max, _gain_force):
	en_combat = false
