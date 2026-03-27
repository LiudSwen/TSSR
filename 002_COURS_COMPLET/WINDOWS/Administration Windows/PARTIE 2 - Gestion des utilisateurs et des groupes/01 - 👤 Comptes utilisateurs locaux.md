

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

Les comptes utilisateurs locaux sont des identités créées et stockées directement sur un serveur Windows, indépendamment d'Active Directory. Ils permettent aux utilisateurs de s'authentifier et d'accéder aux ressources de ce serveur spécifique uniquement.

> [!info] Contexte d'utilisation
> Les comptes locaux sont principalement utilisés dans les environnements suivants :
> - Serveurs workgroup (hors domaine)
> - Serveurs autonomes ou en DMZ
> - Comptes de service pour des applications spécifiques
> - Accès d'urgence ou de secours (compte administrateur local)

> [!warning] Limitation importante
> Un compte utilisateur local n'est valable QUE sur le serveur où il a été créé. Il ne permet pas d'accéder à d'autres machines du réseau (contrairement aux comptes de domaine AD).

---

## 🔧 Création et gestion des comptes utilisateurs

### Méthodes de création

Il existe trois principales méthodes pour gérer les comptes utilisateurs locaux :

#### 1️⃣ Via la console Gestion de l'ordinateur (GUI)

**Chemin d'accès :**
```
Gestionnaire de serveur > Outils > Gestion de l'ordinateur > 
Utilisateurs et groupes locaux > Utilisateurs
```

Ou directement via la commande : `lusrmgr.msc`

**Étapes de création :**

1. Clic droit sur le dossier "Utilisateurs"
2. Sélectionner "Nouvel utilisateur..."
3. Renseigner les informations obligatoires :
   - **Nom d'utilisateur** : identifiant de connexion (sensible à la casse lors de la connexion)
   - **Mot de passe** : selon la politique de sécurité en vigueur
   - **Confirmer le mot de passe**

4. Options disponibles :
   - ☐ L'utilisateur doit changer de mot de passe à la prochaine ouverture de session
   - ☐ L'utilisateur ne peut pas changer de mot de passe
   - ☐ Le mot de passe n'expire jamais
   - ☐ Le compte est désactivé

> [!example] Exemple de configuration courante
> Pour un compte de service applicatif :
> - ✅ Le mot de passe n'expire jamais
> - ✅ L'utilisateur ne peut pas changer de mot de passe
> - ❌ L'utilisateur doit changer de mot de passe à la prochaine connexion

#### 2️⃣ Via l'invite de commandes

**Création d'un utilisateur :**
```cmd
net user [nom_utilisateur] [mot_de_passe] /add
```

**Exemples pratiques :**
```cmd
REM Créer un utilisateur simple
net user jdupont MonP@ss123! /add

REM Créer un utilisateur avec commentaire
net user mmartin * /add /comment:"Compte de service pour application web"
REM Le * demande interactivement le mot de passe (plus sécurisé)

REM Créer avec expiration désactivée
net user service_backup P@ssw0rd /add /expires:never
```

**Modification d'un utilisateur existant :**
```cmd
REM Désactiver un compte
net user jdupont /active:no

REM Activer un compte
net user jdupont /active:yes

REM Changer le mot de passe
net user jdupont NouveauP@ss456!

REM Définir que le mot de passe n'expire jamais
net user service_app * /expires:never
```

**Suppression d'un utilisateur :**
```cmd
net user [nom_utilisateur] /delete

REM Exemple
net user ancien_employe /delete
```

**Lister les utilisateurs :**
```cmd
net user
```

> [!tip] Astuce
> Utilisez `net user [nom_utilisateur]` sans autres paramètres pour afficher toutes les informations détaillées d'un compte spécifique.

#### 3️⃣ Via PowerShell (méthode moderne)

