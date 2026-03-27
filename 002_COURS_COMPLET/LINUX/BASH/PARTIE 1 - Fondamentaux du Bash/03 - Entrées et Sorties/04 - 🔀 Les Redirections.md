
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

## 🎯 Introduction aux redirections

Les redirections permettent de **contrôler les flux d'entrée et de sortie** d'une commande. Par défaut, une commande lit depuis le clavier (entrée standard) et affiche sur le terminal (sortie standard et erreur standard). Les redirections permettent de modifier ce comportement pour :

- Sauvegarder les résultats dans des fichiers
- Lire des données depuis des fichiers
- Filtrer ou ignorer certains messages
- Combiner plusieurs flux

> [!info] Pourquoi c'est important Les redirections sont essentielles pour l'automatisation, la journalisation (logs), le traitement de données et la création de scripts robustes. Elles permettent de gérer proprement les sorties et erreurs de vos programmes.

---

## 🔢 Les descripteurs de fichiers

Chaque processus Unix/Linux possède trois flux standards, identifiés par des **descripteurs de fichiers** (file descriptors) :

|Descripteur|Nom|Symbole|Description|Destination par défaut|
|---|---|---|---|---|
|**0**|Entrée standard|`stdin`|Flux d'entrée|Clavier|
|**1**|Sortie standard|`stdout`|Flux de sortie normale|Terminal|
|**2**|Erreur standard|`stderr`|Flux d'erreurs|Terminal|

> [!example] Visualisation des flux
> 
> ```bash
> # Une commande typique
> ls -l fichier.txt
> 
> # Utilise :
> # - stdin (0) : pas de lecture au clavier ici
> # - stdout (1) : affiche la liste des fichiers
> # - stderr (2) : affiche les erreurs (ex: fichier introuvable)
> ```

Ces descripteurs sont la base de toutes les redirections. Comprendre leur fonctionnement est essentiel pour maîtriser les redirections.

---

## 📤 Redirection de sortie standard

### Écrasement avec `>`

L'opérateur `>` redirige la sortie standard (stdout) vers un fichier en **écrasant** son contenu.

**Syntaxe :**

```bash
commande > fichier
# Équivalent explicite :
commande 1> fichier
```

> [!example] Exemples pratiques
> 
> ```bash
> # Sauvegarder une liste de fichiers
> ls -l > liste_fichiers.txt
> 
> # Créer un fichier avec du texte
> echo "Bonjour le monde" > message.txt
> 
> # Sauvegarder la sortie d'une recherche
> find /home -name "*.pdf" > pdfs_trouves.txt
> 
> # Créer un fichier vide (équivalent à touch)
> > fichier_vide.txt
> ```

> [!warning] Attention à l'écrasement Le contenu précédent du fichier est **complètement perdu** ! Si le fichier n'existe pas, il est créé automatiquement.
> 
> ```bash
> echo "Première ligne" > fichier.txt
> echo "Deuxième ligne" > fichier.txt
> # Résultat : fichier.txt ne contient que "Deuxième ligne"
> ```

### Ajout avec `>>`

L'opérateur `>>` redirige la sortie standard en **ajoutant** à la fin du fichier sans écraser le contenu existant.

**Syntaxe :**

```bash
commande >> fichier
# Équivalent explicite :
commande 1>> fichier
```

> [!example] Exemples pratiques
> 
> ```bash
> # Ajouter des lignes à un fichier de log
> echo "[$(date)] Démarrage du script" >> logs.txt
> echo "[$(date)] Traitement terminé" >> logs.txt
> 
> # Concaténer plusieurs sorties
> cat fichier1.txt > resultat.txt
> cat fichier2.txt >> resultat.txt
> cat fichier3.txt >> resultat.txt
> 
> # Ajouter des informations système
> echo "=== État du système ===" >> rapport.txt
> df -h >> rapport.txt
> free -h >> rapport.txt
> ```

> [!tip] Astuce pour les logs Utilisez toujours `>>` pour les fichiers de logs afin de conserver l'historique complet :
> 
> ```bash
> ./mon_script.sh >> application.log 2>&1
> ```

**Tableau comparatif :**

|Opérateur|Comportement|Usage typique|
|---|---|---|
|`>`|Écrase le fichier|Sauvegardes ponctuelles, exports|
|`>>`|Ajoute au fichier|Logs, accumulation de données|

---

## 📥 Redirection d'entrée standard

L'opérateur `<` permet de fournir le contenu d'un fichier comme **entrée** à une commande.

**Syntaxe :**

```bash
commande < fichier
# Équivalent explicite :
commande 0< fichier
```

