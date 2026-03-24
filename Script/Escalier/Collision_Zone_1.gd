extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.name == "Joueur":
		if not body.sas and body.etage == 0: # Etat A
			body.set_collision_layer_value(2, true)
			print("Etat A")

		elif body.sas and body.etage == 0: # Etat B → Etat A
			body.sas = false
			body.set_collision_mask_value(1, true)
			body.set_collision_mask_value(2, false)

			print("Etat A")
