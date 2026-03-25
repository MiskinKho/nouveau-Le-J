extends State

func enter() -> void:
	pass

func update(_delta: float) -> void:
	print("Fatigue update, energie: ", personnage.stats.bien_etre.energie, " epuise: ", personnage.epuise)
	if personnage.stats.bien_etre.energie <= 1.0:
		personnage.epuise = true
		personnage.state_machine._changer_etat("Dormir")
		return
	if personnage.coussin:
		var distance = (personnage.coussin.global_position - personnage.global_position).length()
		if distance > 12:
			personnage._se_deplacer_vers(personnage.coussin.global_position)
		else:
			personnage.state_machine._changer_etat("Dormir")
	else:
		personnage.state_machine._changer_etat("Dormir")

func exit() -> void:
	pass
