extends Resource

class_name Item

enum Type {GEMME, MINERAL, TAROT, NOURRITURE, OBJET_CHAT, VETEMENT, ENCENS, MEUBLE, NOURRITURE_CHAT}

@export var nom: String = ""
@export var description: String = ""
@export var type: Type = Type.GEMME
@export var icone: Texture2D
@export var valeur: int = 0
@export var friandise: bool = false
# Effets sur le chat
@export var bonus_confort: float = 0.0
@export var bonus_confiance: float = 0.0
@export var bonus_energie: float = 0.0
@export var bonus_faim: float = 0.0
@export var bonus_force: float = 0.0
