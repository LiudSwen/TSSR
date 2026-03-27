

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

## 🎯 Introduction à la boucle while

La boucle `while` est une structure de contrôle fondamentale en Bash qui permet d'exécuter un bloc de commandes **tant qu'une condition reste vraie**. Contrairement à la boucle `for` qui itère sur une liste définie, `while` continue jusqu'à ce que sa condition devienne fausse.

### Quand utiliser while ?

- **Attente d'un événement** : surveiller un fichier, un processus, une connexion
- **Traitement de flux** : lire un fichier ligne par ligne, traiter des données en continu
- **Compteurs dynamiques** : quand le nombre d'itérations n'est pas connu à l'avance
- **Boucles infinies** : daemons, serveurs, menus interactifs
- **Validation d'entrées** : redemander jusqu'à obtenir une réponse valide

> [!info] Différence clé avec for `for` parcourt une collection finie, `while` continue tant qu'une condition est satisfaite. `while` est plus flexible mais nécessite une attention particulière pour éviter les boucles infinies non désirées.

---

## 📝 Syntaxe de base

### Structure générale

```bash
while [ condition ]
do
    # Commandes à exécuter
    # tant que condition est vraie
done
```

### Syntaxe alternative (une ligne)

```bash
while [ condition ]; do commandes; done
```

> [!tip] Format compact Pour les boucles simples, la syntaxe sur une ligne est pratique. Pour du code plus lisible et maintenable, préférez le format multi-lignes.

### Exemples fondamentaux

```bash
# Compteur simple
compteur=1
while [ $compteur -le 5 ]
do
    echo "Itération numéro $compteur"
    ((compteur++))  # Incrémenter le compteur
done

# Avec double parenthèses (syntaxe arithmétique)
compteur=1
while (( compteur <= 5 ))
do
    echo "Compteur : $compteur"
    ((compteur++))
done
```

> [!example] Sortie
> 
> ```
> Itération numéro 1
> Itération numéro 2
> Itération numéro 3
> Itération numéro 4
> Itération numéro 5
> ```

---

## 🧪 Conditions et tests

### Types de conditions

La boucle `while` accepte plusieurs types de conditions :

#### 1. Tests avec crochets `[ ]`

```bash
# Test numérique
while [ $nombre -lt 10 ]
do
    echo $nombre
    ((nombre++))
done

# Test de chaîne
while [ "$reponse" != "oui" ]
do
    read -p "Continuer ? (oui/non) : " reponse
done

# Test de fichier
while [ ! -f "/tmp/signal.txt" ]
do
    echo "Attente du fichier signal..."
    sleep 2
done
```

#### 2. Tests avec double crochets `[[ ]]`

```bash
# Plus puissant, permet les regex et opérateurs logiques
while [[ $nom != "exit" && $compteur -lt 10 ]]
do
    read -p "Entrez un nom (exit pour quitter) : " nom
    ((compteur++))
done
```

#### 3. Tests arithmétiques `(( ))`

```bash
# Syntaxe C-like, plus naturelle pour les nombres
i=0
while (( i < 10 ))
do
    echo "i = $i"
    (( i++ ))
done

# Opérations complexes
while (( compteur * 2 <= limite ))
do
    echo "Double de $compteur = $((compteur * 2))"
    (( compteur++ ))
done
```

#### 4. Code de retour de commande

```bash
# Tant que la commande réussit (retourne 0)
while ping -c 1 google.com &> /dev/null
do
    echo "Connexion internet active"
    sleep 5
done

# Tant qu'un processus existe
while pgrep -x "mon_programme" > /dev/null
do
    echo "Le programme tourne encore..."
    sleep 3
done
```

### Tableau récapitulatif des opérateurs

