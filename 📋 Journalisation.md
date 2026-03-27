## 1. Concepts fondamentaux

Les **journaux (logs)** sont des traces d'activité enregistrées par les applications et les OS. Ils servent à :

- **Développeurs** : déboguer
- **Admins** : diagnostiquer des pannes, analyser l'utilisation
- **Cybersécurité** : détecter des intrusions

Points de vigilance :

- **Stockage** : les logs peuvent prendre beaucoup de place → compression + rotation
- **Historique** : conserver l'historique pour analyser des événements passés
- **Légal** : RGPD (art. 32), LPM, HDS → respecter durée de conservation et protection
- **Centralisation** + **Standardisation** pour faciliter la lecture

---

## 2. Journalisation GNU/Linux — Syslog

### Protocole

|Protocole|Port|Sécurité|
|---|---|---|
|Syslog/UDP|514|❌ Non sécurisé|
|Syslog/TCP|514|⚠️ Moyen|
|Syslog over TLS|6514/TCP|✅ Recommandé|

> Standard IETF : **RFC 5424** — Toujours préférer TCP sur UDP (garantie de livraison)

### Structure d'un message syslog

`Date` | `Hôte` | `Service/PID` | `Type de message` | `Priorité` | `Message`

### Catégories (facility) — principales

|Code|Mot-clé|Description|
|---|---|---|
|0|kern|Noyau|
|1|user|Espace utilisateur|
|3|daemon|Services|
|4|auth|Authentification|
|9|cron|Tâches planifiées|
|10|authpriv|Élévation de privilèges|
|13|security|Audit|
|16–23|local0–7|Usage local libre|

### Niveaux de sévérité

|Code|Nom|Description|
|---|---|---|
|0|Emergency|Système inutilisable|
|1|Alert|Intervention immédiate|
|2|Critical|Erreur critique|
|3|Error|Erreur de fonctionnement|
|4|Warning|Avertissement|
|5|Notice|Événement normal notable|
|6|Info|Information|
|7|Debug|Débogage|

### Outils Linux essentiels

|Outil|Usage|
|---|---|
|`rsyslog`|Daemon de stockage (config : `/etc/rsyslog.conf`)|
|`journalctl`|Consultation logs systemd (binaire dans `/run/systemd/journal`)|
|`logrotate`|Rotation/archivage automatique (via cron)|
|`logger`|Envoyer un message syslog depuis bash|
|`grep`, `zgrep`|Filtrage de logs|
|`tail -f`|Suivi en temps réel|
|`dmesg`|Logs noyau|
|`last` / `lastb`|Historique connexions / échecs|

Stockage par défaut : `/var/log/` (ex : `auth.log`, `kern.log`, `syslog`)

---

## 3. Journalisation Windows — Event Viewer

### Accès

- Raccourci : `Win + R` → `eventvwr`
- Fichiers : `C:\Windows\System32\winevt\Logs`

### Organisation des journaux

|Catégorie|Contenu|
|---|---|
|Journaux Windows|OS (Application, Sécurité, Système)|
|Journaux applications et services|Applicatifs|
|Affichages personnalisés|Vues filtrées custom|
|Abonnements|Centralisation (WEF)|

### Event IDs importants

|ID|Événement|
|---|---|
|**4624**|Connexion réussie|
|**4625**|Échec de connexion|
|**4740**|Compte verrouillé|
|**4728**|Ajout à un groupe de sécurité global|
|**4732**|Ajout à un groupe de sécurité local|
|**4756**|Ajout à un groupe de sécurité universel|
|**4663**|Tentative d'accès à des objets sensibles|
|**1102**|Suppression des journaux ⚠️|

### Centralisation — Windows Event Forwarding (WEF)

|Protocole|Port|
|---|---|
|WinRM/HTTP|5985|
|WinRM/HTTPS|5986|

→ Gestion possible par **GPO**

---

## 4. Pour aller plus loin

- **logwatch**, **Graylog**, **LogAnalyzer** → automatiser l'analyse
- **HIDS** → détection d'intrusion basée sur les hôtes
- **SIEM** (Security Information and Event Management) → corrélation et alerting centralisé
- **SOC** → exploitation opérationnelle des logs