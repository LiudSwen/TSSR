# ⚡ L'essentiel en 5 minutes - Scripts Bash TSSR

## 📌 C'est quoi en 2 lignes ?

Le script Bash est un fichier texte exécutable qui automatise des tâches système. Il permet d'enchaîner des commandes, gérer des conditions, boucles et variables pour créer des programmes shell réutilisables.

---

## 💡 Concepts clés à retenir

- **Shebang** : Ligne `#!/bin/bash` qui spécifie l'interpréteur à utiliser
- **Variables spéciales** : `$0` (nom script), `$1-$9` (arguments), `$#` (nb args), `$?` (code sortie), `$$` (PID)
- **Code de sortie** : Valeur 0-255 indiquant le statut (0 = succès, autre = erreur)
- **Substitution** : `$(commande)` capture le résultat d'une commande, `$(( calcul ))` pour l'arithmétique
- **Test** : Condition vraie = 0, fausse = valeur non-nulle (inversé par rapport à la logique standard)

---

## 💻 Commandes essentielles

```bash
# 🐧 Création et exécution de script
chmod u+x script.sh              # Rendre exécutable
./script.sh arg1 arg2            # Exécuter avec arguments
source script.sh                 # Exécuter dans le shell courant (garde les variables)

# 🔍 Variables
var="valeur"                     # Affectation (PAS d'espace autour du =)
echo "$var"                      # Utilisation (toujours entre guillemets)
read -p "Question : " var        # Saisie utilisateur
export VAR="valeur"              # Rendre disponible aux sous-shells

# 🧮 Substitutions
resultat=$(commande)             # Capturer sortie d'une commande
calcul=$(( 5 + 3 * 2 ))          # Calcul arithmétique
nombre=$(( $nombre + 1 ))        # Incrémenter
```

```bash
# 🔀 Structures conditionnelles
if [ condition ]; then           # Si (attention aux espaces !)
  instructions
elif [ condition2 ]; then        # Sinon si (optionnel)
  instructions
else                             # Sinon (optionnel)
  instructions
fi

case $variable in                # Choix multiple
  valeur1) instructions;;
  valeur2|valeur3) instructions;;
  *) instructions_defaut;;       # Cas par défaut
esac

# 🔁 Boucles
for var in liste mot1 mot2; do   # Pour chaque élément
  instructions
done

for (( i=0; i<10; i++ )); do     # Boucle style C
  instructions
done

while [ condition ]; do          # Tant que
  instructions
done
```

```bash
# 🧪 Tests et opérateurs
# Comparaison nombres
[ $a -eq $b ]    # Égal          [ $a -ne $b ]    # Différent
[ $a -lt $b ]    # Inférieur     [ $a -le $b ]    # Inférieur ou égal
[ $a -gt $b ]    # Supérieur     [ $a -ge $b ]    # Supérieur ou égal

# Comparaison chaînes
[ "$s1" = "$s2" ]    # Égal (un seul =)
[ "$s1" != "$s2" ]   # Différent
[ -z "$s" ]          # Chaîne vide
[ -n "$s" ]          # Chaîne non-vide

# Tests fichiers
[ -e fichier ]       # Existe
[ -f fichier ]       # Est un fichier
[ -d dossier ]       # Est un dossier
[ -r fichier ]       # Lisible
[ -w fichier ]       # Modifiable
[ -x fichier ]       # Exécutable
[ -s fichier ]       # Existe et taille > 0

# Opérateurs logiques
[ ! condition ]              # NON
[ $a -gt 5 -a $a -lt 10 ]   # ET (-a)
[ $a -eq 1 -o $a -eq 2 ]    # OU (-o)
[[ condition1 && condition2 ]]  # ET moderne
[[ condition1 || condition2 ]]  # OU moderne
```

```bash
# 🔧 Fonctions
function nom() {                 # Déclaration (méthode 1)
  local var="locale"            # Variable locale à la fonction
  echo "$1"                     # Premier argument de la fonction
  return 0                      # Code retour (0-255)
}

nom() {                          # Déclaration (méthode 2, sans 'function')
  resultat=$(( $1 + $2 ))
  echo $resultat                # Sortir une valeur texte
}

nom arg1 arg2                    # Appel de fonction
valeur=$(nom 5 10)              # Capturer le résultat
```

---

## ⚠️ Pièges à éviter

