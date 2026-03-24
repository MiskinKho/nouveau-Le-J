extends Mobilier
@export var bonus_regeneration: float = 2.0  # Multiplicateur de régénération (2x plus vite que par terre)

func get_bonus() -> float:
	return bonus_regeneration
