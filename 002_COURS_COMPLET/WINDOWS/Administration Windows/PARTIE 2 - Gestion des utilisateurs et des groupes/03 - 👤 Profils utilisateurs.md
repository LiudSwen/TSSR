

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

## 🎯 Introduction aux profils utilisateurs

Un **profil utilisateur** est un ensemble de paramètres et de fichiers qui définissent l'environnement de travail d'un utilisateur Windows. Il contient toutes les personnalisations, configurations et données propres à chaque utilisateur.

> [!info] Pourquoi les profils sont importants
> Les profils permettent à plusieurs utilisateurs de partager le même ordinateur tout en conservant un environnement personnalisé. Chaque utilisateur retrouve ses paramètres, documents et préférences à chaque connexion.

### Contenu typique d'un profil

Un profil utilisateur stocke :
- Les paramètres du Bureau (fond d'écran, thème, disposition des icônes)
- Les favoris et historique des navigateurs
- Les documents personnels (Bureau, Documents, Téléchargements)
- Les paramètres des applications
- Les configurations réseau (lecteurs mappés, imprimantes)
- Les paramètres de personnalisation Windows

---

## 🗂️ Types de profils utilisateurs

Windows Server propose trois types principaux de profils utilisateurs, chacun adapté à des besoins spécifiques.

### 1. Profil local

Le **profil local** est créé automatiquement lors de la première connexion d'un utilisateur sur un ordinateur. Il est stocké uniquement sur cet ordinateur.

> [!example] Caractéristiques du profil local
> - **Emplacement** : `C:\Users\[NomUtilisateur]`
> - **Portée** : Un seul ordinateur
> - **Persistance** : Permanent sur cet ordinateur
> - **Cas d'usage** : Postes fixes avec utilisateurs dédiés

**Avantages** :
- Rapidité d'accès (stockage local)
- Pas de dépendance réseau
- Simple à gérer

**Inconvénients** :
- Non portable entre machines
- Perte des données si l'ordinateur est remplacé
- Multiplicité des profils si l'utilisateur change de poste

> [!warning] Attention
> Les profils locaux ne suivent pas l'utilisateur. Un utilisateur qui se connecte sur plusieurs machines aura un profil différent sur chaque machine.

---

### 2. Profil itinérant (Roaming Profile)

Le **profil itinérant** est stocké sur un serveur réseau et se synchronise avec l'ordinateur lors de la connexion et déconnexion de l'utilisateur.

> [!example] Caractéristiques du profil itinérant
> - **Emplacement** : Serveur de fichiers (partage réseau)
> - **Portée** : Tous les ordinateurs du domaine
> - **Persistance** : Suivre l'utilisateur partout
> - **Cas d'usage** : Utilisateurs mobiles, environnements multi-postes

**Fonctionnement** :
1. L'utilisateur se connecte à n'importe quel ordinateur du domaine
2. Windows télécharge le profil depuis le serveur
3. L'utilisateur travaille avec son environnement habituel
4. À la déconnexion, les modifications sont synchronisées vers le serveur

**Avantages** :
- Environnement cohérent sur tous les postes
- Sauvegarde centralisée
- Mobilité totale de l'utilisateur

**Inconvénients** :
- Temps de connexion/déconnexion plus long
- Dépendance au réseau
- Consommation de bande passante
- Nécessite de l'espace de stockage serveur

> [!tip] Optimisation des profils itinérants
> Utilisez la redirection de dossiers pour les données volumineuses (Documents, Bureau) afin de réduire le temps de synchronisation.

**Configuration d'un profil itinérant** :

```powershell
# Via les propriétés du compte utilisateur dans AD
# Onglet "Profil" → Chemin du profil : \\serveur\profils\%username%
```

Dans Active Directory Users and Computers :
1. Clic droit sur l'utilisateur → **Propriétés**
2. Onglet **Profil**
3. Chemin du profil : `\\serveur\profils\%username%`

---

### 3. Profil obligatoire (Mandatory Profile)

Le **profil obligatoire** est un profil itinérant en lecture seule. Les modifications apportées par l'utilisateur ne sont pas sauvegardées à la déconnexion.

> [!example] Caractéristiques du profil obligatoire
> - **Emplacement** : Serveur de fichiers
> - **Portée** : Tous les ordinateurs du domaine
> - **Persistance** : Réinitialisation à chaque déconnexion
> - **Cas d'usage** : Environnements sécurisés, postes publics, kiosques

**Avantages** :
- Environnement standardisé et contrôlé
- Pas de pollution du profil par l'utilisateur
- Sécurité renforcée
- Parfait pour les comptes partagés

**Inconvénients** :
- Aucune personnalisation possible
- Perte de tous les changements à la déconnexion
- Peut être frustrant pour les utilisateurs

**Création d'un profil obligatoire** :

1. Créer un profil itinérant fonctionnel
2. Renommer le fichier `NTUSER.DAT` en `NTUSER.MAN`
3. Le profil devient obligatoire (lecture seule)

```powershell
# Sur le partage réseau du profil
Rename-Item "\\serveur\profils\utilisateur\NTUSER.DAT" "NTUSER.MAN"
```

> [!warning] Extension .MAN
> L'extension `.MAN` (Mandatory) transforme automatiquement un profil itinérant en profil obligatoire. Cette modification est irréversible sans renommer le fichier.

---

## 📁 Structure d'un profil utilisateur

Un profil utilisateur Windows est organisé en plusieurs dossiers et fichiers clés. Comprendre cette structure est essentiel pour le dépannage.

### Emplacement par défaut

```
C:\Users\[NomUtilisateur]\
```

### Principaux dossiers et fichiers

| Élément | Type | Description |
|---------|------|-------------|
| **Desktop** | Dossier | Contenu du Bureau de l'utilisateur |
| **Documents** | Dossier | Documents personnels |
| **Downloads** | Dossier | Fichiers téléchargés |
| **Pictures** | Dossier | Photos et images |
| **Music** | Dossier | Fichiers audio |
| **Videos** | Dossier | Fichiers vidéo |
| **AppData** | Dossier | Données des applications |
| **NTUSER.DAT** | Fichier | Ruche de registre de l'utilisateur |
| **NTUSER.DAT.LOG** | Fichier | Journal des transactions registre |

### Le dossier AppData

Le dossier `AppData` est masqué par défaut et contient trois sous-dossiers importants :

```
AppData\
├── Local\      → Données locales (non itinérantes)
├── LocalLow\   → Données locales avec faibles privilèges
└── Roaming\    → Données itinérantes (suivent l'utilisateur)
```

> [!info] AppData\Roaming vs AppData\Local
> - **Roaming** : Paramètres d'applications qui doivent suivre l'utilisateur (favoris, signatures)
> - **Local** : Données volumineuses ou spécifiques à la machine (cache, fichiers temporaires)

### Le fichier NTUSER.DAT

`NTUSER.DAT` est la **ruche de registre** de l'utilisateur. Elle contient toutes les clés du registre `HKEY_CURRENT_USER` :

- Paramètres du Bureau
- Associations de fichiers personnalisées
- Paramètres des applications
- Variables d'environnement utilisateur
- Configurations réseau

> [!warning] Fichier système
> `NTUSER.DAT` est un fichier système caché et verrouillé lorsque l'utilisateur est connecté. Il ne peut être modifié que lorsque l'utilisateur est déconnecté.

### Dossiers spéciaux

Windows utilise des dossiers cachés supplémentaires :

```
├── Cookies\              → Cookies du navigateur (hérité)
├── Favorites\            → Favoris Internet Explorer
├── Links\                → Liens rapides de l'explorateur
├── Recent\               → Fichiers récemment ouverts
├── Searches\             → Recherches enregistrées
└── Start Menu\           → Menu Démarrer personnalisé
```

---

## ⚙️ Gestion des profils utilisateurs

### Afficher les profils existants

**Via l'interface graphique** :

1. Clic droit sur **Ce PC** → **Propriétés**
2. **Paramètres système avancés**
3. Onglet **Avancé** → **Paramètres** (section Profils des utilisateurs)

Vous verrez la liste de tous les profils avec :
- Nom du profil
- Taille
- Type (Local/Itinérant)
- Date de dernière modification

**Via PowerShell** :

```powershell
# Lister tous les profils
Get-WmiObject -Class Win32_UserProfile | Select-Object LocalPath, Loaded, LastUseTime

# Profils chargés actuellement
Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.Loaded -eq $true}

# Taille des profils
Get-ChildItem C:\Users | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | 
             Measure-Object -Property Length -Sum).Sum / 1GB
    [PSCustomObject]@{
        User = $_.Name
        SizeGB = [math]::Round($size, 2)
    }
}
```

---

### Supprimer un profil utilisateur

> [!warning] Attention - Perte de données
> La suppression d'un profil est définitive. Assurez-vous de sauvegarder les données importantes avant de procéder.

**Méthode 1 : Interface graphique**

1. Paramètres système → **Profils des utilisateurs**
2. Sélectionner le profil à supprimer
3. Cliquer sur **Supprimer**
4. Confirmer l'action

**Méthode 2 : PowerShell**

```powershell
# Supprimer le profil d'un utilisateur spécifique
$profil = Get-WmiObject -Class Win32_UserProfile | 
          Where-Object {$_.LocalPath -like "*\nomutilisateur"}
$profil.Delete()

# Alternative avec CIM (plus moderne)
Get-CimInstance -ClassName Win32_UserProfile | 
    Where-Object {$_.LocalPath -like "*\nomutilisateur"} | 
    Remove-CimInstance
```

> [!tip] Quand supprimer un profil ?
> - Le profil est corrompu et provoque des erreurs
> - L'utilisateur n'utilise plus cet ordinateur
> - Libération d'espace disque
> - Réinitialisation complète de l'environnement utilisateur

---

### Copier un profil

La copie de profil peut être utile pour :
- Créer un profil par défaut personnalisé
- Migrer un profil vers un autre compte
- Créer un modèle de profil

**Procédure** :

1. L'utilisateur source doit être **déconnecté**
2. Se connecter avec un compte administrateur
3. Paramètres système → **Profils des utilisateurs**
4. Sélectionner le profil source
5. Cliquer sur **Copier vers**
6. Spécifier l'emplacement de destination
7. Définir les autorisations pour le nouveau profil

> [!warning] Limitations de la copie
> La copie de profil via l'interface graphique a des limitations. Pour des migrations complexes, utilisez des outils comme USMT (User State Migration Tool).

---

### Profil par défaut (Default Profile)

Le **profil par défaut** sert de modèle pour tous les nouveaux profils utilisateurs créés sur la machine.

**Emplacement** : `C:\Users\Default`

**Personnalisation du profil par défaut** :

1. Créer un compte utilisateur temporaire
2. Se connecter et personnaliser l'environnement
3. Copier ce profil vers `C:\Users\Default`
4. Tous les nouveaux utilisateurs hériteront de ces paramètres

```powershell
# Exemple : Copier un fond d'écran dans le profil par défaut
Copy-Item "C:\Wallpapers\entreprise.jpg" "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Themes\"
```

> [!tip] Cas d'usage
> Utile pour déployer une configuration standard sur tous les nouveaux comptes : fond d'écran d'entreprise, raccourcis Bureau, favoris navigateur, etc.

---

## 🔧 Dépannage des profils

### Profil temporaire

Le **profil temporaire** est un symptôme courant de corruption de profil. Windows charge un profil temporaire qui sera supprimé à la déconnexion.

**Symptômes** :
- Message "Vous avez été connecté avec un profil temporaire"
- Bureau vide, personnalisations perdues
- Modifications non sauvegardées

**Causes principales** :
- Corruption du fichier `NTUSER.DAT`
- Problèmes de permissions
- Antivirus bloquant l'accès au profil
- Profil itinérant inaccessible (problème réseau)

**Solution 1 : Via le registre**

```powershell
# 1. Identifier le SID de l'utilisateur
$user = "nomutilisateur"
$sid = (New-Object System.Security.Principal.NTAccount($user)).Translate([System.Security.Principal.SecurityIdentifier]).Value

# 2. Ouvrir regedit et naviguer vers :
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList

# 3. Chercher deux clés avec le même SID :
#    - Une normale : S-1-5-21-xxxxx
#    - Une avec .bak : S-1-5-21-xxxxx.bak

# 4. Actions :
#    - Supprimer la clé SANS .bak
#    - Renommer la clé .bak en supprimant le .bak
#    - Redémarrer
```

**Solution 2 : Recréation du profil**

Si la solution registre ne fonctionne pas :

1. Sauvegarder les données utilisateur depuis `C:\Users\[nom].TEMP`
2. Supprimer complètement le profil corrompu
3. L'utilisateur se reconnecte → nouveau profil créé
4. Restaurer les données sauvegardées

---

### Profil itinérant non chargé

**Symptômes** :
- Le profil local est chargé au lieu du profil itinérant
- Message d'erreur au démarrage
- Temps de connexion très long puis échec

**Causes et solutions** :

| Cause | Vérification | Solution |
|-------|--------------|----------|
| Partage réseau inaccessible | `Test-Path \\serveur\profils` | Vérifier connectivité réseau et permissions |
| Permissions incorrectes | Permissions NTFS du dossier profil | Accorder contrôle total à l'utilisateur |
| Profil corrompu sur serveur | Taille, intégrité fichiers | Supprimer et laisser recréer |
| Quota dépassé | Espace disque serveur | Augmenter quota ou nettoyer |
| GPO bloquante | `gpresult /r` | Vérifier stratégies de groupe |

**Diagnostic PowerShell** :

```powershell
# Vérifier le chemin du profil itinérant dans AD
Get-ADUser nomutilisateur -Properties ProfilePath | Select-Object Name, ProfilePath

# Tester l'accès au partage
Test-Path "\\serveur\profils\nomutilisateur"

# Vérifier les permissions
Get-Acl "\\serveur\profils\nomutilisateur" | Format-List

# Vérifier la taille du profil
$size = (Get-ChildItem "\\serveur\profils\nomutilisateur" -Recurse | 
         Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Taille du profil : $([math]::Round($size, 2)) MB"
```

---

### Profil lent à charger

**Causes fréquentes** :
- Profil itinérant trop volumineux
- Bande passante réseau insuffisante
- Trop de fichiers dans le profil
- Problèmes de performance serveur

**Solutions** :

1. **Redirection de dossiers** : Déplacer Documents, Bureau, Images vers un partage réseau séparé

2. **Exclusions de dossiers itinérants** :

```powershell
# Via GPO : Configuration utilisateur → Stratégies → 
# Modèles d'administration → Système → Profils utilisateur
# Activer "Exclure les répertoires dans le profil itinérant"
# Ajouter : AppData\Local;AppData\LocalLow
```

3. **Nettoyage du profil** :

```powershell
# Supprimer les fichiers temporaires
Remove-Item "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Vider le cache Internet Explorer
Remove-Item "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Nettoyer les téléchargements anciens
Get-ChildItem "$env:USERPROFILE\Downloads" | 
    Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-30)} | 
    Remove-Item -Force
```

4. **Augmenter le timeout de chargement** :

Via GPO : Définir le délai d'attente pour les profils utilisateur itinérants lents (par défaut 30 secondes)

---

### Fichier NTUSER.DAT verrouillé

**Problème** : Impossible de supprimer ou modifier le profil car `NTUSER.DAT` est utilisé.

**Solutions** :

```powershell
# 1. Vérifier si l'utilisateur est connecté
query user

# 2. Déconnecter l'utilisateur si nécessaire
logoff [ID_SESSION]

# 3. Si le fichier reste verrouillé, identifier le processus
# Télécharger Handle.exe de Sysinternals
handle.exe NTUSER.DAT

# 4. Tuer le processus qui verrouille le fichier
Stop-Process -Id [PID] -Force

# 5. Alternative : redémarrer en mode sans échec
```

---

### Permissions de profil incorrectes

**Symptômes** :
- Accès refusé à certains dossiers du profil
- Impossibilité d'enregistrer des paramètres
- Applications ne démarrant pas correctement

**Réparation des permissions** :

```powershell
# Prendre possession du profil
takeown /F "C:\Users\nomutilisateur" /R /D Y

# Réinitialiser les permissions
icacls "C:\Users\nomutilisateur" /reset /T /C

# Accorder le contrôle total à l'utilisateur
icacls "C:\Users\nomutilisateur" /grant nomutilisateur:(OI)(CI)F /T

# Accorder permissions système
icacls "C:\Users\nomutilisateur" /grant SYSTEM:(OI)(CI)F /T
icacls "C:\Users\nomutilisateur" /grant Administrateurs:(OI)(CI)F /T
```

---

## ✅ Bonnes pratiques

### Gestion des profils itinérants

> [!tip] Optimisation des profils itinérants
> - **Limitez la taille** : Configurez des quotas (recommandation : < 100 MB)
> - **Utilisez la redirection de dossiers** pour Documents, Bureau, Images
> - **Excluez les dossiers temporaires** du profil itinérant
> - **Activez la compression** sur le partage de profils
> - **Surveillez régulièrement** la taille des profils

### Sécurité

> [!warning] Sécurisation des profils
> - Les partages de profils doivent être accessibles uniquement par les utilisateurs concernés
> - Utilisez le chiffrement (BitLocker) sur les serveurs de profils
> - Auditez les accès aux profils sensibles
> - Sauvegardez régulièrement les profils itinérants

### Performance

| Recommandation | Impact | Mise en œuvre |
|----------------|--------|---------------|
| Profils < 50 MB | ⭐⭐⭐ | Quotas + nettoyage automatique |
| Redirection de dossiers | ⭐⭐⭐ | GPO de redirection |
| Exclusion AppData\Local | ⭐⭐ | GPO d'exclusion |
| Réseau Gigabit | ⭐⭐ | Infrastructure réseau |
| SSD sur serveur | ⭐⭐ | Matériel serveur |

### Sauvegarde

> [!info] Stratégie de sauvegarde
> - **Profils itinérants** : Sauvegarder le partage réseau quotidiennement
> - **Profils locaux critiques** : Script de sauvegarde automatique
> - **Profil par défaut** : Versionner les modifications
> - **Tests de restauration** : Valider la procédure régulièrement

### Documentation

Maintenez une documentation claire :
- Emplacement des profils itinérants
- Stratégie de nommage des comptes
- Procédures de dépannage courantes
- Contacts en cas de problème
- Historique des modifications du profil par défaut

---

## 🎓 Points clés à retenir

- Les **profils locaux** sont rapides mais non portables
- Les **profils itinérants** permettent la mobilité mais nécessitent une bonne gestion
- Les **profils obligatoires** garantissent un environnement standardisé
- La **structure du profil** est centrée autour de `NTUSER.DAT` et du dossier `AppData`
- Le **dépannage** passe souvent par le registre et la vérification des permissions
- L'**optimisation** des profils itinérants est essentielle pour la performance
- La **redirection de dossiers** est complémentaire aux profils itinérants