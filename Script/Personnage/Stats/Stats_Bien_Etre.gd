extends Resource       # Ressource sérialisable : peut être sauvegardée/chargée et partagée
class_name Stats_Bien_Etre  # Type global pour le typage fort dans les autres scripts

@export var faim: float = 0.0        # 0 = rassasié, 100 = affamé (augmente avec le temps via TimeManager)
@export var energie: float = 100.0   # 0 = épuisé, 100 = plein d'énergie (diminue à l'entraînement)
@export var sommeil: float = 100.0   # Réservé (non utilisé activement dans la logique actuelle)
@export var confort: float = 50.0    # Augmente avec le mobilier et les caresses
@export var confiance: float = 50.0  # Augmente quand le joueur caresse le chat (voir Monde.gd)



func depenser_energie(cout: float) -> void: # Depense de l'energie en restant borne a 0.
	energie = max(0.0, energie - cout)   # Retire le cout, plancher a 0 (pas d'energie negative)


func recevoir_caresse(gain: float = 5.0) -> void: # Applique le gain de confiance d'une caresse.
	confiance = min(100.0, confiance + gain)  # Ajoute le gain en plafonnant à 100


func to_dict() -> Dictionary:    # Serialise toutes les stats de bien-etre en Dictionary JSON-compatible.
	return {
		"faim": faim,            # Niveau de faim actuel
		"energie": energie,      # Niveau d'energie actuel
		"sommeil": sommeil,      # Niveau de sommeil (reserve)
		"confort": confort,      # Niveau de confort
		"confiance": confiance   # Niveau de confiance envers le joueur
	}

func from_dict(data: Dictionary):  # Deserialise un Dictionary. Utilise get() pour la robustesse des anciennes saves.
	faim = data.get("faim", 0.0)            # Fallback rassasie
	energie = data.get("energie", 100.0)    # Fallback plein d'energie
	sommeil = data.get("sommeil", 100.0)    # Fallback repose
	confort = data.get("confort", 50.0)     # Fallback confort moyen
	confiance = data.get("confiance", 50.0) # Fallback confiance moyenne
