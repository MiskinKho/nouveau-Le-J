extends Node
class_name StateMachine

signal etat_change(etat)

var etat_actuel: Node = null
var etat_precedent: Node = null

func _ready() -> void:
	for enfant in get_children():
		if enfant is State:
			enfant.personnage = get_parent()
	await get_tree().process_frame
	_changer_etat(get_child(0))

func _physics_process(delta: float) -> void:
	if etat_actuel:
		etat_actuel.update(delta)

func _changer_etat(nouvel_etat) -> void:
	if nouvel_etat is String:
		nouvel_etat = get_node_or_null(nouvel_etat)
	if nouvel_etat == etat_actuel:
		return
	if etat_actuel:
		etat_actuel.exit()
	etat_precedent = etat_actuel
	etat_actuel = nouvel_etat
	etat_actuel.enter()
	emit_signal("etat_change", etat_actuel)

func get_etat_nom() -> String:
	return etat_actuel.name if etat_actuel else ""

func get_etat_precedent() -> Object:
	return etat_precedent
