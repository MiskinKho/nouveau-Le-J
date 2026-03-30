extends Node  # Singleton autoload : gère le cycle de vie des besoins du chat

var chat_node: CharacterBody2D  # Référence au noeud Chat dans la scène

# Initialise le manager avec le noeud chat et connecte les signaux du TimeManager.
func initialiser(chat: CharacterBody2D):
	chat_node = chat
	TimeManager.faim_change.connect(_on_faim_change)  # Reçoit chaque frame la portion de faim
	TimeManager.jour_change.connect(_on_nouveau_jour) # Reçoit le changement de jour

# Augmente la faim du chat chaque frame, proportionnellement au temps écoulé in-game.
# Guard : ne pas augmenter si le chat est en train de manger (il gère sa faim lui-même dans Etat_Manger).
func _on_faim_change(diminution: float):
	if chat_node and not chat_node.mange:
		# min(100, ...) pour plafonner la faim à 100
		chat_node.stats.bien_etre.faim = min(100.0, chat_node.stats.bien_etre.faim + diminution)

# Au nouveau jour : restaure l'énergie à 100 et sauvegarde automatiquement.
func _on_nouveau_jour(_jour):
	if chat_node:
		chat_node.stats.bien_etre.energie = 100  # Nouvelle journée = nuit de récupération complète
		SaveManager.sauvegarder(chat_node.stats)

# Lance une tentative d'entraînement sur la cible.
# Vérifie d'abord que l'énergie est suffisante.
func entrainer(cible):
	if cible.stats.bien_etre.energie < 1:
		EventBus.energie_insuffisante.emit(cible)  # Signal pour afficher un message au joueur
		return
	EventBus.entrainement_demande.emit(cible)  # Déclenche la transition et le combat

# Déclenche une caresse sur la cible (délègue à Monde.gd via EventBus).
func caresser(cible):
	EventBus.caresse_demandee.emit(cible)
