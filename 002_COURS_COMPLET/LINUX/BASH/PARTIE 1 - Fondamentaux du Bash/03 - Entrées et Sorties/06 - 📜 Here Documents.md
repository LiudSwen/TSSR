

## 📑 Table des matières

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

Les **here documents** (heredocs) sont une fonctionnalité puissante de bash qui permet de passer du texte multi-lignes à une commande sans avoir besoin de fichiers temporaires. C'est un mécanisme de redirection qui traite un bloc de texte comme s'il provenait d'un fichier.

> [!info] Définition Un here document permet de créer un flux d'entrée standard temporaire directement dans le script, délimité par des marqueurs définis par l'utilisateur.

---

## 📝 Here Documents classiques (<<EOF)

### Syntaxe de base

```bash
commande <<DELIMITER
contenu ligne 1
contenu ligne 2
contenu ligne 3
DELIMITER
```

> [!example] Exemple simple
> 
> ```bash
> cat <<EOF
> Bonjour,
> Ceci est un message
> sur plusieurs lignes.
> EOF
> ```
> 
> **Sortie :**
> 
> ```
> Bonjour,
> Ceci est un message
> sur plusieurs lignes.
> ```

### Pourquoi utiliser les here documents ?

Les here documents sont particulièrement utiles dans les situations suivantes :

|Cas d'usage|Avantage|
|---|---|
|Scripts de configuration|Génération de fichiers sans éditeur externe|
|Messages multi-lignes|Meilleure lisibilité que les `echo` multiples|
|Entrées pour des commandes interactives|Automatisation de commandes qui attendent stdin|
|Génération de code|Création dynamique de scripts ou de fichiers|
|Documentation embarquée|Affichage d'aide ou d'instructions|

### Fonctionnement détaillé

```bash
# Le délimiteur peut être n'importe quel mot (convention : EOF, END, MARKER)
cat <<FIN
Texte du here document
FIN

# Redirection vers un fichier
cat <<EOF > fichier.txt
Contenu qui sera écrit
dans fichier.txt
EOF

# Utilisation avec d'autres commandes
mysql -u root -p <<SQL
USE database;
SELECT * FROM users;
SQL

# Indentation du code (mais pas du contenu)
if [ condition ]; then
    cat <<EOF
Le contenu commence à la marge
même si le code est indenté
EOF
fi
```

> [!warning] Attention à l'indentation Le délimiteur de fin **doit** être sur une ligne seule, sans espace avant lui (sauf si on utilise `<<-`, voir astuces).

---

## 🔄 Here Documents avec substitution

Par défaut, bash effectue l'expansion des variables et des commandes dans un here document.

### Expansion des variables

```bash
nom="Alice"
age=30

cat <<EOF
Nom: $nom
Age: $age
Date: $(date +%Y-%m-%d)
EOF
```

**Sortie :**

```
Nom: Alice
Age: 30
Date: 2024-12-11
```

### Expansion des commandes

```bash
cat <<EOF
Utilisateur actuel: $(whoami)
Répertoire: $(pwd)
Nombre de fichiers: $(ls | wc -l)
EOF
```

> [!example] Génération de fichier de configuration
> 
> ```bash
> serveur="192.168.1.100"
> port=8080
> 
> cat <<CONFIG > app.conf
> [server]
> host=$serveur
> port=$port
> max_connections=100
> 
> [logging]
> level=info
> file=/var/log/app.log
> CONFIG
> ```

### Cas d'usage pratiques

**1. Génération de scripts SQL dynamiques**

```bash
table="users"
condition="created_at > '2024-01-01'"

mysql -u root <<SQL
SELECT * FROM $table
WHERE $condition
ORDER BY id DESC
LIMIT 10;
SQL
```

**2. Création d'emails automatisés**

```bash
destinataire="user@example.com"
sujet="Rapport quotidien"

mail -s "$sujet" "$destinataire" <<BODY
Bonjour,

Voici le rapport du $(date +%d/%m/%Y):
- Nombre de connexions: $(grep "login" /var/log/auth.log | wc -l)
- Espace disque: $(df -h / | tail -1 | awk '{print $5}')

Cordialement,
Le système
BODY
```

