@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTCondition                          # Classe LimboAI pour les conditions
class_name BTCondition_FaimCritique          # Nom global pour l'éditeur BT

# Seuil de faim au-dessus duquel le personnage doit manger
const SEUIL_FAIM := 70.0

# _tick() vérifie si la faim est critique
func _tick(_delta: float) -> Status:
	# La faim monte (contrairement à l'énergie qui descend)
	if agent.stats.bien_etre.faim > SEUIL_FAIM:  # Faim au-dessus du seuil critique
		return SUCCESS                              # Condition remplie → chercher à manger
	return FAILURE                                  # Pas assez faim → passer à la branche suivante
