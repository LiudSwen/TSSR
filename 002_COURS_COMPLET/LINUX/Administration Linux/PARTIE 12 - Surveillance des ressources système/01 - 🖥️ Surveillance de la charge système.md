

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

## 🔍 Surveillance de la charge système

La surveillance de la charge système est essentielle pour maintenir la santé et les performances d'un serveur Linux. Elle permet d'identifier les goulots d'étranglement, de détecter les anomalies et d'optimiser l'utilisation des ressources.

> [!info] Pourquoi surveiller la charge ?
> 
> - Détecter les problèmes de performance avant qu'ils n'impactent les utilisateurs
> - Planifier les montées en charge et le dimensionnement
> - Identifier les processus consommateurs de ressources
> - Diagnostiquer les lenteurs système

---

### ⏱️ uptime et load average

`uptime` est la commande la plus simple pour obtenir un aperçu rapide de la charge système. Elle affiche depuis combien de temps le système fonctionne et le "load average" (charge moyenne).

#### Syntaxe de base

```bash
uptime
```

**Exemple de sortie :**

```bash
 14:23:45 up 5 days, 3:12,  2 users,  load average: 0.52, 0.48, 0.45
```

#### Interprétation des résultats

|Élément|Description|
|---|---|
|`14:23:45`|Heure actuelle|
|`up 5 days, 3:12`|Temps depuis le dernier démarrage|
|`2 users`|Nombre d'utilisateurs connectés|
|`load average: 0.52, 0.48, 0.45`|Charge moyenne sur 1, 5 et 15 minutes|

> [!example] Comprendre le Load Average Le load average représente le nombre moyen de processus en attente d'exécution CPU ou en état d'attente I/O.
> 
> **Règle générale :**
> 
> - Sur un système à 1 CPU : load de 1.0 = 100% d'utilisation
> - Sur un système à 4 CPU : load de 4.0 = 100% d'utilisation
> - Load > nombre de CPU = système surchargé
> - Load < nombre de CPU = ressources disponibles

#### Cas d'usage pratiques

```bash
# Afficher uniquement le load average
uptime | awk -F'load average:' '{ print $2 }'

# Surveiller le load en continu (toutes les 2 secondes)
watch -n 2 uptime

# Vérifier le nombre de CPU pour interpréter le load
nproc
# ou
lscpu | grep "^CPU(s):"
```

> [!tip] Astuce d'interprétation Observez l'évolution sur les 3 périodes :
> 
> - **Load croissant** (0.3 → 0.6 → 1.2) : problème qui s'aggrave
> - **Load décroissant** (1.5 → 0.8 → 0.4) : situation qui s'améliore
> - **Load stable** (0.5 → 0.5 → 0.5) : charge constante

> [!warning] Pièges courants
> 
> - Un load élevé n'indique pas toujours un problème CPU : il peut s'agir d'attente I/O (disque, réseau)
> - Comparez toujours le load au nombre de CPU disponibles
> - Un load de 2.0 sur un système à 8 CPU n'est pas préoccupant

---

### 🎯 top - interface interactive

`top` est l'outil de surveillance en temps réel le plus utilisé sous Linux. Il affiche une vue dynamique des processus et de l'utilisation des ressources système.

#### Lancement et interface

```bash
# Lancer top
top

# Lancer avec un délai de rafraîchissement personnalisé (en secondes)
top -d 2

# Afficher uniquement les processus d'un utilisateur
top -u nom_utilisateur

# Mode batch (non-interactif) - utile pour les scripts
top -b -n 1 > snapshot.txt
```

#### Structure de l'affichage

**En-tête système :**

```
top - 14:30:45 up 5 days,  3:19,  2 users,  load average: 0.52, 0.48, 0.45
Tasks: 245 total,   1 running, 244 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.3 us,  0.8 sy,  0.0 ni, 96.5 id,  0.3 wa,  0.0 hi,  0.1 si,  0.0 st
MiB Mem :  15921.2 total,   8234.5 free,   4156.3 used,   3530.4 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used.  11023.7 avail Mem
```

