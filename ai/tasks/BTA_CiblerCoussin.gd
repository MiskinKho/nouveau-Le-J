@tool
extends BTAction
class_name BTAction_CiblerCoussin

## Écrit la référence du coussin dans le blackboard pour BTAction_SeDeplacerVers

# _generate_name() affiche un nom lisible dans l'arbre
func _generate_name() -> String:
	return "Cibler coussin → blackboard"

# _tick() stocke le coussin comme cible de navigation
func _tick(_delta: float) -> Status:
	blackboard.set_var(&"cible", agent.coussin)  # Écrit la référence du coussin dans le blackboard
	return SUCCESS                                # Immédiat → passe à BTAction_SeDeplacerVers
