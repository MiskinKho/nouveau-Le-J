# CLAUDE.md — Le-J (Jeu isométrique pixel art, Godot 4.3)

---

## 1. Contexte du projet

Jeu 2D isométrique pixel art sur **Godot 4.3**, développé en **GDScript**.
Repo GitHub : https://github.com/MiskinKho/nouveau-Le-J

### Vision générale
Jeu centré sur la collecte et l'élevage de chats, mêlant :
- **Tamagotchi + Pokémon** — collectionner, élever, entraîner des chats
- **Breath of Fire 3** — système de combat au tour par tour
- **MyBrute** — les chats se battent automatiquement
- **Stardew Valley** — exploration d'un monde ouvert
- **Witchbrook** — design isométrique

### Gameplay Chat
- Combat automatique en tour par tour
- Statistiques : PV, Force, Agilité, Précision, Défense
- Compétences selon niveau et stats, déclenchées par probabilité
- Force et PV augmentent via combats avec le joueur
- Mini-jeux à la Nintendogs pour les autres stats
- Système de confort, confiance (items + interactions répétées)
- Système de besoins : faim, sommeil, énergie (gérés avec items)
- Combat contre animaux sauvages via le joueur
- Nombre d'entraînements limité par jour

### Gameplay Joueur
- Collecter et élever différentes races de chats
- Explorer le monde et découvrir des secrets
- Développer des arts et artisanat
- Boutiques (items joueur et chats)
- Collectibles : Pierres/Minéraux, Cartes de Tarot, Vêtements, Encens
- Cultiver des plantes, pêcher des poissons (bonus aux chats)
- Équiper des bijoux associés aux pierres (bonus)
- Acheter et placer des meubles dans sa maison
- Participer à des tournois (lié à l'histoire)
- Développer des relations avec les habitants

### Histoire
Le joueur arrive dans une nouvelle maison et découvre qu'il est lié à un héritage de sorcière.

---

## 2. Architecture technique

### Principe fondamental
- **Héritage** pour ce qu'un objet EST
- **Composition** pour ce qu'un objet FAIT (composants opt-in)
- **State Machine** pour l'IA des personnages
- **EventBus** pour les signaux globaux découplés
- **Resources** pour les données et stats

### Hiérarchie des personnages
```
CharacterBody2D (Godot built-in)
└── Personnage.gd                     ← base commune à tous les personnages
    │   Flags : menu_ouvert, en_combat, en_repositionnement, last_dir, mange, epuise
    │   Stats : Resource → Creature (stats_combat + stats_bien_etre)
    │   Méthodes communes : deplacer, arreter, _verifier_vitaux
    │   États communs : Idle, Marcher, Combat, Dormir, Manger, Fatigue, Faim
    │
    ├── Joueur.gd                     ← input joueur, étages, son de pas
    │       etage, sas, play_footstep, interagir PNJ
    │       Composant : CompDeplacementJoueur
    │
    └── PNJ.gd                        ← personnages IA (anciennement Chat.gd)
            ZoneClick, survol souris, navigation A*, déambulation
            Composant : CompDeplacementIA
            │
            ├── Chat.gd               ← spécifique au chat du joueur
            │       gamelle (@export), coussin (@export), sur_coussin (flag)
            │       _on_click() surchargé
            │
            ├── Mob.gd                ← animaux sauvages (anciennement Animaux_Sauvages.gd)
            │       leash, zone_deplacement, position_depart
            │       signal creature_cliquee, _on_click() surchargé
            │
            └── Humain.gd             ← habitants PNJ (futur)
```

### Hiérarchie des composants (Node enfants, opt-in)
```
CompDeplacement                       ← calcul iso pur
│   speed, deplacer(dir), arreter()
│
├── CompDeplacementIA                 ← IA navigation
│       extends CompDeplacement
│       NavigationAgent2D, direction, zone_deplacement
│       position_depart, choisir_direction()
│
└── CompDeplacementJoueur             ← input joueur
        extends CompDeplacement
        get_direction(), Input.get_vector()
```

### Hiérarchie des états
```
State (Node)                          ← base commune tous états
├── StateBienEtre extends State       ← accès props bien-être (PNJ uniquement)
│   ├── Etat_Dormir
│   ├── Etat_Fatigue
│   ├── Etat_Faim
│   └── Etat_Manger
├── Etat_Idle
├── Etat_Marcher
│   └── Etat_Deplacement             ← surcharge _get_direction() pour input joueur
└── Etat_Combat
```

### Hiérarchie des données (Resources)
```
Creature                              ← conteneur principal d'un personnage
│   nom, race
├── Stats_Combat (Resource)           ← pv_max, pv_actuel, force, defense, agilite, precision
└── Stats_Bien_Etre (Resource)        ← faim, energie, sommeil, confort, confiance

Mobilier
├── Stats_Mobilier_Chat               ← vitesse_regen, seuil, bonus_*
└── Stats_Mobilier_Joueur

Item                                  ← type, icone, valeur, bonus_* (Resource)
```

### Utilitaires et bus
```
Utils.gd (Autoload statique)          ← dir8_from_vector() et autres utilitaires communs
EventBus.gd (Autoload singleton)      ← tous les signaux globaux
Managers (Autoloads)                  ← CreatureManager, SaveManager, TimeManager, InventoryManager
```

### AutoLoads (Singletons)
- `SaveManager` — sauvegarde/chargement JSON
- `TimeManager` — cycle jour/nuit, calendrier
- `InventoryManager` — gestion inventaire
- `CombatManager` — logique de combat
- `CreatureManager` — gestion des créatures
- `DayNightManager` — couleurs du cycle jour/nuit
- `EventBus` — signaux centralisés

### Signaux EventBus
- Combat : `combat_demarre`, `attaque_effectuee`, `combat_termine`, `tour_joueur_commence`
- UI : `inventaire_ouvert`, `menu_pause_ouvert`, `menu_gamelle_ouvert`, `menu_contexte_ouvert`, `hud_chat_visible`, `sauvegarde_demandee`, `transition_demandee`
- Créature : `entrainement_demande`, `caresse_demandee`, `energie_insuffisante`, `combat_entrainement_termine`
- Étages : `etage_change`, `faux_etage_change`

---

## 3. État actuel du projet

### Systèmes implémentés
- Inventaire (24 slots, extensible par paliers de 8)
- Sauvegarde JSON complète
- Cycle jour/nuit (900s = 1 jour de jeu)
- Gamelle (états VIDE/MOITIE/PLEINE)
- Combat entraînement joueur vs chat (tour par tour)
- State Machine du chat (Idle, Marcher, Faim, Manger, Fatigue, Dormir)
- Système d'étages A/B/C/D
- Menu contextuel, menu pause, HUD

### Déjà fait
- `Personnage.gd` nettoyé — ne contient plus la logique spécifique au joueur
- `Chat.gd` → renommé `class_name PNJ`, hérite de `Personnage`
- `Animaux_Sauvages.gd` → renommé `class_name Mob`, hérite de `PNJ`
- `Joueur.gd` complété — `etage`, `sas`, `_play_footstep`, `_physics_process`
- `Monde.gd` — connexions doubles corrigées
- `Etat_Dormir` — logique `sur_coussin` et régénération corrigée

### En cours / À faire
- Refactoring `Chat.gd` (PNJ) — déléguer `_choisir_direction` et `_se_deplacer_vers` à `CompDeplacementIA`
- `sur_coussin: bool` — présent dans `PNJ.gd` et utilisé dans `Etat_Fatigue` et `Etat_Dormir` ✅
- Supprimer `Player_Stats.gd` et nettoyer la référence dans `Stats_Personnage.gd`
- `Etat_Deplacement` à créer — hérite de `Etat_Marcher`, surcharge `_get_direction()` pour input joueur
- État Combat pour le chat via State Machine
- Système de compétences du chat
- Affichage description items au survol
- Filtrage par catégorie dans l'inventaire
- `process_mode = PROCESS_MODE_DISABLED` sur les états inactifs (performance)
- `duplicate()` sur les Resources au runtime (éviter partage entre personnages)
- `@export var initial_state` dans `StateMachine` au lieu de `get_child(0)`

### Doublons restants à corriger
- `_choisir_direction()` — dans `PNJ` (Chat.gd) ET `Mob` (Animaux_Sauvages.gd) → centraliser dans `CompDeplacementIA`
- `_se_deplacer_vers()` — dans `PNJ` (Chat.gd) → doit déléguer à `CompDeplacementIA.se_deplacer_vers()`
- `Player_Stats.gd` — doublon de `Stats_Combat.gd`, à supprimer
- `_choisir_prochain()` — encore dupliquée dans `Etat_Idle.gd` et `Etat_Marcher.gd` → à déplacer dans `State.gd`

---

## 4. Instructions de travail

### Avant de commencer
- Lire ce fichier `CLAUDE.md` en entier
- Cloner ou relire le repo GitHub sur la branche `Test` : https://github.com/MiskinKho/nouveau-Le-J (branche de travail principale)
- Consulter la skill Godot 4 avant de réfléchir à une logique ou modifier un script
- Lancer `analyse_projet.sh` pour avoir l'état actuel du projet

### Avant de modifier une fonction ou un script
- Utiliser `grep -rn "nom_fonction" Script/` pour identifier tous les scripts impactés
- Analyser si d'autres scripts ont un lien avec le script concerné
- Vérifier que la solution proposée n'entre pas en conflit avec la logique globale des autres scripts
- Considérer la cohérence de l'ensemble des scripts avant toute modification
- Adapter tous les scripts impactés en même temps

### Avant de supprimer un script ou une fonction
- Utiliser `grep -rn "nom_script"` pour vérifier qu'il n'est référencé nulle part

### Avant de fusionner deux fonctions supposément identiques
- Utiliser `diff fichier1.gd fichier2.gd` pour confirmer qu'elles sont bien identiques

### Avant de créer un nouveau script
- Utiliser `grep` pour vérifier qu'un script similaire n'existe pas déjà

### Règles de code
- Ne pas générer un script entier pour corriger seulement quelques lignes
- Ne pas créer de nouveaux scripts sans vérifier les doublons existants
- Réutiliser et hériter des scripts existants au maximum
- Toujours ajouter un commentaire par ligne — ne jamais retirer ni remplacer un commentaire existant
- Priorité : refactoring avant nouvelles features

### Règles de communication
- Toujours proposer un plan et attendre validation avant de modifier le code
- Lister explicitement les erreurs potentielles avant d'appliquer un changement
- Ne pas poser de questions avant d'avoir répondu
- Traiter une chose à la fois
- En cas de doute sur une API ou syntaxe Godot 4.3, consulter docs.godotengine.org
