extends Node2D  # Noeud racine de la scène principale : orchestre toutes les connexions de signaux


func _ready():
	# Initialise les couches d'étage à invisibles
	$"Etage 1".modulate.a = 0.0
	$FauxEtage.modulate.a = 0.0

	# Connexions des signaux EventBus → handlers locaux ou lambdas
	EventBus.caresse_demandee.connect(_on_caresse_demandee)
	EventBus.energie_insuffisante.connect(_on_energie_insuffisante)
	EventBus.sauvegarde_demandee.connect(func(): SaveManager.sauvegarder(CreatureManager.chat_node.stats))
	EventBus.menu_pause_ouvert.connect(func(): $Cl_Pause.ouvrir())
	EventBus.menu_gamelle_ouvert.connect(func(gamelle): $UI_Gamelle.ouvrir(gamelle))
	EventBus.menu_contexte_ouvert.connect(func(pos, cible): $Ui_Contexte.ouvrir(pos, cible))
	# Lambdas pour les changements de visibilité d'étage
	EventBus.etage_change.connect(func(e, v): $"Etage 1".modulate.a = 1.0 if v else 0.0)
	EventBus.faux_etage_change.connect(func(v): $FauxEtage.modulate.a = 1.0 if v else 0.0)
	# Connexion de la transition : connecte le callback one-shot puis lance le fondu
	

	# Charge la sauvegarde si elle existe, sinon démarre un nouveau jeu
	var creature_sauvegardee = SaveManager.charger()
	if creature_sauvegardee != null:
		$Chat.stats = creature_sauvegardee  # Applique les stats sauvegardées au noeud Chat
	else:
		TimeManager.heure = 8.0  # Nouveau jeu : démarre à 8h du matin
		TimeManager.jour = 1
	DayNightManager.initialiser($CycleJourNuit, $Joueur/PointLight2D)
	CreatureManager.initialiser($Chat)

	# Ajoute 5 croquettes à l'inventaire au démarrage (items de test/démo)
	var croquettes = load("res://Asset/Item/Croquette.tres")
	InventoryManager.ajouter_item(croquettes, 5)

func _get_joueur() -> Joueur:
	return $Joueur as Joueur  # Helper non utilisé actuellement (prévu pour accès typé au joueur)


# Exécute la caresse : vérifie la distance, bloque les inputs, attend 1s, applique le bonus de confiance.
func _on_caresse_demandee(cible):
	var joueur = $Joueur
	if joueur.global_position.distance_to(cible.global_position) > 60:
		EventBus.trop_loin.emit(cible)  # Trop loin : signal pour feedback UI
		return
	joueur.menu_ouvert = true   # Bloque les inputs pendant la caresse
	cible.menu_ouvert = true
	await get_tree().create_timer(1.0).timeout  # Animation/délai de 1 seconde
	cible.stats.bien_etre.recevoir_caresse()  # La Resource applique le gain et gère le plafond
	joueur.menu_ouvert = false
	cible.menu_ouvert = false
	EventBus.sauvegarde_demandee.emit()  # Sauvegarde centralisée : Monde écoute ce signal
func _on_energie_insuffisante(_cible):
	print("Le chat est trop fatigué pour s'entraîner !")  # À remplacer par un feedback UI