> [!example] Exemples pratiques
> 
> ```bash
> # Compter les lignes d'un fichier
> wc -l < fichier.txt
> 
> # Trier le contenu d'un fichier
> sort < noms.txt
> 
> # Envoyer un email avec le contenu d'un fichier
> mail -s "Rapport" user@example.com < rapport.txt
> 
> # Lire un script SQL
> mysql -u root -p database_name < script.sql
> ```

> [!info] Différence avec un argument
> 
> ```bash
> # Avec redirection (stdin)
> wc -l < fichier.txt
> # Affiche : 42
> 
> # Avec argument
> wc -l fichier.txt
> # Affiche : 42 fichier.txt
> 
> # La redirection ne passe pas le nom du fichier à la commande
> ```

**Combinaison entrée/sortie :**

```bash
# Trier un fichier et sauvegarder le résultat
sort < entree.txt > sortie.txt

# Traiter et filtrer un fichier
grep "erreur" < logs.txt > erreurs.txt
```

---

## ❌ Redirection d'erreur standard

L'opérateur `2>` redirige les **messages d'erreur** (stderr) vers un fichier.

**Syntaxe :**

```bash
commande 2> fichier_erreurs
```

> [!example] Exemples pratiques
> 
> ```bash
> # Sauvegarder uniquement les erreurs
> find / -name "*.conf" 2> erreurs.txt
> 
> # Séparer sorties et erreurs
> ls fichier_existant fichier_inexistant > sorties.txt 2> erreurs.txt
> 
> # Compilation avec gestion des erreurs
> gcc programme.c -o programme 2> erreurs_compilation.txt
> ```

> [!warning] Pourquoi séparer stdout et stderr ? Les erreurs ne doivent pas se mélanger avec les données valides :
> 
> ```bash
> # Mauvais : erreurs mélangées avec les résultats
> find / -name "*.txt" > resultats.txt
> 
> # Bon : séparation claire
> find / -name "*.txt" > resultats.txt 2> erreurs.txt
> ```

**Ajout d'erreurs :**

```bash
# Ajouter les erreurs sans écraser
commande 2>> fichier_erreurs.log
```

---

## 🔗 Redirections combinées

### Rediriger stdout et stderr vers le même fichier

**Méthode moderne (recommandée) :**

```bash
commande &> fichier
# Ou pour ajout :
commande &>> fichier
```

**Méthode classique :**

```bash
commande > fichier 2>&1
# Pour ajout :
commande >> fichier 2>&1
```

> [!info] Explication de `2>&1`
> 
> - `2>` : redirige stderr
> - `&1` : vers le descripteur 1 (stdout)
> - Donc stderr va au même endroit que stdout

> [!example] Exemples pratiques
> 
> ```bash
> # Tout sauvegarder dans un seul fichier
> ./script.sh &> execution.log
> 
> # Ajouter toutes les sorties
> ./tache_nocturne.sh &>> logs_quotidiens.log
> 
> # Ancienne syntaxe (équivalent)
> ./script.sh > execution.log 2>&1
> ```

### Rediriger stderr vers stdout

Utile pour utiliser stdout dans un pipe avec les erreurs incluses :

```bash
# Envoyer tout (sorties + erreurs) dans un grep
commande 2>&1 | grep "mot_clé"

# Compter toutes les lignes (sorties + erreurs)
find / -name "*.txt" 2>&1 | wc -l
```

### Échanger stdout et stderr

Technique avancée pour inverser les flux :

```bash
# Échanger stdout (1) et stderr (2)
commande 3>&1 1>&2 2>&3 3>&-

# Explication :
# 3>&1 : sauvegarder stdout dans descripteur 3
# 1>&2 : stdout devient stderr
# 2>&3 : stderr devient l'ancien stdout (sauvegardé en 3)
# 3>&- : fermer le descripteur 3
```

> [!tip] Cas d'usage de l'échange Quand vous voulez capturer seulement stderr dans une variable mais que la commande affiche beaucoup sur stdout :
> 
> ```bash
> erreurs=$(commande 3>&1 1>&2 2>&3)
> ```

---

## 🕳️ Le trou noir `/dev/null`

`/dev/null` est un fichier spécial qui **détruit toutes les données** qu'on lui envoie. C'est le "trou noir" du système.

**Utilisation :**

```bash
# Ignorer complètement la sortie standard
commande > /dev/null

# Ignorer les erreurs
commande 2> /dev/null

# Ignorer tout (sorties et erreurs)
commande &> /dev/null
# Ou :
commande > /dev/null 2>&1
```

