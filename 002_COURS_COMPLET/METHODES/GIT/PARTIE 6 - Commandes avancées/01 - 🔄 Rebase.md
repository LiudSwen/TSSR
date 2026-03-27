

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

## 🎯 Introduction au Rebase

Le **rebase** est une commande Git puissante qui permet de réorganiser l'historique des commits. Contrairement au merge qui crée un nouveau commit de fusion, le rebase réécrit l'historique en déplaçant ou en combinant des commits.

> [!info] Pourquoi utiliser le rebase ?
> 
> - Maintenir un historique linéaire et propre
> - Éviter les commits de merge inutiles
> - Faciliter la lecture de l'historique du projet
> - Nettoyer et organiser vos commits avant de les partager

---

## ⚙️ La commande git rebase

### Syntaxe de base

```bash
# Rebaser la branche courante sur une autre branche
git rebase <branche-cible>

# Rebaser sur la branche main
git rebase main

# Rebaser sur une branche distante
git rebase origin/main
```

### Fonctionnement détaillé

Lorsque vous exécutez `git rebase main` depuis votre branche de feature :

1. Git identifie le commit commun entre votre branche et `main`
2. Git met de côté tous vos commits depuis ce point
3. Git avance votre branche au même niveau que `main`
4. Git réapplique vos commits un par un sur cette nouvelle base

```bash
# Avant le rebase
main:     A---B---C
               \
feature:        D---E

# Après git rebase main depuis feature
main:     A---B---C
                   \
feature:            D'---E'
```

> [!example] Exemple pratique
> 
> ```bash
> # Vous êtes sur votre branche feature
> git checkout feature
> 
> # Vous voulez intégrer les derniers changements de main
> git fetch origin
> git rebase origin/main
> 
> # Si tout se passe bien
> # Your branch is now rebased on origin/main
> ```

### Gestion des conflits pendant le rebase

```bash
# Si un conflit survient pendant le rebase
# 1. Résolvez les conflits dans les fichiers concernés

# 2. Ajoutez les fichiers résolus
git add <fichier-résolu>

# 3. Continuez le rebase
git rebase --continue

# Pour abandonner le rebase et revenir à l'état initial
git rebase --abort

# Pour sauter un commit problématique (à utiliser avec précaution)
git rebase --skip
```

> [!warning] Attention aux conflits Lors d'un rebase, vous pouvez avoir plusieurs conflits successifs car Git réapplique vos commits un par un. Soyez patient et résolvez chaque conflit méthodiquement.

### Options utiles

```bash
# Rebaser en préservant les merges commits
git rebase --preserve-merges <branche>

# Rebaser avec une stratégie de résolution de conflits
git rebase -X theirs <branche>  # Favorise les changements de la branche cible
git rebase -X ours <branche>    # Favorise vos changements

# Rebaser sur un commit spécifique
git rebase <commit-hash>

# Rebaser en mode verbose pour plus d'informations
git rebase --verbose <branche>
```

---

## 🔀 Différence entre Merge et Rebase

### Comparaison visuelle

|Aspect|Merge|Rebase|
|---|---|---|
|**Historique**|Non-linéaire, préserve l'historique complet|Linéaire, réécrit l'historique|
|**Commits supplémentaires**|Crée un commit de merge|Aucun commit supplémentaire|
|**Traçabilité**|Montre quand les branches ont été fusionnées|L'historique semble séquentiel|
|**Conflits**|Résolus une seule fois|Peuvent survenir plusieurs fois|
|**Sécurité**|Sûr pour les branches publiques|Dangereux pour les branches partagées|

### Merge : Préservation de l'historique

```bash
# Merge traditionnel
git checkout main
git merge feature

# Résultat
main:     A---B---C-------M
               \         /
feature:        D---E---
```

> [!info] Avantages du merge
> 
> - L'historique complet est préservé
> - Sûr pour les branches publiques
> - Montre clairement les points de fusion
> - Un seul conflit à résoudre par fusion

### Rebase : Historique linéaire

```bash
# Rebase pour un historique propre
git checkout feature
git rebase main

# Résultat
main:     A---B---C
                   \
feature:            D'---E'
```

> [!info] Avantages du rebase
> 
> - Historique linéaire et facile à lire
> - Pas de commits de merge inutiles
> - Facilite les bisect et les reverts
> - Logs Git plus propres

### Quand utiliser chacun ?

