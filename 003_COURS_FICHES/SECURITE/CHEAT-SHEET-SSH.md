# SSH - Cheatsheet TSSR
> CCP 3 — Exploiter des serveurs Linux | CCP 7 — Sécuriser les accès et interconnexions

---

## Concepts clés

| Concept | Définition |
|---------|------------|
| SSH | Protocole chiffré client/serveur — remplace Telnet, RSH, FTP |
| Port par défaut | TCP **22** |
| Version à utiliser | **SSH-2** (SSH-1 obsolète et vulnérable) |
| Couche OSI | Couche **7** (Application) |
| Garanties | Confidentialité + Intégrité + Authentification bidirectionnelle |
| PFS | Perfect Forward Secrecy — compromission d'une clé n'affecte pas les sessions passées |
| TOFU | Trust On First Use — validation manuelle de l'empreinte serveur à la 1ère connexion |
| OpenSSH | Implémentation open source — paquet `openssh-client` / `openssh-server` |

---

## Connexion et transfert de fichiers

| Action | Commande |
|--------|----------|
| Connexion SSH simple | `ssh user@host` |
| Connexion sur port spécifique | `ssh -p 2222 user@host` |
| Connexion verbeux (debug) | `ssh -v user@host` |
| Copie fichier vers serveur (SCP) | `scp fichier.txt user@host:/chemin/` |
| Copie dossier récursif (SCP) | `scp -r dossier/ user@host:/chemin/` |
| Copie depuis serveur (SCP) | `scp user@host:/chemin/fichier.txt .` |
| Transfert interactif (SFTP) | `sftp user@host` |
| Tunnel local (port forwarding) | `ssh -L 8080:localhost:80 user@host` |
| Tunnel distant (remote forwarding) | `ssh -R 9090:localhost:3000 user@host` |
| Proxy SOCKS | `ssh -D 1080 user@host` |
| Application graphique distante | `ssh -X user@host` |

---

## Gestion des clés

| Action | Commande |
|--------|----------|
| Générer une clé Ed25519 (recommandé) | `ssh-keygen -t ed25519` |
| Générer une clé RSA 4096 bits | `ssh-keygen -t rsa -b 4096` |
| Copier la clé publique sur serveur | `ssh-copy-id user@host` |
| Lancer l'agent SSH | `eval $(ssh-agent)` |
| Ajouter une clé à l'agent | `ssh-add ~/.ssh/id_ed25519` |
| Lister les clés de l'agent | `ssh-add -l` |

---

## Configuration et sécurisation

| Paramètre `sshd_config` | Valeur recommandée |
|-------------------------|-------------------|
| Changer le port | `Port 2222` |
| Désactiver login root | `PermitRootLogin no` |
| Authentification par clé uniquement | `PasswordAuthentication no` |
| Méthodes d'auth | `AuthenticationMethods publickey` |
| Tester la config sans redémarrer | `sudo sshd -t` |
| Recharger le service | `sudo systemctl reload ssh` |

---

## Fichiers importants

| Fichier | Rôle |
|---------|------|
| `/etc/ssh/sshd_config` | Configuration du serveur SSH |
| `/etc/ssh/ssh_config` | Configuration globale du client SSH |
| `~/.ssh/config` | Configuration client par hôte |
| `~/.ssh/known_hosts` | Empreintes des serveurs connus |
| `~/.ssh/authorized_keys` | Clés publiques autorisées sur le serveur |
| `~/.ssh/id_ed25519` | Clé privée (ne jamais partager !) |
| `~/.ssh/id_ed25519.pub` | Clé publique (à déposer sur les serveurs) |
| `/etc/ssh/ssh_host_*` | Clés d'identité du serveur |

---

## Fail2Ban (protection anti-bruteforce)

| Action | Commande |
|--------|----------|
| Installer Fail2Ban | `sudo apt install fail2ban` |
| Statut d'une jail | `sudo fail2ban-client status sshd` |
| Débloquer une IP | `sudo fail2ban-client set sshd unbanip <ip>` |
| Voir les logs | `sudo journalctl -u fail2ban` |

---

## Points de vigilance

| Piège | À retenir |
|-------|-----------|
| Ne jamais utiliser SSH-1 | Vulnérabilités connues — toujours SSH-2 |
| `PermitRootLogin yes` | Interdit en prod — vecteur d'attaque direct |
| Clé privée sans passphrase | Risque si le fichier est volé |
| Désactiver `PasswordAuthentication` trop tôt | Tester d'abord la connexion par clé ! |
| Partager sa clé privée | Jamais — seule la clé **publique** se partage |
| Ne pas vérifier l'empreinte serveur | Risque de MITM (Man In The Middle) |
| Port 22 exposé sans Fail2Ban | Attaques bruteforce en continu sur port 22 |
