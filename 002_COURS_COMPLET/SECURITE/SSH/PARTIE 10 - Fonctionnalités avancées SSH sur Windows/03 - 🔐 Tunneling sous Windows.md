

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

## Introduction au Tunneling SSH

Le **tunneling SSH** (ou SSH port forwarding) permet de créer des canaux sécurisés à travers une connexion SSH pour transporter d'autres protocoles. C'est comme créer un "tunnel" chiffré dans lequel circulent vos données.

> [!info] Pourquoi utiliser le tunneling SSH ?
> 
> - **Sécurité** : Chiffre les communications non sécurisées (HTTP, MySQL, etc.)
> - **Contournement** : Permet d'accéder à des services bloqués par un pare-feu
> - **Simplicité** : Pas besoin de VPN complet pour accéder à quelques services
> - **Flexibilité** : S'adapte à de nombreux cas d'usage

### Les trois types de tunneling

|Type|Direction|Usage typique|
|---|---|---|
|**Local**|Client → Serveur|Accéder à un service distant depuis votre machine|
|**Remote**|Serveur → Client|Exposer un service local à un serveur distant|
|**Dynamic**|Client ↔ Serveur|Proxy SOCKS pour naviguer via le serveur|

---

## Port Forwarding depuis Windows

### Local Port Forwarding

Le **Local Port Forwarding** redirige un port local de votre machine Windows vers un service accessible depuis le serveur SSH.

> [!example] Cas d'usage Vous voulez accéder à une base de données MySQL (port 3306) qui n'est accessible que depuis le serveur SSH.

#### Syntaxe de base

```bash
ssh -L [adresse_locale:]port_local:hôte_destination:port_destination utilisateur@serveur_ssh
```

#### Exemple pratique : Accès à MySQL

```bash
# Rediriger le port local 3307 vers MySQL sur le serveur
ssh -L 3307:localhost:3306 user@serveur-ssh.com

# Maintenant, vous pouvez vous connecter à MySQL localement
mysql -h 127.0.0.1 -P 3307 -u root -p
```

> [!tip] Astuce Si vous omettez `[adresse_locale:]`, SSH écoute par défaut sur `localhost` (127.0.0.1), ce qui est plus sécurisé.

#### Redirection vers un hôte tiers

```bash
# Accéder à un service sur un autre serveur via le SSH
ssh -L 8080:serveur-interne.local:80 user@bastion.com

# Le trafic passe par : Vous → bastion.com → serveur-interne.local:80
```

#### Écouter sur toutes les interfaces

```bash
# Permet à d'autres machines de votre réseau d'utiliser le tunnel
ssh -L 0.0.0.0:8080:localhost:80 user@serveur.com

# Ou spécifiquement votre IP locale
ssh -L 192.168.1.100:8080:localhost:80 user@serveur.com
```

> [!warning] Attention à la sécurité Écouter sur `0.0.0.0` expose le tunnel à votre réseau local. Assurez-vous que c'est intentionnel !

### Remote Port Forwarding

Le **Remote Port Forwarding** expose un service de votre machine Windows sur le serveur SSH distant.

> [!example] Cas d'usage Vous développez un site web localement (port 3000) et voulez le montrer à un collègue qui peut accéder au serveur SSH.

#### Syntaxe de base

```bash
ssh -R [adresse_distante:]port_distant:hôte_local:port_local utilisateur@serveur_ssh
```

#### Exemple pratique : Exposer un serveur web local

```bash
# Votre serveur web écoute sur localhost:3000
# Le rendre accessible sur le serveur SSH au port 8080
ssh -R 8080:localhost:3000 user@serveur-public.com

# Vos collègues peuvent maintenant accéder à : http://serveur-public.com:8080
```

#### Exposer un service sur toutes les interfaces du serveur

```bash
# Par défaut, SSH écoute uniquement sur localhost du serveur distant
# Pour écouter sur toutes les interfaces :
ssh -R 0.0.0.0:8080:localhost:3000 user@serveur.com

# ⚠️ Nécessite GatewayPorts yes dans /etc/ssh/sshd_config du serveur
```

> [!warning] Configuration serveur requise Pour que le Remote Port Forwarding écoute sur autre chose que localhost du serveur, l'administrateur doit activer `GatewayPorts yes` dans la configuration SSH du serveur.

### Dynamic Port Forwarding (SOCKS)

Le **Dynamic Port Forwarding** crée un proxy SOCKS qui route tout le trafic à travers le serveur SSH.

