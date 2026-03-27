## ⚡ L'essentiel en 5 minutes - Services bureautiques DSI

### 📌 C'est quoi en 2 lignes ?

Les services bureautiques regroupent les logiciels et outils permettant de travailler au quotidien : messagerie, stockage de fichiers, suites Office et prise de main à distance. Fournis par la DSI, ils existent en version locale (on-premises) ou cloud et sont critiques pour la productivité et la collaboration en entreprise.

---

### 💡 Concepts clés à retenir :

- **Service bureautique** : Logiciel/application pour tâches courantes de bureau (communication, documents, collaboration)
- **On-premises** : Solution hébergée localement sur les serveurs de l'entreprise (contrôle total, maintenance interne)
- **Cloud** : Solution hébergée en ligne par un fournisseur externe (accessible partout, moins de maintenance)
- **DSI** : Direction des Systèmes d'Information - fournit et gère ces services pour l'entreprise
- **4 piliers** : Messagerie électronique, Stockage de fichiers, Suites bureautiques, Prise de main à distance

---

### 💻 Commandes essentielles :

```bash
# 🐧 Linux - Connexion SSH
ssh utilisateur@serveur          # Connexion en ligne de commande
ssh -X utilisateur@serveur       # Connexion avec interface graphique (X11 forwarding)
scp fichier user@serveur:~       # Transfert de fichier via SSH
```

```powershell
# 🪟 Windows - Bureau à distance
mstsc                            # Lancer le client RDP (Remote Desktop)
mstsc /v:nom_serveur             # Se connecter directement à un serveur
Get-SmbConnection                # Vérifier les connexions SMB actives
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol  # Désactiver SMBv1
```

```bash
# 🌐 Configuration Samba (Linux)
sudo apt install samba           # Installation Samba
sudo nano /etc/samba/smb.conf    # Configuration des partages
sudo smbpasswd -a utilisateur    # Créer un utilisateur Samba
sudo systemctl restart smbd      # Redémarrer le service
```

---

### 📐 Protocoles et architectures :

**Messagerie électronique :**

- **SMTP** : Envoi de mails (port 25/587)
- **IMAP/POP3** : Réception de mails (ports 143/993 ou 110/995)
- **Architecture** : Serveurs de messagerie + Clients (Outlook, Thunderbird) + Protocoles + Pare-feu + Redondance

**Stockage de fichiers :**

- **SMB (Server Message Block)** : Protocole Windows pour partage réseau (ports 445/139)
- **Samba** : Implémentation open-source de SMB pour Linux/Unix
- **WebDAV** : Extension HTTP pour partage cloud (Google Drive, OneDrive, Dropbox)
- **NAS** : Serveur de stockage réseau utilisant SMB/NFS

**Prise de main à distance :**

- **SSH** : Connexion cryptée Linux/Unix (port 22)
- **RDP** : Remote Desktop Protocol Windows (port 3389)
- **VNC** : Alternative multi-plateforme (port 5900+)
- **RDWeb** : Accès RDP via navigateur web

---

### ⚠️ Pièges à éviter :

- ❌ **Utiliser SMBv1** : Obsolète, failles de sécurité critiques (WannaCry exploitait SMBv1) - TOUJOURS désactiver
- ❌ **Désactiver SMB complètement** : Bloque le partage de fichiers réseau et l'accès aux NAS
- ❌ **Accès à distance sans chiffrement** : Les données circulent en clair (utiliser SSH/RDP avec TLS, jamais Telnet)
- ❌ **Pas de 2FA sur prise de main** : Accès non sécurisé aux postes utilisateurs
- ❌ **Droits d'accès trop larges** : Partages ouverts à tous = fuite de données

---

### ✅ Bonnes pratiques :

- ✅ **Versions SMB récentes** : Utiliser SMBv2/v3 uniquement (performances + chiffrement natif)
- ✅ **Chiffrement systématique** : SSH pour Linux, RDP avec TLS pour Windows, HTTPS pour webmail
- ✅ **2FA obligatoire** : Authentification à deux facteurs pour accès à distance et cloud
- ✅ **Gestion des droits** : Principe du moindre privilège (accès strictement nécessaire)
- ✅ **Sauvegardes régulières** : 3-2-1 (3 copies, 2 supports, 1 hors site)
- ✅ **Traçabilité** : Logs d'accès et modifications pour audit
- ✅ **VPN pour accès externe** : Ne jamais exposer RDP/SMB directement sur Internet

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**SMB**|Protocole Windows de partage fichiers/imprimantes sur réseau local|
|**Samba**|Implémentation Linux de SMB pour interopérabilité Windows/Linux|
|**WebDAV**|Extension HTTP permettant édition collaborative de documents web|
|**RDP**|Remote Desktop Protocol - prise de contrôle Windows à distance|
|**SSH**|Secure Shell - connexion cryptée ligne de commande (Linux/Unix)|
|**VNC**|Virtual Network Computing - contrôle graphique multi-plateforme|
|**X11 forwarding**|Affichage d'applications graphiques Linux via SSH|
|**NAS**|Network Attached Storage - serveur de fichiers dédié sur réseau|
|**Workgroup**|Groupe de travail Windows sans domaine centralisé|
|**Domaine AD**|Active Directory - gestion centralisée des utilisateurs Windows|
|**2FA**|Two-Factor Authentication - double authentification (mot de passe + code)|
|**IMAP**|Internet Message Access Protocol - consultation mails sur serveur|
|**SMTP**|Simple Mail Transfer Protocol - envoi de mails|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : **4 services critiques DSI** = Messagerie (Exchange/Gmail) + Stockage (SMB/WebDAV) + Suite Office + Accès distant (RDP/SSH)
    
2. 💻 **Pratique** : **Désactiver SMBv1 immédiatement** sur tous les systèmes Windows (`Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol`) - faille de sécurité majeure
    
3. ⚠️ **Piège** : **Ne JAMAIS exposer RDP/SMB directement sur Internet** sans VPN - port 3389/445 = cibles privilégiées des ransomwares (utiliser VPN + 2FA obligatoire)
    

---

### 🛠️ Solutions par usage :

**Messagerie :**

- On-premises : Exchange Server, Zimbra, Postfix
- Cloud : Microsoft 365, Google Workspace, Zoho Mail, ProtonMail

**Stockage :**

- On-premises : Partages SMB/Samba, NAS (Synology/QNAP)
- Cloud : OneDrive, Google Drive, Dropbox, Nextcloud (hybride)

**Suites bureautiques :**

- On-premises : Microsoft Office, LibreOffice, OpenOffice
- Cloud : Microsoft 365, Google Workspace, OnlyOffice

**Prise de main :**

- On-premises : RDP (Windows), SSH (Linux), VNC, TeamViewer
- Cloud : TeamViewer, AnyDesk, Chrome Remote Desktop, Guacamole (web)

---

### 🔐 Checklist sécurité services bureautiques :

- [ ] SMBv1 désactivé partout
- [ ] SMBv2/v3 avec chiffrement activé
- [ ] 2FA sur messagerie cloud
- [ ] 2FA sur accès RDP/SSH
- [ ] VPN obligatoire pour accès externe
- [ ] Ports RDP/SMB filtrés par pare-feu (jamais exposés publiquement)
- [ ] Logs d'authentification activés
- [ ] Sauvegardes régulières testées
- [ ] Gestion des droits d'accès par groupes AD
- [ ] Chiffrement des données stockées (BitLocker/LUKS)