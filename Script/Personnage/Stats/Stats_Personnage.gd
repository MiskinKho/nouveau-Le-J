extends Resource
class_name Creature  # Ressource complète d'un personnage : stats + sérialisation save/load

@export var nom: String = "Chat"
@export var race: String = "Commun"
@export var combat: Stats_Combat = Stats_Combat.new()            # Sous-ressource combat (PV, force, etc.)
@export var bien_etre: Stats_Bien_Etre = Stats_Bien_Etre.new()  # Sous-ressource bien-être (faim, énergie, etc.)
@export var competences: Array = []   # Liste de compétences (non implémenté)

# Sérialise la créature en Dictionary JSON-compatible pour la sauvegarde.
func to_dict() -> Dictionary:
	return {
		"nom": nom,
		"race": race,
		"combat": {                       # Aplatit les sous-ressources en dictionnaires simples
			"niveau": combat.niveau,
			"experience": combat.experience,
			"pv_max": combat.pv_max,
			"pv_actuel": combat.pv_actuel,
			"force": combat.force,
			"agilite": combat.agilite,
			"precision": combat.precision,
			"defense": combat.defense
		},
		"bien_etre": {
			"faim": bien_etre.faim,
			"energie": bien_etre.energie,
			"sommeil": bien_etre.sommeil,
			"confort": bien_etre.confort,
			"confiance": bien_etre.confiance
		}
	}

# Désérialise un Dictionary (issu du JSON) pour reconstruire la créature.
# Crée de nouvelles instances de Stats_Combat et Stats_Bien_Etre pour éviter les références partagées.
func from_dict(data: Dictionary):
	nom = data["nom"]
	race = data["race"]
	combat = Stats_Combat.new()              # Nouvelle instance : pas de référence partagée avec une autre créature
	combat.niveau = data["combat"]["niveau"]
	combat.experience = data["combat"]["experience"]
	combat.pv_max = data["combat"]["pv_max"]
	combat.pv_actuel = data["combat"]["pv_actuel"]
	combat.force = data["combat"]["force"]
	combat.agilite = data["combat"]["agilite"]
	combat.precision = data["combat"]["precision"]
	combat.defense = data["combat"]["defense"]
	bien_etre = Stats_Bien_Etre.new()
	bien_etre.faim = data["bien_etre"]["faim"]
	bien_etre.energie = data["bien_etre"]["energie"]
	bien_etre.sommeil = data["bien_etre"]["sommeil"]
	bien_etre.confort = data["bien_etre"]["confort"]
	bien_etre.confiance = data["bien_etre"]["confiance"]
