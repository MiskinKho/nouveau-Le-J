extends State

func enter() -> void:
	pass

func update(_delta: float) -> void:
	if personnage.gamelle and personnage.gamelle.nourriture > 0:
		var distance = (personnage.gamelle.global_position - personnage.global_position).length()
		if distance > 1:
			personnage._se_deplacer_vers(personnage.gamelle.global_position)
		else:
			personnage.state_machine._changer_etat("Manger")
	else:
		personnage.state_machine._changer_etat("Idle")

func exit() -> void:
	pass
