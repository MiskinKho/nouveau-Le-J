extends Node  # Singleton autoload : gère le rendu visuel du cycle jour/nuit

var cycle_node: CanvasModulate  # Filtre de couleur global sur toute la scène 2D
var lumiere_node: PointLight2D  # Lumière artificielle (lampe, fenêtre) active la nuit

# Initialise avec les noeuds de la scène et se connecte au signal horaire.
func initialiser(cycle: CanvasModulate, lumiere: PointLight2D):
	cycle_node = cycle
	lumiere_node = lumiere
	TimeManager.heure_change.connect(_on_heure_change)

func _on_heure_change(_heure):
	if cycle_node:
		cycle_node.color = _get_couleur_heure(TimeManager.heure)  # Met à jour le filtre global
	if lumiere_node:
		_mettre_a_jour_lumiere(TimeManager.heure)

# Retourne une couleur de filtre selon l'heure pour simuler la lumière du jour.
# Transitions : nuit foncée → aube orange → jour blanc → coucher de soleil → nuit.
func _get_couleur_heure(h: float) -> Color:
	if h < 6.0:
		return Color(0.1, 0.1, 0.3)   # Nuit : bleu très sombre
	elif h < 8.0:
		# Aube : interpolation de l'orange vers le blanc (lever du soleil)
		return Color(0.8, 0.5, 0.3).lerp(Color(1, 1, 1), (h - 6.0) / 2.0)
	elif h < 18.0:
		return Color(1, 1, 1)          # Journée : blanc neutre (pas de filtre)
	elif h < 21.0:
		# Coucher de soleil : interpolation du blanc vers l'orange
		return Color(1, 1, 1).lerp(Color(0.8, 0.4, 0.2), (h - 18.0) / 3.0)
	else:
		# Tombée de la nuit : interpolation de l'orange vers le bleu sombre
		return Color(0.8, 0.4, 0.2).lerp(Color(0.1, 0.1, 0.3), (h - 21.0) / 3.0)

# Gère l'intensité de la lumière artificielle (éteinte le jour, active la nuit).
func _mettre_a_jour_lumiere(h: float):
	if h >= 8.0 and h < 18.0:
		lumiere_node.energy = 0.0       # Journée : lumière artificielle inutile, éteinte
	elif h >= 18.0 and h < 21.0:
		# Allumage progressif au coucher du soleil
		lumiere_node.energy = (h - 18.0) / 3.0
	elif h >= 6.0 and h < 8.0:
		# Extinction progressive à l'aube
		lumiere_node.energy = 1.0 - ((h - 6.0) / 2.0)
	else:
		lumiere_node.energy = 1.0       # Nuit : lumière artificielle à pleine puissance
