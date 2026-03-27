extends State  # État déclenché quand la faim dépasse 70 — le chat cherche sa gamelle

func enter() -> void:
	pass  # Pas d'initialisation nécessaire : le chat se dirige immédiatement vers la gamelle

func update(_delta: float) -> void:
	# Vérifie que la gamelle existe ET contient de la nourriture
	if personnage.gamelle and personnage.gamelle.nourriture > 0:
		var distance = (personnage.gamelle.global_position - personnage.global_position).length()
		if distance > 1:
			# Pas encore arrivé : se déplace vers la gamelle via NavigationAgent2D
			personnage._se_deplacer_vers(personnage.gamelle.global_position)
		else:
			# Arrivé à la gamelle : passe à l'état Manger
			personnage.state_machine._changer_etat("Manger")
	else:
		# Pas de gamelle ou gamelle vide : abandon, retour à l'idle
		personnage.state_machine._changer_etat("Idle")

func exit() -> void:
	pass
