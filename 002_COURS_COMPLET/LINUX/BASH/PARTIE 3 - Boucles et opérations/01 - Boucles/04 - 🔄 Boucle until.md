

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

La boucle `until` est une structure de contrôle qui exécute un bloc de commandes **tant qu'une condition reste fausse**. Elle s'arrête dès que la condition devient vraie. C'est l'inverse logique de la boucle `while`.

> [!info] Quand utiliser `until` ? La boucle `until` est particulièrement utile quand vous attendez qu'un événement se produise ou qu'une condition soit satisfaite. Elle rend le code plus lisible dans les scénarios d'attente active.

**Pourquoi c'est important :**

- Clarté du code : exprime naturellement une logique d'attente
- Alternative élégante au `while` avec condition négative
- Très utile pour les scripts de surveillance et d'attente

---

## 📝 Syntaxe et fonctionnement

### Structure de base

```bash
until [ condition ]
do
    # Commandes à exécuter
    # tant que la condition est FAUSSE
done
```

### Forme compacte (sur une ligne)

```bash
until [ condition ]; do commandes; done
```

> [!example] Exemple simple
> 
> ```bash
> compteur=1
> 
> until [ $compteur -gt 5 ]
> do
>     echo "Itération $compteur"
>     ((compteur++))
> done
> 
> echo "Boucle terminée, compteur = $compteur"
> ```
> 
> **Sortie :**
> 
> ```
> Itération 1
> Itération 2
> Itération 3
> Itération 4
> Itération 5
> Boucle terminée, compteur = 6
> ```

### Syntaxe avec double crochets (recommandé)

```bash
until [[ condition ]]
do
    commandes
done
```

> [!tip] Avantage de `[[ ]]` Les doubles crochets offrent une syntaxe plus moderne, évitent les problèmes de word splitting et permettent des opérateurs plus intuitifs comme `==`, `!=`, `&&`, `||`.

---

## ❌ Condition fausse pour continuer

### Principe fondamental

La boucle `until` continue **tant que la condition est fausse (retourne un code de sortie non nul)**. Elle s'arrête quand la condition devient **vraie (retourne 0)**.

|État de la condition|Code retour|Comportement|
|---|---|---|
|Fausse|Non nul (1, 2, ...)|✅ Continue la boucle|
|Vraie|0|⛔ Arrête la boucle|

> [!example] Attendre qu'un fichier existe
> 
> ```bash
> fichier="/tmp/signal.txt"
> 
> until [ -f "$fichier" ]
> do
>     echo "En attente du fichier $fichier..."
>     sleep 2
> done
> 
> echo "Le fichier est apparu !"
> ```

### Avec commandes comme condition

```bash
# Attendre qu'un service réponde
until ping -c 1 google.com &> /dev/null
do
    echo "Pas de connexion internet, nouvelle tentative..."
    sleep 5
done

echo "Connexion internet établie !"
```

> [!warning] Code de retour Bash évalue la condition comme fausse si le code de retour est différent de 0. Une commande qui échoue retourne généralement 1 ou plus, ce qui maintient la boucle active.

---

## 🔄 Différence fondamentale avec while

### Comparaison logique

|Aspect|`while`|`until`|
|---|---|---|
|**Continue quand**|Condition VRAIE|Condition FAUSSE|
|**S'arrête quand**|Condition FAUSSE|Condition VRAIE|
|**Logique**|Faire tant que...|Faire jusqu'à ce que...|
|**Lisibilité**|Bonne pour actions répétées|Meilleure pour attente|

### Exemple comparatif

```bash
# Avec while : continue tant que < 5
compteur=1
while [ $compteur -lt 5 ]
do
    echo "While: $compteur"
    ((compteur++))
done

# Avec until : continue jusqu'à >= 5
compteur=1
until [ $compteur -ge 5 ]
do
    echo "Until: $compteur"
    ((compteur++))
done
```

> [!info] Équivalence `until [ condition ]` est strictement équivalent à `while [ ! condition ]`
> 
> Mais `until` est souvent plus lisible quand on exprime une attente.

### Quand préférer `until` ?

```bash
# ✅ until est plus naturel ici
until [ -f /tmp/ready ]
do
    echo "En attente..."
    sleep 1
done

# ❌ while nécessite une négation moins intuitive
while [ ! -f /tmp/ready ]
do
    echo "En attente..."
    sleep 1
done
```

> [!tip] Règle de lisibilité Utilisez `until` quand vous exprimez une attente ou un objectif à atteindre. Utilisez `while` quand vous décrivez une condition de continuation.

---

## 💡 Cas d'usage typiques

### 1. Attente de disponibilité d'un service

```bash
# Attendre qu'un port soit ouvert
port=8080
host="localhost"

until nc -z $host $port 2>/dev/null
do
    echo "Le port $port n'est pas encore ouvert..."
    sleep 2
done

echo "Le service sur le port $port est disponible !"
```

### 2. Boucle de retry avec tentatives limitées

