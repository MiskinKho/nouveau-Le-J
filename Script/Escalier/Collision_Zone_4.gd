extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.name == "Joueur":
		if body.sas and body.etage == 1: # Etat C → Etat D
			body.sas = false
			body.set_collision_mask_value(2, false)
			body.set_collision_mask_value(3, true)


			print("Etat D")
			