> [!example] Cas d'usage typiques
> 
> ```bash
> # Vérifier si une commande existe (sans affichage)
> command -v git > /dev/null 2>&1 && echo "Git est installé"
> 
> # Tester si un fichier existe silencieusement
> grep "pattern" fichier > /dev/null 2>&1
> if [ $? -eq 0 ]; then
>     echo "Pattern trouvé"
> fi
> 
> # Supprimer les avertissements gênants
> find / -name "*.tmp" 2> /dev/null
> 
> # Script silencieux
> ./script_verbeux.sh > /dev/null 2>&1
> ```

> [!warning] À utiliser avec précaution Ne cachez pas systématiquement les erreurs ! Vous pourriez masquer des problèmes importants.
> 
> ```bash
> # Mauvais : vous ne verrez jamais les erreurs
> script_critique.sh 2> /dev/null
> 
> # Bon : au moins logger les erreurs
> script_critique.sh 2>> erreurs.log
> ```

**Lecture depuis `/dev/null` :**

```bash
# Fournir une entrée vide
commande < /dev/null

# Utile pour forcer la non-interactivité
ssh user@host < /dev/null
```

---

## 🔬 Techniques avancées

### Here Documents (Heredoc)

Permet de passer un bloc de texte multi-lignes directement comme entrée :

```bash
# Syntaxe de base
commande << DELIMITATION
ligne 1
ligne 2
ligne 3
DELIMITATION
```

> [!example] Exemples pratiques
> 
> ```bash
> # Créer un fichier multi-lignes
> cat > config.txt << EOF
> server=localhost
> port=8080
> debug=true
> EOF
> 
> # Envoyer des commandes à un programme
> mysql -u root -p database_name << ENDSQL
> CREATE TABLE users (
>     id INT PRIMARY KEY,
>     name VARCHAR(100)
> );
> INSERT INTO users VALUES (1, 'Alice');
> ENDSQL
> 
> # Script Python embarqué dans un script Bash
> python3 << PYTHON
> import sys
> print(f"Python version: {sys.version}")
> for i in range(5):
>     print(f"Ligne {i}")
> PYTHON
> ```

> [!tip] Heredoc avec suppression de l'indentation Utilisez `<<-` pour ignorer les tabulations en début de ligne :
> 
> ```bash
> if true; then
>     cat <<- EOF
> 		Ce texte est indenté dans le code
> 		Mais l'indentation sera supprimée
> 	EOF
> fi
> ```

### Here Strings

Version courte pour passer une seule ligne :

```bash
# Syntaxe
commande <<< "texte"
```

> [!example] Exemples
> 
> ```bash
> # Passer une variable à une commande
> grep "motif" <<< "$ma_variable"
> 
> # Conversion base64
> base64 <<< "texte à encoder"
> 
> # Calcul avec bc
> bc <<< "scale=2; 22/7"
> 
> # Test de validation
> read -r reponse <<< "oui"
> ```

### Redirection de plage de descripteurs

Ouvrir et manipuler des descripteurs personnalisés :

```bash
# Ouvrir un descripteur en lecture
exec 3< fichier.txt

# Lire depuis ce descripteur
read ligne <&3

# Fermer le descripteur
exec 3<&-

# Ouvrir un descripteur en écriture
exec 4> sortie.txt
echo "Données" >&4
exec 4>&-
```

> [!example] Cas d'usage : fichiers temporaires
> 
> ```bash
> # Créer un descripteur temporaire
> exec 5> >(logger -t mon_script)
> 
> # Tout ce qui va vers 5 est envoyé au syslog
> echo "Message de log" >&5
> 
> # Fermer
> exec 5>&-
> ```

### Process Substitution

Traiter la sortie d'une commande comme un fichier :

```bash
# Syntaxe : <(commande)
diff <(ls dir1) <(ls dir2)

# Comparer deux sorties triées
diff <(sort fichier1.txt) <(sort fichier2.txt)

# Multiples sources
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)
```

---

## ⚠️ Pièges courants

### Ordre des redirections

L'ordre est crucial avec `2>&1` :

```bash
# ❌ FAUX : stderr va vers l'ancien stdout (le terminal)
commande 2>&1 > fichier

# ✅ CORRECT : stderr va vers le nouveau stdout (le fichier)
commande > fichier 2>&1
```

> [!warning] Explication Les redirections sont évaluées de **gauche à droite** :
> 
> - Version fausse : `2>&1` copie stderr vers stdout (terminal), puis `>` redirige stdout vers le fichier, mais stderr reste au terminal
> - Version correcte : `>` redirige stdout vers le fichier, puis `2>&1` copie stderr vers stdout (maintenant le fichier)

