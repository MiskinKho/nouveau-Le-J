@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_ChoisirDirection         # Nom global pour l'éditeur BT

# Variable blackboard contenant la référence au composant de déplacement IA
@export var comp_var: StringName = &"Comp_DeplacementIA"  # Nom de la variable blackboard

# _tick() choisit une direction libre via le composant de déplacement
func _tick(_delta: float) -> Status:
	var comp = blackboard.get_var(&"Comp_DeplacementIA")    # Récupère CompDeplacementIA depuis le blackboard
	comp.choisir_direction()                                 # Délègue au composant : raycast diagonales, shuffle
	if comp.direction != Vector2.ZERO:                       # Une direction libre a été trouvée
		return SUCCESS                                       # Direction choisie → passer à la marche
	return FAILURE                                           # Toutes directions bloquées → fallback idle
