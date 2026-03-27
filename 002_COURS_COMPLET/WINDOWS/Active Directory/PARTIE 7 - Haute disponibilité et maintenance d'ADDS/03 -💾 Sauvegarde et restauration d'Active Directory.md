

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

## Introduction

La sauvegarde et la restauration d'Active Directory sont des éléments cruciaux de la haute disponibilité. Contrairement à une simple récupération de fichiers, la restauration d'AD implique des mécanismes spécifiques liés à la réplication et à la cohérence des données distribuées sur plusieurs contrôleurs de domaine.

> [!info] Pourquoi c'est critique Active Directory contient toutes les informations d'authentification, d'autorisation et de configuration de votre infrastructure. Une perte de données AD peut paralyser complètement une organisation. Même avec la réplication, certains scénarios nécessitent une restauration depuis une sauvegarde.

---

## Sauvegarde de l'état du système

### Qu'est-ce que l'état du système ?

L'**état du système** (System State) sur un contrôleur de domaine inclut tous les composants critiques nécessaires au fonctionnement d'Active Directory :

|Composant|Description|
|---|---|
|**Base de données AD (NTDS.DIT)**|Contient tous les objets de l'annuaire|
|**Fichiers journaux**|Logs des transactions AD|
|**Registre système**|Configuration Windows et AD|
|**SYSVOL**|Scripts de stratégies de groupe et fichiers partagés|
|**Fichiers système**|Fichiers de démarrage Windows|
|**Base de certificats**|Si le serveur héberge une AC d'entreprise|

> [!warning] Point important Sauvegarder uniquement le fichier NTDS.DIT ne suffit PAS. Vous devez sauvegarder l'intégralité de l'état du système pour garantir une restauration cohérente.

### Méthodes de sauvegarde

#### 🔹 Avec Windows Server Backup (WSB)

**Installation de la fonctionnalité :**

```powershell
# Installer Windows Server Backup
Install-WindowsFeature Windows-Server-Backup -IncludeManagementTools
```

**Sauvegarde complète du serveur :**

```powershell
# Créer une sauvegarde complète vers un disque externe
wbadmin start backup -backupTarget:E: -include:C: -allCritical -quiet

# Sauvegarde de l'état du système uniquement
wbadmin start systemstatebackup -backupTarget:E: -quiet
```

**Sauvegarde planifiée :**

```powershell
# Créer une sauvegarde quotidienne à 2h du matin
$Policy = New-WBPolicy
$BackupTarget = New-WBBackupTarget -VolumePath "E:"
Add-WBBackupTarget -Policy $Policy -Target $BackupTarget

# Ajouter l'état du système
Add-WBSystemState -Policy $Policy

# Définir la planification (tous les jours à 02:00)
$Schedule = New-WBSchedule -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday -Time 02:00
Set-WBSchedule -Policy $Policy -Schedule $Schedule

# Appliquer la politique
Set-WBPolicy -Policy $Policy
```

#### 🔹 Avec PowerShell (cmdlets dédiées)

```powershell
# Vérifier les sauvegardes existantes
Get-WBBackupSet -BackupTarget E:

# Sauvegarde manuelle avec journalisation
$Date = Get-Date -Format "yyyy-MM-dd_HH-mm"
wbadmin start systemstatebackup -backupTarget:E: -quiet | 
    Out-File "C:\Logs\Backup_$Date.log"

# Vérifier l'espace disque avant sauvegarde
$Volume = Get-Volume -DriveLetter E
if ($Volume.SizeRemaining -lt 50GB) {
    Write-Warning "Espace insuffisant sur le volume de sauvegarde !"
}
```

> [!tip] Astuce professionnelle Utilisez toujours des chemins de sauvegarde dédiés et évitez de sauvegarder sur le même volume que les données source. Idéalement, sauvegardez vers un stockage réseau (NAS/SAN) ou un service cloud.

### Planification des sauvegardes

**Stratégie de sauvegarde recommandée :**

