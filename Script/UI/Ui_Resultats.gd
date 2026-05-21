extends CanvasLayer

@onready var panel = $Panel_Resultats
@onready var label_stats = $Panel_Resultats/Label_Stats
@onready var btn_continuer = $Panel_Resultats/Btn_Continuer

func _ready():
	visible = false
	btn_continuer.pressed.connect(fermer)
	EventBus.combat_entrainement_termine.connect(_on_combat_termine)

func _on_combat_termine(creature, gain_pv_max, gain_force):
	afficher(creature, gain_pv_max, gain_force)

func afficher(stats: Resource, gain_pv_max: int, gain_force: int):  # Personnage_Data_Chat (duck typing : .combat)
	visible = true
	label_stats.text = "+%d PV Max  →  %d\n+%d Force  →  %d\nDéfense : %d" % [
		gain_pv_max, stats.combat.get_pv_max(),    # PV max reel (base race + bonus)
		gain_force, stats.combat.get_force(),       # Force reelle (base race + bonus)
		stats.combat.get_defense()                  # Defense reelle (base race + bonus)
	]

func fermer():
	visible = false
