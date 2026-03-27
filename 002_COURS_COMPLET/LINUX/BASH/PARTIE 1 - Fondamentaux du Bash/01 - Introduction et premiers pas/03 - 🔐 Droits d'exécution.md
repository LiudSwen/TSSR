

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

Les droits d'exécution sont essentiels pour transformer un simple fichier texte en un script exécutable. Par défaut, lorsque vous créez un fichier `.sh`, le système ne lui accorde pas le droit d'être exécuté directement. C'est une mesure de sécurité fondamentale d'Unix/Linux.

> [!info] Pourquoi cette restriction ? Empêcher l'exécution accidentelle de fichiers potentiellement dangereux téléchargés ou créés par erreur. Chaque fichier doit être explicitement marqué comme exécutable.

---

## ⚡ La commande chmod +x

### Syntaxe de base

```bash
chmod +x script.sh
```

Cette commande ajoute le droit d'exécution (x) pour tous les utilisateurs (propriétaire, groupe, autres).

### Exemple pratique complet

```bash
# Créer un script simple
echo '#!/bin/bash' > mon_script.sh
echo 'echo "Hello World"' >> mon_script.sh

# Tenter de l'exécuter sans permission
./mon_script.sh
# Erreur : Permission denied

# Ajouter les droits d'exécution
chmod +x mon_script.sh

# Maintenant ça fonctionne
./mon_script.sh
# Affiche : Hello World
```

> [!tip] Astuce pratique Vous pouvez rendre exécutables plusieurs fichiers en une seule commande :
> 
> ```bash
> chmod +x script1.sh script2.sh script3.sh
> ```

### Variantes de la commande

```bash
# Ajouter l'exécution uniquement pour le propriétaire
chmod u+x script.sh

# Ajouter l'exécution pour le groupe
chmod g+x script.sh

# Ajouter l'exécution pour les autres utilisateurs
chmod o+x script.sh

# Retirer le droit d'exécution
chmod -x script.sh
```

---

## 🔢 Comprendre les permissions Unix

### Le système de permissions

Chaque fichier Unix possède trois types de permissions pour trois catégories d'utilisateurs :

|Catégorie|Symbole|Description|
|---|---|---|
|**User** (Propriétaire)|`u`|La personne qui possède le fichier|
|**Group** (Groupe)|`g`|Les membres du groupe associé au fichier|
|**Others** (Autres)|`o`|Tous les autres utilisateurs du système|

### Les trois permissions

|Permission|Symbole|Valeur octale|Signification pour un fichier|Signification pour un répertoire|
|---|---|---|---|---|
|**Read** (Lecture)|`r`|4|Lire le contenu du fichier|Lister les fichiers du répertoire|
|**Write** (Écriture)|`w`|2|Modifier le fichier|Créer/supprimer des fichiers dans le répertoire|
|**Execute** (Exécution)|`x`|1|Exécuter le fichier comme programme|Accéder au répertoire (cd)|

### Notation symbolique vs octale

```bash
# Notation symbolique
rwxr-xr-x

# Notation octale équivalente
755
```

**Décomposition :**

```
rwx  r-x  r-x
421  401  401
 7    5    5
```

|Combinaison|Calcul|Octal|Signification|
|---|---|---|---|
|`rwx`|4+2+1|7|Lecture, écriture, exécution|
|`rw-`|4+2+0|6|Lecture et écriture|
|`r-x`|4+0+1|5|Lecture et exécution|
|`r--`|4+0+0|4|Lecture seule|
|`-wx`|0+2+1|3|Écriture et exécution|
|`-w-`|0+2+0|2|Écriture seule|
|`--x`|0+0+1|1|Exécution seule|
|`---`|0+0+0|0|Aucune permission|

> [!example] Exemples courants
> 
> ```bash
> # 755 - Script standard accessible par tous
> chmod 755 script.sh
> # Propriétaire : rwx (7) - tout
> # Groupe : r-x (5) - lecture et exécution
> # Autres : r-x (5) - lecture et exécution
> 
> # 700 - Script privé
> chmod 700 script.sh
> # Propriétaire : rwx (7) - tout
> # Groupe : --- (0) - rien
> # Autres : --- (0) - rien
> 
> # 644 - Fichier de données standard
> chmod 644 data.txt
> # Propriétaire : rw- (6) - lecture et écriture
> # Groupe : r-- (4) - lecture seule
> # Autres : r-- (4) - lecture seule
> ```

---

## ⚖️ chmod 755 vs chmod +x

### Différences fondamentales

|Aspect|`chmod +x`|`chmod 755`|
|---|---|---|
|**Type**|Modification relative|Permission absolue|
|**Impact**|Ajoute l'exécution, conserve le reste|Définit toutes les permissions|
|**Lecture**|Inchangée|Activée pour tous|
|**Écriture**|Inchangée|Activée pour le propriétaire uniquement|
|**Exécution**|Activée pour tous|Activée pour tous|

