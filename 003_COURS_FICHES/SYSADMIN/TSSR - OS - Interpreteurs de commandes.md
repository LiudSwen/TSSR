## ⚡ L'essentiel en 5 minutes - Interpréteurs de commandes (Shells)

### 📌 C'est quoi en 2 lignes ?

Les shells (bash, PowerShell) sont des interfaces textuelles (CLI) permettant d'interagir avec l'OS via des commandes. Ils offrent plus de puissance et d'automatisation que les interfaces graphiques (GUI) pour l'administration système.

---

### 💡 Concepts clés à retenir :

- **Shell** : Programme qui interprète les commandes utilisateur et communique avec l'OS
- **CLI (Command Line Interface)** : Interface textuelle (prompt → commande → résultat → prompt)
- **Prompt** : Invite de commande affichant le contexte (user@host:répertoire$ pour bash, PS C:\chemin> pour PowerShell)
- **Builtin** : Commande interne au shell (ex: cd, echo, type) vs commande externe (ex: mkdir)
- **Flux standards** : stdin (0 entrée), stdout (1 sortie), stderr (2 erreurs) - gérables séparément

---

### 💻 Commandes essentielles :

```bash
# 🐧 GNU bash (Linux/Unix)
man commande               # Afficher le manuel (RTFM)
type commande              # Type de la commande (builtin/externe)
cd chemin                  # Changer de répertoire
echo "texte"               # Afficher du texte
alias nom='cible'          # Créer un raccourci
unalias nom                # Supprimer un alias
history                    # Historique des commandes
```

```powershell
# 🪟 PowerShell (Windows 7+)
Get-Help Cmdlet            # Aide sur une commande
Get-Command                # Lister les commandes disponibles
Set-ExecutionPolicy        # Gérer les permissions de scripts
Get-Alias                  # Lister les alias
```

```bash
# 🔗 Redirections et pipes (bash/PowerShell)
commande > fichier         # Redirige stdout (écrase)
commande >> fichier        # Redirige stdout (ajoute)
commande < fichier         # Redirige stdin
commande 2> erreurs.txt    # Redirige stderr
commande 2>&1              # Fusionne stderr dans stdout
commande1 | commande2      # Pipe: sortie de cmd1 → entrée de cmd2
commande1 |& commande2     # Pipe avec stderr inclus

# 🔄 Exécution séquentielle
cmd1 ; cmd2                # Exécute cmd2 après cmd1 (toujours)
cmd1 && cmd2               # Exécute cmd2 SI cmd1 réussit
cmd1 || cmd2               # Exécute cmd2 SI cmd1 échoue
cmd &                      # Exécute en arrière-plan (asynchrone)

# 🃏 Wildcards (jokers)
*                          # N'importe quels caractères (y compris aucun)
?                          # Un seul caractère quelconque
[abc]                      # Un caractère parmi a, b ou c
[a-z]                      # Un caractère dans la plage a-z
a[bc]*                     # Combinaisons possibles
```

---

### ⚠️ Pièges à éviter :

- ❌ **Espace = séparateur** : `echo salut tout` → 2 arguments ("salut" et "tout"), utiliser `'salut tout'` pour 1 argument
- ❌ **Confondre > et >>** : `>` écrase le fichier, `>>` ajoute à la fin
- ❌ **Oublier stderr** : `commande > log.txt` affiche quand même les erreurs à l'écran (utiliser `2>&1`)
- ❌ **Sensibilité à la casse** : bash distingue `Fichier.txt` ≠ `fichier.txt`
- ❌ **Exécuter scripts sans vérifier** : risque sécurité (PowerShell bloque par défaut via ExecutionPolicy)

---

### ✅ Bonnes pratiques :

- ✅ **RTFM d'abord** : `man commande` (bash) ou `Get-Help Cmdlet` (PowerShell) avant de demander
- ✅ **Auto-complétion** : Touche Tab pour gagner du temps et éviter les erreurs
- ✅ **Historique** : Flèches ↑/↓ pour rappeler les commandes précédentes
- ✅ **Tester avant** : Vérifier les commandes destructives (ex: `rm -rf`) avec `ls` avant
- ✅ **Distinguer builtin/externe** : `type cmd` (bash) pour comprendre ce qu'on exécute

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Shell**|Interpréteur de commandes (bash, sh, PowerShell, cmd.exe)|
|**Prompt**|Invite de commande affichant le contexte actuel|
|**Builtin**|Commande interne au shell (ex: cd, echo)|
|**Pipe (\|)**|Connecte stdout d'une commande à stdin de la suivante|
|**Redirection (>, <)**|Change la destination/source des flux standard|
|**stdin/stdout/stderr**|Entrée standard (0), sortie standard (1), erreur standard (2)|
|**Wildcard**|Caractère joker pour substitution (* ? [])|
|**Alias**|Raccourci personnalisé pour une commande longue|
|**Cmdlet**|Applet de commande PowerShell (format Verbe-Nom)|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Bash (Linux/Unix) et PowerShell (Windows) sont les 2 shells TSSR essentiels
2. 💻 **Pratique** : `man commande` (bash) - la 1ère commande à maîtriser pour être autonome
3. ⚠️ **Piège** : `>` écrase le fichier, `>>` ajoute - confusion = perte de données !

---

**🔑 Mémo rapide redirections :**

```bash
cmd > file      # stdout → file (écrase)
cmd >> file     # stdout → file (ajoute)
cmd 2> file     # stderr → file
cmd 2>&1        # stderr → stdout
cmd1 | cmd2     # stdout cmd1 → stdin cmd2
```

**🏆 Exemples terrain :**

```bash
# Rechercher fichiers .txt ET gérer les erreurs
find /home -name "*.txt" > results.txt 2> errors.txt

# Filtrer processus Chrome
ps aux | grep chrome

# Créer dossier et y aller en 1 ligne
mkdir ~/backup && cd ~/backup && touch file.txt
```