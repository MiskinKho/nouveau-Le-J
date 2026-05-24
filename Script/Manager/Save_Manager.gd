extends Node  # Singleton autoload pour la persistance des données de jeu

const SAVE_PATH = "user://save.json"  # Chemin de sauvegarde dans le dossier utilisateur Godot (AppData/Roaming sur Windows)

# Sérialise l'état complet du jeu en JSON et l'écrit sur disque.
# Sauvegarde : créature, inventaire, capacité inventaire, heure et jour.
func sauvegarder(creature: Resource):  # Personnage_Data_Chat en pratique (duck typing : to_dict())
	var data = {
		"creature": creature.to_dict(),                    # Stats complètes de la créature
		"inventaire": InventoryManager.to_dict(),           # Contenu de l'inventaire
		"capacite_inventaire": InventoryManager.capacite_max,
		"temps": {
			"jour": TimeManager.jour,
			"heure": TimeManager.heure                     # Heure fractionnaire (ex: 14.5 = 14h30)
		}
	}
	var fichier = FileAccess.open(SAVE_PATH, FileAccess.WRITE)  # Ouvre/crée le fichier en écriture
	fichier.store_string(JSON.stringify(data))                   # Sérialise en JSON compact
	fichier.close()

# Charge le fichier de sauvegarde et reconstruit l'état du jeu.
# Retourne null si aucune sauvegarde n'existe (première partie).
func charger() -> Resource:  # Retourne Personnage_Data_Chat (seul type sauvegarde actuellement)
	if not FileAccess.file_exists(SAVE_PATH):
		return null  # Pas de sauvegarde : le jeu démarre avec les valeurs par défaut

	var fichier = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(fichier.get_as_text())  # Parse le JSON en Dictionary
	fichier.close()

	# Guard : fichier corrompu, vide ou JSON invalide → parse échoue (null) ou ne renvoie pas un Dictionary
	if data == null or typeof(data) != TYPE_DICTIONARY:
		push_warning("Save_Manager : sauvegarde illisible ou corrompue, démarrage par défaut")  # Avertit sans crasher
		return null  # Traité comme une absence de sauvegarde (même chemin que fichier absent)

	# Guard : structure inattendue (pas de clé créature) → save tronquée ou d'une ancienne version
	if not data.has("creature"):
		push_warning("Save_Manager : sauvegarde sans donnée créature, démarrage par défaut")  # Avertit sans crasher
		return null  # Traité comme une absence de sauvegarde

	var creature = Personnage_Data_Chat.new()  # Le SaveManager ne sauvegarde que les chats actuellement
	creature.from_dict(data["creature"])       # Reconstruit les stats depuis le Dictionary

	# Restaure l'inventaire si présent (compatibilité avec les sauvegardes sans inventaire)
	if data.has("inventaire"):
		InventoryManager.from_dict(data["inventaire"])
	if data.has("capacite_inventaire"):
		InventoryManager.capacite_max = data["capacite_inventaire"]
	if data.has("temps"):
		TimeManager.jour = data["temps"]["jour"]
		TimeManager.heure = data["temps"]["heure"]

	return creature
