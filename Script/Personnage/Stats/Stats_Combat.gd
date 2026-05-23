extends Resource
class_name Stats_Combat  # Stats de combat d'un combattant (chat, joueur, ennemi)

@export var base: Stats_Combat_Base = null   # Archetype de race (PV/force/defense de base) — assigne par setup() via RaceRegistry
@export var pv_actuel: int = 0               # Points de vie actuels (runtime) — rempli par setup() a la creation
@export var bonus_pv_max: int = 0            # Bonus permanents de PV max accumules par l'individu (entrainement)
@export var bonus_force: int = 0             # Bonus permanents de force accumules par l'individu
@export var bonus_defense: int = 0           # Bonus permanents de defense accumules par l'individu

# Branche la race et remplit les PV au maximum. Point d'entree unique a la creation d'un combattant.
func setup(race: Stats_Combat_Base) -> void:
	base = race                              # Assigne l'archetype de race (source unique : RaceRegistry)
	pv_actuel = get_pv_max()                 # Demarre a pleins PV (base prete, get_pv_max() fiable)

# Applique des degats : retire les PV en restant borne a 0. Centralise la mutation des PV (auparavant dispersee dans Combat_Manager).
func subir_degats(degats: int) -> void:
	pv_actuel = max(0, pv_actuel - degats)   # Retire les degats, plancher a 0 (pas de PV negatifs)

# True si le combattant est hors combat (PV epuises). Point d'extension futur (bouclier, esquive).
func est_ko() -> bool:
	return pv_actuel <= 0                    # KO des que les PV atteignent 0

# Restaure les PV au maximum reel (base de race + bonus). Appele en fin d'entrainement.
func restaurer_pv() -> void:
	pv_actuel = get_pv_max()                 # Remet a pleins PV en tenant compte des bonus

# Applique les gains permanents d'un entrainement (bonus individuels, la race reste intacte).
func appliquer_gain_entrainement(gain_pv_max: int, gain_force: int) -> void:
	bonus_pv_max += gain_pv_max              # Ajoute le gain de PV max au bonus individuel
	bonus_force += gain_force                # Ajoute le gain de force au bonus individuel

# PV maximum reel : base de race + bonus accumules par l'individu.
func get_pv_max() -> int:
	return base.pv_max_base + bonus_pv_max   # Somme race + bonus individuels

# Force reelle : base de race + bonus accumules.
func get_force() -> int:
	return base.force_base + bonus_force     # Somme race + bonus individuels

# Defense reelle : base de race + bonus accumules.
func get_defense() -> int:
	return base.defense_base + bonus_defense # Somme race + bonus individuels

# Serialise uniquement le runtime + l'id de race. Les valeurs de base ne sont PAS sauvees (elles vivent dans le .tres).
func to_dict() -> Dictionary:
	return {
		"race_id": RaceManager.get_id(base),  # Id stable de la race (pour retrouver le .tres au chargement)
		"pv_actuel": pv_actuel,                # Points de vie actuels
		"bonus_pv_max": bonus_pv_max,          # Bonus PV max accumules
		"bonus_force": bonus_force,            # Bonus force accumules
		"bonus_defense": bonus_defense         # Bonus defense accumules
	}

# Deserialise un Dictionary. Restaure la race via son id, puis le runtime. get() pour robustesse.
func from_dict(data: Dictionary):
	base = RaceManager.get_race(data.get("race_id", ""))  # Recharge l'archetype depuis l'id (null si id inconnu)
	pv_actuel = data.get("pv_actuel", 0)                   # Fallback 0
	bonus_pv_max = data.get("bonus_pv_max", 0)             # Fallback 0
	bonus_force = data.get("bonus_force", 0)               # Fallback 0
	bonus_defense = data.get("bonus_defense", 0)           # Fallback 0
