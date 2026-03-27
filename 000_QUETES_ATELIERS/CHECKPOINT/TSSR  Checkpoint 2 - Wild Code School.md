---
title: "TSSR : Checkpoint 2 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2902/pages/18651"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Checkpoint TSSR

## TSSR: Checkpoint 2

Moyen

4h

1 formateur

Checkpoint TSSR

## TSSR: Checkpoint 2

![image](http://workshop.industrial-architecture.cloud/images/atEonlfPz5Unq02sGCd1Nw.png)  
Comme pour le premier checkpoint, celui-ci est un point d'étape. Il a pour principal objectif de te permettre de vérifier si tu as bien assimilé les compétences vues jusqu'à présent.  
Il n'y a pas de surprises, les notions abordées sont celles vues dans les semaines qui viennent de s'écouler.  
C'est un exercice individuel, Mais tu as bien sûr le droit de te référer aux quêtes que tu as déjà effectuées et à la documentation (Internet).  
Tu devrais être en mesure de le finir dans le temps imparti. Plus tu as des automatismes, plus tu iras vite. Mais comme dans la vraie vie, on ne connait pas tout par cœur.  
Néanmoins, il ne s'agit pas d'un examen. Si tu n'as pas fini au bout de la durée impartie, ne t'inquiète pas, **tu es fortement invité à retravailler le checkpoint** par la suite afin de réussir à valider les compétences. L'essentiel est que tu comprennes et sois capable de mettre en application les notions abordées, si tu n'as pas encore la rapidité, cela viendra en t'exerçant.  
Ton formateur va t'aider dans cette évaluation en examinant le travail que tu as fourni et en validant la quête le cas échéant.  
Si tu n'as pas tout fini dans les délais, tu ajouteras simplement un commentaire `# Effectué en dehors du timing`, pour l'indiquer à ton formateur. Ça lui permettra de bien comprendre les forces et faiblesses de chacun, et de s'adapter.

```shell
Activités et compétences types évaluées dans ce checkpoint :

Exploiter les éléments de l’infrastructure et assurer le support aux utilisateurs

 Assurer le support utilisateur en centre de services
 Exploiter des serveurs Windows et un domaine Active Directory
 Exploiter des serveurs Linux
✅  Exploiter un réseau IP

Maintenir l’infrastructure et contribuer à son évolution et à sa sécurisation

✅ Maintenir des serveurs dans une infrastructure virtualisée
✅ Automatiser des tâches à l’aide de scripts
✅ Maintenir et sécuriser les accès à Internet et les interconnexions des réseaux
 Mettre en place, assurer et tester les sauvegardes et les restaurations des éléments de l’infrastructure
 Exploiter et maintenir les services de déploiement des postes de travail
```

## 📝 Objectifs

✅ Réaliser les 3 exercices du challenge  
✅ Valider les compétences acquises durant ces dernières semaines de formations

## Sommaire

- [🤓 Contexte de ce checkpoint](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#-contexte-de-ce-checkpoint)
- [📖 Répondre aux questions (*How to*)](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#-r%C3%A9pondre-aux-questions-how-to)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#-challenge)
	- [Exercice 1: Configuration IP client-serveur (temps estimé: 1h30)](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#exercice-1--configuration-ip-client-serveur-temps-estim%C3%A9--1h30)
		- [a. Théorie](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#a-th%C3%A9orie)
				- [b. Mise en pratique](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#b-mise-en-pratique)
		- [Exercice 2: Débogage de script PowerShell (temps estimé: 1h)](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#exercice-2--d%C3%A9bogage-de-script-powershell-temps-estim%C3%A9--1h)
		- [a. Contexte et objectif](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#a-contexte-et-objectif)
				- [b. Mise en pratique](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#b-mise-en-pratique-1)
		- [Exercice 3: Vérification d'une infrastructure réseau (temps estimé: 1h30)](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#exercice-3--v%C3%A9rification-dune-infrastructure-r%C3%A9seau-temps-estim%C3%A9--1h30)
		- [a. Objectifs](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#a-objectifs)
				- [b. Théorie](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#b-th%C3%A9orie)
				- [c. Mise en pratique](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#c-mise-en-pratique)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2902/pages/18651#-crit%C3%A8res-dacceptation)

## 🤓 Contexte de ce checkpoint

Tu travailles dans le service SI de la société **SweetCakes**.  
En l'absence de tes collègues, tu vas utiliser toutes tes compétences pour le bon fonctionnement de ton entreprise.  
Il n'y a pas d'ordre pour faire les exercices.

Dans ce checkpoint, pour les exercices 1 et 2, tu interviens sur 2 machines virtuelles VirtualBox:

- Une VM serveur nommée **SRVWIN01**
- Une VM client nommée **CLIENT1**

Les 2 VM ont une interface réseau configurée en mode `Réseau interne` sur le réseau **Checkpoint2** avec un câble connecté.  
Les pare-feu sont désactivés sur les 2 VM.

Détails sur les VM:

| Type de machine | Nom | Utilisateur | Mot de passe |
| --- | --- | --- | --- |
| Serveur | SRVWIN01 | Administrator | P@ssw0rdAdm!nS |
| Client | CLIENT1 | Wilder | tssr4Ever! |
|  |  | Administrateur | P@ssw0rdAdm!nL |

**Fichier à télécharger**:

Télécharge le fichier compressé **checkpoint2\_files.zip** disponible [ici](https://github.com/WildCodeSchool/TSSR_Resources/tree/main/Checkpoint2).  
Le mot de passe est `P](^|\$M7-UO9\>Ah!4jH`.

Dans le dossier décompressé tu as:

- Un fichier **Checkpoint2\_reponses.docx** dans lequel tu vas mettre toutes les réponses de ce checkpoint 2
- 3 fichiers de type **.pcap** pour l'exercice 3

## 📖 Répondre aux questions (How to)

Les réponses doivent être mise dans le fichier **Checkpoint2\_reponses.docx**.

2 types de questions te sont posées:

- Des questions théoriques ouvertes  
	Pour ces questions, les réponses (jamais plus d'un court paragraphe de quelques lignes) sont à écrire dans la partie prévue pour cela en dessous du numéro de la question dans le fichier de réponses.
```shell
Réponds correctement aux questions demandées. Seules les réponses complètes, techniques et argumentées seront prises en compte.
```
- Des questions pratiques  
	Ces questions demande de lancer des commandes et d'effectuer des actions sur les VM du checkpoint.  
	Pour ces questions, les réponses à fournir consistent à mettre une ou plusieurs copies d'écran dans la partie prévue pour cela en dessous du numéro de la question dans le fichier réponse.
```shell
Seule tes copies d'écran font foi pour tes réponses. Tu dois montrer clairement ce qui est demandé avec la copie d'écran des fenêtres, pas de l'écran entier. L'ordre d'exécution doit être respecté.

Si tu mets des explications écrites elles ne seront pas prise en compte.
```

---

## 💪 Challenge

## Exercice 1: Configuration IP client-serveur (temps estimé: 1h30)

Tu as 2 ordinateurs, un client **CLIENT1** et un serveur **SRVWIN01**.  
La communication entre ces 2 machines dysfonctionne.  
Tu dois la rétablir.

```shell
Selon la configuration matérielle de ton ordinateur hôte, modifie celle des VM selon tes besoins, par exemple pour la quantité de RAM.
```

### a. Théorie

Réponds aux questions ci-dessous dans le fichier réponse.

**Q.1.1** Le serveur SRVWIN01 a le rôle DHCP d'installé et correctement configuré et activé.  
Quelles peuvent être les raisons pour lesquelles le client ne reçoit pas de configuration IP du serveur?

**Q.1.2** Sur le serveur on exécute la commande `ipconfig /all`. On a une adresse 172.16.10.10/24. Si on exécute la même commande sur le client, on a une adresse 172.16.100.50/24.  
Pourquoi un ping ne fonctionne pas entre ces 2 machines?

**Q.1.3** Si le client a une configuration IP en DHCP, pour quelle(s) raison(s) il ne prend pas la première adresse configurée sur la plage des adresses IP mais une autre adresse?

**Q.1.4** Est-il possible de forcer un client à prendre une adresse IP spécifique en DHCP? Si oui explique comment procéder sur le client et sur le serveur.

**Q.1.5** Le résultat de la commande `ipconfig /all` donne aussi, sur le client et sur le serveur, une adresse IPv6 qui commence par fe80...  
Quelle est cette adresse et à quoi sert-elle?

**Q.1.6** Quel autre type d'adresse IPv6 peut-on avoir sur une machine? Précise le type, le préfixe, et la porté.

**Q.1.7** Est-il possible de configurer le service DHCPv6 sur le serveur SRVWIN01 avec des préfixes d'adresses Unicast Locales Uniques?  
Dans ce cas, si le client a une configuration IP en DHCP, est-ce qu'il va avoir automatiquement une adresse IPv6 Unicast Locales Uniques?

**Q.1.8** Entre 2 machines on exécute la commande `ping` avec le nom des machines au lieu de l'adresse IP. La commande s'exécute correctement.  
Quel protocole permet cela?

**Q.1.9** Si l'IPv6 est activé, le retour de la commande ping avec le nom d'une machine est une adresse IPv6. Pourquoi?  
Quelle option de la commande ping permet d'avoir une adresse IPv4?

**Q.1.10** À partir du serveur, je veux pouvoir faire un ping vers le client à partir de son nom, et également avec un alias de ce nom, par exemple **CLIENT\_TEST**, comment procéder?

### b. Mise en pratique

Dans le fichier réponse, met les copies d'écran demandées.

**Q.1.11** Sans changer la configuration IPv4 des 2 machines, depuis le serveur montre le résultat d'un ping vers l'adresse IPv4 du client.  
Modifie la configuration IP statique sur le client pour que ce ping depuis le serveur soit fonctionnel.  
Montre le résultat de la commande `ipconfig /all` sur le client avec la nouvelle adresse IP.  
Montre le résultat d'un ping IPv4 du serveur vers le client.

**Q.1.12** Mets le client **CLIENT1** en DHCP.  
Montre le résultat de la commande `ipconfig /all` et des commandes possibles sur le client qui permettent d'avoir une nouvelle configuration IP.  
Montre le résultat d'un ping IPv4 du serveur vers le client.

**Q.1.13** Sur le serveur, modifie la configuration du service DHCP (sans supprimer la plage) pour que le client prenne une adresse IP entre 172.16.10.100 et 172.16.10.200.  
Montre les changements effectués sur le serveur.  
Montre le résultat de la commande `ipconfig /all` sur le client avec la nouvelle adresse IP.

**Q.1.14** Sur le serveur, sans modifier les plages IP "bloquées", fais une modification pour que le client ai l'adresse IP 172.16.10.15.  
Montre le changement de configuration sur le serveur.  
Montre le résultat de la commande `ipconfig /all` sur le client avec la nouvelle adresse IP.

**Q.1.15** Sans changer la configuration IPv6 des 2 machines, montre le résultat d'un ping IPv6 du serveur vers le client.

**Q.1.16** Sur le serveur, mets en place une configuration DHCPv6 avec le préfixe `fd01:2345:6789:abcd::/64`.  
Ajoute 2 plages d'exclusions:

- De `fd01:2345:6789:abcd::1` à `fd01:2345:6789:abcd::13`
- De `fd01:2345:6789:abcd::fff1` à `fd01:2345:6789:abcd::fffe`  
	Montre le changement de configuration sur le serveur.

**Q.1.17** Depuis le client, fais un ping vers le serveur avec le nom du serveur.  
Montre le résultat du ping avec une adresse IP de sortie en IPv4.

**Q.1.18** Depuis le serveur, fais un ping vers le client avec le nom du client.  
Modifie la configuration sur le serveur pour que ce ping soit fonctionnel, et qu'un ping vers **CLIENT\_TEST** fonctionne également pour la même machine cliente.  
Montre le changement de configuration sur le serveur.  
Montre le résultat d'un ping depuis le serveur vers CLIENT\_TEST en utilisant le nom de la machine.

## Exercice 2: Débogage de script PowerShell (temps estimé: 1h)

### a. Contexte et objectif

Le système actuel n'a pas d'Active Directory, et donc il n'y a pas de centralisation de gestion des utilisateurs, tout est fait localement sur les ordinateurs.  
Le service des Ressources Humaines a donc demandé au SI un processus automatisé pour la création des utilisateurs locaux sur les ordinateurs à partir d'une liste extraite du logiciel RH.

Voici ce qui a été demandé:

- On doit pouvoir exécuter le script à partir d'un compte qui a des privilèges peu élevés
- Les utilisateurs à créer sont dans un fichier CSV
- Un test est fait pour savoir si chaque utilisateur existe déjà sur la machine
- Si l'utilisateur n'existe pas, il est créé, avec des droits restreints
- Sinon, il n'est pas crée et le script continue.
- On connait le résultat de ces 2 actions avec un message. Si possible des couleurs peuvent aider à la compréhension des messages.

Le script `AddLocalUsers.ps1` a été crée. Voici comment il doit fonctionner:

- Sur un ordinateur client, on se connecte avec un compte local, qui n'est pas administrateur local de la machine
- On exécute le script `C:\Scripts\Main.ps1`
- Ce script lance avec des privilèges élevés le script `C:\Scripts\AddLocalUsers.ps1`
- Ce script va lire une liste d'utilisateurs contenue dans le fichier `C:\Scripts\Users.csv`
- Chaque utilisateur du fichier est testé pour savoir s'il existe déjà sur la machine locale:
	- Si c'est le cas, le script ne fait rien, un message de couleur rouge alerte, et le script continue
		- S'il n'existe pas localement, l'utilisateur est crée et placé dans le groupe local des utilisateurs de la machine, et un message de couleur verte affiche le résultat, puis le script continue

Malheureusement, ce script dysfonctionne!  
A partir des remarques ci-dessous, remontées par les premiers utilisateurs, corrige le script.

### b. Mise en pratique

**Q.2.1** Il existe une nouvelle version **\-v2** des fichiers sur le serveur dans le dossier **c:\\Scripts**.  
En faisant un partage de ce dossier, transferts les fichiers vers le dossier **c:\\Scripts** qui est sur le client CLIENT1.  
Montre la configuration qui te permet de faire cela.

```shell
Si tu n'as pas encore fait l'exercice 1 et/ou que tu es bloqué à cette étape, passe directement à la question Q.2.2.

Tu es en contexte d'entreprise, donc tu ne dois pas utiliser le système des dossiers partagés dans l'interface de Virtualbox.
```

**Q.2.2** Sur le client exécute le script **Main.ps1**.  
Modifie le script pour qu'il lance correctement le script **AddLocalUsers.ps1**.  
Mets des commentaires au `# Q.2.2`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée pour que le script AddLocalUsers.ps1 s’exécute correctement.

```shell
Pour la suite, afin de facilité le débogage, tu peux exécuter directement le script

AddLocalUsers.ps1 en tant qu'administrateur local sans passer par le script Main.ps1
```

**Q.2.3** Le premier utilisateur du fichier **Users.csv** n'est jamais pris en compte.  
Mets des commentaires au `# Q.2.3`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée.  
Montre que le premier utilisateur est bien crée.

**Q.2.4** Le champs `Description` est importé du fichier CSV mais n'est pas utilisé.  
Mets des commentaires au `# Q.2.4`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée.  
Montre que le champs Description est bien importé.

**Q.2.5** Dans l'importation des utilisateurs du fichier CSV, tous les champs sont pris. Or il n'y en a qu'une partie qui est utilisé par la suite.  
Mets des commentaires au `# Q.2.5`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée pour que le script n'utilise que les champs nécessaires.

**Q.2.6** Le mot de passe de l'utilisateur crée n'est pas affiché.  
Modifie le script pour qu'un message de couleur verte affiche `"Le compte <Utilisateur> a été crée avec le mot de passe <MotDePasse>"`.  
Mets des commentaires au `# Q.2.6`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée pour avoir un message d'information de couleur verte.

**Q.2.7** Une fonction de création de log, nommée `Log` existe dans le fichier **Functions.psm1**.  
Intègre, le code de cette fonction au script.  
Avant cette intégration, tu ajoute un commentaire dans un `# Q.2.7`.  
Montre par une copie d'écran la manière que tu as utilisé pour incorporer le code de cette fonction ainsi que tes commentaires.

```shell
Si tu es bloqué à la question Q.2.7, passe directement à la Q.2.9, car la suivante (la Q.2.8) est liée à celle-ci.
```

**Q.2.8** Utilise le code de la fonction `Log` pour journaliser des événements du script **AddLocalUsers.ps1**.  
Avant chaque journalisation ajoute un commentaire dans un `# Q.2.8`.  
Montre avec 2 copies d'écran 2 journalisations de ton code.

**Q.2.9** Si l'utilisateur à créer existe déjà, il n'est pas crée, ce qui est normal (c'est comme ça que doit fonctionner le script). Or cette information n'est pas affichée, donc on ne le sait pas.  
Modifie le script pour qu'un message affiche en rouge `"Le compte <Utilisateur> existe déjà"`.  
Mets des commentaires au `# Q.2.9`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée pour avoir un message d'information de couleur rouge.

**Q.2.10** L'ajout des utilisateurs dans le groupe des utilisateurs locaux ne fonctionne pas. Corrige le script pour que cela fonctionne.  
Mets des commentaires au `# Q.2.10`.  
Montre par une copie d'écran tes commentaires et la modification du code effectuée pour que l'ajout dans le groupe des utilisateurs locaux fonctionne.

**Q.2.11** Les comptes utilisateurs créés ont un mot de passe qui expire.  
Corrige le script pour que les utilisateurs soient crées avec un mot de passe sans expiration.  
Mets des commentaires avec un `# Q.2.11`  
Montre par une copie d'écran tes commentaires et la modification du code effectuée pour que les mots de passe des utilisateurs créés n'expirent pas.

## Exercice 3: Vérification d'une infrastructure réseau (temps estimé: 1h30)

### a. Objectifs

Un nouveau vlan a été crée dans un bâtiment annexe de l'entreprise.  
Il faut vérifier si tout est fonctionnel.

Voici le schéma du réseau:

![schéma infra réseau](https://storage.googleapis.com/assets_upload_prod/cUPtVmppoKRwceTbsVlxTnPTBZ2qyls5.png)  
Informations sur les ordinateurs:

| Matériel | Adresse MAC | Adresse IP |
| --- | --- | --- |
| PC1 | 00:50:79:66:68:00 | 10.10.4.1/16 |
| PC2 | 00:50:79:66:68:01 | 10.11.80.2/16 |
| PC3 | 00:50:79:66:68:02 | 10.10.80.3/16 |
| PC4 | 00:50:79:66:68:03 | 10.10.4.2/16 |
| PC5 | 00:50:79:66:68:04 | 10.10.4.7/15 |

La configuration IP est statique sur les PC.  
Lorsque cela est possible, la passerelle par défaut est configurée.

Informations sur les matériels d'interconnexion **A** et **B**:

- Un seul vlan 10.10.0.0/16 configuré sur tous les ports

Informations sur le matériel d'interconnexion **C**:

| Interface | Adresse MAC | Adresse IP |
| --- | --- | --- |
| g1/0 | CA:01:DA:D2:00:1C | 10.12.2.254/30 |
| g2/0 | CA:01:DA:D2:00:08 | 10.10.255.254/16 |

Informations sur le matériel d'interconnexion **D**:

| Interface | Adresse MAC | Adresse IP |
| --- | --- | --- |
| g2/0 | CA:03:9E:EF:00:38 | 10.12.2.253/30 |
| g3/0 | CA:03:9E:EF:00:54 | 172.16.5.254/24 |

```shell
Dans ce réseau :

Tous les matériels sont allumés
Toutes les adresses IP sont configurées
Toutes les routes IP sont configurées
```

### b. Théorie

Réponds aux questions ci-dessous dans le fichier réponse.

**Q.3.1** Quels sont les matériels **A** et **B**? Quel est leur rôle sur un réseau? Sur quelle couche du modèle OSI fonctionnent-ils?

**Q.3.2** Rempli le tableau suivant pour les PC du réseau:

| PC | Adresse réseau | 1ère adresse | Dernière adresse | Adresse de diffusion |
| --- | --- | --- | --- | --- |
| PC1 |  |  |  |  |
| PC2 |  |  |  |  |
| PC3 |  |  |  |  |
| PC4 |  |  |  |  |
| PC5 |  |  |  |  |

**Q.3.3** Quel est le rôle de **A** pour un ping de PC1 vers PC3?  
Explique si cette communication a réussi.

**Q.3.4** Quel est le rôle de **B** pour un ping de PC2 vers PC4?  
Explique si cette communication a réussi.

**Q.3.5** Le résultat d'un ping de PC5 vers PC2 est `10.11.80.2 icmp_seq=1 timeout`.  
Celui d'un ping de PC2 vers PC5 est `No gateway found`.  
Explique ces 2 résultats.

**Q.3.6** Quels sont les matériels **C** et **D**? Quel est leur rôle sur un réseau? Sur quelle couche du modèle OSI fonctionnent-ils?

**Q.3.7** Comment PC3 peut envoyer des paquets IP en dehors de son réseau?  
Quel matériel l'aide dans cette tâche?

**Q.3.8** Le matériel trouvé à la question précédente remplit-il ce rôle pour tous les PC du réseau (PC1~5)?

**Q.3.9** Sur **C**, pour l'interface **g1/0**, que signifie le **g**, le **1**, et le **0**?

**Q.3.10** Sur **C**, que faut-il configurer pour atteindre le réseau 172.16.5.0/24 et au moyen de quelle commande?  
Cette action est-elle effective au niveau du routeur ou d'une interface en particulier?

**Q.3.11** Rempli le tableau ci-dessous qui contient les informations de la trame ethernet suivant l'emplacement sur le réseau pour un ping depuis PC1 vers le réseau 172.16.5.0/24.

Ne rempli que le ping request (pas le reply).

| Emplacement sur le réseau | Adresse MAC destination | Adresse MAC source | Adresse IP source | Adresse IP destination |
| --- | --- | --- | --- | --- |
| Entre PC1 et A |  |  |  |  |
| Entre B et C |  |  |  |  |
| Entre C et D |  |  |  |  |
| Après D |  |  |  |  |

### c. Mise en pratique

Dans cette partie, tu utilises les fichiers **.pcap** que tu as téléchargé.  
Ces fichiers sont des captures de trame ethernet à différents endroits du réseau.

```shell
Les fichiers sont indépendants et peuvent être traités dans n'importe quel ordre.
```

**Fichier file1**:

**Q.3.12** Dans le paquet N°1, quel est l'ethertype du protocole encapsulé?  
Quel est son nom et son rôle?

**Q.3.13** À quoi sert la communication sur les paquets N°1 et 2?

**Q.3.14** Est-ce qu'un matériel répond à la demande? Justifie ta réponse.

**Q.3.15** À quel endroit du réseau a-t-elle été enregistrée? Justifie ta réponse.

**Fichier file2**:

**Q.3.16** Quels sont les différents protocoles encapsulés dans la communication capturée?

**Q.3.17** Quels sont les matériels source et destinataire dans cette communication?  
Est-ce que cette communication a réussi? Justifie ta réponse.

**Q.3.18** À quel endroit du réseau a-t-elle été enregistrée? Justifie ta réponse.

**Fichier file3**:

**Q.3.19** Que se passe t'il dans cette capture?

**Q.3.20** Au vu des matériels du réseau, est-ce que cette communication va réussir? Justifie.

**Q.3.21** Peut-on affirmer que cette capture a été faite entre les matériels C et D?  
Si ce n'est pas le cas, avec les renseignements dont tu disposes, indique à quel emplacement du réseau elle a pu être réalisée.

## 🧐 Critères d'acceptation

Toutes tes réponses écrites, ainsi que tes copies d'écran sont mis dans le fichier réponse.

Solution postée le **vendredi 09 janvier 2026**

[Télécharger le fichier](https://storage.googleapis.com/odyssey_production_solutions/solutions/68a58cd5bdafdf28f7b707004029cc13?GoogleAccessId=odyssey-app%40odyssey-react-267410.iam.gserviceaccount.com&Expires=1774255206&Signature=l7tPfRSQjG2uuz7bUi%2Fcop6kkyL%2FtiVTVCBaG0qdJdZ385uB4LUxsb5XHU%2Fg7XiHhdCPNWR4RnkBxHj%2Bj4arBlhZf6CQPaV01GlLQZas%2FkbCYMdYufmiHmgOFzFHnJrJ6xGzHED7OdLjeZNCQo4UAfxwCy2jSGO0dtI3PMzgKLxVfJ0H7hjzgOgapLDZ4nDg1awgsJVOtZM2c4tqAsHif5UtEiTHbJbuKO8L41b0AohoERGsq8J7J9k9B3rF627CoIiR%2FhNunmb%2Fr6rGJe9qSue4177n7eCNQ7N%2BR5zc6HD1wIZnktc9v%2FUL%2FtEburwyjftOIKugRpZoP7cuyn7Zyw%3D%3D)

⚠️ La Wild Code School n'est pas responsable des liens / fichiers partagés par les Wilders.