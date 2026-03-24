extends Node
class_name State

# Référence au chat, assignée par la StateMachine au démarrage
var personnage: Personnage

func enter() -> void:
	pass # Ce qui se passe quand on entre dans cet état

func update(delta: float) -> void:
	pass # Ce qui se passe chaque frame

func exit() -> void:
	pass # Ce qui se passe quand on quitte cet état
