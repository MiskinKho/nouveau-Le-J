extends CanvasLayer

@export var joueur: CharacterBody2D
@export var chat_node: CharacterBody2D

@onready var panel = $Panel_Combat
@onready var menu_principal = $Panel_Combat/Menu_Principal
@onready var menu_cible = $Panel_Combat/Menu_Cible
@onready var menu_competence = $Panel_Combat/Menu_Competence

@onready var barre_pv_joueur = $Panel_Combat/Barre_PV_Joueur
@onready var barre_pv_chat = $Panel_Combat/Barre_PV_Chat
@onready var barre_pv_ennemi = $Panel_Combat/Barre_PV_Ennemi
@onready var label_pv_joueur = $Panel_Combat/Label_PV_Joueur
@onready var label_pv_chat = $Panel_Combat/Label_PV_Chat
@onready var label_pv_ennemi = $Panel_Combat/Label_PV_Ennemi
@onready var label_nom_ennemi = $Panel_Combat/Label_Nom_Ennemi
@onready var label_degats = $Panel_Combat/Label_Degats

@onready var btn_attaquer = $Panel_Combat/Menu_Principal/Btn_Attaquer
@onready var btn_competence = $Panel_Combat/Menu_Principal/Btn_Competence
@onready var btn_objet = $Panel_Combat/Menu_Principal/Btn_Objet
@onready var btn_fuir = $Panel_Combat/Menu_Principal/Btn_Fuir
@onready var btn_chat = $Panel_Combat/Menu_Cible/Btn_Chat
@onready var btn_retour = $Panel_Combat/Btn_Retour

@export var scene_degats: PackedScene
@export var monde: Node2D

var ennemi_node: Node

func _ready():
	btn_attaquer.pressed.connect(_on_attaquer)
	btn_competence.pressed.connect(_on_competence)
	btn_objet.pressed.connect(_on_objet)
	btn_fuir.pressed.connect(_on_fuir)
	btn_chat.pressed.connect(_on_cible_chat)
	btn_retour.pressed.connect(_on_retour)
	
	# Connexion aux signaux du CombatManager
	EventBus.combat_demarre.connect(_on_combat_demarre)
	EventBus.attaque_effectuee.connect(_on_attaque_effectuee)
	EventBus.combat_termine.connect(_on_combat_termine)
	EventBus.tour_joueur_commence.connect(_on_tour_joueur_commence)

func afficher(p_stats_chat: Resource):  # Personnage_Data_Chat (duck typing : .combat)
	# Le flag chat_node.en_combat est posé automatiquement par Personnage via le signal EventBus.combat_demarre
	# Passe directement la référence aux stats joueur (et non une copie) pour que les dégâts subis persistent dans le Resource Personnage_Data_Joueur
	CombatManager.lancer_combat(p_stats_chat, joueur.stats.combat, CombatManager.Mode.JOUEUR)

func afficher_auto(p_stats_chat: Resource, p_stats_ennemi: Stats_Combat, p_ennemi_node: Node):  # duck typing
	ennemi_node = p_ennemi_node
	await joueur.repositionner_pour_combat(ennemi_node)  # Délègue le repositionnement physique au Joueur (responsabilité gameplay)
	# Les flags en_combat (joueur, chat_node, ennemi) sont posés automatiquement par Personnage via le signal EventBus.combat_demarre
	CombatManager.lancer_combat(p_stats_chat, p_stats_ennemi, CombatManager.Mode.AUTO)

func _on_combat_demarre(combattant_1, combattant_2, mode):
	panel.visible = true
	if mode == CombatManager.Mode.AUTO:
		btn_attaquer.visible = false
		btn_competence.visible = false
		barre_pv_ennemi.max_value = combattant_2.get_pv_max()
		barre_pv_ennemi.value = combattant_2.pv_actuel
		label_pv_ennemi.text = "%d / %d" % [combattant_2.pv_actuel, combattant_2.get_pv_max()]
		label_nom_ennemi.text = combattant_2.base.nom_race
		# Mode AUTO : la barre joueur reflète l'état hors combat (le joueur ne participe pas)
		barre_pv_joueur.max_value = joueur.stats.combat.get_pv_max()
		barre_pv_joueur.value = joueur.stats.combat.pv_actuel
		label_pv_joueur.text = "%d / %d" % [joueur.stats.combat.pv_actuel, joueur.stats.combat.get_pv_max()]
	else:
		btn_attaquer.visible = true
		btn_competence.visible = true
		# Mode JOUEUR : combattant_2 EST joueur.stats.combat (référence), on lit depuis le Manager pour cohérence avec _on_attaque_effectuee
		barre_pv_joueur.max_value = combattant_2.get_pv_max()
		barre_pv_joueur.value = combattant_2.pv_actuel
		label_pv_joueur.text = "%d / %d" % [combattant_2.pv_actuel, combattant_2.get_pv_max()]
	barre_pv_chat.max_value = combattant_1.get_pv_max()
	barre_pv_chat.value = combattant_1.pv_actuel
	label_pv_chat.text = "%d / %d" % [combattant_1.pv_actuel, combattant_1.get_pv_max()]
	label_degats.text = ""
	_afficher_menu(menu_principal)