```bash
# Tentatives d'exécution jusqu'au succès (max 5 fois)
tentatives=0
max_tentatives=5

until curl -s https://api.example.com/data || [ $tentatives -ge $max_tentatives ]
do
    ((tentatives++))
    echo "Tentative $tentatives/$max_tentatives échouée, nouvelle tentative dans 3s..."
    sleep 3
done

if [ $tentatives -ge $max_tentatives ]; then
    echo "Échec après $max_tentatives tentatives"
    exit 1
fi
```

### 3. Attendre une entrée utilisateur valide

```bash
# Demander un nombre valide
until [[ $reponse =~ ^[0-9]+$ ]]
do
    read -p "Entrez un nombre entier positif : " reponse
    
    if [[ ! $reponse =~ ^[0-9]+$ ]]; then
        echo "❌ Entrée invalide, veuillez entrer un nombre"
    fi
done

echo "✅ Vous avez entré : $reponse"
```

### 4. Surveillance de processus

```bash
# Attendre la fin d'un processus
pid=12345

until ! kill -0 $pid 2>/dev/null
do
    echo "Processus $pid toujours actif..."
    sleep 5
done

echo "Le processus $pid s'est terminé"
```

### 5. Attente de disponibilité de ressources

```bash
# Attendre qu'il y ait assez d'espace disque
seuil_mb=1000

until [ $(df /tmp | awk 'NR==2 {print $4}') -gt $seuil_mb ]
do
    echo "Espace disque insuffisant sur /tmp, attente..."
    sleep 10
done

echo "Espace disque disponible, traitement lancé"
```

### 6. Boucle de menu avec sortie conditionnelle

```bash
# Menu jusqu'à ce que l'utilisateur choisisse "quitter"
choix=""

until [[ $choix == "q" ]]
do
    echo "=== Menu ==="
    echo "1. Option A"
    echo "2. Option B"
    echo "q. Quitter"
    read -p "Votre choix : " choix
    
    case $choix in
        1) echo "Vous avez choisi A" ;;
        2) echo "Vous avez choisi B" ;;
        q) echo "Au revoir !" ;;
        *) echo "Choix invalide" ;;
    esac
    echo
done
```

---

## ⚠️ Pièges courants

### 1. Boucle infinie par oubli de modification

```bash
# ❌ PIÈGE : La condition ne change jamais
compteur=1
until [ $compteur -gt 5 ]
do
    echo "Itération"
    # Oubli d'incrémenter : boucle infinie !
done

# ✅ CORRECT : Modifier la variable de contrôle
compteur=1
until [ $compteur -gt 5 ]
do
    echo "Itération $compteur"
    ((compteur++))  # Incrémentation nécessaire
done
```

> [!warning] Toujours prévoir une sortie Assurez-vous que la condition peut devenir vraie à un moment donné, sinon vous créez une boucle infinie.

### 2. Confusion avec la logique inversée

```bash
# ❌ ERREUR : Penser comme un while
until [ $x -eq 10 ]  # Continue JUSQU'À x == 10
do
    # Cette boucle s'arrête quand x vaut 10
done

# Si vous voulez continuer TANT QUE x == 10, utilisez while
while [ $x -eq 10 ]
do
    # Cette boucle continue tant que x vaut 10
done
```

### 3. Conditions multiples mal formées

```bash
# ❌ Mauvaise syntaxe
until [ $a -gt 5 ] && [ $b -lt 10 ]  # Opérateur && entre crochets séparés
do
    commandes
done

# ✅ Correctes
until [ $a -gt 5 -a $b -lt 10 ]     # -a pour AND dans [ ]
until [[ $a -gt 5 && $b -lt 10 ]]   # && dans [[ ]] (recommandé)
```

### 4. Oublier les guillemets avec les variables

```bash
# ❌ Risque d'erreur si la variable est vide ou contient des espaces
until [ $fichier = "config.txt" ]
do
    commandes
done

# ✅ Toujours quoter les variables
until [ "$fichier" = "config.txt" ]
do
    commandes
done
```

### 5. Ne pas gérer le timeout

```bash
# ❌ Pas de limite de temps
until curl -s https://api.exemple.com
do
    sleep 5
    # Pourrait attendre indéfiniment
done

# ✅ Ajouter un timeout
debut=$(date +%s)
timeout=60

until curl -s https://api.exemple.com || [ $(($(date +%s) - debut)) -gt $timeout ]
do
    echo "Tentative..."
    sleep 5
done

if [ $(($(date +%s) - debut)) -gt $timeout ]; then
    echo "Timeout atteint"
    exit 1
fi
```

---

## ✅ Bonnes pratiques

### 1. Rendre la condition de sortie évidente

```bash
# ✅ Variable explicite
service_pret=false

until $service_pret
do
    if systemctl is-active --quiet mon-service; then
        service_pret=true
    else
        echo "Service pas encore prêt..."
        sleep 2
    fi
done
```

### 2. Toujours ajouter un timeout pour les attentes réseau

