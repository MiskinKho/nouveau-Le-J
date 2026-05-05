extends Resource
class_name Stats_Combat  # Stats de combat d'un combattant (chat, joueur, ennemi)

@export var nom: String = ""        # Nom affiché dans l'UI de combat
@export var niveau: int = 1         # Niveau (non utilisé activement dans le calcul actuel)
@export var experience: int = 0     # XP accumulée (non utilisée, prévu pour évolution)
@export var pv_max: int = 50        # Points de vie maximum
@export var pv_actuel: int = 50     # Points de vie actuels (modifiés pendant le combat)
@export var force: int = 10         # Détermine les dégâts infligés : max(1, force - défense_cible)
@export var defense: int = 5        # Réduit les dégâts reçus
@export var agilite: int = 10       # Non utilisé activement (prévu pour esquive/vitesse)
@export var precision: int = 10     # Non utilisé activement (prévu pour taux de touche)

# Serialise toutes les stats de combat en Dictionary JSON-compatible.
func to_dict() -> Dictionary:
	return {
		"nom": nom,                # Nom du combattant
		"niveau": niveau,          # Niveau actuel
		"experience": experience,  # XP accumulee
		"pv_max": pv_max,          # Points de vie maximum
		"pv_actuel": pv_actuel,    # Points de vie actuels
		"force": force,            # Force d'attaque
		"defense": defense,        # Reduction de degats
		"agilite": agilite,        # Esquive/vitesse (reserve)
		"precision": precision     # Taux de touche (reserve)
	}

# Deserialise un Dictionary. Utilise get() pour la robustesse des anciennes saves.
func from_dict(data: Dictionary):
	nom = data.get("nom", "")              # Fallback chaine vide si absent
	niveau = data.get("niveau", 1)         # Fallback niveau 1
	experience = data.get("experience", 0) # Fallback 0 XP
	pv_max = data.get("pv_max", 50)        # Fallback 50 PV max
	pv_actuel = data.get("pv_actuel", 50)  # Fallback 50 PV actuels
	force = data.get("force", 10)          # Fallback force 10
	defense = data.get("defense", 5)       # Fallback defense 5
	agilite = data.get("agilite", 10)      # Fallback agilite 10
	precision = data.get("precision", 10)  # Fallback precision 10
