extends Personnage  # Le joueur hérite de Personnage (animations, déplacement iso, stats)
class_name Joueur

@onready var pas_bois: AudioStreamPlayer2D = $AudioListener2D  # Son de pas, joué sur les frames 2 et 5 de Walk
@export var tilemap_sol: TileMapLayer  # TileMap du sol pour détecter le type de surface sous les pieds
@export var chat: CharacterBody2D      # Référence au chat (pour le menu contextuel à proximité)

# Initialisation du joueur : instancie sa Resource specifique si aucune n'est assignee dans l'editeur
func _ready():
	super()  # Appelle Personnage._ready() pour connecter les signaux combat (en_combat auto-géré)
	if stats == null:
		stats = Personnage_Data_Joueur.new()  # Instancie la Resource specifique joueur
	stats.combat.setup(RaceRegistre.get_race("joueur"))  # Branche la race + remplit les PV au max
	print("DEBUG race joueur = ", stats.combat.base)
# Étage actuel du joueur (0 = rez-de-chaussée, 1 = étage).
# Le setter gère les changements de calques de collision et la visibilité des couches.
var etage := 0:
	set(value):
		etage = value
		if value == 1 and sas:          # Monte à l'étage en passant par le sas
			EventBus.faux_etage_change.emit(true)
		if value == 0 and sas:          # Redescend en passant par le sas
			z_index = 2
			EventBus.faux_etage_change.emit(false)

# Sas de transition d'étage : état intermédiaire où le joueur est sur l'escalier.
# Le setter ajuste z_index et émet les signaux de visibilité des couches.
var sas := false:
	set(value):
		sas = value
		if not sas and etage == 0:      # Etat A : rez-de-chaussée normal
			z_index = 0
		elif sas and etage == 0:        # Etat B : en bas de l'escalier, devant le mur
			z_index = 2
		elif not sas and etage == 1:    # Etat D : à l'étage, hors sas
			z_index = 3
			EventBus.faux_etage_change.emit(false)
			EventBus.etage_change.emit(etage, true)
		elif sas and etage == 1:        # Etat C : à l'étage, dans le sas
			z_index = 2
			EventBus.etage_change.emit(etage, false)
			EventBus.faux_etage_change.emit(true)

# Chaque frame : détecte la touche Entrée pour interagir avec le chat proche
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and not en_combat:
		if global_position.distance_to(chat.global_position) < 50:
			# Ouvre le menu contextuel à la position écran du chat (transformée canvas → écran)
			EventBus.menu_contexte_ouvert.emit(
				get_viewport().get_canvas_transform() * chat.global_position, chat)

# Callback de changement de frame d'animation : déclenche le son de pas aux bonnes frames
func _on_animated_sprite_2d_frame_changed():
	if sprite.animation.begins_with("Walk"):
		if sprite.frame == 2 or sprite.frame == 5:  # Frames de contact du pied avec le sol
			_play_footstep()

# Joue un son de pas adapté à la surface sous le joueur (détection via TileMap)
func _play_footstep():
	var tile_pos = tilemap_sol.local_to_map(tilemap_sol.to_local(global_position))  # Coordonnées de tuile
	var _tile_data = tilemap_sol.get_cell_tile_data(tile_pos)  # Données de la tuile (non utilisées ici, prévu pour variations)
	pas_bois.play()  # Joue le son de pas bois (seul son implémenté pour l'instant)

# Repositionne le joueur à une distance fixe d'une cible avant un combat automatique.
# Si le joueur est trop proche, recule jusqu'à atteindre distance_cible, puis tourne face à la cible.
# Posé/retire le flag en_repositionnement pour bloquer Comp_Deplacement_Joueur pendant l'opération.
func repositionner_pour_combat(cible: Node2D) -> void:
	var distance_cible = 112.0                                                # Distance souhaitée entre joueur et cible avant combat
	var distance_actuelle = global_position.distance_to(cible.global_position)  # Distance actuelle
	en_repositionnement = true                                                # Bloque l'input/déplacement normal pendant le repositionnement
	if distance_actuelle < distance_cible:                                    # Trop proche : recule
		var direction_recul = (global_position - cible.global_position).normalized()  # Vecteur de fuite normalisé
		while global_position.distance_to(cible.global_position) < distance_cible:    # Recule tant que pas assez loin
			velocity = Vector2(direction_recul.x, direction_recul.y * 0.5) * 100.0    # Projection iso (y * 0.5) + vitesse 100
			move_and_slide()                                                  # Applique la physique
			_play_walk(_dir8_from_vector(direction_recul))                    # Animation de marche dans la direction du recul
			await get_tree().process_frame                                    # Cède la main, prochain frame physique
	var direction_ennemi = (cible.global_position - global_position).normalized()  # Vecteur joueur → cible (pour orientation finale)
	var dir = _dir8_from_vector(direction_ennemi)                             # Direction sur 8 points cardinaux
	_play_idle(dir)                                                           # Idle face à la cible
	last_dir = dir                                                            # Mémorise la direction (pour les anims suivantes)
	await get_tree().create_timer(0.3).timeout                                # Petit délai pour la lisibilité avant le combat
	en_repositionnement = false                                               # Libère le déplacement normal

# Joue l'animation d'attaque du joueur, attend qu'elle se termine et retourne en Idle.
# Utilisée par Ui_Combat lors d'une attaque en mode JOUEUR (entraînement).
func jouer_animation_attaque() -> void:
	sprite.play("ATK SE")                                                     # Animation d'attaque (direction SE en dur, à généraliser plus tard via last_dir)
	await sprite.animation_finished                                           # Bloque jusqu'à la fin de l'animation
	sprite.play("Idle " + last_dir)                                           # Retour à l'idle dans la dernière direction
