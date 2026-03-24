extends Node

var cycle_node: CanvasModulate
var lumiere_node: PointLight2D

func initialiser(cycle: CanvasModulate, lumiere: PointLight2D):
	cycle_node = cycle
	lumiere_node = lumiere
	TimeManager.heure_change.connect(_on_heure_change)

func _on_heure_change(_heure):
	if cycle_node:
		cycle_node.color = _get_couleur_heure(TimeManager.heure)
	if lumiere_node:
		_mettre_a_jour_lumiere(TimeManager.heure)

func _get_couleur_heure(h: float) -> Color:
	if h < 6.0:
		return Color(0.1, 0.1, 0.3)
	elif h < 8.0:
		return Color(0.8, 0.5, 0.3).lerp(Color(1, 1, 1), (h - 6.0) / 2.0)
	elif h < 18.0:
		return Color(1, 1, 1)
	elif h < 21.0:
		return Color(1, 1, 1).lerp(Color(0.8, 0.4, 0.2), (h - 18.0) / 3.0)
	else:
		return Color(0.8, 0.4, 0.2).lerp(Color(0.1, 0.1, 0.3), (h - 21.0) / 3.0)

func _mettre_a_jour_lumiere(h: float):
	if h >= 8.0 and h < 18.0:
		lumiere_node.energy = 0.0
	elif h >= 18.0 and h < 21.0:
		lumiere_node.energy = (h - 18.0) / 3.0
	elif h >= 6.0 and h < 8.0:
		lumiere_node.energy = 1.0 - ((h - 6.0) / 2.0)
	else:
		lumiere_node.energy = 1.0
