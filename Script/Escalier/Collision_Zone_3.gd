extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Joueur":
		if body.sas and body.etage == 0: # Etat B → Etat C
			body.etage = 1
			body.set_collision_layer_value(3, true)
			
			print("Etat C")
		elif body.sas and body.etage == 1: # Etat C
			pass
		elif not body.sas and body.etage == 1: # Etat D → Etat C
			body.sas = true
			body.set_collision_mask_value(3, false)
			body.set_collision_mask_value(2, true)
			print("Etat C")
		
