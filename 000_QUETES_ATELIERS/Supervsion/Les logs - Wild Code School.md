---
title: "Les logs - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3105/pages/11880"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Supervision

## Les logs

Introduction aux logs. Couvre les types de logs, leur interprétation, et les outils de gestion de base.

Moyen

3 pairs

Supervision

## Les logs

## Introduction

Dans cette quête, tu vas explorer le monde de la journalisation des événements qui se produisent sur un système informatique, plus communément appelé **journaux** ou **logs** système. Les logs sont des éléments cruciaux pour tout administrateur systèmes et réseaux. Ils sont essentiels pour le dépannage, la sécurité et la conformité dans un SI.

## 🤓 Objectifs:

✅ Comprendre l'importance des logs système  
✅ Connaître les différents types de logs  
✅ Apprendre à lire et interpréter les logs de base  
✅ Découvrir les outils de gestion des logs

## Sommaire

- [❓ Pourquoi les logs sont-ils importants?](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-pourquoi-les-logs-sont-ils-importants-)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-exercice)
- [📋 Types de logs courants](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-types-de-logs-courants)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-exercice-1)
- [🕵 Lecture et interprétation des logs](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-lecture-et-interpr%C3%A9tation-des-logs)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-exercice-2)
- [💻 Outils de gestion des logs](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-outils-de-gestion-des-logs)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-exercice-3)
- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/3105/pages/11880#-crit%C3%A8res-dacceptation)

## ❓ Pourquoi les logs sont-ils importants?

Les logs système jouent un rôle crucial dans la gestion et la maintenance des systèmes informatiques. Ce chapitre explique les différentes raisons pour lesquelles les logs sont indispensables, y compris pour le dépannage, la sécurité, la conformité, la performance et l'historique des événements système.

1. **Dépannage**: Permettent d'identifier et de résoudre les problèmes rapidement
2. **Sécurité**: Aident à détecter et à investiguer les incidents de sécurité
3. **Conformité**: Essentiels pour respecter les réglementations et les audits
4. **Performance**: Fournissent des insights sur les performances du système
5. **Historique**: Offrent un historique des événements système

Voici trois scénarios spécifiques où les logs seraient cruciaux pour un serveur web, avec des explications:

1. Détection d'une attaque par déni de service (DDoS):
	- Scénario: Le site web de l'entreprise devient soudainement lent ou inaccessible.
		- Importance des logs: Les logs de trafic du serveur web montreraient un nombre anormalement élevé de requêtes provenant de multiples adresses IP en un court laps de temps. Cela permettrait d'identifier rapidement l'attaque, de bloquer les IP malveillantes et de prendre des mesures pour atténuer l'impact.
2. Identification d'une faille de sécurité:
	- Scénario: Une page d'administration du site web a été accédée par un utilisateur non autorisé.
		- Importance des logs: Les logs d'accès et d'authentification montreraient les tentatives de connexion réussies et échouées, ainsi que les actions effectuées après la connexion. Cela aiderait à comprendre comment la faille a été exploitée, quelles données ont pu être compromises, et permettrait de renforcer la sécurité en conséquence.
3. Optimisation des performances du site web:
	- Scénario: Les utilisateurs se plaignent de temps de chargement lents sur certaines pages du site.
		- Importance des logs: Les logs de performance du serveur web (comme les temps de réponse) et les logs d'erreurs des applications permettraient d'identifier les pages ou les requêtes qui prennent le plus de temps à se charger. Cela aiderait à cibler les optimisations nécessaires, que ce soit au niveau du code, de la base de données ou de la configuration du serveur.

Ces scénarios démontrent comment les logs sont essentiels pour la sécurité, la performance et la résolution de problèmes sur un serveur web d'entreprise.

## 🔬 Exercice

Imagine que tu es responsable des logs réseau. Énumère un scénario spécifique dans lequel les logs seraient cruciaux et explique pourquoi.

---

## 📋 Types de logs courants

Les différents types de logs dans un système informatique fournissent des informations essentielles pour le dépannage, la sécurité et la gestion quotidienne des systèmes

1. **Logs système**: Événements liés au système d'exploitation
2. **Logs d'application**: Activités spécifiques aux applications
3. **Logs de sécurité**: Tentatives de connexion, modifications des droits d'accès
4. **Logs réseau**: Trafic réseau, connexions, pare-feu

## 🔬 Exercice

Sur ton système personnel (Windows ou Linux), trouve et identifie au moins deux types de logs différents. Note leur emplacement et décris brièvement leur contenu.

