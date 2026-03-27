## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Outils installés](#5-outils-installés)
6. [Fonctionnalités](#6-fonctionnalités)
7. [Maintenance](#7-maintenance)
8. [Références](#8-références)
9. [Contributeurs](#9-contributeurs)

---

## 1. Vue d'ensemble

Ce document présente l'infrastructure de supervision Zabbix déployée dans le cadre du **Projet 3 - Build Your Infra** pour l'entreprise fictive **BillU**.

**Informations générales :**
- **Nom du serveur :** DOM-ZABBIX-01
- **Type :** VM Ubuntu Server
- **IP :** 172.16.13.3 (VLAN 130 - Serveurs)
- **Version Zabbix :** 7.4 LTS
- **Base de données :** PostgreSQL 15
- **Interface Web :** Zabbix Frontend (Apache2)

**Rôle :**
Zabbix assure la supervision centralisée de l'infrastructure BillU, incluant :
- Monitoring des serveurs Windows et Linux
- Surveillance réseau (équipements VyOS, pfSense)
- Collecte de métriques système (CPU, RAM, disque, réseau)
- Alertes et notifications en cas d'incident
- Tableaux de bord personnalisés

---

## 2. Objectifs

### Objectifs principaux

1. **Supervision centralisée**
   - Surveiller l'ensemble des serveurs de l'infrastructure BillU
   - Collecter les métriques de performance en temps réel
   - Détecter les anomalies et incidents

2. **Alerting proactif**
   - Configurer des déclencheurs pour les événements critiques
   - Envoyer des notifications automatiques aux administrateurs
   - Réduire le temps de réponse aux incidents

3. **Reporting et historique**
   - Conserver l'historique des performances
   - Générer des rapports d'activité
   - Analyser les tendances à long terme

4. **Conformité projet**
   - Répondre aux exigences du Sprint 3 du Projet 3
   - Documenter l'infrastructure de supervision
   - Faciliter la maintenance et l'évolution

---

## 3. Architecture

### 3.1 Emplacement réseau

| Élément             | VLAN     | Réseau         | Rôle                      |
| ------------------- | -------- | -------------- | ------------------------- |
| DOM-ZABBIX-01       | VLAN 130 | 172.16.13.0/24 | Serveur de supervision    |
| Serveurs supervisés | VLAN 130 | 172.16.13.0/24 | Serveurs d'infrastructure |
| PC Admin            | VLAN 150 | 172.16.6.0/24  | Accès interface web       |

### 3.2 Ports et protocoles

| Service | Port | Protocole | Usage |
|---------|------|-----------|-------|
| Zabbix Server | 10051 | TCP | Communication serveur ↔ agents |
| Zabbix Agent 2 | 10050 | TCP | Collecte de données |
| Interface Web | 80/443 | HTTP/HTTPS | Accès frontend |
| PostgreSQL | 5432 | TCP | Base de données (local) |
| SNMP | 161 | UDP | Monitoring équipements réseau |

---

## 4. Structure de la documentation

- **README.md** - Ce fichier
- **[installation.md](components/Zabbix/installation.md)**- Procédure d'installation complète
- **[configuration.md](components/Zabbix/configuration.md)** - Configuration du logiciel installée
- **ressources/**


---
## 5. Outils installés

### 5.1 Composants Zabbix

| Composant                    | Version | Description                          |
| ---------------------------- | ------- | ------------------------------------ |
| **Zabbix Server**            | 7.4 LTS | Serveur principal de supervision     |
| **Zabbix Frontend**          | 7.4 LTS | Interface web de gestion             |
| **Zabbix Agent 2**           | 7.4 LTS | Agent de collecte (serveurs Linux)   |
| **Zabbix Agent 2 (Windows)** | 7.4 LTS | Agent de collecte (serveurs Windows) |

### 5.2 Dépendances système

| Logiciel | Version | Rôle |
|----------|---------|------|
| **PostgreSQL** | 15 | Base de données principale |
| **Apache2** | 2.4+ | Serveur web pour frontend |
| **PHP-FPM** | 8.2 | Traitement des pages PHP |
| **SNMP** | Net-SNMP | Monitoring équipements réseau |

---

## 6. Fonctionnalités

### 6.1 Supervision des serveurs

**Serveurs Windows supervisés :**
- DOM-AD-01 (Contrôleur de domaine)
- DOM-DHCP-01 (Serveur DHCP)
- DOM-LOGS-01 (Serveur Graylog)
- DOM-GLPI-01 (Serveur GLPI)
- DOM-FS-01 (Serveur de fichiers)
- DOM-WEBINT-01 (Serveur WEB Interne)

**Métriques collectées :**
- Utilisation CPU, RAM, disque
- Services Windows critiques
- Événements système (Event Viewer)
- Performance réseau

**Serveurs Linux supervisés :**
- DOM-LOGS-01 (Serveur de logs)
- DOM-GLPI-01 (Gestion de parc)

**Métriques collectées :**
- Load average, CPU, RAM, disque
- Processus et services systemd
- Logs système (/var/log/syslog)
- Connexions réseau

### 6.2 Supervision réseau

**Équipements :**
- VyOS (Routeur inter-VLAN)
- pfSense (Firewall)

**Protocole :** SNMP v2c

**Données collectées :**
- État des interfaces réseau
- Trafic entrant/sortant
- Utilisation CPU/RAM
- Uptime

### 6.3 Alertes et notifications

**Types d'alertes configurées :**
- **Warning** : Seuils d'avertissement (CPU > 70%, RAM > 80%)
- **Critical** : Incidents critiques (Service arrêté, disque > 90%)
-  **Information** : Événements d'information (Serveur redémarré)

**Canaux de notification :**
- Email (administrateurs)
- Interface web Zabbix
- Logs système

### 6.4 Tableaux de bord

**Dashboards disponibles :**
1. **Vue d'ensemble infrastructure** : État global des serveurs
2. **Performance serveurs** : Graphiques CPU/RAM/Disque
3. **Réseau** : Trafic et état des interfaces
4. **Alertes actives** : Liste des problèmes en cours

---

## 7. Maintenance

### 7.1 Tâches quotidiennes

- Vérifier les alertes actives dans le dashboard
- Contrôler l'état de santé des agents
- Valider la collecte des métriques

### 7.2 Tâches hebdomadaires

- Vérifier l'espace disque du serveur Zabbix
- Consulter les rapports de performance
- Mettre à jour les seuils d'alerte si nécessaire

### 7.3 Tâches mensuelles

- Sauvegarde complète de la base PostgreSQL
- Export des templates et configurations
- Génération de rapports mensuels
- Audit des hôtes et templates obsolètes

### 7.4 Sauvegardes

**Base de données PostgreSQL :**
```bash
# Sauvegarde manuelle
sudo -u postgres pg_dump zabbix > /backup/zabbix_$(date +%Y%m%d).sql

# Restauration
sudo -u postgres psql zabbix < /backup/zabbix_20250208.sql
```

**Configuration Zabbix :**
```bash
# Export des templates (via interface web)
Administration → General → Import/Export

# Sauvegarde des fichiers de configuration
tar -czf /backup/zabbix-config_$(date +%Y%m%d).tar.gz \
  /etc/zabbix/ \
  /usr/lib/zabbix/
```

### 7.5 Mise à jour

**Procédure de mise à jour Zabbix :**
1. Sauvegarder la base de données
2. Arrêter les services Zabbix
3. Mettre à jour les paquets
4. Vérifier la configuration
5. Redémarrer les services
```bash
# Arrêt des services
sudo systemctl stop zabbix-server zabbix-agent2

# Mise à jour
sudo apt update
sudo apt upgrade zabbix-server-pgsql zabbix-frontend-php zabbix-apache-conf zabbix-agent2

# Redémarrage
sudo systemctl start zabbix-server zabbix-agent2
sudo systemctl status zabbix-server
```

---

## 8. Références

### 8.1 Documentation officielle

- **Zabbix Documentation** : https://www.zabbix.com/documentation/7.0/
- **Zabbix Agent 2** : https://www.zabbix.com/documentation/7.0/manual/appendix/agent2
- **PostgreSQL 15** : https://www.postgresql.org/docs/15/

### 8.2 Templates utilisés

- **Template OS Windows by Zabbix Agent 2**
- **Template OS Linux by Zabbix Agent 2**
- **Template Net Network Generic Device SNMP**

### 8.4 Guides internes

- Configuration SSH par clé publique
- Nomenclature BillU
- Procédures de sauvegarde

---

## 9. Contributeurs

### Équipe G1 - TSSR Projet 3

| Membre        | Rôle                      | Responsabilités                                 |
| ------------- | ------------------------- | ----------------------------------------------- |
| **Franck**    | Scrum Master / Technicien | Architecture, déploiement Zabbix, documentation |
| **Christian** | Technicien                |                                                 |
| **Matthias**  | Technicien                |                                                 |

---

- **Formation** : TSSR (Technicien Supérieur Systèmes et Réseaux)
- **Projet** : Projet 3 - Build Your Infra
- **Sprint** : Sprint 2 - Supervision et monitoring
- **Entreprise fictive** : BillU
- **Période** : Février 2025

---
