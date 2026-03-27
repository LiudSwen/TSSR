

## 📚 Table des matières

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

## Introduction

La commande `read` est l'outil principal pour interagir avec l'utilisateur dans un script Bash. Elle permet de capturer les entrées clavier et de les stocker dans des variables pour un traitement ultérieur.

> [!info] Pourquoi utiliser `read` ?
> 
> - Créer des scripts interactifs
> - Recueillir des informations de configuration
> - Demander des confirmations avant des actions critiques
> - Personnaliser l'exécution d'un script selon les besoins de l'utilisateur

---

## Syntaxe de base

La syntaxe la plus simple de `read` consiste à lire l'entrée utilisateur et à la stocker dans une variable.

```bash
read variable
```

> [!example] Exemple basique
> 
> ```bash
> #!/bin/bash
> 
> echo "Comment vous appelez-vous ?"
> read nom
> echo "Bonjour, $nom !"
> ```
> 
> **Exécution :**
> 
> ```
> Comment vous appelez-vous ?
> Alice
> Bonjour, Alice !
> ```

### Fonctionnement

1. Le script s'arrête et attend une entrée utilisateur
2. L'utilisateur tape du texte et appuie sur Entrée
3. Le texte saisi est stocké dans la variable spécifiée
4. Le script reprend son exécution

> [!warning] Attention Si aucune variable n'est spécifiée (`read` seul), l'entrée est stockée dans la variable spéciale `$REPLY`.

---

## Option `-p` : Afficher un prompt

L'option `-p` permet d'afficher un message d'invite (prompt) sur la même ligne que la saisie, rendant le code plus concis et lisible.

```bash
read -p "message" variable
```

> [!example] Comparaison avec/sans `-p`
> 
> **Sans `-p` :**
> 
> ```bash
> echo "Entrez votre âge :"
> read age
> ```
> 
> **Avec `-p` :**
> 
> ```bash
> read -p "Entrez votre âge : " age
> ```
> 
> Les deux produisent le même résultat, mais la version avec `-p` est plus élégante.

> [!tip] Astuce de formatage Ajoutez un espace à la fin du message pour séparer visuellement le prompt de la saisie :
> 
> ```bash
> read -p "Nom : " nom
> # Au lieu de
> read -p "Nom :" nom
> ```

### Exemple pratique

```bash
#!/bin/bash

read -p "Entrez votre ville : " ville
read -p "Entrez votre code postal : " code_postal

echo "Vous habitez à $ville ($code_postal)"
```

---

## Option `-s` : Mode silencieux

L'option `-s` (silent) masque la saisie de l'utilisateur, essentielle pour les mots de passe et données sensibles.

```bash
read -s variable
```

> [!example] Saisie de mot de passe
> 
> ```bash
> #!/bin/bash
> 
> read -p "Nom d'utilisateur : " username
> read -sp "Mot de passe : " password
> echo  # Retour à la ligne après la saisie masquée
> 
> echo "Connexion en tant que $username..."
> ```
> 
> **Exécution :**
> 
> ```
> Nom d'utilisateur : alice
> Mot de passe : 
> Connexion en tant que alice...
> ```

> [!warning] N'oubliez pas le retour à la ligne ! Après un `read -s`, ajoutez toujours un `echo` pour revenir à la ligne, sinon la sortie suivante apparaîtra sur la même ligne que le prompt.

### Exemple complet de formulaire sécurisé

```bash
#!/bin/bash

echo "=== Création de compte ==="
read -p "Nom d'utilisateur : " username

# Première saisie du mot de passe
read -sp "Mot de passe : " password1
echo

# Confirmation du mot de passe
read -sp "Confirmer le mot de passe : " password2
echo

if [ "$password1" = "$password2" ]; then
    echo "✓ Compte créé avec succès pour $username"
else
    echo "✗ Les mots de passe ne correspondent pas"
fi
```

---

## Option `-t` : Définir un timeout

L'option `-t` définit un délai d'attente en secondes. Si l'utilisateur ne répond pas à temps, `read` retourne un code d'erreur.

```bash
read -t secondes variable
```

> [!info] Cas d'usage
> 
> - Scripts automatisés avec valeurs par défaut
> - Confirmations avec timeout de sécurité
> - Menus interactifs avec expiration

