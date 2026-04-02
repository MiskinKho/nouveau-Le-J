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
var mode_auto := false

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

func afficher(p_stats_chat: Creature):
	chat_node.en_combat = true  # Assurez-vous que cette ligne est présente
	CombatManager.lancer_combat(p_stats_chat, _creer_stats_joueur(), CombatManager.Mode.JOUEUR)

func afficher_auto(p_stats_chat: Creature, p_stats_ennemi: Stats_Combat, p_ennemi_node: Node):
	ennemi_node = p_ennemi_node
	chat_node.en_combat = true
	await _repositionner_joueur()
	joueur.en_combat = true
	CombatManager.lancer_combat(p_stats_chat, p_stats_ennemi, CombatManager.Mode.AUTO)

func _creer_stats_joueur() -> Stats_Combat:
	var stats = Stats_Combat.new()
	stats.nom = "Joueur"
	stats.force = joueur.stats.combat.force
	stats.defense = joueur.stats.combat.defense
	stats.pv_max = joueur.stats.combat.pv_max
	stats.pv_actuel = joueur.stats.combat.pv_actuel
	return stats

func _on_combat_demarre(combattant_1, combattant_2, mode):
	panel.visible = true
	if mode == CombatManager.Mode.AUTO:
		btn_attaquer.visible = false
		btn_competence.visible = false
		barre_pv_ennemi.max_value = combattant_2.pv_max
		barre_pv_ennemi.value = combattant_2.pv_actuel
		label_pv_ennemi.text = "%d / %d" % [combattant_2.pv_actuel, combattant_2.pv_max]
		label_nom_ennemi.text = combattant_2.nom
	else:
		btn_attaquer.visible = true
		btn_competence.visible = true
	barre_pv_chat.max_value = combattant_1.pv_max
	barre_pv_chat.value = combattant_1.pv_actuel
	barre_pv_joueur.max_value = joueur.stats.combat.pv_max
	barre_pv_joueur.value = joueur.stats.combat.pv_actuel
	label_pv_chat.text = "%d / %d" % [combattant_1.pv_actuel, combattant_1.pv_max]
	label_pv_joueur.text = "%d / %d" % [joueur.stats.combat.pv_actuel, joueur.stats.combat.pv_max]
	label_degats.text = ""
	_afficher_menu(menu_principal)

func _on_attaque_effectuee(attaquant_nom, cible_nom, degats):
	label_degats.text = "%s inflige %d dégâts à %s !" % [attaquant_nom, degats, cible_nom]
	
	# Met à jour les barres selon qui est attaqué
	var stats_chat = CombatManager.stats_combattant_1
	var stats_ennemi = CombatManager.stats_combattant_2
	barre_pv_chat.value = stats_chat.pv_actuel
	label_pv_chat.text = "%d / %d" % [stats_chat.pv_actuel, stats_chat.pv_max]
	if CombatManager.mode_actuel == CombatManager.Mode.AUTO:
		barre_pv_ennemi.value = stats_ennemi.pv_actuel
		label_pv_ennemi.text = "%d / %d" % [stats_ennemi.pv_actuel, stats_ennemi.pv_max]
	else:
		barre_pv_joueur.value = joueur.stats.combat.pv_actuel
		label_pv_joueur.text = "%d / %d" % [joueur.stats.combat.pv_actuel, joueur.stats.combat.pv_max]
	
	# Dégâts flottants
	var degats_label = scene_degats.instantiate()
	monde.add_child(degats_label)
	var position_cible = chat_node.global_position if cible_nom == CombatManager.stats_combattant_1.nom else joueur.global_position
	if ennemi_node and is_instance_valid(ennemi_node) and cible_nom == CombatManager.stats_combattant_2.nom:
		position_cible = ennemi_node.global_position
	degats_label.afficher(degats, position_cible + Vector2(0, -32))

func _on_combat_termine(victoire: bool):
	if CombatManager.mode_actuel == CombatManager.Mode.AUTO:
		if victoire:
			label_degats.text = "Victoire !"
			if ennemi_node:
				ennemi_node.queue_free()
		else:
			label_degats.text = "%s est KO..." % CombatManager.stats_combattant_1.nom
			CombatManager.stats_combattant_1.pv_actuel = 1
		await get_tree().create_timer(1.5).timeout
		cacher()
	else:
		var gain_pv_max = max(1, CombatManager.stats_combattant_2.force / 5)
		var gain_force = max(1, CombatManager.stats_combattant_1.force / 5)
		EventBus.transition_demandee.emit(joueur, chat_node, func():
			cacher()
			EventBus.combat_entrainement_termine.emit(CombatManager.creature_complete, gain_pv_max, gain_force)
		)

func _on_tour_joueur_commence():
	btn_attaquer.disabled = false
	panel.visible = true
	_afficher_menu(menu_principal)

func cacher():
	panel.visible = false
	btn_attaquer.visible = true
	btn_competence.visible = true
	btn_attaquer.disabled = false
	joueur.stats.combat.pv_actuel = joueur.stats.combat.pv_max
	barre_pv_joueur.value = joueur.stats.combat.pv_max
	joueur.en_combat = false
	chat_node.en_combat = false
	SaveManager.sauvegarder(CombatManager.creature_complete)

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
	joueur.sprite.play("ATK SE")
	await joueur.sprite.animation_finished
	joueur.sprite.play("Idle " + joueur.last_dir)
	CombatManager.attaque_joueur()

func _repositionner_joueur() -> void:
	var distance_cible = 112.0
	var distance_actuelle = joueur.global_position.distance_to(ennemi_node.global_position)
	joueur.en_repositionnement = true
	if distance_actuelle < distance_cible:
		var direction_recul = (joueur.global_position - ennemi_node.global_position).normalized()
		while joueur.global_position.distance_to(ennemi_node.global_position) < distance_cible:
			joueur.velocity = Vector2(direction_recul.x, direction_recul.y * 0.5) * 100.0
			joueur.move_and_slide()
			joueur._play_walk(joueur._dir8_from_vector(direction_recul))
			await get_tree().process_frame
	var direction_ennemi = (ennemi_node.global_position - joueur.global_position).normalized()
	var dir = joueur._dir8_from_vector(direction_ennemi)
	joueur._play_idle(dir)
	joueur.last_dir = dir
	await get_tree().create_timer(0.3).timeout
	joueur.en_repositionnement = false
