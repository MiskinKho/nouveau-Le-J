extends Node

enum Mode { JOUEUR, AUTO }

# Signaux
signal combat_demarre(combattant_1, combattant_2, mode)
signal attaque_effectuee(attaquant_nom, cible_nom, degats)
signal combat_termine(victoire: bool)
signal tour_joueur_commence

# État du combat
var mode_actuel: Mode
var stats_combattant_1: Stats_Combat  # Toujours le chat
var stats_combattant_2: Stats_Combat  # Joueur ou ennemi
var creature_complete: Creature       # Pour accès aux stats bien_être
var en_combat := false
var tour_joueur := true

func lancer_combat(p_creature: Creature, p_stats_ennemi: Stats_Combat, p_mode: Mode):
	creature_complete = p_creature
	stats_combattant_1 = p_creature.combat
	stats_combattant_2 = p_stats_ennemi
	mode_actuel = p_mode
	en_combat = true
	tour_joueur = true
	EventBus.combat_demarre.emit(stats_combattant_1, stats_combattant_2, p_mode)

	
	if p_mode == Mode.AUTO:
		await get_tree().create_timer(0.5).timeout
		_tour_auto()

func attaque_joueur():
	if not en_combat or not tour_joueur:
		return
	tour_joueur = false
	
	# Calcul des dégâts du joueur sur le chat (entraînement)
	# Ici combattant_2 = stats joueur, combattant_1 = chat
	var degats: int = max(1, stats_combattant_2.force - stats_combattant_1.defense)
	stats_combattant_1.pv_actuel -= degats
	stats_combattant_1.pv_actuel = max(0, stats_combattant_1.pv_actuel)
	 
	
	if stats_combattant_1.pv_actuel <= 0:
		_terminer_combat(true)
		return
	
	await get_tree().create_timer(1.0).timeout
	_riposte_chat()

func _riposte_chat():
	# Le chat riposte contre le joueur
	var degats: int = max(1, stats_combattant_1.force - stats_combattant_2.defense)
	stats_combattant_2.pv_actuel -= degats
	stats_combattant_2.pv_actuel = max(0, stats_combattant_2.pv_actuel)
	EventBus.attaque_effectuee.emit(stats_combattant_1.nom, "Joueur", degats)
	
	if stats_combattant_2.pv_actuel <= 0:
		_terminer_combat(false)
		return
	
	tour_joueur = true
	EventBus.tour_joueur_commence.emit()

func _tour_auto():
	if not en_combat:
		return
	
	# Tour du chat
	var degats_chat: int = max(1, stats_combattant_1.force - stats_combattant_2.defense)
	stats_combattant_2.pv_actuel -= degats_chat
	stats_combattant_2.pv_actuel = max(0, stats_combattant_2.pv_actuel)
	EventBus.attaque_effectuee.emit(stats_combattant_1.nom, stats_combattant_2.nom, degats_chat ) 
	
	if stats_combattant_2.pv_actuel <= 0:
		_terminer_combat(true)
		return
	
	await get_tree().create_timer(1.0).timeout
	
	# Tour de l'ennemi
	var degats_ennemi: int = max(1, stats_combattant_2.force - stats_combattant_1.defense)
	stats_combattant_1.pv_actuel -= degats_ennemi
	stats_combattant_1.pv_actuel = max(0, stats_combattant_1.pv_actuel)
	EventBus.attaque_effectuee.emit(stats_combattant_2.nom, stats_combattant_1.nom, degats_ennemi)
	
	if stats_combattant_1.pv_actuel <= 0:
		_terminer_combat(false)
		return
	
	await get_tree().create_timer(1.0).timeout
	_tour_auto()

func _terminer_combat(victoire: bool):
	en_combat = false
	
	# Gains de stats si entraînement
	if mode_actuel == Mode.JOUEUR:
		var gain_pv_max: int = max(1, stats_combattant_2.force / 5)
		var gain_force: int = max(1, stats_combattant_1.force / 5)
		creature_complete.combat.pv_max += gain_pv_max
		creature_complete.combat.force += gain_force
		creature_complete.combat.pv_actuel = creature_complete.combat.pv_max
		creature_complete.bien_etre.energie = max(0.0, creature_complete.bien_etre.energie - 33)
	
	EventBus.combat_termine.emit(victoire)
	print("signal combat_termine émis")
