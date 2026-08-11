@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_Idle             # Nom global — "one-shot" car retourne SUCCESS immédiatement

# _tick() joue idle et retourne SUCCESS en une seule frame
func _tick(_delta: float) -> Status:
	agent.velocity = Vector2.ZERO     # Arrête tout mouvement
	agent.move_and_slide()            # Applique la physique
	agent.comp_anim.jouer_idle()      # Lance l'animation Idle via le composant (last_dir interne)
	return SUCCESS                    # Terminé immédiatement → le Selector est satisfait
