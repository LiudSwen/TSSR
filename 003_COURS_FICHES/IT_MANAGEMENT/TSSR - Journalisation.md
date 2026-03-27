## ⚡ L'essentiel en 5 minutes - Journalisation Système

### 📌 C'est quoi en 2 lignes ?

La journalisation enregistre toutes les traces d'activité des systèmes et applications (connexions, erreurs, événements) dans des fichiers logs. C'est essentiel pour le débogage, l'administration système et la détection d'intrusions.

---

### 💡 Concepts clés à retenir :

- **Syslog** : Protocole standard de journalisation Unix/Linux (RFC 5424) avec séparation générateur/stockage/analyseur
- **Catégorie (facility)** : Type de message (0-23 : kern, user, mail, daemon, auth, cron, etc.)
- **Sévérité** : Niveau de gravité (0-7 : emergency, alert, critical, error, warning, notice, info, debug)
- **Event ID (Windows)** : Code numérique identifiant le type d'événement système
- **Centralisation** : Collecte des logs de plusieurs machines vers un serveur unique pour analyse globale

---

### 💻 Commandes essentielles :

```bash
# 🐧 Linux - Consultation logs
tail -f /var/log/syslog              # Suivi temps réel
grep "error" /var/log/auth.log       # Recherche dans logs
journalctl -xe                       # Logs systemd récents
journalctl -u ssh.service            # Logs d'un service
dmesg                                # Logs noyau
last                                 # Connexions réussies
lastb                                # Tentatives échec

# 🐧 Linux - Génération logs
logger -p auth.info "Mon message"    # Envoyer un log
logger -t MonScript "Test"           # Avec tag personnalisé

# 🐧 Linux - Configuration
rsyslogd -N1                         # Tester config rsyslog
logrotate /etc/logrotate.conf        # Rotation manuelle
```

```powershell
# 🪟 Windows - Event Viewer
eventvwr                             # Ouvrir observateur
Get-EventLog -LogName Security -Newest 100  # 100 derniers événements
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625}  # Échecs connexion
```

```bash
# 🌐 Configuration rsyslog (/etc/rsyslog.conf)
auth,authpriv.*     /var/log/auth.log    # Auth vers fichier
*.emerg             :omusrmsg:*          # Urgences vers tous users
*.* @@serveur:514                        # Tout vers serveur distant (TCP)
*.* @serveur:514                         # Tout vers serveur distant (UDP)

# 🌐 Ports syslog
514/UDP   # Syslog non sécurisé (éviter)
514/TCP   # Syslog TCP (privilégier)
6514/TCP  # Syslog over TLS (recommandé)
```

---

### 📐 Hiérarchies importantes :

**Niveaux de sévérité Syslog (0 = pire → 7 = détail) :**

```
0 - EMERGENCY  : Système mort
1 - ALERT      : Action immédiate
2 - CRITICAL   : Erreur critique
3 - ERROR      : Erreur fonctionnelle
4 - WARNING    : Avertissement
5 - NOTICE     : Normal mais notable
6 - INFO       : Information
7 - DEBUG      : Débogage
```

**Catégories essentielles (Linux) :**

```
0-kern    : Noyau
3-daemon  : Services
4-auth    : Authentification
9-cron    : Tâches planifiées
10-authpriv : Sécurité/sudo
```

**Event ID Windows critiques :**

```
4624 : Connexion réussie
4625 : Échec connexion (brute force !)
4740 : Compte verrouillé
4728/4732/4756 : Modification groupes (élévation privilèges !)
1102 : Suppression logs (⚠️ tentative dissimulation)
```

---

### ⚠️ Pièges à éviter :

- ❌ **Utiliser UDP pour syslog** : Pas de garantie de livraison, logs perdus possibles → toujours TCP ou TLS
- ❌ **Logs locaux non protégés** : Attaquant peut les modifier/supprimer → centraliser sur serveur distant sécurisé
- ❌ **Rotation désactivée** : Saturation disque et perte de logs récents → configurer logrotate
- ❌ **Journalisation trop verbeuse** : Niveau DEBUG en prod = surcharge → ajuster sévérité selon contexte
- ❌ **Ne pas filtrer les IP sources** : Serveur syslog accessible à tous → pare-feu strict sur 514/6514

---

### ✅ Bonnes pratiques :

- ✅ **Centraliser les logs** : Un serveur dédié pour tous les équipements (corrélation d'événements)
- ✅ **Chiffrer les logs** : Syslog over TLS (6514/TCP) pour éviter interception sur le réseau
- ✅ **Surveiller Event ID 1102** : Suppression logs = indicateur de compromission potentielle
- ✅ **Respecter obligations légales** : RGPD/LPM → durée de conservation définie (souvent 6-12 mois)
- ✅ **Filtrer par catégorie/sévérité** : Logs auth dans fichier dédié, errors vers alertes admin

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**rsyslog**|Daemon Linux gérant réception/stockage/transmission logs selon RFC 5424|
|**facility**|Catégorie de log syslog (kern, user, auth, daemon, etc.)|
|**severity**|Niveau de gravité du message (0=emerg → 7=debug)|
|**logrotate**|Outil Linux d'archivage/compression/suppression automatique des anciens logs|
|**journalctl**|Commande de consultation des logs systemd (format binaire)|
|**Event Viewer**|Observateur d'événements Windows (eventvwr)|
|**WEF**|Windows Event Forwarding - centralisation logs Windows via WinRM|
|**SIEM**|Security Information and Event Management - analyse corrélée de logs sécurité|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Les logs sont LA preuve légale et technique de l'activité système → obligation conservation selon RGPD/LPM
2. 💻 **Pratique** : `tail -f /var/log/auth.log` (Linux) et Event ID 4625 (Windows) = détection tentatives d'intrusion
3. ⚠️ **Piège** : Logs locaux uniquement = attaquant les efface (Event 1102) → TOUJOURS centraliser sur serveur distant chiffré