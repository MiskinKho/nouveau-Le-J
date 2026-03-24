extends Node
const SAVE_PATH = "user://save.json"

func sauvegarder(creature: Creature):
	var data = {
		"creature": creature.to_dict(),
		"inventaire": InventoryManager.to_dict(),
		"capacite_inventaire": InventoryManager.capacite_max,
		"temps": {
			"jour": TimeManager.jour,
			"heure": TimeManager.heure
		}
	}
	var fichier = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	fichier.store_string(JSON.stringify(data))
	fichier.close()

func charger() -> Creature:
	if not FileAccess.file_exists(SAVE_PATH):
		return null
	var fichier = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(fichier.get_as_text())
	fichier.close()
	
	var creature = Creature.new()
	creature.from_dict(data["creature"])
	
	if data.has("inventaire"):
		InventoryManager.from_dict(data["inventaire"])
	if data.has("capacite_inventaire"):
		InventoryManager.capacite_max = data["capacite_inventaire"]
	if data.has("temps"):
		TimeManager.jour = data["temps"]["jour"]
		TimeManager.heure = data["temps"]["heure"]
	
	return creature
