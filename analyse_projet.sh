#!/bin/bash
# =============================================================================
# analyse_projet.sh — Analyse automatique du projet Le-J (branche Test)
# À lancer depuis la racine du projet avant chaque session de travail
# =============================================================================

SCRIPT_DIR="Script"
SEP="─────────────────────────────────────────────────────────"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         RAPPORT D'ANALYSE — LE-J (branche Test)         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# =============================================================================
# 1. RÉSUMÉ GÉNÉRAL
# =============================================================================
echo "📊 RÉSUMÉ GÉNÉRAL"
echo "$SEP"
total=$(find $SCRIPT_DIR -name "*.gd" | wc -l)
echo "  Scripts .gd trouvés : $total"
echo "  Dossiers principaux :"
for d in "$SCRIPT_DIR"/*/; do
    count=$(find "$d" -name "*.gd" | wc -l)
    echo "    - $(basename $d) : $count scripts"
done
echo ""

# =============================================================================
# 2. HIÉRARCHIE D'HÉRITAGE
# =============================================================================
echo "🔗 HIÉRARCHIE D'HÉRITAGE"
echo "$SEP"
echo "  Scripts qui héritent de CharacterBody2D directement (devrait être 0) :"
result=$(grep -rn "^extends CharacterBody2D" $SCRIPT_DIR/ 2>/dev/null)
if [ -z "$result" ]; then
    echo "    ✅ Aucun — tous passent par Personnage"
else
    echo "$result" | sed 's/^/    ⚠️  /'
fi
echo ""

echo "  Scripts qui héritent de Personnage :"
grep -rn "^extends Personnage" $SCRIPT_DIR/ | sed 's/^/    ✅ /'
echo ""

echo "  Scripts qui héritent de PNJ :"
grep -rn "^extends PNJ" $SCRIPT_DIR/ | sed 's/^/    ✅ /'
echo ""

# =============================================================================
# 3. DOUBLONS DE FONCTIONS
# =============================================================================
echo "🔍 FONCTIONS POTENTIELLEMENT DUPLIQUÉES"
echo "$SEP"
echo "  _choisir_direction :"
grep -rn "^func _choisir_direction" $SCRIPT_DIR/ | sed 's/^/    /'
echo ""

echo "  _se_deplacer_vers :"
grep -rn "^func _se_deplacer_vers" $SCRIPT_DIR/ | sed 's/^/    /'
echo ""

echo "  _choisir_prochain :"
grep -rn "^func _choisir_prochain" $SCRIPT_DIR/ | sed 's/^/    /'
echo ""

echo "  _verifier_vitaux :"
grep -rn "^func _verifier_vitaux" $SCRIPT_DIR/ | sed 's/^/    /'
echo ""

echo "  _dir8_from_vector :"
grep -rn "^func _dir8_from_vector" $SCRIPT_DIR/ | sed 's/^/    /'
echo ""

# =============================================================================
# 4. SCRIPTS OBSOLÈTES / À SUPPRIMER
# =============================================================================
echo "🗑️  SCRIPTS OBSOLÈTES"
echo "$SEP"

echo "  Player_Stats.gd (doublon de Stats_Combat) :"
if [ -f "$SCRIPT_DIR/Personnage/Stats/Player_Stats.gd" ]; then
    echo "    ⚠️  Toujours présent — références :"
    grep -rn "PlayerStats" $SCRIPT_DIR/ | sed 's/^/      /'
else
    echo "    ✅ Supprimé"
fi
echo ""

echo "  Chat.gd (ancienne version, remplacée par PNJ.gd) :"
if [ -f "$SCRIPT_DIR/Personnage/Personnage/Chat.gd" ]; then
    echo "    ⚠️  Toujours présent — à vérifier si encore utilisé"
else
    echo "    ✅ Supprimé"
fi
echo ""

# =============================================================================
# 5. BUGS CONNUS
# =============================================================================
echo "🐛 VÉRIFICATIONS DE BUGS CONNUS"
echo "$SEP"

echo "  Signaux connectés en double dans Monde.gd :"
monde="$SCRIPT_DIR/Vrac/Monde.gd"
if [ -f "$monde" ]; then
    doubles=$(grep "EventBus\." "$monde" | sort | uniq -d)
    if [ -z "$doubles" ]; then
        echo "    ✅ Aucune connexion double détectée"
    else
        echo "    ⚠️  Connexions doubles :"
        echo "$doubles" | sed 's/^/      /'
    fi
else
    echo "    ⚠️  Monde.gd introuvable à $monde"
fi
echo ""

echo "  sur_coussin présent dans PNJ :"
if grep -q "sur_coussin" $SCRIPT_DIR/Personnage/Personnage/PNJ.gd 2>/dev/null; then
    echo "    ✅ Présent"
else
    echo "    ⚠️  Manquant dans PNJ.gd"
fi
echo ""

echo "  Etat_Combat utilise personnage (pas get_parent) :"
if grep -q "get_parent" $SCRIPT_DIR/Personnage/Etats/Etat/Etat_Combat.gd 2>/dev/null; then
    echo "    ⚠️  Utilise encore get_parent()"
else
    echo "    ✅ Utilise personnage correctement"
fi
echo ""

# =============================================================================
# 6. VARIABLES NON UTILISÉES / RÉFÉRENCES MANQUANTES
# =============================================================================
echo "🔎 RÉFÉRENCES CROISÉES"
echo "$SEP"

echo "  Scripts qui référencent Player_Stats :"
result=$(grep -rn "Player_Stats\|PlayerStats" $SCRIPT_DIR/ 2>/dev/null)
if [ -z "$result" ]; then
    echo "    ✅ Aucune référence"
else
    echo "$result" | sed 's/^/    ⚠️  /'
fi
echo ""

echo "  Scripts qui utilisent get_parent().get_parent() (anti-pattern) :"
result=$(grep -rn "get_parent().get_parent()" $SCRIPT_DIR/ 2>/dev/null)
if [ -z "$result" ]; then
    echo "    ✅ Aucun"
else
    echo "$result" | sed 's/^/    ⚠️  /'
fi
echo ""

# =============================================================================
# 7. ÉTAT DE L'ARCHITECTURE
# =============================================================================
echo "🏗️  ÉTAT DE L'ARCHITECTURE"
echo "$SEP"

echo "  class_name déclarés :"
grep -rn "^class_name" $SCRIPT_DIR/ | sed 's/^/    /'
echo ""

echo "  Autoloads référencés (EventBus, SaveManager, etc.) :"
for autoload in EventBus SaveManager TimeManager InventoryManager CombatManager CreatureManager DayNightManager; do
    count=$(grep -rn "$autoload" $SCRIPT_DIR/ | wc -l)
    echo "    $autoload : $count références"
done
echo ""

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                   FIN DU RAPPORT                        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