**3. Génération de code HTML**

```bash
titre="Ma Page Web"
contenu="Bienvenue sur mon site"

cat <<HTML > page.html
<!DOCTYPE html>
<html>
<head>
    <title>$titre</title>
</head>
<body>
    <h1>$titre</h1>
    <p>$contenu</p>
    <p>Généré le $(date)</p>
</body>
</html>
HTML
```

---

## 🔒 Here Documents sans substitution (<<'EOF')

En entourant le délimiteur de quotes simples ou doubles, on désactive toutes les expansions.

### Protection du contenu

```bash
# Avec quotes simples : AUCUNE expansion
cat <<'EOF'
Le prix est $100
L'utilisateur est $USER
La date est $(date)
EOF
```

**Sortie :**

```
Le prix est $100
L'utilisateur est $USER
La date est $(date)
```

> [!info] Équivalences Ces trois syntaxes sont équivalentes pour désactiver l'expansion :
> 
> - `<<'EOF'`
> - `<<"EOF"`
> - `<<\EOF`

### Quand utiliser cette forme ?

```bash
# 1. Génération de scripts bash
cat <<'SCRIPT' > nouveau_script.sh
#!/bin/bash
# Ce script utilise des variables
nom=$1
echo "Bonjour $nom"
SCRIPT

# 2. Documentation avec exemples de code
cat <<'DOC'
Pour utiliser cette variable :
    export PATH=$PATH:/usr/local/bin
    echo $HOME
DOC

# 3. Génération de templates
cat <<'TEMPLATE' > config.template
# Configuration
SERVER=${SERVER_NAME}
PORT=${SERVER_PORT}
# Ces variables seront remplacées plus tard
TEMPLATE
```

### Différences avec la forme classique