|Situation|Utiliser|
|---|---|
|Branche locale non partagée|**Rebase**|
|Intégration de changements dans votre branche de travail|**Rebase**|
|Fusion de feature dans main (branche publique)|**Merge**|
|Branches déjà push sur le remote|**Merge**|
|Préservation de l'historique exact nécessaire|**Merge**|
|Nettoyage avant une pull request|**Rebase**|

> [!tip] Workflow recommandé
> 
> ```bash
> # 1. Pendant le développement (branche privée)
> git rebase main  # Pour garder votre branche à jour
> 
> # 2. Avant de créer une pull request
> git rebase -i main  # Pour nettoyer vos commits
> 
> # 3. Pour intégrer dans main (branche publique)
> git checkout main
> git merge feature  # Merge classique pour préserver l'historique
> ```

---

## ✨ Rebase interactif

Le **rebase interactif** est l'une des fonctionnalités les plus puissantes de Git. Il permet de modifier, réorganiser, fusionner ou supprimer des commits dans l'historique.

### Lancer un rebase interactif

```bash
# Rebaser les N derniers commits de manière interactive
git rebase -i HEAD~3

# Rebaser tous les commits depuis un commit spécifique
git rebase -i <commit-hash>

# Rebaser depuis le commit parent
git rebase -i HEAD^

# Rebaser depuis une branche
git rebase -i main
```

### Interface du rebase interactif

Lorsque vous lancez un rebase interactif, un éditeur s'ouvre avec une liste de commits :

```bash
pick abc1234 Ajout de la fonctionnalité X
pick def5678 Correction d'un bug
pick ghi9012 Amélioration de la documentation

# Rebase abc1234..ghi9012 onto main (3 commands)
#
# Commands:
# p, pick <commit> = utiliser le commit
# r, reword <commit> = utiliser le commit, mais modifier le message
# e, edit <commit> = utiliser le commit, mais s'arrêter pour amender
# s, squash <commit> = utiliser le commit, mais le fusionner avec le précédent
# f, fixup <commit> = comme "squash", mais ignorer le message de commit
# x, exec <command> = exécuter une commande shell
# b, break = s'arrêter ici (continuer avec 'git rebase --continue')
# d, drop <commit> = supprimer le commit
# l, label <label> = marquer le HEAD courant avec un nom
# t, reset <label> = réinitialiser HEAD à un label
```

### Actions disponibles

#### 1. Pick - Garder un commit tel quel

```bash
pick abc1234 Ajout de la fonctionnalité X
```

> [!info] Usage C'est l'action par défaut. Le commit est conservé sans modification.

#### 2. Reword - Modifier le message de commit

```bash
reword abc1234 Ajout de la fonctionnalité X
```

> [!info] Usage Git s'arrêtera après l'application du commit pour vous permettre de modifier le message. Utile pour corriger les fautes ou améliorer la clarté.

#### 3. Edit - Modifier le contenu du commit

```bash
edit abc1234 Ajout de la fonctionnalité X
```

```bash
# Après que Git s'arrête sur ce commit
# Faites vos modifications
git add <fichiers>

# Amendez le commit
git commit --amend

# Continuez le rebase
git rebase --continue
```

> [!info] Usage Permet de modifier le contenu d'un commit (ajout/suppression de fichiers, modification du code).

#### 4. Squash - Fusionner avec le commit précédent

```bash
pick abc1234 Ajout de la fonctionnalité X
squash def5678 Correction d'un bug dans X
squash ghi9012 Ajout de tests pour X
```

> [!info] Usage Les commits marqués `squash` seront fusionnés avec le commit précédent. Vous pourrez éditer le message de commit combiné. Idéal pour regrouper des commits liés.

#### 5. Fixup - Fusionner en ignorant le message

```bash
pick abc1234 Ajout de la fonctionnalité X
fixup def5678 Oups, oublié un fichier
fixup ghi9012 Typo
```

> [!info] Usage Comme `squash`, mais le message du commit fixup est ignoré. Parfait pour des corrections mineures ou des oublis.

#### 6. Drop - Supprimer un commit

```bash
pick abc1234 Ajout de la fonctionnalité X
drop def5678 Commit de debug à supprimer
pick ghi9012 Amélioration de la documentation
```

> [!info] Usage Le commit est complètement supprimé de l'historique. Attention aux dépendances avec d'autres commits.

#### 7. Exec - Exécuter une commande

```bash
pick abc1234 Ajout de la fonctionnalité X
exec npm test
pick def5678 Correction d'un bug
exec npm test
```

