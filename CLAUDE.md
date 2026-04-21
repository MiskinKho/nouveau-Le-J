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
- **Behaviour Tree** pour l'IA des personnages
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

## 3. Documents de référence

| Fichier | Rôle |
|---|---|---|---|
| `Claude.md` | Contexte, Architecture, Instructions et règles de travail |
| `Rapport.md`| Log des modifications apportées |
| `Journal.md`| État des lieux global du jeu |
| `Carnet.md` | Historique cumulatif des features |

**Ordre de lecture en début de session :**
1. `Claude.md` — ce fichier
2. `Rapport.md` — priorités et directives de la session
3. `Journal.md` — ce qui fonctionne, ce qui est cassé, Futur implémentation

---

## 4. Instructions de travail

### Contexte du refactoring

Le projet a été construit de façon organique, sans architecture définie au départ. Chaque système a été implémenté de façon isolée, en dupliquant la logique existante à chaque nouveau besoin plutôt qu'en l'abstraisant. C'est l'origine des doublons actuels et des scripts partiellement vidés sans nettoyage cohérent.

Le refactoring documenté ici n'est pas une réécriture arbitraire : c'est la consolidation progressive vers l'architecture cible définie a posteriori. **La règle absolue est : refactoring avant nouvelle feature** — on ne construit pas sur de la dette technique.

### Avant de commencer
- Lire ce fichier `Claude.md` en entier
- Lire `Rapport.md` pour connaître les priorités de la session
- Lire `Journal.md` — Etat actuel du jeu
- Cloner ou relire le repo GitHub sur la branche `test` : https://github.com/MiskinKho/nouveau-Le-J
- Consulter la skill Godot 4 et LimboAI 
- Lancer `analyse_projet.sh` pour avoir l'état actuel du projet

### Règles de code
- Considérer la cohérence de l'ensemble de la structure des scripts avant toute modification
- Vérifier si la solution proposée n'entre pas en conflit avec la logique global de la structure/hiérarchie des scripts
- Ne pas créer de scripts/fonctions doublons 
- Réutiliser et hériter des scripts existants au maximum
- Toujours ajouter un commentaire par ligne — ne jamais retirer ni remplacer un commentaire existant
- Priorité : refactoring avant nouvelle feature
- Ne pas générer un script entier pour corriger seulement quelques lignes


### Analyse Global
- Consulter la skill Godot 4 et LimboAI avant de réfléchir à une logique, de créer/générer un script
- Vérifier s'il n'existe pas de script doublon

### Avant de créer un nouveau script
- Utiliser `grep` pour vérifier qu'un script similaire n'existe pas déjà
- Vérifier la cohérence avec la structure/Hiérarchie

### Avant de modifier une fonction ou un script
- Utiliser `grep -rn "nom_fonction" Script/` pour identifier tous les scripts impactés
- Analyser si d'autres scripts ont un lien avec le script concerné
- Adapter tous les scripts impactés en même temps
- Vérifier que toutes les références et appels vers le script/la fonction sont mis à jour
- Vérifier la cohérence avec la structure/Hiérarchie

### Avant de supprimer un script ou une fonction
- Utiliser `grep -rn "nom_script"` pour vérifier qu'il n'est référencé nulle part

### Avant de fusionner deux fonctions supposément identiques
- Utiliser `diff fichier1.gd fichier2.gd` pour confirmer qu'elles sont bien identiques

### Après création/modification/Suppression d'un script ou d'une fonction 
- Analyser les erreurs et dysfonctionnement possibles dû à un changement, 
- Proposer une solution pour les corriger
- Vérifier que toutes les références et appels vers le script/la fonction sont mis à jour



### Règles de communication
- Toujours proposer un plan et attendre validation avant de modifier le code
- Lister explicitement les erreurs potentielles avant d'appliquer un changement
- Ne pas poser de questions avant d'avoir répondu
- Ne pas générer de script avant d'être sûre que la logique me convienne
- Traiter une chose à la fois
- En cas de doute sur une API ou syntaxe Godot 4.3, consulter docs.godotengine.org
- Toujours ajouter un commentaire sur chaque lignes pour expliquer ce qu'elle fait ou comment elle fonctionne, si un commentaires est déjà présent, ne pas le retirer ni le remplacer
---

## 5. Obligations de fin de session

### 1. Rédiger le rapport

Mettre à jour le fichier Rapport.md en suivant le format existant du document .

Inclure obligatoirement :
- Les fichiers modifiés, créés ou supprimés
- Les changements logiques importants et leur justification
- Les points d'attention pour le Compte 2 (bugs potentiels, dérives architecturales, choix discutables)

### 2. Pusher sur la branche `test`

```bash
git add -A
git commit -m "Session [N] — [description courte]"
git push origin test
```
