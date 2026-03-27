## ⚡ L'essentiel en 5 minutes - SSH (Secure Shell)

### 📌 C'est quoi en 2 lignes ?

Protocole client-serveur sécurisé pour accéder à distance à un terminal, transférer des fichiers et créer des tunnels chiffrés. Remplace FTP/Telnet/RSH en garantissant confidentialité, intégrité et authentification bidirectionnelle sur TCP port 22.

---

### 💡 Concepts clés à retenir :

- **OpenSSH** : Implémentation standard (client `ssh`, serveur `sshd`, version actuelle 9.9p2)
- **Authentification bidirectionnelle** : Le client authentifie le serveur (via sa clé publique), puis le serveur authentifie le client (mot de passe ou clé)
- **TOFU (Trust On First Use)** : À la 1ère connexion, le client enregistre la clé serveur dans `~/.ssh/known_hosts` après validation manuelle
- **PFS (Perfect Forward Secrecy)** : Échange de clés Diffie-Hellman (ECDH) = même si la clé privée est compromise plus tard, les sessions passées restent secrètes
- **RFC 4251-4254** : Standards du protocole SSH version 2 (v1 obsolète)

---

### 💻 Commandes essentielles :

```bash
# 🔐 Connexion & Clés
ssh [user@]host                    # Connexion basique (port 22, user local par défaut)
ssh -p 2222 user@host              # Port personnalisé
ssh -l user -v host                # Mode verbeux (debug)

ssh-keygen -t ed25519              # Générer paire de clés (ed25519 recommandé)
ssh-keygen -t ecdsa -b 256         # Ou ECDSA 256 bits
ssh-keygen -lf ~/.ssh/id_ed25519.pub  # Afficher empreinte d'une clé

ssh-copy-id user@host              # Copier clé publique sur serveur distant
ssh-keygen -R hostname             # Retirer une clé de known_hosts (après changement serveur)

# 📁 Transfert de fichiers
scp local_file user@host:/path/    # Copier fichier vers serveur
scp user@host:/path/file ./        # Copier fichier depuis serveur
scp -r local_dir/ user@host:/path/ # Copier dossier (récursif)

sftp user@host                     # Session SFTP interactive
# Commandes SFTP : get, put, ls, cd, lcd, bye

# 🔧 Configuration & Test
sudo sshd -t                       # Tester config serveur (syntaxe)
sshd -T                            # Afficher config effective
ssh -G host                        # Afficher config client pour un hôte

ssh -Q cipher-auth                 # Lister chiffrements supportés
ssh -Q key                         # Lister types de clés supportés

# 🚇 Tunnels
ssh -L 8080:localhost:80 host      # Tunnel local (client:8080 → host:80)
ssh -R 9090:localhost:3000 host    # Tunnel reverse (host:9090 → client:3000)
ssh -D 1080 host                   # Proxy SOCKS (client:1080)
ssh -X host                        # X11 forwarding (GUI distante)
```

---

### 📐 Fichiers & Emplacements clés :

|Fichier/Dossier|Rôle|
|---|---|
|**`/etc/ssh/sshd_config`**|Config serveur SSH|
|**`/etc/ssh/ssh_host_*_key`**|Clés privées du serveur|
|**`/etc/ssh/ssh_host_*_key.pub`**|Clés publiques du serveur|
|**`~/.ssh/id_*`**|Clés privées utilisateur|
|**`~/.ssh/id_*.pub`**|Clés publiques utilisateur|
|**`~/.ssh/known_hosts`**|Clés publiques des serveurs connus|
|**`~/.ssh/authorized_keys`**|Clés publiques autorisées à se connecter (côté serveur)|
|**`~/.ssh/config`**|Config client personnalisée|

---

### ⚠️ Pièges à éviter :

- ❌ **Port 22 sur Internet sans protection** : Cible massive de bots brute-force (changer le port, utiliser Fail2Ban)
- ❌ **Accepter une nouvelle clé serveur sans vérifier** : Risque d'attaque MITM (Man-in-the-Middle). Toujours vérifier l'empreinte hors-bande
- ❌ **Clé privée sans passphrase** : Si le fichier est volé, accès immédiat. Toujours protéger avec `ssh-keygen -p`
- ❌ **Authentification par mot de passe seul** : Vulnérable au brute-force. Privilégier `publickey` ou `publickey,password`
- ❌ **Ignorer l'alerte "REMOTE HOST IDENTIFICATION HAS CHANGED"** : Possible usurpation ! Ne jamais supprimer machinalement la ligne dans `known_hosts`

---

### ✅ Bonnes pratiques :

- ✅ **Authentification par clé + passphrase** : Sécurité maximale (clé + ce que tu connais)
- ✅ **Changer le port par défaut** : `Port 2222` dans `sshd_config` (évite 99% des scans automatiques)
- ✅ **Désactiver root login** : `PermitRootLogin no` (se connecter avec user normal puis `sudo`)
- ✅ **Installer Fail2Ban** : Bloque les IP après X échecs (protection anti brute-force)
- ✅ **Forcer SSH v2** : `Protocol 2` (v1 obsolète et vulnérable)
- ✅ **Limiter les algorithmes faibles** : Désactiver ssh-rsa, préférer ed25519/ecdsa

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**TOFU**|Trust On First Use : accepter la clé serveur à la 1ère connexion|
|**PFS**|Perfect Forward Secrecy : échange de clés éphémère (ECDH)|
|**HMAC**|Hash-based Message Authentication Code : contrôle d'intégrité|
|**Fingerprint**|Empreinte SHA256 d'une clé (identifiant unique)|
|**Bastion**|Serveur intermédiaire sécurisé pour accéder à un réseau interne|
|**Tunnel/Forwarding**|Encapsuler du trafic dans SSH (port local/remote, SOCKS)|
|**Passphrase**|Mot de passe protégeant une clé privée chiffrée|

---

### 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : SSH = authentification BIDIRECTIONNELLE (serveur→client puis client→serveur) avec chiffrement + intégrité
2. 💻 **Pratique** : `ssh-keygen -t ed25519` → `ssh-copy-id user@host` → connexion sans mot de passe
3. ⚠️ **Piège** : Alerte "REMOTE HOST IDENTIFICATION HAS CHANGED" = NE JAMAIS IGNORER (possible MITM) → vérifier avant de supprimer la clé

---

**📌 Antisèche usage rapide :**

```bash
# Setup initial (1 fois)
ssh-keygen -t ed25519 -C "mon-email@example.com"  # Créer clé
ssh-copy-id user@192.168.1.10                      # Déployer sur serveur

# Connexion quotidienne
ssh user@serveur                                    # Connexion simple
ssh -p 2222 user@serveur                           # Port custom

# Transfert fichier
scp file.txt user@serveur:/tmp/                    # Upload
scp user@serveur:/tmp/file.txt ./                  # Download

# Tunnel (accès web interne via SSH)
ssh -L 8080:intranet.local:80 user@bastion         # http://localhost:8080
```

**⚙️ Config serveur minimale sécurisée (`/etc/ssh/sshd_config`) :**

```bash
Port 2222                                # Changer port
PermitRootLogin no                       # Bloquer root
PasswordAuthentication no                # Forcer clés (après setup)
PubkeyAuthentication yes
AuthenticationMethods publickey          # Ou publickey,password (2FA)
```