> [!example] Confirmation avec timeout
> 
> ```bash
> #!/bin/bash
> 
> echo "Fichier système sur le point d'être supprimé !"
> 
> if read -t 5 -p "Voulez-vous continuer ? (o/n) " reponse; then
>     if [ "$reponse" = "o" ]; then
>         echo "Suppression en cours..."
>     else
>         echo "Annulation."
>     fi
> else
>     echo -e "\nTemps écoulé. Opération annulée par sécurité."
> fi
> ```

### Code de retour

|Code|Signification|
|---|---|
|0|Lecture réussie dans le délai|
|> 0|Timeout dépassé ou erreur|

```bash
#!/bin/bash

if read -t 3 -p "Répondez vite : " reponse; then
    echo "Vous avez dit : $reponse"
else
    echo "Trop lent ! Valeur par défaut appliquée."
    reponse="valeur_defaut"
fi
```

> [!tip] Combiner timeout et valeur par défaut Utilisez le timeout pour proposer automatiquement une valeur par défaut si l'utilisateur ne répond pas, idéal pour l'automatisation.

---

## Option `-n` : Limiter le nombre de caractères

L'option `-n` limite la lecture à un nombre exact de caractères, sans attendre la touche Entrée.

```bash
read -n nombre variable
```

> [!example] Menu à choix unique
> 
> ```bash
> #!/bin/bash
> 
> echo "Choisissez une option :"
> echo "1) Démarrer"
> echo "2) Arrêter"
> echo "3) Redémarrer"
> 
> read -n 1 -p "Votre choix : " choix
> echo  # Retour à la ligne
> 
> case $choix in
>     1) echo "Démarrage en cours..." ;;
>     2) echo "Arrêt en cours..." ;;
>     3) echo "Redémarrage en cours..." ;;
>     *) echo "Choix invalide" ;;
> esac
> ```

### Confirmation oui/non rapide

```bash
#!/bin/bash

read -n 1 -p "Êtes-vous sûr ? (o/n) " reponse
echo

if [ "$reponse" = "o" ]; then
    echo "Confirmé !"
else
    echo "Annulé."
fi
```

> [!tip] Expérience utilisateur fluide Avec `-n 1`, l'utilisateur n'a pas besoin d'appuyer sur Entrée, ce qui rend l'interaction plus rapide et naturelle pour les choix simples.

### Lecture d'un code PIN

```bash
#!/bin/bash

read -n 4 -sp "Entrez votre code PIN (4 chiffres) : " pin
echo
echo "Code saisi : ${#pin} caractères"
```

---

## Option `-a` : Lecture dans un tableau

L'option `-a` permet de stocker l'entrée utilisateur directement dans un tableau, en séparant les mots par des espaces.

```bash
read -a tableau
```

> [!example] Saisie de plusieurs valeurs
> 
> ```bash
> #!/bin/bash
> 
> read -p "Entrez vos fruits préférés (séparés par des espaces) : " -a fruits
> 
> echo "Vous avez entré ${#fruits[@]} fruits :"
> for i in "${!fruits[@]}"; do
>     echo "  $((i+1)). ${fruits[i]}"
> done
> ```
> 
> **Exécution :**
> 
> ```
> Entrez vos fruits préférés (séparés par des espaces) : pomme banane orange
> Vous avez entré 3 fruits :
>   1. pomme
>   2. banane
>   3. orange
> ```

### Accès aux éléments du tableau

```bash
#!/bin/bash

read -p "Entrez des nombres : " -a nombres

echo "Premier nombre : ${nombres[0]}"
echo "Deuxième nombre : ${nombres[1]}"
echo "Tous les nombres : ${nombres[@]}"
echo "Nombre d'éléments : ${#nombres[@]}"
```

> [!warning] Séparateur par défaut Par défaut, `read -a` sépare les éléments selon la variable `IFS` (Internal Field Separator), qui contient espace, tabulation et retour à la ligne. Pour un comportement différent, modifiez `IFS`.

### Exemple avec IFS personnalisé

```bash
#!/bin/bash

# Lecture d'une liste séparée par des virgules
IFS=',' read -p "Entrez des emails (séparés par ,) : " -a emails

echo "Emails enregistrés :"
for email in "${emails[@]}"; do
    # Suppression des espaces autour
    email=$(echo "$email" | xargs)
    echo "  - $email"
done
```

