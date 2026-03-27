

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

## Introduction aux pipes

Les **pipes** (symbole `|`) sont l'un des concepts les plus puissants d'Unix/Linux. Ils permettent de connecter la sortie standard (stdout) d'une commande directement à l'entrée standard (stdin) d'une autre commande, créant ainsi un flux de données entre processus.

> [!info] Philosophie Unix Les pipes incarnent la philosophie Unix : "Write programs that do one thing and do it well. Write programs to work together." Au lieu de créer des outils monolithiques, on combine des outils simples et spécialisés.

### Pourquoi utiliser les pipes ?

- **Efficacité** : Traitement en flux sans fichiers temporaires
- **Performance** : Les données circulent en mémoire
- **Modularité** : Combinaison infinie de commandes
- **Lisibilité** : Code plus clair et maintenable

---

## Syntaxe de base : commande1 | commande2

### Structure fondamentale

```bash
commande1 | commande2
```

Le pipe `|` redirige la sortie standard de `commande1` vers l'entrée standard de `commande2`.

> [!example] Exemple simple
> 
> ```bash
> # Afficher les fichiers et compter les lignes
> ls -l | wc -l
> 
> # Afficher les processus et chercher un programme
> ps aux | grep firefox
> 
> # Lire un fichier et afficher les 10 premières lignes
> cat fichier.txt | head -n 10
> ```

### Schéma conceptuel

```
┌────────────┐         ┌────────────┐
│ commande1  │ stdout  │ commande2  │
│            ├────────>│            │
│  (génère)  │   |     │ (traite)   │
└────────────┘         └────────────┘
```

> [!warning] Important Seule la **sortie standard** (stdout) est redirigée par le pipe. Les erreurs (stderr) continuent d'apparaître à l'écran. Pour rediriger aussi les erreurs : `commande1 2>&1 | commande2`

### Différence avec les redirections

|Opérateur|Fonction|Exemple|
|---|---|---|
|`\|`|Connecte stdout à stdin|`cat file \| grep mot`|
|`>`|Redirige stdout vers un fichier|`ls > liste.txt`|
|`>>`|Ajoute stdout à un fichier|`echo "texte" >> log.txt`|
|`<`|Redirige un fichier vers stdin|`sort < data.txt`|

---

## Chaînage de commandes

Le véritable pouvoir des pipes réside dans la capacité de chaîner plusieurs commandes pour créer des pipelines complexes.

### Pipelines multiples

```bash
# Pipeline à 3 étapes
commande1 | commande2 | commande3

# Pipeline à N étapes
cmd1 | cmd2 | cmd3 | cmd4 | ... | cmdN
```

> [!example] Exemples de chaînage
> 
> ```bash
> # Trouver les 5 fichiers les plus volumineux
> du -ah | sort -rh | head -n 5
> 
> # Lister les utilisateurs connectés uniques
> who | cut -d' ' -f1 | sort | uniq
> 
> # Analyser les logs : filtrer, extraire, compter
> cat access.log | grep "ERROR" | awk '{print $4}' | sort | uniq -c
> 
> # Pipeline complexe avec formatage
> ps aux | grep -v grep | awk '{print $2, $11}' | column -t | sort -k2
> ```

### Flux de données dans un pipeline

```
Données brutes
     ↓
 Commande1 (filtre)
     ↓
 Commande2 (transforme)
     ↓
 Commande3 (agrège)
     ↓
 Commande4 (formate)
     ↓
Résultat final
```

### Performance des pipelines

> [!tip] Optimisation Les commandes dans un pipeline s'exécutent en **parallèle**, pas séquentiellement. Chaque commande démarre dès que la précédente produit des données.

```bash
# ❌ Inefficace : crée des fichiers temporaires
cat fichier.txt > temp1
grep "motif" temp1 > temp2
sort temp2 > temp3
uniq temp3 > resultat.txt
rm temp1 temp2 temp3

# ✅ Efficace : pipeline direct
cat fichier.txt | grep "motif" | sort | uniq > resultat.txt
```

