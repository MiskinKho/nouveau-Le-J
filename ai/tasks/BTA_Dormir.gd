extends BTAction                             # Classe LimboAI pour les actions (retourne SUCCESS, FAILURE ou RUNNING)
class_name BTAction_Dormir          # Nom global pour l'éditeur BT

# Seuil d'énergie à atteindre avant de se réveiller (même valeur que Etat_Dormir sans coussin)
const SEUIL_REVEIL := 33.0
# Vitesse de régénération d'énergie par seconde (1 unité/s = regen standard sans coussin)
const VITESSE_REGEN := 1.0

# _enter() est appelée une seule fois quand l'arbre entre dans cette action
func _enter() -> void:
	agent.epuise = true              # Marque le personnage comme épuisé (utilisé par d'autres systèmes)
	agent.velocity = Vector2.ZERO    # Arrête tout mouvement
	agent._play_idle()               # Lance l'animation statique

# _tick() est appelée à chaque tick tant que l'action retourne RUNNING
func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO    # Sécurité : maintient l'immobilité à chaque frame
	agent.move_and_slide()           # Applique la physique (nécessaire pour CharacterBody2D)
	# Régénère l'énergie sans dépasser le seuil de réveil
	agent.stats.bien_etre.energie = min(SEUIL_REVEIL, agent.stats.bien_etre.energie + delta * VITESSE_REGEN)
	# Vérifie si le seuil de réveil est atteint
	if agent.stats.bien_etre.energie >= SEUIL_REVEIL:  # Assez reposé → se réveiller
		return SUCCESS                                   # Action terminée → la Sequence réussit
	return RUNNING                                       # Pas encore → re-tick à la prochaine frame

# _exit() est appelée une seule fois quand l'arbre quitte cette action
func _exit() -> void:
	agent.epuise = false             # Nettoie le flag d'épuisement au réveil
