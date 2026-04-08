@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_ChoisirDirection         # Nom global pour l'éditeur BT

# _tick() choisit une direction libre via raycast et la stocke sur le personnage
func _tick(_delta: float) -> Status:
	agent._choisir_direction()                # Délègue au PNJ : raycast 4 diagonales, shuffle
	if agent.direction != Vector2.ZERO:       # Une direction libre a été trouvée
		return SUCCESS                         # Direction choisie → passer à la marche
	return FAILURE                             # Toutes directions bloquées → fallback idle
