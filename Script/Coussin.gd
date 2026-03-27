extends Mobilier  # Hérite de Mobilier (StaticBody2D avec stats_chat et stats_joueur)

@export var bonus_regeneration: float = 2.0  # Multiplicateur de vitesse de régénération d'énergie

# Retourne le multiplicateur de régénération.
# Utilisé potentiellement par d'autres systèmes mais actuellement Etat_Dormir lit directement stats_chat.
func get_bonus() -> float:
	return bonus_regeneration