> [!example] Cas d'usage Naviguer sur Internet comme si vous étiez sur le serveur SSH, ou accéder à plusieurs services internes sans créer un tunnel pour chacun.

#### Syntaxe de base

```bash
ssh -D [adresse_locale:]port_local utilisateur@serveur_ssh
```

#### Exemple pratique : Proxy SOCKS

```bash
# Créer un proxy SOCKS sur le port 1080
ssh -D 1080 user@serveur-distant.com
```

#### Configuration du navigateur

Configurer Firefox pour utiliser le proxy SOCKS :

1. **Firefox** → Paramètres → Réseau → Paramètres de connexion
2. Sélectionner "Configuration manuelle du proxy"
3. **Hôte SOCKS** : `127.0.0.1`
4. **Port** : `1080`
5. Sélectionner **SOCKS v5**
6. Cocher "Proxy DNS lorsque SOCKS v5 est utilisé"

> [!tip] Alternative : Extensions de navigateur Des extensions comme **FoxyProxy** permettent de basculer facilement entre différents proxies.

#### Utilisation avec curl

```bash
# Faire passer une requête curl par le proxy SOCKS
curl --socks5 localhost:1080 http://example.com

# Avec résolution DNS via le proxy
curl --socks5-hostname localhost:1080 http://internal-site.local
```

---

## Configuration des tunnels

### Configuration via ligne de commande

#### Options essentielles

```bash
# -f : Passe en arrière-plan après authentification
# -N : Ne pas exécuter de commande distante (juste le tunnel)
# -T : Désactive l'allocation de pseudo-terminal

ssh -fNT -L 3307:localhost:3306 user@serveur.com
```

> [!tip] Combinaison idéale pour les tunnels `-fNT` est la combinaison parfaite pour créer un tunnel en arrière-plan sans session interactive.

#### Maintenir le tunnel actif

```bash
# -o ServerAliveInterval=60 : Envoie un keepalive toutes les 60 secondes
# -o ServerAliveCountMax=3 : Ferme après 3 tentatives échouées

ssh -fNT -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -L 8080:localhost:80 user@serveur.com
```

#### Réutilisation de connexions avec ControlMaster

```bash
# Première connexion : crée un socket de contrôle
ssh -fNT -M -S ~/.ssh/control-%r@%h:%p -L 3307:localhost:3306 user@serveur.com

# Connexions suivantes : réutilisent le socket
ssh -S ~/.ssh/control-%r@%h:%p user@serveur.com "commande"

# Fermer le tunnel principal
ssh -S ~/.ssh/control-%r@%h:%p -O exit user@serveur.com
```

### Configuration persistante

#### Dans le fichier de configuration SSH

Éditer `C:\Users\VotreNom\.ssh\config` :

```bash
# Tunnel MySQL persistant
Host mysql-tunnel
    HostName serveur-db.com
    User admin
    IdentityFile ~/.ssh/id_rsa
    LocalForward 3307 localhost:3306
    ServerAliveInterval 60
    ServerAliveCountMax 3
    # Ne pas ouvrir de session interactive
    RequestTTY no
```

**Utilisation** :

```bash
# Démarrer le tunnel en arrière-plan
ssh -fN mysql-tunnel

# Se connecter à MySQL localement
mysql -h 127.0.0.1 -P 3307 -u root -p
```

#### Configuration pour développement web

```bash
Host dev-tunnel
    HostName serveur-dev.com
    User developer
    # Tunnel pour le site web
    LocalForward 8080 localhost:80
    # Tunnel pour l'API
    LocalForward 8081 localhost:3000
    # Tunnel pour la base de données
    LocalForward 5433 localhost:5432
    # Proxy SOCKS pour tout le reste
    DynamicForward 1080
    ServerAliveInterval 60
```

### Gestion des tunnels multiples

#### Script PowerShell pour gérer les tunnels

```powershell
# start-ssh-tunnels.ps1

# Fonction pour démarrer un tunnel
function Start-SSHTunnel {
    param(
        [string]$Name,
        [string]$Host
    )
    
    Write-Host "Démarrage du tunnel : $Name"
    Start-Process ssh -ArgumentList "-fN", $Host -WindowStyle Hidden
}

# Démarrer plusieurs tunnels
Start-SSHTunnel -Name "MySQL" -Host "mysql-tunnel"
Start-SSHTunnel -Name "Redis" -Host "redis-tunnel"
Start-SSHTunnel -Name "Web" -Host "web-tunnel"

Write-Host "Tous les tunnels sont démarrés !"
```

