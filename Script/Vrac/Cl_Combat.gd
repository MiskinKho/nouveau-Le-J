extends Node  # Nœud de scène : gère la mise en scène du combat au niveau des nœuds (CombatManager gère les règles sur les Resources)
class_name ClCombat

@export var ecart_combattants: float = 60.0  # Demi-distance entre les deux combattants une fois placés, réglable dans l'éditeur

# Calcule les positions de combat des deux combattants et délègue le déplacement à chacun.
# Ne déplace personne directement : décide les destinations, chaque personnage exécute via son composant.
func calcul_position_combat(combattant_a: Personnage, combattant_b: Personnage) -> void:
	var centre = (combattant_a.global_position + combattant_b.global_position) / 2  # Point médian entre les deux positions actuelles
	var pos_a = centre + Vector2(-ecart_combattants, 0)       # Destination du premier combattant, à gauche du centre
	var pos_b = centre + Vector2(ecart_combattants, 0)        # Destination du second combattant, à droite du centre
	combattant_a.comp_deplacement.positionner(pos_a, pos_b)   # A se positionne et regarde vers la position de B
	combattant_b.comp_deplacement.positionner(pos_b, pos_a)   # B se positionne et regarde vers la position de A