### Écrasement accidentel

```bash
# ❌ DANGER : écrase le fichier source !
sort fichier.txt > fichier.txt

# ✅ CORRECT : utiliser un fichier temporaire
sort fichier.txt > fichier.txt.tmp && mv fichier.txt.tmp fichier.txt

# ✅ OU : utiliser l'option -o de sort
sort -o fichier.txt fichier.txt
```

### Redirection dans les boucles

```bash
# ❌ Inefficace : ouvre/ferme le fichier à chaque itération
for i in {1..1000}; do
    echo "Ligne $i" >> fichier.txt
done

# ✅ Meilleur : une seule ouverture
{
    for i in {1..1000}; do
        echo "Ligne $i"
    done
} >> fichier.txt

# ✅ Ou : grouper avec parenthèses (sous-shell)
(for i in {1..1000}; do
    echo "Ligne $i"
done) >> fichier.txt
```

### Permissions insuffisantes

```bash
# ❌ Erreur si pas de droits d'écriture
echo "texte" > /root/fichier.txt

# ✅ Utiliser sudo avec tee
echo "texte" | sudo tee /root/fichier.txt > /dev/null

# ✅ Ou shell avec privilèges
sudo bash -c 'echo "texte" > /root/fichier.txt'
```

---

## ✅ Bonnes pratiques

### 1. Toujours vérifier les codes de retour

```bash
# Rediriger ET vérifier le succès
if commande > sortie.txt 2> erreurs.txt; then
    echo "Succès"
else
    echo "Échec, voir erreurs.txt"
    exit 1
fi
```

### 2. Utiliser des chemins absolus dans les scripts

```bash
# ❌ Risqué : dépend du répertoire courant
./script.sh > logs.txt

# ✅ Sûr : chemin absolu
./script.sh > /var/log/monapp/logs.txt
```

### 3. Logger systématiquement dans les scripts de production

```bash
#!/bin/bash

LOGFILE="/var/log/mon_script.log"

# Tout logger automatiquement
exec 1> >(tee -a "$LOGFILE")
exec 2>&1

# Maintenant tout est dans le log ET affiché
echo "Début du script"
# ... reste du script
```

### 4. Utiliser des fichiers temporaires sécurisés

```bash
# ✅ Créer un fichier temporaire unique
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Utiliser le fichier temporaire
grep "pattern" fichier.txt > "$TMPFILE"
sort "$TMPFILE" > resultat.txt

# Le trap garantit le nettoyage
```

### 5. Documenter les redirections complexes

```bash
# Bon exemple avec commentaires
{
    # Génération du rapport
    echo "=== Rapport système ==="
    echo "Date: $(date)"
    echo ""
    
    # Espace disque
    echo "Espace disque:"
    df -h
    
    # Processus
    echo "Processus actifs:"
    ps aux | head -20
    
} > rapport.txt 2>&1  # Tout dans le rapport, erreurs comprises
```

### 6. Préférer `&>` à `> fichier 2>&1`

```bash
# ✅ Moderne et lisible
commande &> tout.log

# ❌ Ancien style (mais fonctionnel)
commande > tout.log 2>&1
```

### 7. Attention aux shells non-bash

```bash
# Bash uniquement
commande &> fichier

# POSIX compatible (fonctionne partout)
commande > fichier 2>&1
```

---

## 🎓 Résumé des opérateurs

|Opérateur|Description|Exemple|
|---|---|---|
|`>`|Redirige stdout (écrase)|`ls > liste.txt`|
|`>>`|Redirige stdout (ajoute)|`echo "ligne" >> log.txt`|
|`<`|Redirige stdin|`sort < entree.txt`|
|`2>`|Redirige stderr (écrase)|`cmd 2> err.txt`|
|`2>>`|Redirige stderr (ajoute)|`cmd 2>> err.log`|
|`&>`|Redirige stdout et stderr|`cmd &> tout.txt`|
|`2>&1`|Redirige stderr vers stdout|`cmd > out.txt 2>&1`|
|`<<`|Here document|`cat << EOF`|
|`<<<`|Here string|`bc <<< "2+2"`|
|`>&`|Duplique descripteur|`exec 2>&1`|
|`<&-`|Ferme descripteur en lecture|`exec 3<&-`|
|`>&-`|Ferme descripteur en écriture|`exec 4>&-`|

---

> [!tip] Astuce finale Pour déboguer vos redirections, utilisez `set -x` au début de votre script pour voir exactement comment Bash interprète vos commandes :
> 
> ```bash
> set -x
> commande > fichier 2>&1
> set +x
> ```