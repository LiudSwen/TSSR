
## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🎯 Introduction

La **substitution de commandes** est un mécanisme fondamental du shell qui permet d'exécuter une commande et d'utiliser sa sortie comme valeur dans une autre commande ou variable. C'est l'un des outils les plus puissants pour créer des scripts dynamiques et flexibles.

> [!info] Pourquoi utiliser la substitution de commandes ?
> 
> - Capturer le résultat d'une commande pour l'utiliser ailleurs
> - Construire des commandes dynamiques basées sur l'état du système
> - Automatiser des tâches complexes en chaînant des opérations
> - Créer des scripts adaptables et intelligents

### Quand l'utiliser ?

- Stocker le résultat d'une commande dans une variable
- Utiliser la sortie d'une commande comme argument d'une autre
- Construire des noms de fichiers ou chemins dynamiques
- Effectuer des calculs ou transformations de données

---

## 🔙 Syntaxe avec backticks

La syntaxe historique utilise les **backticks** (accents graves) : `` `commande` ``

### Syntaxe de base

```bash
# Capture la sortie dans une variable
resultat=`commande`

# Utilisation directe dans une commande
echo "Nous sommes le `date`"

# Exemple pratique
utilisateur=`whoami`
echo "Bonjour $utilisateur"
```

### Exemples concrets

```bash
# Obtenir la date actuelle
date_actuelle=`date +%Y-%m-%d`
echo "Date : $date_actuelle"  # Affiche : Date : 2025-12-11

# Compter les fichiers dans un répertoire
nb_fichiers=`ls -1 | wc -l`
echo "Il y a $nb_fichiers fichiers"

# Obtenir le répertoire personnel
home=`echo $HOME`
echo "Répertoire personnel : $home"

# Créer un nom de fichier avec timestamp
backup_file=`date +%Y%m%d_%H%M%S`_backup.tar.gz
echo "Fichier de backup : $backup_file"
```

> [!warning] Limitations des backticks
> 
> - Difficiles à imbriquer (nécessite des échappements complexes)
> - Moins lisibles, surtout dans du code dense
> - Peuvent être confondus avec des apostrophes simples
> - Syntaxe considérée comme obsolète dans le Bash moderne

### Caractéristiques

