@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_SeDeplacerVers           # Nom global pour l'éditeur BT

# Distance en pixels en dessous de laquelle on considère le personnage comme arrivé
const DISTANCE_ARRIVEE := 12.0

# Variable blackboard qui contient la clé de la cible (permet de réutiliser l'action pour coussin ET gamelle)
@export var cible_var: StringName = &"cible" # Nom de la variable blackboard contenant la position cible

# _tick() déplace le personnage vers la cible à chaque frame
func _tick(_delta: float) -> Status:
	# Récupère la position cible depuis le blackboard (Vector2 ou Node avec global_position)
	var cible = blackboard.get_var(cible_var)  # Lit la variable depuis le blackboard partagé
	if not is_instance_valid(cible):            # Cible invalide ou supprimée
		return FAILURE                           # Échec → le Selector essaiera le fallback

	# Calcule la distance entre le personnage et la cible
	var distance = (cible.global_position - agent.global_position).length()
	if distance <= DISTANCE_ARRIVEE:           # Assez proche → arrivé à destination
		agent.velocity = Vector2.ZERO            # Arrête le mouvement
		agent.move_and_slide()                   # Applique la physique
		return SUCCESS                            # Action terminée → passe à la tâche suivante

	# Pas encore arrivé → utilise la navigation pour se déplacer
	agent._se_deplacer_vers(cible.global_position)  # Délègue au NavigationAgent2D de PNJ
	return RUNNING                              # En cours → re-tick à la prochaine frame
