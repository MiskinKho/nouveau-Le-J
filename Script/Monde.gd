extends Node2D

func _ready():
	
		# Écoute les signaux EventBus
	EventBus.entrainement_demande.connect(_on_entrainement_demande)
	EventBus.caresse_demandee.connect(_on_caresse_demandee)
	EventBus.energie_insuffisante.connect(_on_energie_insuffisante)
	EventBus.sauvegarde_demandee.connect(func(): SaveManager.sauvegarder($Chat.stats))
	EventBus.menu_pause_ouvert.connect(func(): $Cl_Pause.ouvrir())
	EventBus.menu_gamelle_ouvert.connect(func(gamelle): $UI_Gamelle.ouvrir(gamelle))
	EventBus.menu_contexte_ouvert.connect(func(pos, cible): $Ui_Contexte.ouvrir(pos, cible))
	EventBus.hud_chat_visible.connect(_on_hud_chat_visible)
	EventBus.etage_change.connect(func(e, v): $"Etage 1".modulate.a = 1.0 if v else 0.0)
	EventBus.faux_etage_change.connect(func(v): $FauxEtage.modulate.a = 1.0 if v else 0.0)
	EventBus.sauvegarde_demandee.connect(func(): SaveManager.sauvegarder(CreatureManager.chat_node.stats))
	EventBus.etage_change.connect(func(v): $"Etage 1".modulate.a = 1.0 if v else 0.0)
	EventBus.faux_etage_change.connect(func(v): $FauxEtage.modulate.a = 1.0 if v else 0.0)
	EventBus.transition_demandee.connect(func(depuis, vers, callback):
		$Cl_Transition.transition_terminee.connect(callback, CONNECT_ONE_SHOT)
		$Cl_Transition.lancer_transition(depuis, vers)
)
	
	
	var creature_sauvegardee = SaveManager.charger()
	if creature_sauvegardee != null:
		$Chat.stats = creature_sauvegardee
	else:
		TimeManager.heure = 8.0
		TimeManager.jour = 1
	
	DayNightManager.initialiser($CycleJourNuit, $Joueur/PointLight2D)
	CreatureManager.initialiser($Chat)
	

	
	for creature in get_tree().get_nodes_in_group("creatures_sauvages"):
		creature.creature_cliquee.connect(_on_creature_cliquee)
	
	var croquettes = load("res://Asset/Item/Croquette.tres")
	InventoryManager.ajouter_item(croquettes, 5)
	
func _on_entrainement_demande(cible):
	var transition = $Cl_Transition
	transition.transition_terminee.connect(func():
		$Ui_Combat.afficher(cible.stats)
		$Joueur.en_combat = true
	, CONNECT_ONE_SHOT)
	transition.lancer_transition($Joueur, cible)

func _on_caresse_demandee(cible):
	var joueur = $Joueur
	if joueur.global_position.distance_to(cible.global_position) > 60:
		EventBus.trop_loin.emit(cible)
		return
	joueur.menu_ouvert = true
	cible.menu_ouvert = true
	await get_tree().create_timer(1.0).timeout
	cible.stats.bien_etre.confiance = min(100.0, cible.stats.bien_etre.confiance + 5.0)
	joueur.menu_ouvert = false
	cible.menu_ouvert = false
	SaveManager.sauvegarder(cible.stats)

func _on_energie_insuffisante(_cible):
	print("Le chat est trop fatigué pour s'entraîner !")

func _process(_delta):
	if $Joueur.etage == 0 and $Joueur.sas == false:
		$"Etage 1".modulate.a = 0.0
		$"FauxEtage".modulate.a = 0.0

func _on_creature_cliquee(creature):
	$Ui_Combat.chat_node = $Chat
	$Ui_Combat.afficher_auto($Chat.stats, creature.stats, creature)
	
	
func _on_hud_chat_visible(visible: bool, cible):
	var hud = $UI_HUD
	if cible:
		hud.chat = cible
	hud.get_node("Panel_Chat").visible = visible
