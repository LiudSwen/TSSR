## ⚡ L'essentiel en 5 minutes - Git & GitHub

### 📌 C'est quoi en 2 lignes ?

**Git** = logiciel de gestion de versions décentralisé qui enregistre l'historique complet des modifications de fichiers. **GitHub** = plateforme web hébergeant des dépôts Git et ajoutant des fonctionnalités collaboratives (≠ Git lui-même).

---

### 💡 Concepts clés à retenir :

- **Versioning** : Sauvegarder l'historique des modifications pour revenir en arrière, travailler à plusieurs, développer des fonctionnalités isolément
- **Décentralisé** : Chaque développeur a une copie complète du projet localement (pas besoin de serveur permanent)
- **Repository (dépôt)** : Dossier contenant le projet + son historique Git complet
- **Commit** : Instantané du projet à un moment donné avec ID unique et commentaire
- **Branche** : Ligne de développement parallèle pour isoler des modifications

---

### 💻 Commandes essentielles :

```bash
# 🔧 Configuration initiale
git config --global user.name "Nom"
git config --global user.email "email@exemple.com"

# 📂 Démarrage projet
git init                         # Initialiser un dépôt Git local
git clone <url>                  # Copier un dépôt distant

# 📊 Vérification état
git status                       # Voir l'état des fichiers (untracked/modified/staged)
git log                          # Historique des commits
git diff                         # Voir les modifications non indexées

# ➕ Enregistrer modifications
git add <fichier>                # Ajouter fichier à l'index (stage)
git add .                        # Ajouter tous les fichiers modifiés
git commit -m "message"          # Valider les modifications indexées

# 🌿 Gestion branches
git branch                       # Lister les branches
git branch <nom>                 # Créer une branche
git checkout <branche>           # Basculer sur une branche
git checkout -b <nom>            # Créer et basculer sur nouvelle branche
git merge <branche>              # Fusionner une branche dans la branche actuelle

# 🔄 Synchronisation distante
git remote add origin <url>      # Lier le dépôt local à un dépôt distant
git push origin <branche>        # Envoyer les commits vers le distant
git pull origin <branche>        # Récupérer et fusionner les modifications distantes
git fetch                        # Récupérer sans fusionner

# 🆘 Annulations
git reset <fichier>              # Retirer fichier de l'index (unstage)
git revert <commit-id>           # Annuler un commit en créant un nouveau commit
git stash                        # Mettre de côté temporairement les modifications
git stash pop                    # Récupérer les modifications mises de côté
```

---

### 📐 Les 3 arbres Git :

**Flux de travail Git :**

```
1. Working Directory (répertoire de travail)
   ↓ git add
2. Index / Stage (zone de transit)
   ↓ git commit
3. HEAD (dernier commit de la branche actuelle)
```

**États des fichiers :**

```
Untracked → git add → Staged → git commit → Unmodified
                                                ↓ modification
                                            Modified → git add → Staged
```

---

### ⚠️ Pièges à éviter :

- ❌ **Confondre Git et GitHub** : Git = outil local, GitHub = service web distant
- ❌ **Commiter sur main/master directement** : Cette branche DOIT TOUJOURS être fonctionnelle, développer sur des branches dédiées
- ❌ **Faire des commits trop gros** : Commiter régulièrement avec des messages clairs (pas "fix" ou "update")
- ❌ **Oublier de pull avant de push** : Récupérer les modifications distantes avant d'envoyer les siennes
- ❌ **Ne pas vérifier git status** : Toujours vérifier l'état avant add/commit pour éviter d'inclure des fichiers non désirés

---

### ✅ Bonnes pratiques :

- ✅ **Workflow avec branches** : main (production) → dev → feature/bugfix (temporaires) → fusion après validation
- ✅ **Messages de commit explicites** : "Ajout authentification utilisateur" plutôt que "update"
- ✅ **Commiter souvent** : Petites modifications logiques plutôt qu'un gros commit fourre-tout
- ✅ **Utiliser .gitignore** : Exclure fichiers temporaires, logs, configurations locales du versioning
- ✅ **Tester avant de merger** : Vérifier que la branche est fonctionnelle avant fusion dans main

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Repository**|Dossier projet avec historique Git complet (.git/)|
|**Commit**|Enregistrement horodaté des modifications avec ID unique (hash SHA)|
|**Stage/Index**|Zone intermédiaire où préparer les fichiers avant commit|
|**HEAD**|Pointeur vers le dernier commit de la branche actuelle|
|**Branch**|Ligne de développement parallèle (pointeur mobile sur commits)|
|**Merge**|Fusion de deux branches (intégrer modifications d'une branche dans une autre)|
|**Fork**|Copie d'un dépôt GitHub sur son propre compte pour modifications indépendantes|
|**Pull Request**|Demande d'intégration de modifications d'une branche/fork vers la branche principale|
|**Clone**|Copie locale complète d'un dépôt distant|
|**Remote**|Dépôt distant (généralement sur GitHub/GitLab)|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Git est décentralisé = historique complet en local, pas besoin de serveur pour travailler
2. 💻 **Pratique** : Workflow de base = `git add .` → `git commit -m "message"` → `git push origin <branche>`
3. ⚠️ **Piège** : Toujours `git pull` avant `git push` et JAMAIS commiter directement sur main sans tests