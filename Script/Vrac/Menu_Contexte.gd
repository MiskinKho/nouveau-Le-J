extends Panel

signal action_choisie(action: String)

@onready var btn_entrainer = $Btn_Entrainer
@onready var btn_caresser = $Btn_Caresser
@onready var btn_annuler = $Btn_Annuler

func _ready():
	btn_entrainer.pressed.connect(func(): emit_signal("action_choisie", "entrainer"))
	btn_caresser.pressed.connect(func(): emit_signal("action_choisie", "caresser"))
	btn_annuler.pressed.connect(fermer)

func fermer():
	get_parent().visible = false