**Création d'un utilisateur :**
```powershell
# Création avec mot de passe sécurisé
$Password = ConvertTo-SecureString "MonP@ss123!" -AsPlainText -Force
New-LocalUser -Name "jdupont" -Password $Password -FullName "Jean Dupont" -Description "Utilisateur standard"

# Création avec prompt interactif pour le mot de passe
New-LocalUser -Name "mmartin" -Description "Compte de service" -NoPassword
Set-LocalUser -Name "mmartin" -Password (Read-Host -AsSecureString "Entrez le mot de passe")
```

**Modification d'un utilisateur :**
```powershell
# Désactiver un compte
Disable-LocalUser -Name "jdupont"

# Activer un compte
Enable-LocalUser -Name "jdupont"

# Modifier les propriétés
Set-LocalUser -Name "jdupont" -Description "Nouvelle description" -FullName "Jean-Pierre Dupont"

# Définir que le mot de passe n'expire jamais
Set-LocalUser -Name "service_app" -PasswordNeverExpires $true

# Changer le mot de passe
$NewPassword = ConvertTo-SecureString "NouveauP@ss!" -AsPlainText -Force
Set-LocalUser -Name "jdupont" -Password $NewPassword
```

**Consultation et suppression :**
```powershell
# Lister tous les utilisateurs locaux
Get-LocalUser

# Afficher les détails d'un utilisateur
Get-LocalUser -Name "jdupont" | Format-List *

# Supprimer un utilisateur
Remove-LocalUser -Name "ancien_employe"
```

> [!tip] PowerShell vs CMD
> PowerShell offre plus de flexibilité et une meilleure gestion des objets. C'est la méthode recommandée pour l'automatisation et les scripts modernes.

---

## 📝 Propriétés des comptes utilisateurs

### Propriétés principales

Chaque compte utilisateur possède plusieurs propriétés configurables via l'interface graphique (double-clic sur l'utilisateur dans `lusrmgr.msc`) :

#### Onglet "Général"

| Propriété | Description | Cas d'usage |
|-----------|-------------|-------------|
| **Nom complet** | Nom affiché de l'utilisateur | "Jean Dupont" pour jdupont |
| **Description** | Information sur le compte | "Compte de service IIS" ou "Utilisateur temporaire" |
| **L'utilisateur doit changer le mot de passe...** | Force le changement au premier login | Nouveaux employés |
| **L'utilisateur ne peut pas changer de mot de passe** | Empêche la modification | Comptes de service |
| **Le mot de passe n'expire jamais** | Désactive l'expiration | Comptes de service, tâches planifiées |
| **Le compte est désactivé** | Bloque toute connexion | Suspension temporaire d'accès |

> [!warning] Attention aux comptes de service
> Pour les comptes utilisés par des applications ou services Windows :
> - ✅ TOUJOURS cocher "Le mot de passe n'expire jamais"
> - ✅ TOUJOURS cocher "L'utilisateur ne peut pas changer de mot de passe"
> 
> Sinon, le service cessera de fonctionner lorsque le mot de passe expirera !

#### Onglet "Membre de"

Affiche les groupes locaux auxquels l'utilisateur appartient. Par défaut, un nouvel utilisateur est membre du groupe **Utilisateurs**.

Pour une gestion avancée des appartenances aux groupes, voir la section suivante sur les groupes locaux.

#### Onglet "Profil"

Configure le profil utilisateur :

- **Chemin du profil** : Emplacement d'un profil itinérant (rare en local)
- **Script d'ouverture de session** : Script exécuté à la connexion
- **Chemin d'accès local** : Lecteur réseau mappé automatiquement
- **Dossier de base** : Dossier personnel de l'utilisateur

> [!info] Utilisation limitée en environnement local
> Ces options sont principalement utilisées dans un environnement Active Directory. En environnement local (workgroup), elles sont rarement configurées.

### Attributs avancés via PowerShell

PowerShell permet d'accéder à des propriétés supplémentaires :

```powershell
# Voir toutes les propriétés d'un compte
Get-LocalUser -Name "jdupont" | Select-Object *

# Propriétés utiles :
# - Enabled : Le compte est-il actif ?
# - PasswordRequired : Un mot de passe est-il requis ?
# - PasswordLastSet : Date du dernier changement de mot de passe
# - LastLogon : Dernière connexion
# - SID : Identifiant de sécurité unique
```

