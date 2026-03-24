extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Joueur":
		if not body.sas and body.etage == 0: # Etat A → Etat B
			body.sas = true
			body.set_collision_mask_value(1, false)
			body.set_collision_mask_value(2, true)
			print("Etat B")
		elif body.sas and body.etage == 1: # Etat C → Etat B
			body.etage = 0
			 
			print("Etat B")