```powershell
# Script de sauvegarde automatique avec rotation
$BackupPath = "\\NAS01\Backups\DC01"
$RetentionDays = 14

# Créer la sauvegarde
wbadmin start systemstatebackup -backupTarget:$BackupPath -quiet

# Nettoyer les anciennes sauvegardes
Get-ChildItem $BackupPath -Directory | 
    Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-$RetentionDays) } |
    Remove-Item -Recurse -Force

# Notification par email si échec
if ($LASTEXITCODE -ne 0) {
    Send-MailMessage -To "admin@domain.com" `
                     -From "dc01@domain.com" `
                     -Subject "Échec sauvegarde DC01" `
                     -SmtpServer "smtp.domain.com"
}
```

> [!warning] Attention à la taille Une sauvegarde de l'état du système peut facilement atteindre 10 à 50 GB selon la taille de votre annuaire. Planifiez l'espace de stockage en conséquence.

**Fréquence recommandée :**

|Environnement|Fréquence minimale|Rétention|
|---|---|---|
|Production critique|Quotidienne|30 jours|
|Production standard|Quotidienne|14 jours|
|Test/Développement|Hebdomadaire|7 jours|

---

## Restauration ne faisant pas autorité

### Concept et cas d'usage

Une **restauration ne faisant pas autorité** (non-authoritative restore) restaure les données AD depuis une sauvegarde, mais ces données sont ensuite mises à jour via la réplication depuis les autres contrôleurs de domaine.

**🎯 Quand l'utiliser :**

- ✅ Restaurer un contrôleur de domaine défaillant
- ✅ Reconstruire un DC après une panne matérielle
- ✅ Récupérer après une corruption du système d'exploitation
- ✅ Réinitialiser un DC de test

**❌ Quand NE PAS l'utiliser :**

- ❌ Récupérer un objet supprimé accidentellement (utilisez une restauration faisant autorité)
- ❌ Annuler une modification répliquée sur tous les DCs

> [!info] Principe de fonctionnement Après la restauration, les USN (Update Sequence Numbers) des objets restaurés sont plus anciens que ceux des autres DCs. Lors de la réplication, les données "plus récentes" des autres DCs écrasent les données restaurées.

### Procédure de restauration

#### Étape 1 : Démarrer en DSRM

```powershell
# Depuis Windows, redémarrer en mode DSRM
shutdown /r /o /t 0

# Sélectionner : Dépannage > Options avancées > Paramètres de démarrage
# Appuyer sur F8 pour "Mode de restauration des services d'annuaire"
```

#### Étape 2 : Se connecter avec le compte DSRM

- **Nom d'utilisateur :** `.\Administrateur` (compte local, pas de domaine)
- **Mot de passe :** Mot de passe DSRM défini lors de la promotion du DC

#### Étape 3 : Restaurer l'état du système

```powershell
# Lister les sauvegardes disponibles
wbadmin get versions -backupTarget:E:

# Identifier la version à restaurer (exemple : 12/29/2025-02:00)
$Version = "12/29/2025-02:00"

# Restaurer l'état du système
wbadmin start systemstaterecovery -version:$Version -backupTarget:E: -quiet

# La restauration prend généralement 15-30 minutes
```

> [!warning] Redémarrage automatique Par défaut, le serveur redémarre automatiquement après la restauration. Assurez-vous que c'est bien ce que vous voulez.

#### Étape 4 : Redémarrer normalement

```powershell
# Redémarrer en mode normal
shutdown /r /t 0
```

#### Étape 5 : Vérifier la réplication

```powershell
# Vérifier que la réplication fonctionne
repadmin /showrepl

# Forcer la réplication si nécessaire
repadmin /syncall /AdeP

# Vérifier les événements AD
Get-EventLog -LogName "Directory Service" -Newest 50 | 
    Where-Object { $_.EntryType -eq "Error" }
```

> [!example] Scénario typique Votre DC01 a subi une panne matérielle. Vous installez Windows Server sur un nouveau matériel, restaurez la sauvegarde de l'état du système, et le DC se resynchronise automatiquement avec DC02 et DC03 pour obtenir les dernières modifications.

---

## Restauration faisant autorité

### Concept et cas d'usage

Une **restauration faisant autorité** (authoritative restore) force les données restaurées à être répliquées vers TOUS les autres contrôleurs de domaine, écrasant les données actuelles.

**🎯 Quand l'utiliser :**

- ✅ Récupérer un objet supprimé accidentellement (utilisateur, OU, GPO)
- ✅ Annuler une modification erronée répliquée partout
- ✅ Restaurer un sous-arbre entier de l'annuaire
- ✅ Récupérer après une suppression massive accidentelle

**❌ Quand NE PAS l'utiliser :**

- ❌ Restaurer un DC défaillant (utilisez une restauration non-authoritative)
- ❌ Si vous n'êtes pas sûr de ce que vous faites (risque de corruption de l'annuaire)

> [!info] Principe de fonctionnement La restauration faisant autorité incrémente artificiellement les USN des objets restaurés, les rendant "plus récents" que toutes les versions existantes. Ces objets sont alors répliqués vers tous les autres DCs.

### Procédure de restauration

#### Étape 1 à 3 : Identiques à la restauration non-authoritative

Suivez les étapes 1 à 3 de la restauration ne faisant pas autorité (démarrer en DSRM et restaurer l'état du système).

#### Étape 4 : Marquer les objets comme faisant autorité

**⚠️ NE PAS REDÉMARRER après la restauration de l'état du système**

```powershell
# Restaurer un seul objet utilisateur
ntdsutil
activate instance ntds
authoritative restore
restore object "CN=Jean Dupont,OU=Users,DC=contoso,DC=com"
quit
quit

