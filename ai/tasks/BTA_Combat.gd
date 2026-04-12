@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Action : immobilise le chat pendant le combat

## Immobilise le personnage pendant toute la durée du combat

# Nom affiché dans l'arbre BT (nécessite @tool)
func _generate_name() -> String:
	return "Attendre fin combat"             # Nom lisible dans l'éditeur

# _enter() arrête le mouvement à l'entrée dans le combat
func _enter() -> void:
	agent.velocity = Vector2.ZERO            # Stoppe tout déplacement en cours
	agent.move_and_slide()                   # Applique la physique pour que le stop soit immédiat
	agent._play_idle(agent.last_dir)         # Joue l'animation idle dans la dernière direction

# _tick() maintient l'immobilisation tant que le combat est actif
func _tick(_delta: float) -> Status:
	agent.velocity = Vector2.ZERO            # Continue de bloquer le mouvement chaque frame
	agent.move_and_slide()                   # Applique la physique
	if agent.en_combat:                      # Combat toujours en cours
		return RUNNING                       # Reste dans cette tâche → re-tick à la prochaine frame
	return SUCCESS                           # Combat terminé → le Selector reprend le cours normal

# _exit() s'assure que le chat est bien arrêté en sortant
func _exit() -> void:
	agent._play_idle(agent.last_dir)         # Remet l'animation idle proprement