#### Vérifier les tunnels actifs

```powershell
# Lister les processus SSH
Get-Process ssh | Select-Object Id, ProcessName, StartTime

# Vérifier les ports en écoute
netstat -ano | Select-String "LISTENING" | Select-String ":3307|:8080|:1080"
```

#### Fermer tous les tunnels

```powershell
# Arrêter tous les processus SSH
Get-Process ssh | Stop-Process -Force

# Ou de manière sélective
Get-Process ssh | Where-Object {$_.StartTime -lt (Get-Date).AddHours(-1)} | Stop-Process
```

> [!warning] Pièges courants
> 
> - **Port déjà utilisé** : Vérifiez qu'aucun autre service n'utilise le port local
> - **Processus orphelins** : Les processus SSH en arrière-plan peuvent rester actifs après fermeture du terminal
> - **Permissions** : Certains ports (< 1024) nécessitent des privilèges administrateur

---

## Applications pratiques

### Accès sécurisé aux bases de données

#### MySQL / MariaDB

```bash
# Configuration dans ~/.ssh/config
Host mysql-prod
    HostName bastion.entreprise.com
    User dba
    LocalForward 3307 db-prod.internal:3306
    
Host mysql-dev
    HostName bastion.entreprise.com
    User dba
    LocalForward 3308 db-dev.internal:3306
```

**Connexion** :

```bash
# Démarrer le tunnel
ssh -fN mysql-prod

# Se connecter avec votre client préféré
mysql -h 127.0.0.1 -P 3307 -u admin -p
# Ou avec MySQL Workbench, DBeaver, etc.
```

#### PostgreSQL

```bash
Host postgres-tunnel
    HostName serveur-ssh.com
    User admin
    LocalForward 5433 localhost:5432
```

```bash
# Connexion avec psql
psql -h localhost -p 5433 -U postgres -d ma_base

# Ou chaîne de connexion
postgresql://postgres:password@localhost:5433/ma_base
```

#### MongoDB

```bash
Host mongo-tunnel
    HostName bastion.com
    User admin
    LocalForward 27018 mongo-cluster.internal:27017
```

```bash
# Connexion avec mongo shell
mongo mongodb://localhost:27018/ma_base

# Ou avec Compass, Studio 3T, etc.
```

> [!tip] Bonnes pratiques pour les bases de données
> 
> - Utilisez un port local différent du port par défaut (ex: 3307 au lieu de 3306)
> - Ne partagez jamais vos tunnels sur `0.0.0.0`
> - Ajoutez `ServerAliveInterval` pour éviter les déconnexions

### Contournement de pare-feu

#### Accès à un serveur web bloqué

```bash
# Le pare-feu bloque l'accès direct au port 80
# Mais autorise SSH (port 22)

ssh -L 8080:localhost:80 user@serveur-bloqué.com

# Accéder au site via : http://localhost:8080
```

#### Accès à plusieurs services internes

```bash
Host intranet-access
    HostName gateway.entreprise.com
    User employe
    # Wiki interne
    LocalForward 8081 wiki.internal:80
    # GitLab interne
    LocalForward 8082 gitlab.internal:443
    # Jenkins
    LocalForward 8083 jenkins.internal:8080
    # Grafana monitoring
    LocalForward 8084 grafana.internal:3000
```

### Accès à des services internes

#### Architecture en saut (Jump Host)

```bash
# Accéder à un service via un bastion
Host private-db
    HostName bastion.entreprise.com
    User admin
    LocalForward 5432 db-privée.local:5432
    ProxyJump bastion.entreprise.com
```

#### Chaîne de tunnels

```bash
# Tunnel via plusieurs serveurs
# Vous → Bastion1 → Bastion2 → Service

# Premier tunnel
ssh -fNT -L 2222:bastion2.internal:22 user@bastion1.com

# Second tunnel via le premier
ssh -fNT -L 5432:database.private:5432 -p 2222 user@localhost
```

> [!example] Cas réel : Architecture cloud Vous avez une base de données RDS dans un VPC privé AWS, accessible uniquement via une instance EC2 dans un sous-réseau public.
> 
> ```bash
> Host aws-rds-tunnel
>     HostName ec2-public.amazonaws.com
>     User ec2-user
>     IdentityFile ~/.ssh/aws-key.pem
>     LocalForward 5432 rds-private.region.rds.amazonaws.com:5432
> ```

