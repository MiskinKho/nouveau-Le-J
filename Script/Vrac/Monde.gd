extends Node2D  # Noeud racine de la scène principale : orchestre toutes les connexions de signaux

var _ennemi_combat_actuel: Node = null  # Référence à la créature sauvage du combat AUTO en cours (pour cleanup post-victoire)

func _ready():
	# Initialise les couches d'étage à invisibles
	$"Etage 1".modulate.a = 0.0
	$FauxEtage.modulate.a = 0.0

	# Connexions des signaux EventBus → handlers locaux ou lambdas
	EventBus.entrainement_demande.connect(_on_entrainement_demande)
	EventBus.caresse_demandee.connect(_on_caresse_demandee)
	EventBus.energie_insuffisante.connect(_on_energie_insuffisante)
	EventBus.combat_termine.connect(_on_combat_termine)  # Cleanup ennemi sauvage après victoire en mode AUTO
	EventBus.sauvegarde_demandee.connect(func(): SaveManager.sauvegarder(CreatureManager.chat_node.stats))
	EventBus.menu_pause_ouvert.connect(func(): $Cl_Pause.ouvrir())
	EventBus.menu_gamelle_ouvert.connect(func(gamelle): $UI_Gamelle.ouvrir(gamelle))
	EventBus.menu_contexte_ouvert.connect(func(pos, cible): $Ui_Contexte.ouvrir(pos, cible))
	# Lambdas pour les changements de visibilité d'étage
	EventBus.etage_change.connect(func(e, v): $"Etage 1".modulate.a = 1.0 if v else 0.0)
	EventBus.faux_etage_change.connect(func(v): $FauxEtage.modulate.a = 1.0 if v else 0.0)
	# Connexion de la transition : connecte le callback one-shot puis lance le fondu
	EventBus.transition_demandee.connect(func(depuis, vers, callback):
		$Cl_Transition.transition_terminee.connect(callback, CONNECT_ONE_SHOT)  # Se déconnecte automatiquement après usage
		$Cl_Transition.lancer_transition(func(): $Cl_Combat.calcul_position_combat(depuis, vers))  # Positions calculées et appliquées pendant le noir
	)

	# Charge la sauvegarde si elle existe, sinon démarre un nouveau jeu
	var creature_sauvegardee = SaveManager.charger()
	if creature_sauvegardee != null:
		$Chat.stats = creature_sauvegardee  # Applique les stats sauvegardées au noeud Chat
	else:
		TimeManager.heure = 8.0  # Nouveau jeu : démarre à 8h du matin
		TimeManager.jour = 1

	DayNightManager.initialiser($CycleJourNuit, $Joueur/PointLight2D)
	CreatureManager.initialiser($Chat)

	# Connecte le signal de clic de chaque créature sauvage présente dans la scène
	for creature in get_tree().get_nodes_in_group("creatures_sauvages"):
		creature.creature_cliquee.connect(_on_creature_cliquee)

	# Ajoute 5 croquettes à l'inventaire au démarrage (items de test/démo)
	var croquettes = load("res://Asset/Item/Croquette.tres")
	InventoryManager.ajouter_item(croquettes, 5)

func _get_joueur() -> Joueur:
	return $Joueur as Joueur  # Helper non utilisé actuellement (prévu pour accès typé au joueur)

# Lance la transition vers le combat d'entraînement.
# Connecte la callback one-shot AVANT de lancer la transition pour éviter une race condition.
func _on_entrainement_demande(cible):
	var transition = $Cl_Transition
	transition.transition_terminee.connect(func():
		$Ui_Combat.afficher(cible.stats)
		# Le flag $Joueur.en_combat est posé automatiquement par Personnage via le signal EventBus.combat_demarre
	, CONNECT_ONE_SHOT)
	transition.lancer_transition(func(): $Cl_Combat.calcul_position_combat($Joueur, cible))  # Positions calculées pendant le noir, affichage UI après via transition_terminee

# Exécute la caresse : vérifie la distance, bloque les inputs, attend 1s, applique le bonus de confiance.
func _on_caresse_demandee(cible):
	var joueur = $Joueur
	if joueur.global_position.distance_to(cible.global_position) > 60:
		EventBus.trop_loin.emit(cible)  # Trop loin : signal pour feedback UI
		return
	joueur.menu_ouvert = true   # Bloque les inputs pendant la caresse
	cible.menu_ouvert = true
	await get_tree().create_timer(1.0).timeout  # Animation/délai de 1 seconde
	cible.stats.bien_etre.confiance = min(100.0, cible.stats.bien_etre.confiance + 5.0)
	joueur.menu_ouvert = false
	cible.menu_ouvert = false
	SaveManager.sauvegarder(cible.stats)  # Sauvegarde après chaque caresse

func _on_energie_insuffisante(_cible):
	print("Le chat est trop fatigué pour s'entraîner !")  # À remplacer par un feedback UI

# Lance un combat automatique contre une créature sauvage cliquée.
func _on_creature_cliquee(creature):
	_ennemi_combat_actuel = creature  # Mémorise la ref pour la cleanup post-combat (queue_free dans _on_combat_termine)
	$Ui_Combat.chat_node = $Chat
	$Ui_Combat.afficher_auto($Chat.stats, creature.stats.combat, creature)

# Cleanup de fin de combat : libère la créature sauvage si victoire en mode AUTO, gère la transition de fin en mode JOUEUR, sauvegarde l'état.
# Listener du signal EventBus.combat_termine émis par CombatManager.
func _on_combat_termine(_victoire: bool, mode: int, gain_pv_max: int, gain_force: int):
	if mode == CombatManager.Mode.AUTO and _victoire and _ennemi_combat_actuel:
		_ennemi_combat_actuel.queue_free()                     # Supprime la créature sauvage vaincue
	_ennemi_combat_actuel = null                               # Reset dans tous les cas (défaite, mode JOUEUR)
	if mode == CombatManager.Mode.JOUEUR:
		# Lance la transition de fin de combat puis ferme l'UI et déclenche l'écran de résultats
		EventBus.transition_demandee.emit($Joueur, $Chat, func():
			$Ui_Combat.cacher()                                # Ferme l'UI de combat après la transition
			EventBus.combat_entrainement_termine.emit(CombatManager.creature_complete, gain_pv_max, gain_force)  # Déclenche Ui_Resultats
		)
	SaveManager.sauvegarder(CombatManager.creature_complete)   # Sauvegarde l'état du chat post-combat (centralisé ici, plus dans Ui_Combat)
