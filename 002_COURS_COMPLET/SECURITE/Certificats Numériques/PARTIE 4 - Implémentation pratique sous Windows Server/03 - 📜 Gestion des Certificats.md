

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

## 🎫 Demande et Émission de Certificats

### 📋 Comprendre le cycle de vie d'une demande

Le processus de demande et d'émission d'un certificat suit un workflow structuré qui garantit la sécurité et la traçabilité de chaque certificat émis.

```
Demandeur → Génère CSR → Soumet à la CA → Validation → Émission → Déploiement
```

> [!info] Pourquoi ce processus est important Chaque étape du workflow assure que seules les entités légitimes reçoivent des certificats, et permet un audit complet de tous les certificats émis dans l'infrastructure.

### 🔑 Types de demandes de certificats

#### 1. Demande via l'interface graphique (MMC)

**Méthode la plus simple pour les administrateurs :**

1. Ouvrir `certmgr.msc` (certificats utilisateur) ou `certlm.msc` (certificats machine)
2. Clic droit sur **Personnel** → **Toutes les tâches** → **Demander un nouveau certificat**
3. Sélectionner le modèle approprié
4. Remplir les informations requises
5. Soumettre la demande

> [!example] Exemple pratique Pour demander un certificat de serveur web :
> 
> - Ouvrir `certlm.msc` sur le serveur web
> - Personnel → Demander un nouveau certificat
> - Choisir "Serveur Web" ou "Ordinateur"
> - Spécifier le nom DNS (ex: www.entreprise.local)

#### 2. Demande via Certreq (ligne de commande)

**Pour l'automatisation et les scénarios avancés :**

```powershell
# Créer un fichier de configuration de demande (request.inf)
[NewRequest]
Subject = "CN=serveur01.entreprise.local,OU=IT,O=Entreprise,L=Paris,C=FR"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = FALSE
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1 ; Server Authentication
OID=1.3.6.1.5.5.7.3.2 ; Client Authentication

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=serveur01.entreprise.local&"
_continue_ = "dns=www.entreprise.local&"
_continue_ = "dns=mail.entreprise.local"
```

```powershell
# Générer la demande de certificat (CSR)
certreq -new request.inf request.csr

# Soumettre la demande à la CA
certreq -submit -config "CA-SERVER\Entreprise-CA" request.csr cert.cer

# Installer le certificat émis
certreq -accept cert.cer
```

> [!tip] Astuce avancée Utilisez `certreq -dump request.csr` pour vérifier le contenu de votre CSR avant de le soumettre. Cela permet de détecter les erreurs de configuration.

#### 3. Demande via PowerShell

**Méthode moderne et scriptable :**

```powershell
# Demander un certificat depuis un modèle
Get-Certificate -Template "WebServer" `
                -DnsName "www.entreprise.local","api.entreprise.local" `
                -SubjectName "CN=www.entreprise.local,OU=IT,O=Entreprise" `
                -CertStoreLocation "Cert:\LocalMachine\My"

# Avec spécification de la CA
$params = @{
    Template = "WebServer"
    Url = "https://ca-server.entreprise.local/certsrv"
    DnsName = @("web01.entreprise.local", "www.entreprise.local")
    SubjectName = "CN=web01.entreprise.local"
    CertStoreLocation = "Cert:\LocalMachine\My"
}
Get-Certificate @params
```

> [!warning] Attention aux permissions Pour demander des certificats machine, le script PowerShell doit être exécuté avec des privilèges administrateur.

#### 4. Demande via l'interface Web (ADCS Web Enrollment)

**Pour les utilisateurs distants ou non-domaine :**

```
https://ca-server.entreprise.local/certsrv
```

Étapes :

1. Accéder à l'URL de la CA
2. S'authentifier (Kerberos ou Basic Auth)
3. Sélectionner "Demander un certificat"
4. Choisir le type de certificat
5. Télécharger le certificat émis

> [!info] Configuration requise Le service Web Enrollment doit être installé via le rôle ADCS et configuré dans IIS avec l'authentification appropriée.

### 📝 Anatomie d'une demande de certificat (CSR)

Une CSR (Certificate Signing Request) contient :

|Champ|Description|Exemple|
|---|---|---|
|**Subject (DN)**|Identité du demandeur|CN=serveur01.entreprise.local,OU=IT,O=Entreprise|
|**Clé publique**|Clé publique à certifier|RSA 2048 bits|
|**Extensions**|Informations supplémentaires|SAN (Subject Alternative Names)|
|**Signature**|Preuve de possession de la clé privée|Signature avec la clé privée|

```bash
# Examiner une CSR
certutil -dump request.csr
```

### 🎯 Processus d'émission côté CA

Lorsqu'une demande arrive à la CA :

1. **Validation de la requête** : Format PKCS#10 valide, signature correcte
2. **Vérification des permissions** : Le demandeur a-t-il le droit d'utiliser ce modèle ?
3. **Application du modèle** : Extensions, durée de validité, usage de clé
4. **Génération du certificat** : Signature avec la clé privée de la CA
5. **Stockage** : Enregistrement dans la base de données de la CA
6. **Publication** : Publication dans Active Directory (si configuré)

> [!example] Vérification des certificats émis
> 
> ```powershell
> # Lister tous les certificats émis
> certutil -view -restrict "Disposition=20" -out "CommonName,SerialNumber,NotAfter"
> 
> # Filtrer par modèle
> certutil -view -restrict "CertificateTemplate=WebServer,Disposition=20"
> ```

### 🔐 Paramètres clés de génération

**Longueur de clé :**

- RSA 2048 bits : Standard actuel
- RSA 4096 bits : Sécurité renforcée (plus lent)
- ECC 256 bits : Alternative moderne (équivalent RSA 3072)

**Algorithme de hachage :**

- SHA-256 : Standard actuel
- SHA-384/512 : Pour sécurité accrue
- ~~SHA-1~~ : Obsolète, à éviter

**KeyUsage (usage de la clé) :**

- `Digital Signature` : Pour signatures numériques
- `Key Encipherment` : Pour chiffrement de clés
- `Data Encipherment` : Pour chiffrement de données
- `Key Agreement` : Pour échange de clés

**Extended Key Usage (EKU) :**

- `Server Authentication` (1.3.6.1.5.5.7.3.1) : Serveurs SSL/TLS
- `Client Authentication` (1.3.6.1.5.5.7.3.2) : Authentification client
- `Code Signing` (1.3.6.1.5.5.7.3.3) : Signature de code
- `Email Protection` (1.3.6.1.5.5.7.3.4) : S/MIME

> [!warning] Pièges courants
> 
> - **Clé non-exportable** : Si vous devez migrer le certificat, pensez à le rendre exportable lors de la demande
> - **SAN manquants** : Les navigateurs modernes vérifient les SAN, pas seulement le CN
> - **Mauvais stockage** : Les certificats serveur vont dans `LocalMachine\My`, pas `CurrentUser\My`

---

## ⚙️ Approbation Manuelle vs Automatique

### 🤖 Comprendre les modes d'approbation

La CA peut traiter les demandes de certificats de deux manières distinctes, chacune adaptée à des besoins de sécurité différents.

```
Demande → Mode Auto → Émission immédiate
Demande → Mode Manuel → Attente approbation → Émission
```

> [!info] Choix du mode Le mode d'approbation est défini au niveau du **modèle de certificat**, pas au niveau de la CA elle-même. Cela permet une gestion granulaire selon le type de certificat.

### 🔄 Approbation automatique

**Fonctionnement :** Dès que la CA reçoit une demande valide pour un modèle configuré en approbation automatique, elle émet immédiatement le certificat sans intervention humaine.

**Avantages :**

- Déploiement rapide et automatisé
- Pas d'intervention administrative
- Idéal pour l'auto-inscription via GPO
- Scalabilité pour des milliers de postes

**Cas d'usage :**

- Certificats d'ordinateurs du domaine
- Certificats d'authentification utilisateur
- Certificats de chiffrement de disque (BitLocker)
- Certificats de session RDP

**Configuration :**

```powershell
# Vérifier le mode d'approbation d'un modèle
certutil -v -template "Ordinateur"