|Opérateur|Type|Description|Exemple|
|---|---|---|---|
|`-eq`|Numérique|Égal|`[ $a -eq 5 ]`|
|`-ne`|Numérique|Différent|`[ $a -ne 0 ]`|
|`-lt`|Numérique|Inférieur|`[ $a -lt 10 ]`|
|`-le`|Numérique|Inférieur ou égal|`[ $a -le 10 ]`|
|`-gt`|Numérique|Supérieur|`[ $a -gt 0 ]`|
|`-ge`|Numérique|Supérieur ou égal|`[ $a -ge 5 ]`|
|`=` ou `==`|Chaîne|Égal|`[ "$str" = "test" ]`|
|`!=`|Chaîne|Différent|`[ "$str" != "" ]`|
|`-z`|Chaîne|Vide|`[ -z "$var" ]`|
|`-n`|Chaîne|Non vide|`[ -n "$var" ]`|
|`-f`|Fichier|Existe et est un fichier|`[ -f "file.txt" ]`|
|`-d`|Fichier|Existe et est un répertoire|`[ -d "/tmp" ]`|
|`-e`|Fichier|Existe (fichier ou répertoire)|`[ -e "path" ]`|

> [!warning] Guillemets pour les variables Toujours mettre les variables chaînes entre guillemets dans les tests : `[ "$var" = "valeur" ]` pour éviter les erreurs si la variable est vide.

---

## ♾️ Boucles infinies

Une boucle infinie s'exécute indéfiniment jusqu'à interruption manuelle ou par `break`.

### Syntaxe principale

```bash
# Méthode 1 : while true
while true
do
    echo "Cette boucle tourne sans fin"
    sleep 1
done

# Méthode 2 : while :
while :
do
    echo "Alternative avec deux-points"
    sleep 1
done

# Méthode 3 : condition toujours vraie
while [ 1 -eq 1 ]
do
    echo "1 sera toujours égal à 1..."
    sleep 1
done
```

> [!tip] Préférence de style `while true` est la plus lisible et explicite. `while :` est plus compacte (`:` est une commande intégrée qui ne fait rien et retourne toujours 0).

### Cas d'usage typiques

#### Menu interactif

```bash
while true
do
    echo "=== Menu Principal ==="
    echo "1. Option A"
    echo "2. Option B"
    echo "3. Quitter"
    read -p "Votre choix : " choix
    
    case $choix in
        1) echo "Option A sélectionnée" ;;
        2) echo "Option B sélectionnée" ;;
        3) echo "Au revoir !"; break ;;
        *) echo "Choix invalide" ;;
    esac
    echo ""
done
```

#### Monitoring continu

```bash
while true
do
    clear
    echo "=== Surveillance système ==="
    echo "Date : $(date)"
    echo "Charge : $(uptime | awk -F'load average:' '{print $2}')"
    echo "Mémoire : $(free -h | grep Mem | awk '{print $3"/"$2}')"
    
    sleep 5  # Rafraîchir toutes les 5 secondes
done
```

#### Daemon/Service

```bash
# Script qui tourne en arrière-plan
while true
do
    # Vérifier une condition
    if [ -f "/tmp/nouveau_fichier.txt" ]; then
        traiter_fichier "/tmp/nouveau_fichier.txt"
        mv "/tmp/nouveau_fichier.txt" "/tmp/traite/"
    fi
    
    sleep 10  # Vérifier toutes les 10 secondes
done
```

> [!warning] Interruption de boucles infinies Pour arrêter une boucle infinie : **Ctrl+C** en interactif, ou `kill PID` si en arrière-plan. Toujours prévoir une condition de sortie propre avec `break` si possible.

---

## 📄 Lecture de fichiers ligne par ligne

L'un des usages les plus courants de `while` est la lecture séquentielle de fichiers.

### Méthode standard avec redirection

```bash
# Lire fichier.txt ligne par ligne
while read ligne
do
    echo "Ligne lue : $ligne"
done < fichier.txt
```

### Préservation des espaces de fin

```bash
# La redirection IFS='' préserve les espaces
while IFS= read -r ligne
do
    echo "$ligne"
done < fichier.txt
```

> [!info] Options importantes
> 
> - `IFS=` : préserve les espaces en début/fin de ligne
> - `-r` : désactive l'interprétation des backslashes (traite `\` comme caractère littéral)
> - Ces options sont recommandées pour une lecture fidèle du fichier

### Lire plusieurs champs par ligne