### VPN léger avec SOCKS

#### Configuration complète

```bash
Host vpn-proxy
    HostName serveur-distant.com
    User vpnuser
    DynamicForward 1080
    # Compression pour améliorer les performances
    Compression yes
    # Maintenir la connexion
    ServerAliveInterval 60
    ServerAliveCountMax 3
    # Réutiliser la connexion
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
```

#### Utilisation système

**Windows : Configuration du proxy système**

```powershell
# PowerShell : Configurer le proxy SOCKS
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "socks=127.0.0.1:1080"

# Désactiver le proxy
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0
```

#### Applications compatibles SOCKS

```bash
# Git via SOCKS
git config --global http.proxy socks5://127.0.0.1:1080
git config --global https.proxy socks5://127.0.0.1:1080

# curl
curl --socks5 localhost:1080 https://api.example.com

# wget
wget -e use_proxy=yes -e socks_proxy=127.0.0.1:1080 https://example.com

# Python requests
proxies = {
    'http': 'socks5://localhost:1080',
    'https': 'socks5://localhost:1080'
}
requests.get('https://example.com', proxies=proxies)
```

> [!warning] Limitations du proxy SOCKS
> 
> - Tous les logiciels ne supportent pas SOCKS (certains nécessitent HTTP/HTTPS)
> - Les requêtes DNS peuvent fuir en dehors du tunnel si mal configuré
> - Les performances peuvent être réduites pour des transferts de gros fichiers

---

## Outils GUI pour tunneling

### PuTTY

**Configuration d'un tunnel local dans PuTTY :**

1. Ouvrir PuTTY
2. **Session** → Entrer le hostname
3. **Connection → SSH → Tunnels**
4. **Source port** : Port local (ex: 3307)
5. **Destination** : `localhost:3306`
6. Sélectionner **Local**
7. Cliquer **Add**
8. Retourner à **Session** → Sauvegarder la configuration

**Tunnel dynamique (SOCKS) dans PuTTY :**

1. Même procédure jusqu'à **Tunnels**
2. **Source port** : 1080
3. Sélectionner **Dynamic**
4. Cliquer **Add**

> [!tip] Astuce PuTTY Sauvegardez vos sessions avec des noms explicites comme "MySQL-Prod-Tunnel" pour les retrouver facilement.

**Ligne de commande PuTTY (plink)** :

```cmd
REM Tunnel local en arrière-plan
plink -L 3307:localhost:3306 -N user@serveur.com -i C:\cles\id_rsa.ppk

REM Tunnel dynamique
plink -D 1080 -N user@serveur.com -i C:\cles\id_rsa.ppk
```

### MobaXterm

MobaXterm offre une interface graphique très intuitive pour gérer les tunnels.

**Créer un tunnel dans MobaXterm :**

