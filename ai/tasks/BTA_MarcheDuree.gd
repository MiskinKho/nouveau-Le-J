@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_MarcherDuree             # Nom global pour l'éditeur BT

# Variable blackboard contenant la référence au composant de déplacement IA
@export var comp_var: StringName = &"Comp_DeplacementIA"  # Nom de la variable blackboard

# Durée de marche aléatoire (en secondes)
var duree := 0.0                             # Temps restant avant d'arrêter de marcher

# _enter() initialise une durée aléatoire à chaque entrée
func _enter() -> void:
	duree = randf_range(1.0, 3.0)            # Durée courte : le chat marche par petites séquences

# _tick() déplace le personnage dans la direction choisie via le composant
func _tick(delta: float) -> Status:
	var comp = blackboard.get_var(&"Comp_DeplacementIA")
	duree -= delta
	if duree <= 0:
		comp.arreter()
		return SUCCESS
	comp.deplacer(comp.direction)
	agent._play_walk(agent._dir8_from_vector(comp.direction))
	return RUNNING

func _exit() -> void:
	var comp = blackboard.get_var(&"Comp_DeplacementIA")
	comp.arreter()               # Encore en train de marcher