# Rechercher "msPKI-Enrollment-Flag" :
# 0 = Approbation manuelle requise
# Autres valeurs avec bit approprié = Auto-approbation
```

> [!example] Configuration d'un modèle en auto-approbation Via la console CA :
> 
> 1. Ouvrir `certtmpl.msc`
> 2. Dupliquer le modèle "Ordinateur"
> 3. Onglet **Traitement de la demande** : Décocher "L'approbation de l'administrateur de certificats est requise"
> 4. Onglet **Sécurité** : Donner "Lire" et "Inscription" aux groupes appropriés
> 5. Publier le modèle sur la CA

### ✋ Approbation manuelle

**Fonctionnement :** Les demandes sont mises en attente dans une file d'attente. Un administrateur doit examiner et approuver ou refuser chaque demande individuellement.

**Avantages :**

- Contrôle humain sur chaque émission
- Vérification de l'identité du demandeur
- Idéal pour certificats sensibles
- Traçabilité accrue

**Cas d'usage :**

- Certificats d'administrateur
- Certificats de signature de code
- Certificats de serveurs critiques
- Certificats externes (partenaires, fournisseurs)

**Configuration :**

```powershell
# Activer l'approbation manuelle sur un modèle
# Via certtmpl.msc → Propriétés du modèle
# Onglet "Traitement de la demande"
# ☑ Cocher "L'approbation de l'administrateur de certificats est requise"
```

### 📊 Gestion de la file d'attente des demandes

**Via l'interface graphique (certsrv.msc) :**

1. Ouvrir la console Autorité de certification
2. Développer la CA → **Demandes en attente**
3. Clic droit sur une demande → **Toutes les tâches**
    - **Émettre** : Approuver et émettre le certificat
    - **Refuser** : Rejeter la demande
    - **Propriétés** : Examiner les détails

**Via la ligne de commande :**

```powershell
# Lister toutes les demandes en attente
certutil -view -restrict "Disposition=9" -out "RequestID,RequesterName,CommonName,Request.StatusCode"

# Approuver une demande spécifique
certutil -resubmit 1234
# Où 1234 est l'ID de la demande

# Refuser une demande
certutil -deny 1234
```

**Via PowerShell (plus flexible) :**

```powershell
# Fonction pour approuver des demandes
function Approve-PendingRequest {
    param(
        [Parameter(Mandatory=$true)]
        [int]$RequestID,
        [string]$CAName = "Entreprise-CA"
    )
    
    certutil -config $CAName -resubmit $RequestID
}

# Fonction pour lister et filtrer les demandes
function Get-PendingRequests {
    param([string]$Filter = "")
    
    $output = certutil -view -restrict "Disposition=9" -out "RequestID,RequesterName,CommonName,DistinguishedName" csv
    $output | ConvertFrom-Csv | Where-Object { $_.CommonName -like "*$Filter*" }
}

# Exemple : Approuver toutes les demandes d'un utilisateur spécifique
Get-PendingRequests | Where-Object { $_.RequesterName -like "*jdupont*" } | 
    ForEach-Object { Approve-PendingRequest -RequestID $_.RequestID }