### Comparaison pratique

```bash
# Créer un fichier avec permissions par défaut (644)
touch script.sh
ls -l script.sh
# -rw-r--r-- 1 user group 0 Dec 16 10:00 script.sh

# Méthode 1 : chmod +x
chmod +x script.sh
ls -l script.sh
# -rwxr-xr-x 1 user group 0 Dec 16 10:00 script.sh
# Résultat : 755 (car on partait de 644)

# Remettre à zéro
chmod 644 script.sh

# Méthode 2 : chmod 755
chmod 755 script.sh
ls -l script.sh
# -rwxr-xr-x 1 user group 0 Dec 16 10:00 script.sh
# Résultat : 755 (imposé directement)
```

### Cas où ça fait une différence

```bash
# Partir d'un fichier avec permissions inhabituelles (600)
chmod 600 script.sh
ls -l script.sh
# -rw------- 1 user group 0 Dec 16 10:00 script.sh

# Avec chmod +x
chmod +x script.sh
ls -l script.sh
# -rwx--x--x 1 user group 0 Dec 16 10:00 script.sh
# Résultat : 711 (ajoute juste x partout)

# Remettre à 600
chmod 600 script.sh

# Avec chmod 755
chmod 755 script.sh
ls -l script.sh
# -rwxr-xr-x 1 user group 0 Dec 16 10:00 script.sh
# Résultat : 755 (impose la configuration)
```

> [!warning] Attention aux permissions existantes `chmod +x` préserve les permissions de lecture et d'écriture existantes, tandis que `chmod 755` les écrase complètement.

### Quand utiliser l'un ou l'autre ?

**Utilisez `chmod +x` quand :**

- Vous voulez simplement rendre un fichier exécutable
- Vous ne voulez pas modifier les autres permissions
- Vous travaillez dans un environnement où les permissions varient

**Utilisez `chmod 755` quand :**

- Vous voulez garantir un état de permissions précis
- Vous déployez des scripts en production
- Vous avez besoin de permissions standardisées

```bash
# Cas typique en développement
chmod +x mon_script.sh  # Rapide et sûr

# Cas typique en production
chmod 755 /usr/local/bin/deploy.sh  # Permissions explicites et contrôlées
```

---

## 🔍 Vérification des permissions avec ls -l

### Syntaxe et lecture

```bash
ls -l script.sh
# -rwxr-xr-x 1 user group 1234 Dec 16 10:00 script.sh
```

### Décomposition de la sortie

```
-rwxr-xr-x 1 user group 1234 Dec 16 10:00 script.sh
│││││││││ │ │    │     │    │            │
│││││││││ │ │    │     │    │            └─ Nom du fichier
│││││││││ │ │    │     │    └─ Date de modification
│││││││││ │ │    │     └─ Taille en octets
│││││││││ │ │    └─ Groupe propriétaire
│││││││││ │ └─ Utilisateur propriétaire
│││││││││ └─ Nombre de liens physiques
││││││││└─ Exécution pour autres (x)
│││││││└─ Écriture pour autres (-)
││││││└─ Lecture pour autres (r)
│││││└─ Exécution pour groupe (x)
││││└─ Écriture pour groupe (-)
│││└─ Lecture pour groupe (r)
││└─ Exécution pour propriétaire (x)
│└─ Écriture pour propriétaire (w)
└─ Lecture pour propriétaire (r)
Le premier caractère indique le type
```

### Premier caractère (type de fichier)

|Symbole|Type|Description|
|---|---|---|
|`-`|Fichier régulier|Fichier normal|
|`d`|Répertoire|Dossier|
|`l`|Lien symbolique|Raccourci vers un autre fichier|
|`b`|Périphérique bloc|Disque dur, clé USB|
|`c`|Périphérique caractère|Terminal, port série|
|`p`|Tube nommé (FIFO)|Communication inter-processus|
|`s`|Socket|Communication réseau|

### Commandes de vérification utiles

```bash
# Liste détaillée d'un fichier
ls -l script.sh

# Liste tous les fichiers (y compris cachés)
ls -la

# Liste avec permissions en octal (nécessite stat)
stat -c "%a %n" script.sh
# Affiche : 755 script.sh

# Voir les permissions de tous les scripts
ls -l *.sh

# Affichage détaillé avec stat
stat script.sh
# Affiche toutes les métadonnées du fichier
```

> [!example] Exemple de vérification complète
> 
> ```bash
> # Créer un script
> echo '#!/bin/bash' > test.sh
> echo 'echo "Test"' >> test.sh
> 
> # Vérifier les permissions initiales
> ls -l test.sh
> # -rw-r--r-- 1 user group 28 Dec 16 10:00 test.sh
> 
> # Ajouter les droits d'exécution
> chmod +x test.sh
> 
> # Vérifier à nouveau
> ls -l test.sh
> # -rwxr-xr-x 1 user group 28 Dec 16 10:00 test.sh
> 
> # Vérifier en notation octale
> stat -c "%a" test.sh
> # 755
> ```