---

## 🔐 Comptes intégrés

Windows Server crée automatiquement plusieurs comptes intégrés lors de l'installation. Ces comptes ont des rôles spécifiques dans le système.

### Administrateur

**Caractéristiques :**
- Compte avec privilèges complets sur le système
- Ne peut PAS être supprimé
- Peut être renommé (recommandé pour la sécurité)
- Peut être désactivé (mais attention aux conséquences !)

**Bonnes pratiques de sécurité :**

> [!warning] Recommandations importantes
> 1. **Renommer le compte Administrateur** pour éviter les attaques par force brute ciblant ce nom connu
> 2. **Utiliser un mot de passe très robuste** (20+ caractères, complexe)
> 3. **Créer des comptes administrateurs nommés** pour chaque administrateur système
> 4. **Désactiver le compte si non utilisé** (uniquement si d'autres comptes admin existent)
> 5. **Ne jamais utiliser pour les tâches quotidiennes** (principe du moindre privilège)

**Renommer le compte Administrateur :**

```powershell
# Via PowerShell
Rename-LocalUser -Name "Administrateur" -NewName "Admin_Systeme_2025"

# Vérification
Get-LocalUser | Where-Object {$_.SID -like "*-500"}
```

Ou via GPO locale :
```
Configuration ordinateur > Paramètres Windows > Paramètres de sécurité > 
Stratégies locales > Options de sécurité > 
Comptes : Renommer le compte Administrateur
```

### Invité (Guest)

**Caractéristiques :**
- Compte avec privilèges minimaux
- Désactivé par défaut
- Permet un accès temporaire sans mot de passe (très risqué)
- Ne peut PAS être supprimé

> [!warning] Sécurité
> Le compte Invité doit TOUJOURS rester désactivé en production pour des raisons de sécurité. Il représente un vecteur d'attaque potentiel.

**Cas d'usage légitime (très rare) :**
- Kiosques publics strictement contrôlés
- Démonstrations temporaires dans un environnement isolé

### DefaultAccount

**Caractéristiques :**
- Compte système utilisé par Windows pour certaines opérations
- Désactivé par défaut
- Utilisé par le système pour l'exécution d'applications multi-utilisateurs
- **NE JAMAIS activer ou modifier ce compte**

> [!info] Information technique
> Ce compte est géré par Windows et n'a pas vocation à être utilisé par des humains. Il est présent depuis Windows 10 / Server 2016.

### WDAGUtilityAccount

**Caractéristiques :**
- Compte pour Windows Defender Application Guard
- Géré automatiquement par le système
- Utilisé pour isoler des applications dans un conteneur de sécurité
- **NE PAS modifier**

---

## 🔑 Gestion des mots de passe et stratégies

### Stratégies de mot de passe locales

Windows Server applique par défaut une politique de mot de passe pour renforcer la sécurité.

**Accès aux stratégies :**
```
Gestionnaire de serveur > Outils > Stratégie de sécurité locale >
Stratégies de compte > Stratégie de mot de passe
```

Ou via la commande : `secpol.msc`

#### Paramètres de stratégie disponibles

| Paramètre | Valeur par défaut | Description | Recommandation |
|-----------|-------------------|-------------|----------------|
| **Appliquer l'historique des mots de passe** | 24 mots de passe mémorisés | Empêche la réutilisation des anciens mots de passe | 12-24 |
| **Durée de vie maximale du mot de passe** | 42 jours | Le mot de passe doit être changé après ce délai | 60-90 jours (ou désactivé pour comptes de service) |
| **Durée de vie minimale du mot de passe** | 1 jour | Délai avant de pouvoir changer à nouveau le mot de passe | 1 jour |
| **Longueur minimale du mot de passe** | 7 caractères | Nombre minimum de caractères requis | 12-14 caractères minimum |
| **Le mot de passe doit respecter des exigences de complexité** | Activé | Force l'utilisation de 3 des 4 catégories de caractères | Activé |
| **Stocker les mots de passe en utilisant un chiffrement réversible** | Désactivé | Très risqué, ne jamais activer sauf besoin très spécifique | Désactivé |

#### Exigences de complexité détaillées

Lorsque la complexité est activée, un mot de passe doit :

1. ✅ Ne PAS contenir le nom du compte utilisateur
2. ✅ Ne PAS contenir des parties du nom complet de l'utilisateur (3 caractères consécutifs ou plus)
3. ✅ Faire au moins 7 caractères de long (ou selon la longueur minimale définie)
4. ✅ Contenir des caractères provenant de 3 des 4 catégories suivantes :
   - Lettres majuscules (A-Z)
   - Lettres minuscules (a-z)
   - Chiffres (0-9)
   - Caractères spéciaux (!@#$%^&*()_+-=[]{}|;:,.<>?)

> [!example] Exemples de mots de passe
> - ✅ **Valide** : `P@ssw0rd2025` (majuscules, minuscules, chiffres, spéciaux)
> - ✅ **Valide** : `MonServeur#123` (majuscules, minuscules, chiffres, spéciaux)
> - ❌ **Invalide** : `password123` (pas de majuscule ni caractère spécial)
> - ❌ **Invalide** : `Jean123` (contient le prénom de l'utilisateur Jean Dupont)

### Stratégies de verrouillage de compte

Protection contre les attaques par force brute.

**Accès :**
```
Stratégie de sécurité locale > Stratégies de compte > 
Stratégie de verrouillage du compte
```

| Paramètre | Valeur par défaut | Description | Recommandation |
|-----------|-------------------|-------------|----------------|
| **Seuil de verrouillage du compte** | 0 (désactivé) | Nombre de tentatives échouées avant verrouillage | 5-10 tentatives |
| **Durée de verrouillage du compte** | Non défini | Durée du verrouillage | 15-30 minutes |
| **Réinitialiser le compteur de verrouillage après** | Non défini | Délai après lequel le compteur repart à zéro | 15-30 minutes |

> [!tip] Configuration recommandée
> ```
> Seuil de verrouillage : 5 tentatives
> Durée de verrouillage : 30 minutes
> Réinitialisation du compteur : 30 minutes
> ```
> 
> Cela bloque un compte après 5 échecs de connexion pendant 30 minutes, puis le déverrouille automatiquement.

### Déverrouillage manuel d'un compte

#### Via l'interface graphique

1. Ouvrir `lusrmgr.msc`
2. Double-clic sur le compte verrouillé
3. Onglet "Général"
4. Décocher "Le compte est verrouillé"

#### Via PowerShell

```powershell
# Vérifier si un compte est verrouillé
Get-LocalUser -Name "jdupont" | Select-Object Name, Enabled, LockedOut

# Note : PowerShell ne permet pas de déverrouiller directement un compte local
# Il faut utiliser l'interface graphique ou net user
```

#### Via CMD

```cmd
REM Déverrouiller en réinitialisant le mot de passe
net user jdupont NouveauMotDePasse
```

> [!warning] Limitation
> Les cmdlets PowerShell pour les comptes locaux ne permettent pas de déverrouiller un compte directement. Il faut passer par l'interface graphique ou réinitialiser le mot de passe.

### Gestion des mots de passe expirés

**Forcer l'expiration immédiate d'un mot de passe :**

```powershell
# Le compte devra changer son mot de passe à la prochaine connexion
Set-LocalUser -Name "jdupont" -PasswordNeverExpires $false
# Puis définir une date d'expiration dans le passé (via interface graphique)
```

**Désactiver l'expiration pour un compte de service :**

```powershell
Set-LocalUser -Name "service_web" -PasswordNeverExpires $true
```

```cmd
net user service_web /expires:never
```

### Affichage des informations de mot de passe

**Via PowerShell :**
```powershell
# Voir les détails de mot de passe d'un compte
Get-LocalUser -Name "jdupont" | Format-List Name, PasswordLastSet, PasswordExpires, PasswordRequired, PasswordNeverExpires

# Lister tous les comptes avec mot de passe n'expirant jamais
Get-LocalUser | Where-Object {$_.PasswordNeverExpires -eq $true} | Select-Object Name, Description
```

**Via CMD :**
```cmd
REM Afficher toutes les informations d'un compte
net user jdupont
```

> [!tip] Audit de sécurité
> Exécutez régulièrement un audit des comptes locaux pour identifier :
> - Les comptes avec mots de passe n'expirant jamais (sauf comptes de service légitimes)
> - Les comptes désactivés qui peuvent être supprimés
> - Les comptes sans mot de passe ou avec mots de passe faibles
> - Les dernières dates de connexion pour détecter les comptes inactifs

---

## 🎯 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

1. **Oublier de cocher "Le mot de passe n'expire jamais" pour les comptes de service**
   - Conséquence : Le service cesse de fonctionner après expiration
   - Solution : Toujours configurer correctement dès la création

2. **Désactiver le seul compte Administrateur sans avoir créé d'autres administrateurs**
   - Conséquence : Perte totale d'accès administratif au serveur
   - Solution : Toujours avoir au moins 2 comptes administrateurs actifs

3. **Utiliser le même mot de passe pour plusieurs comptes de service**
   - Risque : Compromission en cascade
   - Solution : Un mot de passe unique par compte de service

4. **Ne pas documenter les comptes de service**
   - Problème : Impossible de savoir à quoi sert un compte après plusieurs mois
   - Solution : Description claire + documentation externe

5. **Créer des comptes avec des droits excessifs**
   - Risque : Violation du principe du moindre privilège
   - Solution : Donner uniquement les droits nécessaires

### ✅ Bonnes pratiques

1. **Nommage cohérent**
   ```
   Utilisateurs standards : prenom.nom ou pnom
   Comptes de service : svc_application ou service_fonction
   Comptes administrateurs : adm_prenom.nom
   ```

2. **Documentation systématique**
   - Utiliser le champ "Description" pour chaque compte
   - Tenir à jour un registre des comptes de service (application associée, mot de passe stocké en coffre-fort)

3. **Séparation des privilèges**
   - Un compte administrateur personnel pour chaque administrateur système
   - Un compte utilisateur standard pour les tâches quotidiennes
   - Utilisation de "Exécuter en tant qu'administrateur" uniquement quand nécessaire

4. **Revue régulière des comptes**
   - Audit mensuel ou trimestriel
   - Suppression des comptes inutilisés depuis 90+ jours
   - Vérification des comptes avec privilèges

5. **Gestion sécurisée des mots de passe**
   - Utiliser un gestionnaire de mots de passe d'entreprise pour les comptes de service
   - Ne JAMAIS stocker les mots de passe en clair dans des fichiers
   - Rotation régulière des mots de passe administrateurs

6. **Traçabilité**
   - Activer l'audit des événements de connexion
   - Surveiller les échecs de connexion répétés
   - Journaliser les modifications de comptes

---

> [!tip] Mémo rapide des commandes essentielles
> ```powershell
> # PowerShell - Gestion des utilisateurs locaux
> Get-LocalUser                                    # Lister les utilisateurs
> New-LocalUser -Name "user" -Password $pass       # Créer un utilisateur
> Set-LocalUser -Name "user" -Description "desc"   # Modifier un utilisateur
> Remove-LocalUser -Name "user"                    # Supprimer un utilisateur
> Disable-LocalUser -Name "user"                   # Désactiver un utilisateur
> Enable-LocalUser -Name "user"                    # Activer un utilisateur
> ```
> 
> ```cmd
> REM CMD - Gestion des utilisateurs locaux
> net user                              REM Lister les utilisateurs
> net user nom_user mot_de_passe /add   REM Créer un utilisateur
> net user nom_user /delete             REM Supprimer un utilisateur
> net user nom_user /active:no          REM Désactiver un utilisateur
> net user nom_user                     REM Afficher les détails
> ```

---