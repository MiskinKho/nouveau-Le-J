extends Node

var items: Dictionary = {}  # Item -> quantite
var capacite_max: int = 24
var est_ouvert := false

func to_dict() -> Dictionary:
	var data = {}
	for item in items.keys():
		data[item.nom] = items[item]
	return data

func from_dict(data: Dictionary):
	items.clear()
	for nom in data:
		var item = load("res://Asset/Item/" + nom + ".tres")
		if item:
			items[item] = data[nom]

func ajouter_item(item: Item, quantite: int = 1):
	if items.has(item):
		items[item] += quantite
	else:
		items[item] = quantite

func retirer_item(item: Item, quantite: int = 1) -> bool:
	if not items.has(item) or items[item] < quantite:
		return false
	items[item] -= quantite
	if items[item] <= 0:
		items.erase(item)
	return true

func avoir_item(item: Item) -> int:
	return items.get(item, 0)

func get_inventaire() -> Dictionary:
	return items

func augmenter_capacite(quantite: int = 8):
	capacite_max += quantite