---

## Lecture de plusieurs variables

`read` peut lire plusieurs valeurs en une seule commande et les affecter à différentes variables.

```bash
read var1 var2 var3
```

### Comportement

- Les mots sont séparés selon `IFS` (par défaut : espaces)
- Chaque mot est affecté à une variable dans l'ordre
- Si plus de mots que de variables : les mots supplémentaires vont dans la dernière variable
- Si moins de mots que de variables : les variables restantes sont vides

> [!example] Lecture de prénom et nom
> 
> ```bash
> #!/bin/bash
> 
> read -p "Entrez votre prénom et nom : " prenom nom
> echo "Bonjour $prenom $nom !"
> ```
> 
> **Exécution :**
> 
> ```
> Entrez votre prénom et nom : Marie Dupont
> Bonjour Marie Dupont !
> ```

### Cas avec surplus de mots

```bash
#!/bin/bash

read -p "Entrez trois mots : " mot1 mot2 mot3

echo "Mot 1 : $mot1"
echo "Mot 2 : $mot2"
echo "Mot 3 : $mot3"
```

**Si l'utilisateur entre "un deux trois quatre cinq" :**

```
Mot 1 : un
Mot 2 : deux
Mot 3 : trois quatre cinq
```

> [!tip] La dernière variable capture tout le reste C'est utile pour capturer une phrase complète dans la dernière variable :
> 
> ```bash
> read -p "Titre et description : " titre description
> # titre = premier mot
> # description = tout le reste
> ```

### Exemple pratique : Date de naissance

```bash
#!/bin/bash

read -p "Entrez votre date de naissance (JJ MM AAAA) : " jour mois annee

echo "Vous êtes né(e) le $jour/$mois/$annee"

# Validation simple
if [ "$annee" -lt 1900 ] || [ "$annee" -gt 2024 ]; then
    echo "Année invalide !"
fi
```

---

## Combinaison d'options

Les options de `read` peuvent être combinées pour créer des interactions sophistiquées.

### Tableau des combinaisons utiles

|Combinaison|Usage|
|---|---|
|`-p -s`|Prompt avec saisie masquée (mot de passe)|
|`-p -t`|Prompt avec timeout|
|`-n -t`|Choix unique avec timeout|
|`-p -a`|Prompt pour tableau|
|`-s -n`|Saisie masquée de longueur fixe (PIN)|
|`-p -s -t`|Mot de passe avec timeout|

> [!example] Menu interactif avec timeout
> 
> ```bash
> #!/bin/bash
> 
> echo "=== Menu Principal ==="
> echo "1) Option A"
> echo "2) Option B"
> echo "3) Quitter"
> 
> if read -n 1 -t 10 -p "Choix [auto-sélection dans 10s] : " choix; then
>     echo
>     case $choix in
>         1) echo "Option A sélectionnée" ;;
>         2) echo "Option B sélectionnée" ;;
>         3) echo "Au revoir !" ;;
>         *) echo "Choix invalide" ;;
>     esac
> else
>     echo -e "\nTimeout - Sortie automatique"
>     exit 0
> fi
> ```

### Formulaire de connexion complet

```bash
#!/bin/bash

echo "=== Connexion Sécurisée ==="

# Nom d'utilisateur avec timeout
if ! read -t 30 -p "Nom d'utilisateur : " username; then
    echo -e "\nTimeout - Session expirée"
    exit 1
fi

# Mot de passe masqué avec timeout
if ! read -t 30 -sp "Mot de passe : " password; then
    echo -e "\nTimeout - Session expirée"
    exit 1
fi
echo

# Confirmation rapide
read -n 1 -p "Se souvenir de moi ? (o/n) : " remember
echo

echo "Connexion en cours pour $username..."
```

---

## Bonnes pratiques

> [!tip] Validation des entrées Toujours valider les données saisies par l'utilisateur :
> 
> ```bash
> read -p "Entrez un nombre : " nombre
> 
> if ! [[ "$nombre" =~ ^[0-9]+$ ]]; then
>     echo "Erreur : ce n'est pas un nombre valide"
>     exit 1
> fi
> ```

