extends CompDeplacement           # Spécialise CompDeplacement pour le personnage joueur
class_name CompDeplacementJoueur  # Note : ce composant existe mais Joueur.gd gère le déplacement directement.
								  # À intégrer si refactor de Joueur.gd vers architecture par composants.

# Lit l'input clavier/manette et applique le déplacement ou l'arrêt.
# Utilise get_vector() qui retourne un vecteur normalisé diagonal automatiquement.
func traiter_deplacement() -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input == Vector2.ZERO:
		arreter()
	else:
		deplacer(input)



# Retourne uniquement le vecteur d'input sans l'appliquer (utile pour les animations, checks, etc.)
func get_direction() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
