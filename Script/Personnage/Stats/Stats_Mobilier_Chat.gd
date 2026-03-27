extends Resource
class_name Stats_Mobilier_Chat  # Bonus apportés par un meuble au chat qui l'utilise

@export var bonus_energie: float = 1.0           # Bonus à la régénération d'énergie (non utilisé directement, voir vitesse_regeneration)
@export var bonus_confort: float = 0.0
@export var bonus_confiance: float = 0.0
@export var vitesse_regeneration: float = 2.0    # Multiplicateur de vitesse : lu par Etat_Dormir (delta * bonus)
@export var quantite_max_regeneration: float = 50.0  # Plafond d'énergie récupérée sur ce meuble (ex: 50 = récupère jusqu'à 50%, pas 100%)