|Aspect|Détail|
|---|---|
|**Lisibilité**|Moyenne à faible|
|**Imbrication**|Difficile (nécessite ```)|
|**Compatibilité**|Excellente (tous les shells POSIX)|
|**Recommandation**|Éviter dans du nouveau code|

---

## 🚀 Syntaxe moderne $()

La syntaxe **recommandée** et moderne utilise `$(commande)`. C'est la norme POSIX actuelle.

### Syntaxe de base

```bash
# Capture la sortie dans une variable
resultat=$(commande)

# Utilisation directe
echo "Nous sommes le $(date)"

# Exemple pratique
utilisateur=$(whoami)
echo "Bonjour $utilisateur"
```

### Pourquoi préférer $() ?

> [!tip] Avantages de la syntaxe $()
> 
> - **Plus lisible** : distinction claire entre commande et texte
> - **Imbrication facile** : pas besoin d'échappement
> - **Moins d'erreurs** : syntaxe plus explicite
> - **Standard moderne** : recommandée par les guides de style

### Exemples avancés

```bash
# Opérations sur fichiers
fichiers_modifies=$(find . -mtime -1 -type f)
echo "Fichiers modifiés aujourd'hui : $fichiers_modifies"

# Informations système
cpu_count=$(nproc)
mem_total=$(free -h | awk '/^Mem:/ {print $2}')
echo "CPUs: $cpu_count, RAM: $mem_total"

# Manipulation de chaînes
nom_majuscule=$(echo "alice" | tr '[:lower:]' '[:upper:]')
echo "Nom en majuscules : $nom_majuscule"

# Traitement de logs
erreurs=$(grep -c "ERROR" /var/log/app.log)
echo "Nombre d'erreurs : $erreurs"

# Construction de chemins
projet_dir=$(pwd)
backup_dir="$projet_dir/backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir"
```

### Comparaison avec les backticks

```bash
# Ancienne syntaxe (backticks)
date_backup=`date +%Y%m%d`
fichier="backup_$date_backup.tar"

# Nouvelle syntaxe (recommandée)
date_backup=$(date +%Y%m%d)
fichier="backup_$date_backup.tar"

# Les deux produisent le même résultat
# mais $() est plus claire et maintenable
```

---

## 🪆 Substitution imbriquée

La substitution imbriquée permet d'utiliser le résultat d'une commande comme entrée d'une autre commande, créant ainsi des chaînes d'opérations complexes.

### Avec la syntaxe moderne $()

```bash
# Simple imbrication
# Compte les lignes du fichier le plus récent
nb_lignes=$(wc -l < $(ls -t | head -n1))

# Imbrication multiple
# Trouve le processus qui utilise le plus de mémoire
top_process=$(ps aux | sort -nrk 4 | head -n1 | awk '{print $11}')

# Exemple complet et lisible
dernier_log=$(ls -t /var/log/*.log | head -n1)
erreurs_recentes=$(grep -c "ERROR" "$dernier_log")
echo "Erreurs dans $dernier_log : $erreurs_recentes"
```

### Exemples pratiques d'imbrication

```bash
# Trouver et compter les fichiers Python modifiés cette semaine
fichiers_py_recents=$(find . -name "*.py" -mtime -7)
nb_py_recents=$(echo "$fichiers_py_recents" | wc -l)
echo "Fichiers Python modifiés : $nb_py_recents"

# Obtenir l'IP du serveur DNS actif
dns_server=$(cat /etc/resolv.conf | grep nameserver | head -n1 | awk '{print $2}')
echo "Serveur DNS : $dns_server"

# Créer un backup avec le nom du répertoire courant
repertoire_actuel=$(basename $(pwd))
tar -czf "${repertoire_actuel}_$(date +%Y%m%d).tar.gz" .

# Trouver le fichier le plus volumineux
gros_fichier=$(du -sh * | sort -hr | head -n1)
echo "Fichier le plus gros : $gros_fichier"
```

### Imbrication complexe

```bash
# Exemple : Analyser les logs du dernier déploiement
dernier_deploy=$(ls -t /var/log/deploy-*.log | head -n1)
date_deploy=$(grep "Started at" "$dernier_deploy" | awk '{print $3, $4}')
duree_deploy=$(grep "Completed in" "$dernier_deploy" | awk '{print $3}')

echo "Dernier déploiement :"
echo "  Date : $date_deploy"
echo "  Durée : $duree_deploy"
echo "  Erreurs : $(grep -c ERROR "$dernier_deploy")"
```

### Avec les backticks (à éviter)

```bash
# Imbrication avec backticks : DIFFICILE et ILLISIBLE
# Il faut échapper les backticks internes avec \
nb_lignes=`wc -l < \`ls -t | head -n1\``

# Rapidement ingérable avec plusieurs niveaux
resultat=`commande1 \`commande2 \\\`commande3\\\`\``

# Comparaison : la même chose avec $()
resultat=$(commande1 $(commande2 $(commande3)))
```

> [!warning] Éviter les backticks pour l'imbrication L'imbrication avec backticks nécessite d'échapper chaque niveau avec `\`, ce qui devient rapidement illisible et source d'erreurs. **Utilisez toujours $() pour les substitutions imbriquées.**

### Bonnes pratiques pour l'imbrication

```bash
# ✅ BON : Décomposer en étapes lisibles
dernier_fichier=$(ls -t | head -n1)
nb_lignes=$(wc -l < "$dernier_fichier")
echo "Le fichier $dernier_fichier contient $nb_lignes lignes"

# ⚠️ ACCEPTABLE : Imbrication simple et claire
nb_lignes=$(wc -l < $(ls -t | head -n1))

# ❌ MAUVAIS : Imbrication trop profonde
resultat=$(commande1 $(commande2 $(commande3 $(commande4))))
# Difficile à déboguer et maintenir

# ✅ MEILLEUR : Utiliser des variables intermédiaires
etape1=$(commande1)
etape2=$(commande2 "$etape1")
etape3=$(commande3 "$etape2")
resultat=$(commande4 "$etape3")
```

---

## 📦 Capture de sortie de commande

La substitution de commandes capture la **sortie standard** (stdout) d'une commande. Comprendre ce mécanisme est essentiel pour l'utiliser efficacement.

### Comportement de base

```bash
# Capture la sortie standard
sortie=$(echo "Hello World")
echo "$sortie"  # Affiche : Hello World

# Les retours à la ligne sont préservés
multi_lignes=$(cat << EOF
Ligne 1
Ligne 2
Ligne 3
EOF
)
echo "$multi_lignes"

# Attention : les espaces multiples sont compactés sans guillemets
texte=$(echo "un    deux    trois")
echo $texte   # Affiche : un deux trois
echo "$texte" # Affiche : un    deux    trois
```

### Capture avec sortie d'erreur

```bash
# Par défaut, seul stdout est capturé
resultat=$(ls fichier_inexistant)  # stderr s'affiche à l'écran
echo "Resultat : $resultat"         # Variable vide

# Rediriger stderr vers stdout pour tout capturer
resultat=$(ls fichier_inexistant 2>&1)
echo "Resultat : $resultat"  # Contient le message d'erreur

# Séparer stdout et stderr
sortie=$(commande 2>/dev/null)      # Ignore les erreurs
erreurs=$(commande 2>&1 >/dev/null) # Capture seulement les erreurs
```

### Gestion des espaces et retours à la ligne

```bash
# Préservation des retours à la ligne
fichiers=$(ls -1)
echo "$fichiers"  # Chaque fichier sur une ligne
echo $fichiers    # Tous les fichiers sur une ligne

# Itération sur les lignes
while IFS= read -r ligne; do
    echo "Traitement de : $ligne"
done < <(find . -name "*.txt")

# Conversion en tableau
fichiers_array=($(ls *.txt))
echo "Nombre de fichiers : ${#fichiers_array[@]}"
echo "Premier fichier : ${fichiers_array[0]}"
```

### Traitement de la sortie

```bash
# Nettoyage des espaces en début/fin
resultat=$(echo "  texte avec espaces  " | xargs)
echo "[$resultat]"  # Affiche : [texte avec espaces]

# Supprimer le dernier retour à la ligne
sortie=$(commande)
sortie="${sortie%$'\n'}"

# Compter les lignes de sortie
nb_lignes=$(commande | wc -l)

# Filtrer la sortie
erreurs=$(commande 2>&1 | grep ERROR)

# Transformer la sortie
majuscules=$(echo "texte" | tr '[:lower:]' '[:upper:]')
```

### Cas d'usage avancés

```bash
# Capturer et parser une sortie structurée
info_disque=$(df -h / | tail -n1)
utilisation=$(echo "$info_disque" | awk '{print $5}')
echo "Disque utilisé à $utilisation"

# Capturer le code de sortie ET la sortie
sortie=$(commande 2>&1)
code_retour=$?
if [ $code_retour -ne 0 ]; then
    echo "Erreur (code $code_retour) : $sortie"
fi

# Capturer avec timeout
sortie=$(timeout 5s commande_longue)

# Capturer en ignorant certaines lignes
sortie=$(commande | grep -v "ligne_a_ignorer")
```

> [!tip] Guillemets et substitution Toujours mettre entre guillemets les variables contenant une substitution : `"$variable"`
> 
> - Préserve les espaces et retours à la ligne
> - Évite le word splitting
> - Protège contre les caractères spéciaux

### Performance et optimisation

```bash
# ❌ INEFFICACE : Appels multiples
for i in {1..100}; do
    date=$(date +%s)
    echo "Timestamp : $date"
done

# ✅ EFFICACE : Un seul appel
timestamp=$(date +%s)
for i in {1..100}; do
    echo "Timestamp : $timestamp"
done

# Éviter les substitutions dans les boucles si possible
# Calculer une fois, réutiliser plusieurs fois
```

---

## ⚠️ Pièges courants

### 1. Oublier les guillemets

```bash
# ❌ PROBLÈME : Sans guillemets
fichiers=$(ls *.txt)
for f in $fichiers; do  # Word splitting sur les espaces
    echo "$f"
done

# ✅ SOLUTION : Avec guillemets
fichiers=$(ls *.txt)
for f in "$fichiers"; do  # Préserve les espaces
    echo "$f"
done

# Ou mieux encore
while IFS= read -r fichier; do
    echo "$fichier"
done < <(ls *.txt)
```

### 2. Confondre $() avec (())

```bash
# $() : Substitution de commande
resultat=$(date)

# $(()) : Évaluation arithmétique
calcul=$((5 + 3))

# ❌ ERREUR courante
somme=$(5 + 3)  # Essaie d'exécuter "5" comme commande

# ✅ CORRECT
somme=$((5 + 3))  # Pour l'arithmétique
```

### 3. Capturer stderr par erreur

```bash
# ❌ PROBLÈME : Les erreurs s'affichent à l'écran
resultat=$(grep "pattern" fichier_inexistant)
# grep: fichier_inexistant: No such file or directory

# ✅ SOLUTION : Rediriger stderr
resultat=$(grep "pattern" fichier_inexistant 2>/dev/null)

# Ou capturer stderr aussi
resultat=$(grep "pattern" fichier_inexistant 2>&1)
```

### 4. Substitution dans les conditions

```bash
# ❌ PROBLÈME : Syntaxe invalide
if $(grep -q "pattern" fichier); then
    echo "Trouvé"
fi

# ✅ SOLUTION : Pas de substitution nécessaire
if grep -q "pattern" fichier; then
    echo "Trouvé"
fi

# La commande elle-même retourne un code de sortie
```

### 5. Variables vides ou non définies

```bash
# ❌ PROBLÈME : Variable vide provoque une erreur
fichier=$(find . -name "inexistant.txt")
cat "$fichier"  # cat: : No such file or directory

# ✅ SOLUTION : Vérifier avant utilisation
fichier=$(find . -name "inexistant.txt")
if [ -n "$fichier" ]; then
    cat "$fichier"
else
    echo "Fichier non trouvé"
fi
```

### 6. Performances avec grandes sorties

```bash
# ❌ INEFFICACE : Charge tout en mémoire
tous_les_logs=$(cat /var/log/huge_file.log)
echo "$tous_les_logs" | grep "ERROR"

# ✅ EFFICACE : Pipe direct
cat /var/log/huge_file.log | grep "ERROR"

# Ou encore mieux
grep "ERROR" /var/log/huge_file.log
```

### 7. Caractères spéciaux non échappés

```bash
# ❌ PROBLÈME : Interprétation du glob
fichiers=$(echo *.txt)  # Expansion du shell

# ✅ SOLUTION : Protéger avec guillemets
fichiers=$(echo "*.txt")  # Littéral

# Pour lister vraiment les fichiers
fichiers=$(ls *.txt)
```

---

## 💡 Astuces avancées

### 1. Substitution avec valeur par défaut

```bash
# Utiliser une valeur par défaut si la commande échoue
resultat=$(commande_qui_peut_echouer) || resultat="valeur_par_defaut"

# Ou avec une syntaxe plus compacte
fichier=${fichier:-$(find . -name "*.txt" | head -n1)}
```

### 2. Substitution conditionnelle

```bash
# Exécuter une substitution seulement si nécessaire
if [ ! -f "cache.txt" ]; then
    resultat=$(commande_couteuse)
    echo "$resultat" > cache.txt
else
    resultat=$(cat cache.txt)
fi
```

### 3. Substitution avec processus en arrière-plan

```bash
# Lancer en parallèle et récupérer les résultats
resultat1=$(commande1) &
pid1=$!
resultat2=$(commande2) &
pid2=$!

wait $pid1
wait $pid2

echo "Résultat 1 : $resultat1"
echo "Résultat 2 : $resultat2"
```

### 4. Here-strings avec substitution

```bash
# Passer une variable comme stdin
resultat=$(grep "pattern" <<< "$texte")

# Équivalent à
resultat=$(echo "$texte" | grep "pattern")
```

### 5. Substitution dans les prompts

```bash
# Prompt dynamique avec git
export PS1='$(git branch 2>/dev/null | grep "^*" | cut -d" " -f2) \$ '

# Prompt avec couleurs
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

### 6. Debugging des substitutions

```bash
# Activer le mode debug
set -x
resultat=$(commande complexe)
set +x

# Afficher la commande avant exécution
echo "Exécution de : commande complexe"
resultat=$(commande complexe)
echo "Résultat : $resultat"
```

### 7. Substitution avec gestion d'erreur robuste

```bash
# Fonction wrapper pour capturer sortie et code retour
capture_commande() {
    local output
    local status
    output=$(eval "$@" 2>&1)
    status=$?
    echo "$output"
    return $status
}

# Utilisation
if resultat=$(capture_commande "commande complexe"); then
    echo "Succès : $resultat"
else
    echo "Échec : $resultat"
fi
```

### 8. Optimisation avec substitution partielle

```bash
# Extraire juste ce dont on a besoin
premier_mot=$(echo "$phrase" | awk '{print $1}')

# Plus efficace que
tous_les_mots=$(echo "$phrase")
premier_mot="${tous_les_mots%% *}"
```

### 9. Substitution avec transformations

```bash
# Chaîner plusieurs transformations
texte=$(cat fichier.txt | tr '[:upper:]' '[:lower:]' | sed 's/ancien/nouveau/g' | sort -u)

# Ou plus lisible
texte=$(cat fichier.txt)
texte=$(echo "$texte" | tr '[:upper:]' '[:lower:]')
texte=$(echo "$texte" | sed 's/ancien/nouveau/g')
texte=$(echo "$texte" | sort -u)
```

### 10. Substitution récursive

```bash
# Répéter une substitution jusqu'à stabilité
ancien=""
nouveau=$(commande_initiale)

while [ "$ancien" != "$nouveau" ]; do
    ancien="$nouveau"
    nouveau=$(echo "$ancien" | transformation)
done

echo "Résultat final : $nouveau"
```

> [!example] Exemple complet : Script de monitoring
> 
> ```bash
> #!/bin/bash
> 
> # Collecte d'informations système avec substitution
> hostname=$(hostname)
> date_heure=$(date "+%Y-%m-%d %H:%M:%S")
> cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
> mem_usage=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')
> disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
> 
> # Rapport
> echo "=== Rapport système - $hostname ==="
> echo "Date : $date_heure"
> echo "CPU : ${cpu_usage}%"
> echo "Mémoire : ${mem_usage}%"
> echo "Disque : ${disk_usage}%"
> 
> # Alertes
> if [ $(echo "$cpu_usage > 80" | bc) -eq 1 ]; then
>     echo "⚠️ Alerte : CPU élevé !"
> fi
> ```

---

## 📊 Tableau récapitulatif

|Syntaxe|Lisibilité|Imbrication|Compatibilité|Usage recommandé|
|---|---|---|---|---|
|`` `cmd` ``|⭐⭐|⭐|⭐⭐⭐⭐⭐|Scripts legacy uniquement|
|`$(cmd)`|⭐⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|Tous les nouveaux scripts|

> [!tip] Règle d'or **Utilisez toujours `$(commande)` dans vos nouveaux scripts.** C'est la syntaxe standard, recommandée, et beaucoup plus maintenable.

---

_Cours complet sur la substitution de commandes en Bash - Prêt pour Obsidian_ ✨