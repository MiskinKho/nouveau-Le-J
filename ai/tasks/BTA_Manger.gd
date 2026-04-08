@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_Manger                   # Nom global pour l'éditeur BT

# Seuil de faim en dessous duquel le chat est rassasié
const SEUIL_RASSASIE := 20.0
# Quantité de nourriture consommée par seconde
const VITESSE_MANGER := 1.0

# _enter() active le flag de repas
func _enter() -> void:
	agent.mange = true                # Bloque l'accumulation de faim dans CreatureManager
	agent.velocity = Vector2.ZERO     # Immobile pendant le repas
	agent._play_idle()                # Animation statique (pas d'animation de manger dédiée)

# _tick() consomme la gamelle et réduit la faim à chaque frame
func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO     # Sécurité : maintient l'immobilité
	agent.move_and_slide()            # Applique la physique

	var unite_mangee = delta * VITESSE_MANGER              # Quantité consommée cette frame
	agent.gamelle.manger(unite_mangee)                      # Retire de la gamelle
	# Réduit la faim sans descendre en dessous de 0
	agent.stats.bien_etre.faim = max(0.0, agent.stats.bien_etre.faim - unite_mangee)

	# Rassasié → arrêter de manger
	if agent.stats.bien_etre.faim <= SEUIL_RASSASIE:       # Faim suffisamment basse
		return SUCCESS                                       # Repas terminé

	# Gamelle vidée en cours de repas → arrêter aussi
	if not is_instance_valid(agent.gamelle) or agent.gamelle.nourriture <= 0:
		return SUCCESS                                       # Plus rien à manger

	return RUNNING                                           # Encore en train de manger

# _exit() désactive le flag de repas
func _exit() -> void:
	agent.mange = false               # Réactive l'accumulation de faim dans CreatureManager