|Caractéristique|`<<EOF`|`<<'EOF'`|
|---|---|---|
|Variables (`$var`)|✅ Expansées|❌ Littérales|
|Commandes (`$(cmd)`)|✅ Exécutées|❌ Littérales|
|Backticks (`` `cmd` ``)|✅ Exécutées|❌ Littérales|
|Backslash (`\`)|✅ Échappe|❌ Littéral|
|Usage principal|Génération dynamique|Modèles statiques|

> [!example] Exemple comparatif
> 
> ```bash
> USER="alice"
> 
> # Avec expansion
> cat <<EOF
> User: $USER
> EOF
> # Sortie : User: alice
> 
> # Sans expansion
> cat <<'EOF'
> User: $USER
> EOF
> # Sortie : User: $USER
> ```

---

## ⚡ Here Strings (<<<)

Les **here strings** sont une variante compacte pour passer une chaîne unique (généralement une ligne) à une commande.

### Syntaxe et utilisation

```bash
# Syntaxe de base
commande <<< "chaîne de caractères"

# Équivalent à :
echo "chaîne de caractères" | commande
```

> [!example] Exemples pratiques
> 
> ```bash
> # Lecture d'une variable
> read var <<< "valeur"
> echo $var  # Affiche : valeur
> 
> # Traitement avec grep
> grep "motif" <<< "texte contenant un motif"
> 
> # Calcul avec bc
> resultat=$(bc <<< "scale=2; 10/3")
> echo $resultat  # Affiche : 3.33
> 
> # Conversion avec base64
> encoded=$(base64 <<< "mon texte secret")
> 
> # Comptage de mots
> wc -w <<< "un deux trois quatre"  # Affiche : 4
> ```

### Avantages des here strings

**1. Concision**

```bash
# Avec here string (concis)
grep "error" <<< "$log_line"

# Sans here string (verbeux)
echo "$log_line" | grep "error"
```

**2. Pas de sous-shell inutile**

```bash
# Here string : pas de sous-shell pour echo
read a b c <<< "1 2 3"

# Pipe : crée un sous-shell
echo "1 2 3" | read a b c  # Les variables peuvent ne pas persister
```

**3. Gestion des variables avec espaces**

```bash
texte="ligne 1
ligne 2
ligne 3"

# Here string préserve les nouvelles lignes
wc -l <<< "$texte"  # Compte 3 lignes

# Expansion de variables
nombre=42
bc <<< "$nombre * 2"  # Calcule 84
```

### Comparaison avec les alternatives

|Méthode|Syntaxe|Cas d'usage|
|---|---|---|
|Here string|`cmd <<< "$var"`|Passage rapide d'une variable|
|Pipe avec echo|`echo "$var" \| cmd`|Traditionnel, plus verbeux|
|Here document|`cmd <<EOF`<br>`$var`<br>`EOF`|Multi-lignes, blocs de texte|
|Fichier temporaire|`echo "$var" > tmp; cmd < tmp`|Rarement nécessaire|

> [!tip] Astuce pour les tableaux
> 
> ```bash
> # Passer un tableau en entrée
> fruits=("pomme" "banane" "orange")
> 
> while read fruit; do
>     echo "Fruit: $fruit"
> done <<< "$(printf '%s\n' "${fruits[@]}")"
> ```

---

## ⚠️ Pièges courants et bonnes pratiques

### Piège 1 : Indentation du délimiteur

```bash
# ❌ ERREUR : espaces avant EOF
if true; then
    cat <<EOF
    texte
    EOF  # Bash ne reconnaîtra pas ce EOF !
fi

# ✅ CORRECT : EOF à la marge
if true; then
    cat <<EOF
texte
EOF
fi

# ✅ ALTERNATIVE : utiliser <<- pour ignorer les tabs
if true; then
    cat <<-EOF
	texte indenté avec des TABS
	EOF
fi
```

> [!warning] Attention `<<-` retire uniquement les **tabulations** en début de ligne, pas les espaces !

### Piège 2 : Oublier les quotes pour du contenu littéral

```bash
# ❌ Générer un script avec expansion non voulue
cat <<EOF > script.sh
echo "Bonjour $USER"  # $USER sera remplacé maintenant !
EOF

# ✅ Utiliser des quotes pour du contenu littéral
cat <<'EOF' > script.sh
echo "Bonjour $USER"  # $USER restera littéral
EOF
```

### Piège 3 : Délimiteur mal choisi

```bash
# ❌ Mauvais choix si le texte contient "EOF"
cat <<EOF
Ceci est la fin du fichier EOF
Ce n'est pas vraiment la fin
EOF  # Bash s'arrête ici !

# ✅ Choisir un délimiteur unique
cat <<END_OF_TEXT
Ceci est la fin du fichier EOF
Ce n'est pas vraiment la fin
END_OF_TEXT
```

### Bonnes pratiques

> [!tip] Conventions de nommage
> 
> - `EOF` : End Of File (le plus courant)
> - `SQL` : pour du code SQL
> - `HTML`, `JSON`, `XML` : selon le type de contenu
> - `END`, `DONE`, `MARKER` : alternatives génériques

**1. Toujours quoter les variables dans les here strings**

```bash
# ✅ Bon
var="texte avec espaces"
grep "pattern" <<< "$var"

# ❌ Risqué
grep "pattern" <<< $var  # Word splitting !
```

**2. Utiliser des here documents pour la lisibilité**

```bash
# ❌ Difficile à lire
echo "Ligne 1" > fichier.txt; echo "Ligne 2" >> fichier.txt; echo "Ligne 3" >> fichier.txt

# ✅ Clair et maintenable
cat <<EOF > fichier.txt
Ligne 1
Ligne 2
Ligne 3
EOF
```

**3. Préférer `<<-` pour le code indenté**

```bash
# ✅ Code proprement indenté
function afficher_menu() {
    cat <<-'MENU'
	1. Option 1
	2. Option 2
	3. Quitter
	MENU
}
```

---

## 💡 Astuces avancées

### Astuce 1 : Redirection multiple

```bash
# Envoyer vers fichier ET afficher
cat <<EOF | tee fichier.txt
Contenu à la fois
affiché et enregistré
EOF

# Envoyer vers plusieurs fichiers
cat <<EOF | tee fichier1.txt fichier2.txt > /dev/null
Contenu dupliqué
EOF
```

### Astuce 2 : Here documents dans des fonctions

```bash
function generer_config() {
    local nom=$1
    local valeur=$2
    
    cat <<CONFIG
[section]
$nom = $valeur
date_creation = $(date -I)
CONFIG
}

# Utilisation
generer_config "timeout" "30" > config.ini
```

### Astuce 3 : Combinaison avec des pipes

```bash
# Filtrage du contenu
cat <<EOF | grep "important"
ligne normale
ligne importante
autre ligne importante
ligne finale
EOF

# Transformation avec sed
cat <<EOF | sed 's/foo/bar/g'
foo est partout
foo foo foo
EOF

# Tri du contenu
cat <<EOF | sort
zebra
alpha
beta
EOF
```

### Astuce 4 : Here documents avec sudo

```bash
# Créer un fichier avec sudo
sudo tee /etc/config.conf > /dev/null <<EOF
# Configuration système
option1=valeur1
option2=valeur2
EOF

# Ou avec cat et sudo sh
sudo sh -c 'cat <<EOF > /etc/config.conf
option1=valeur1
option2=valeur2
EOF'
```

### Astuce 5 : Échappement sélectif

```bash
# Mélanger expansion et littéral
nom="Alice"
cat <<EOF
Bonjour $nom
Le symbole dollar littéral : \$
Commande non exécutée : \$(date)
Mais celle-ci oui : $(date)
EOF
```

### Astuce 6 : Here documents dans des boucles

```bash
# Générer plusieurs fichiers
for i in {1..3}; do
    cat <<EOF > fichier_$i.txt
Fichier numéro $i
Créé le $(date)
EOF
done

# Traiter plusieurs entrées
while read ligne; do
    echo "Traitement: $ligne"
done <<DONNEES
ligne 1
ligne 2
ligne 3
DONNEES
```

### Astuce 7 : Suppression des tabs en début de ligne

```bash
# <<- retire les tabs initiaux (pas les espaces !)
if true; then
	cat <<-EOF
		Ce texte est indenté avec des TABS
		Les tabs initiaux seront retirés
		Mais pas les espaces    internes
	EOF
fi
```

> [!tip] Conversion espaces → tabs Dans votre éditeur, configurez l'indentation en tabulations pour profiter de `<<-`, ou utilisez `expand -t 4` pour convertir.

### Astuce 8 : Here strings avec des tableaux

```bash
# Joindre des éléments de tableau
array=("un" "deux" "trois")
joined=$(IFS=,; echo "${array[*]}")
wc -w <<< "$joined"

# Ou directement
printf '%s\n' "${array[@]}" | while read item; do
    echo "Item: $item"
done
```

### Astuce 9 : Validation et tests

```bash
# Tester une commande avec un here document
test_sql() {
    sqlite3 :memory: <<SQL
CREATE TABLE test (id INT, nom TEXT);
INSERT INTO test VALUES (1, 'Alice');
SELECT * FROM test;
SQL
}

# Tester avec différentes entrées
for input in "test1" "test2" "test3"; do
    resultat=$(mon_programme <<< "$input")
    echo "Input: $input → Output: $resultat"
done
```

---

> [!info] Résumé des syntaxes
> 
> - `<<EOF` : Here document avec expansion
> - `<<'EOF'` : Here document sans expansion (littéral)
> - `<<-EOF` : Here document avec suppression des tabs initiaux
> - `<<<` : Here string pour une ligne/variable

Les here documents sont un outil essentiel pour écrire des scripts bash propres, lisibles et maintenables. Maîtriser leurs différentes formes permet d'éviter les fichiers temporaires et de mieux structurer son code.