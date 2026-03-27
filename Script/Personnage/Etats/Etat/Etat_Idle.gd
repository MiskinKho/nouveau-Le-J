extends State   # Hérite de State, implémente l'état "repos/attente"

# Table de probabilité pour le prochain état après la durée d'idle.
# Idle est favorisé (70%) pour donner une impression de chat calme et contemplatif.



func enter() -> void:
	personnage._play_idle()                    # Lance l'animation statique (direction par défaut "S")
	duree = randf_range(2.0, 5.0)             # Durée aléatoire entre 2 et 5 secondes

func update(delta: float) -> void:
	if _verifier_vitaux():   # Vérifie faim/énergie — change d'état si seuils dépassés
		return
	duree -= delta           # Décompte le temps restant
	if duree <= 0:
		# Durée écoulée : tire un nouvel état au hasard selon les poids
		personnage.state_machine._changer_etat(_choisir_prochain(POIDS))

func exit() -> void:
	pass  # Rien à nettoyer en sortant d'Idle