> [!info] Décodage de l'utilisation CPU
> 
> - **us (user)** : temps CPU en mode utilisateur (applications)
> - **sy (system)** : temps CPU en mode noyau (système)
> - **ni (nice)** : temps CPU pour les processus avec priorité modifiée
> - **id (idle)** : temps CPU inactif
> - **wa (iowait)** : temps CPU en attente d'I/O
> - **hi (hardware interrupts)** : interruptions matérielles
> - **si (software interrupts)** : interruptions logicielles
> - **st (steal time)** : temps volé par l'hyperviseur (VM uniquement)

**Colonnes des processus :**

|Colonne|Signification|
|---|---|
|PID|Identifiant du processus|
|USER|Propriétaire du processus|
|PR|Priorité du processus|
|NI|Valeur nice (-20 à 19)|
|VIRT|Mémoire virtuelle totale|
|RES|Mémoire résidente (RAM physique)|
|SHR|Mémoire partagée|
|S|État (R=running, S=sleeping, Z=zombie, etc.)|
|%CPU|Pourcentage d'utilisation CPU|
|%MEM|Pourcentage d'utilisation mémoire|
|TIME+|Temps CPU total consommé|
|COMMAND|Nom de la commande|

#### Commandes interactives essentielles

Une fois `top` lancé, vous pouvez utiliser ces touches :

```bash
# Navigation et tri
M          # Trier par utilisation mémoire (RES)
P          # Trier par utilisation CPU (par défaut)
T          # Trier par temps d'exécution (TIME+)
N          # Trier par PID
<          # Déplacer la colonne de tri vers la gauche
>          # Déplacer la colonne de tri vers la droite

# Filtrage et recherche
u          # Filtrer par utilisateur (demande le nom)
o ou O     # Ajouter des filtres personnalisés
L          # Rechercher une chaîne de caractères
&          # Localiser le prochain résultat

# Affichage
1          # Basculer entre vue globale CPU et par cœur
t          # Changer l'affichage des statistiques CPU
m          # Changer l'affichage de la mémoire
V          # Vue arborescente (hiérarchie des processus)
c          # Afficher le chemin complet de la commande
i          # Masquer les processus inactifs
d ou s     # Changer l'intervalle de mise à jour

# Actions sur les processus
k          # Tuer un processus (demande le PID et le signal)
r          # Renice un processus (changer sa priorité)

# Autres
h ou ?     # Aide interactive
q          # Quitter top
W          # Sauvegarder la configuration actuelle
```

#### Exemples de filtres avancés

```bash
# Lancer top en affichant uniquement les processus Apache
top -u www-data

# Afficher uniquement les processus utilisant plus de 5% de CPU
# Dans top, appuyez sur 'o' puis tapez :
%CPU>5.0

# Sauvegarder un snapshot des 20 processus les plus gourmands
top -b -n 1 -o %CPU | head -n 25 > top_cpu.txt
top -b -n 1 -o %MEM | head -n 25 > top_mem.txt
```

> [!tip] Raccourcis pour un diagnostic rapide
> 
> 1. Lancez `top`
> 2. Appuyez sur `1` pour voir chaque cœur CPU
> 3. Appuyez sur `M` pour trier par mémoire
> 4. Appuyez sur `i` pour masquer les processus inactifs
> 5. Observez les valeurs **wa** (iowait) : si élevées, problème d'I/O disque

> [!warning] Attention à l'interprétation
> 
> - **VIRT élevé ≠ problème** : c'est de la mémoire virtuelle (peut être du swap non utilisé)
> - **RES** est la vraie consommation mémoire physique
> - Un processus avec 100% CPU est normal s'il fait des calculs intensifs
> - Surveillez plutôt plusieurs processus à 100% simultanément

#### Cas d'usage pratiques

```bash
# Surveiller un serveur web (processus Apache/Nginx)
top -u www-data -d 3

# Identifier un processus qui consomme de la mémoire de façon anormale
# Lancer top, puis 'M' pour trier par mémoire, et observer l'évolution

# Monitorer l'impact d'un script
# Terminal 1 : lancer le script
# Terminal 2 : top -p $(pgrep -d',' nom_script)

# Mode batch pour surveillance automatique
top -b -n 5 -d 10 > top_monitoring.log
# 5 captures, toutes les 10 secondes
```

---

### 🚀 htop - alternative améliorée

`htop` est une version améliorée et plus conviviale de `top`, avec une interface colorée, intuitive et des fonctionnalités supplémentaires.

