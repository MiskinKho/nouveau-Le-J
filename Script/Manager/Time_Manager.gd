extends Node  # Singleton autoload : gère le temps in-game (heure, jour, calendrier)

signal jour_change(jour)       # Émis à minuit (passage au jour suivant)
signal heure_change(heure)     # Émis chaque frame (utile pour le cycle jour/nuit)
signal faim_change(diminution) # Émis chaque frame avec la portion de faim à ajouter

var heure: float = 8.0   # Heure actuelle (0.0 à 24.0), commence à 8h du matin
var jour: int = 1         # Numéro du jour depuis le début du jeu

# Durée d'une journée en secondes réelles. 900s = 15 minutes réelles = 24h in-game.
var duree_journee: float = 900.0

const JOURS_SEMAINE = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
const MOIS = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
const JOURS_PAR_MOIS = 30   # Calendrier simplifié : tous les mois font 30 jours
const MOIS_PAR_AN = 12

func _process(delta):
	# Avance l'heure proportionnellement : 24h / duree_journee secondes réelles
	heure += delta * (24.0 / duree_journee)

	# Calcule la faim à ajouter ce delta : proportionnelle au temps écoulé in-game
	# 100 unités de faim se remplissent exactement en 24h in-game
	var diminution_faim = delta * (24.0 / duree_journee) * (100.0 / 24.0)
	emit_signal("faim_change", diminution_faim)

	# Passage à minuit : incrémente le jour
	if heure >= 24.0:
		heure = 0.0
		jour += 1
		emit_signal("jour_change", jour)
		_nouveau_jour()

	emit_signal("heure_change", heure)  # Émis chaque frame pour le cycle jour/nuit

func _nouveau_jour():
	print("Nouveau jour : ", get_date_formatee())  # Debug uniquement

# Retourne le nom du jour de la semaine (modulo 7 sur le numéro de jour)
func get_jour_semaine() -> String:
	return JOURS_SEMAINE[(jour - 1) % 7]

# Retourne le jour du mois (1 à 30, recommence après 30 jours)
func get_jour_mois() -> int:
	return ((jour - 1) % JOURS_PAR_MOIS) + 1

# Retourne le nom du mois (cycle sur 12 mois, recommence après 360 jours)
func get_mois() -> String:
	return MOIS[((jour - 1) / JOURS_PAR_MOIS) % MOIS_PAR_AN]

# Retourne l'heure formatée "HH:MM" avec padding zéro
func get_heure_formatee() -> String:
	var h = int(heure)
	var m = int((heure - h) * 60)  # Extrait les minutes depuis la partie décimale
	return "%02d:%02d" % [h, m]

# Retourne la date complète formatée : "Lundi 3 Janvier - 08:30"
func get_date_formatee() -> String:
	return "%s %d %s - %s" % [get_jour_semaine(), get_jour_mois(), get_mois(), get_heure_formatee()]