### Débugger un pipeline

Pour comprendre ce qui se passe à chaque étape :

```bash
# Insérer 'tee' pour voir les données intermédiaires
cat fichier.txt | tee etape1.txt | grep "motif" | tee etape2.txt | sort
```

---

## Utilisation avec grep, awk, sed

Ces trois outils sont les piliers du traitement de texte en ligne de commande et s'utilisent fréquemment avec des pipes.

### Avec grep (recherche de motifs)

`grep` filtre les lignes contenant un motif spécifique.

```bash
# Filtrer les lignes contenant "error"
cat log.txt | grep "error"

# Filtrer les lignes ne contenant PAS "success" (-v = inverse)
ps aux | grep -v "grep"

# Recherche insensible à la casse (-i)
cat users.txt | grep -i "admin"

# Compter les occurrences (-c)
cat access.log | grep "404" | wc -l

# Afficher le contexte (2 lignes avant/après)
cat code.py | grep -C 2 "def main"
```

> [!example] Cas d'usage courants avec grep
> 
> ```bash
> # Trouver les processus gourmands en CPU
> ps aux | grep -v USER | sort -nrk 3 | head -5
> 
> # Chercher une IP dans les logs
> cat access.log | grep "192.168.1.100"
> 
> # Lister les fichiers modifiés aujourd'hui
> ls -l | grep "$(date '+%b %e')"
> ```

### Avec awk (traitement de colonnes)

`awk` excelle dans le traitement de données tabulaires (colonnes).

```bash
# Extraire une colonne spécifique
ps aux | awk '{print $2}'        # 2ème colonne (PID)

# Extraire plusieurs colonnes
ps aux | awk '{print $1, $2, $11}'  # user, PID, commande

# Avec condition
ps aux | awk '$3 > 50 {print $0}'  # CPU > 50%

# Calculs et formatage
df -h | awk 'NR>1 {print $5, $6}' | column -t
```

> [!example] Exemples avancés avec awk
> 
> ```bash
> # Somme d'une colonne
> cat ventes.txt | awk '{sum += $3} END {print "Total:", sum}'
> 
> # Formatage personnalisé
> ps aux | awk '{printf "%-10s %5d %s\n", $1, $2, $11}'
> 
> # Filtrage complexe
> cat access.log | awk '$9 == 404 {print $1, $7}'
> 
> # Avec séparateur personnalisé (-F)
> cat /etc/passwd | awk -F: '{print $1, $3}'  # username et UID
> ```

### Avec sed (édition de flux)

`sed` permet de transformer le texte à la volée (substitutions, suppressions, insertions).

```bash
# Substitution simple
echo "hello" | sed 's/hello/bonjour/'

# Substitution globale (toutes les occurrences)
cat fichier.txt | sed 's/old/new/g'

# Supprimer des lignes
cat fichier.txt | sed '/motif/d'

# Garder seulement certaines lignes
cat fichier.txt | sed -n '/motif/p'

# Substitution avec regex
cat urls.txt | sed 's/http:/https:/g'
```

> [!example] Cas d'usage courants avec sed
> 
> ```bash
> # Nettoyer les espaces multiples
> cat data.txt | sed 's/  */ /g'
> 
> # Supprimer les lignes vides
> cat fichier.txt | sed '/^$/d'
> 
> # Extraire des lignes par numéro
> cat fichier.txt | sed -n '10,20p'  # lignes 10 à 20
> 
> # Remplacements multiples
> cat config.txt | sed 's/dev/prod/g; s/localhost/server.com/g'
> 
> # Ajouter du texte en début de ligne
> cat liste.txt | sed 's/^/- /'
> ```

### Combiner grep, awk et sed

