# Installation du service DNS

## Vue d’ensemble

Dans cette infrastructure, le service DNS est **installé automatiquement** lors de la mise en place du rôle **Active Directory Domain Services (AD DS)**.

Aucune installation manuelle du rôle DNS n’a été effectuée.

---

## Dépendance entre AD DS et DNS

Active Directory repose entièrement sur le service DNS pour :

- La résolution de noms interne
- La localisation des contrôleurs de domaine
- L’enregistrement dynamique des machines du domaine

Pour cette raison, Microsoft impose la présence d’un serveur DNS lors de la promotion d’un contrôleur de domaine.

---

## Installation du DNS via AD DS

Le service DNS a été installé automatiquement lors des étapes suivantes :

1. Installation du rôle **Active Directory Domain Services**
2. Promotion du serveur en **contrôleur de domaine**
3. Activation du rôle **DNS** pendant l’assistant de promotion AD DS

À l’issue de cette procédure :
- Le rôle DNS est présent sur le serveur
- La zone DNS directe du domaine (`billu.lan`) est créée automatiquement
- Le DNS est intégré à Active Directory

---

## Justification du choix

Cette méthode respecte les bonnes pratiques Microsoft :

- DNS intégré à AD DS
- Réplication automatique via Active Directory
- Gestion centralisée des zones DNS
- Sécurisation des mises à jour dynamiques

Aucune installation séparée du service DNS n’est nécessaire dans ce contexte.
