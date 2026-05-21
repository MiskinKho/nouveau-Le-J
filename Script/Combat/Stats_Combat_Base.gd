extends Resource                            # Resource serialisable : peut etre stockee en .tres et partagee
class_name Stats_Combat_Base                      # Type global pour le typage fort dans Stats_Combat

# Donnees de race partagees entre tous les individus d'une meme race.
# Plusieurs Stats_Combat peuvent referencer la meme Race_Combat (archetype partage).
# Modifier le .tres → tous les chats de cette race sont impactes instantanement.

@export var nom_race: String = "Inconnue"   # Nom affichable de la race (pour encyclopedie)
@export var pv_max_base: int = 50           # Points de vie maximum de base de la race
@export var force_base: int = 10            # Force d'attaque de base de la race
@export var defense_base: int = 5           # Defense de base de la race
