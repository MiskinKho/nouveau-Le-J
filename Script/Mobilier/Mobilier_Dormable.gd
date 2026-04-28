extends Mobilier             # Hérite de Mobilier (StaticBody2D avec stats)
class_name MobilierDormable  # Classe de base pour tous les meubles où un PNJ peut dormir

@onready var zone_occupation: Area2D = $ZoneOccupation  # Zone physique qui détecte les PNJ sur le meuble

func _ready() -> void:
	add_to_group("mobilier_sommeil")  # Inscrit le meuble dans le groupe utilisé par le BT pour trouver où dormir

# Retourne true si le Personnage donné est physiquement dans la ZoneOccupation du meuble
func est_occupe_par(personnage: Personnage) -> bool:
	return personnage in zone_occupation.get_overlapping_bodies()