---

## 🕵 Lecture et interprétation des logs

Apprendre à lire et interpréter les logs est essentiel pour diagnostiquer les problèmes et comprendre le comportement du système. Les logs suivent généralement un format structuré comprenant un horodatage (ou *Timestamp*), un niveau de gravité, une source et un message détaillé.

La plupart des logs suivent un format similaire:

```shell
[Timestamp] [Niveau] [Source] Message
```

Exemple:

```shell
2023-07-27 14:30:15 [ERROR] [Apache] Failed to load module mod_ssl: No such file or directory
```

Niveaux de log courants:

- INFO: Informations générales
- WARNING: Avertissements potentiels
- ERROR: Erreurs nécessitant une attention
- CRITICAL: Problèmes critiques nécessitant une action immédiate

## 🔬 Exercice

Analyse l'entrée de log suivante et réponds aux questions:

```shell
2023-07-28 09:15:23 [WARNING] [FileSystem] Disk usage on /dev/sda1 has reached 85%
```
1. Quel est le timestamp de cet événement?
2. Quel est le niveau de log?
3. Quelle est la source du log?
4. Quel est le message principal?
5. Quelle action recommanderais-tu suite à ce log?

---

## 💻 Outils de gestion des logs

Pour gérer et analyser efficacement les logs, divers outils sont disponibles. Ces outils facilitent la collecte, le stockage, la recherche et l'analyse des logs, permettant ainsi une gestion proactive et réactive des systèmes.

- **journalctl**: Un outil puissant pour les systèmes utilisant systemd sur Linux. Il permet de visualiser et de filtrer les journaux systèmes de manière détaillée et flexible.
- **Event Viewer** (Observateur d'événements): L'outil intégré de Windows pour visualiser les événements système, applicatifs et de sécurité. Il aide à diagnostiquer les problèmes et à auditer les actions sur le système.
- **Elasticsearch, Logstash, Kibana (ELK Stack)**: Une suite d'outils pour la recherche, l'analyse et la visualisation des logs à grande échelle. Elasticsearch stocke et indexe les logs, Logstash collecte et transforme les données, et Kibana fournit des visualisations interactives.
- **Splunk**: Une plateforme commerciale pour la gestion et l'analyse des logs d'entreprise. Elle offre des capacités avancées de recherche, de surveillance et de visualisation des données en temps réel.
- **Graylog**: Une solution open-source pour la gestion centralisée des logs. Elle permet de collecter, indexer et analyser les logs de manière efficace, avec des capacités de recherche et de visualisation similaires à celles de l'ELK Stack.

Ces outils t'aideront à centraliser les logs provenant de différentes sources, à identifier les tendances, à détecter les anomalies et à réagir rapidement aux incidents. Ils sont essentiels pour maintenir la performance, la sécurité et la fiabilité des systèmes informatiques.

## 🔬 Exercice

Choisis l'un des outils mentionnés (par exemple, journalctl si tu es sur Linux, ou l'Observateur d'événements si tu es sur Windows). Utilise-le pour consulter les logs système des dernières 24 heures. Note trois événements intéressants que tu as trouvés et explique pourquoi ils ont attiré ton attention.

---

```shell
📚 Ressources complémentaires
Documentation officielle de journalctl
Guide de gestion des logs Linux
Introduction à l'ELK Stack
Bonnes pratiques en matière de logging
```

---

## 📝 Quiz

```shell
# 1  - [] Ils améliorent les performances du systèmeIls permettent d'identifier rapidement la source des problèmesIls empêchent les erreurs de se produireValider# 2 WARNINGINFOCRITICALValider# 3 Event ViewerjournalctltailValider# 4 TimestampNiveau de logAdresse IP de l'utilisateurValiderTon score :0 / 4
```

---

## 💪 Challenge

1. Installe un serveur web (Apache ou Nginx) sur une machine virtuelle Linux
2. Configure le logging pour enregistrer les accès et les erreurs
3. Génère du trafic sur le serveur web (utilise des outils comme curl ou un navigateur)
4. Analyse les logs générés et identifie:

## 🧐 Critères d'acceptation

- Ton serveur web est correctement configuré et génère des logs
- Tu peux expliquer la structure des logs de ton serveur web

Solution postée le **dimanche 01 février 2026**

[https://gist.github.com/LiudSwen/88472b0477977da15fff505902dc425e](https://gist.github.com/LiudSwen/88472b0477977da15fff505902dc425e)