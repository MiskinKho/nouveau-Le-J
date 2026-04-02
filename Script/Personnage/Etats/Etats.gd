extends Node          # Hérite de Node, classe de base légère sans transformation
class_name State      # Déclare le type global "State" utilisable partout dans le projet

# Référence au personnage propriétaire de cette machine à états.
# Assignée par StateMachine._ready() pour que chaque état puisse piloter le personnage.
var personnage: Personnage
var duree := 0.0  # Durée restante en secondes avant de choisir le prochain état
# Appelée une fois quand on entre dans cet état (ex: lancer une animation, choisir direction).

# Table de probabilité pour le prochain état après la durée de marche.
# Équilibre 50/50 entre continuer à marcher ou s'arrêter.
const POIDS = {
	"Marcher": 50,
	"Idle": 50
}

func enter() -> void:
	pass

# Appelée chaque frame physique par StateMachine._physics_process().
# delta = temps écoulé depuis la frame précédente, en secondes.
func update(delta: float) -> void:
	pass

# Appelée une fois quand on quitte cet état (ex: arrêter une animation, remettre velocity à zéro).
func exit() -> void:
	pass

# Vérifie les stats vitales — implémentation dans StateBienEtre.
# Les états qui ne sont pas de type bien-être n'ont pas besoin de cette vérification.
func _verifier_vitaux() -> bool:
	return false

# Tire au sort le prochain état selon un dictionnaire de poids probabilistes.
# poids : { "NomEtat": int } — plus la valeur est haute, plus l'état est probable.
# Ex: { "Marcher": 30, "Idle": 70 } → 70% de chances de rester Idle.
func _choisir_prochain(poids: Dictionary) -> String:
	var total := 0
	for p in poids.values():   # Calcule la somme totale des poids
		total += p
	var tirage := randi() % total  # Nombre aléatoire entre 0 et total-1
	var cumul := 0
	for etat in poids:             # Parcourt les états dans l'ordre d'insertion
		cumul += poids[etat]       # Cumule les poids pour trouver le bon intervalle
		if tirage < cumul:
			return etat            # L'état dont l'intervalle contient le tirage est choisi
	return "Idle"                  # Fallback de sécurité (ne devrait jamais être atteint)
