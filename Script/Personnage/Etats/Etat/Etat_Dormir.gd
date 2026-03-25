extends State
func enter() -> void:
	personnage._play_idle()
	
	
func update(delta: float) -> void:
	personnage.velocity = Vector2.ZERO
	personnage.move_and_slide()
	var seuil = 33.0
	var bonus = 1.0
	if personnage.coussin and personnage.coussin.stats_chat:
		seuil = personnage.coussin.stats_chat.quantite_max_regeneration
		bonus = personnage.coussin.stats_chat.vitesse_regeneration
	
	if personnage.epuise:
		personnage.stats.bien_etre.energie = min(seuil, personnage.stats.bien_etre.energie + delta * bonus)
	
	if personnage.stats.bien_etre.energie >= seuil:
		personnage.epuise = false
		personnage.state_machine._changer_etat("Idle")
	
	
func exit() -> void:
	pass
