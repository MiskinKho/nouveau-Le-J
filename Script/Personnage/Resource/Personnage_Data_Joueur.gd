extends Resource
class_name Personnage_Data_Joueur  # Donnees du joueur

@export var nom: String = "Joueur"                                 # Nom du joueur
@export var combat: Stats_Combat = Stats_Combat.new()              # Sous-ressource combat (PV, force, etc.)

# Serialise en Dictionary JSON-compatible. Delegue a Stats_Combat.
func to_dict() -> Dictionary:
	return {
		"nom": nom,                        # Nom du joueur
		"combat": combat.to_dict()         # Delegation a Stats_Combat
	}

# Deserialise un Dictionary. Cree une nouvelle instance pour eviter les references partagees.
func from_dict(data: Dictionary):
	nom = data["nom"]                              # Restaure le nom
	combat = Stats_Combat.new()                    # Nouvelle instance : pas de reference partagee
	combat.from_dict(data["combat"])               # Delegation a Stats_Combat