```bash
# Fichier CSV : nom,age,ville
while IFS=',' read -r nom age ville
do
    echo "Nom: $nom | Age: $age | Ville: $ville"
done < donnees.csv

# Exemple avec /etc/passwd (séparateur : )
while IFS=':' read -r user pass uid gid info home shell
do
    echo "Utilisateur $user (UID: $uid) - Shell: $shell"
done < /etc/passwd
```

### Ignorer les lignes vides ou commentaires

```bash
while IFS= read -r ligne
do
    # Ignorer les lignes vides
    [[ -z "$ligne" ]] && continue
    
    # Ignorer les commentaires (commençant par #)
    [[ "$ligne" =~ ^[[:space:]]*# ]] && continue
    
    # Traiter la ligne
    echo "Traitement : $ligne"
done < config.txt
```

### Lecture avec numéro de ligne

```bash
numero=1
while IFS= read -r ligne
do
    printf "%3d: %s\n" "$numero" "$ligne"
    ((numero++))
done < fichier.txt
```

> [!example] Cas pratique : traitement de logs
> 
> ```bash
> # Extraire les erreurs d'un log
> while IFS= read -r ligne
> do
>     if [[ "$ligne" =~ ERROR|CRITICAL ]]; then
>         echo "[$(date +%H:%M:%S)] $ligne" >> erreurs_filtrees.log
>     fi
> done < application.log
> ```

---

## ⌨️ Combinaison avec read

La commande `read` est naturellement associée à `while` pour créer des interactions utilisateur ou traiter des entrées.

### Lecture interactive simple

```bash
# Demander jusqu'à obtenir une réponse valide
while true
do
    read -p "Entrez 'oui' ou 'non' : " reponse
    
    if [[ "$reponse" == "oui" || "$reponse" == "non" ]]; then
        break
    fi
    
    echo "Réponse invalide, réessayez."
done

echo "Vous avez répondu : $reponse"
```

### Options utiles de read

```bash
# -t : timeout (en secondes)
compteur=0
while [ $compteur -lt 3 ]
do
    if read -t 5 -p "Répondez dans 5 secondes : " reponse; then
        echo "Vous avez dit : $reponse"
        break
    else
        echo "Temps écoulé !"
        ((compteur++))
    fi
done

# -s : masquer la saisie (pour mots de passe)
tentatives=0
while [ $tentatives -lt 3 ]
do
    read -s -p "Mot de passe : " password
    echo ""
    
    if [ "$password" == "secret123" ]; then
        echo "Accès accordé"
        break
    fi
    
    ((tentatives++))
    echo "Mot de passe incorrect ($tentatives/3)"
done

# -n : lire N caractères seulement
while true
do
    read -n 1 -p "Appuyez sur une touche (q pour quitter) : " touche
    echo ""
    
    [[ "$touche" == "q" ]] && break
    
    echo "Vous avez pressé : $touche"
done
```

### Lire depuis stdin avec pipe

```bash
# Lire la sortie d'une commande
ps aux | while read user pid cpu mem vsz rss tty stat start time command
do
    # Afficher seulement les processus utilisant plus de 5% CPU
    cpu_int=${cpu%.*}  # Enlever les décimales
    if [ "$cpu_int" -gt 5 ]; then
        echo "Process gourmand : $command (CPU: $cpu%)"
    fi
done

# Traiter des URLs depuis un fichier
cat urls.txt | while IFS= read -r url
do
    echo "Téléchargement de $url..."
    wget -q "$url" -P /tmp/downloads/
done
```

> [!warning] Sous-shell dans les pipes Attention : `commande | while read` crée un sous-shell. Les variables modifiées dans la boucle ne persistent pas après :
> 
> ```bash
> # ❌ Ne fonctionne pas
> compteur=0
> echo -e "a\nb\nc" | while read ligne; do ((compteur++)); done
> echo $compteur  # Affiche 0 !
> 
> # ✅ Solution : redirection au lieu de pipe
> compteur=0
> while read ligne; do ((compteur++)); done <<< "$(echo -e 'a\nb\nc')"
> echo $compteur  # Affiche 3
> ```

