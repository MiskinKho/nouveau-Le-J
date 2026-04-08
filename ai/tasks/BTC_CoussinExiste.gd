@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTCondition                          # Classe LimboAI pour les conditions
class_name BTCondition_CoussinExiste         # Nom global pour l'éditeur BT

# _tick() vérifie si le personnage a un coussin assigné
func _tick(_delta: float) -> Status:
	# Vérifie que le coussin existe et n'a pas été libéré de la mémoire
	if is_instance_valid(agent.coussin):      # coussin assigné et valide en mémoire
		return SUCCESS                         # Condition remplie → le chat peut aller au coussin
	return FAILURE                             # Pas de coussin → fallback vers dormir sur place