### Filtrer par permissions

```bash
# Trouver tous les fichiers exécutables
find . -type f -executable

# Trouver tous les fichiers avec permission 755
find . -type f -perm 755

# Trouver tous les scripts sans permission d'exécution
find . -name "*.sh" ! -perm -u+x
```

---

## ✨ Bonnes pratiques

### 1. Sécurité des scripts

```bash
# ❌ Mauvais : trop permissif
chmod 777 script.sh  # Tout le monde peut tout faire !

# ✅ Bon : permissions appropriées
chmod 755 script.sh  # Exécutable par tous, modifiable par le propriétaire uniquement
```

> [!warning] Danger du 777 `chmod 777` donne tous les droits à tout le monde. C'est une faille de sécurité majeure. N'importe qui peut modifier votre script et y injecter du code malveillant.

### 2. Scripts personnels vs scripts système

```bash
# Scripts personnels (uniquement vous)
chmod 700 ~/mes_scripts/perso.sh

# Scripts d'équipe (groupe de travail)
chmod 750 /opt/team/deploy.sh

# Scripts publics (tous les utilisateurs)
chmod 755 /usr/local/bin/utility.sh
```

### 3. Vérification avant exécution

```bash
# Toujours vérifier les permissions avant d'exécuter un script inconnu
ls -l script_inconnu.sh
stat -c "%a" script_inconnu.sh

# Vérifier le propriétaire
ls -l script_inconnu.sh | awk '{print $3}'
```

### 4. Permissions récursives avec prudence

```bash
# ❌ Dangereux : rend tout exécutable
chmod -R +x mon_dossier/

# ✅ Mieux : uniquement les fichiers .sh
find mon_dossier/ -name "*.sh" -exec chmod +x {} \;

# ✅ Encore mieux : permissions différenciées
find mon_dossier/ -type d -exec chmod 755 {} \;  # Répertoires
find mon_dossier/ -type f -name "*.sh" -exec chmod 755 {} \;  # Scripts
find mon_dossier/ -type f ! -name "*.sh" -exec chmod 644 {} \;  # Autres fichiers
```

> [!tip] Astuce pour les dépôts Git Git peut préserver les permissions d'exécution. Après un `git clone`, vérifiez toujours :
> 
> ```bash
> git ls-files --stage | grep '^100755'
> # Liste les fichiers avec permissions d'exécution dans Git
> ```

### 5. Documentation des permissions

```bash
# Ajouter un commentaire en en-tête de script important
#!/bin/bash
# Permissions recommandées : 750
# Propriétaire : admin
# Groupe : operators
```

### 6. Utiliser umask pour les permissions par défaut

```bash
# Voir le umask actuel
umask
# Généralement : 0022

# Définir un umask plus restrictif
umask 0077  # Les nouveaux fichiers seront 600, les répertoires 700

# Dans votre ~/.bashrc pour le rendre permanent
echo "umask 0077" >> ~/.bashrc
```

### 7. Permissions minimales nécessaires

> [!info] Principe du moindre privilège Donnez toujours le minimum de permissions nécessaires au bon fonctionnement. Il est plus facile d'ajouter des permissions que de détecter un abus de permissions trop larges.

**Exemples de permissions optimales :**

|Type de fichier|Permissions|Octal|Justification|
|---|---|---|---|
|Script personnel|`rwx------`|700|Vous seul pouvez exécuter|
|Script d'équipe|`rwxr-x---`|750|L'équipe peut exécuter, pas modifier|
|Script public|`rwxr-xr-x`|755|Tous peuvent exécuter, vous seul modifiez|
|Fichier de config|`rw-------`|600|Contient des données sensibles|
|Fichier de log|`rw-r--r--`|644|Lisible par tous, modifiable par vous|

---

## 🎓 Résumé des commandes essentielles

```bash
# Rendre un script exécutable (méthode simple)
chmod +x script.sh

# Définir des permissions précises
chmod 755 script.sh

# Retirer l'exécution
chmod -x script.sh

# Vérifier les permissions (format long)
ls -l script.sh

# Vérifier les permissions (format octal)
stat -c "%a" script.sh

# Permissions récursives sélectives
find . -name "*.sh" -exec chmod +x {} \;

# Vérifier qui peut exécuter
ls -l script.sh | cut -c1-10
```

> [!tip] Mémo rapide
> 
> - `chmod +x` → Rend exécutable rapidement
> - `chmod 755` → Standard pour scripts publics
> - `chmod 700` → Standard pour scripts privés
> - `ls -l` → Affiche les permissions
> - `stat` → Affiche les permissions en octal