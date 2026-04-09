extends StaticBody2D  # Corps statique : ne bouge pas mais détecte les collisions

enum Etat { PLEINE, MOITIE, VIDE }  # États visuels de la gamelle

var etat: Etat = Etat.VIDE
var nourriture: float = 0.0  # Quantité actuelle (0 à 100)

@onready var sprite = $Sprite2D
@onready var zone_detection = $Zone_Detection  # Area2D pour détecter l'entrée du chat

# Textures assignées dans l'éditeur pour les 4 niveaux de remplissage
@export var sprite_vide: Texture2D
@export var sprite_tier: Texture2D
@export var sprite_moitie: Texture2D
@export var sprite_remplie: Texture2D

signal chat_peut_manger  # Émis quand le chat entre dans la zone (non utilisé actuellement — la FSM gère la distance)

func _ready():
	zone_detection.body_entered.connect(_on_body_entered)
	zone_detection.input_event.connect(_on_click)  # Clic sur la zone = ouvre le menu gamelle

# Remplit la gamelle d'une portion (+25) quand un item NOURRITURE_CHAT est déposé.
# Plafonné à 100 par min().
func remplir(item: Item):
	nourriture = min(100.0, nourriture + 25.0)
	_mettre_a_jour_etat()
	print("Gamelle remplie : ", nourriture)

# Retire une quantité de nourriture (appelé chaque frame par Etat_Manger).
func manger(quantite: float):
	nourriture = max(0.0, nourriture - quantite)
	_mettre_a_jour_etat()

# Met à jour le sprite et l'état enum selon le niveau de nourriture.
# Seuils : 0 = vide, 1-33 = tier, 34-66 = moitié, 67-100 = pleine.
func _mettre_a_jour_etat():
	if nourriture <= 0:
		etat = Etat.VIDE
		sprite.texture = sprite_vide
	elif nourriture <= 33:
		etat = Etat.MOITIE       # Note : enum MOITIE mais visuellement c'est "tier" (< 1/3)
		sprite.texture = sprite_tier
	elif nourriture <= 66:
		etat = Etat.PLEINE       # Note : enum PLEINE mais visuellement c'est "moitié"
		sprite.texture = sprite_moitie
	else:
		sprite.texture = sprite_remplie  # Vraiment pleine (> 66)

func _on_body_entered(body):
	print("body entered : ", body.name)
	if body.is_in_group("chats"):
		emit_signal("chat_peut_manger")  # Non connecté actuellement — la logique est dans Etat_Faim

# Clic sur la zone de détection de la gamelle : ouvre le menu de remplissage
func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		EventBus.menu_gamelle_ouvert.emit(self)
