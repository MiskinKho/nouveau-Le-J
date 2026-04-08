@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_MarcherDuree             # Nom global pour l'éditeur BT

# Durée de marche aléatoire (en secondes)
var duree := 0.0                             # Temps restant avant d'arrêter de marcher

# _enter() initialise une durée aléatoire à chaque entrée
func _enter() -> void:
	duree = randf_range(1.0, 3.0)            # Durée courte : le chat marche par petites séquences

# _tick() déplace le personnage dans la direction choisie
func _tick(delta: float) -> Status:
	duree -= delta                            # Décompte le temps de marche
	if duree <= 0:                            # Temps écoulé → arrêter
		agent.velocity = Vector2.ZERO          # Stoppe le mouvement
		return SUCCESS                          # Marche terminée

	# Applique la projection isométrique : y divisé par 2 pour aplatir le mouvement vertical
	var iso := Vector2(agent.direction.x, agent.direction.y * 0.5)
	agent.velocity = iso.normalized() * agent.speed   # Normalise pour vitesse constante en diagonale
	agent.move_and_slide()                             # Déplace avec gestion des collisions
	# Met à jour l'animation de marche selon la direction en 8 directions
	agent._play_walk(agent._dir8_from_vector(agent.direction))
	return RUNNING                                      # Encore en train de marcher

# _exit() arrête le mouvement proprement
func _exit() -> void:
	agent.velocity = Vector2.ZERO            # Sécurité : stoppe tout mouvement résiduel
