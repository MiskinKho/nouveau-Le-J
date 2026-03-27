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
