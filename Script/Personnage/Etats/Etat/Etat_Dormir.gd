extends State  # État de sommeil : régénère l'énergie jusqu'à un seuil, puis réveille le chat

func enter() -> void:
	personnage._play_idle()  # Animation statique pendant le sommeil (pas d'animation dédiée)
	print("DORMIR ENTER")
func update(delta: float) -> void:
	personnage.velocity = Vector2.ZERO  # Aucun mouvement pendant le sommeil
	personnage.move_and_slide()

	var seuil = 33.0   # Énergie cible par défaut (récupération partielle, pas totale)
	var bonus = 1.0    # Multiplicateur de vitesse de régénération (1 = standard)

	# Si le chat est sur un coussin avec des stats configurées, utilise ses bonus
	if personnage.coussin and personnage.coussin.stats_chat:
		seuil = personnage.coussin.stats_chat.quantite_max_regeneration  # Ex: 50 sur coussin
		bonus = personnage.coussin.stats_chat.vitesse_regeneration        # Ex: 2x plus vite

	# Régénère uniquement si le chat est marqué comme épuisé (évite la régénération infinie)

		# min() pour ne pas dépasser le seuil configuré
	personnage.stats.bien_etre.energie = min(seuil, personnage.stats.bien_etre.energie + delta * bonus)
	print("energie: ", personnage.stats.bien_etre.energie)
	# Seuil atteint : le chat s'est suffisamment reposé, retour à l'idle
	if personnage.stats.bien_etre.energie >= seuil:
		personnage.epuise = false
		personnage.state_machine._changer_etat("Idle")

func exit() -> void:
	pass
