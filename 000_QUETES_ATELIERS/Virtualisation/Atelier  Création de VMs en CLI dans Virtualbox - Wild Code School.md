---
title: "Atelier : Création de VMs en CLI dans Virtualbox - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2777/pages/13691"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Virtualisation

## Atelier: Création de VMs en CLI dans Virtualbox

Moyen

1h

Auto-validation

Virtualisation

## Atelier: Création de VMs en CLI dans Virtualbox

## Introduction

Dans cet atelier, tu vas approfondir ta connaissance de VirtualBox, un outil que tu as déjà utilisé pour monter des VM. Au lieu d'utiliser l'interface graphique, tu vas voir comment créer et démarrer des VM à l'aide de lignes de code.  
Cette manière de procéder te permet de gagner en efficacité et de mieux comprendre les fonctionnalités sous-jacentes de VirtualBox. Les lignes de code offrent un niveau de précision et de contrôle supérieur à celui de l'interface graphique, et te permettent de personnaliser tes VM avec une plus grande finesse. Par ailleurs, l'utilisation de scripts d'automatisation en remplacement d'opération réalisées à la main permet un gain de vitesse et une bien meilleure fiabilité dans le cas d'opérations répétitives.

![image](https://www.oracle.com/ocom/groups/public/@otn/documents/digitalasset/2264362.gif)

## 🤓 Objectifs:

✅ Utiliser la commande VBoxManage  
✅ Apprendre à créer et démarrer des VM avec des commandes  
✅ Synthétiser tout ça sous forme de script

## Sommaire

- [📌 La virtualisation (rappel)](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-la-virtualisation-rappel)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-mise-en-%C5%93uvre)
	- [🔧 Prérequis](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-pr%C3%A9requis)
		- [👉 VBoxManage](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-vboxmanage)
		- [🔬 Créer une VM de zéro](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-cr%C3%A9er-une-vm-de-z%C3%A9ro)
		- [🔬 Créer une VM de zéro avec un script](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-cr%C3%A9er-une-vm-de-z%C3%A9ro-avec-un-script)
		- [🔬 Créer des VMs à partir d'une autre VM avec un script](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-cr%C3%A9er-des-vms-%C3%A0-partir-dune-autre-vm-avec-un-script)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2777/pages/13691#challenge)

## 📌 La virtualisation (rappel)

La virtualisation est une technique qui permet de simuler plusieurs environnements informatiques sur une même machine physique, chacun fonctionnant comme une machine autonome. Cela permet une meilleure utilisation des ressources, une isolation des environnements et une flexibilité dans la gestion des ressources informatiques.

## 👉 Mise en œuvre

## 🔧 Prérequis

Pour cet atelier, il te faut:

- Une machine sur laquelle le logiciel Virtualbox est installé
- Un ou plusieurs fichiers ISO d'image d'installation d'OS pour pouvoir créer une VM de zéro
- Au moins une VM déjà existante qui sert de modèle
```shell
Cette quête a été faite avec une machine sous Ubuntu 22.04 LTS. La version installée de Virtualbox est la 7.

Il est possible que des différences d'affichages ou de résultats apparaissent dans le cas d'une configuration différente.

Si tu es sous Windows, tu devras adapter les lignes de commandes
```

## 👉 VBoxManage

**VBoxManage** est l'outil de gestion en ligne de commande de VirtualBox. Avec cet outil, tu peux créer et gérer les VM, ainsi que leur configuration.

Voici quelques exemples qui te permettent d'avoir des informations sur les VM:

- **Avoir la liste des VM** avec la commande `vboxmanage list vms`:
```bash
1
wilder@Ubuntu:~$ vboxmanage list vms
2
"ClientWindows1" {a192051d-8e02-4b17-b314-95bfa7cb912c}
3
"WinServer1" {f13a598e-eca6-4012-bf77-162e4056d9e6}
4
"FreePBX" {55178726-eb94-45f2-9b3f-3253f2575274}
5
"Windows1" {e6c1ecaf-7467-4d90-b661-6ada020fd05e}
6
"Windows2" {faf23580-6ace-4a32-9799-875be62f935c}
7
"FTP server" {16d7eb2e-e4ac-4541-9e72-19a5ddf89f2e}
```

> Cette commande renvois la liste des VM présente dans la configuration de virtualbox dans `~/.config/VirtualBox/VirtualBox.xml`.  
> Le numéro présent à la suite du nom est l' **ID** de la VM.

Voilà le contenu du fichier:

```bash
1
wilder@Ubuntu:~/.config/VirtualBox$ cat VirtualBox.xml 
2
[...]
3
    <MachineRegistry>
4
      <MachineEntry uuid="{a192051d-8e02-4b17-b314-95bfa7cb912c}" src="/home/wilder/VirtualBox VMs/ClientWindows1/ClientWindows1.vbox"/>
5
      <MachineEntry uuid="{f13a598e-eca6-4012-bf77-162e4056d9e6}" src="/home/wilder/VirtualBox VMs/WinServer1/WinServer1.vbox"/>
6
      <MachineEntry uuid="{55178726-eb94-45f2-9b3f-3253f2575274}" src="/home/wilder/VirtualBox VMs/FreePBX/FreePBX.vbox"/>
7
      <MachineEntry uuid="{e6c1ecaf-7467-4d90-b661-6ada020fd05e}" src="/home/wilder/VirtualBox VMs/Windows1/Windows1.vbox"/>
8
      <MachineEntry uuid="{faf23580-6ace-4a32-9799-875be62f935c}" src="/home/wilder/VirtualBox VMs/Windows2/Windows2.vbox"/>
9
      <MachineEntry uuid="{16d7eb2e-e4ac-4541-9e72-19a5ddf89f2e}" src="/home/wilder/VirtualBox VMs/FTP server/FTP server.vbox"/>
10
    </MachineRegistry>
11
[...]
```
- **Obtenir des informations sur une VM** avec la commande `vboxmanage showvminfo %VM%` (%VM% est le nom ou l'ID de la VM):
```bash
1
wilder@Ubuntu:~$  vboxmanage showvminfo ClientWindows1
2
Name:                        ClientWindows1
3
Encryption:     disabled
4
Groups:                      /Infra_TSSR
5
Guest OS:                    Windows 10 (64-bit)
6
[...]
```

Ou

```bash
1
wilder@Ubuntu:~$  vboxmanage showvminfo {a192051d-8e02-4b17-b314-95bfa7cb912c}
2
Name:                        ClientWindows1
3
Encryption:     disabled
4
Groups:                      /Infra_TSSR
5
Guest OS:                    Windows 10 (64-bit)
6
[...]
```
- **Obtenir des informations sur les VM démarées** avec la commande `vboxmanage list runningvms`:
```bash
1
wilder@Ubuntu:~$  vboxmanage list runningvms
2
wilder@Ubuntu:~$
```

Ici il n'y a pas de résultat car aucune VM n'est démarrée.  
Démarres en une avec la commande `startvm` comme ceci:

```bash
1
wilder@Ubuntu:~$ vboxmanage startvm WinServer1
2
Waiting for VM "WinServer1" to power on...
3
VM "WinServer1" has been successfully started.
```

Si tu relance la commande `vboxmanage list runningvms` tu vois que la liste n'est plus vide:

```bash
1
wilder@Ubuntu:~$ vboxmanage list runningvms
2
"WinServer1" {f13a598e-eca6-4012-bf77-162e4056d9e6}
```
- **Avoir la liste et l'arborescence des snapshots d'une VM** avec la commande `vboxmanage snapshot <NomDeVM> list`:
```bash
1
wilder@Ubuntu:~$  vboxmanage snapshot glpi list
2
   Name: Instantané 1 (UUID: f555081a-33c2-475b-8aa8-09a21d806551)
3
   Description: après fixe adresse IP statique
4
      Name: Instantané 2 (UUID: 0a157e77-7bf6-456a-baf0-1ce8545c7cc2)
5
      Description: après install openssh-server
6
         Name: Instantané 3 - avant install mariaDB et php (UUID: 3d230fb4-7881-423e-a2a5-6ec76544678b)
7
            Name: Instantané 4 - avant installation glpi 10 (UUID: c16c4026-5b48-481b-af75-9b70fbb2925c)
8
               Name: Instantané 5 - avant création de la BDD (UUID: ca3215a5-c2aa-4f03-8cfb-f808ae9c1d65) *
9
               Description: avec compte, prvilège, etc
10
                  Name: Instantané 6 - début d'installation (warnings) (UUID: 54ed094b-8122-4328-aa8b-452dd95ab89a)
11
                  Description: Il y a des warnings au check : version php ancienne, etc.
12
[...]
```
```shell
La doc officielle sur VBoxManageLa partie de la doc officielle qui concerne VBoxManage.https://www.virtualbox.org/manual/ch08.html
```

## 🔬 Créer une VM de zéro

On va utiliser la commande `vboxmanage createvm`.

Ta VM a les caractéristiques suivantes:

- Nom: `Ubuntu10`
- Taille de disque dur: `30 Go`
- Type du disque dur: `vmdk`
```shell
Ici la VM aura un disque dur de type vmdk qui est un format generique pour les VM, mais tu peux utiliser le format vdi également.
```
- Lecteur CD branché: `oui`, avec le fichier image iso d'Ubuntu d'inséré
- Taille de RAM: `2048 Go`
- Carte réseau: `oui, en NAT`
- Contrôleur graphique: `VMSVGA`
- Taille de la mémoire vidéo: `16 Mo`

Voici les lignes de commande à exécuter:

```bash
1
# Création de la VM
2
vboxmanage createvm --name Ubuntu10 --ostype "Ubuntu_64" --register
3

4
# Configuration de la mémoire RAM, de la mémoire vidéo, et du contrôleur graphique
5
vboxmanage modifyvm Ubuntu10 --memory 2048 --graphicscontroller VMSVGA --vram 16
6

7
# Création du contrôleur SATA
8
vboxmanage storagectl Ubuntu10 --name "SATA Controller" --add sata --controller IntelAhci
9
# Création du disque dur
10
vboxmanage createmedium disk --filename ~/VirtualBox\ VMs/Ubuntu10/Ubuntu10.vmdk --size 30000 --format VMDK
11
# Attachement du disque dur crée à la VM
12
vboxmanage storageattach Ubuntu10 --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/Ubuntu10/Ubuntu10.vmdk
13

14
# Ajout d'un lecteur CDrom
15
vboxmanage storagectl Ubuntu10 --name "IDE Controller" --add ide
16
# Insertion de l'image d'installation dans le lecteur CDrom
17
vboxmanage storageattach Ubuntu10 --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium /home/wilder/Documents/ubuntu-22.04.2-desktop-amd64.iso
18

19
# Configuration de la carte réseau en NAT
20
vboxmanage modifyvm Ubuntu10 --nic1 nat
21

22
# Démarrage de la VM
23
vboxmanage startvm Ubuntu10 --type gui
```
```shell
Ces lignes de codes vont créer la VM et la démarrer pour commencer l'installation.
```

## 🔬 Créer une VM de zéro avec un script

Si on reprend les lignes de commandes ci-dessus, et que l'on passe en argument le nom de la VM, la taille de la RAM, ainsi que l'emplacement d'un fichier ISO d'installation, on peut avoir un script très pratique.

Voilà un exemple de ce qui est possible avec le script `createVmWithIso.sh`:

```bash
1
#!/bin/bash
2

3
# Création et configuration d'une VM dans VirtualBox à partir d'une ISO
4
# Arguments :
5
# - nom de la VM
6
# - taille de la RAM
7
# - Emplacement fichier ISO
8

9
# Check arguments
10
if [ $# -ne 3 ]
11
then
12
    echo "Il manque les données suivantes à mettre en arguments de ce script :"
13
    echo "- Nom de la VM"
14
    echo "- Taille de la RAM (en Mo)"
15
    echo "- Emplacement du fichier ISO d'installation"
16
    exit 1
17
fi
18

19
# Création des variables
20
vm_name=$1
21
vm_ram=$2
22
iso_path=$3
23

24
# Création de la VM vide
25
vboxmanage createvm --name $vm_name --ostype "Ubuntu_64" --register
26

27
# Configuration de la mémoire RAM, de la mémoire vidéo, et du contrôleur graphique
28
vboxmanage modifyvm $vm_name --memory $vm_ram --vram 16 --graphicscontroller VMSVGA
29

30
# Création du contrôleur SATA
31
vboxmanage storagectl $vm_name --name "SATA Controller" --add sata --controller IntelAhci
32
# Création du disque dur
33
vboxmanage createmedium disk --filename ~/VirtualBox\ VMs/$vm_name/$vm_name.vmdk --size 30000 --format VMDK
34
# Attachement du disque dur crée à la VM
35
vboxmanage storageattach $vm_name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ~/VirtualBox\ VMs/$vm_name/$vm_name.vmdk
36

37
# Ajout d'un lecteur CDrom
38
vboxmanage storagectl $vm_name --name "IDE Controller" --add ide
39
# Insertion de l'image d'installation dans le lecteur CDrom
40
vboxmanage storageattach $vm_name --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $iso_path
41

42
# # Configuration de la carte réseau en NAT
43
vboxmanage modifyvm $vm_name --nic1 nat
44

45
# Démarrage de la VM
46
vboxmanage startvm "$vm_name" --type gui
```

Créer ce script et exécute-le comme ceci pour le tester:

```shell
wilder@Ubuntu:~$ ./createVmWithIso.sh Ubuntu10 2048 /home/wilder/Documents/ubuntu-22.04.2-desktop-amd64.iso
```
```shell
Tu as désormais un script qui créer une VM avec différents arguments.
```

## 🔬 Créer des VMs à partir d'une autre VM avec un script

On peut également créer des VMs à partir d'une autre VM.  
Tu vas utiliser le disque dur de ta VM template pour créer directement des VM fonctionnelles.  
Tu vas d'abord cloner le disque dur virtuel de la VM template avec la commande `vboxmanage clonemedium`.

Créer un fichier de script `createVmFromTemplate.sh` et copie les lignes de commandes ci-dessous:

```shell
On repart du script précédent, modifié. Entre-autre, on y a ajouté une boucle pour pouvoir créer plusieurs VMs.
```
```bash
1
#!/bin/bash
2

3
# Création d'une ou plusieurs VM Ubuntu VirtualBox à partir d'un template de disque dur
4
# Arguments :
5
# - nom de la VM
6
# - taille de la RAM
7
# - nombre de VMs à créer (optionnel)
8

9
# Vérification des arguments
10
if [ $# -lt 2 ]
11
then
12
    echo "Arguments requis pour ce script :"
13
    echo "- Nom de la VM"
14
    echo "- Taille de la RAM (en Mo)"
15
    echo "Optionnel :"
16
    echo "- Nombre de VMs à créer (par défaut 1)"
17
    exit 1
18
fi
19

20
# Variables depuis les arguments
21
vm_name=$1
22
vm_ram=$2
23
num_vms=${3:-1}
24

25
# Emplacement du disque dur template
26
template_disk_path="/home/wilder/VirtualBox VMs/Template/TemplateUbuntu-22.04LTS/TemplateUbuntu-22.04LTS_1.vmdk"
27

28
for i in $(seq -w 1 $num_vms)
29
do
30
    if [ $num_vms -eq 1 ]
31
    then
32
        final_vm_name=$vm_name
33
    else
34
        final_vm_name="${vm_name}_${i}"
35
    fi
36

37
    # Emplacement du nouveau disque dur cloné
38
    new_disk_path="/home/wilder/VirtualBox VMs/${final_vm_name}/${final_vm_name}_1.vmdk"
39

40
    # Création du dossier pour la nouvelle VM
41
    mkdir -p "/home/wilder/VirtualBox VMs/${final_vm_name}"
42

43
    # Création de la VM vide
44
    vboxmanage createvm --name $final_vm_name --ostype "Ubuntu_64" --register
45

46
    # Configuration de la mémoire RAM et du contrôleur graphique
47
    vboxmanage modifyvm $final_vm_name --memory $vm_ram --graphicscontroller VMSVGA --vram 16
48

49
    # Création du contrôleur SATA
50
    vboxmanage storagectl $final_vm_name --name "SATA Controller" --add sata --controller IntelAhci
51

52
    # Création du contrôleur IDE
53
    vboxmanage storagectl $final_vm_name --name "IDE Controller" --add ide
54

55
    # Attachement du lecteur CD-ROM au contrôleur IDE
56
    vboxmanage storageattach $final_vm_name --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
57

58
    # Clonage du disque dur template
59
    vboxmanage clonemedium disk "$template_disk_path" "$new_disk_path" --format VMDK
60

61
    # Attachement du disque dur cloné à la VM
62
    vboxmanage storageattach $final_vm_name --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$new_disk_path"
63

64
    # Configuration de la carte réseau en NAT
65
    vboxmanage modifyvm $final_vm_name --nic1 nat
66
done
```

Voilà comment exécuter ce script:

```shell
wilder@Ubuntu:~$ ./createVmFromTemplate.sh Ubuntu10_ 2048 2
```
```shell
Avec ce script tu a plusieurs VM directement fonctionnelles !
```

## ☝️ Résumé

On peut utiliser Virtualbox graphiquement, mais l'utilisation de lignes de commandes ou de script augmente considérablement la puissance de ce logiciel.  
La commande de gestion des VM est **vboxmanage**.  
On peut récupérer des informations et on peut gérer la création et l'utilisation des VM avec cette commande.  
Une VM peut être créer à partir d'une image d'installation, ou bien à partir d'une autre VM en clonant son disque dur virtuel.

## 📝 Quiz

```shell
# 1  -  Avec quelle commande peut-on définir la taille de la mémoire RAM ?vboxmanage createvmVBoxManage clonemediumvboxmanage modifyvmvboxmanage createmedium diskValider# 2 On doit obligatoirement créer un disque dur videOn n'a pas besoin de créer un contrôleur de disqueOn est obligé de créer un contrôleur de disqueOn doit obligatoirement créer un emplacement pour le disque dur de la VM clonéeValider# 3 vboxmanage createvmVBoxManage clonemediumvboxmanage modifyvmvboxmanage createmedium diskValider# 4 vraifauxValider# 5 Gérer des VMAucune des réponses précédentesCréer des VMDémarrer des VMValiderTon score :0 / 5
```

## 💪Challenge

- Test les différentes méthodes de création de VM évoquées dans cet atelier dans Virtualbox avec l'outil vboxmanage.
- Pour aller plus loin, tu peux créer un script qui démarre les VM de ton environnement de test, par exemple un serveur Debian et un client Ubuntu
- Tu peux également créer un second script qui éteint toutes les VM en cours d’exécution.

Quête terminée le **mardi 06 janvier 2026**