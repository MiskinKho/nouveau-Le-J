@tool
extends BTAction
class_name BTAction_CiblerGamelle

## Écrit la référence de la gamelle dans le blackboard pour BTAction_SeDeplacerVers

# _generate_name() affiche un nom lisible dans l'arbre
func _generate_name() -> String:
	return "Cibler gamelle → blackboard"

# _tick() stocke la gamelle comme cible de navigation
func _tick(_delta: float) -> Status:
	blackboard.set_var(&"cible", agent.gamelle)  # Écrit la référence de la gamelle dans le blackboard
	return SUCCESS                                # Immédiat → passe à BTAction_SeDeplacerVers
