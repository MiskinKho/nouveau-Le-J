extends StaticBody2D  # Objet de décor statique interactif (coussin, meuble, etc.)
class_name Mobilier   # Classe de base pour tous les meubles

@export var nom: String = ""                          # Nom affiché (non utilisé dans l'UI actuelle)
@export var stats_chat: Stats_Mobilier_Chat           # Stats du mobilier pour le chat (énergie, confort, etc.)
@export var stats_joueur: Stats_Mobilier_Joueur       # Stats du mobilier pour le joueur (non utilisées activement)
