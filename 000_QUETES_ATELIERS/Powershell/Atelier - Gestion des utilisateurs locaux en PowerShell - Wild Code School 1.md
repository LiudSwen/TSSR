---
title: "Atelier - Gestion des utilisateurs locaux en PowerShell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3954/pages/18529"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
PowerShell

## Atelier - Gestion des utilisateurs locaux en PowerShell

Moyen

2h

Auto-validation

PowerShell

## Atelier - Gestion des utilisateurs locaux en PowerShell

## Gestion de la sécurité d'exécution des scripts PowerShell

Dans PowerShell, il existe plusieurs paramètres de stratégie d'exécution des scripts:

- **Default**: paramètre par défaut (équivalent à **Restricted** pour les clients et **RemoteSigned** pour les serveurs)
- **Restricted**: n'autorise pas l'exécution des scripts
- **AllSigned**: n'exécute que les scripts signés
- **RemoteSigned**: exécute les scripts locaux sans obligation de confiance et les scripts d'internet signés
- **Unrestricted**: autorise l'exécution de tous les scripts, ceux en provenance d'internet doivent être autorisés au lancement
- **Bypass**: tous les scripts sont exécutés sans aucun avertissement
- **Undefined**: aucune stratégie d'exécution n'est définie

Ces stratégies d'exécution de scripts ont les étendues suivantes:

- **MachinePolicy**: Défini par une stratégie de groupe pour tous les utilisateurs de l'ordinateur
- **UserPolicy**: Défini par une stratégie de groupe pour l'utilisateur actuel de l'ordinateur
- **Process**: Affecte uniquement la session PowerShell actuelle
- **CurrentUser**: Affecte uniquement l'utilisateur actuel
- **LocalMachine**: Étendue par défaut qui affecte tous les utilisateurs de l'ordinateur

Démarrer une console PowerShell en tant **qu'administrateur**:

- Commande pour connaître la stratégie en cours:
```powershell
1
PS C:\Users\wilder> Get-ExecutionPolicy
```
- Commande pour modifier la stratégie:
```powershell
1
PS C:\Users\wilder> Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted
```

***A faire:***

- Changer la sécurité d'exécution des scripts
- Ecrire les commandes correspondantes aux 2 cibles suivantes:
	- Mets la stratégie de sécurité d'exécution **Undefined** sur l'étendue **LocalMachine**
		- Mets la stratégie de sécurité d'exécution **bypass** sur l'étendue **CurrentUser**

### Atelier - Gestion des utilisateurs locaux en PowerShell

2h