```bash
# Pipeline complet d'analyse de logs
cat access.log | \
  grep "2024-01-15" | \              # Filtrer par date
  awk '{print $1, $9}' | \           # Extraire IP et code status
  sed 's/ /,/g' | \                  # Convertir en CSV
  sort | uniq -c | \                 # Compter les occurrences
  sort -rn | \                       # Trier par fréquence
  head -10                           # Top 10

# Extraction et transformation de données
ps aux | \
  grep -v "grep" | \                 # Exclure grep lui-même
  awk '$3 > 10 {print $2, $3, $11}' | \  # CPU > 10%
  sed 's/%//g' | \                   # Retirer les %
  column -t                          # Alignement des colonnes
```

---

## Pipes nommés (FIFO)

Les **pipes nommés** (ou FIFO - First In First Out) sont des fichiers spéciaux qui permettent la communication inter-processus de manière persistante, contrairement aux pipes anonymes qui n'existent que le temps de l'exécution.

### Création d'un pipe nommé

```bash
# Créer un pipe nommé
mkfifo mon_pipe

# Vérifier sa création (type 'p' pour pipe)
ls -l mon_pipe
# Sortie : prw-r--r-- 1 user group 0 Dec 11 10:00 mon_pipe
```

> [!info] Type de fichier Le 'p' au début indique qu'il s'agit d'un pipe. Ce n'est pas un fichier classique : il ne contient pas de données, il sert de canal de communication.

### Utilisation basique

```bash
# Terminal 1 : Écrire dans le pipe (producteur)
echo "Message de communication" > mon_pipe

# Terminal 2 : Lire depuis le pipe (consommateur)
cat < mon_pipe
```

> [!warning] Comportement bloquant Un pipe nommé **bloque** : l'écriture attend qu'il y ait un lecteur, et vice-versa. C'est une synchronisation automatique entre processus.

### Cas d'usage des pipes nommés

#### 1. Communication entre processus indépendants

```bash
# Créer le pipe
mkfifo /tmp/logger_pipe

# Processus 1 : Générateur de logs
while true; do
  echo "$(date): Événement système" > /tmp/logger_pipe
  sleep 5
done &

# Processus 2 : Consommateur de logs
while true; do
  read ligne < /tmp/logger_pipe
  echo "LOG REÇU: $ligne" >> /var/log/custom.log
done &
```

#### 2. Remplacement de fichiers temporaires

```bash
# ❌ Avec fichier temporaire
command1 > /tmp/temp_file
command2 < /tmp/temp_file
rm /tmp/temp_file

# ✅ Avec pipe nommé
mkfifo /tmp/my_pipe
command1 > /tmp/my_pipe &
command2 < /tmp/my_pipe
rm /tmp/my_pipe
```

#### 3. Serveur de commandes simple

```bash
# Créer le pipe de commandes
mkfifo /tmp/cmd_pipe

# Serveur qui exécute les commandes reçues
while true; do
  if read cmd < /tmp/cmd_pipe; then
    echo "Exécution: $cmd"
    eval "$cmd"
  fi
done &

# Clients peuvent envoyer des commandes
echo "ls -la" > /tmp/cmd_pipe
echo "df -h" > /tmp/cmd_pipe
```

#### 4. Monitoring et métriques en temps réel

```bash
# Pipe pour les métriques
mkfifo /tmp/metrics_pipe

# Collecteur de métriques
while true; do
  cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
  mem=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
  echo "$(date +%s),$cpu,$mem" > /tmp/metrics_pipe
  sleep 10
done &

# Analyseur de métriques
while read metric < /tmp/metrics_pipe; do
  echo "$metric" >> /var/log/metrics.csv
  # Alertes si nécessaire
  cpu_val=$(echo $metric | cut -d',' -f2)
  if (( $(echo "$cpu_val > 80" | bc -l) )); then
    echo "ALERTE: CPU élevé ($cpu_val%)" | mail -s "Alert" admin@domain.com
  fi
done &
```

### Gestion des pipes nommés

```bash
# Lister les pipes nommés
find /tmp -type p

# Supprimer un pipe nommé
rm mon_pipe

# Vérifier si un fichier est un pipe
if [[ -p mon_pipe ]]; then
  echo "C'est un pipe nommé"
fi
```

### Différences pipe anonyme vs nommé