# Redémarrer ensuite
shutdown /r /t 0
```

**Restaurer une unité d'organisation complète :**

```powershell
ntdsutil
activate instance ntds
authoritative restore
restore subtree "OU=Marketing,DC=contoso,DC=com"
quit
quit
```

**Restaurer la totalité de l'annuaire (extrêmement rare) :**

```powershell
ntdsutil
activate instance ntds
authoritative restore
restore database
quit
quit
```

> [!warning] Danger : Restauration complète La restauration de la totalité de l'annuaire (`restore database`) doit être effectuée UNIQUEMENT si vous êtes absolument certain de vouloir ramener TOUT l'annuaire à un état antérieur. Cela annule TOUTES les modifications effectuées depuis la sauvegarde.

### Restauration sélective

**Restaurer uniquement certains attributs :**

```powershell
# Cette option est moins courante mais possible avec ntdsutil
# Exemple : restaurer uniquement les membres d'un groupe

ntdsutil
activate instance ntds
authoritative restore
restore object "CN=Groupe-RH,OU=Groups,DC=contoso,DC=com" verinc 100000
quit
quit
```

**Paramètre `verinc` :**

- Définit l'incrément d'USN à appliquer
- Valeur par défaut : 100 000
- Plus la valeur est élevée, plus la priorité est haute lors de la réplication

> [!tip] Astuce pour les gros environnements Si vous avez de nombreux DCs ou des liens de réplication lents, augmentez le `verinc` à 500 000 ou 1 000 000 pour garantir que la restauration faisant autorité prend le dessus rapidement.

**Script PowerShell pour automatiser :**

```powershell
# Fonction de restauration faisant autorité
function Restore-ADObjectAuthoritative {
    param(
        [string]$ObjectDN,
        [int]$VersionIncrease = 100000
    )
    
    $NtdsUtilCommands = @(
        "activate instance ntds"
        "authoritative restore"
        "restore object `"$ObjectDN`" verinc $VersionIncrease"
        "quit"
        "quit"
    )
    
    $NtdsUtilCommands | ntdsutil
}

# Utilisation
Restore-ADObjectAuthoritative -ObjectDN "CN=User01,OU=Users,DC=contoso,DC=com"
```

---

## Mode de restauration des services d'annuaire (DSRM)

### Comprendre le DSRM

Le **Directory Services Restore Mode (DSRM)** est un mode de démarrage spécial de Windows Server qui démarre le système sans charger Active Directory.

**📌 Caractéristiques du DSRM :**

- Active Directory n'est **PAS** démarré
- Le DC fonctionne comme un serveur Windows autonome
- Permet l'accès direct à la base de données NTDS.DIT
- Utilise un compte administrateur local distinct
- Nécessaire pour toute restauration AD

> [!info] Analogie Le DSRM est l'équivalent du "mode sans échec" pour Active Directory. C'est un environnement minimal qui permet d'effectuer des opérations de maintenance et de restauration critiques.

**🎯 Utilisations du DSRM :**

|Scénario|Description|
|---|---|
|**Restauration AD**|Obligatoire pour restaurer l'état du système|
|**Réparation de NTDS.DIT**|Correction de corruption de base de données|
|**Maintenance offline**|Défragmentation, vérification d'intégrité|
|**Récupération d'urgence**|Accès au système si AD est corrompu|
|**Changement de mot de passe DSRM**|Réinitialisation du mot de passe DSRM|

### Accéder au DSRM

#### Méthode 1 : Depuis Windows (recommandé)

```powershell
# Redémarrer en DSRM
shutdown /r /o /t 0

# Ou configurer le prochain démarrage en DSRM
bcdedit /set safeboot dsrepair
shutdown /r /t 0

# Après utilisation, supprimer l'option
bcdedit /deletevalue safeboot
```

#### Méthode 2 : Depuis les options de démarrage

1. Redémarrer le serveur
2. Appuyer sur **F8** pendant le démarrage
3. Sélectionner **Mode de restauration des services d'annuaire**

#### Méthode 3 : Depuis msconfig

```powershell
# Ouvrir msconfig
msconfig

# Onglet "Démarrage" > cocher "Démarrage sécurisé" > sélectionner "Réparation Active Directory"
# Appliquer et redémarrer
```

> [!warning] Se connecter correctement En DSRM, vous devez utiliser le compte administrateur LOCAL. La syntaxe est `.\Administrateur` ou `NOM-SERVEUR\Administrateur`, JAMAIS `DOMAINE\Administrateur`.

### Gestion du mot de passe DSRM

Le mot de passe DSRM est défini lors de la promotion du serveur en contrôleur de domaine et n'est **PAS synchronisé** avec les mots de passe du domaine.

#### Vérifier/Modifier le mot de passe DSRM

**En mode normal (depuis Windows) :**

```powershell
# Modifier le mot de passe DSRM
ntdsutil
set dsrm password
reset password on server null
# Taper le nouveau mot de passe deux fois
quit
quit
```

**Synchroniser avec un compte du domaine :**

```powershell
# Synchroniser le mot de passe DSRM avec un compte administrateur du domaine
ntdsutil
set dsrm password
sync from domain account CONTOSO\AdminDS
quit
quit
```

> [!tip] Bonne pratique Synchronisez le mot de passe DSRM avec un compte de service dédié dont le mot de passe est géré et documenté. Cela évite les situations où personne ne se souvient du mot de passe DSRM.

**Script de rotation automatique :**

```powershell
# Script à exécuter mensuellement via une tâche planifiée
$NewPassword = "P@ssw0rd-" + (Get-Date -Format "yyyyMM")

$Commands = @(
    "set dsrm password"
    "reset password on server null"
    "$NewPassword"
    "$NewPassword"
    "quit"
    "quit"
)

$Commands | ntdsutil

# Enregistrer dans un coffre-fort de mots de passe
# (code de connexion à votre gestionnaire de mots de passe)
```

#### Autoriser la connexion DSRM en ligne

Par défaut, le compte DSRM ne peut se connecter qu'en mode DSRM. Vous pouvez l'autoriser en mode normal pour les tests :

```powershell
# Autoriser la connexion DSRM même quand AD est démarré (DÉCONSEILLÉ en production)
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" `
                 -Name "DsrmAdminLogonBehavior" `
                 -Value 2 `
                 -PropertyType DWORD

# Valeurs possibles :
# 0 = Uniquement en DSRM (défaut, recommandé)
# 1 = Toujours si DC est offline
# 2 = Toujours (dangereux !)
```

> [!warning] Risque de sécurité N'activez JAMAIS la connexion DSRM en mode normal sur un DC de production. Cela crée une porte dérobée qui peut être exploitée par des attaquants.

---

## Comparaison des types de restauration

|Critère|Restauration non-authoritative|Restauration authoritative|
|---|---|---|
|**Objectif**|Restaurer un DC défaillant|Récupérer des objets supprimés|
|**Réplication post-restauration**|Reçoit les données des autres DCs|Envoie les données vers les autres DCs|
|**USN des objets**|Conservés (anciens)|Incrémentés (plus récents)|
|**Impact sur l'annuaire**|Aucun, le DC se resynchronise|Modifie tous les DCs|
|**Complexité**|Faible|Moyenne à élevée|
|**Risque**|Très faible|Moyen (si mal exécuté)|
|**Durée typique**|30 min - 2h|1-4h (selon la réplication)|
|**Nécessite DSRM**|Oui|Oui|
|**Étape ntdsutil**|Non|Oui|

> [!example] Scénario comparatif
> 
> **Cas 1 : Panne matérielle de DC01**
> 
> - Solution : Restauration **non-authoritative**
> - Résultat : DC01 récupère et se synchronise avec DC02/DC03
> 
> **Cas 2 : Un administrateur supprime l'OU "Marketing" par erreur**
> 
> - Solution : Restauration **authoritative** de l'OU Marketing
> - Résultat : L'OU réapparaît sur tous les DCs

---

## Bonnes pratiques

### 🎯 Sauvegarde

1. **Testez vos sauvegardes régulièrement**
    
    ```powershell
    # Script de test trimestriel
    # Restaurer sur un DC de test et vérifier l'intégrité
    ```
    
2. **Sauvegardez au moins 2 DCs par domaine**
    
    - Protège contre la perte simultanée de plusieurs DCs
    - Offre des points de restauration alternatifs
3. **Conservez des sauvegardes hors site**
    
    - Cloud ou datacenter secondaire
    - Protection contre les sinistres physiques
4. **Respectez la durée de vie des pierres tombales**
    
    - Par défaut : 180 jours
    - Ne restaurez JAMAIS une sauvegarde plus ancienne que la TSL
5. **Documentez votre stratégie de sauvegarde**
    
    - Emplacement des sauvegardes
    - Procédures de restauration
    - Mots de passe DSRM sécurisés

### 🎯 Restauration

1. **Préparez-vous AVANT le sinistre**
    
    ```powershell
    # Vérifiez que vous connaissez le mot de passe DSRM
    # Documentez les procédures
    # Formez l'équipe
    ```
    
2. **Isolez le DC pendant la restauration**
    
    - Déconnectez du réseau si possible
    - Évite la réplication prématurée
3. **Vérifiez la cohérence après restauration**
    
    ```powershell
    # Vérifier la base de données
    ntdsutil
    activate instance ntds
    files
    integrity
    quit
    quit
    
    # Vérifier la réplication
    repadmin /showrepl
    repadmin /replsummary
    ```
    
4. **Effectuez une restauration authoritative uniquement si nécessaire**
    
    - Identifiez précisément l'objet à restaurer
    - Comprenez l'impact sur tous les DCs
    - Documentez l'action
5. **Surveillez la réplication post-restauration**
    
    ```powershell
    # Surveiller pendant 24-48h
    Get-ADReplicationFailure -Target DC01
    Get-ADReplicationPartnerMetadata -Target DC01
    ```
    

### 🎯 Sécurité DSRM

1. **Changez le mot de passe DSRM régulièrement**
    
    - Au minimum : annuellement
    - Recommandé : trimestriellement
2. **Ne stockez JAMAIS le mot de passe DSRM en clair**
    
    - Utilisez un gestionnaire de mots de passe d'entreprise
    - Accès limité aux administrateurs AD seniors
3. **Auditez les démarrages en DSRM**
    
    ```powershell
    # Créer une alerte sur l'événement 1074 (Safe Mode boot)
    Get-WinEvent -FilterHashtable @{
        LogName='System'
        ID=1074
    } | Where-Object { $_.Message -match "safe mode" }
    ```
    
4. **Testez l'accès DSRM régulièrement**
    
    - Vérifiez que le mot de passe fonctionne
    - Dans un environnement de test uniquement

> [!tip] Check-list de restauration d'urgence
> 
> ✅ Mot de passe DSRM connu et testé ✅ Sauvegardes récentes (< 7 jours) ✅ Procédures documentées et accessibles ✅ Équipe formée aux procédures de restauration ✅ DC de test disponible pour valider les procédures ✅ Contacts des éditeurs de logiciels intégrés à AD ✅ Plan de communication en cas de sinistre ✅ Outils de restauration installés et fonctionnels

---

## Pièges courants à éviter

> [!warning] Erreurs fréquentes

**❌ Restaurer une sauvegarde trop ancienne**

- Risque : Création d'objets "lingering objects"
- Solution : Respectez toujours la durée de vie des pierres tombales (180 jours par défaut)

**❌ Oublier l'étape ntdsutil pour une restauration authoritative**

- Résultat : Les objets restaurés sont immédiatement écrasés par la réplication
- Solution : Suivez scrupuleusement la procédure en 5 étapes

**❌ Se connecter avec le mauvais compte en DSRM**

- Erreur : Essayer de se connecter avec `DOMAINE\Administrateur`
- Correct : Utiliser `.\Administrateur` (compte local)

**❌ Restaurer tous les DCs simultanément**

- Problème : Plus de référence "saine" pour la réplication
- Solution : Restaurez UN SEUL DC, laissez-le répliquer, puis passez aux autres si nécessaire

**❌ Ne pas tester les sauvegardes**

- Risque : Découvrir que les sauvegardes sont corrompues au moment critique
- Solution : Tests trimestriels dans un environnement de lab

---

> [!info] 📚 Concepts clés à retenir
> 
> - **L'état du système** inclut NTDS.DIT, SYSVOL, registre et fichiers système
> - **Restauration non-authoritative** : pour reconstruire un DC défaillant
> - **Restauration authoritative** : pour récupérer des objets supprimés
> - **DSRM** : mode de démarrage obligatoire pour toute restauration AD
> - **Le mot de passe DSRM** est indépendant et doit être géré séparément
> - **Testez régulièrement** vos procédures de sauvegarde et restauration

---

_Cours réalisé pour Obsidian - Active Directory Domain Services (ADDS)_