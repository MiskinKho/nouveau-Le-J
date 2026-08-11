extends Node                                                                                # Composant simple — pas de physique, pas de rendu
class_name CompAnimation                                                                    # Nom global pour usage dans les types

# Référence à l'AnimationPlayer du Personnage parent — assigné après instanciation
@onready var anim_player: AnimationPlayer = get_parent().get_node("AnimationPlayer")

# Dernière direction connue (1 des 8 cardinales) — utilisée quand jouer_idle() est appelé sans argument
var last_dir: String = "S"

# Lance l'anim Idle dans la direction donnée (ou la dernière connue si vide)
func jouer_idle(dir: String = "") -> void:
	var d: String = dir if dir != "" else last_dir                          # Détermine la direction à utiliser
	last_dir = d                                                            # Mémorise pour les futurs appels sans argument
	_jouer_si_existe("Idle_" + d)                                           # Joue Idle_E / Idle_NE / etc. si l'anim existe

# Lance l'anim Walk dans la direction du vecteur donné
func jouer_walk(vec: Vector2) -> void:                                      # vec = direction de marche (non normalisé est OK)
	last_dir = _vector_to_dir(vec)                                          # Convertit le vecteur en direction texte et mémorise
	_jouer_si_existe("Walk_" + last_dir)                                    # Joue Walk_E / Walk_NE / etc. si l'anim existe

# Lance l'anim Attaque dans la direction donnée, awaitable jusqu'à la fin de l'anim
func jouer_atk(dir: String = "") -> void:                                   # dir optionnel
	var d: String = dir if dir != "" else last_dir                          # Détermine la direction à utiliser
	last_dir = d                                                            # Mémorise
	var nom: String = "ATK_" + d                                            # Nom de l'anim attendue (ex: ATK_SE)
	if anim_player.has_animation(nom):                                      # Si l'anim existe (ex: pas pour les chats qui n'ont pas d'ATK)
		anim_player.play(nom)                                               # Joue (toujours redémarrer pour une attaque)
		await anim_player.animation_finished                                # Attend la fin de l'anim avant de rendre la main à l'appelant

# Conversion vecteur → direction texte (8 directions) — exposée pour les appelants qui en ont besoin
func vector_to_dir(v: Vector2) -> String:
	return _vector_to_dir(v)                                                # Délègue à la fonction interne

# --- Interne ---

# Joue une animation seulement si elle existe et n'est pas déjà en train de jouer.
# Évite les redémarrages permanents quand jouer_walk/idle est appelée chaque frame avec la même direction.
func _jouer_si_existe(nom: String) -> void:
	if get_parent() is Joueur:
		print("Demande anim: ", nom, " | existe: ", anim_player.has_animation(nom))
	if anim_player.has_animation(nom):                                      # Vérifie l'existence (certaines directions peuvent manquer selon le perso)
		if anim_player.current_animation != nom:                            # Pas déjà en train de jouer → on lance (sinon on laisse défiler)
			anim_player.play(nom)

# Conversion vecteur → direction texte (8 directions cardinales/diagonales).
# Logique identique à l'ancien _dir8_from_vector de Personnage.gd.
func _vector_to_dir(v: Vector2) -> String:
	if v == Vector2.ZERO:                                                   # Cas du vecteur nul
		return last_dir                                                     # Garde la dernière direction connue
	var ang: float = v.angle()                                              # Angle en radians (0 = Est, PI/2 = Sud en 2D Godot)
	var idx: int = int(round(ang / (PI / 4.0))) & 7                         # Index 0-7 sur le cercle, & 7 fait le modulo 8
	var dirs: Array[String] = ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]  # Table des 8 directions dans le sens trigo (depuis E)
	return dirs[idx]                                                        # Retourne la direction correspondante
