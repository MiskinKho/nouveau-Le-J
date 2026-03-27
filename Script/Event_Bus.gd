extends Node  # Singleton autoload : bus d'événements global (pattern Observer découplé)
			  # Permet à n'importe quel script d'émettre ou d'écouter des événements sans référence directe.

# --- Temps ---
signal heure_changee(heure: float)  # Doublon de TimeManager.heure_change (à unifier si refactor)
signal jour_change(jour: int)

# --- Combat ---
signal combat_demarre(combattant_1, combattant_2, mode)
signal attaque_effectuee(attaquant_nom: String, cible_nom: String, degats: int)
signal combat_termine(victoire: bool)
signal tour_joueur_commence

# --- Créature ---
signal faim_changee(diminution: float)   # Non utilisé (TimeManager.faim_change utilisé à la place)
signal energie_changee(valeur: float)    # Non utilisé (réservé pour futur HUD d'énergie en temps réel)
signal creature_selectionnee(creature)   # Non utilisé (prévu pour sélection multiple de créatures)

# --- Inventaire ---
signal item_ajoute(item, quantite: int)  # Non utilisé (le manager gère directement sans signal)
signal item_retire(item, quantite: int)  # Idem

# --- Interaction ---
signal interaction_demandee(action: String, cible)  # Non utilisé (remplacé par les signaux dédiés)

# --- UI ---
signal menu_ouvert(menu: String)   # Non utilisé
signal menu_ferme(menu: String)    # Non utilisé
signal sauvegarde_demandee         # Émis par les boutons Sauvegarder (HUD, pause)
signal menu_pause_ouvert           # Émis par le bouton Menu du HUD
signal menu_gamelle_ouvert(gamelle) # Émis par un clic sur la gamelle
signal menu_contexte_ouvert(position, cible)  # Émis par clic sur le chat ou touche Entrée
signal hud_chat_visible(visible: bool, cible) # Émis pour afficher/masquer le panel stats du chat

# --- Interaction créature ---
signal entrainement_demande(cible)    # Déclenche la transition + combat d'entraînement
signal caresse_demandee(cible)        # Déclenche la séquence de caresse
signal energie_insuffisante(cible)    # Affiché quand le chat est trop fatigué pour s'entraîner
signal trop_loin(cible)               # Affiché quand le joueur est trop loin pour caresser

signal transition_demandee(depuis, vers, callback)  # Lance la transition fondu + callback post-transition

signal combat_entrainement_termine(creature, gain_pv_max, gain_force)  # Déclenche l'affichage des résultats
signal inventaire_ouvert  # Émis par plusieurs sources pour ouvrir l'inventaire

# --- Étages ---
signal etage_change(etage: int, visible: bool)    # Contrôle la visibilité du layer "Etage 1"
signal faux_etage_change(visible: bool)            # Contrôle la visibilité du layer "FauxEtage"

signal inventaire_visibilite_demandee  # Non utilisé (doublon d'inventaire_ouvert)
var inventaire_visible := false         # État non utilisé dans la logique actuelle
