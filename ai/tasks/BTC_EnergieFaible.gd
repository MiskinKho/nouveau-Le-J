@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTCondition                          # Classe LimboAI pour les conditions
class_name BTCondition_EnergieFaible         # Nom global pour l'éditeur BT

# Seuil d'énergie en dessous duquel le personnage est considéré fatigué
const SEUIL_FATIGUE := 20.0

# _tick() est appelée à chaque tick de l'arbre
func _tick(_delta: float) -> Status:
	# agent = le nœud sur lequel le BTPlayer est attaché (Personnage/Chat)
	if agent.stats.bien_etre.energie <= SEUIL_FATIGUE:  # Vérifie si l'énergie est faible
		return SUCCESS                                    # Condition remplie → la Sequence continue
	return FAILURE                                        # Condition non remplie → la Sequence s'arrête
