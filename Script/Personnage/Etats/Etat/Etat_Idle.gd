extends State

const POIDS = {
	"Marcher": 30,
	"Idle": 70
}

var duree := 0.0

func enter() -> void:
	personnage._play_idle()
	duree = randf_range(2.0, 5.0)

func update(delta: float) -> void:
	if personnage.statss.bien_etre.faim > 70.0:
		personnage.state_machine._changer_etat("Faim")
		return
	if personnage.statss.bien_etre.energie <= 1.0:
		personnage.epuise = true
		personnage.state_machine._changer_etat("Dormir")
		return
	if personnage.statss.bien_etre.energie <= 20.0:
		personnage.state_machine._changer_etat("Fatigue")
		return

	duree -= delta
	if duree <= 0:
		personnage.state_machine._changer_etat(_choisir_prochain())

func exit() -> void:
	pass

func _choisir_prochain() -> String:
	var total := 0
	for p in POIDS.values():
		total += p
	var tirage := randi() % total
	var cumul := 0
	for etat in POIDS:
		cumul += POIDS[etat]
		if tirage < cumul:
			return etat
	return "Idle"
