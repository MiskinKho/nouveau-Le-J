extends CompDeplacement       # Spécialise CompDeplacement pour les PNJ contrôlés par l'IA
class_name CompDeplacementIA

# TODO : Ce composant n'est pas encore câblé dans les scènes (.tscn).
# Pour l'activer : ajouter un noeud CompDeplacementIA comme enfant du CharacterBody2D dans l'éditeur,
# puis y reparenter le NavigationAgent2D, et faire déléguer PNJ._choisir_direction / _se_deplacer_vers ici.
# En attendant, l'implémentation canonique reste dans PNJ.gd.
