# Sommaire

- [Rapport d'Audit de Sécurité Active Directory](#rapport-daudit-de-sécurité-active-directory)
- [1. Objectif de l'audit](#1-objectif-de-laudit)
- [2. Résumé exécutif](#2-résumé-exécutif)
- [3. Méthodologie](#3-méthodologie)
- [4. Synthèse des vulnérabilités identifiées](#4-synthèse-des-vulnérabilités-identifiées)
- [5. Mesures correctives mises en place](#5-mesures-correctives-mises-en-place)
  - [Désactivation des protocoles NTLMv1 et LM](#désactivation-des-protocoles-ntlmv1-et-lm)
  - [Renforcement de la politique de mot de passe](#renforcement-de-la-politique-de-mot-de-passe)
  - [Mise en place de la solution LAPS](#mise-en-place-de-la-solution-laps)
  - [Sécurisation des comptes administrateurs](#sécurisation-des-comptes-administrateurs)
  - [Protection des comptes sensibles](#protection-des-comptes-sensibles)
  - [Restriction de l'ajout de machines au domaine](#restriction-de-lajout-de-machines-au-domaine)
  - [Nettoyage du groupe Schema Admins](#nettoyage-du-groupe-schema-admins)
  - [Mise en place d'une sauvegarde Active Directory](#mise-en-place-dune-sauvegarde-active-directory)
- [6. Points restant à améliorer](#6-points-restant-à-améliorer)
  - [Utilisation du compte Administrator](#utilisation-du-compte-administrator)
  - [Mise en place d'une sauvegarde automatique](#mise-en-place-dune-sauvegarde-automatique)
  - [Supervision et journalisation](#supervision-et-journalisation)
- [7. Conclusion](#7-conclusion)
# Rapport d'Audit de Sécurité Active Directory

| Élément            | Information                                  |
| ------------------ | -------------------------------------------- |
| Client             | Environnement de test – Infrastructure BillU |
| Domaine audité     | billu.lan                                    |
| Outil d'audit      | PingCastle                                   |
| Type d'audit       | Audit de configuration Active Directory      |
| Date audit initial | 05/03/2026                                   |
| Date audit final   | 08/03/2026                                   |

---

## 1. Objectif de l'audit

Cet audit a pour objectif d'évaluer la configuration de sécurité de l'infrastructure Active Directory et d'identifier les vulnérabilités pouvant compromettre la sécurité du domaine.

L'analyse a été réalisée à l'aide de l'outil PingCastle, spécialisé dans l'audit de sécurité Active Directory.

> **PingCastle** analyse la configuration d'un domaine Active Directory et génère un score de risque de 0 à 100. Plus le score est élevé, plus le niveau de risque est important. L'objectif est d'atteindre un score le plus bas possible.

Les objectifs principaux sont :

- Identifier les faiblesses de configuration
- Vérifier l'application des bonnes pratiques Microsoft
- Proposer des mesures correctives
- Améliorer le niveau global de sécurité du domaine

---

## 2. Résumé exécutif

L'audit initial a mis en évidence plusieurs vulnérabilités liées à :

- L'utilisation de protocoles d'authentification obsolètes
- Des stratégies de sécurité insuffisantes
- Une protection incomplète des comptes administrateurs
- L'absence de mécanismes de sécurisation des comptes locaux

Suite à l'application des correctifs recommandés, le niveau de sécurité du domaine a été significativement amélioré.

| Étape | Score de risque |
|-------|----------------|
| Audit initial (V1) | 71 / 100 |
| Audit final (V8) | 21 / 100 |

La majorité des vulnérabilités critiques identifiées lors de l'audit initial ont été corrigées.

---

## 3. Méthodologie

L'audit a été réalisé en trois étapes :

**1. Analyse initiale**

Exécution de PingCastle sur le contrôleur de domaine afin d'identifier :

- Les vulnérabilités de configuration
- Les mauvaises pratiques
- Les paramètres de sécurité insuffisants

**2. Remédiation**

Application des recommandations fournies par l'outil d'audit afin de :

- Renforcer les paramètres de sécurité
- Corriger les vulnérabilités identifiées
- Améliorer la configuration Active Directory

**3. Vérification**

Un second audit a été réalisé afin de valider les corrections mises en place.

---

## 4. Synthèse des vulnérabilités identifiées

| Vulnérabilité                                     | Criticité | Statut                 |
| ------------------------------------------------- | --------- | ---------------------- |
| Protocoles NTLMv1 et LM autorisés                 | Élevée    | Corrigé                |
| Politique de mot de passe insuffisante            | Élevée    | Corrigé                |
| Audit des événements incomplet                    | Moyenne   | Corrigé                |
| Comptes administrateurs non protégés              | Élevée    | Corrigé                |
| Absence de LAPS                                   | Élevée    | Corrigé (A configurer) |
| Comptes sensibles délégables                      | Élevée    | Corrigé                |
| Ajout de machines au domaine par des utilisateurs | Moyenne   | Corrigé                |
| Groupe Schema Admins non vide                     | Moyenne   | Corrigé                |
| Sauvegarde Active Directory obsolète              | Élevée    | Corrigé                |
| Utilisation récente du compte Administrator       | Faible    | En observation         |

---

## 5. Mesures correctives mises en place

### Désactivation des protocoles NTLMv1 et LM

Les protocoles d'authentification obsolètes LM et NTLMv1 ont été désactivés. Le domaine utilise désormais NTLMv2 uniquement.

> **LM et NTLMv1** sont des protocoles d'authentification anciens présentant des failles connues. Ils permettent notamment à un attaquant d'intercepter et de rejouer des authentifications réseau, ou de récupérer des mots de passe à partir des hash capturés. NTLMv2 corrige ces failles en utilisant un mécanisme de défi-réponse plus robuste.

Cela réduit les risques liés aux attaques :

- Pass-the-Hash
- Interception d'authentification
- Récupération de hash NTLM

Une **GPO dédiée** a été configurée au niveau du domaine afin de définir le niveau d’authentification LAN Manager.

Configuration appliquée :
```
Computer Configuration  
 → Policies  
 → Windows Settings  
 → Security Settings  
 → Local Policies  
 → Security Options
```

Paramètre configuré :
`Network security: LAN Manager authentication level`

Valeur définie :
`Send NTLMv2 response only. Refuse LM & NTLM`

Cette configuration force l’utilisation du protocole **NTLMv2**, qui offre un mécanisme d’authentification plus robuste et empêche l’utilisation des protocoles obsolètes.

---

### Renforcement de la politique de mot de passe

La stratégie de sécurité du domaine a été modifiée afin d'imposer :

- Une longueur minimale de mot de passe de 8 caractères
- Une politique de sécurité conforme aux recommandations Microsoft

> Les recommandations Microsoft actuelles préconisent une longueur minimale de 12 à 14 caractères. Une évolution vers cette norme pourrait être envisagée lors d'un prochain cycle de renforcement.

La configuration a été appliquée dans la **Default Domain Policy**, qui définit les paramètres de sécurité pour l’ensemble des comptes du domaine.

Chemin de configuration :
```
Computer Configuration  
 → Policies  
 → Windows Settings  
 → Security Settings  
 → Account Policies  
 → Password Policy
```

Paramètre modifié :
`Minimum password length

Valeur définie :
`8 caractères minimum

Cette modification impose aux utilisateurs du domaine de définir des mots de passe plus robustes.

---

### Mise en place de la solution LAPS

La solution Microsoft LAPS (Local Administrator Password Solution) a été déployée. Cette solution permet :

- De générer un mot de passe unique pour chaque poste
- De renouveler automatiquement le mot de passe administrateur local
- De stocker ce mot de passe dans Active Directory

> Sans LAPS, le compte administrateur local de tous les postes partage souvent le même mot de passe. Si un attaquant le compromet sur une machine, il peut s'en servir pour se déplacer latéralement sur l'ensemble du parc. LAPS supprime ce risque en rendant chaque mot de passe unique et géré centralement.

Cela limite fortement les attaques de propagation latérale.

**/!\ LE LOGICIEL N'A PAS ÉTÉ CONFIGURÉ /!\**

---

### Sécurisation des comptes administrateurs

Les comptes administrateurs ont été ajoutés dans le groupe **Protected Users**.

> Le groupe **Protected Users** est un groupe de sécurité spécial introduit dans Windows Server 2012 R2. Tout compte membre de ce groupe bénéficie automatiquement de protections renforcées, sans configuration supplémentaire.

Ce groupe applique plusieurs protections :

- Désactivation de NTLM pour ces comptes
- Limitation de la durée de vie des tickets Kerberos
- Chiffrement fort obligatoire
- Interdiction du cache des mots de passe

---

### Protection des comptes sensibles

Les comptes administrateurs ont été configurés avec l'option **"This account is sensitive and cannot be delegated"**.

> La **délégation Kerberos** permet à un service d'agir au nom d'un utilisateur pour accéder à d'autres ressources. Si un compte administrateur est délégable, un attaquant ayant compromis un serveur peut potentiellement usurper l'identité de cet administrateur sur l'ensemble du domaine. Cette option empêche ce scénario.

Cette configuration a été appliquée via les propriétés du compte utilisateur dans **Active Directory Users and Computers**.

Chemin :
```
User Properties  
 → Account  
 → Account Options
```

Option activée :
`Account is sensitive and cannot be delegated

Cette option empêche l’utilisation de ces comptes dans les mécanismes de délégation Kerberos, limitant ainsi certains scénarios d’attaque.

---

### Restriction de l'ajout de machines au domaine

La valeur Active Directory `ms-DS-MachineAccountQuota` a été modifiée à 0.

> Par défaut, cette valeur est fixée à 10, ce qui signifie que n'importe quel utilisateur du domaine peut ajouter jusqu'à 10 machines. Un utilisateur malveillant pourrait en profiter pour intégrer une machine sous son contrôle dans le domaine et intercepter des authentifications. En passant cette valeur à 0, seuls les administrateurs peuvent désormais ajouter des machines.

La modification a été réalisée via **ADSI Edit**.

Valeur appliquée :
`0

Cette configuration empêche désormais les utilisateurs standards d’ajouter des machines au domaine. Seuls les administrateurs peuvent effectuer cette opération.

---

### Nettoyage du groupe Schema Admins

Le groupe **Schema Admins** a été vidé.

> Ce groupe possède des privilèges très élevés permettant de modifier le **schéma Active Directory**, c'est-à-dire la structure de base de tous les objets du domaine. Il doit être vide en permanence et n'être utilisé que le temps d'une opération spécifique nécessitant ces droits, puis vidé immédiatement après.

Cette opération a été réalisée dans :
```
Active Directory Users and Computers  
 → Users  
 → Schema Admins
```

Tous les membres présents ont été supprimés afin de respecter les bonnes pratiques de sécurité Microsoft.

Ce groupe ne doit être utilisé que temporairement lors de modifications spécifiques du schéma Active Directory.

---

### Mise en place d'une sauvegarde Active Directory

Une sauvegarde du contrôleur de domaine a été réalisée à l'aide de **Windows Server Backup**.

Une sauvegarde **System State** a été effectuée afin de permettre la restauration de :

- Active Directory
- SYSVOL
- Registre
- Configuration système

> Le **System State** est le composant minimal à sauvegarder pour pouvoir restaurer un contrôleur de domaine. Il contient la base de données Active Directory (NTDS.dit), le SYSVOL qui héberge les GPO et scripts de connexion, ainsi que les informations de configuration système indispensables au redémarrage du service.

La fonctionnalité suivante a été installée :
```
Windows Server Backup
```

Une sauvegarde **System State** a ensuite été exécutée.

Commande utilisée :
```
wbadmin start systemstatebackup
```

---

## 6. Points restant à améliorer

### Utilisation du compte Administrator

Le compte **Administrator** a été utilisé récemment pour certaines tâches d'administration.

Les bonnes pratiques recommandent :

- D'utiliser des comptes administrateurs nominatifs (ex : `adm.prenom.nom`)
- De réserver le compte `Administrator` intégré aux situations d'urgence uniquement

> L'utilisation d'un compte générique ne permet pas de savoir quel administrateur a réalisé quelle action. En cas d'incident, la traçabilité est indispensable pour comprendre ce qui s'est passé.

---

### Mise en place d'une sauvegarde automatique

Une sauvegarde manuelle a été réalisée. Il est recommandé de mettre en place :

- Une sauvegarde automatique quotidienne
- Une sauvegarde externalisée (hors site ou solution cloud)
- Des tests réguliers de restauration

> Une sauvegarde qui n'a jamais été testée en restauration est une sauvegarde dont on ne peut pas garantir le fonctionnement. Il est conseillé de tester la restauration au moins une fois par trimestre.

---

### Supervision et journalisation

Afin d'améliorer la détection d'incidents, il est recommandé de mettre en place :

- Une centralisation des journaux (solution de type SIEM)
- Une solution de supervision avec alertes
- Une analyse régulière des événements de sécurité

> Un **SIEM** (Security Information and Event Management) est une solution qui collecte et corrèle les journaux de l'ensemble des équipements du réseau. Il permet de détecter des comportements suspects en temps réel et de conserver un historique des événements pour les investigations.

---

## 7. Conclusion

L'audit de sécurité Active Directory a permis d'identifier plusieurs vulnérabilités liées à la configuration initiale du domaine.

La mise en place des mesures correctives a permis :

- D'améliorer significativement la sécurité du domaine (score PingCastle passé de 71 à 21)
- D'appliquer les bonnes pratiques Microsoft
- De réduire les risques liés aux attaques ciblant Active Directory

L'infrastructure présente désormais un niveau de sécurité satisfaisant, sous réserve de poursuivre les améliorations recommandées concernant la sauvegarde automatique, la traçabilité des comptes administrateurs et la mise en place d'une solution de supervision.

---
