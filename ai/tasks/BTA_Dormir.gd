@tool
extends BTAction                             # Classe LimboAI pour les actions (retourne SUCCESS, FAILURE ou RUNNING)
class_name BTAction_Dormir                   # Nom global pour l'éditeur BT

# Seuil de réveil par défaut (dort au sol, pas sur mobilier)
const SEUIL_REVEIL_DEFAUT := 33.0
# Vitesse de régénération par défaut (dort au sol, pas sur mobilier)
const VITESSE_REGEN_DEFAUT := 1.0

# Mobilier sur lequel le personnage dort actuellement (null = dort au sol)
# Stocké au _enter() pour éviter de re-scanner le groupe à chaque _tick()
var mobilier_actuel: MobilierDormable = null

# _enter() est appelée une seule fois quand l'arbre entre dans cette action
func _enter() -> void:
	agent.epuise = true              # Marque le personnage comme épuisé (utilisé par d'autres systèmes)
	agent.velocity = Vector2.ZERO    # Arrête tout mouvement
	agent._play_idle()               # Lance l'animation statique
	mobilier_actuel = _trouver_mobilier_sous_agent()  # Détecte une seule fois si on dort sur un meuble

# Cherche dans le groupe "mobilier_sommeil" un meuble qui contient l'agent dans sa ZoneOccupation.
# Retourne le meuble trouvé, ou null si l'agent dort au sol.
func _trouver_mobilier_sous_agent() -> MobilierDormable:
	for m in agent.get_tree().get_nodes_in_group("mobilier_sommeil"):  # Parcourt tous les meubles dormables du monde
		if m.est_occupe_par(agent):  # Demande au meuble s'il contient l'agent dans sa zone
			return m                  # Premier trouvé → on s'arrête (un personnage ne peut être que sur un meuble à la fois)
	return null                       # Aucun meuble ne contient l'agent → dort au sol

# _tick() est appelée à chaque tick tant que l'action retourne RUNNING
func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO    # Sécurité : maintient l'immobilité à chaque frame
	agent.move_and_slide()           # Applique la physique (nécessaire pour CharacterBody2D)

	# Détermine les stats de régénération : mobilier si on est dessus, valeurs par défaut sinon
	var seuil := SEUIL_REVEIL_DEFAUT    # Valeur par défaut (sol)
	var vitesse := VITESSE_REGEN_DEFAUT # Valeur par défaut (sol)
	if mobilier_actuel and mobilier_actuel.stats_chat:                  # Dort sur un meuble avec stats configurées
		seuil = mobilier_actuel.stats_chat.quantite_max_regeneration    # Seuil lu dans la Resource du meuble
		vitesse = mobilier_actuel.stats_chat.vitesse_regeneration       # Vitesse lue dans la Resource du meuble

	# Régénère l'énergie sans dépasser le seuil
	agent.stats.bien_etre.energie = min(seuil, agent.stats.bien_etre.energie + delta * vitesse)
	# Vérifie si le seuil de réveil est atteint
	if agent.stats.bien_etre.energie >= seuil:  # Assez reposé → se réveiller
		return SUCCESS                            # Action terminée → la Sequence réussit
	return RUNNING                                # Pas encore → re-tick à la prochaine frame

# _exit() est appelée une seule fois quand l'arbre quitte cette action
func _exit() -> void:
	agent.epuise = false             # Nettoie le flag d'épuisement au réveil
	mobilier_actuel = null           # Nettoie la référence au meuble
