extends State

func enter() -> void:
	personnage.mange = true

func update(delta: float) -> void:
	personnage.velocity = Vector2.ZERO
	personnage.move_and_slide()
	personnage._play_idle()

	var unite_mangee = delta * 1.0
	personnage.gamelle.manger(unite_mangee)
	personnage.stats.bien_etre.faim = max(0.0, personnage.stats.bien_etre.faim - unite_mangee)

	if personnage.stats.bien_etre.faim <= 20.0:
		personnage.state_machine._changer_etat("Idle")
	if not personnage.gamelle or personnage.gamelle.nourriture <= 0:
		personnage.state_machine._changer_etat("Idle")

func exit() -> void:
	personnage.mange = false
