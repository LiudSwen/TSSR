## ⚡ L'essentiel en 5 minutes - Gestion des Utilisateurs (Linux & Windows)

### 📌 C'est quoi en 2 lignes ?

La gestion des utilisateurs permet d'identifier et d'authentifier des personnes/services sur un système, de contrôler leurs droits d'accès aux fichiers/ressources via des permissions, et de les organiser en groupes pour simplifier l'administration système.

---

### 💡 Concepts clés à retenir :

- **Utilisateur** : Entité identifiée par un login, associée à une personne, un service (www-data) ou un rôle (root)
- **Groupe** : Conteneur d'utilisateurs (Linux) ou d'utilisateurs ET groupes (Windows) pour gérer les permissions
- **UID/GID** : Identifiants numériques uniques pour utilisateurs (UID) et groupes (GID) sur Linux
- **SID** : Security Identifier unique sur Windows (format S-1-5-21-xxx-xxx-xxx-xxx)
- **IAM** : Identity & Access Management - gestion centralisée des identités et accès aux ressources
- **Identification** : Déclaration d'identité (login) - "Qui suis-je ?"
- **Authentification** : Preuve d'identité (mot de passe) - "Prouver qui je suis"
- **Répertoire personnel** : Espace dédié à chaque utilisateur pour stocker ses données personnelles

---

### 💻 Commandes essentielles :

```bash
# 🐧 LINUX - Gestion utilisateurs
id wilder                          # Affiche UID, GID et groupes
whoami                             # Affiche le nom d'utilisateur actuel
who                                # Liste utilisateurs connectés
adduser wilder                     # Créer un utilisateur
deluser wilder                     # Supprimer un utilisateur
usermod -aG sudo wilder            # Ajouter au groupe sudo
passwd wilder                      # Changer le mot de passe
chfn wilder                        # Modifier la description
chsh -s /bin/zsh wilder            # Changer le shell par défaut
su - wilder                        # Changer d'utilisateur
sudo commande                      # Exécuter avec droits root

# 🐧 LINUX - Gestion groupes
groupadd devops                    # Créer un groupe
groupdel devops                    # Supprimer un groupe
groupmod -n new old                # Renommer un groupe
newgrp docker                      # Prendre un nouveau groupe principal

# 🐧 LINUX - Droits d'accès (permissions classiques)
ls -l fichier                      # Afficher les droits (-rw-r--r--)
chown user:group fichier           # Changer propriétaire
chgrp group fichier                # Changer groupe
chmod 755 fichier                  # Modifier droits (rwxr-xr-x)
chmod u+x,g-w fichier              # Mode symbolique

# 🐧 LINUX - Droits ACL (avancés)
getfacl fichier                    # Lire les ACL
setfacl -m u:wilder1:rwx fichier   # Ajouter ACL utilisateur
setfacl -m g:dev:rx fichier        # Ajouter ACL groupe
setfacl -x u:wilder1 fichier       # Supprimer ACL utilisateur
```

```powershell
# 🪟 WINDOWS - Gestion utilisateurs
Get-LocalUser                      # Lister utilisateurs locaux
Get-WmiObject win32_useraccount    # Liste détaillée + SID
New-LocalUser -Name "wilder"       # Créer un utilisateur
Remove-LocalUser -Name "wilder"    # Supprimer un utilisateur
Enable-LocalUser -Name "wilder"    # Activer un compte
Disable-LocalUser -Name "wilder"   # Désactiver un compte
Get-ChildItem C:\Users             # Lister répertoires utilisateurs

# 🪟 WINDOWS - Gestion groupes
Get-LocalGroup                     # Lister groupes locaux
Get-WmiObject win32_group          # Liste détaillée + SID
New-LocalGroup -Name "DevOps"      # Créer un groupe
Remove-LocalGroup -Name "DevOps"   # Supprimer un groupe
Add-LocalGroupMember -Group "Administrateurs" -Member "wilder"
Get-LocalGroupMember -Group "Administrateurs"

# 🪟 WINDOWS - Droits d'accès (ACL)
Get-Acl C:\temp\file.txt | Format-List               # Afficher ACL
$acl = Get-Acl C:\temp\file.txt                      # Récupérer ACL
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("wilder","FullControl","Allow")
$acl.SetAccessRule($rule)                            # Ajouter règle
$acl | Set-Acl C:\temp\file.txt                      # Appliquer ACL
```

```bash
# 🌐 Fichiers de configuration Linux
/etc/passwd                        # Liste utilisateurs (login:x:UID:GID:description:home:shell)
/etc/shadow                        # Mots de passe hashés (nécessite sudo)
/etc/group                         # Liste groupes (group:x:GID:membres)
/etc/gshadow                       # Mots de passe groupes
/home/utilisateur                  # Répertoire personnel (~ raccourci)
/root                              # Répertoire de root (exception)

# 🌐 Configuration Windows
C:\Users\utilisateur               # Répertoire personnel
%SystemRoot%\system32\Config\SAM   # Base SAM (mots de passe)
rundll32.exe keymgr.dll,KRShowKeyMgr  # Gestionnaire d'identification
```

