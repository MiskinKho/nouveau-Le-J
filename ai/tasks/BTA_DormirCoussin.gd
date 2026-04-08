@tool                                        # Nécessaire pour que LimboAI détecte la tâche dans l'éditeur
extends BTAction                             # Classe LimboAI pour les actions
class_name BTAction_DormirSurCoussin         # Nom global pour l'éditeur BT

# Seuil de réveil par défaut si le coussin n'a pas de stats configurées
const SEUIL_REVEIL_DEFAUT := 50.0
# Vitesse de régénération par défaut si le coussin n'a pas de stats configurées
const VITESSE_REGEN_DEFAUT := 2.0

# _enter() est appelée une seule fois quand l'arbre entre dans cette action
func _enter() -> void:
	agent.sur_coussin = true          # Active le flag coussin (utilisé par d'autres systèmes)
	agent.epuise = true               # Marque comme épuisé pour la régénération
	agent.velocity = Vector2.ZERO     # Arrête tout mouvement
	agent._play_idle()                # Lance l'animation statique

# _tick() régénère l'énergie à chaque frame avec les bonus du coussin
func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO     # Sécurité : maintient l'immobilité
	agent.move_and_slide()            # Applique la physique

	# Récupère les stats du coussin si elles existent
	var seuil := SEUIL_REVEIL_DEFAUT   # Valeur par défaut
	var bonus := VITESSE_REGEN_DEFAUT   # Valeur par défaut
	if agent.coussin and agent.coussin.stats_chat:                        # Coussin avec stats configurées
		seuil = agent.coussin.stats_chat.quantite_max_regeneration         # Seuil personnalisé du coussin
		bonus = agent.coussin.stats_chat.vitesse_regeneration              # Vitesse personnalisée du coussin

	# Régénère l'énergie sans dépasser le seuil du coussin
	agent.stats.bien_etre.energie = min(seuil, agent.stats.bien_etre.energie + delta * bonus)

	# Vérifie si le seuil de réveil est atteint
	if agent.stats.bien_etre.energie >= seuil:  # Assez reposé → se réveiller
		return SUCCESS                             # Action terminée
	return RUNNING                                # Pas encore → re-tick à la prochaine frame

# _exit() nettoie les flags au réveil
func _exit() -> void:
	agent.epuise = false              # Nettoie le flag d'épuisement
	agent.sur_coussin = false         # Nettoie le flag coussin
