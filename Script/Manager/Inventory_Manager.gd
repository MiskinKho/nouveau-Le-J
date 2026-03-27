extends Node  # Singleton autoload : une seule instance globale pour tout le jeu

var items: Dictionary = {}   # Clé = ressource Item, Valeur = quantité (int). Accès O(1) par item.
var capacite_max: int = 24   # Nombre max de slots visibles dans l'UI (pas un vrai blocage d'ajout)
var est_ouvert := false       # Flag pour bloquer certaines actions quand l'inventaire est ouvert

# Sérialise l'inventaire en { nom_item: quantité } pour la sauvegarde JSON.
# Utilise le nom comme clé car les objets Resource ne sont pas sérialisables directement en JSON.
func to_dict() -> Dictionary:
	var data = {}
	for item in items.keys():
		data[item.nom] = items[item]
	return data

# Reconstruit l'inventaire depuis un Dictionary JSON en rechargeant les ressources .tres.
func from_dict(data: Dictionary):
	items.clear()
	for nom in data:
		# Charge la ressource par son nom (convention : "res://Asset/Item/{nom}.tres")
		var item = load("res://Asset/Item/" + nom + ".tres")
		if item:
			items[item] = data[nom]  # Ignore silencieusement les items dont le fichier n'existe plus

# Ajoute un item à l'inventaire. Si déjà présent, incrémente la quantité.
func ajouter_item(item: Item, quantite: int = 1):
	if items.has(item):
		items[item] += quantite
	else:
		items[item] = quantite

# Retire une quantité d'un item. Retourne false si l'item est absent ou en quantité insuffisante.
# Supprime l'entrée du dictionnaire quand la quantité tombe à 0.
func retirer_item(item: Item, quantite: int = 1) -> bool:
	if not items.has(item) or items[item] < quantite:
		return false
	items[item] -= quantite
	if items[item] <= 0:
		items.erase(item)  # Nettoie les entrées vides
	return true

# Retourne la quantité disponible d'un item (0 si absent)
func avoir_item(item: Item) -> int:
	return items.get(item, 0)

# Retourne le dictionnaire complet (référence directe — ne pas modifier sans passer par les méthodes)
func get_inventaire() -> Dictionary:
	return items

# Augmente la capacité d'affichage de l'inventaire (débloqué par progression ou achat)
func augmenter_capacite(quantite: int = 8):
	capacite_max += quantite
