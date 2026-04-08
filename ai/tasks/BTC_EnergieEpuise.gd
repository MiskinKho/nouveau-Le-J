extends BTCondition                          # Classe LimboAI pour les conditions (retourne SUCCESS ou FAILURE)
class_name BTCondition_EnergieEpuise         # Nom global pour pouvoir l'assigner dans l'éditeur BT

# Seuil d'énergie en dessous duquel le personnage est considéré épuisé
const SEUIL_EPUISE := 1.0

# _tick() est appelée à chaque tick de l'arbre — c'est l'équivalent de update() dans la FSM
func _tick(_delta: float) -> Status:
	# agent = le nœud sur lequel le BTPlayer est attaché (Personnage/Chat)
	if agent.stats.bien_etre.energie <= SEUIL_EPUISE:  # Vérifie si l'énergie est critique
		return SUCCESS                                   # Condition remplie → la Sequence continue
	return FAILURE                                       # Condition non remplie → la Sequence s'arrête
