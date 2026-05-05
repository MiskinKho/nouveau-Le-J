extends Resource
class_name Personnage_Data_Chat  # Donnees completes d'un chat : stats + serialisation save/load

@export var nom: String = "Chat"                                   # Nom du chat (affiche dans l'UI)
@export var race: String = "Commun"                                # Race du chat (cosmetique pour l'instant)
@export var combat: Stats_Combat = Stats_Combat.new()              # Sous-ressource combat (PV, force, etc.)
@export var bien_etre: Stats_Bien_Etre = Stats_Bien_Etre.new()    # Sous-ressource bien-etre (faim, energie, etc.)
@export var competences: Array = []                                # Liste de competences (non implemente)

# Serialise en Dictionary JSON-compatible. Delegue aux sous-Resources.
func to_dict() -> Dictionary:
	return {
		"nom": nom,                        # Nom du chat
		"race": race,                      # Race du chat
		"combat": combat.to_dict(),        # Delegation a Stats_Combat
		"bien_etre": bien_etre.to_dict()   # Delegation a Stats_Bien_Etre
	}

# Deserialise un Dictionary. Cree de nouvelles instances pour eviter les references partagees.
func from_dict(data: Dictionary):
	nom = data["nom"]                              # Restaure le nom
	race = data["race"]                            # Restaure la race
	combat = Stats_Combat.new()                    # Nouvelle instance : pas de reference partagee
	combat.from_dict(data["combat"])               # Delegation a Stats_Combat
	bien_etre = Stats_Bien_Etre.new()              # Nouvelle instance : pas de reference partagee
	bien_etre.from_dict(data["bien_etre"])         # Delegation a Stats_Bien_Etre