> [!info] Installation `htop` n'est généralement pas installé par défaut :
> 
> ```bash
> # Debian/Ubuntu
> sudo apt install htop
> 
> # RHEL/CentOS/Rocky
> sudo dnf install htop
> 
> # Arch Linux
> sudo pacman -S htop
> ```

#### Avantages de htop par rapport à top

|Fonctionnalité|top|htop|
|---|---|---|
|Interface colorée|❌|✅|
|Utilisation souris|❌|✅|
|Défilement horizontal/vertical|Limité|✅ Complet|
|Vue arborescente claire|Basique|✅ Excellente|
|Sélection multiple processus|❌|✅|
|Recherche incrémentale|Basique|✅ Avancée|
|Configuration visuelle|❌|✅ Menu F2|
|Barres graphiques CPU/Mem|❌|✅|

#### Lancement et options

```bash
# Lancer htop
htop

# Lancer avec un délai spécifique (en dixièmes de seconde)
htop -d 50  # Mise à jour toutes les 5 secondes

# Filtrer par utilisateur
htop -u nom_utilisateur

# Trier par colonne au démarrage
htop -s PERCENT_CPU    # Tri par CPU
htop -s PERCENT_MEM    # Tri par mémoire

# Mode arborescence au démarrage
htop -t
```

#### Interface et navigation

**En-tête coloré :**

```
1[|||                    5.0%]    Tasks: 87, 234 thr; 1 running
2[||                     2.3%]    Load average: 0.52 0.48 0.45
3[|                      1.8%]    Uptime: 5 days, 03:19:45
4[                       0.5%]
Mem[|||||||||||||| 4.15G/15.9G]
Swp[                   0K/4.00G]
```

> [!example] Légende des barres
> 
> - **Vert** : processus utilisateur normaux
> - **Bleu** : processus système (priorité basse)
> - **Rouge** : processus noyau
> - **Jaune** : temps IRQ
> - **Magenta** : temps soft IRQ
> - **Gris** : temps IO-wait
> - **Cyan** : temps steal (virtualisation)

#### Raccourcis clavier essentiels

```bash
# Navigation
↑ ↓ ← →       # Naviguer dans la liste
PgUp/PgDn     # Page précédente/suivante
Home/End      # Début/Fin de la liste

# Tri
F6 ou <       # Menu de tri (choisir la colonne)
P             # Trier par CPU (%)
M             # Trier par mémoire (%)
T             # Trier par TIME+
I             # Inverser l'ordre de tri

# Filtrage et recherche
F3 ou /       # Rechercher un processus
F4 ou \       # Filtrer par nom
F5 ou t       # Vue arborescente (tree view)
u             # Filtrer par utilisateur
U             # Annuler le filtre utilisateur

# Affichage
F2            # Configuration (Setup)
S             # Appel système (strace) - nécessite privilèges
l             # Afficher/masquer lsof pour le processus
H             # Afficher/masquer les threads
K             # Afficher/masquer les threads noyau
p             # Afficher le chemin complet
Space         # Marquer/démarquer un processus

# Actions sur les processus
F7            # Diminuer la priorité (nice +)
F8            # Augmenter la priorité (nice -)
F9            # Menu kill (envoyer un signal)
k             # Envoyer SIGTERM (kill gracieux)
F10 ou q      # Quitter htop

# Autres
h ou F1       # Aide
C             # Afficher la ligne de commande complète
```

#### Configuration personnalisée (F2)

Le menu Setup (F2) permet de personnaliser complètement l'affichage :

**1. Meters** (gauche et droite) :

- Ajouter/supprimer des widgets (CPU, mémoire, swap, load, uptime, etc.)
- Choisir le style d'affichage (barres, texte, graphique, LED)

**2. Display options** :

- Masquer les threads
- Afficher les chemins complets
- Mettre en surbrillance les nouveaux processus
- Activer le mode arborescence par défaut

**3. Colors** :

- Choisir un thème de couleurs
- Mode monochrome pour terminaux basiques

**4. Columns** :

- Sélectionner les colonnes à afficher
- Réorganiser l'ordre des colonnes

> [!tip] Configuration recommandée
> 
> 1. Appuyez sur F2
> 2. Allez dans "Columns"
> 3. Ajoutez : PID, USER, NICE, CPU%, MEM%, Command
> 4. Dans "Display options", activez :
>     - Tree view
>     - Show custom thread names
>     - Highlight program basename
> 5. F10 pour sauvegarder