```bash
# ✅ Fonction réutilisable avec timeout
attendre_service() {
    local url=$1
    local timeout=${2:-30}  # 30s par défaut
    local debut=$(date +%s)
    
    until curl -sf "$url" > /dev/null || [ $(($(date +%s) - debut)) -gt $timeout ]
    do
        echo "En attente de $url..."
        sleep 2
    done
    
    if [ $(($(date +%s) - debut)) -gt $timeout ]; then
        echo "Timeout : $url n'a pas répondu en ${timeout}s"
        return 1
    fi
    
    echo "Service $url disponible"
    return 0
}

# Utilisation
attendre_service "http://localhost:8080/health" 60
```

### 3. Fournir un retour visuel

```bash
# ✅ Indicateur de progression
compteur=0
max=20

until [ -f /tmp/fichier.txt ] || [ $compteur -ge $max ]
do
    echo -n "."  # Affiche des points sans retour à la ligne
    ((compteur++))
    sleep 1
done

echo  # Retour à la ligne final

if [ $compteur -ge $max ]; then
    echo "❌ Timeout"
else
    echo "✅ Fichier trouvé"
fi
```

### 4. Utiliser des fonctions pour la lisibilité

```bash
# ✅ Condition dans une fonction
est_service_actif() {
    systemctl is-active --quiet "$1"
}

until est_service_actif "nginx"
do
    echo "Nginx pas encore actif..."
    sleep 2
done

echo "Nginx est actif !"
```

### 5. Documenter la condition de sortie

```bash
# ✅ Commentaire clair
# Boucle jusqu'à ce que le fichier de lock soit supprimé
until [ ! -f /var/lock/mon_app.lock ]
do
    echo "Application verrouillée, attente..."
    sleep 5
done
```

---

## 🚀 Astuces avancées

### 1. Combiner until avec des sous-shells

```bash
# Attendre que toutes les tâches en arrière-plan soient terminées
until (jobs -r | wc -l | grep -q '^0$')
do
    echo "$(jobs -r | wc -l) tâches en cours..."
    sleep 2
done

echo "Toutes les tâches sont terminées"
```

### 2. Utiliser until avec des pipes

```bash
# Attendre qu'une ligne spécifique apparaisse dans un log
until grep -q "Server started" /var/log/app.log
do
    echo "Attente du démarrage du serveur..."
    sleep 1
done

echo "Serveur démarré avec succès"
```

### 3. Until avec compteur pour debug

```bash
# Compteur d'itérations pour le débogage
iteration=0

until [ -f /tmp/ready ]
do
    ((iteration++))
    echo "[Itération $iteration] Attente..."
    
    # Afficher des stats toutes les 10 itérations
    if [ $((iteration % 10)) -eq 0 ]; then
        echo "--- Déjà $iteration secondes d'attente ---"
    fi
    
    sleep 1
done
```

### 4. Condition complexe avec évaluation paresseuse

```bash
# Utiliser && et || pour court-circuiter l'évaluation
until [[ -f "$fichier" && $(stat -c%s "$fichier") -gt 0 ]]
do
    # N'évalue la taille que si le fichier existe
    echo "Fichier inexistant ou vide..."
    sleep 2
done
```

### 5. Until dans une fonction pour réutilisation

```bash
# Fonction générique d'attente
attendre_jusqu_a() {
    local condition="$1"
    local message="${2:-En attente...}"
    local delai="${3:-2}"
    
    until eval "$condition"
    do
        echo "$message"
        sleep "$delai"
    done
}

# Utilisations
attendre_jusqu_a "[ -f /tmp/done ]" "Attente du fichier..." 1
attendre_jusqu_a "ping -c1 google.com &>/dev/null" "Attente connexion..." 5
```

### 6. Until avec signal trap

```bash
# Sortir proprement d'une boucle until sur SIGINT
interrompu=false

trap 'interrompu=true' INT

until [ -f /tmp/signal ] || $interrompu
do
    echo "En attente (Ctrl+C pour annuler)..."
    sleep 2
done

if $interrompu; then
    echo "Interruption par l'utilisateur"
    exit 130
fi
```

### 7. Évaluation dynamique de condition

```bash
# Condition définie dynamiquement
condition_cmd="[ \$(ls -1 /tmp/*.txt 2>/dev/null | wc -l) -ge 5 ]"

until eval "$condition_cmd"
do
    echo "Moins de 5 fichiers .txt dans /tmp"
    sleep 3
done

echo "Au moins 5 fichiers .txt présents"
```

---

> [!tip] Résumé
> 
> - `until` exécute des commandes **jusqu'à ce qu'une condition devienne vraie**
> - C'est l'inverse logique de `while` : continue quand la condition est **fausse**
> - Idéal pour les scénarios d'**attente active** et de **surveillance**
> - Toujours prévoir une **condition de sortie** et un **timeout** pour éviter les boucles infinies
> - Préférer `until` à `while [ ! ... ]` quand cela améliore la lisibilité