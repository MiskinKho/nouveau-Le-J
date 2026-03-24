extends Node

# Temps
signal heure_changee(heure: float)
signal jour_change(jour: int)

# Combat
signal combat_demarre(combattant_1, combattant_2, mode)
signal attaque_effectuee(attaquant_nom: String, cible_nom: String, degats: int)
signal combat_termine(victoire: bool)
signal tour_joueur_commence

# Créature
signal faim_changee(diminution: float)
signal energie_changee(valeur: float)
signal creature_selectionnee(creature)

# Inventaire
signal item_ajoute(item, quantite: int)
signal item_retire(item, quantite: int)

# Interaction
signal interaction_demandee(action: String, cible)

# UI
signal menu_ouvert(menu: String)
signal menu_ferme(menu: String)
signal sauvegarde_demandee
signal menu_pause_ouvert
signal menu_gamelle_ouvert(gamelle)
signal menu_contexte_ouvert(position, cible)
signal hud_chat_visible(visible: bool, cible)


# Interaction créature
signal entrainement_demande(cible)
signal caresse_demandee(cible)
signal energie_insuffisante(cible)
signal trop_loin(cible)

signal transition_demandee(depuis, vers, callback)

signal combat_entrainement_termine(creature, gain_pv_max, gain_force)
signal inventaire_ouvert

# Etages
signal etage_change(etage: int, visible: bool)
signal faux_etage_change(visible: bool)


signal inventaire_visibilite_demandee
var inventaire_visible := false
