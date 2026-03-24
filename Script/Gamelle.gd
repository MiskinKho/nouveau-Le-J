extends StaticBody2D

enum Etat { PLEINE, MOITIE, VIDE }

var etat: Etat = Etat.VIDE
var nourriture: float = 0.0  # 0 à 100

@onready var sprite = $Sprite2D
@onready var zone_detection = $Zone_Detection

@export var sprite_vide: Texture2D
@export var sprite_tier: Texture2D
@export var sprite_moitie: Texture2D
@export var sprite_remplie: Texture2D

signal chat_peut_manger

func _ready():
	zone_detection.body_entered.connect(_on_body_entered)
	zone_detection.input_event.connect(_on_click)
	
func remplir(item: Item):
	nourriture = min(100.0, nourriture + 25.0)
	_mettre_a_jour_etat()
	print("Gamelle remplie : ", nourriture)
	
func manger(quantite: float):
	nourriture = max(0.0, nourriture - quantite)
	_mettre_a_jour_etat()

func _mettre_a_jour_etat():
	if nourriture <= 0:
		etat = Etat.VIDE
		sprite.texture = sprite_vide
	elif nourriture <= 33:
		etat = Etat.MOITIE
		sprite.texture = sprite_tier
	elif nourriture <= 66:
		etat = Etat.PLEINE
		sprite.texture = sprite_moitie
	else:
		sprite.texture = sprite_remplie

func _on_body_entered(body):
	print("body entered : ", body.name)
	if body.is_in_group("chats"):
		emit_signal("chat_peut_manger")


func _nourrir_chat(chat):
	print("chat mange, nourriture : ", nourriture, " faim : ", chat.stats.faim)
	if nourriture <= 0:
		return
		# Le chat mange progressivement
	var portion = 10.0
	nourriture = max(0.0, nourriture - portion)
	chat.stats.faim = min(100.0, chat.stats.faim + portion * 2)
	_mettre_a_jour_etat()
	# Si le chat est rassasié, il retourne à l'idle
	if chat.stats.faim >= 80.0:
		chat.etat_actuel = chat.Etat.IDLE
		
func _on_click(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		EventBus.menu_gamelle_ouvert.emit(self)
