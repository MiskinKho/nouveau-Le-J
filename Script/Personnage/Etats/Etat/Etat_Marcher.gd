extends State

const POIDS = {
	"Marcher": 50,
	"Idle": 50
}

var duree := 0.0

func enter() -> void:
	duree = randf_range(1.0, 3.0)
	personnage._choisir_direction()

func update(delta: float) -> void:
	if personnage.stats.bien_etre.faim > 70.0:
		personnage.state_machine._changer_etat("Faim")
		return
	if personnage.stats.bien_etre.energie <= 1.0:
		personnage.epuise = true
		personnage.state_machine._changer_etat("Dormir")
		return
	if personnage.stats.bien_etre.energie <= 20.0:
		personnage.state_machine._changer_etat("Fatigue")
		return

	duree -= delta
	if duree <= 0:
		personnage.state_machine._changer_etat(_choisir_prochain())
		return

	var iso := Vector2(personnage.direction.x, personnage.direction.y * 0.5)
	personnage.velocity = iso.normalized() * personnage.speed
	personnage.move_and_slide()
	personnage._play_walk(personnage._dir8_from_vector(personnage.direction))

func exit() -> void:
	personnage.velocity = Vector2.ZERO

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