1. **Tunneling** (icône dans la barre d'outils)
2. **New SSH tunnel**
3. Choisir le type :
    - **Local port forwarding** (My computer ← Remote server)
    - **Remote port forwarding** (My computer → Remote server)
    - **Dynamic port forwarding (SOCKS proxy)**

**Configuration Local Port Forwarding** :

```
Forwarded port: 3307
SSH server: serveur.com
SSH login: user
SSH port: 22
Remote server: localhost
Remote port: 3306
```

**Avantages de MobaXterm** :

- Interface graphique claire et intuitive
- Gestion centralisée de tous les tunnels
- Indicateurs visuels de l'état des tunnels
- Terminal intégré + éditeur SFTP
- Profils sauvegardables

> [!tip] MobaXterm Pro Tip Les tunnels peuvent être configurés pour démarrer automatiquement avec MobaXterm. Cliquez sur le tunnel → **Settings** → **Auto-start tunnel**.

### SecureCRT

**Configuration d'un Port Forwarding dans SecureCRT :**

1. **Options → Session Options**
2. **Connection → Port Forwarding**
3. Cliquer **Add** pour ajouter un forward
4. Configurer :
    - **Name** : MySQL Tunnel
    - **Local** : 127.0.0.1:3307
    - **Remote** : localhost:3306

**Configuration SOCKS** :

1. Même menu **Port Forwarding**
2. Cocher **Request dynamic port forwarding**
3. **Listen Port** : 1080

**Avantages de SecureCRT** :

- Interface professionnelle et stable
- Excellent pour les environnements d'entreprise
- Gestion avancée des sessions et scripts
- Support de multiples protocoles

### Visual Studio Code

VS Code intègre le tunneling SSH via l'extension **Remote - SSH**.

**Configuration automatique** :

1. Installer l'extension **Remote - SSH**
2. `Ctrl+Shift+P` → "Remote-SSH: Connect to Host"
3. VS Code crée automatiquement des tunnels pour :
    - Le port de debug
    - Les serveurs web locaux
    - Les services de développement

**Port Forwarding manuel dans VS Code** :

1. Connecté à un hôte distant
2. **Ports** panel (dans la barre latérale)
3. **Forward a Port**
4. Entrer le port à rediriger

**Configuration dans settings.json** :

```json
{
    "remote.SSH.defaultForwardedPorts": [
        {
            "localPort": 3000,
            "remotePort": 3000,
            "name": "Dev Server"
        },
        {
            "localPort": 5432,
            "remotePort": 5432,
            "name": "PostgreSQL"
        }
    ]
}
```

> [!example] Workflow développeur Vous développez sur un serveur distant. VS Code forward automatiquement le port 3000 de votre serveur Node.js, vous pouvez ouvrir `http://localhost:3000` dans votre navigateur Windows.

---

## 🎯 Astuces de pro

### Script de gestion de tunnels

```powershell
# manage-tunnels.ps1

function Show-Tunnels {
    Write-Host "`n=== Tunnels SSH actifs ===" -ForegroundColor Cyan
    $sshProcesses = Get-Process ssh -ErrorAction SilentlyContinue
    
    if ($sshProcesses) {
        $sshProcesses | ForEach-Object {
            Write-Host "PID: $($_.Id) | Démarré: $($_.StartTime)" -ForegroundColor Green
        }
        
        Write-Host "`n=== Ports en écoute ===" -ForegroundColor Cyan
        netstat -ano | Select-String "LISTENING" | Select-String "127.0.0.1" | ForEach-Object {
            if ($_ -match ":(\d+).*?(\d+)$") {
                $port = $matches[1]
                $pid = $matches[2]
                Write-Host "Port $port (PID: $pid)"
            }
        }
    } else {
        Write-Host "Aucun tunnel SSH actif" -ForegroundColor Yellow
    }
}

function Stop-AllTunnels {
    Write-Host "Arrêt de tous les tunnels SSH..." -ForegroundColor Yellow
    Get-Process ssh -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Tous les tunnels ont été fermés" -ForegroundColor Green
}

# Utilisation
# Show-Tunnels
# Stop-AllTunnels
```

### Résolution de problèmes courants

|Problème|Solution|
|---|---|
|"Port already in use"|Vérifier avec `netstat -ano` et tuer le processus, ou utiliser un autre port local|
|Tunnel se ferme immédiatement|Ajouter `-v` pour le mode verbose et identifier l'erreur|
|Lenteur du tunnel|Activer la compression avec `-C`|
|Tunnel se déconnecte|Ajouter `ServerAliveInterval=60` et `ServerAliveCountMax=3`|
|Impossible de se connecter au service tunnelé|Vérifier que le service distant fonctionne, et que le firewall autorise SSH|

> [!tip] Debug avancé Utilisez `ssh -v` (verbose), `-vv` (très verbose), ou `-vvv` (debug complet) pour diagnostiquer les problèmes de connexion.

### Automatisation au démarrage Windows

**Créer une tâche planifiée** :

```powershell
# Script start-tunnels.ps1
ssh -fN mysql-tunnel
ssh -fN redis-tunnel
ssh -fN web-tunnel
```

**Créer la tâche** :

1. **Gestionnaire des tâches** → Créer une tâche
2. **Général** : "Démarrage tunnels SSH"
3. **Déclencheurs** : À l'ouverture de session
4. **Actions** : Démarrer PowerShell avec `-File "C:\scripts\start-tunnels.ps1"`
5. Cocher "Exécuter si l'utilisateur est connecté ou non"

---

## 📊 Tableau récapitulatif

|Type de tunnel|Commande|Cas d'usage|
|---|---|---|
|**Local**|`ssh -L local:dest:port`|Accéder à un service distant|
|**Remote**|`ssh -R remote:local:port`|Exposer un service local|
|**Dynamic**|`ssh -D port`|Proxy SOCKS / VPN léger|
|**Arrière-plan**|`ssh -fN`|Tunnel persistant|
|**Keepalive**|`ServerAliveInterval=60`|Maintenir la connexion|
|**Contrôle**|`ControlMaster auto`|Réutiliser les connexions|