---

### 📐 Lecture des permissions Linux :

**Format : `-rwxrwxrwx`**

- **1er caractère** : Type (`-` fichier, `d` répertoire, `l` lien)
- **2-4** : Droits propriétaire (User)
- **5-7** : Droits groupe (Group)
- **8-10** : Droits autres (Other)

**Valeurs numériques (chmod) :**

- `r` (read) = 4
- `w` (write) = 2
- `x` (execute) = 1
- **Exemple concret :**

```
-rw-r--r--  →  644  (User:rw, Group:r, Other:r)
drwxr-xr-x  →  755  (User:rwx, Group:rx, Other:rx)
-rwx------  →  700  (User:rwx, Group:-, Other:-)
```

---

### 📐 Droits Windows (5 types) :

|Droit|Description|Symbole|
|---|---|---|
|**Contrôle total**|Tous droits + gestion permissions|FullControl|
|**Modification**|Lecture, écriture, suppression|Modify|
|**Lecture & Exécution**|Lire + exécuter programmes|ReadAndExecute|
|**Écriture**|Créer/modifier fichiers|Write (W)|
|**Lecture**|Consulter seulement|Read (R)|

**Actions possibles :** Autoriser (Allow) ou Refuser (Deny)

---

### ⚠️ Pièges à éviter :

- ❌ **Confondre login et UID** : Le système utilise l'UID, pas le nom (renommer ne change pas l'UID)
- ❌ **Oublier le "x" dans /etc/passwd** : `x` indique que le mot de passe est dans /etc/shadow
- ❌ **chmod 777 partout** : Énorme faille de sécurité, jamais en production !
- ❌ **Supprimer un utilisateur sans backup** : Sauvegarder /home/user avant deluser
- ❌ **ACL Windows : Deny > Allow** : Un refus l'emporte toujours sur une autorisation
- ❌ **Modifier /etc/shadow directement** : Toujours utiliser passwd, vipw ou usermod
- ❌ **Root UID ≠ 0** : Root DOIT avoir UID=0, sinon problèmes système majeurs
- ❌ **Oublier l'héritage Windows** : Les sous-dossiers héritent des droits par défaut

---

### ✅ Bonnes pratiques :

- ✅ **Principe du moindre privilège** : Donner uniquement les droits nécessaires, jamais plus
- ✅ **Utiliser les groupes** : Plus facile de gérer 1 groupe que 50 utilisateurs individuellement
- ✅ **Nommer logiquement** : Conventions claires (dev, admin, backup, www-data)
- ✅ **ACL pour cas spéciaux** : Les permissions classiques d'abord, ACL quand vraiment nécessaire
- ✅ **Vérifier régulièrement** : `pwck` et `grpck` sur Linux pour détecter les incohérences
- ✅ **Documenter les modifications** : Noter qui a quels droits et pourquoi
- ✅ **Désactiver vs Supprimer** : Désactiver d'abord (Enable/Disable), supprimer après validation
- ✅ **Sauvegarder SAM (Windows)** : Avant modifications importantes des comptes

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**UID**|User IDentifier - numéro unique d'utilisateur sur Linux (root=0, users≥1000)|
|**GID**|Group IDentifier - numéro unique de groupe sur Linux|
|**SID**|Security IDentifier - identifiant unique Windows (S-1-5-21-xxx-xxx-xxx-xxx)|
|**ACL**|Access Control List - permissions avancées au-delà de User/Group/Other|
|**rwx**|Read/Write/eXecute - les 3 permissions de base Linux|
|**SAM**|Security Account Manager - base de données des comptes Windows|
|**Gecos**|Champ description/commentaire dans /etc/passwd (nom complet, bureau, tel)|
|**nologin**|Shell empêchant la connexion interactive (utilisateurs système)|
|**Périmètre fonctionnel**|Ensemble des fonctionnalités/applications accessibles à l'utilisateur|
|**IAM**|Identity & Access Management - gestion centralisée identités/accès|
|**Héritage**|Transmission automatique des droits du dossier parent aux sous-dossiers|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Linux utilise UID/GID (numériques), Windows utilise SID (alphanumériques) - Ne jamais confondre nom d'utilisateur et identifiant unique !
    
2. 💻 **Pratique** : `chmod 755` (Linux) = droits standards répertoire / `Get-Acl | Set-Acl` (Windows) = gestion permissions complètes
    
3. ⚠️ **Piège** : Sur Windows, **Deny l'emporte TOUJOURS sur Allow** - Un seul refus annule toutes les autorisations !
    

---

**💾 Fichiers vitaux à connaître :**

- **Linux** : `/etc/passwd` (users), `/etc/shadow` (passwords), `/etc/group` (groupes)
- **Windows** : `C:\Users` (profils), `SAM` (comptes), `Get-LocalUser` (PowerShell)

**🔐 Droits minimaux recommandés :**

- Fichiers sensibles : `600` (rw-------) ou `640` (rw-r-----)
- Exécutables : `755` (rwxr-xr-x)
- Répertoires : `750` (rwxr-x---) ou `755` (rwxr-xr-x)