#### Actions avancées sur les processus

```bash
# Tuer plusieurs processus en même temps
# 1. Marquez les processus avec Space
# 2. Appuyez sur F9
# 3. Choisissez le signal (SIGTERM, SIGKILL, etc.)

# Suivre un processus spécifique et ses enfants
# 1. Sélectionnez le processus parent
# 2. Appuyez sur F5 pour la vue arborescente
# 3. Les processus enfants apparaissent en dessous avec indentation

# Changer la priorité de plusieurs processus
# 1. Marquez les processus avec Space
# 2. F7 pour augmenter nice (baisser priorité)
# 3. F8 pour diminuer nice (augmenter priorité)
```

#### Cas d'usage pratiques

```bash
# Surveiller spécifiquement les processus d'un service
htop -u mysql

# Lancer htop en mode arborescence pour voir les relations parent-enfant
htop -t

# Identifier rapidement les processus zombies
# Dans htop, recherchez l'état 'Z' dans la colonne S

# Surveiller l'impact d'une compilation
# Lancer htop, puis F5 pour tree view, et chercher 'make' ou 'gcc'

# Diagnostiquer un problème d'I/O wait
# 1. Lancer htop
# 2. Regarder les barres CPU : si beaucoup de rouge/gris = I/O wait élevé
# 3. Trier par IO_RATE (F6, choisir IO_RATE) si la colonne est activée
```

> [!warning] Limitations de htop
> 
> - Non disponible par défaut sur tous les systèmes
> - Légèrement plus gourmand en ressources que `top`
> - Sur des systèmes très chargés (milliers de processus), peut être plus lent
> - Les scripts automatisés préfèrent souvent `top -b` pour sa stabilité

> [!tip] Astuce de productivité Créez un alias dans votre `.bashrc` ou `.zshrc` :
> 
> ```bash
> alias ht='htop -t -d 30'  # Lance htop en mode tree, refresh 3s
> alias htu='htop -u $USER -t'  # Vos processus uniquement
> ```

#### Comparaison rapide : quand utiliser quoi ?

|Situation|Outil recommandé|Raison|
|---|---|---|
|Diagnostic rapide|`uptime`|Ultra rapide, load average en un coup d'œil|
|Surveillance continue serveur|`top`|Léger, toujours disponible, scriptable|
|Exploration interactive|`htop`|Interface intuitive, vue arborescente|
|Gestion de processus|`htop`|Sélection multiple, actions facilitées|
|Scripts automatisés|`top -b`|Sortie stable et parsable|
|Systèmes embarqués/anciens|`top`|Moins de dépendances|
|Débutants Linux|`htop`|Plus facile à comprendre visuellement|

---

## 🎯 Synthèse et bonnes pratiques

> [!tip] Workflow recommandé pour le diagnostic
> 
> 1. **Première vérification** : `uptime` pour un aperçu rapide du load
> 2. **Si load élevé** : `top` ou `htop` pour identifier les coupables
> 3. **Analyse approfondie** : utiliser les fonctions de tri et filtrage
> 4. **Action** : ajuster les priorités, arrêter des processus, ou dimensionner

> [!warning] Erreurs fréquentes à éviter
> 
> - Ne pas confondre VIRT et RES pour la mémoire
> - Ne pas paniquer devant un load élevé sans vérifier le nombre de CPU
> - Ne pas tuer des processus système sans comprendre leur rôle
> - Ne pas surveiller uniquement le CPU : l'I/O wait est souvent critique

**Commandes complémentaires utiles :**

```bash
# Vérifier le nombre de CPU pour interpréter le load
nproc

# Voir l'historique du load (si sar est installé)
sar -q

# Identifier les processus en attente I/O
iotop  # Nécessite installation séparée

# Vue globale des ressources
vmstat 1  # Statistiques toutes les secondes
```

---

**📚 Points clés à retenir :**

1. **uptime** : diagnostic rapide du load average sur 1, 5 et 15 minutes
2. **top** : outil universel de surveillance, léger et toujours disponible
3. **htop** : interface moderne et intuitive pour une utilisation interactive
4. Comparez toujours le load au nombre de CPU disponibles
5. Surveillez RES (pas VIRT) pour la vraie consommation mémoire
6. Un iowait élevé indique des problèmes d'I/O disque, pas de CPU