- ❌ **Espaces dans l'affectation** : `var = "valeur"` → ERREUR (doit être `var="valeur"`)
- ❌ **Variables sans guillemets** : `[ $var = "texte" ]` échoue si $var contient des espaces → utiliser `[ "$var" = "texte" ]`
- ❌ **Confusion test** : Bash considère 0 = vrai et non-zéro = faux (inverse de la logique habituelle)
- ❌ **sudo dans les scripts** : Mettre sudo dans le script = risque sécurité → toujours exécuter avec `sudo ./script.sh`
- ❌ **Oublier le shebang** : Sans `#!/bin/bash`, le script peut être interprété par le mauvais shell

---

## ✅ Bonnes pratiques

- ✅ **Toujours quoter les variables** : `"$var"` évite les problèmes avec espaces et caractères spéciaux
- ✅ **Tester avec ShellCheck** : Outil de validation qui détecte les erreurs courantes (`shellcheck script.sh`)
- ✅ **Vérifier les droits sudo** : `if [[ $EUID -ne 0 ]]; then echo "Nécessite sudo" >&2; exit 1; fi`
- ✅ **Utiliser local dans les fonctions** : Évite les conflits de variables globales
- ✅ **Terminer avec exit** : `exit 0` (succès) ou `exit 1` (erreur) pour retourner un code propre
- ✅ **Commenter le code** : `# Commentaire` pour expliquer la logique
- ✅ **Suffixe .sh** : Nommer les scripts `script.sh` pour clarté
- ✅ **Portable shebang** : `#!/usr/bin/env bash` pour meilleure compatibilité multi-distributions

---

## 📚 Vocabulaire technique

|Terme|Définition courte|
|---|---|
|**Shebang**|`#!` + chemin interpréteur en 1ère ligne du script|
|**Argument**|Valeur passée au script à l'exécution (`./script.sh arg1`)|
|**Paramètre**|Variable interne récupérant un argument (`$1`, `$2`)|
|**Code de sortie**|Valeur 0-255 indiquant succès (0) ou erreur (autre)|
|**Métacaractère**|Caractère spécial Bash : `|
|**Substitution**|Capture de résultat : `$(cmd)` ou calcul `$((expr))`|
|**Quoting**|Guillemets `"` (interprète $) ou apostrophes `'` (littéral)|
|**Test**|Évaluation condition entre `[ ]` ou `[[ ]]`|
|**$?**|Variable contenant le code de sortie de la dernière commande|
|**local**|Déclare une variable limitée à la portée d'une fonction|
|**source**|Exécute script dans le shell courant (conserve variables)|
|**export**|Rend variable disponible aux processus enfants|

---

## 🎯 À retenir ABSOLUMENT

### 1. 💡 **Théorique** : Tests inversés en Bash

En Bash, 0 = vrai (succès) et non-zéro = faux (échec). C'est l'inverse de la logique habituelle ! `echo $?` affiche le code de sortie de la dernière commande.

### 2. 💻 **Pratique** : Quoter systématiquement

```bash
# ❌ MAUVAIS : plante si $nom contient des espaces
if [ $nom = "Bob" ]; then echo "OK"; fi

# ✅ BON : toujours entre guillemets
if [ "$nom" = "Bob" ]; then echo "OK"; fi
```

### 3. ⚠️ **Piège** : Espaces et syntaxe stricte

```bash
var="valeur"     # ✅ Correct
var = "valeur"   # ❌ ERREUR : espaces interdits
[ $a -eq 5 ]     # ✅ Espaces obligatoires dans les crochets
[$a -eq 5]       # ❌ ERREUR : manque espaces
```

---

## 🔑 Aide-mémoire rapide

**Structure minimale d'un script :**

```bash
#!/bin/bash
# Description du script

# Code ici
exit 0
```

**Checker rapidement :**

```bash
shellcheck script.sh    # Vérifier les erreurs
bash -n script.sh       # Vérifier la syntaxe sans exécuter
```

**Déboguer :**

```bash
bash -x script.sh       # Mode debug (affiche chaque ligne exécutée)
set -x                  # Activer debug dans le script
set +x                  # Désactiver debug
```

**Codes de sortie courants :**

- `0` → Succès
- `1` → Erreur générale
- `2` → Mauvaise syntaxe
- `126` → Pas de droit d'exécution
- `127` → Commande introuvable