|Caractéristique|Pipe anonyme (`\|`)|Pipe nommé (FIFO)|
|---|---|---|
|**Création**|Automatique|`mkfifo`|
|**Durée de vie**|Le temps du pipeline|Persistant jusqu'à suppression|
|**Visibilité**|Processus parent-enfant|Tous processus avec accès fichier|
|**Usage**|Pipelines simples|Communication inter-processus|
|**Fichier**|Non|Oui (fichier spécial)|

> [!tip] Quand utiliser les pipes nommés ?
> 
> - Communication entre scripts indépendants
> - Architecture producteur-consommateur
> - Monitoring et logging centralisés
> - Remplacement de fichiers temporaires pour économiser I/O disque

---

## Pièges courants et bonnes pratiques

### ⚠️ Pièges courants

#### 1. Utiliser `cat` inutilement (UUOC - Useless Use Of Cat)

```bash
# ❌ Inefficace : processus inutile
cat fichier.txt | grep "motif"

# ✅ Efficace : grep peut lire directement
grep "motif" fichier.txt

# ❌ Chaîne inutile
cat fichier.txt | sort | uniq

# ✅ Direct
sort fichier.txt | uniq
```

#### 2. Oublier que stderr n'est pas redirigé

```bash
# ❌ Les erreurs apparaissent à l'écran
commande_qui_echoue | grep "résultat"

# ✅ Rediriger aussi stderr
commande_qui_echoue 2>&1 | grep "résultat"

# ✅ Ou ignorer stderr
commande_qui_echoue 2>/dev/null | grep "résultat"
```

#### 3. Pipeline sur une ligne vide

```bash
# ❌ Risque : si la commande ne retourne rien
ps aux | grep "inexistant" | awk '{print $2}' | xargs kill

# ✅ Vérifier avant d'agir
pids=$(ps aux | grep "inexistant" | awk '{print $2}')
if [[ -n "$pids" ]]; then
  echo "$pids" | xargs kill
else
  echo "Aucun processus trouvé"
fi
```

#### 4. Ne pas gérer les codes de retour

```bash
# ❌ Continue même si une commande échoue
commande1 | commande2 | commande3

# ✅ Arrêter si une commande échoue
set -o pipefail
commande1 | commande2 | commande3 || {
  echo "Erreur dans le pipeline" >&2
  exit 1
}
```

> [!warning] set -o pipefail Par défaut, le code de retour d'un pipeline est celui de la **dernière** commande. Avec `set -o pipefail`, le pipeline échoue si **n'importe quelle** commande échoue.

#### 5. Pipes et boucles

```bash
# ❌ Problème : la boucle s'exécute dans un sous-shell
count=0
cat fichier.txt | while read line; do
  ((count++))
done
echo "$count"  # Affiche 0 !

# ✅ Solution : redirection au lieu de pipe
count=0
while read line; do
  ((count++))
done < fichier.txt
echo "$count"  # Affiche le bon nombre
```

### ✅ Bonnes pratiques

#### 1. Utiliser `tee` pour conserver des étapes intermédiaires

```bash
# Sauvegarder et continuer le traitement
cat data.txt | grep "important" | tee intermediate.txt | sort | uniq
```

#### 2. Limiter la longueur des pipelines

```bash
# ❌ Pipeline trop long et illisible
cat file | grep x | awk '...' | sed '...' | cut ... | sort | uniq | grep y | awk '...'

# ✅ Diviser en étapes avec variables ou fonctions
etape1=$(cat file | grep x | awk '...')
etape2=$(echo "$etape1" | sed '...' | cut ...)
echo "$etape2" | sort | uniq
```

#### 3. Utiliser `xargs` pour passer les résultats en arguments

```bash
# Trouver et supprimer des fichiers
find . -name "*.tmp" | xargs rm -f

# Avec gestion des espaces dans les noms
find . -name "*.tmp" -print0 | xargs -0 rm -f
```

#### 4. Indenter les pipelines longs pour la lisibilité