### Lecture de multiple variables simultanées

```bash
# Lire plusieurs valeurs sur une ligne
while true
do
    read -p "Entrez largeur et hauteur (ou 'q' pour quitter) : " larg haut
    
    [[ "$larg" == "q" ]] && break
    
    # Vérifier que ce sont des nombres
    if [[ "$larg" =~ ^[0-9]+$ && "$haut" =~ ^[0-9]+$ ]]; then
        surface=$((larg * haut))
        echo "Surface : $surface"
    else
        echo "Erreur : entrez deux nombres"
    fi
done
```

---

## 🎮 Contrôle de flux

### break - Sortir de la boucle

```bash
# Chercher un fichier et s'arrêter dès qu'on le trouve
compteur=0
while [ $compteur -lt 100 ]
do
    fichier="backup_${compteur}.tar.gz"
    
    if [ -f "$fichier" ]; then
        echo "Trouvé : $fichier"
        break  # Sortir immédiatement de la boucle
    fi
    
    ((compteur++))
done

if [ $compteur -eq 100 ]; then
    echo "Aucun fichier trouvé"
fi
```

### continue - Passer à l'itération suivante

```bash
# Traiter seulement les nombres pairs
nombre=0
while [ $nombre -le 10 ]
do
    ((nombre++))
    
    # Si impair, passer au suivant
    if [ $((nombre % 2)) -ne 0 ]; then
        continue
    fi
    
    echo "$nombre est pair"
done
```

### Combinaison break et continue

```bash
# Menu avec validation
while true
do
    read -p "Entrez un nombre entre 1 et 10 (0 pour quitter) : " num
    
    # Quitter
    if [ "$num" -eq 0 ]; then
        echo "Au revoir !"
        break
    fi
    
    # Vérifier que c'est un nombre
    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
        echo "Erreur : ce n'est pas un nombre"
        continue
    fi
    
    # Vérifier la plage
    if [ "$num" -lt 1 ] || [ "$num" -gt 10 ]; then
        echo "Hors limites !"
        continue
    fi
    
    # Traiter le nombre valide
    echo "Vous avez choisi : $num"
done
```

---

## ⚠️ Pièges courants

### 1. Boucle infinie accidentelle

```bash
# ❌ ERREUR : le compteur n'est jamais incrémenté
compteur=1
while [ $compteur -le 5 ]
do
    echo "Itération"
    # Oubli de : ((compteur++))
done
# Cette boucle ne s'arrêtera JAMAIS !

# ✅ CORRECT
compteur=1
while [ $compteur -le 5 ]
do
    echo "Itération $compteur"
    ((compteur++))  # Ne pas oublier !
done
```

### 2. Modification de variable dans un sous-shell

```bash
# ❌ Ne fonctionne pas
total=0
cat nombres.txt | while read nombre
do
    total=$((total + nombre))
done
echo "Total : $total"  # Affiche 0 !

# ✅ Solution : utiliser une redirection
total=0
while read nombre
do
    total=$((total + nombre))
done < nombres.txt
echo "Total : $total"  # Correct !
```

### 3. Oubli de IFS= et -r avec read

```bash
# ❌ Perd les espaces et interprète les backslashes
while read ligne
do
    echo "$ligne"
done < fichier.txt

# ✅ Lecture fidèle
while IFS= read -r ligne
do
    echo "$ligne"
done < fichier.txt
```

### 4. Guillemets manquants dans les tests

```bash
# ❌ Erreur si $var est vide
while [ $var != "stop" ]
do
    # ...
done

# ✅ Toujours mettre des guillemets
while [ "$var" != "stop" ]
do
    # ...
done
```

### 5. Condition toujours vraie par erreur

```bash
# ❌ Erreur de logique
trouve=false
while [ "$trouve" = false ]  # Comparaison de chaînes !
do
    # ...
    trouve=true  # Assigne la chaîne "true", pas le booléen
done
# Cette boucle continue car "true" != false (chaîne)

# ✅ Utiliser une variable numérique
trouve=0
while [ $trouve -eq 0 ]
do
    # ...
    trouve=1
done

# ✅ OU tester directement
while ! $trouve
do
    # ...
    trouve=true
done
```

