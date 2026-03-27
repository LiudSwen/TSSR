---
title: "Les bases du courrier électronique - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2538/pages/9225"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Courrier électronique

## Les bases du courrier électronique

Introduction au fonctionnement, protocoles et enjeux du courrier électronique

Facile

2h

3 pairs

Courrier électronique

## Les bases du courrier électronique

## Introduction

Le courrier électronique est un moyen de communication très couramment utilisé notamment dans un contexte professionnel. Il est ainsi fréquent de disposer d'une ou plusieurs adresses mail souvent réservées à des usages particuliers (adresse pro, celle pour communiquer avec sa famille ou ses amis, adresse à spam...)

Cette quête propose d'explorer dans les grandes lignes comment fonctionne le courrier électronique ainsi que les protocoles impliqués.

![L'inscription "E-mail!" accrochée par une punaise](https://openclipart.org/image/2400px/svg_to_png/3040/zeimusu-Thumbtack-note-email.png)

## 🤓 Objectifs:

✅ Comprendre le fonctionnement général du courrier électronique  
✅ Découvrir SMTP, POP3 et IMAP  
✅ Explorer les différentes formes de client mail  
✅ Installer et configurer un client mail

## Sommaire

- [📖 Introduction](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-introduction)
- [📭 Adresses et boîtes](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-adresses-et-bo%C3%AEtes)
- [📧 Format](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-format)
- [📯 Acheminement et consultation](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-acheminement-et-consultation)
	- [📩 Le client mail](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-le-client-mail)
		- [📨 Le serveur SMTP](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-le-serveur-smtp)
		- [🏤 Le serveur POP3/IMAP](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-le-serveur-pop3imap)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2538/pages/9225#-crit%C3%A8res-dacceptation)

## 📖 Introduction

Apparu dès la fin des années 60, le courrier électronique est l'une des plus anciennes applications des réseaux informatiques. Elle permet à ses utilisateurs l'échange asynchrone de messages.

Il existe de nombreux termes dans le langage courant pour désigner ces messages: courrier électronique, e-mail, courriel, mail... La métaphore ne s'arrête d'ailleurs pas là et de nombreux concepts du courrier électronique sont nommés par analogie avec le système postal.

Ainsi, un **expéditeur** peut envoyer un **e-mail** en utilisant l' **adresse** électronique d'un **destinataire** qui reçoit ce **courrier** dans une **boîte** de réception où il peut venir le récupérer.

Regarde la vidéo suivante pour commencer à rentrer dans le vif du sujet:

## 📭 Adresses et boîtes

Pour pouvoir recevoir des e-mail, il est nécessaire de disposer d'une boite de réception qui prend la forme d'un compte sur un serveur de messagerie.

Ce compte est identifié par une adresse dont le format suit le schéma général suivant: `<identifiant de compte>@<nom de domaine>`.

Toutes les adresses ne correspondent pas directement à des boîtes. Il existe ainsi:

- Des alias qui redirigent vers d'autres boîtes.
- Des listes de diffusion qui sont une seule adresse pour un ensemble de destinataires.
```shell
Adresse électroniqueContinue de creuser la question des adresses mail avec la page WikipediA qui leur est consacrée.https://fr.wikipedia.org/wiki/Adresse_%C3%A9lectronique
```
```shell
Pour aller plus loin
Le paragraphe 3.4.1 de la RFC 5322 fournit plus de précisions sur le format exact d'une adresse mail.
```

Ce compte (boîte mail) peut être souscrit auprès d'un fournisseur ou créé sur son propre serveur. Il correspond à un espace de stockage dédié dans lequel les courriers reçus sont stockés en attente de lecture par le propriétaire de la boite mail.

```shell
Boîte aux lettres électroniqueLa page WikipediA consacré aux boîtes mail permet de poursuivre la découverte de cette notion.https://fr.wikipedia.org/wiki/Bo%C3%AEte_aux_lettres_%C3%A9lectronique
```

## 📧 Format

Un e-mail est en résumé une suite de caractères.  
Il est constitué d'un ensemble de lignes, chaque ligne étant terminée par un retour/fin de ligne au format CRLF.  
Chaque ligne ne doit pas faire plus de 1000 caractères (CRLF inclus) et devrait en faire 80 au plus.

Les premières lignes sont des en-têtes (un par ligne) de la forme `<nom de l'en-tête>:<valeur du champs>` (et donc avec CRLF à la fin pour terminer la ligne).

Ces entêtes sont suivies optionnellement d'un corps de message. La fin des entêtes (et donc le début du corps) est marquées par une ligne vide (CRLF 2 fois de suite).

2 entêtes sont obligatoires:

- `orig-date` indiquant la date et l'heure à laquelle l'expéditeur envoie cet e-mail.
- `from` indiquant l'adresse électronique de l'expéditeur.
```shell
L'entête from d'un mail est rempli à la rédaction par l'expéditeur mais n'est pas utilisé pour une quelconque forme d'authentification.

En pratique, il est possible (et même facile) d'indiquer ce qu'on souhaite dans cet entête.

Il ne fourni donc aucune garantie sur l'expéditeur réel du message !
```

D'autres en-têtes sont très couramment utilisés:

- `to` contient les adresses des destinataires principaux du message.
- `cc` (pour *Carbon Copy*) contient les adresses des destinataires secondaires (en copie) du message.
- `bcc` (pour *Blind Carbon Copy*) contient les adresses des destinataires cachés du message. Les adresses de ces destinataires ne sont pas communiquées aux autres. Sur les logiciels en Français, on trouve `cci` pour `Copie Carbone Invisible`.
- `subject` indique le sujet du message.
- `reply-to` est utilisé pour indiquer qu'il faut répondre à une autre adresse que celle présente dans `from`.
```shell
Courrier électroniquePlus d'info le format des e-mail sur la page WikipediA associée.https://fr.wikipedia.org/wiki/Courrier_%C3%A9lectronique
```

De nombreuses extensions du format initial existent pour permettre de transporter autre chose que du texte, par exemple tout le système des MIME défini notamment dans les RFC [2045](https://www.rfc-editor.org/rfc/rfc2045), [2046](https://www.rfc-editor.org/rfc/rfc2046), [2047](https://www.rfc-editor.org/rfc/rfc2047), [2049](https://www.rfc-editor.org/rfc/rfc2049), [4288](https://www.rfc-editor.org/rfc/rfc4288) et [4289](https://www.rfc-editor.org/rfc/rfc4289).

```shell
Pour aller plus loin
La RFC 5322 décrit précisément le format d'un Internet Message.
```

## 📯 Acheminement et consultation

Le système permettant l'acheminement d'un courrier électronique à son destinataire implique plusieurs protocoles et mobilise plusieurs serveurs.

Les 3 principaux protocoles en jeu sont:

- SMTP: *Simple Mail Transfer Protocol* qui est chargé de l'envoi des messages.
- POP3: *Post Office Protocol* qui permet de relever sa boîte mail.
- IMAP: *Internet Message Access Protocol* qui permet lui aussi de consulter sa boîte mail, plutôt dans une logique de connexion persistante.

On distingue:

- Le client de messagerie aussi appelé **MUA** pour *Message User Agent*.
- Le serveur chargé de l'envoi des messages ou **MTA** pour *Message Transfer Agent*.
- Le serveur chargé du stockage et de la consultation des messages reçus ou **MDA** pour *Message Delivery Agent*.

Le schéma suivant dresse le portrait d'un envoi de mail:

![Schéma de l'acheminement d'un e-mail](https://blog.theliel.es/wp-content/uploads/2016/04/howemailworks.png)

```shell
Internet Mail ArchitectureLa RFC 5598 détaille l'architecture globale du système de courrier électronique avec les différents types de serveurs impliqués.https://www.rfc-editor.org/rfc/rfc5598
```

## 📩 Le client mail

La partie visible du système est le client mail (MUA). C'est un logiciel ayant de multiples fonctions:

- Édition de l'e-mail: il permet la rédaction simple du message et de ses en-têtes au bon format.
- La communication via le protocole SMTP avec un serveur d'envoi de mail (MTA).
- La consultation/récupération des messages reçus sur un serveur de stockage de mail (MDA) avec POP3 et/ou IMAP.

La plupart de ces clients peuvent être paramétrés pour consulter plusieurs boîtes mail différentes (avec plusieurs comptes associés) et ainsi permettre la gestion de l'ensemble de ses adresses mail via un seul logiciel.  
Ils disposent en général d'un mécanisme de gestion de la connexion avec un fonctionnement hors ligne permettant, en l'absence de connexion aux serveurs, de consulter les messages déjà récupérés et éventuellement de rédiger des messages pour envoi ultérieur, au moment où l'ordinateur est connecté à Internet.

Comme ils stockent les messages localement sur l'ordinateur où ils s'exécutent, ils permettent éventuellement d'achiver des messages tout en les supprimant du serveur et ainsi d'y libérer l'espace.

Au-delà de ces fonctions spécifiques au courrier électronique, ces client mails ont souvent d'autres fonctionnalités bureautiques comme la gestion des contacts, d'agenda, de tâches, *etc.*.

Il existe de nombreux clients de messagerie. À titre d'exemple, on peut citer:

- [Thunderbird](https://www.thunderbird.net/fr/): client libre de messagerie disponible sur toutes les plateformes.
- [Outlook](https://outlook.live.com/owa/): le client de messagerie de Microsoft.

Aujourd'hui, de nombreux utilisateurs ont troqué les clients de messagerie dits *lourds* au profit d'applications web fournissant des services similaires. On parle alors de **webmail** qui est donc un site web hébergé par un serveur web (et qu'on consulte donc à l'aide un navigateur web via le protocole HTTPS).  
Pour envoyer et recevoir les messages, c'est alors le serveur web qui prend les rôles de clients SMTP et POP3/IMAP.  
Des nombreux fournisseurs d'adresses mail fournissent aussi un webmail pour y accéder ([La poste](https://laposte.net/accueil), [Mailo](https://www.mailo.com/fr/), [Gmail](https://mail.google.com/)...)

```shell
Client de messagerieQuelques informations complémentaires sur les clients de messagerie.https://fr.wikipedia.org/wiki/Client_de_messagerie
```

## 📨 Le serveur SMTP

Le client de messagerie n'envoie pas directement les e-mails à leurs destinataires, il passe par au moins un intermédiaire: un serveur SMTP.

Les serveurs SMTP sont en charge d'envoyer les courriers électroniques.  
On peut éventuellement séparer leurs fonctions en 2 rôles:

- Un rôle de [Message Transfer Agent](https://en.wikipedia.org/wiki/Message_transfer_agent) (MTA) qui consiste à transmettre les courriers électroniques de serveur SMTP en serveur SMTP jusqu'au serveur hébergeant la boîte de réception.
- Un rôle de [Message Submission Agent](https://en.wikipedia.org/wiki/Message_submission_agent) (MSA) qui consiste à permettre à des clients de messagerie de se connecter pour soumettre un courrier électronique à envoyer.

Lorsqu'un serveur SMTP reçoit un e-mail, il le stocke dans une file d'attente. Selon la nature du client qui se connecte, ce serveur a alors le rôle MSA, si le client est un client de messagerie (MUA) ou le rôle MTA, si le client est un autre serveur SMTP (MTA).

Par ailleurs, un serveur SMTP parcourt les messages qu'il a en attente et tente de les envoyer.

L'envoi d'un e-mail avec SMTP consiste notamment à analyser l'adresse mail de destination et à récupérer la partie après `@`: le nom de domaine.  
À ce stade, il sollicite DNS pour récupérer les enregistrements [MX (Mail eXchange)](https://fr.wikipedia.org/wiki/Enregistrement_Mail_eXchanger) associés à ce nom de domaine et obtient ainsi la liste des serveurs de messagerie gérant ce domaine par ordre de préférence.  
Il peut ainsi tenter de contacter les serveurs les uns après les autres jusqu'à réussir à transférer l'e-mail à l'un d'entre eux.

Historiquement, SMTP ne comportait aucune forme de sécurité:

- Pas d'authentification, ainsi n'importe qui pouvait soumettre des messages à n'importe quel serveur pourvu qu'il soit accessible.
- Pas de confidentialité, toutes les communications étaient en clair.
```shell
Le SPAM
Le système de courrier électronique est énormément utilisé pour l'envoi de courriers indésirables (spam).

Selon Signal spam, le spam représente la vaste majorité des courriers électroniques et constitue un vecteur d'attaque courant pour les cybercriminels.
Pour lutter contre les spams, de nombreuses solutions et protocoles ont été mis en place tels que :

Des systèmes de filtrage des e-mails comme SpamAssassin.
DMARC (Domain-based Message Authentication, Reporting, and Conformance) un système de lutte contre le spam visant l'authentification des serveurs expéditeurs.
DKIM (DomainKeys Identified Mail) une norme d'authentification du nom de domaine de l'expéditeur d'un e-mail.
SPF (Sender Policy Framework) une norme de vérification du nom de domaine expéditeur d'un courrier électronique.
Des listes de blocage. Lorsqu'une organisation identifie un serveur SMTP qui envoie trop de spams, elle l'ajoute à la liste des serveurs qui ont interdiction de communiquer avec les serveurs SMTP de cette organisation.

Plus d'info : Lutte anti-spam sur WikipediA.
```

Un serveur SMTP librement accessible sur internet et ne mettant en place aucune forme d'authentification (le fonctionnement historique de SMTP) est très rapidement repéré par les spammeurs qui vont l'utiliser pour envoyer leurs e-mails. Ce type de serveur est appelé [relais ouvert](https://fr.wikipedia.org/wiki/Open_relay).

Pour permettre à leurs serveurs de gérer efficacement le courrier légitime, les administrateurs de serveurs SMTP cherchent donc les protéger du spam.  
Cette protection consiste en substance à authentifier les utilisateurs qui envoient des messages (et donc à ne plus être un **relais ouvert**) et à détecter ceux qui envoient du spam pour:

1. Ne pas transmettre ces spam (et donc éviter que leurs serveurs se fassent eux-même bloquer par les autres)
2. Bloquer ces utilisateurs pour décharger leurs serveurs du traitement des spam.

Plusieurs stratégies existent:

- Un serveur disponible uniquement sur un réseau privé.  
	C'est une stratégie qui peut être utilisée dans une entreprise, en acceptant uniquement les connexions venant du réseau interne. Cette stratégie est souvent mise en place par les [FAI](https://fr.wikipedia.org/wiki/Fournisseur_d%27acc%C3%A8s_%C3%A0_Internet) dont l'offre pour les particuliers contient en général l'accès à un serveur SMTP et qui n'est parfois possible que depuis la connexion fournie par ce FAI (et donc indirectement authentifiée lors de la connexion à Internet).
- Mettre en place une authentification via les extensions SMTP dédiées.  
	Ces serveurs peuvent alors être accessibles depuis Internet puisqu'un compte valide est nécessaire pour y accéder. C'est la stratégie habituelle des fournisseurs d'adresses mail qui proposent aussi d'accéder aux boîtes de réception à l'aide d'un client lourd.

Le protocole **SMTP** s'appuie en général sur **TCP** et utilise historiquement le port standard **25**.  
SMTP ne fournissant aucun mécanisme de chiffrement pour assurer la confidentialité des échanges, il n'est pas raisonnable de l'utiliser tel quel pour échanger des informations d'authentification.

Par ailleurs, il est assez courant pour un administrateur de réseau (et pour un FAI) de bloquer le port 25 et ainsi éviter que son réseau n'héberge des **relais ouverts**.

Il est possible d'utiliser SMTP en combinaison avec [TLS](https://fr.wikipedia.org/wiki/Transport_Layer_Security) et ainsi d'assurer la confidentialité des échanges.

2 modes de fonctionnement permettent cette utilisation.

La première consiste à commencer l'échange protocolaire en SMTP à basculer en TLS via un message particulier. Ce mode de fonctionnement est appelé **STARTTLS**. On parle aussi de **TLS opportuniste** pour indiquer le basculement de la connexion en TLS *si possible*.  
Le port standard utilisé pour ce type de connexion est le **587**.

SMTP peut aussi être encapsulé *implicitement* dans TLS, c'est-à-dire que l'intégralité de l'échange SMTP se fait sur TLS et donc que la communication commence par l'échange TLS permettant l'établissement de la confidentialité dès le début de la communication.  
Le port standard utilisé pour ce mode de fonctionnement dit SMTPS (SMTP over TLS) est le **465**.

```shell
Simple Mail Transfer Protocol (🇬🇧)L'article (en anglais) de WikipediA sur SMTP permet de reprendre et de poursuivre l'exploration de ce protocole.https://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol
```
```shell
Pour aller plus loin
La RFC 5321 est le standard de base de SMTP.

Elle est complétée par de nombreuses extensions telles que :

La RFC 4954 sur l'ajout de l'authentification à SMTP
La RFC 3207 sur l'utilisation opportuniste de TLS avec SMTP.
La RFC 8314 revient sur les différents modes de fonctionnement de SMTP (mais aussi POP3 et IMAP) avec TLS et recommande l'usage implicite de TLS au lieu de STARTTLS qui était la recommandation précédente.
```

Il existe de nombreux serveurs SMTP qui assurent en général les 2 rôles de MSA et MTA (voir plus). Par exemple:

- [Postfix](https://www.postfix.org/), un serveur très courant dans le monde Unix qui vise à remplacer le serveur historique [Sendmail](https://fr.wikipedia.org/wiki/Sendmail).
- [Exchange](https://en.wikipedia.org/wiki/Microsoft_Exchange_Server), le serveur de messagerie électronique de Microsoft qui utilise historiquement un protocole propriétaire pour la communication avec le client de messagerie **Outlook**.

## 🏤 Le serveur POP3/IMAP

Maintenant que l'e-mail a été rédigé et envoyé depuis le client de messagerie puis a transité de serveur en serveur à l'aide de SMTP jusqu'à la boite de réception, il faut que son destinataire puisse le lire.

C'est l'objectif des protocoles **POP3** et **IMAP** qui permettent au client de messagerie (MUA) de communiquer avec le serveur [MDA](https://fr.wikipedia.org/wiki/Mail_Delivery_Agent) pour consulter les messages reçus.  
Une authentification est ici nécessaire puisqu'elle permet au serveur de décider quelle boîte de réception il permet au client de consulter. Cette authentification prend en général la forme d'un login (souvent l'adresse mail, ou la partie identifiant de compte de l'adresse mail) associé à un mot de passe.

**POP3** est un protocole conçu à une époque où l'essentiel des connexions à Internet étaient intermittentes. Son fonctionnement par défaut consiste ainsi à se connecter à la boîte de réception sur le serveur, télécharger localement tous les nouveaux e-mail reçus et à les supprimer du serveur.  
Ainsi une fois cette opération effectuée, il est possible de consulter tranquillement ses messages hors ligne et la boite de réception sur le serveur a été vidée permettant ainsi d'économiser un espace de stockage souvent très limité, à l'époque.

Il est néanmoins possible, en général, de paramétrer son client de messagerie pour demander la conservation des messages sur le serveur.  
La conservation des messages sur le serveur permet la consultation de sa boîte depuis plusieurs clients sur plusieurs terminaux, ce qui est un cas d'usage assez habituel aujourd'hui.

**POP3** se base sur **TCP** et le port standard est le **110**.

Comme **SMTP**, **POP3** ne fourni aucune confidentialité des échanges, aussi, il est préférable de l'associer à **TLS**.  
Là aussi, cette association peut-être opportuniste via **STARTTLS** ou implicite, on parle alors de **POP3S**. Dans ce dernier cas, le port standard est alors le **995**.

```shell
Post Office Protocol (🇬🇧)Poursuit ton exploration de POP3 avec la page WikipediA associée.https://en.wikipedia.org/wiki/Post_Office_Protocol
```

**IMAP** est quand à lui prévu pour la consultation de messages stockés sur le serveur. La suppression d'un message sur le serveur (associée éventuellement d'un archivage local) est ainsi, par défaut, une opération manuelle.  
Il est donc plus *naturellement* adapté pour les usages d'aujourd'hui, même si l'essentiel des fournisseurs de e-mail permettent en général au client de choisir en offrant à la fois **POP3** et **IMAP**.

Là encore, **IMAP** est historiquement un protocole en clair, donc aujourd'hui à encapsuler dans **TLS**.  
Il utilise **TCP** comme protocole de transport et son port standard est le **143**.  
L'utilisation avec **TLS** peut se faire à nouveau, soit avec **STARTTLS**, soit, pour plutôt pour suivre la recommandation la plus récente, avec **TLS** implicite sur le port standard **993**.

```shell
Internet Message Access ProtocolLa page WikipediA sur IMAP te permet de poursuivre ton étude d'IMAP.https://fr.wikipedia.org/wiki/Internet_Message_Access_Protocol
```

La boîte de réception sur le serveur de messagerie, comme sur le stockage local au client, se présente d'une façon assez similaire à un système de fichier. On retrouve ainsi la notion de dossiers permettant un classement des e-mails. On trouve habituellement:

- Courrier entrant (INBOX)
- Brouillons (Drafts)
- Envoyés (Sent)
- Corbeille (Trash)
- Indésirables (Junk)
- Modèles (Templates)
- Archives (Archives)

La création de nouveaux dossier est possible sur le client, comme sur le serveur et des synchronisations entre les dossiers clients et serveurs sont envisageables.  
Des classements automatiques des e-mails reçus dans des dossiers particuliers via des filtres sont en général proposés par le client, et parfois peuvent être directement fait sur le serveur, comme pour le cas des filtres spam qui peuvent classer ces messages dans le dossier **Indésirables**.

```shell
Configurer les dossiers spéciaux d'un compte IMAPPour plus d'info sur les dossiers locaux et distants sur la documentation de Thunderbid.https://support.mozilla.org/fr/kb/configurer-les-dossiers-speciaux-dun-compte-imap
```

Quelques exemples parmi les nombreux serveurs POP3/IMAP existants:

- [Dovecot](https://dovecot.org/) est sans doute l'un des plus utilisés
- Le serveur exchange de Microsoft assure aussi la fonctionnalité de MDA.
```shell
Pour aller plus loin
Retrouve les standards IETF des protocoles pour relever ses messages dans les RFC :

La RFC 1939 pour POP3
La RFC 9051 pour IMAP
```

---

## ☝️ Résumé

Le système permettant l'échange asyncrhone de courriers électroniques est un système client serveurs impliquant plusieurs types de rôle (MUA <-> MSA <-> MTA <-> MDA <-> MUA) ainsi que 3 protocoles principaux: SMTP, POP3 et IMAP.  
Ces protocoles faisant circuler l'information en clair, il est nécessaire de les encapsuler dans TLS et bien qu'un mode dit opportuniste permet de faire basculer une connexion initialement en clair en une connexion TLS, il est aujourd'hui recommandé d'utiliser TLS implicitement pour l'intégralité de la communication.  
L'utilisation de DNS et des enregistrements MX est aussi nécessaire au bon fonctionnement de ce système en permettant de trouver les serveurs SMTP gérant un domaine mail (i.e. la seconde partie d'une adresse mail).

---

## 📝 Quiz

```shell
# 1  - SMTP signifieSimple Message Transport ProtocolSimple Mail Transfer ProtocolStandard Message Text PostSecure Message Transfer ProtocolValider# 2 POP3SMTPSMTPSIMAPSNMPValider# 3 POP3SMTPSMTPSSNMPIMAPValider# 4 TexteQuantiqueBinaireValider# 5 Reply-toFromAucunValiderTon score :0 / 5
```

---

## 💪 Challenge

Commence par te créer une nouvelle adresse mail pour ce test en souscrivant à l'offre gratuite de [mailo.com](https://mailo.com/).

Installe [thunderbird](https://www.thunderbird.net/fr/) sur ton ordinateur.

Configure le pour qu'il te permette d’accéder à ta nouvelle adresse. Thunderbird dispose d'un assistant automatique de configuration qui connaît déjà les informations de connexion à Mailo.

Une fois le compte paramétré, vérifie qu'il fonctionne correctement en t'envoyant un e-mail depuis une autre de tes adresses puis en y répondant.

Créé un dossier `Mes archives` dans tes `Dossiers locaux` puis déplace le mail de test que tu as reçu dans ce dossier.

Va maintenant voir dans les paramètres de ce compte pour y trouver les informations suivantes:

- Nom du serveur SMTP configuré pour ce compte
- Port utilisé pour se connecter à ce serveur
- Protocole utilisé pour la connexion (SMTP en clair, STARTTLS ou SMTPS)
- Nom du serveur IMAP configuré pour ce compte
- Port utilisé pour se connecter à ce serveur
- Protocole utilisé pour la connexion (IMAP en clair, STARTTLS ou IMAPS)
- L'emplacement du stockage du dossier `Mes archives` sur ton ordinateur

Copie les réponses à ces questions dans la solution à cette quête et ajoute le contenu du fichier de stockage de `Mes archives` (indice: il devrait contenir notamment l'e-mail reçu dans sa version brute texte).

## 🧐 Critères d'acceptation

Les réponses sont correctement indiquées et on peut bien lire l'e-mail de test avec les en-têtes correspondantes.

Solution postée le **mardi 10 février 2026**

**Nom du serveur SMTP:** mail.mailo.com

**Port SMTP:** 465

**Protocole SMTP:** SMTPS (SSL/TLS)

**Nom du serveur IMAP:** mail.mailo.com

**Port IMAP:** 993

**Protocole IMAP:** IMAPS (SSL/TLS)

**Chemin vers le dossier "Mes archives":**  
`C:\Users\chica\AppData\Roaming\Thunderbird\Profiles\he0rn76y.default-release\Mail\Local Folders`