> [!info] Usage Permet d'exécuter une commande shell après chaque commit. Utile pour vérifier que les tests passent à chaque étape.

### Réorganiser les commits

```bash
# Ordre original
pick abc1234 Commit C
pick def5678 Commit B
pick ghi9012 Commit A

# Modifier l'ordre en déplaçant les lignes
pick ghi9012 Commit A
pick def5678 Commit B
pick abc1234 Commit C
```

> [!warning] Attention à l'ordre Réorganiser les commits peut créer des conflits si les commits dépendent les uns des autres.

### Exemples pratiques

#### Nettoyer l'historique avant une pull request

```bash
# Situation : vous avez 5 commits brouillons
git log --oneline
abc1234 Ajout feature
def5678 Fix typo
ghi9012 Oups oublié un fichier
jkl3456 Tests ajoutés
mno7890 Fix tests

# Lancer le rebase interactif
git rebase -i HEAD~5
```

```bash
# Dans l'éditeur
pick abc1234 Ajout feature
fixup ghi9012 Oups oublié un fichier
reword abc1234 Ajout feature
pick jkl3456 Tests ajoutés
fixup mno7890 Fix tests

# Résultat : 2 commits propres au lieu de 5
```

#### Séparer un gros commit en plusieurs petits

```bash
# Marquer le commit à éditer
edit abc1234 Gros commit avec plein de changements

# Git s'arrête sur le commit
git reset HEAD^

# Créer plusieurs commits
git add fichier1.js
git commit -m "Ajout de la fonctionnalité A"

git add fichier2.js
git commit -m "Ajout de la fonctionnalité B"

git add fichier3.js
git commit -m "Ajout des tests"

# Continuer le rebase
git rebase --continue
```

#### Fusionner tous les commits d'une branche

```bash
# Fusionner tous les commits depuis main
git rebase -i main
```

```bash
# Dans l'éditeur
pick abc1234 Premier commit
squash def5678 Deuxième commit
squash ghi9012 Troisième commit
squash jkl3456 Quatrième commit

# Résultat : un seul commit propre
```

> [!tip] Astuce professionnelle Utilisez `git rebase -i --autosquash` avec des commits préfixés par `fixup!` ou `squash!` pour une organisation automatique :
> 
> ```bash
> git commit -m "Ajout feature"
> # Plus tard
> git commit --fixup HEAD  # Créera "fixup! Ajout feature"
> 
> # Le rebase interactif organisera automatiquement
> git rebase -i --autosquash main
> ```

---

## ⚠️ Golden Rule du Rebase

### La règle d'or

> [!warning] RÈGLE FONDAMENTALE **Ne jamais rebaser des commits qui ont été push sur un dépôt public et que d'autres personnes ont pu récupérer.**

Cette règle est absolue car le rebase réécrit l'historique Git. Si d'autres développeurs ont basé leur travail sur ces commits, le rebase créera des divergences catastrophiques.

### Pourquoi cette règle existe-t-elle ?

```bash
# Situation initiale
origin/main:  A---B---C
                       \
teammate:               D

# Vous rebasez et force push
origin/main:  A---B---C'---D'---E'

# Le coéquipier essaie de push
teammate:     A---B---C---D---F
# CONFLIT ! Les historiques ont divergé
```

Conséquences pour votre coéquipier :

- Son historique ne correspond plus au remote
- Il devra merger ou rebaser son travail
- Risque de duplication de commits
- Perte potentielle de travail

### Branches sûres vs dangereuses

|Type de branche|Rebase autorisé ?|Raison|
|---|---|---|
|Branche locale jamais push|✅ OUI|Personne d'autre ne l'utilise|
|Branche feature personnelle|✅ OUI|Vous êtes le seul à travailler dessus|
|Branche push mais pas encore partagée|✅ OUI (avec précaution)|Personne n'a encore pull|
|Branche de travail partagée|❌ NON|D'autres développeurs travaillent dessus|
|Branche main/master|❌ JAMAIS|Branche principale du projet|
|Branche release|❌ JAMAIS|Utilisée pour les déploiements|

### Cas d'usage sûrs

```bash
# ✅ Scénario sûr 1 : Branche locale
git checkout -b ma-feature
# ... plusieurs commits ...
git rebase main  # OK : branche jamais partagée

# ✅ Scénario sûr 2 : Feature branch personnelle
git checkout -b feature/mon-travail
git push origin feature/mon-travail
# Vous êtes seul sur cette branche
git rebase main
git push --force-with-lease origin feature/mon-travail  # OK avec précaution

# ✅ Scénario sûr 3 : Nettoyage avant PR
git checkout feature/nouvelle-fonctionnalite
git rebase -i main  # Nettoyer les commits
# Si jamais push : git push --force-with-lease
# Créer la PR immédiatement après
```

