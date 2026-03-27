
## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
   - [3.1 Serveurs impliqués](#31-serveurs-impliqués)
1. [Structure de la documentation](#4-structure-de-la-documentation)
2. [Services installés](#5-services-installés)
3. [Maintenance](#6-maintenance)
   - [6.1 Sauvegardes](#61-sauvegardes)
   - [6.2 Monitoring](#62-monitoring)
7. [Références](#7-références)
8. [Historique des modifications](#8-historique-des-modifications)
9. [Contributeurs](#9-contributeurs)

---

## 1. Vue d'ensemble

Le routeur **VyOS** est l'élément central de la segmentation réseau de l'infrastructure BillU.

- **Nom du routeur** : VYOS-ROUTER-01
- **Type** : Routeur logiciel open-source (basé sur Debian)
- **Plateforme** : Machine virtuelle Proxmox VE


---

## 2. Objectifs

- **Routage inter-VLAN** : Communication entre les différents segments réseau (Administration, Serveurs, Clients, Téléphonie)
- **Relais DHCP** : Transmission des requêtes DHCP depuis les VLANs clients vers le serveur DHCP centralisé
- **Segmentation réseau** : Séparation logique du trafic via VLAN
- **Passerelle par défaut** : Point de sortie pour chaque VLAN vers les autres réseaux

---

## 3. Architecture

### 3.1 Serveurs impliqués

- **VYOS-ROUTER-01** : Routeur principal pour le routage inter-VLAN et DHCP relay
- **DOM-DHCP-01** : Serveur DHCP cible pour le relay (VLAN 120)

---

## 4. Structure de la documentation

- **README.md** - Ce fichier
- **[installation.md](components/Vyos_routeur/installation.md)**- Procédure d'installation complète
- **[configuration.md](components/Vyos_routeur/configuration.md)** - Configuration des interfaces, VLANs, routage et DHCP relay
- **ressources/**
- **screenshots/** - Captures d'écran
  

---

## 5. Services installés

- **Routage inter-VLAN** - Routage entre les VLANs
- **DHCP Relay** - Relais DHCP vers serveur centralisé
- **SSH Server** - Accès distant sécurisé (port 22)

---

## 6. Maintenance

### 6.1 Sauvegardes

### 6.2 Monitoring


---

## 7. Références


---

## 8. Historique des modifications

| Date       | Auteur | Modification                         |
| ---------- | ------ | ------------------------------------ |
| 28/01/2026 | Franck | Documentation installation terminée  |
| 28/01/2026 | Franck | Documentation configuration terminée |
| 28/01/2026 | Franck | Documentation README terminée        |
|            |        |                                      |
|            |        |                                      |

---

## 9. Contributeurs

- **Franck** - Installation et configuration, documentation
- **Franck & Matthias** - Tests et validation


---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 2  
**Dernière mise à jour** : 28/01/2026