> [!warning] Bash n'a pas de vrais booléens En Bash, `true` et `false` sont des commandes qui retournent 0 ou 1. Pour des drapeaux, utilisez 0/1 ou testez directement les conditions.

---

## ✅ Bonnes pratiques

### 1. Toujours avoir une condition de sortie

```bash
# ✅ Même dans une boucle "infinie", prévoir une sortie
max_iterations=1000
compteur=0

while true
do
    # Travail...
    
    # Protection anti-boucle infinie
    ((compteur++))
    if [ $compteur -ge $max_iterations ]; then
        echo "ERREUR : Nombre maximal d'itérations atteint"
        break
    fi
done
```

### 2. Utiliser sleep dans les boucles de surveillance

```bash
# ✅ Éviter de surcharger le CPU
while ! [ -f "/tmp/signal.txt" ]
do
    sleep 1  # Attendre 1 seconde entre chaque vérification
done

# ❌ Consomme 100% du CPU inutilement
while ! [ -f "/tmp/signal.txt" ]
do
    :  # Ne rien faire mais vérifier en continu
done
```

### 3. Valider les entrées utilisateur

```bash
# ✅ Vérifier systématiquement
while true
do
    read -p "Entrez un nombre positif : " nombre
    
    # Vérifier que c'est un nombre
    if ! [[ "$nombre" =~ ^[0-9]+$ ]]; then
        echo "Erreur : entrez un nombre entier"
        continue
    fi
    
    # Vérifier qu'il est positif
    if [ "$nombre" -le 0 ]; then
        echo "Erreur : le nombre doit être positif"
        continue
    fi
    
    # OK, sortir
    break
done
```

### 4. Préférer les doubles crochets pour les tests complexes

```bash
# ✅ Plus lisible et moins d'erreurs
while [[ "$reponse" != "oui" && "$reponse" != "non" ]]
do
    read -p "Répondez par oui ou non : " reponse
done

# ❌ Syntaxe lourde avec crochets simples
while [ "$reponse" != "oui" ] && [ "$reponse" != "non" ]
do
    read -p "Répondez par oui ou non : " reponse
done
```

### 5. Gérer les signaux d'interruption

```bash
# ✅ Nettoyer proprement à l'interruption
trap 'echo "Interruption détectée, nettoyage..."; rm -f /tmp/temp_*; exit' INT TERM

while true
do
    # Créer des fichiers temporaires
    touch "/tmp/temp_$$_$(date +%s)"
    
    sleep 2
done
```

### 6. Commenter les boucles complexes

```bash
# ✅ Expliquer la logique
# Attendre que le service soit démarré
# Timeout après 30 secondes (30 * 1 seconde)
timeout=30
compteur=0

while ! systemctl is-active --quiet mon_service
do
    sleep 1
    ((compteur++))
    
    if [ $compteur -ge $timeout ]; then
        echo "ERREUR : Service non démarré après ${timeout}s"
        exit 1
    fi
done

echo "Service démarré avec succès"
```

### 7. Utiliser des fonctions pour la lisibilité

```bash
# ✅ Encapsuler la logique complexe
fonction_valide_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Boucle plus lisible
while true
do
    read -p "Entrez votre email : " email
    
    if fonction_valide_email "$email"; then
        break
    fi
    
    echo "Email invalide, réessayez"
done
```

---

## 🎓 Résumé

La boucle `while` est un outil puissant et flexible en Bash :

- **Syntaxe** : `while [ condition ]; do commandes; done`
- **Usage principal** : répéter tant qu'une condition est vraie
- **Boucles infinies** : `while true` pour services, menus, monitoring
- **Lecture de fichiers** : `while IFS= read -r ligne; do ... done < fichier`
- **Avec read** : validation d'entrées, interactions utilisateur
- **Contrôle** : `break` pour sortir, `continue` pour passer à l'itération suivante

> [!tip] Astuce finale Testez toujours vos boucles `while` avec des données variées et prévoyez systématiquement une condition de sortie ou un timeout pour éviter les blocages.