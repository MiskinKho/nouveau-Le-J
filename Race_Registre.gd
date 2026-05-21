extends Node                                                                          # Autoload : noeud global accessible partout via RaceRegistry

# Table centrale id → archetype de race (Stats_Combat_Base).
# Point unique pour : sauvegarde par id, chargement, et listing des races (encyclopedie future).
# Renommer un .tres → mettre a jour UNE ligne ici, les saves continuent de marcher.

const RACES := {                                                                      # Dictionnaire id → Resource prechargee
	"chat_commun": preload("res://resource/stats_combat_base/stats_combat_base_chat_commun.tres"),  # Race du chat commun
	"souris": preload("res://resource/stats_combat_base/stats_combat_base_souris.tres"),            # Race de la souris
	"joueur": preload("res://resource/stats_combat_base/stats_combat_base_joueur.tres"),            # "Race" du joueur
}

# Retourne l'archetype de race correspondant a un id, ou null si id inconnu.
func get_race(id: String) -> Stats_Combat_Base:
	return RACES.get(id)                                                              # .get() renvoie null si la cle n'existe pas

# Retourne l'id correspondant a un archetype de race, ou "" si introuvable.
func get_id(race: Stats_Combat_Base) -> String:
	var cle = RACES.find_key(race)                                                    # find_key cherche la cle par valeur (comparaison par reference)
	return cle if cle != null else ""                                                 # Renvoie "" plutot que null pour un type de retour String stable
