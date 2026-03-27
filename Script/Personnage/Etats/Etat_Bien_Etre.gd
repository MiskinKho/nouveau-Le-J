extends State
class_name StateBienEtre

# Vérifie les stats vitales du personnage et déclenche un changement d'état si nécessaire.
# Doit être appelée en début de update() dans chaque état concerné.
# Retourne true si un changement d'état a été lancé — permet au caller de faire "return" immédiatement.
func _verifier_vitaux() -> bool:
	if personnage.stats.bien_etre.energie <= 1.0:         # Énergie épuisée : forcer le sommeil
		personnage.epuise = true                           # Marquer comme épuisé pour Etat_Dormir
		personnage.state_machine._changer_etat("Dormir")
		return true
	if personnage.stats.bien_etre.energie <= 20.0:        # Énergie faible : chercher un coussin
		personnage.state_machine._changer_etat("Fatigue")
		return true
	return false  # Aucun changement : l'état courant peut continuer
	if personnage.stats.bien_etre.faim > 70.0:           # Seuil de faim critique
		personnage.state_machine._changer_etat("Faim")
		return true

func update(delta: float) -> void:
	if _verifier_vitaux():   # Vérifie faim/énergie — change d'état si seuils dépassés
		return
	duree -= delta           # Décompte le temps restant
	if duree <= 0:
		# Durée écoulée : tire un nouvel état au hasard selon les poids
		personnage.state_machine._changer_etat(_choisir_prochain(POIDS))