```bash
# ✅ Lisible avec backslash
cat access.log | \
  grep "2024-01-15" | \
  awk '{print $1, $9}' | \
  sort | \
  uniq -c | \
  sort -rn | \
  head -10
```

#### 5. Documenter les pipelines complexes

```bash
# ✅ Avec commentaires
cat access.log | \
  grep "2024-01-15" | \          # Filtrer par date
  awk '{print $1, $9}' | \       # Extraire IP et status code
  sort | \                       # Trier pour uniq
  uniq -c | \                    # Compter les occurrences
  sort -rn | \                   # Trier par fréquence décroissante
  head -10                       # Top 10
```

---

## Astuces avancées

### 1. Pipes avec substitution de processus

```bash
# Comparer la sortie de deux commandes
diff <(ls dir1) <(ls dir2)

# Joindre deux sources de données
join <(sort file1.txt) <(sort file2.txt)
```

### 2. Utiliser `pv` pour monitorer le flux

```bash
# Afficher la progression
cat gros_fichier.log | pv | grep "erreur" > resultat.txt

# Avec estimation de taille
pv access.log | grep "404" | wc -l
```

### 3. Paralléliser avec `xargs -P`

```bash
# Traiter 4 fichiers en parallèle
find . -name "*.log" | xargs -P 4 -I {} gzip {}
```

### 4. Pipeline avec timeout

```bash
# Limiter le temps d'exécution
timeout 30s cat /dev/urandom | head -c 1M > random_data.bin
```

### 5. Créer des fonctions pour pipelines réutilisables

```bash
# Fonction de filtrage des logs
filter_errors() {
  grep -i "error\|fatal\|critical" | \
  awk '{print $1, $2, $NF}' | \
  sort | uniq -c | sort -rn
}

# Utilisation
cat app.log | filter_errors
tail -f live.log | filter_errors
```

### 6. Pipeline bidirectionnel avec coproc

```bash
# Créer un coprocessus
coproc bc -l

# Envoyer et recevoir des données
echo "scale=2; 22/7" >&"${COPROC[1]}"
read resultat <&"${COPROC[0]}"
echo "Pi approximation: $resultat"
```

### 7. Combiner pipes et job control

```bash
# Lancer en arrière-plan avec pipe
tail -f /var/log/syslog | grep "error" > errors.log &

# Monitorer plusieurs logs simultanément
(tail -f /var/log/app1.log | grep "ERROR" >> errors.log) &
(tail -f /var/log/app2.log | grep "ERROR" >> errors.log) &
(tail -f /var/log/app3.log | grep "ERROR" >> errors.log) &
```

### 8. Pipeline avec condition ternaire

```bash
# Exécuter différents traitements selon condition
cat data.txt | (grep -q "PROD" && awk '{print $1}' || awk '{print $2}')
```

> [!tip] Astuce pro Créez un fichier `~/.bash_pipelines` avec vos pipelines favoris sous forme de fonctions, puis sourcez-le dans `~/.bashrc` pour les avoir toujours disponibles !

---

## 📊 Tableau récapitulatif

|Opérateur|Description|Exemple|
|---|---|---|
|`\|`|Pipe standard (stdout → stdin)|`ls \| wc -l`|
|`\|&`|Pipe avec stderr|`cmd \|& grep error`|
|`2>&1 \|`|Rediriger stderr+stdout|`cmd 2>&1 \| less`|
|`tee`|Dupliquer le flux|`cmd \| tee file.txt \| grep x`|
|`mkfifo`|Créer un pipe nommé|`mkfifo /tmp/pipe`|
|`<()`|Substitution de processus|`diff <(cmd1) <(cmd2)`|

---

> [!tip] Mémo rapide
> 
> - **Pipe** = connecter la sortie d'une commande à l'entrée d'une autre
> - **grep** = filtrer des lignes
> - **awk** = traiter des colonnes
> - **sed** = transformer du texte
> - **FIFO** = communication entre processus indépendants
> - Toujours utiliser `set -o pipefail` dans les scripts critiques
> - Les pipelines s'exécutent en **parallèle**, pas séquentiellement