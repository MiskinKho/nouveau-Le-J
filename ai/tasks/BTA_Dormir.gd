@tool
extends BTAction                             # Classe LimboAI pour les actions (retourne SUCCESS, FAILURE ou RUNNING)
class_name BTAction_Dormir                   # Nom global pour l'éditeur BT

# Seuil d'énergie par défaut si pas de mobilier (dormir au sol)
const SEUIL_REVEIL_DEFAUT := 33.0
# Vitesse de régénération par défaut si pas de mobilier (dormir au sol)
const VITESSE_REGEN_DEFAUT := 1.0

# _enter() est appelée une seule fois quand l'arbre entre dans cette action
func _enter() -> void:
	agent.epuise = true              # Marque le personnage comme épuisé (utilisé par d'autres systèmes)
	agent.sur_coussin = is_instance_valid(agent.coussin)  # True si on dort sur un mobilier (utile pour autres systèmes)
	agent.velocity = Vector2.ZERO    # Arrête tout mouvement
	agent._play_idle()               # Lance l'animation statique

# _tick() est appelée à chaque tick tant que l'action retourne RUNNING
func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO    # Sécurité : maintient l'immobilité à chaque frame
	agent.move_and_slide()           # Applique la physique (nécessaire pour CharacterBody2D)

	# Détermine les stats de régénération : mobilier si présent, valeurs par défaut sinon
	var seuil := SEUIL_REVEIL_DEFAUT   # Valeur par défaut (sol)
	var vitesse := VITESSE_REGEN_DEFAUT  # Valeur par défaut (sol)
	if agent.sur_coussin and agent.coussin.stats_chat:       # Dort sur mobilier avec stats configurées
		seuil = agent.coussin.stats_chat.quantite_max_regeneration  # Seuil lu dans la Resource du mobilier
		vitesse = agent.coussin.stats_chat.vitesse_regeneration     # Vitesse lue dans la Resource du mobilier

	# Régénère l'énergie sans dépasser le seuil
	agent.stats.bien_etre.energie = min(seuil, agent.stats.bien_etre.energie + delta * vitesse)
	# Vérifie si le seuil de réveil est atteint
	if agent.stats.bien_etre.energie >= seuil:  # Assez reposé → se réveiller
		return SUCCESS                            # Action terminée → la Sequence réussit
	return RUNNING                                # Pas encore → re-tick à la prochaine frame

# _exit() est appelée une seule fois quand l'arbre quitte cette action
func _exit() -> void:
	agent.epuise = false             # Nettoie le flag d'épuisement au réveil
	agent.sur_coussin = false        # Nettoie le flag coussin au réveil
