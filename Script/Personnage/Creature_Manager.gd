extends Node

var chat_node: CharacterBody2D

func initialiser(chat: CharacterBody2D):
	chat_node = chat
	TimeManager.faim_change.connect(_on_faim_change)
	TimeManager.jour_change.connect(_on_nouveau_jour)

func _on_faim_change(diminution: float):
	if chat_node and not chat_node.mange:
		chat_node.statss.bien_etre.faim = min(100.0, chat_node.statss.bien_etre.faim + diminution)

func _on_nouveau_jour(_jour):
	if chat_node:
		chat_node.statss.bien_etre.energie = 100
		SaveManager.sauvegarder(chat_node.stats)

func entrainer(cible):
	if cible.statss.bien_etre.energie < 5:
		EventBus.energie_insuffisante.emit(cible)
		return
	EventBus.entrainement_demande.emit(cible)

func caresser(cible):
	EventBus.caresse_demandee.emit(cible)
