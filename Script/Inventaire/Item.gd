extends Resource
class_name Item  # Ressource représentant un objet de l'inventaire

# Types d'items : détermine dans quel slot/contexte l'item peut être utilisé
enum Type {GEMME, MINERAL, TAROT, NOURRITURE, OBJET_CHAT, VETEMENT, ENCENS, MEUBLE, NOURRITURE_CHAT}

@export var nom: String = ""         # Identifiant affiché et utilisé pour le chargement ("res://Asset/Item/{nom}.tres")
@export var description: String = ""
@export var type: Type = Type.GEMME
@export var icone: Texture2D         # Texture affichée dans l'Item_Slot de l'UI
@export var valeur: int = 0          # Valeur marchande (non utilisée pour l'instant)
@export var friandise: bool = false  # Tag "friandise" (non utilisé activement, prévu pour interactions)

# Effets appliqués au chat quand l'item est utilisé (bonus positifs)
@export var bonus_confort: float = 0.0
@export var bonus_confiance: float = 0.0
@export var bonus_energie: float = 0.0
@export var bonus_faim: float = 0.0     # Réduit la faim quand consommé
@export var bonus_force: float = 0.0
