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

func afficher(stats: Creature, gain_pv_max: int, gain_force: int):
	visible = true
	label_stats.text = "+%d PV Max  →  %d\n+%d Force  →  %d\nDéfense : %d\nAgilité : %d\nPrécision : %d" % [
		gain_pv_max, stats.combat.pv_max,
		gain_force, stats.combat.force,
		stats.combat.defense,
		stats.combat.agilite,
		stats.combat.precision
	]

func fermer():
	visible = false