### Cas d'usage dangereux

```bash
# ❌ Scénario dangereux 1 : Branche partagée
git checkout feature/equipe
# Plusieurs personnes travaillent dessus
git rebase main  # DANGER ! Ne pas faire
git push --force  # CATASTROPHE pour l'équipe

# ❌ Scénario dangereux 2 : Main/Master
git checkout main
git rebase autre-branche  # JAMAIS ! Utilisez merge

# ❌ Scénario dangereux 3 : Commits publics anciens
git rebase -i HEAD~20  # Danger si ces commits sont dans des branches partagées
```

### Force push : avec précaution

Si vous devez absolument rebaser une branche déjà push, utilisez `--force-with-lease` :

```bash
# ❌ Force push classique (dangereux)
git push --force

# ✅ Force push avec sécurité
git push --force-with-lease

# Différence : --force-with-lease refuse de push si quelqu'un
# a push des changements entre-temps
```

> [!warning] Avant un force push
> 
> 1. Vérifiez que personne d'autre ne travaille sur la branche
> 2. Communiquez avec votre équipe
> 3. Utilisez `--force-with-lease` au lieu de `--force`
> 4. Faites-le pendant une période de faible activité

### Workflow d'équipe recommandé

```bash
# 1. Créez votre branche feature
git checkout -b feature/ma-fonctionnalite

# 2. Développez localement avec des rebases fréquents
git fetch origin
git rebase origin/main  # OK : rebase local

# 3. Nettoyez avant de push
git rebase -i origin/main  # OK : toujours local

# 4. Première fois : push normal
git push origin feature/ma-fonctionnalite

# 5. Si besoin de nettoyer après le premier push
# D'abord vérifier que personne n'a pull
git rebase -i origin/main
git push --force-with-lease origin feature/ma-fonctionnalite

# 6. Créez la PR immédiatement
# Ne rebasez plus après la création de la PR si d'autres reviewent

# 7. Pour merger dans main : utilisez MERGE, pas rebase
git checkout main
git merge feature/ma-fonctionnalite
```

### Récupération après un rebase problématique

Si vous avez violé la règle d'or par accident :

```bash
# 1. Trouvez le commit d'avant le rebase dans le reflog
git reflog

# 2. Restaurez l'état précédent
git reset --hard HEAD@{X}  # X = numéro du reflog

# 3. Push la version correcte
git push --force-with-lease

# 4. Informez immédiatement votre équipe
```

> [!tip] Communication d'équipe Établissez des règles claires dans votre équipe :
> 
> - Qui a le droit de rebaser quelles branches ?
> - Quand utiliser merge vs rebase ?
> - Comment communiquer avant un force push ?
> - Politique sur les branches main/develop/release

### Alternatives au rebase sur branches publiques

```bash
# Au lieu de rebaser une branche publique partagée
# Option 1 : Merge
git merge origin/main

# Option 2 : Pull avec rebase LOCAL uniquement
git pull --rebase origin main  # Rebase vos commits locaux non-push

# Option 3 : Créer une nouvelle branche
git checkout -b feature/ma-fonctionnalite-v2
git rebase main
# Travailler sur la nouvelle branche propre
```

---

## 🎯 Résumé des bonnes pratiques

> [!tip] Checklist du rebase
> 
> **Avant de rebaser :**
> 
> - ✅ La branche est-elle locale uniquement ?
> - ✅ Suis-je le seul à travailler dessus ?
> - ✅ Ai-je communiqué avec l'équipe si nécessaire ?
> - ✅ Ai-je un backup (tag ou branche) ?
> 
> **Pendant le rebase :**
> 
> - ✅ Résoudre les conflits avec soin
> - ✅ Tester après chaque étape importante
> - ✅ Vérifier que rien n'est cassé
> 
> **Après le rebase :**
> 
> - ✅ Vérifier l'historique avec `git log`
> - ✅ Tester l'application complètement
> - ✅ Utiliser `--force-with-lease` si force push nécessaire

> [!info] Quand utiliser rebase vs merge
> 
> - **Rebase** : Branches locales, nettoyage d'historique, intégration continue des changements
> - **Merge** : Branches publiques, préservation d'historique, intégration finale dans main