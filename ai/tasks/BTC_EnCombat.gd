@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTCondition                          # Condition : vérifie un état, retourne SUCCESS ou FAILURE

## Vérifie si le personnage est actuellement en combat

# Nom affiché dans l'arbre BT (nécessite @tool)
func _generate_name() -> String:
	return "En combat ?"                     # Nom lisible dans l'éditeur

# _tick() vérifie le flag en_combat du personnage
func _tick(_delta: float) -> Status:
	if agent.en_combat:                      # Flag défini dans Personnage.gd, activé par Monde.gd/CombatManager
		return SUCCESS                       # En combat → la Sequence continue vers BTA_Combat
	return FAILURE                           # Pas en combat → le Selector passe aux branches suivantes
