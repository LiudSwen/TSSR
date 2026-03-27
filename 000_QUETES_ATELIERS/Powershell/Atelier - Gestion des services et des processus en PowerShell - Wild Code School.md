---
title: "Atelier - Gestion des services et des processus en PowerShell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3955/pages/18535"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
PowerShell

## Atelier - Gestion des services et des processus en PowerShell

Facile

1h

Auto-validation

PowerShell

## Atelier - Gestion des services et des processus en PowerShell

Sur les OS Windows, on utilise couramment le mode graphique. Néanmoins, le passage en mode console est un moyen d'optimiser son temps.

## 1\. Prérequis

- Un ordinateur tournant sous Windows (version 10 ou Server 2019)
- Une console shell: la console shell de PowerShell ou l’éditeur PowerShell ISE
	- Tu peux aussi utiliser un éditeur de scripts comme VSCode
```powershell
DISCLAIMER

Les expérimentations pratiques ont été réalisées sur une machine virtuelle Windows 11 Pro, sur un système en français, avec un clavier Français AZERTY.

Cette VM est hebergée sur Virtualbox, tournant sur un système hôte Ubuntu 24.04 LTS.

Elles peuvent être reproduites avec une autre configuration d'ordinateur (autre version de Windows, autre langue, autre hyperviseur, autre système hôte), mais des différences peuvent alors apparaître et tu devras peut-être adapter les actions à effectuer.
```

## 2\. Gestion des services

Les services sont des programmes qui, en général, s'exécutent au démarrage du système d'exploitation, et qui tournent en arrière-plan. C'est-à-dire qu'ils fonctionnent sans que l'on ait nécessairement une fenêtre ou une notification à l'écran.

Pour la suite, ouvre une console PowerShell en mode administrateur.

## a. Affichage des services

La commande ci-dessous affiche tous les services.

```powershell
1
Get-Service
```

Ici, nous voyons donc trois colonnes qui représentent 3 attributs:

- Status
- Name
- DisplayName

Cela correspond à ce que nous voyons dans la fenêtre **Services** en mode graphique.  
Pour le voir, chercher **services** dans la recherche Windows (Cortana).

Pour n’afficher que les colonnes **Nom** et **Status**, par exemple:

```powershell
1
Get-Service | Select-Object -Property Status,Name
```

Pour trier par l'attribut **status**:

```powershell
1
Get-Service | Sort-Object -Property Status
```

Pour lister tous les services en cours d’exécution:

```powershell
1
Get-Service | Where-Object {$_.Status -eq « Running »}
```

Pour lister un service en particulier, par exemple **WalletService**:

```powershell
1
Get-Service | Where-Object {$_.DisplayName -like "*WalletService*"}
```

## b. Démarrage des services

Démarrage d’un service, par exemple **WalletService**:

```powershell
1
Start-Service -Name WalletService
```

Ou

```powershell
1
Get-Service | Where-Object {$_.Name -eq "WalletService"} | Start-Service
```

Comprends-tu la différence entre ces 2 lignes de code?

- Dans la première, on va démarrer directement le service concerné, ici **WalletService**
- Dans la seconde, on va chercher tous les services, avec `Get-Service`, on va envoyer le résultat dans un pipe `|` et avec `Where-Object` on va rechercher le service, donc **WalletService**. Ensuite on va le démarrer.

## c. Arrêt des services

Arrêt d’un service, par exemple **WalletService**:

```powershell
1
PS C:\Users\wilder> Stop-Service -Name WalletService
```

Ou

```powershell
1
PS C:\Users\wilder> Get-Service | Where-Object {$_.Name -eq "WalletService"} | Stop-Service
```

Ici tu reconnais 2 lignes presque similaires à celles du démarrage d'un service.

## d. Changement du mode de démarrage (en console administrateur)

Un service a 3 démarrages possible:

- **Automatique**: le service est lancé à chaque démarrage de Windows
- **Manuel**: le service n'est lancé qu'en cas de besoin
- **Désactivé**: le service ne sera jamais utilisé

Pour changer le mode de démarrage du service **WalletService** à **automatique**:

```powershell
1
PS C:\Users\wilder> Set-Service -Name WalletService -StartupType Automatic
```

## e. Changement d’état d’un service

Un service a 3 états possible:

- **Running**: en cours d'exécution
- **Stopped**: en arrêt
- **Paused**: en attente

Pour changer l’état du service **WalletService** à **stopped** par exemple:

```powershell
1
PS C:\Users\wilder> Set-Service -Name WalletService -Status Stopped
```

## 3\. Gestion des processus

Les processus sont des programmes en cours d'exécution.

## a. Démarrer un processus

Exécuter le code ci-dessous:

```powershell
1
PS C:\Users\wilder> Start-Process -FilePath calc.exe
```

En faisant cela, on démarre le processus **calc.exe** qui est associé à l’application calculatrice.

De la même façon qu'il existe 2 manières de lancer un service, il y a 2 manières de démarrer un processus.  
Essaye les commandes `Get-Process` suivi d'un pipe `|`, puis de `Where-Object`.  
Enfin termine la ligne de code par un `Start-Process`.  
Essaye avec le processus **calc.exe**

## b. Affichage d'un processus

Pour afficher le processus correspondant:

```powershell
1
Get-Process -Name CalculatorApp
```

> **CalculatorApp** peut aussi apparaître sous le terme **Calculator** sur certaines version de Windows (Windows 10 par ex).

En ajoutant le paramètre **FileVersionInfo** et en formatant la sortie standard en affichage **Format-List**, on obtient plus d’information:

```powershell
1
Get-Process -Name CalculatorApp -FileVersionInfo | Format-List
```

## c. Arrêt d'un processus

Pour arrêter un processus:

```powershell
1
Stop-Process -Name CalculatorApp
```

Comme pour le lancement d'un processus, tu peux exécuter la même série d'instructions, mais avec `Stop-Process` derrière un pipe `|`.

Une fois arrivé au bout de cet atelier tu as une première approche de la gestion en PowerShell.

Quête terminée le **jeudi 30 octobre 2025**