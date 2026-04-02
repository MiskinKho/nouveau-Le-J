extends Node  # Singleton autoload : orchestre toute la logique de combat (entraînement et combat sauvage)

enum Mode { JOUEUR, AUTO }  # JOUEUR = entraînement interactif, AUTO = combat contre ennemi sauvage

signal combat_demarre(combattant_1, combattant_2, mode)
signal attaque_effectuee(attaquant_nom, cible_nom, degats)
signal combat_termine(victoire: bool)
signal tour_joueur_commence  # Émis quand c'est au joueur d'agir (mode JOUEUR)

var mode_actuel: Mode
var stats_combattant_1: Stats_Combat  # Toujours le chat
var stats_combattant_2: Stats_Combat  # Joueur (mode JOUEUR) ou ennemi sauvage (mode AUTO)
var creature_complete: Creature       # Référence complète pour accéder aux stats bien_être post-combat
var en_combat := false
var tour_joueur := true  # True = le joueur peut agir, false = attente de la riposte

# Initialise et lance un combat.
# p_mode détermine si c'est interactif (joueur choisit les attaques) ou automatique.
func lancer_combat(p_creature: Creature, p_stats_ennemi: Stats_Combat, p_mode: Mode):
	creature_complete = p_creature
	stats_combattant_1 = p_creature.combat
	stats_combattant_2 = p_stats_ennemi
	mode_actuel = p_mode
	en_combat = true
	tour_joueur = true
	EventBus.combat_demarre.emit(stats_combattant_1, stats_combattant_2, p_mode)

	if p_mode == Mode.AUTO:
		await get_tree().create_timer(0.5).timeout  # Petit délai avant le premier tour pour la lisibilité
		_tour_auto()

# Exécute l'attaque du joueur sur le chat (mode entraînement).
# Bloque si ce n'est pas le tour du joueur (anti-spam de bouton).
func attaque_joueur():
	if not en_combat or not tour_joueur:
		return
	tour_joueur = false  # Bloque les nouvelles attaques jusqu'à la riposte

	# Dégâts = force joueur - défense chat, minimum 1 (toujours au moins 1 dégât)
	var degats: int = max(1, stats_combattant_2.force - stats_combattant_1.defense)
	stats_combattant_1.pv_actuel -= degats
	stats_combattant_1.pv_actuel = max(0, stats_combattant_1.pv_actuel)  # Clamp à 0

	if stats_combattant_1.pv_actuel <= 0:
		_terminer_combat(true)  # Chat à 0 PV : victoire de l'entraînement
		return

	await get_tree().create_timer(1.0).timeout  # Pause dramatique avant la riposte
	_riposte_chat()

# Riposte du chat après l'attaque du joueur (mode entraînement).
func _riposte_chat():
	var degats: int = max(1, stats_combattant_1.force - stats_combattant_2.defense)
	stats_combattant_2.pv_actuel -= degats
	stats_combattant_2.pv_actuel = max(0, stats_combattant_2.pv_actuel)
	EventBus.attaque_effectuee.emit(stats_combattant_1.nom, "Joueur", degats)

	if stats_combattant_2.pv_actuel <= 0:
		_terminer_combat(false)  # Joueur à 0 PV : défaite
		return

	tour_joueur = true                  # Rend la main au joueur
	EventBus.tour_joueur_commence.emit()

# Tour entièrement automatique pour le combat contre un ennemi sauvage.
# S'appelle récursivement via await jusqu'à la fin du combat.
func _tour_auto():
	if not en_combat:
		return

	# Tour du chat
	var degats_chat: int = max(1, stats_combattant_1.force - stats_combattant_2.defense)
	stats_combattant_2.pv_actuel -= degats_chat
	stats_combattant_2.pv_actuel = max(0, stats_combattant_2.pv_actuel)
	EventBus.attaque_effectuee.emit(stats_combattant_1.nom, stats_combattant_2.nom, degats_chat)

	if stats_combattant_2.pv_actuel <= 0:
		_terminer_combat(true)
		return

	await get_tree().create_timer(1.0).timeout  # Délai entre les tours pour lisibilité

	# Tour de l'ennemi
	var degats_ennemi: int = max(1, stats_combattant_2.force - stats_combattant_1.defense)
	stats_combattant_1.pv_actuel -= degats_ennemi
	stats_combattant_1.pv_actuel = max(0, stats_combattant_1.pv_actuel)
	EventBus.attaque_effectuee.emit(stats_combattant_2.nom, stats_combattant_1.nom, degats_ennemi)

	if stats_combattant_1.pv_actuel <= 0:
		_terminer_combat(false)
		return

	await get_tree().create_timer(1.0).timeout
	_tour_auto()  # Appel récursif : prochain tour

# Finalise le combat, distribue les gains si entraînement, émet le signal de fin.
func _terminer_combat(victoire: bool):
	en_combat = false

	# Gains d'entraînement uniquement en mode JOUEUR (pas de gains contre les ennemis sauvages)
	if mode_actuel == Mode.JOUEUR:
		var gain_pv_max: int = max(1, stats_combattant_2.force / 5)   # Gain PV basé sur la force du joueur
		var gain_force: int = max(1, stats_combattant_1.force / 5)    # Gain force basé sur la force du chat
		creature_complete.combat.pv_max += gain_pv_max
		creature_complete.combat.force += gain_force
		creature_complete.combat.pv_actuel = creature_complete.combat.pv_max  # Restaure les PV après entraînement
		creature_complete.bien_etre.energie = max(0.0, creature_complete.bien_etre.energie - 37                                                                               )  # Coût énergétique

	EventBus.combat_termine.emit(victoire)