```

### 📋 Workflow d'approbation recommandé

Pour les certificats nécessitant une approbation manuelle, suivez ce processus :

1. **Notification** : Configurer des alertes email pour les nouvelles demandes
2. **Vérification** : Examiner l'identité du demandeur et la légitimité de la demande
3. **Validation** : Vérifier que les informations du certificat sont correctes
4. **Approbation** : Émettre le certificat
5. **Notification** : Informer le demandeur que son certificat est disponible

> [!tip] Automatisation partielle Vous pouvez créer un script PowerShell qui :
> 
> - Envoie un email à l'équipe de sécurité pour chaque nouvelle demande en attente
> - Vérifie certains critères automatiquement (par exemple, appartenance à un groupe AD)
> - Approuve automatiquement si tous les critères sont remplis, sinon alerte un humain

### 📊 Tableau comparatif

|Critère|Approbation automatique|Approbation manuelle|
|---|---|---|
|**Rapidité**|Instantanée|Délai variable (heures/jours)|
|**Scalabilité**|Excellente (milliers/jour)|Limitée par ressources humaines|
|**Sécurité**|Dépend des permissions AD|Contrôle humain supplémentaire|
|**Charge admin**|Nulle|Élevée|
|**Traçabilité**|Logs automatiques|Logs + décision humaine|
|**Cas d'usage**|Certificats standards|Certificats sensibles/critiques|

> [!warning] Erreurs fréquentes
> 
> - **Tout en auto-approbation** : Même les certificats admin, ce qui réduit la sécurité
> - **Tout en manuel** : Engorgement de la file d'attente et frustration des utilisateurs
> - **Pas de notification** : Demandes en attente pendant des jours sans que personne ne le sache
> - **Pas de SLA défini** : Les utilisateurs ne savent pas combien de temps attendre

### 🔐 Bonnes pratiques

1. **Segmentation par sensibilité** :
    
    - Auto : Postes de travail, authentification basique
    - Manuel : Administrateurs, serveurs critiques, signature de code
2. **Notifications automatiques** :
    
    ```powershell
    # Script à exécuter via tâche planifiée (toutes les heures)
    $pending = certutil -view -restrict "Disposition=9" -out "RequestID" csv | 
                ConvertFrom-Csv
    
    if ($pending.Count -gt 0) {
        Send-MailMessage -To "admins@entreprise.local" `
                         -Subject "[$($pending.Count)] demandes de certificat en attente" `
                         -Body "Veuillez examiner les demandes sur CA-SERVER" `
                         -SmtpServer "smtp.entreprise.local"
    }
    ```
    
3. **Documentation du processus** :
    
    - Créer une procédure d'approbation claire
    - Définir les critères d'acceptation/rejet
    - Établir des SLA (ex: approbation sous 4h ouvrées)
4. **Audit régulier** :
    
    ```powershell
    # Vérifier les approbations/refus du dernier mois
    certutil -view -restrict "Request.SubmittedWhen>=now-30:00" `
             -out "RequestID,RequesterName,Disposition,Request.SubmittedWhen"
    ```
    

---

## 🔄 Renouvellement de Certificats

### ⏰ Pourquoi renouveler les certificats ?

Les certificats ont une durée de vie limitée pour des raisons de sécurité. Le renouvellement est un processus crucial pour maintenir la continuité des services.

```
Émission → Période de validité → Période de renouvellement → Expiration
         |<----- 2 ans ----->|<-- 60 jours avant -->|
```

> [!info] Durée de vie typique
> 
> - **Certificats publics** : 398 jours maximum (norme CA/Browser Forum depuis 2020)
> - **Certificats internes** : 1 à 5 ans selon la politique de l'entreprise
> - **Certificats Root/Subordinate CA** : 10 à 20 ans

### 🔄 Types de renouvellement

#### 1. Renouvellement avec la même clé

**Principe :** Réutilisation de la paire de clés existante, seul le certificat est renouvelé.

**Avantages :**

- Processus simple et rapide
- Pas besoin de redéployer la clé privée
- Utile pour des renouvellements rapides

**Inconvénients :**

- La clé privée vieillit (risque accru de compromission)
- Ne suit pas les meilleures pratiques de sécurité

**Usage :** Renouvellement de certificats CA (pour maintenir la continuité de la chaîne)

```powershell
# Renouveler avec la même clé (via certreq)
certreq -enroll -machine -cert "SerialNumber" renew reusekeys
```

#### 2. Renouvellement avec nouvelle clé

**Principe :** Génération d'une nouvelle paire de clés, nouveau certificat.

**Avantages :**

- Meilleure sécurité (nouvelle clé fraîche)
- Suit les meilleures pratiques
- Opportunité de changer la longueur de clé ou l'algorithme

**Inconvénients :**

- Nécessite la sauvegarde et le déploiement de la nouvelle clé privée
- Process plus lourd

**Usage :** Standard pour la plupart des certificats (serveurs, utilisateurs)

```powershell
# Renouveler avec nouvelle clé
certreq -enroll -machine -cert "SerialNumber" renew
```

### 🛠️ Méthodes de renouvellement

#### Via l'interface graphique (MMC)

1. Ouvrir `certmgr.msc` ou `certlm.msc`
2. Localiser le certificat dans **Personnel** → **Certificats**
3. Clic droit sur le certificat → **Toutes les tâches** → **Renouveler le certificat avec une nouvelle clé**
4. Suivre l'assistant
5. Le nouveau certificat remplace l'ancien dans le store

> [!tip] Renouvellement automatique Si le modèle de certificat a l'option "Renouvellement automatique" activée, Windows tentera de renouveler automatiquement le certificat dans la période définie.

#### Via PowerShell

```powershell
# Méthode 1 : Obtenir et renouveler un certificat spécifique
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | 
        Where-Object { $_.Subject -like "*serveur01*" }

Get-Certificate -Template "WebServer" `
                -Renew $cert `
                -CertStoreLocation "Cert:\LocalMachine\My"

# Méthode 2 : Script pour renouveler tous les certificats expirant bientôt
$threshold = (Get-Date).AddDays(30)
$certsToRenew = Get-ChildItem -Path Cert:\LocalMachine\My | 
                Where-Object { 
                    $_.NotAfter -lt $threshold -and 
                    $_.NotAfter -gt (Get-Date) 
                }

foreach ($cert in $certsToRenew) {
    try {
        Get-Certificate -Template "WebServer" `
                        -Renew $cert `
                        -CertStoreLocation "Cert:\LocalMachine\My"
        Write-Host "✅ Renouvelé : $($cert.Subject)"
    } catch {
        Write-Warning "❌ Échec renouvellement : $($cert.Subject) - $_"
    }
}
```

#### Via Certreq (ligne de commande)

```powershell
# 1. Identifier le certificat à renouveler
certutil -store My

# 2. Renouveler par numéro de série
certreq -enroll -machine -cert "1234567890abcdef" renew

# 3. Ou avec nouvelle clé
certreq -enroll -machine -cert "1234567890abcdef" renew

# 4. Pour un certificat de CA
certutil -renewCert
```

### 🔔 Surveillance et alertes d'expiration

**Script PowerShell de surveillance :**

```powershell
# Vérifier les certificats expirant dans les 30 jours
function Get-ExpiringCertificates {
    param(
        [int]$DaysBeforeExpiry = 30,
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    $threshold = (Get-Date).AddDays($DaysBeforeExpiry)
    
    $certs = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-ChildItem -Path Cert:\LocalMachine\My -Recurse | 
        Where-Object { 
            $_.NotAfter -lt $using:threshold -and 
            $_.NotAfter -gt (Get-Date) 
        } | Select-Object Subject, Thumbprint, NotAfter, Issuer
    }
    
    return $certs
}

# Générer un rapport HTML
$expiring = Get-ExpiringCertificates -DaysBeforeExpiry 30

if ($expiring) {
    $html = $expiring | ConvertTo-Html -Title "Certificats expirant" -PreContent "<h1>⚠️ Certificats expirant dans 30 jours</h1>"
    
    Send-MailMessage -To "admins@entreprise.local" `
                     -Subject "⚠️ [$($expiring.Count)] certificats à renouveler" `
                     -Body ($html | Out-String) `
                     -BodyAsHtml `
                     -SmtpServer "smtp.entreprise.local"
}
```

**Surveillance côté CA (tous les certificats émis) :**

```powershell
# Lister tous les certificats actifs expirant dans 60 jours
certutil -view -restrict "NotAfter<=now+60:00,Disposition=20" `
         -out "CommonName,SerialNumber,NotAfter,RequesterName" csv | 
         ConvertFrom-Csv | 
         Sort-Object NotAfter
```

### ⚙️ Renouvellement automatique via GPO

Pour les certificats de machines du domaine, configurez l'auto-inscription :

1. **Configuration GPO** :
    
    ```
    Computer Configuration
    → Policies
    → Windows Settings
    → Security Settings
    → Public Key Policies
    → Certificate Services Client - Auto-Enrollment
    ```
    
2. **Paramètres recommandés** :
    
    - ☑ Configuration Model: Enabled
    - ☑ Renew expired certificates, update pending certificates, and remove revoked certificates
    - ☑ Update certificates that use certificate templates
    - Taux de renouvellement : 10% (pour étaler la charge)
3. **Période de renouvellement sur le modèle** :
    
    ```powershell
    # Via certtmpl.msc → Propriétés du modèle
    # Onglet "Général" → Période de renouvellement : 6 semaines
    ```
    

> [!example] Exemple complet d'auto-inscription Pour activer l'auto-inscription des certificats machine :
> 
> 1. GPO activée (comme ci-dessus)
> 2. Modèle "Ordinateur" publié sur la CA
> 3. Permissions sur le modèle : "Domain Computers" avec Lire + Inscription
> 4. Période de renouvellement : 6 semaines avant expiration
> 
> Résultat : Tous les postes du domaine renouvellent automatiquement leur certificat 6 semaines avant expiration, sans intervention.

### 📊 Stratégie de renouvellement recommandée

|Type de certificat|Période de renouvellement|Méthode|Automatisation|
|---|---|---|---|
|**Postes de travail**|6 semaines avant expiration|GPO auto-inscription|✅ Complète|
|**Serveurs web**|30 jours avant expiration|Script PowerShell|⚙️ Semi-automatique|
|**Utilisateurs**|4 semaines avant expiration|GPO auto-inscription|✅ Complète|
|**CA subordonnée**|6 mois avant expiration|Manuel|❌ Manuel|
|**Signature de code**|60 jours avant expiration|Manuel + validation|❌ Manuel|

### 🔐 Renouvellement des certificats de CA

**CA subordonnée :**

```powershell
# Sur le serveur CA subordonnée
certutil -renewCert

# Soumettre la nouvelle demande à la Root CA
# Installer le nouveau certificat émis
certutil -installCert ca-subordinate-renewed.cer
```

**Root CA (opération critique) :**

```powershell
# Créer une sauvegarde complète AVANT !

# Renouveler le certificat de la Root CA
certutil -renewCert ReuseKeys

# Ou avec nouvelle clé (change la paire de clés de la Root CA)
certutil -renewCert
```

> [!warning] Attention critique Le renouvellement d'une Root CA avec nouvelle clé est une opération majeure :
> 
> - Tous les certificats de la chaîne devront être republiés
> - Les clients devront faire confiance au nouveau certificat Root
> - Planifiez plusieurs mois de période de transition

### 🐛 Problèmes courants et solutions

**Problème 1 : Le renouvellement automatique ne fonctionne pas**

Solution :

```powershell
# Vérifier le service de certificat
Get-Service -Name CertSvc | Restart-Service

# Forcer la mise à jour GPO
gpupdate /force

# Déclencher manuellement l'auto-inscription
certutil -pulse
```

**Problème 2 : Erreur "The request was denied by a certificate manager or CA administrator"**

Solution : Vérifier que :

- Le modèle autorise le renouvellement
- L'utilisateur/ordinateur a les permissions d'inscription
- La période de renouvellement est ouverte

**Problème 3 : Le certificat renouvelé n'a pas les mêmes propriétés**

Solution : Le modèle a peut-être changé. Vérifiez :

```powershell
certutil -v -template "NomDuModele"
```

> [!tip] Bonnes pratiques de renouvellement
> 
> 1. **Anticipez** : Ne renouvelez jamais le dernier jour !
> 2. **Testez** : Validez le nouveau certificat avant de remplacer l'ancien
> 3. **Planifiez** : Créez un calendrier de renouvellement pour les certificats critiques
> 4. **Automatisez** : Utilisez l'auto-inscription quand c'est possible
> 5. **Surveillez** : Mettez en place des alertes 60, 30 et 7 jours avant expiration
> 6. **Documentez** : Maintenez un inventaire des certificats et de leurs dates d'expiration

---

## 🚫 Révocation de Certificats

### ❓ Qu'est-ce que la révocation ?

La révocation est le processus par lequel un certificat est déclaré invalide avant sa date d'expiration naturelle. C'est l'équivalent numérique d'une annulation de carte bancaire.

```
Certificat émis → Événement de sécurité → Révocation → Liste CRL → Clients informés
```

> [!warning] Importance critique Un certificat révoqué ne doit PLUS JAMAIS être utilisé ou accepté. La révocation est irréversible et permanente. C'est une mesure de sécurité critique pour protéger l'infrastructure.

### 🎯 Raisons de révoquer un certificat

|Raison|Code CRL|Description|Urgence|
|---|---|---|---|
|**Clé compromise**|1 - Key Compromise|La clé privée a été exposée ou volée|🔴 IMMÉDIATE|
|**CA compromise**|2 - CA Compromise|La CA elle-même est compromise|🔴 IMMÉDIATE|
|**Changement d'affiliation**|3 - Affiliation Changed|L'employé a quitté l'entreprise|🟡 Rapide|
|**Remplacé**|4 - Superseded|Remplacé par un nouveau certificat|🟢 Normal|
|**Cessation d'opération**|5 - Cessation of Operation|Le service n'est plus utilisé|🟢 Normal|
|**Suspension**|6 - Certificate Hold|Suspension temporaire (peut être levée)|🟡 Rapide|

> [!info] Suspension vs Révocation permanente La suspension (Certificate Hold) est le SEUL code de révocation réversible. Tous les autres sont permanents et irréversibles.

### 🛠️ Méthodes de révocation

#### 1. Via l'interface graphique (certsrv.msc)

**Processus standard :**

1. Ouvrir la console **Autorité de certification**
2. Développer la CA → **Certificats émis**
3. Localiser le certificat à révoquer
4. Clic droit → **Toutes les tâches** → **Révoquer le certificat**
5. Sélectionner la raison de révocation
6. Cliquer sur **Oui** pour confirmer

> [!example] Cas pratique : Employé quittant l'entreprise
> 
> 1. Identifier tous ses certificats (recherche par nom)
> 2. Les révoquer un par un avec raison "Affiliation Changed"
> 3. Publier une nouvelle CRL
> 4. Désactiver son compte AD

#### 2. Via Certutil (ligne de commande)

```powershell
# Révoquer un certificat par numéro de série
certutil -revoke "1234567890abcdef" 3
# 3 = Affiliation Changed

# Révoquer avec raison "Key Compromise"
certutil -revoke "1234567890abcdef" 1

# Révoquer tous les certificats d'un utilisateur
# 1. Trouver les certificats
certutil -view -restrict "RequesterName=DOMAIN\jdupont,Disposition=20" -out "SerialNumber"

# 2. Les révoquer (script)
$serials = certutil -view -restrict "RequesterName=DOMAIN\jdupont,Disposition=20" -out "SerialNumber" csv | 
           ConvertFrom-Csv

foreach ($cert in $serials) {
    certutil -revoke $cert.SerialNumber 3
    Write-Host "Révoqué : $($cert.SerialNumber)"
}
```

**Codes de raison de révocation :**

```powershell
# 0 = Unspecified
# 1 = Key Compromise
# 2 = CA Compromise
# 3 = Affiliation Changed
# 4 = Superseded
# 5 = Cessation of Operation
# 6 = Certificate Hold (suspension temporaire)
```

#### 3. Via PowerShell (méthode moderne)

```powershell
# Fonction pour révoquer un certificat
function Revoke-Certificate {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SerialNumber,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet('Unspecified','KeyCompromise','CACompromise',
                     'AffiliationChanged','Superseded','CessationOfOperation','CertificateHold')]
        [string]$Reason,
        
        [string]$CAConfig = "CA-SERVER\Entreprise-CA"
    )
    
    # Conversion raison en code
    $reasonCode = switch ($Reason) {
        'Unspecified' { 0 }
        'KeyCompromise' { 1 }
        'CACompromise' { 2 }
        'AffiliationChanged' { 3 }
        'Superseded' { 4 }
        'CessationOfOperation' { 5 }
        'CertificateHold' { 6 }
    }
    
    # Révocation
    certutil -config $CAConfig -revoke $SerialNumber $reasonCode
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Certificat $SerialNumber révoqué (raison: $Reason)" -ForegroundColor Green
        
        # Publier automatiquement une nouvelle CRL
        certutil -config $CAConfig -CRL
        Write-Host "📋 Nouvelle CRL publiée" -ForegroundColor Green
    } else {
        Write-Error "❌ Échec de la révocation du certificat $SerialNumber"
    }
}

# Exemple d'utilisation
Revoke-Certificate -SerialNumber "1234567890abcdef" -Reason "KeyCompromise"
```

**Script de révocation en masse :**

```powershell
# Révoquer tous les certificats d'un serveur décommissionné
function Revoke-ServerCertificates {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ServerName,
        [string]$Reason = 'CessationOfOperation'
    )
    
    # Trouver tous les certificats du serveur
    $certs = certutil -view -restrict "CommonName=*$ServerName*,Disposition=20" `
                      -out "SerialNumber,CommonName" csv | ConvertFrom-Csv
    
    Write-Host "🔍 Trouvé $($certs.Count) certificat(s) pour $ServerName"
    
    foreach ($cert in $certs) {
        Write-Host "Révocation de : $($cert.CommonName) [$($cert.SerialNumber)]"
        Revoke-Certificate -SerialNumber $cert.SerialNumber -Reason $Reason
    }
}