> [!tip] Valeurs par défaut Proposez des valeurs par défaut pour améliorer l'expérience :
> 
> ```bash
> read -p "Port [8080] : " port
> port=${port:-8080}  # Si vide, utilise 8080
> echo "Utilisation du port $port"
> ```

> [!tip] Messages clairs Soyez explicite sur le format attendu :
> 
> ```bash
> read -p "Date (JJ/MM/AAAA) : " date
> read -p "Email (ex: user@domain.com) : " email
> ```

> [!tip] Gestion des erreurs Vérifiez le code de retour de `read` :
> 
> ```bash
> if read -p "Continuer ? " reponse; then
>     echo "Vous avez répondu : $reponse"
> else
>     echo "Erreur de lecture"
>     exit 1
> fi
> ```

> [!tip] Nettoyage des données Supprimez les espaces superflus :
> 
> ```bash
> read -p "Nom : " nom
> nom=$(echo "$nom" | xargs)  # Supprime espaces début/fin
> ```

---

## Pièges courants

> [!warning] Oubli du retour à la ligne après `-s`
> 
> ```bash
> # ❌ Mauvais
> read -sp "Mot de passe : " password
> echo "Connexion..."  # S'affiche sur la même ligne
> 
> # ✓ Correct
> read -sp "Mot de passe : " password
> echo  # Retour à la ligne
> echo "Connexion..."
> ```

> [!warning] Variables non initialisées Si `read` échoue (timeout, interruption), la variable peut rester vide :
> 
> ```bash
> # ❌ Risqué
> read -t 5 -p "Nom : " nom
> echo "Bonjour $nom"  # $nom peut être vide
> 
> # ✓ Sécurisé
> if read -t 5 -p "Nom : " nom; then
>     echo "Bonjour $nom"
> else
>     nom="Utilisateur"
>     echo "Bonjour $nom (nom par défaut)"
> fi
> ```

> [!warning] Guillemets autour des variables Toujours mettre les variables entre guillemets pour gérer les espaces :
> 
> ```bash
> read -p "Phrase : " phrase
> 
> # ❌ Problème si phrase contient des espaces
> echo Vous avez dit : $phrase
> 
> # ✓ Correct
> echo "Vous avez dit : $phrase"
> ```

> [!warning] Confusion entre `-n` et nombre d'éléments `-n` limite les caractères, pas le nombre de mots :
> 
> ```bash
> # Attend exactement 5 caractères
> read -n 5 input
> # "hello" → OK
> # "hi" → attend encore 3 caractères
> ```

> [!warning] Modifications de IFS globales Si vous modifiez `IFS`, restaurez-le ensuite :
> 
> ```bash
> # ✓ Sauvegarde et restauration
> OLD_IFS="$IFS"
> IFS=','
> read -a tableau <<< "a,b,c"
> IFS="$OLD_IFS"
> ```

> [!warning] Sécurité avec `-s` Le mode silencieux ne protège que l'affichage. Le mot de passe reste en clair en mémoire :
> 
> ```bash
> read -sp "Mot de passe : " password
> # $password contient le mot de passe en clair
> # Ne jamais l'afficher : echo "$password"  # ❌
> ```

---

## 🎯 Résumé des options

|Option|Syntaxe|Description|Usage typique|
|---|---|---|---|
|`-p`|`read -p "prompt" var`|Affiche un prompt|Tous les cas|
|`-s`|`read -s var`|Masque la saisie|Mots de passe|
|`-t`|`read -t 10 var`|Timeout (secondes)|Valeurs par défaut, sécurité|
|`-n`|`read -n 4 var`|Limite les caractères|Menus, codes PIN|
|`-a`|`read -a tableau`|Stocke dans un tableau|Listes d'éléments|

---

**💡 L'essentiel à retenir :**

- `read` est l'outil standard pour l'interaction utilisateur en Bash
- Utilisez `-p` pour des prompts élégants et `-s` pour les données sensibles
- Les timeouts (`-t`) améliorent l'automatisation et la sécurité
- Validez toujours les entrées utilisateur
- Combinez les options pour créer des interfaces sophistiquées
- Gérez les cas d'erreur et proposez des valeurs par défaut