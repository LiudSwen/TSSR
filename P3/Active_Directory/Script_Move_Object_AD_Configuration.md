## Sommaire

- [1. Objectif](#1-objectif)
- [2. Principe de fonctionnement](#2-principe-de-fonctionnement)
- [3. Pré-requis](#3-pré-requis)
- [4. Structure Active Directory utilisée](#4-structure-active-directory-utilisée)
- [5. Convention de nommage des ordinateurs](#5-convention-de-nommage-des-ordinateurs)
- [6. Fonctionnement du script](#6-fonctionnement-du-script)
- [7. Configuration du script](#7-configuration-du-script)
- [8. Fonction d’analyse du nom de machine](#8-fonction-danalyse-du-nom-de-machine)
- [9. Boucle de traitement des ordinateurs](#9-boucle-de-traitement-des-ordinateurs)
- [10. Mode simulation et déplacement réel](#10-mode-simulation-et-déplacement-réel)
- [11. Exemple de sortie du script](#11-exemple-de-sortie-du-script)

---

# 1. Objectif

L’objectif de ce script PowerShell est **d’automatiser le classement des ordinateurs dans les bonnes unités d’organisation (OU) de l’Active Directory**.

Lorsqu’un ordinateur rejoint le domaine, il est généralement placé par défaut dans :

```
CN=Computers
```

Le script analyse ensuite le **nom de la machine**, détermine le service ou département correspondant et déplace automatiquement l’objet ordinateur dans l’OU appropriée.

Cela permet :
- d’automatiser l’organisation de l’Active Directory
- d’éviter les erreurs de classement
- d’appliquer automatiquement les **GPO associées aux OU**
- de faciliter l’administration des postes

---
# 2. Principe de fonctionnement

Le script fonctionne en plusieurs étapes :
1. Chargement du module **Active Directory**
2. Récupération des ordinateurs présents dans `CN=Computers`
3. Analyse du nom de chaque machine
4. Identification du service correspondant
5. Recherche de l’OU cible dans une table de correspondance
6. Affichage ou déplacement de l’objet dans l’OU cible

---
# 3. Pré-requis

Pour exécuter ce script, les éléments suivants sont nécessaires :
- Serveur membre du domaine ou contrôleur de domaine
- Module **ActiveDirectory** disponible
- Droits suffisants pour déplacer des objets AD
- Convention de nommage des ordinateurs respectée

Module requis :
```
Import-Module ActiveDirectory
```

---

# 4. Structure Active Directory utilisée

Les ordinateurs sont classés sous l’OU principale :

```
OU=BilluComputers
```

Chaque département possède ensuite sa propre OU.

Exemple :
```
OU=BilluComputers  
│  
├── OU=COMMERCIAL  
├── OU=COMMUNICATION  
├── OU=COMPTABILITE  
├── OU=DEV  
├── OU=DSI  
├── OU=JURIDIQUE  
├── OU=QHSE  
└── OU=RH
```

Chaque département peut également contenir des **OU de services**.

Exemple :
```
OU=DSI  
│  
├── ADMINISTRATION_SYSTEMES_RESEAUX  
├── DEVELOPPEMENT_INTEGRATION  
├── EXPLOITATION  
└── SUPPORT
```

---

# 5. Convention de nommage des ordinateurs

Le script repose sur une **convention de nommage standardisée**.

Format attendu :
```
TYPE-SERVICE-NUMERO
```

Exemples :
```
PC-DEV-001  
PC-DSI-002  
PC-ASR-014  
PC-B2B-003
```

Structure :

| Partie  | Description                    |
| ------- | ------------------------------ |
| TYPE    | Type de machine (PC)           |
| SERVICE | Code du service ou département |
| NUMERO  | Numéro unique                  |

Exemple :

```
PC-ASR-014
```

Correspond au service :

```
ADMINISTRATION_SYSTEMES_RESEAUX
```

---

# 6. Fonctionnement du script

Le script se compose de trois parties principales :

1️⃣ Configuration  
2️⃣ Fonctions  
3️⃣ Traitement des objets AD

---

# 7. Configuration du script

La première section configure les paramètres principaux.

### Définition du domaine

```
$Domain = "DC=billu,DC=lan"
```

Cette variable représente la base LDAP du domaine.

---

### OU contenant les nouveaux ordinateurs

```
$SearchBase = "CN=Computers,$Domain"
```

Les nouveaux ordinateurs sont récupérés depuis cet emplacement.

---

### Récupération des ordinateurs

```
$Computers = Get-ADComputer -SearchBase $SearchBase -Filter * -Properties DistinguishedName, Name
```

Cette commande récupère :
- le nom de la machine
- son DistinguishedName

---

### Table de correspondance des OU

Le script utilise une **Hashtable PowerShell**.
```
$OUMap = @{  
    "DEV" = "OU=DEV,OU=BilluComputers,$Domain"  
}
```

Principe :

|Code machine|OU cible|
|---|---|
|DEV|OU DEV|
|ASR|OU ADMINISTRATION_SYSTEMES_RESEAUX|
|FIN|OU FINANCE|

Exemple :
```
PC-ASR-014
```

sera déplacé vers :
```
OU=ADMINISTRATION_SYSTEMES_RESEAUX
```

---

# 8. Fonction d’analyse du nom de machine

La fonction suivante analyse le nom de l’ordinateur.
```
function TargetOUFromComputerName {
```

Elle reçoit le nom de la machine en paramètre.
```
param(  
    [string]$ComputerName  
)
```

---

### Vérification du format du nom

Le script utilise une **expression régulière (Regex)**.
```
if ($ComputerName -match '^[A-Z]+-([A-Z0-9]+)-\d+$')
```

Format attendu :
```
PC-DEV-001
```

La regex extrait le **code du service**.

---

### Extraction du code service

```
$code = $matches[1]
```

Exemple :
```
PC-ASR-014
```

Code récupéré :
```
ASR
```

---

### Recherche dans la table de correspondance

```
if ($OUMap.ContainsKey($code)) {  
    return $OUMap[$code]  
}
```

Si le code existe dans le mapping, l’OU correspondante est renvoyée.

---

# 9. Boucle de traitement des ordinateurs

La boucle traite chaque ordinateur trouvé.

`foreach ($Computer in $Computers)`

Pour chaque machine :
1. récupération du nom
2. récupération du DN actuel
3. calcul de l’OU cible

```
$ComputerName = $Computer.Name  
$CurrentDN = $Computer.DistinguishedName  
$TargetOU = TargetOUFromComputerName -ComputerName $ComputerName
```

---

### Vérification de l’OU cible

if ($TargetOU)

Si une correspondance est trouvée :
```
Write-Host "$ComputerName serait envoyer vers $TargetOU"
```

Sinon :
```
Write-Host "$ComputerName n'a pas de correspondance dans le mapping"
```

---

# 10. Mode simulation et déplacement réel

Actuellement, le script fonctionne en **mode simulation**.

Il affiche simplement les déplacements qui seraient réalisés.
```
Write-Host "$ComputerName serait envoyer vers $TargetOU"
```

---

### Activation du déplacement réel

Pour activer le déplacement automatique, il suffit de décommenter la ligne suivante :
```
Move-ADObject -Identity $CurrentDN -TargetPath $TargetOU
```

La commande :
```
Move-ADObject
```

permet de déplacer un objet dans Active Directory.

---

# 11. Exemple de sortie du script

Exemple d’exécution :

```
PC-DEV-001 est envoyer vers OU=DEV,OU=BilluComputers,DC=billu,DC=lan  
PC-ASR-014 est envoyer vers OU=ADMINISTRATION_SYSTEMES_RESEAUX,OU=DSI,OU=BilluComputers,DC=billu,DC=lan  
PC-FIN-002 est envoyer vers OU=FINANCE,OU=COMPTABILITE,OU=BilluComputers,DC=billu,DC=lan  
PC-TEST-001 n'a pas de correspondance dans le mapping
```
