extends Resource       # Ressource sérialisable : peut être sauvegardée/chargée et partagée
class_name Stats_Bien_Etre  # Type global pour le typage fort dans les autres scripts

@export var faim: float = 0.0        # 0 = rassasié, 100 = affamé (augmente avec le temps via TimeManager)
@export var energie: float = 100.0   # 0 = épuisé, 100 = plein d'énergie (diminue à l'entraînement)
@export var sommeil: float = 100.0   # Réservé (non utilisé activement dans la logique actuelle)
@export var confort: float = 50.0    # Augmente avec le mobilier et les caresses
@export var confiance: float = 50.0  # Augmente quand le joueur caresse le chat (voir Monde.gd)
