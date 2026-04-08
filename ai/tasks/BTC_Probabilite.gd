@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTCondition                          # Classe LimboAI pour les conditions
class_name BTCondition_Probabilite           # Nom global pour l'éditeur BT

# Probabilité de succès (0.0 à 1.0) — 0.5 = 50% de chances
@export var probabilite := 0.5               # Configurable dans l'Inspector du nœud BT

# _tick() fait un tirage aléatoire
func _tick(_delta: float) -> Status:
	if randf() < probabilite:                 # Tirage réussi → on marche
		return SUCCESS
	return FAILURE                             # Tirage raté → fallback vers idle