func _on_attaque_effectuee(attaquant_nom, cible_nom, degats):
	label_degats.text = "%s inflige %d dégâts à %s !" % [attaquant_nom, degats, cible_nom]
	
	# Met à jour les barres selon qui est attaqué
	var stats_chat = CombatManager.stats_combattant_1
	var stats_ennemi = CombatManager.stats_combattant_2
	barre_pv_chat.value = stats_chat.pv_actuel
	label_pv_chat.text = "%d / %d" % [stats_chat.pv_actuel, stats_chat.get_pv_max()]
	if CombatManager.mode_actuel == CombatManager.Mode.AUTO:
		barre_pv_ennemi.value = stats_ennemi.pv_actuel
		label_pv_ennemi.text = "%d / %d" % [stats_ennemi.pv_actuel, stats_ennemi.get_pv_max()]
	else:
		# Mode JOUEUR : stats_ennemi EST joueur.stats.combat (référence), on lit depuis le Manager pour une seule source de vérité
		barre_pv_joueur.value = stats_ennemi.pv_actuel
		label_pv_joueur.text = "%d / %d" % [stats_ennemi.pv_actuel, stats_ennemi.get_pv_max()]
	
	# Dégâts flottants
	var degats_label = scene_degats.instantiate()
	monde.add_child(degats_label)
	# DETTE NOTEE : identification du combattant par nom de race (fragile si deux combattants partagent la meme race). A remplacer par comparaison de references Stats_Combat en session combat dediee.
	var position_cible = chat_node.global_position if cible_nom == CombatManager.stats_combattant_1.base.nom_race else joueur.global_position
	if ennemi_node and is_instance_valid(ennemi_node) and cible_nom == CombatManager.stats_combattant_2.base.nom_race:
		position_cible = ennemi_node.global_position
	degats_label.afficher(degats, position_cible + Vector2(0, -32))

func _on_combat_termine(victoire: bool, mode: int, _gain_pv_max: int, _gain_force: int):
	if mode == CombatManager.Mode.AUTO:
		if victoire:
			label_degats.text = "Victoire !"
			# Le queue_free de l'ennemi est géré par Monde.gd qui écoute aussi combat_termine
		else:
			label_degats.text = "%s est KO..." % CombatManager.stats_combattant_1.base.nom_race
			CombatManager.stats_combattant_1.pv_actuel = 1
		await get_tree().create_timer(1.5).timeout
		cacher()
	# Mode JOUEUR : la transition de fin + cacher() + émission combat_entrainement_termine sont gérés par Monde.gd (orchestrateur des transitions)

func _on_tour_joueur_commence():
	btn_attaquer.disabled = false
	panel.visible = true
	_afficher_menu(menu_principal)

func cacher():
	panel.visible = false
	btn_attaquer.visible = true
	btn_competence.visible = true
	btn_attaquer.disabled = false
	# Note : les PV du joueur ne sont PAS restaurés à 100% — les dégâts subis persistent (game design : récupération via repos/items/etc. à concevoir)
	# Les flags en_combat sont retirés automatiquement par Personnage via le signal EventBus.combat_termine
	# La sauvegarde est centralisée dans Monde._on_combat_termine (listener du même signal)

func _afficher_menu(menu: Panel):
	menu_principal.visible = false
	menu_cible.visible = false
	menu_competence.visible = false
	menu.visible = true
	btn_retour.visible = menu != menu_principal
	if menu == menu_cible:
		if not chat_node.chat_clique.is_connected(_on_cible_chat):
			chat_node.chat_clique.connect(_on_cible_chat)
	else:
		if chat_node.chat_clique.is_connected(_on_cible_chat):
			chat_node.chat_clique.disconnect(_on_cible_chat)

func _on_attaquer():
	_afficher_menu(menu_cible)

func _on_competence():
	_afficher_menu(menu_competence)

func _on_objet():
	EventBus.inventaire_ouvert.emit()

func _on_fuir():
	cacher()

func _on_retour():
	_afficher_menu(menu_principal)

func _on_cible_chat():
	if not CombatManager.en_combat or not CombatManager.tour_joueur:
		return
	btn_attaquer.disabled = true
	panel.visible = false
	await joueur.jouer_animation_attaque()  # Délègue l'animation au Joueur (responsabilité gameplay)
	CombatManager.attaque_joueur()
