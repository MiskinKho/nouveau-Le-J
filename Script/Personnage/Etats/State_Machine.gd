extends Node
class_name StateMachine  # Gestionnaire d'états finis (FSM) générique pour les personnages

signal etat_change(etat)  # Émis quand l'état actif change (utile pour le debug ou l'UI)

var etat_actuel: Node = null    # Référence à l'état Node actuellement actif
var etat_precedent: Node = null # Référence à l'état précédent (permet des transitions de retour)

func _ready() -> void:
	# Assigne la référence au personnage parent à chaque enfant de type State
	for enfant in get_children():
		if enfant is State:
			enfant.personnage = get_parent()  # get_parent() = le CharacterBody2D propriétaire

	# Attend une frame pour que tous les noeuds soient initialisés avant d'activer le premier état
	await get_tree().process_frame
	_changer_etat(get_child(0))  # Démarre avec le premier enfant de la scène (ordre dans l'arbre)

# Appelée chaque frame physique : délègue la mise à jour à l'état actif
func _physics_process(delta: float) -> void:
	print("SM update, etat: ", get_etat_nom())
	if etat_actuel:
		etat_actuel.update(delta)

# Permet de passer par un nom (String) ou une référence directe (Node).
# Évite les changements vers le même état (guard clause).
func _changer_etat(nouvel_etat) -> void:
	if nouvel_etat is String:
		nouvel_etat = get_node_or_null(nouvel_etat)  # Résout "Idle" → noeud enfant nommé "Idle"
	if nouvel_etat == etat_actuel:
		return  # Pas de changement inutile
	if etat_actuel:
		etat_actuel.exit()           # Nettoyage de l'état sortant
	etat_precedent = etat_actuel
	etat_actuel = nouvel_etat
	etat_actuel.enter()              # Initialisation du nouvel état
	emit_signal("etat_change", etat_actuel)

# Retourne le nom du noeud de l'état actif (utile pour le debug/HUD)
func get_etat_nom() -> String:
	return etat_actuel.name if etat_actuel else ""

# Retourne l'objet état précédent (permet à un état de "revenir en arrière")
func get_etat_precedent() -> Object:
	return etat_precedent
