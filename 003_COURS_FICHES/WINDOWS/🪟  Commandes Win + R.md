
```table-of-contents
```toc
minLevel: 2
maxLevel: 2
```
---


## 🔧 Gestion et Administration Système

|Commande|Description|
|---|---|
|`compmgmt.msc`|Console de gestion de l'ordinateur (périphériques, disques, services, utilisateurs)|
|`compmgmt.msc /computer=PCNAME`|Gestion d'un ordinateur distant sur le réseau|
|`control`|Panneau de configuration Windows classique|
|`control system`|Propriétés système (nom PC, domaine, RAM)|
|`control userpasswords2`|Gestion avancée des utilisateurs et connexion automatique|
|`control admintools`|Outils d'administration Windows|
|`control netconnections`|Connexions réseau|
|`control printers`|Périphériques et imprimantes|
|`control keyboard`|Propriétés du clavier|
|`taskmgr`|Gestionnaire des tâches|
|`taskmgr /0`|Gestionnaire des tâches - Onglet Processus|
|`taskmgr /1`|Gestionnaire des tâches - Onglet Performance|
|`msconfig`|Configuration du système et options de démarrage|
|`regedit`|Éditeur du registre Windows ⚠️|
|`regedit /s fichier.reg`|Import silencieux d'un fichier de registre|
|`regedit /e export.reg`|Exporte tout le registre dans un fichier|
|`perfmon`|Moniteur de performances système|
|`perfmon /res`|Moniteur de ressources (CPU, RAM, disque, réseau détaillé)|
|`perfmon /report`|Génère un rapport de diagnostic système automatique|
|`resmon`|Moniteur de ressources en temps réel|
|`msinfo32`|Informations système complètes (matériel, logiciel, composants)|
|`dxdiag`|Outil de diagnostic DirectX (carte graphique, son, pilotes)|
|`systempropertiesadvanced`|Propriétés système avancées (variables d'environnement, performances)|
|`systempropertiesperformance`|Options de performances visuelles|
|`systempropertiesprotection`|Restauration du système et points de restauration|
|`sysdm.cpl`|Propriétés système (nom ordinateur, domaine, matériel)|

---

## 🔒 Sécurité et Stratégies

|Commande|Description|
|---|---|
|`gpedit.msc`|Éditeur de stratégie de groupe locale (Pro/Enterprise uniquement)|
|`secpol.msc`|Stratégies de sécurité locale (mots de passe, audit, droits)|
|`wf.msc`|Pare-feu Windows Defender avec sécurité avancée|
|`certmgr.msc`|Gestionnaire de certificats (utilisateur actuel)|
|`certlm.msc`|Gestionnaire de certificats (machine locale)|
|`tpm.msc`|Gestion du module de plateforme sécurisée TPM|
|`fvenotif`|Notification de chiffrement de lecteur BitLocker|

---

## 👥 Utilisateurs et Comptes

|Commande|Description|
|---|---|
|`netplwiz`|Comptes utilisateurs (interface moderne)|
|`lusrmgr.msc`|Utilisateurs et groupes locaux (Pro/Enterprise uniquement)|
|`azman.msc`|Gestionnaire d'autorisations|
|`credwiz`|Assistant de sauvegarde et restauration des mots de passe|

---

## 💾 Stockage et Disques

|Commande|Description|
|---|---|
|`diskmgmt.msc`|Gestion des disques et partitions ⚠️|
|`cleanmgr`|Nettoyage de disque (fichiers temporaires, cache)|
|`cleanmgr /d C:`|Nettoyage du lecteur C: spécifiquement|
|`cleanmgr /sageset:1`|Configure un profil de nettoyage personnalisé|
|`cleanmgr /sagerun:1`|Exécute le profil de nettoyage 1 automatiquement|
|`dfrgui`|Optimisation et défragmentation des lecteurs|
|`sdclt`|Assistant de sauvegarde et restauration Windows|
|`fsmgmt.msc`|Gestion des dossiers partagés|
|`shrpubw`|Assistant de création de dossiers partagés|

---

## 🖨️ Matériel et Périphériques

|Commande|Description|
|---|---|
|`devmgmt.msc`|Gestionnaire de périphériques (pilotes, matériel)|
|`hdwwiz.cpl`|Assistant d'ajout de matériel|
|`printmanagement.msc`|Gestion de l'impression (imprimantes réseau et locales)|
|`printui`|Interface utilisateur d'imprimante|
|`joy.cpl`|Contrôleurs de jeu (calibration manettes)|
|`irprops.cpl`|Propriétés infrarouge|
|`tabletpc.cpl`|Paramètres de Tablet PC et stylet|

---

## 🌐 Réseau

| Commande       | Description                                        |
| -------------- | -------------------------------------------------- |
| `ncpa.cpl`     | Connexions réseau (configuration IP, DNS, VPN)     |
| `inetcpl.cpl`  | Propriétés Internet (proxy, certificats, sécurité) |
| `firewall.cpl` | Pare-feu Windows (interface simple)                |
| `WFS.msc`      | Fax et numérisation Windows                        |
| `rstrui`       | Restauration du système                            |

---

## 🔧 Services et Composants

|Commande|Description|
|---|---|
|`services.msc`|Gestionnaire de services Windows|
|`appwiz.cpl`|Programmes et fonctionnalités (désinstallation)|
|`optionalfeatures`|Activer/désactiver des fonctionnalités Windows (Hyper-V, WSL, IIS)|
|`wuapp`|Windows Update (vérification des mises à jour)|
|`wusa`|Programme d'installation autonome de Windows Update|
|`cliconfg`|Utilitaire de configuration réseau du client SQL Server|
|`odbcad32`|Administrateur de sources de données ODBC (32 bits)|
|`odbccp32.cpl`|Panneau de configuration ODBC|

---

## 🗃️ Observateur et Journaux

|Commande|Description|
|---|---|
|`eventvwr.msc`|Observateur d'événements (journaux système et applicatifs)|
|`eventvwr.msc /c:System`|Ouvre directement le journal Système|
|`eventvwr.msc /c:Application`|Ouvre directement le journal Application|
|`eventvwr.msc /c:Security`|Ouvre directement le journal Sécurité|
|`perfmon.msc`|Analyseur de performances|
|`taskschd.msc`|Planificateur de tâches|

---

## 🖼️ Interface et Personnalisation

|Commande|Description|
|---|---|
|`desk.cpl`|Paramètres d'affichage (résolution, multi-écrans)|
|`main.cpl`|Propriétés de la souris (sensibilité, boutons)|
|`mmsys.cpl`|Propriétés du son (périphériques audio, volume)|
|`dpiscaling`|Mise à l'échelle DPI (écrans haute résolution)|
|`displayswitch`|Projection sur deuxième écran (Win+P)|
|`colorcpl`|Gestion des couleurs (calibration écran)|
|`eudcedit`|Éditeur de caractères privés|
|`fontview`|Visionneuse de polices|
|`magnify`|Loupe Windows (accessibilité)|
|`narrator`|Narrateur Windows (lecture d'écran)|
|`osk`|Clavier visuel à l'écran|
|`sndvol`|Mélangeur de volume|
|`charmap`|Table des caractères|
|`write`|WordPad|
|`notepad`|Bloc-notes|
|`calc`|Calculatrice|
|`mspaint`|Paint|
|`snippingtool`|Outil Capture d'écran|
|`mstsc`|Connexion Bureau à distance|
|`psr`|Outil Enregistreur d'actions utilisateur (capture pas à pas)|

---

## ⏰ Système et Langue

|Commande|Description|
|---|---|
|`timedate.cpl`|Date et heure (fuseau horaire, synchronisation NTP)|
|`intl.cpl`|Options régionales (formats date/heure, langue, devise)|
|`lpksetup`|Assistant d'installation/désinstallation de langues d'affichage|

---

## 💻 Outils en ligne de commande

|Commande|Description|
|---|---|
|`cmd`|Invite de commandes DOS|
|`cmd /k commande`|Exécute une commande puis reste ouvert|
|`cmd /c commande`|Exécute une commande puis se ferme|
|`powershell`|Windows PowerShell|
|`powershell -NoExit -Command "commande"`|Exécute une commande PowerShell puis reste ouvert|
|`powershell_ise`|PowerShell ISE (environnement de développement)|
|`wmic`|Windows Management Instrumentation Command ⚠️ Déprécié|

---

## 🗂️ Explorateur de fichiers et emplacements

|Commande|Description|
|---|---|
|`explorer`|Explorateur Windows (Ce PC)|
|`explorer C:\`|Ouvre le lecteur C:|
|`explorer %appdata%`|Dossier AppData Roaming utilisateur|
|`explorer %localappdata%`|Dossier AppData Local utilisateur|
|`explorer %temp%`|Dossier temporaire utilisateur|
|`explorer %programfiles%`|Dossier Program Files|
|`explorer %windir%`|Dossier Windows|
|`explorer %systemroot%`|Racine système Windows|
|`explorer %userprofile%`|Dossier du profil utilisateur|
|`explorer shell:startup`|Dossier de démarrage automatique utilisateur|
|`explorer shell:common startup`|Dossier de démarrage automatique tous utilisateurs|
|`explorer shell:sendto`|Dossier "Envoyer vers"|
|`explorer shell:recent`|Documents récents|
|`explorer shell:downloads`|Dossier Téléchargements|
|`explorer shell:desktop`|Bureau|
|`explorer shell:fonts`|Dossier des polices|
|`explorer .`|Ouvre le répertoire de travail actuel|
|`.`|Raccourci pour explorer le dossier utilisateur|
|`..`|Dossier parent du répertoire actuel|

---

## 🛠️ Dépannage et Diagnostic

|Commande|Description|
|---|---|
|`sigverif`|Vérification de signature des fichiers système|
|`sfc /scannow`|Analyse et répare les fichiers système corrompus (via cmd)|
|`verifier`|Gestionnaire de vérification des pilotes|
|`iexpress`|Assistant de création d'archives auto-extractibles|
|`mrt`|Outil de suppression de logiciels malveillants Windows|
|`winver`|Affiche la version de Windows|
|`slui`|Activation de Windows|
|`shutdown`|Arrêt, redémarrage ou mise en veille (nécessite paramètres)|
|`logoff`|Déconnecte l'utilisateur actuel|
|`tskill`|Termine un processus par nom ou ID|

---

## 📊 Gestion des ordinateurs et domaines

|Commande|Description|
|---|---|
|`dsa.msc`|Utilisateurs et ordinateurs Active Directory (nécessite RSAT)|
|`domain.msc`|Domaines et approbations Active Directory (nécessite RSAT)|
|`dssite.msc`|Sites et services Active Directory (nécessite RSAT)|
|`gpmc.msc`|Console de gestion des stratégies de groupe (nécessite RSAT)|
|`rsop.msc`|Jeu de stratégies résultant (analyse des GPO appliquées)|

---

## 🌐 Outils Internet et Réseau avancés

|Commande|Description|
|---|---|
|`iexplore`|Internet Explorer|
|`ras`|Service d'accès distant|
|`rasphone`|Numéroteur réseau|
|`rasdial`|Connexion d'accès distant|
|`napclcfg.msc`|Configuration client NAP (Network Access Protection)|

---

## 💼 Outils de sauvegarde et récupération

|Commande|Description|
|---|---|
|`wbadmin`|Outil de sauvegarde Windows (ligne de commande)|
|`rekeywiz`|Assistant de sauvegarde et restauration du certificat de chiffrement|
|`migwiz`|Assistant Transfert de fichiers et paramètres Windows|

---

## 📱 Périphériques mobiles

|Commande|Description|
|---|---|
|`wmplayer`|Windows Media Player|
|`dvdplay`|Lecture DVD Windows|
|`syncapp`|Centre de synchronisation|
|`presentationsettings`|Paramètres de présentation (désactive écran de veille, ajuste volume)|

---

## 🎮 Jeux et Multimédia

|Commande|Description|
|---|---|
|`mplay32`|Windows Media Player (version ancienne)|
|`soundrecorder`|Magnétophone Windows (enregistrement audio)|

---

## ⚙️ Utilitaires système avancés

|Commande|Description|
|---|---|
|`utilman`|Gestionnaire d'utilitaires (options d'ergonomie)|
|`esentutl`|Utilitaire de base de données ESE|
|`bthprops.cpl`|Propriétés Bluetooth|
|`telephon.cpl`|Informations d'emplacement téléphonique|
|`powercfg.cpl`|Options d'alimentation|
|`wscui.cpl`|Centre de sécurité et maintenance Windows|
|`Firewall.cpl`|Pare-feu Windows (paramètres de base)|