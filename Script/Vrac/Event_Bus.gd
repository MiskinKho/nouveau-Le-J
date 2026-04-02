extends Node  # Singleton autoload : bus d'événements global (pattern Observer découplé)
			  # Permet à n'importe quel script d'émettre ou d'écouter des événements sans référence directe.

# --- Temps ---
signal heure_changee(heure: float)
signal jour_change(jour: int)

# --- Combat ---
signal combat_demarre(combattant_1, combattant_2, mode)
signal attaque_effectuee(attaquant_nom: String, cible_nom: String, degats: int)
signal combat_termine(victoire: bool)
signal tour_joueur_commence

# --- UI ---
signal sauvegarde_demandee         # Émis par les boutons Sauvegarder (HUD, pause)
signal menu_pause_ouvert           # Émis par le bouton Menu du HUD
signal menu_gamelle_ouvert(gamelle) # Émis par un clic sur la gamelle
signal menu_contexte_ouvert(position, cible)  # Émis par clic sur le chat ou touche Entrée
signal hud_chat_visible(visible: bool, cible) # Émis pour afficher/masquer le panel stats du chat
signal inventaire_ouvert  # Émis par plusieurs sources pour ouvrir l'inventaire

# --- Interaction créature ---
signal entrainement_demande(cible)    # Déclenche la transition + combat d'entraînement
signal caresse_demandee(cible)        # Déclenche la séquence de caresse
signal energie_insuffisante(cible)    # Affiché quand le chat est trop fatigué pour s'entraîner
signal trop_loin(cible)               # Affiché quand le joueur est trop loin pour caresser

# --- Transition ---
signal transition_demandee(depuis, vers, callback)  # Lance la transition fondu + callback post-transition
signal combat_entrainement_termine(creature, gain_pv_max, gain_force)  # Déclenche l'affichage des résultats

# --- Étages ---
signal etage_change(etage: int, visible: bool)    # Contrôle la visibilité du layer "Etage 1"
signal faux_etage_change(visible: bool)            # Contrôle la visibilité du layer "FauxEtage"