# Utilisation
Revoke-ServerCertificates -ServerName "web-server-old"
```

### 📋 CRL (Certificate Revocation List)

**Qu'est-ce qu'une CRL ?**

Une CRL est une liste signée numériquement contenant tous les certificats révoqués. Les clients téléchargent régulièrement cette liste pour vérifier la validité des certificats.

```
Client → Vérifie certificat → Télécharge CRL → Compare numéro série → Accepte/Rejette
```

#### Configuration de la CRL

**Paramètres de publication :**

```powershell
# Afficher la configuration CRL actuelle
certutil -getreg CA\CRLPeriod
certutil -getreg CA\CRLPeriodUnits

# Définir la période de validité de la CRL (7 jours)
certutil -setreg CA\CRLPeriod "Days"
certutil -setreg CA\CRLPeriodUnits 7

# Définir la période de chevauchement Delta CRL
certutil -setreg CA\CRLDeltaPeriod "Hours"
certutil -setreg CA\CRLDeltaPeriodUnits 1

# Redémarrer le service pour appliquer
Restart-Service CertSvc

# Publier une nouvelle CRL manuellement
certutil -CRL
```

**Emplacements de publication CRL :**

```powershell
# Voir les points de distribution CRL configurés
certutil -getreg CA\CRLPublicationURLs

# Exemple de sortie :
# 1:C:\Windows\system32\CertSrv\CertEnroll\%3%8.crl
# 2:http://ca-server.entreprise.local/CertEnroll/%3%8.crl
# 10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10
```

> [!info] Variables dans les URLs CRL
> 
> - `%3` = Nom de la CA
> - `%8` = Suffixe CRL
> - `%10` = Suffixe Delta CRL
> - `%6` = Distinguished Name du domaine

#### Types de CRL

**Base CRL :**

- Contient TOUS les certificats révoqués depuis la création de la CA
- Publiée selon la période définie (généralement hebdomadaire)
- Taille augmente avec le temps

**Delta CRL :**

- Contient uniquement les révocations depuis la dernière Base CRL
- Publiée plus fréquemment (généralement horaire)
- Taille petite et constante
- Améliore les performances

```powershell
# Activer les Delta CRL
certutil -setreg CA\CRLDeltaPeriod "Hours"
certutil -setreg CA\CRLDeltaPeriodUnits 1
Restart-Service CertSvc

