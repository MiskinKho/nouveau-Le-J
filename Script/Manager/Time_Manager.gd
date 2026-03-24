extends Node

signal jour_change(jour)
signal heure_change(heure)
signal faim_change(diminution)

var heure: float = 8.0
var jour: int = 1
var duree_journee: float = 900.0 # Durée d'une journée en secondes réelles (900 = 15 min)0.0

const JOURS_SEMAINE = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
const MOIS = ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
const JOURS_PAR_MOIS = 30
const MOIS_PAR_AN = 12

func _process(delta):
	heure += delta * (24.0 / duree_journee)
	var diminution_faim = delta * (24.0 / duree_journee) * (100.0 / 24.0)
	emit_signal("faim_change", diminution_faim)
	if heure >= 24.0:
		heure = 0.0
		jour += 1
		emit_signal("jour_change", jour)
		_nouveau_jour()
	emit_signal("heure_change", heure)

func _nouveau_jour():
	print("Nouveau jour : ", get_date_formatee())

func get_jour_semaine() -> String:
	return JOURS_SEMAINE[(jour - 1) % 7]

func get_jour_mois() -> int:
	return ((jour - 1) % JOURS_PAR_MOIS) + 1

func get_mois() -> String:
	return MOIS[((jour - 1) / JOURS_PAR_MOIS) % MOIS_PAR_AN]

func get_heure_formatee() -> String:
	var h = int(heure)
	var m = int((heure - h) * 60)
	return "%02d:%02d" % [h, m]

func get_date_formatee() -> String:
	return "%s %d %s - %s" % [get_jour_semaine(), get_jour_mois(), get_mois(), get_heure_formatee()]
