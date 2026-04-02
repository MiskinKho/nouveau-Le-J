extends StateBienEtre  # État actif pendant que le chat mange à la gamelle

func enter() -> void:
	personnage.mange = true  # Flag utilisé par CreatureManager pour ne pas augmenter la faim pendant ce temps

func update(delta: float) -> void:
	personnage.velocity = Vector2.ZERO   # Immobile pendant le repas
	personnage.move_and_slide()
	personnage._play_idle()              # Animation statique (pas d'animation de manger dédiée)

	var unite_mangee = delta * 1.0       # Quantité consommée par seconde (1 unité/s)
	personnage.gamelle.manger(unite_mangee)                                    # Retire de la gamelle
	personnage.stats.bien_etre.faim = max(0.0, personnage.stats.bien_etre.faim - unite_mangee)  # Réduit la faim

	# Rassasié (faim < 20) : retour à l'idle
	if personnage.stats.bien_etre.faim <= 20.0:
		personnage.state_machine._changer_etat("Idle")
	# Gamelle vidée en cours de repas : retour à l'idle
	if not personnage.gamelle or personnage.gamelle.nourriture <= 0:
		personnage.state_machine._changer_etat("Idle")

func exit() -> void:
	personnage.mange = false  # Réactive l'accumulation de faim dans CreatureManager