# Publier une Delta CRL
certutil -CRL Delta
```

**Vérification des CRL :**

```powershell
# Examiner une CRL locale
certutil -dump "C:\Windows\system32\CertSrv\CertEnroll\Entreprise-CA.crl"

# Télécharger et examiner une CRL depuis HTTP
certutil -URL "http://ca-server.entreprise.local/CertEnroll/Entreprise-CA.crl"

# Voir les certificats révoqués dans la CRL
certutil -dump "C:\Windows\system32\CertSrv\CertEnroll\Entreprise-CA.crl" | 
    Select-String -Pattern "Serial Number:"
```

### 🌐 OCSP (Online Certificate Status Protocol)

**Alternative moderne à la CRL :**

OCSP permet une vérification en temps réel du statut d'un certificat sans télécharger une liste complète.

```
Client → Requête OCSP → Serveur OCSP → Réponse (Good/Revoked/Unknown)
```

**Avantages vs CRL :**

- ✅ Réponse en temps réel
- ✅ Bande passante réduite (pas de téléchargement de liste)
- ✅ Confidentialité améliorée (OCSP Stapling)
- ❌ Nécessite un service supplémentaire (OCSP Responder)

**Installation du rôle OCSP :**

```powershell
# Installer le rôle OCSP Responder
Install-WindowsFeature -Name ADCS-Online-Cert -IncludeManagementTools

# Configuration via GUI ou PowerShell
# Nécessite un certificat de signature OCSP
```

> [!tip] OCSP Stapling Avec OCSP Stapling, le serveur web récupère la réponse OCSP et la "agrafe" au certificat lors du handshake TLS, éliminant le besoin pour le client de contacter le serveur OCSP.

### 🔍 Vérification du statut de révocation

**Vérifier si un certificat est révoqué :**

```powershell
# Méthode 1 : Via la console CA
certutil -view -restrict "SerialNumber=1234567890abcdef" -out "Disposition"
# Disposition = 21 signifie révoqué

# Méthode 2 : Vérifier dans la CRL
certutil -URL "C:\chemin\vers\certificat.cer"
# Affiche le statut et les points de distribution CRL/OCSP

# Méthode 3 : PowerShell avec System.Security.Cryptography
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("certificat.cer")
$chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
$chain.ChainPolicy.RevocationMode = "Online"
$chain.ChainPolicy.RevocationFlag = "EntireChain"
$isValid = $chain.Build($cert)

if (-not $isValid) {
    $chain.ChainStatus | Format-Table Status, StatusInformation
}
```

**Lister tous les certificats révoqués :**

```powershell
# Via certutil
certutil -view -restrict "Disposition=21" -out "SerialNumber,CommonName,RevokedWhen,RevokedReason"

# Exporter en CSV pour analyse
certutil -view -restrict "Disposition=21" `
         -out "SerialNumber,CommonName,RequesterName,RevokedWhen,RevokedReason" csv | 
         Out-File "certificats-revoques.csv"
```

### ⏸️ Suspension et réactivation

**Suspendre un certificat (Certificate Hold) :**

```powershell
# Suspension temporaire
certutil -revoke "1234567890abcdef" 6

# Publier la CRL
certutil -CRL
```

**Réactiver un certificat suspendu :**

```powershell
# Lever la suspension (ATTENTION : fonctionne UNIQUEMENT pour Certificate Hold)
certutil -view -restrict "SerialNumber=1234567890abcdef"
# Vérifier que Disposition = 21 et Reason = 6 (Certificate Hold)

# La réactivation se fait via des commandes certutil avancées ou l'interface
# IMPORTANT : Ceci n'est possible QUE si le code de révocation était 6 (Certificate Hold)
```

> [!warning] Limitation importante Seuls les certificats révoqués avec le code 6 (Certificate Hold) peuvent être réactivés. Tous les autres codes de révocation sont PERMANENTS et IRRÉVERSIBLES.

### 📊 Bonnes pratiques de révocation

**1. Procédure de révocation d'urgence :**

