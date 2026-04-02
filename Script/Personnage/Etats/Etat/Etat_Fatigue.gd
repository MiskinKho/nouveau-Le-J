extends StateBienEtre  # État intermédiaire : énergie faible, le chat cherche son coussin pour dormir

func enter() -> void:
	pass

func update(_delta: float) -> void:
	# Vérification prioritaire : si épuisement total, dormir immédiatement (même par terre)
	if personnage.stats.bien_etre.energie <= 1.0:
		personnage.epuise = true
		personnage.state_machine._changer_etat("Dormir")
		return

	if personnage.coussin:
		var distance = (personnage.coussin.global_position - personnage.global_position).length()
		if distance > 12: # Encore loin du coussin : s'y déplacer via navigation

			personnage._se_deplacer_vers(personnage.coussin.global_position)
		else:
			personnage.sur_coussin = true       # Arrivé sur le coussin : active le flag avant de dormir
			personnage.state_machine._changer_etat("Dormir") # Sur le coussin : passer à Dormir (bénéficiera du bonus de régénération)
	else:
		# Pas de coussin dans la scène : dormir par terre (régénération standard)
		personnage.state_machine._changer_etat("Dormir")

func exit() -> void:
	pass
