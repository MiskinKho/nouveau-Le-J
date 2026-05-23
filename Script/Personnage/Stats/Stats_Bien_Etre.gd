extends Resource       # Ressource sérialisable : peut être sauvegardée/chargée et partagée
class_name Stats_Bien_Etre  # Type global pour le typage fort dans les autres scripts

@export var faim: float = 0.0        # 0 = rassasié, 100 = affamé (augmente avec le temps via TimeManager)
@export var energie: float = 100.0   # 0 = épuisé, 100 = plein d'énergie (diminue à l'entraînement)
@export var sommeil: float = 100.0   # Réservé (non utilisé activement dans la logique actuelle)
@export var confort: float = 50.0    # Augmente avec le mobilier et les caresses
@export var confiance: float = 50.0  # Augmente quand le joueur caresse le chat (voir Monde.gd)


# Depense de l'energie en restant borne a 0. La Resource gere sa propre mutation (appele par Combat_Manager).
func depenser_energie(cout: float) -> void:
	energie = max(0.0, energie - cout)   # Retire le cout, plancher a 0 (pas d'energie negative)

# Serialise toutes les stats de bien-etre en Dictionary JSON-compatible.
func to_dict() -> Dictionary:
	return {
		"faim": faim,            # Niveau de faim actuel
		"energie": energie,      # Niveau d'energie actuel
		"sommeil": sommeil,      # Niveau de sommeil (reserve)
		"confort": confort,      # Niveau de confort
		"confiance": confiance   # Niveau de confiance envers le joueur
	}

# Deserialise un Dictionary. Utilise get() pour la robustesse des anciennes saves.
func from_dict(data: Dictionary):
	faim = data.get("faim", 0.0)            # Fallback rassasie
	energie = data.get("energie", 100.0)    # Fallback plein d'energie
	sommeil = data.get("sommeil", 100.0)    # Fallback repose
	confort = data.get("confort", 50.0)     # Fallback confort moyen
	confiance = data.get("confiance", 50.0) # Fallback confiance moyenne