```powershell
# Script d'urgence pour compromission de clé
function Emergency-RevokeCompromised {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SerialNumber
    )
    
    Write-Host "🚨 RÉVOCATION D'URGENCE EN COURS" -ForegroundColor Red
    
    # 1. Révocation immédiate
    certutil -revoke $SerialNumber 1  # Key Compromise
    
    # 2. Publication CRL immédiate
    certutil -CRL
    
    # 3. Notification
    Send-MailMessage -To "security@entreprise.local" `
                     -Subject "🚨 ALERTE: Certificat révoqué (Key Compromise)" `
                     -Body "Certificat $SerialNumber révoqué pour compromission de clé" `
                     -Priority High
    
    Write-Host "✅ Révocation terminée et CRL publiée" -ForegroundColor Green
}
```

**2. Automatisation de révocation pour départs :**

```powershell
# Hook dans le processus de départ d'employé
function Revoke-EmployeeCertificates {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    Write-Host "🔍 Recherche des certificats de $Username..."
    
    $certs = certutil -view -restrict "RequesterName=*$Username*,Disposition=20" `
                      -out "SerialNumber,CommonName,CertificateTemplate" csv | 
             ConvertFrom-Csv
    
    if ($certs.Count -eq 0) {
        Write-Host "ℹ️ Aucun certificat actif trouvé" -ForegroundColor Yellow
        return
    }
    
    Write-Host "📋 $($certs.Count) certificat(s) à révoquer"
    
    foreach ($cert in $certs) {
        Write-Host "  - $($cert.CommonName) [$($cert.CertificateTemplate)]"
        certutil -revoke $cert.SerialNumber 3  # Affiliation Changed
    }
    
    # Publication CRL
    certutil -CRL
    
    # Log et notification
    $logEntry = @{
        Date = Get-Date
        User = $Username
        CertificatesRevoked = $certs.Count
        Action = "Employee Departure"
    }
    
    $logEntry | Export-Csv "C:\Logs\Revocations.csv" -Append -NoTypeInformation
    
    Write-Host "✅ Tous les certificats révoqués" -ForegroundColor Green
}
```

**3. Surveillance des révocations :**

```powershell
# Rapport hebdomadaire des révocations
$lastWeek = (Get-Date).AddDays(-7)
$revoked = certutil -view -restrict "RevokedWhen>=$($lastWeek.ToString('yyyy-MM-dd')),Disposition=21" `
                    -out "CommonName,RevokedWhen,RevokedReason,RequesterName" csv | 
           ConvertFrom-Csv

$html = $revoked | ConvertTo-Html -Title "Révocations hebdomadaires" `
                                   -PreContent "<h2>Certificats révoqués la semaine dernière</h2>"

Send-MailMessage -To "admins@entreprise.local" `
                 -Subject "📊 Rapport hebdomadaire des révocations" `
                 -Body ($html | Out-String) `
                 -BodyAsHtml
```

**4. Politique de révocation :**

|Événement|Délai de révocation|Code|Action post-révocation|
|---|---|---|---|
|**Vol d'ordinateur portable**|Immédiat (< 1h)|1|Changer tous les mots de passe|
|**Départ employé**|Jour du départ|3|Désactivation compte AD|
|**Changement de rôle**|Avant changement effectif|4|Émettre nouveaux certificats|
|**Serveur décommissionné**|Avant arrêt|5|Mise à jour DNS/firewall|
|**Suspicion de compromission**|Immédiat (< 2h)|6|Investigation, puis décision|

> [!tip] Checklist de révocation
> 
> - [ ] Identifier tous les certificats concernés
> - [ ] Déterminer le code de révocation approprié
> - [ ] Révoquer les certificats
> - [ ] Publier immédiatement une nouvelle CRL
> - [ ] Notifier les parties concernées
> - [ ] Documenter la raison dans un système de ticketing
> - [ ] Émettre de nouveaux certificats si nécessaire
> - [ ] Vérifier que les services continuent de fonctionner

### 🐛 Problèmes courants

**Problème 1 : CRL non accessible**

```powershell
# Symptôme : Les clients ne peuvent pas vérifier les révocations
# Solution : Vérifier l'accessibilité des URLs CRL

# Test HTTP
Invoke-WebRequest -Uri "http://ca-server.entreprise.local/CertEnroll/Entreprise-CA.crl"

# Test LDAP
certutil -URL ldap:///CN=Entreprise-CA,CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,DC=entreprise,DC=local
```

**Problème 2 : CRL expirée**

```powershell
# Symptôme : Erreur "The revocation function was unable to check revocation"
# Solution : Publier une nouvelle CRL

certutil -CRL

# Vérifier la date d'expiration
certutil -dump "C:\Windows\system32\CertSrv\CertEnroll\Entreprise-CA.crl" | 
    Select-String -Pattern "NextUpdate"
```

**Problème 3 : Certificat révoqué mais toujours accepté**

```powershell
# Causes possibles :
# 1. Cache du client pas rafraîchi
certutil -urlcache * delete  # Vider le cache CRL local

# 2. Vérification de révocation désactivée
# Vérifier la GPO : "Computer Configuration → Windows Settings → Security Settings → Public Key Policies → Certificate Path Validation Settings"

# 3. CRL pas encore propagée
# Attendre la prochaine période de rafraîchissement ou forcer :
gpupdate /force
certutil -pulse
```

---

## 💾 Sauvegarde et Restauration de la CA

### 🎯 Importance de la sauvegarde

Une CA est un composant critique de l'infrastructure PKI. Sa perte signifie :

- ❌ Impossibilité d'émettre de nouveaux certificats
- ❌ Impossibilité de révoquer des certificats compromis
- ❌ Perte de confiance de tous les certificats émis
- ❌ Reconstruction complète de la PKI (jours/semaines de travail)

> [!warning] Criticité La sauvegarde régulière de la CA n'est pas optionnelle. C'est une obligation pour maintenir la continuité des services et la sécurité de l'infrastructure.

### 📦 Éléments à sauvegarder

Une sauvegarde complète de la CA doit inclure :

|Élément|Localisation|Importance|Fréquence|
|---|---|---|---|
|**Clé privée CA**|Stockage protégé|🔴 CRITIQUE|Chaque modification|
|**Certificat CA**|Base de registre|🔴 CRITIQUE|Chaque modification|
|**Base de données CA**|`%SystemRoot%\System32\CertLog`|🔴 CRITIQUE|Quotidienne|
|**Configuration CA**|Registre|🟡 Important|Hebdomadaire|
|**Modèles de certificats**|Active Directory|🟡 Important|Après chaque modif|
|**CRL**|`%SystemRoot%\System32\CertSrv\CertEnroll`|🟢 Utile|Quotidienne|

### 🛠️ Méthodes de sauvegarde

#### 1. Sauvegarde via l'interface graphique

**Processus complet :**

1. Ouvrir **certsrv.msc**
2. Clic droit sur le nom de la CA → **Toutes les tâches** → **Sauvegarder la CA**
3. Suivre l'assistant :
    - **Clé privée et certificat CA** : ✅ OBLIGATOIRE
    - **Base de données et journal de la base de données des certificats** : ✅ OBLIGATOIRE
    - **Effectuer une sauvegarde incrémentielle** : Selon besoin
4. Spécifier le dossier de destination (préférablement sur un autre volume/serveur)
5. Entrer un mot de passe fort pour protéger la clé privée
6. Cliquer sur **Terminer**

> [!tip] Mot de passe de sauvegarde Stockez le mot de passe de sauvegarde dans un coffre-fort sécurisé (physique ou numérique comme Azure Key Vault). Sans ce mot de passe, la restauration sera impossible !

#### 2. Sauvegarde via Certutil (ligne de commande)

```powershell
# Créer le dossier de sauvegarde
$backupPath = "D:\Backups\CA\$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
New-Item -Path $backupPath -ItemType Directory -Force

# Arrêter le service CA (obligatoire pour backup cohérent)
Stop-Service CertSvc

# Sauvegarde complète (base de données + clé privée)
certutil -backup $backupPath
# Entrer le mot de passe quand demandé

# Ou en mode silencieux avec fichier de mot de passe
$password = ConvertTo-SecureString "MotDePasseTresComplexe123!" -AsPlainText -Force
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Créer un fichier de config pour backup automatisé
@"
[Backup]
BackupPath=$backupPath
Password=$plainPassword
"@ | Out-File "$env:TEMP\backup-config.txt"

certutil -backupkey $backupPath -p "$plainPassword"
certutil -backupdb $backupPath

# Redémarrer le service
Start-Service CertSvc

# Nettoyer le fichier de mot de passe
Remove-Item "$env:TEMP\backup-config.txt" -Force
```

**Sauvegarde séparée de la clé privée :**

```powershell
# Sauvegarder UNIQUEMENT la clé privée et le certificat CA
certutil -backupkey "D:\Backups\CA-Key\$(Get-Date -Format 'yyyy-MM-dd')"

# Protection additionnelle : chiffrer le backup avec BitLocker ou EFS
cipher /E "D:\Backups\CA-Key"
```

#### 3. Script PowerShell de sauvegarde automatisée

```powershell
<#
.SYNOPSIS
    Script de sauvegarde automatisée de l'Autorité de Certification
.DESCRIPTION
    Effectue une sauvegarde complète de la CA, vérifie l'intégrité,
    et envoie une notification par email.
#>

function Backup-CertificationAuthority {
    param(
        [Parameter(Mandatory=$true)]
        [string]$BackupPath,
        
        [Parameter(Mandatory=$true)]
        [SecureString]$Password,
        
        [int]$RetentionDays = 90,
        
        [string]$EmailTo = "admins@entreprise.local",
        [string]$SmtpServer = "smtp.entreprise.local"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
    $fullBackupPath = Join-Path $BackupPath $timestamp
    $logFile = Join-Path $BackupPath "backup-log.txt"
    
    # Fonction de logging
    function Write-Log {
        param([string]$Message)
        $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
        Add-Content -Path $logFile -Value $logMessage
        Write-Host $logMessage
    }
    
    try {
        Write-Log "🚀 Démarrage de la sauvegarde CA"
        
        # 1. Créer le dossier de backup
        New-Item -Path $fullBackupPath -ItemType Directory -Force | Out-Null
        Write-Log "📁 Dossier créé : $fullBackupPath"
        
        # 2. Arrêter le service CA
        Write-Log "⏸️ Arrêt du service Certificate Services"
        Stop-Service CertSvc -Force
        Start-Sleep -Seconds 5
        
        # 3. Convertir le SecureString password
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        # 4. Sauvegarde de la base de données
        Write-Log "💾 Sauvegarde de la base de données CA"
        $dbBackup = certutil -backupdb $fullBackupPath
        if ($LASTEXITCODE -ne 0) {
            throw "Échec de la sauvegarde de la base de données"
        }
        
        # 5. Sauvegarde de la clé privée
        Write-Log "🔑 Sauvegarde de la clé privée et certificat CA"
        $keyBackup = certutil -backupkey $fullBackupPath -p $plainPassword
        if ($LASTEXITCODE -ne 0) {
            throw "Échec de la sauvegarde de la clé privée"
        }
        
        # 6. Sauvegarder la configuration du registre
        Write-Log "⚙️ Sauvegarde de la configuration registre"
        reg export "HKLM\SYSTEM\CurrentControlSet\Services\CertSvc" `
            "$fullBackupPath\CertSvc-Registry.reg" /y
        
        # 7. Copier les fichiers de configuration additionnels
        Copy-Item "C:\Windows\System32\CertSrv\CertEnroll\*" `
                  "$fullBackupPath\CertEnroll\" -Recurse -Force
        
        # 8. Redémarrer le service CA
        Write-Log "▶️ Redémarrage du service Certificate Services"
        Start-Service CertSvc
        Start-Sleep -Seconds 5
        
        # Vérifier que le service est bien démarré
        $service = Get-Service CertSvc
        if ($service.Status -ne 'Running') {
            throw "Le service CA n'a pas redémarré correctement"
        }
        
        # 9. Vérifier l'intégrité de la sauvegarde
        Write-Log "🔍 Vérification de l'intégrité de la sauvegarde"
        $files = Get-ChildItem -Path $fullBackupPath -Recurse
        $totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Log "📊 Taille totale de la sauvegarde : $([math]::Round($totalSize, 2)) MB"
        Write-Log "📊 Nombre de fichiers sauvegardés : $($files.Count)"
        
        # 10. Compression de la sauvegarde
        Write-Log "📦 Compression de la sauvegarde"
        $zipPath = "$fullBackupPath.zip"
        Compress-Archive -Path $fullBackupPath -DestinationPath $zipPath -CompressionLevel Optimal
        
        # 11. Nettoyer les anciennes sauvegardes
        Write-Log "🧹 Nettoyage des sauvegardes anciennes (>$RetentionDays jours)"
        $cutoffDate = (Get-Date).AddDays(-$RetentionDays)
        Get-ChildItem -Path $BackupPath -Directory | 
            Where-Object { $_.CreationTime -lt $cutoffDate } |
            ForEach-Object {
                Write-Log "  Suppression : $($_.Name)"
                Remove-Item $_.FullName -Recurse -Force
            }
        
        # 12. Notification de succès
        Write-Log "✅ Sauvegarde terminée avec succès"
        
        $emailBody = @"
<h2>✅ Sauvegarde CA réussie</h2>
<p><strong>Date :</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
<p><strong>Emplacement :</strong> $zipPath</p>
<p><strong>Taille :</strong> $([math]::Round($totalSize, 2)) MB</p>
<p><strong>Nombre de fichiers :</strong> $($files.Count)</p>
<p><strong>Retention :</strong> $RetentionDays jours</p>
<p><strong>Service CA :</strong> $($service.Status)</p>
"@
        
        Send-MailMessage -To $EmailTo `
                         -Subject "✅ Sauvegarde CA - Succès ($timestamp)" `
                         -Body $emailBody `
                         -BodyAsHtml `
                         -SmtpServer $SmtpServer `
                         -From "ca-backup@entreprise.local"
        
        return $true
        
    } catch {
        Write-Log "❌ ERREUR : $_"
        
        # Tenter de redémarrer le service en cas d'erreur
        try {
            Start-Service CertSvc -ErrorAction Stop
            Write-Log "▶️ Service CA redémarré après erreur"
        } catch {
            Write-Log "🚨 CRITIQUE : Impossible de redémarrer le service CA !"
        }
        
        # Notification d'erreur
        $emailBody = @"
<h2>❌ Échec de la sauvegarde CA</h2>
<p><strong>Date :</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
<p><strong>Erreur :</strong> $($_.Exception.Message)</p>
<p><strong>Action requise :</strong> Vérifier les logs et effectuer une sauvegarde manuelle</p>
"@
        
        Send-MailMessage -To $EmailTo `
                         -Subject "❌ Sauvegarde CA - ÉCHEC" `
                         -Body $emailBody `
                         -BodyAsHtml `
                         -SmtpServer $SmtpServer `
                         -From "ca-backup@entreprise.local" `
                         -Priority High
        
        return $false
    }
}

# Exemple d'utilisation
$securePassword = ConvertTo-SecureString "MonMotDePasseBackup2024!" -AsPlainText -Force

Backup-CertificationAuthority -BackupPath "D:\Backups\CA" `
                               -Password $securePassword `
                               -RetentionDays 90
```

**Configuration en tâche planifiée :**

```powershell
# Créer une tâche planifiée pour backup quotidien à 2h du matin
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\Backup-CA.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" `
    -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "Backup CA Quotidien" `
                       -Action $action `
                       -Trigger $trigger `
                       -Principal $principal `
                       -Description "Sauvegarde automatique de l'Autorité de Certification"
```

### 🔄 Restauration de la CA

#### Scénarios de restauration

**Scénario 1 : Restauration sur le même serveur (crash système)**

```powershell
# 1. Réinstaller le rôle ADCS si nécessaire
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

# 2. Restaurer la CA via l'interface
# certsrv.msc → Clic droit sur CA → Toutes les tâches → Restaurer la CA

# 3. Ou via ligne de commande
certutil -restoredb "D:\Backups\CA\2024-12-30-020000"
certutil -restorekey "D:\Backups\CA\2024-12-30-020000"

# 4. Démarrer le service
Start-Service CertSvc
```

**Scénario 2 : Migration vers nouveau serveur**

```powershell
# Sur le nouveau serveur :

# 1. Installer le rôle ADCS
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

# 2. NE PAS configurer la CA (elle sera restaurée)

# 3. Arrêter le service CA (s'il tourne)
Stop-Service CertSvc

# 4. Restaurer la base de données
certutil -restoredb "\\old-server\backup\CA\2024-12-30"

# 5. Restaurer la clé privée (nécessite le mot de passe de sauvegarde)
certutil -restorekey "\\old-server\backup\CA\2024-12-30"

# 6. Importer la configuration du registre
reg import "\\old-server\backup\CA\2024-12-30\CertSvc-Registry.reg"

# 7. Copier les fichiers CertEnroll
Copy-Item "\\old-server\backup\CA\2024-12-30\CertEnroll\*" `
          "C:\Windows\System32\CertSrv\CertEnroll\" -Recurse -Force

# 8. Mettre à jour les URLs de distribution dans AD
certutil -setreg CA\CRLPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl\n2:http://nouveau-serveur.entreprise.local/CertEnroll/%3%8%9.crl\n10:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10"

certutil -setreg CA\CACertPublicationURLs "1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt\n2:http://nouveau-serveur.entreprise.local/CertEnroll/%1_%3%4.crt\n2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11"

# 9. Redémarrer le service
Start-Service CertSvc

# 10. Publier une nouvelle CRL depuis le nouveau serveur
certutil -CRL

# 11. Vérifier le statut
certutil -ping
```

> [!warning] Attention DNS Lors d'une migration, assurez-vous que les enregistrements DNS pointent vers le nouveau serveur, ou conservez le même nom d'hôte pour éviter les problèmes de validation des URLs CRL/AIA.

**Scénario 3 : Restauration partielle (base de données uniquement)**

```powershell
# Restaurer uniquement la base de données (sans la clé privée)
# Utile en cas de corruption de la base de données

Stop-Service CertSvc
certutil -restoredb "D:\Backups\CA\2024-12-30-020000"
Start-Service CertSvc
```

#### Vérifications post-restauration

```powershell
# 1. Vérifier que le service fonctionne
Get-Service CertSvc

# 2. Tester l'émission d'un certificat
certreq -submit test-request.csr test-cert.cer

# 3. Vérifier la base de données
certutil -view -restrict "Disposition=20" | Select-Object -First 10

# 4. Vérifier les URLs CRL/AIA
certutil -getreg CA\CRLPublicationURLs
certutil -getreg CA\CACertPublicationURLs

# 5. Tester l'accès HTTP aux CRL
Invoke-WebRequest "http://ca-server.entreprise.local/CertEnroll/"

# 6. Publier une CRL de test
certutil -CRL
```

### 🔐 Sécurisation des sauvegardes

**Bonnes pratiques critiques :**

1. **Chiffrement** :

```powershell
# Chiffrer le dossier de backup avec EFS
cipher /E "D:\Backups\CA"

# Ou avec BitLocker pour le volume complet
Enable-BitLocker -MountPoint "D:" -EncryptionMethod XtsAes256
```

2. **Stockage hors site** :

```powershell
# Copier les backups vers un emplacement distant
$destination = "\\backup-server\CA-Backups$"
$source = "D:\Backups\CA\$(Get-Date -Format 'yyyy-MM-dd')*"

Copy-Item $source $destination -Recurse -Force

# Ou vers le cloud (Azure Storage, AWS S3, etc.)
# Exemple avec Azure Storage
$storageAccount = "cabackups"
$storageKey = "votre-cle-acces"
$containerName = "ca-backups"

# Upload vers Azure Blob Storage (nécessite Az.Storage module)
$ctx = New-AzStorageContext -StorageAccountName $storageAccount -StorageAccountKey $storageKey
Set-AzStorageBlobContent -File $source -Container $containerName -Context $ctx
```

3. **Contrôle d'accès strict** :

```powershell
# Permissions NTFS restrictives sur le dossier de backup
$acl = Get-Acl "D:\Backups\CA"
$acl.SetAccessRuleProtection($true, $false)  # Désactiver l'héritage

# Ajouter uniquement les admins CA
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAIN\CA-Admins",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl "D:\Backups\CA" $acl
```

4. **Test régulier de restauration** :

```powershell
# Script de test de restauration (sur VM de test)
# À exécuter mensuellement pour valider les backups

function Test-CABackupRestore {
    param([string]$BackupPath)
    
    Write-Host "🧪 Test de restauration CA depuis $BackupPath"
    
    # 1. Créer un snapshot de la VM avant test
    # (commande spécifique à votre hyperviseur)
    
    # 2. Tenter la restauration
    Stop-Service CertSvc
    try {
        certutil -restoredb $BackupPath
        certutil -restorekey $BackupPath
        Start-Service CertSvc
        
        # 3. Vérifier que la CA répond
        $result = certutil -ping
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Test de restauration RÉUSSI" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Test de restauration ÉCHOUÉ" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Erreur lors du test : $_" -ForegroundColor Red
        return $false
    } finally {
        # 4. Restaurer le snapshot de la VM
        # (commande spécifique à votre hyperviseur)
    }
}
```

### 📋 Checklist de sauvegarde/restauration

**Avant la sauvegarde :**

- [ ] Vérifier l'espace disque disponible (min 2x la taille de la base de données)
- [ ] Tester l'accessibilité du stockage de destination
- [ ] Vérifier que le mot de passe de sauvegarde est connu et documenté
- [ ] S'assurer qu'une fenêtre de maintenance est disponible (arrêt service)

**Pendant la sauvegarde :**

- [ ] Arrêter le service CertSvc avant la sauvegarde
- [ ] Sauvegarder la base de données ET la clé privée
- [ ] Exporter la configuration du registre
- [ ] Copier les fichiers CertEnroll et modèles
- [ ] Redémarrer et vérifier le service

**Après la sauvegarde :**

- [ ] Vérifier l'intégrité des fichiers de backup
- [ ] Tester l'extraction/décompression
- [ ] Copier vers stockage hors site
- [ ] Documenter l'emplacement et le mot de passe
- [ ] Vérifier que les notifications ont été envoyées

**Avant la restauration :**

- [ ] Identifier la cause du problème (hardware? corruption?)
- [ ] Sélectionner le bon backup (le plus récent et valide)
- [ ] Avoir le mot de passe de sauvegarde
- [ ] Planifier une fenêtre de maintenance étendue
- [ ] Prévenir les utilisateurs et applications

**Pendant la restauration :**

- [ ] Réinstaller le rôle ADCS si nécessaire
- [ ] Restaurer la base de données
- [ ] Restaurer la clé privée avec le bon mot de passe
- [ ] Importer la configuration du registre
- [ ] Restaurer les fichiers CertEnroll

**Après la restauration :**

- [ ] Vérifier que le service démarre correctement
- [ ] Tester l'émission d'un certificat
- [ ] Publier une nouvelle CRL
- [ ] Vérifier l'accessibilité des URLs HTTP/LDAP
- [ ] Tester quelques scénarios d'utilisation
- [ ] Surveiller les logs pour détecter les anomalies

### 📊 Stratégie de sauvegarde recommandée

|Fréquence|Type|Rétention|Emplacement|
|---|---|---|---|
|**Quotidienne**|Complète|30 jours|Stockage local + réplication|
|**Hebdomadaire**|Complète|3 mois|Stockage réseau|
|**Mensuelle**|Complète|1 an|Stockage hors site / Cloud|
|**Avant changement**|Complète|Permanent|Archive|

> [!tip] Règle 3-2-1 Appliquez la règle de sauvegarde 3-2-1 :
> 
> - **3** copies des données (original + 2 backups)
> - **2** supports différents (disque local + réseau/cloud)
> - **1** copie hors site (protection contre sinistre majeur)

### 🐛 Problèmes courants de restauration

**Problème 1 : Mot de passe de sauvegarde perdu**

```powershell
# ❌ AUCUNE SOLUTION
# La clé privée chiffrée sans le mot de passe est inutilisable
# C'est pourquoi le mot de passe doit être stocké en lieu sûr (coffre-fort physique ou Azure Key Vault)
```

> [!warning] Prévention Stockez TOUJOURS le mot de passe de sauvegarde dans :
> 
> - Un coffre-fort physique sécurisé
> - Azure Key Vault ou équivalent
> - Un gestionnaire de mots de passe enterprise
> - Documentation papier scellée en lieu sûr

**Problème 2 : Base de données corrompue après restauration**

```powershell
# Vérifier l'intégrité
certutil -dump "C:\Windows\System32\CertLog\*.edb"

# Réparer la base de données
esentutl /p "C:\Windows\System32\CertLog\certsrv.edb"

# Défragmenter
esentutl /d "C:\Windows\System32\CertLog\certsrv.edb"
```

**Problème 3 : Service ne démarre pas après restauration**

```powershell
# Vérifier les logs d'événements
Get-EventLog -LogName Application -Source "CertificationAuthority" -Newest 20

# Vérifier les permissions sur les dossiers
icacls "C:\Windows\System32\CertLog"
icacls "C:\Windows\System32\CertSrv"

# Recréer les dossiers si nécessaire
Stop-Service CertSvc
Remove-Item "C:\Windows\System32\CertLog\*.log" -Force
Start-Service CertSvc
```

---

## 🎓 Résumé des concepts clés

### 🔑 Points essentiels à retenir

**Demande et émission :**

- Plusieurs méthodes disponibles (GUI, certreq, PowerShell, Web)
- La CSR contient la clé publique et les informations d'identité
- Les extensions (SAN, EKU, KeyUsage) définissent l'usage du certificat
- Préférez RSA 2048+ bits ou ECC 256+ bits avec SHA-256+

**Approbation :**

- Automatique : rapide, scalable, pour certificats standards
- Manuelle : contrôle renforcé, pour certificats sensibles/critiques
- Le mode est défini au niveau du modèle, pas de la CA
- Notifications et SLA sont essentiels pour le mode manuel

**Renouvellement :**

- Anticipez (30-60 jours avant expiration)
- Avec nouvelle clé = meilleure sécurité (recommandé)
- Avec même clé = cas spécifiques (CA)
- Automatisez via GPO pour les certificats standards
- Surveillez avec scripts et alertes

**Révocation :**

- Irréversible (sauf Certificate Hold)
- Publiez immédiatement une nouvelle CRL après révocation
- Utilisez le bon code de révocation selon la situation
- CRL vs OCSP : compromis entre simplicité et temps réel
- Procédures d'urgence pour compromissions

**Sauvegarde/Restauration :**

- CRITIQUE pour la continuité de service
- Clé privée + base de données + configuration
- Sauvegarde quotidienne minimum
- Mot de passe de backup en lieu ultra-sécurisé
- Testez régulièrement les restaurations
- Règle 3-2-1 (3 copies, 2 supports, 1 hors site)

> [!tip] Pour aller plus loin
> 
> - Mettez en place une surveillance proactive (certificats expirant, CRL, backups)
> - Automatisez au maximum (scripts PowerShell, tâches planifiées)
> - Documentez tous les processus et procédures
> - Formez plusieurs personnes sur la gestion de la CA
> - Auditez régulièrement (certificats émis, révoqués, configuration)

---

_📚 Cours créé pour la formation PKI - Windows Server | Partie : Gestion des Certificats_