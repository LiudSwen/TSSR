---
title: "Atelier : analyse de logs avec Sysmon et Log Parser - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2372/pages/10985"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Atelier: analyse de logs avec Sysmon et Log Parser

Facile

1h

Auto-validation

Windows

## Atelier: analyse de logs avec Sysmon et Log Parser

## Introduction

En plus de l'observateur d’événements inclus dans Windows, on peut utiliser des outils pour aller plus loin dans l'analyse de logs.  
Ici on va utiliser Sysmon, qui est un outil qui se greffe à l'observateur d’événements Windows pour enregistrer toutes les actions se passant sur une machine. On peut complètement le paramétrer avec un fichier xml.  
Log Parser est un autre logiciel qui va nous servir à analyser les logs enregistrés.

![image](https://www.loggly.com/wp-content/uploads/2018/11/Angular-2-exception-handling-made-simple-with-logging-O.png)

## 🤓 Objectifs:

✅ Utiliser un outil externe de journalisation avancée  
✅ Faire du parsing de fichiers de logs

## sommaire

- [👉 Prérequis](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-pr%C3%A9requis)
- [📰 Sysmon](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-sysmon)
	- [🔬 Installation de Sysmon](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-installation-de-sysmon)
		- [🔬 Visualisation du journal de Sysmon](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-visualisation-du-journal-de-sysmon)
		- [🔬 Configuration avec un fichier xml](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-configuration-avec-un-fichier-xml)
- [✂️ Log Parser](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#%EF%B8%8F-log-parser)
	- [🔬 Installation et lancement de Log Parser](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-installation-et-lancement-de-log-parser)
- [💪 Conclusion](https://odyssey.wildcodeschool.com/quests/2372/pages/10985#-conclusion)

## 👉 Prérequis

Tu dois avoir 1 VM configurée de cette manière:

- OS: `Windows server 2022`
- Carte réseau avec accès internet

## 📰 Sysmon

**Sysmon** est un outil de monitoring des journaux d'événements sous Windows. Avec Sysmon on peut monitorer les actions sur le système telles que la création de processus ou de comptes utilisateurs, les connexions réseaux ou encore la création de fichiers.  
Il peut être utilisé seul ou couplé avec un serveur configuré avec Windows Event Collector. Dans ce cas, il récupère les logs Windows de plusieurs machines en un point unique.

```shell
En savoir plus sur SysmonLes informations de paramétrage et la source de téléchargement du logiciel.https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon
```

## 🔬 Installation de Sysmon

Télécharger Sysmon à l'aide du lien ci-dessus.  
Décompresser le dossier Sysmon et installer le logiciel à l'aide de la documentation.

A la fin de l'installation, le message `Sysmon64 started.` apparait pour indiquer que le service sysmon est en statut `running`.  
Lance la commande PowerShell `Get-Service -Name Sysmon64` pour le vérifier.

## 🔬 Visualisation du journal de Sysmon

Va dans l'Event Viewer.  
Cherche le journal **Operational** qui est dans `Applications and services Logs --> Microsoft --> Windows --> Sysmon`  
Effectue les actions suivantes et regarde les modifications dans le journal **Operational**:

- Echec d'ouverture de session
- Ouverture d'une session
- Lancement d'une application (calculatrice, notepad,...)
```shell
Tu peux ajouter des colonnes à ce journal si tu souhaites avoir des informations supplémentaires
```

## 🔬 Configuration avec un fichier xml

Télecharger le fichier `sysmonconfig-export.xml` qui est disponible [ici](https://github.com/SwiftOnSecurity/sysmon-config/blob/master/sysmonconfig-export.xml).

```shell
Ce fichier est une base de travail. Tu peux l'utiliser tel quel, mais tu peux également le personnaliser ou n'en prendre que quelques morceaux.
```

Quelques exemples du contenu de ce fichier xml:

- à partir de la ligne 85: monitoring en lien avec certains processus système (indexeur Windows, Synchronisation de fichiers réseaux,...)
- à partir de la ligne 260: monitoring en lien avec les connexions réseaux

Relancer **Sysmon64** avec l'option `-c` en indiquant l'emplacement et le nom du fichier xml.  
Aller voir dans la fenêtre du journal `Operational` les différences d'affichage.

Une vidéo montrant une modification du fichier xml:

## ✂️ Log Parser

Log Parser est un outil polyvalent qui fournit un accès universel aux données textuelles telles que les fichiers journaux, les fichiers XML et les fichiers CSV, le registre, le système de fichiers et Active Directory.  
On indique à Log Parser les informations dont on a besoin et comment on souhaite les traiter. Les résultats de la requête peuvent être formatés de manière personnalisée dans une sortie textuelle, ou ils peuvent être conservés dans des cibles plus spécialisées telles que SQL, SYSLOG ou un graphique.

```shell
En savoir plus sur Log ParserLa source de téléchargement de Log Parser.https://www.microsoft.com/en-us/download/details.aspx?id=24659
```

## 🔬 Installation et lancement de Log Parser

Télécharger Log Parser à partir de la source ci-dessus et l'installer sur le système.  
Ouvrir une fenêtre de terminal et se placer dans le dossier d'installation de Log Parser, soit `C:\Program Files (x86)\Log Parser 2.2`.

Copier un journal se trouvant dans `C:\Windows\System32\winevt\Logs` dans un autre dossier (par exemple c:\\Temp) et exécuter la commande ci-dessous:

> Ici c'est le journal `Application.evtx` qui a été copié

```powershell
1
c:\Program Files (x86)\Log Parser 2.2>LogParser.exe -stats:OFF -i:EVT "SELECT EventID, SourceName, ComputerName, TimeGenerated, SUBSTR(Message, 0, 50) AS TruncatedMessage FROM 'C:\temp\Application.evtx' WHERE ComputerName = 'WINSERV1'"
```

Tu dois avoir un résultat à peu près identique à ceci:

```shell
EventID SourceName                              ComputerName TimeGenerated       TruncatedMessage
------- --------------------------------------- ------------ ------------------- --------------------------------------------------
4625    EventSystem                             WINSERV1     2023-11-24 01:26:49 The description for Event ID 4625 in Source "Event
1531    Microsoft-Windows-User Profiles Service WINSERV1     2023-11-24 01:26:49 The User Profile Service has started successfully.
900     Software Protection Platform Service    WINSERV1     2023-11-24 01:26:50 The Software Protection service is starting. Param
5615    Microsoft-Windows-WMI                   WINSERV1     2023-11-24 01:26:50 Windows Management Instrumentation Service started
[...]
```
```shell
Ici on a choisi de personnaliser le format de sortie avec les informations qui nous intéresse.
```

Explications de la ligne de commande:

- `-stats:OFF`: Désactive l'affichage des statistiques
- `-i:EVT`: Spécifie le format d'entrée des données, ici un fichier d'événements Windows **.evtx**
- `SELECT ... FROM`: requête de type SQL pour choisir les champs qui seront affichés en colonne
- `SUBSTR(Message, 0, 50) AS TruncatedMessage`: Utilisation de la fonction **SUBSTR** pour extraire les 50 premiers caractères du champ Message de chaque entrée. `AS TruncatedMessage` renomme cette colonne tronquée en **TruncatedMessage**
- `WHERE ComputerName = 'WINSERV1'`: Filtrage des résultats pour n'inclure que les entrées où le `ComputerName` est égal à **WINSERV1**

Tu trouveras d'autres exemples d'utilisation de log parser [ici](https://gist.github.com/exp0se/1bae653b790cf5571d20)

Une petite vidéo pour te montrer comment faire du forensics avec Log Parser:

---

## 💪 Conclusion

Valide l'atelier une fois que tu as installer les 2 logiciels et que tu as des enregistrements de fichiers de logs correct et des requêtes qui fonctionnent.

Quête terminée le **mercredi 04 février 2026**