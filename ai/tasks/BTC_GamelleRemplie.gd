@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTCondition                          # Classe LimboAI pour les conditions
class_name BTCondition_GamelleRemplie        # Nom global pour l'éditeur BT

# _tick() vérifie que la gamelle existe et contient de la nourriture
func _tick(_delta: float) -> Status:
	# Double vérification : gamelle valide ET nourriture disponible
	if is_instance_valid(agent.gamelle) and agent.gamelle.nourriture > 0:
		return SUCCESS                         # Gamelle pleine → le chat peut aller manger
	return FAILURE                             # Pas de gamelle ou vide → fallback idle
