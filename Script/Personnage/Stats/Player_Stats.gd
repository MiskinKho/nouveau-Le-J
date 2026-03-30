extends Resource
class_name PlayerStats  # Stats du personnage joueur (distinct de Stats_Combat du chat)

@export var pv_max: int = 100       # PV maximum du joueur
@export var vie_actuelle: int = 100
@export var force: int = 200        # Force très élevée : le joueur est sensiblement plus fort que le chat
@export var agilite: int = 10
@export var precision: int = 10
@export var defense: int = 5
