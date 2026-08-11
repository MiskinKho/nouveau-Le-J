extends Node  # Singleton autoload : orchestre toute la logique de combat (entraînement et combat sauvage)

enum Mode { JOUEUR, AUTO }  # JOUEUR = entraînement interactif, AUTO = combat contre ennemi sauvage

var mode_actuel: Mode
var stats_combattant_1: Stats_Combat  # Toujours le chat
var stats_combattant_2: Stats_Combat  # Joueur (mode JOUEUR) ou ennemi sauvage (mode AUTO)
var creature_complete: Resource       # Personnage_Data_Chat en pratique (duck typing : .combat et .bien_etre)
var en_combat := false
var tour_joueur := true  # True = le joueur peut agir, false = attente de la riposte

# Initialise et lance un combat.
# p_mode détermine si c'est interactif (joueur choisit les attaques) ou automatique.
func lancer_combat(p_creature: Resource, p_stats_ennemi: Stats_Combat, p_mode: Mode):
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
	var degats: int = max(1, stats_combattant_2.get_force() - stats_combattant_1.get_defense())
	stats_combattant_1.subir_degats(degats)  # La Resource applique les degats et gere le plancher a 0

	if stats_combattant_1.est_ko():
		_terminer_combat(true)  # Chat à 0 PV : victoire de l'entraînement
		return

	await get_tree().create_timer(1.0).timeout  # Pause dramatique avant la riposte
	_riposte_chat()

# Riposte du chat après l'attaque du joueur (mode entraînement).
func _riposte_chat():
	var degats: int = max(1, stats_combattant_1.get_force() - stats_combattant_2.get_defense())
	stats_combattant_2.subir_degats(degats)  # La Resource applique les degats et gere le plancher a 0
	EventBus.attaque_effectuee.emit(stats_combattant_1, stats_combattant_2, degats, stats_combattant_1.base.nom_race, "Joueur")  # Références pour le placement, noms lisibles pour le texte

	if stats_combattant_2.est_ko():
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
	var degats_chat: int = max(1, stats_combattant_1.get_force() - stats_combattant_2.get_defense())
	stats_combattant_2.subir_degats(degats_chat)  # La Resource applique les degats et gere le plancher a 0
	EventBus.attaque_effectuee.emit(stats_combattant_1, stats_combattant_2, degats_chat, stats_combattant_1.base.nom_race, stats_combattant_2.base.nom_race)  # Références pour le placement, noms lisibles pour le texte

	if stats_combattant_2.est_ko():
		_terminer_combat(true)
		return

	await get_tree().create_timer(1.0).timeout  # Délai entre les tours pour lisibilité

	# Tour de l'ennemi
	var degats_ennemi: int = max(1, stats_combattant_2.get_force() - stats_combattant_1.get_defense())
	stats_combattant_1.subir_degats(degats_ennemi)  # La Resource applique les degats et gere le plancher a 0
	EventBus.attaque_effectuee.emit(stats_combattant_2, stats_combattant_1, degats_ennemi, stats_combattant_2.base.nom_race, stats_combattant_1.base.nom_race)  # Références pour le placement, noms lisibles pour le texte

	if stats_combattant_1.est_ko():
		_terminer_combat(false)
		return

	await get_tree().create_timer(1.0).timeout
	_tour_auto()  # Appel récursif : prochain tour

# Finalise le combat, distribue les gains si entraînement, émet le signal de fin.
func _terminer_combat(victoire: bool):
	en_combat = false

	var gain_pv_max: int = 0                                                  # Gain par défaut 0 (mode AUTO : pas de gains)
	var gain_force: int = 0                                                   # Gain par défaut 0 (mode AUTO : pas de gains)

	# Gains d'entraînement uniquement en mode JOUEUR (pas de gains contre les ennemis sauvages)
	if mode_actuel == Mode.JOUEUR:
		gain_pv_max = max(1, stats_combattant_2.get_force() / 5)                    # Gain PV basé sur la force du joueur
		gain_force = max(1, stats_combattant_1.get_force() / 5)                     # Gain force basé sur la force du chat
		creature_complete.combat.appliquer_gain_entrainement(gain_pv_max, gain_force)  # Applique les bonus individuels (race intacte)
		creature_complete.combat.restaurer_pv()                                    # Restaure les PV au max réel après entraînement
		creature_complete.bien_etre.depenser_energie(30)                           # Coût énergétique (la Resource gere le plancher a 0)

	EventBus.combat_termine.emit(victoire, mode_actuel, gain_pv_max, gain_force)  # Émet avec mode et gains pour les listeners (UI, Monde)
