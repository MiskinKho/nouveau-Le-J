extends Node  # Nœud de scène : gère la mise en scène du combat au niveau des nœuds (CombatManager gère les règles sur les Resources)
class_name ClCombat

@export var ecart_combattants: float = 60.0  # Demi-distance entre les deux combattants une fois placés, réglable dans l'éditeur
@export var joueur: Personnage  # Référence au joueur, câblée dans l'inspecteur
@export var chat: Personnage    # Référence au chat du joueur, câblée dans l'inspecteur
@export var ui_combat: CanvasLayer  # Référence à l'UI de combat, câblée dans l'inspecteur
@export var transition: CanvasLayer  # Référence à Cl_Transition, câblée dans l'inspecteur


var _ennemi_combat_actuel: Node = null  # Créature sauvage du combat AUTO en cours, mémorisée pour le cleanup post-victoire
# Calcule les positions de combat des deux combattants et délègue le déplacement à chacun.
# Ne déplace personne directement : décide les destinations, chaque personnage exécute via son composant.
func calcul_position_combat(combattant_a: Personnage, combattant_b: Personnage) -> void:
	var centre = (combattant_a.global_position + combattant_b.global_position) / 2  # Point médian entre les deux positions actuelles
	var pos_a = centre + Vector2(-ecart_combattants, 0)       # Destination du premier combattant, à gauche du centre
	var pos_b = centre + Vector2(ecart_combattants, 0)        # Destination du second combattant, à droite du centre
	combattant_a.comp_deplacement.positionner(pos_a, pos_b)   # A se positionne et regarde vers la position de B
	combattant_b.comp_deplacement.positionner(pos_b, pos_a)   # B se positionne et regarde vers la position de A

# Lance un combat automatique contre une créature sauvage cliquée.
func _on_creature_cliquee(creature):
	_ennemi_combat_actuel = creature  # Mémorise la ref pour la cleanup post-combat (queue_free dans _on_combat_termine)
	await joueur.repositionner_pour_combat(creature)  # Repositionnement avant combat, délégué au joueur
	CombatManager.lancer_combat(chat.stats, creature.stats.combat, CombatManager.Mode.AUTO)  # Démarre le combat, l'UI réagit au signal combat_demarre

func _ready():
	# Connecte le signal de clic de chaque créature sauvage présente dans la scène
	for creature in get_tree().get_nodes_in_group("creatures_sauvages"):  # Parcourt les créatures sauvages du groupe
		creature.creature_cliquee.connect(_on_creature_cliquee)           # Branche le déclenchement du combat AUTO
	EventBus.combat_termine.connect(_on_combat_termine)  # Cleanup ennemi et fin de combat
	EventBus.entrainement_demande.connect(_on_entrainement_demande)  # Déclenche la transition et le combat d'entraînement



# Cleanup de fin de combat : libère la créature sauvage vaincue, gère la transition de fin en mode JOUEUR.
# Listener du signal EventBus.combat_termine émis par CombatManager.
func _on_combat_termine(victoire: bool, mode: int, gain_pv_max: int, gain_force: int):
	if mode == CombatManager.Mode.AUTO and victoire and _ennemi_combat_actuel:
		_ennemi_combat_actuel.queue_free()                     # Supprime la créature sauvage vaincue
	_ennemi_combat_actuel = null                               # Reset dans tous les cas (défaite, mode JOUEUR)
	if mode == CombatManager.Mode.JOUEUR:
		# Transition de fin : ferme l'UI pendant le noir, puis déclenche l'écran de résultats
		ui_combat.cacher()                                     # Ferme l'UI de combat
		EventBus.combat_entrainement_termine.emit(CombatManager.creature_complete, gain_pv_max, gain_force)  # Déclenche Ui_Resultats
	EventBus.sauvegarde_demandee.emit()                        # Sauvegarde centralisée : Monde écoute ce signal


# Lance un entraînement : fondu au noir, placement des combattants, puis démarrage du combat.
# Listener du signal EventBus.entrainement_demande émis par CreatureManager.
func _on_entrainement_demande(cible):
	transition.transition_terminee.connect(func():
		CombatManager.lancer_combat(cible.stats, joueur.stats.combat, CombatManager.Mode.JOUEUR)  # Démarre le combat après le fondu retour, l'UI réagit au signal combat_demarre
	, CONNECT_ONE_SHOT)                                                    # Se déconnecte automatiquement après usage
	transition.lancer_transition(func(): calcul_position_combat(joueur, cible))  # Placement des combattants pendant le noir
