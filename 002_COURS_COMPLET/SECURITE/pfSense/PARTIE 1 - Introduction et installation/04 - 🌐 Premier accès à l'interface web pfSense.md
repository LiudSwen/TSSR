

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## Introduction

Une fois pfSense installé via la console, la majorité de l'administration se fait via l'**interface WebGUI** (Web Graphical User Interface). Cette interface web moderne et intuitive permet de gérer l'ensemble des fonctionnalités du pare-feu sans avoir à manipuler directement des fichiers de configuration.

> [!info] Pourquoi une interface web ?
> 
> - **Accessibilité** : Gérez pfSense depuis n'importe quel poste du réseau local
> - **Ergonomie** : Interface graphique plus conviviale que la ligne de commande
> - **Sécurité** : Connexion HTTPS chiffrée par défaut
> - **Centralisation** : Toutes les fonctionnalités au même endroit

Le premier accès à cette interface est crucial car il permet de personnaliser les paramètres de base et de sécuriser l'accès au firewall.

---

## Connexion à l'interface WebGUI

### Prérequis

Avant de vous connecter, assurez-vous que :

1. **pfSense est démarré** et l'interface LAN est configurée
2. **Votre poste est connecté** au réseau LAN de pfSense
3. **Vous connaissez l'adresse IP** de l'interface LAN (affichée sur la console)

### Accès initial

> [!example] Connexion par défaut
> 
> **URL** : `https://192.168.1.1` (ou l'IP LAN configurée)
> 
> **Identifiants par défaut** :
> 
> - Utilisateur : `admin`
> - Mot de passe : `pfsense`

#### Étapes de connexion

1. **Ouvrez votre navigateur web** (Firefox, Chrome, Edge...)
    
2. **Saisissez l'URL** : `https://192.168.1.1`
    
3. **Acceptez le certificat SSL auto-signé**
    

> [!warning] Avertissement de sécurité du navigateur Au premier accès, le navigateur affichera un avertissement concernant le certificat SSL. C'est **normal** car pfSense utilise un certificat auto-signé par défaut.
> 
> **Actions selon le navigateur** :
> 
> - **Chrome/Edge** : Cliquez sur "Avancé" puis "Continuer vers 192.168.1.1"
> - **Firefox** : Cliquez sur "Avancé" puis "Accepter le risque et continuer"

4. **Entrez les identifiants par défaut** :
    
    - Username : `admin`
    - Password : `pfsense`
5. **Cliquez sur "Sign In"**
    

### Que se passe-t-il lors de la première connexion ?

Lors du premier accès, pfSense :

- Vérifie les identifiants
- Établit une session HTTPS sécurisée
- Redirige automatiquement vers l'**assistant de configuration initiale** (Setup Wizard)

> [!tip] Astuce - Marque-page Ajoutez l'URL de pfSense à vos favoris pour un accès rapide ultérieur.

---

## Assistant de configuration initial

L'**assistant de configuration** (Setup Wizard) guide les nouveaux utilisateurs à travers les paramètres essentiels. Il se lance automatiquement lors du premier accès.

### Page 1 : Bienvenue

Cette page présente l'assistant et explique son rôle.

**Actions** :

- Lisez les informations affichées
- Cliquez sur **"Next"** pour continuer

> [!info] Peut-on ignorer l'assistant ? Oui, vous pouvez cliquer sur "Click here to cancel and continue to the dashboard" pour accéder directement au tableau de bord. Cependant, il est **recommandé de suivre l'assistant** lors de la première configuration.

### Page 2 : Netgate Global Support

Cette page présente les offres de support commercial de Netgate.

**Actions** :

- Prenez connaissance des informations (facultatif)
- Cliquez sur **"Next"**

### Page 3 : General Information

Configuration des paramètres généraux du système.

#### Hostname (Nom d'hôte)

Le nom court du firewall dans votre réseau.

```
Hostname: pfsense
```

> [!example] Exemples de noms
> 
> - `firewall`
> - `fw-principal`
> - `pfsense-prod`
> - `gateway`

**Règles de nommage** :

- Uniquement lettres, chiffres et tirets
- Pas d'espaces ni de caractères spéciaux
- Ne doit pas commencer ou finir par un tiret

#### Domain (Domaine)

Le nom de domaine de votre réseau local.

```
Domain: localdomain
```

> [!example] Exemples de domaines
> 
> - `home.local`
> - `entreprise.lan`
> - `monreseau.local`

Le **FQDN complet** (Fully Qualified Domain Name) sera : `hostname.domain` Exemple : `pfsense.localdomain`

#### Primary DNS Server

Serveur DNS principal utilisé par pfSense lui-même.

```
Primary DNS Server: 8.8.8.8
```

> [!tip] Choix du DNS **Options populaires** :
> 
> - **Google** : `8.8.8.8` / `8.8.4.4`
> - **Cloudflare** : `1.1.1.1` / `1.0.0.1`
> - **Quad9** : `9.9.9.9` / `149.112.112.112`
> - **OpenDNS** : `208.67.222.222` / `208.67.220.220`

#### Secondary DNS Server (optionnel)

Serveur DNS de secours.

```
Secondary DNS Server: 8.8.4.4
```

#### Override DNS

> [!warning] Option importante **"Allow DNS server list to be overridden by DHCP/PPP on WAN"**
> 
> - ☑️ **Coché** : pfSense utilisera les DNS fournis par votre FAI (DHCP WAN)
> - ☐ **Décoché** : pfSense utilisera uniquement les DNS que vous avez spécifiés
> 
> **Recommandation** : Décochez cette option pour garder le contrôle total de vos DNS.

**Actions** :

- Configurez ces paramètres selon vos besoins
- Cliquez sur **"Next"**

### Page 4 : Time Server Information

Configuration du fuseau horaire et du serveur de temps.

#### Timezone (Fuseau horaire)

Sélectionnez votre fuseau horaire dans la liste déroulante.

```
Timezone: Europe/Paris
```

> [!info] Pourquoi c'est important ? Un fuseau horaire correct est essentiel pour :
> 
> - **Les journaux système** (logs horodatés correctement)
> - **Les planifications** (sauvegardes, mises à jour)
> - **Les certificats SSL** (validité temporelle)
> - **La synchronisation réseau** (NTP)

#### Timeserver Hostname

Serveur NTP (Network Time Protocol) pour synchroniser l'horloge.

```
Timeserver: 0.pfsense.pool.ntp.org
```

> [!example] Serveurs NTP alternatifs
> 
> - **Pool NTP mondial** : `pool.ntp.org`
> - **Pool NTP France** : `fr.pool.ntp.org`
> - **Serveurs NIST** : `time.nist.gov`

**Actions** :

- Sélectionnez votre fuseau horaire
- Laissez le serveur NTP par défaut (recommandé)
- Cliquez sur **"Next"**

### Page 5 : Configure WAN Interface

Configuration de l'interface WAN (connexion Internet).

Cette page varie selon votre type de connexion Internet :

#### Type de configuration

|Type|Description|Utilisation|
|---|---|---|
|**DHCP**|Adresse IP obtenue automatiquement|Box Internet, modem câble|
|**Static**|Adresse IP fixe configurée manuellement|Connexion professionnelle|
|**PPPoE**|Connexion avec identifiants|Certains FAI (France : rare)|
|**PPTP**|Tunnel VPN pour connexion|Connexions spécifiques|

> [!tip] Cas le plus courant Dans la majorité des cas (box Internet), sélectionnez **DHCP**.

**Si DHCP est sélectionné** :

- Aucune configuration supplémentaire nécessaire
- pfSense obtiendra automatiquement : IP, masque, passerelle, DNS

**Si Static est sélectionné**, vous devrez renseigner :

```
IP Address: 203.0.113.50
Subnet Mask: 24 (/24)
Gateway: 203.0.113.1
```

#### RFC1918 Networks

> [!warning] Option de sécurité **"Block RFC1918 Private Networks"**
> 
> Bloque le trafic provenant de réseaux privés sur l'interface WAN.
> 
> - ☑️ **Coché** : Recommandé pour la sécurité (bloque 192.168.x.x, 10.x.x.x, 172.16-31.x.x)
> - ☐ **Décoché** : Si votre WAN est sur un réseau privé (rare)

#### Block Bogon Networks

> [!info] Qu'est-ce qu'un "bogon" ? Un réseau "bogon" est une plage d'adresses IP non allouée ou réservée qui ne devrait pas apparaître sur Internet public.

**"Block bogon networks"**

- ☑️ **Coché** : Recommandé pour la sécurité
- Bloque le trafic des IP non-routables sur Internet

**Actions** :

- Sélectionnez le type de configuration (généralement DHCP)
- Laissez les options de sécurité cochées
- Cliquez sur **"Next"**

### Page 6 : Configure LAN Interface

Configuration de l'interface LAN (réseau local).

#### LAN IP Address

Adresse IP de pfSense sur le réseau local.

```
LAN IP Address: 192.168.1.1
Subnet Mask: 24
```

> [!info] Modification de l'IP LAN Si vous changez cette adresse IP :
> 
> - Vous devrez reconfigurer votre poste pour accéder à la nouvelle IP
> - Les clients DHCP devront renouveler leur bail
> 
> **Exemple** : Changer `192.168.1.1` en `10.0.0.1`

**Actions** :

- Conservez l'IP par défaut ou modifiez-la selon votre plan d'adressage
- Cliquez sur **"Next"**

### Page 7 : Set Admin WebGUI Password

**Cette étape est CRITIQUE pour la sécurité.**

#### Changement du mot de passe

```
Admin Password: [nouveau mot de passe fort]
Confirm Password: [répétez le mot de passe]
```

> [!warning] Sécurité critique **Le mot de passe par défaut `pfsense` DOIT être changé immédiatement.**
> 
> Un attaquant connaissant l'IP de votre pfSense pourrait prendre le contrôle total de votre réseau avec les identifiants par défaut.

**Critères d'un bon mot de passe** :

- ✅ Au moins 12 caractères
- ✅ Mélange de majuscules, minuscules, chiffres et symboles
- ✅ Pas de mots du dictionnaire
- ✅ Unique (non utilisé ailleurs)

> [!example] Exemple de mot de passe fort `P@ssw0rd` ❌ Mauvais (trop commun) `Kj9#mL2$pQ5!xR8@` ✅ Bon (complexe et aléatoire)

**Actions** :

- Saisissez un **mot de passe fort et unique**
- Confirmez-le
- **Notez-le dans un endroit sûr** (gestionnaire de mots de passe)
- Cliquez sur **"Next"**

### Page 8 : Reload Configuration

Dernière page de l'assistant.

**Actions** :

- Cliquez sur **"Reload"** pour appliquer les changements
- Attendez que pfSense recharge sa configuration (10-30 secondes)

> [!info] Que se passe-t-il ? pfSense :
> 
> 1. Applique tous les paramètres configurés
> 2. Redémarre les services nécessaires
> 3. Active les nouvelles règles firewall
> 4. Vous redirige vers le tableau de bord

### Page 9 : Wizard Completed

L'assistant est terminé. Vous êtes redirigé vers le **Dashboard** (tableau de bord) de pfSense.

**Félicitations ! Votre pfSense est maintenant configuré avec les paramètres de base.**

---

## Modification du mot de passe admin

Si vous avez ignoré l'assistant ou souhaitez modifier le mot de passe ultérieurement, voici la procédure complète.

### Navigation vers les paramètres utilisateur

1. **Connectez-vous** à l'interface WebGUI
2. Cliquez sur votre nom d'utilisateur en haut à droite (`admin`)
3. Sélectionnez **"Edit User"** dans le menu déroulant

Ou via le menu :

```
System → User Manager → Users → admin (icône crayon)
```

### Modification du mot de passe

Dans la page de modification de l'utilisateur :

1. **Localisez la section "Password"**
    
2. **Saisissez le nouveau mot de passe** :
    
    ```
    Password: [nouveau mot de passe]
    Confirm Password: [répétez le mot de passe]
    ```
    
3. **Cliquez sur "Save"** en bas de la page
    

> [!tip] Vérification Après modification, **déconnectez-vous** et **reconnectez-vous** avec le nouveau mot de passe pour vérifier qu'il fonctionne.

### Sécurité avancée du compte admin

> [!tip] Bonnes pratiques supplémentaires
> 
> **1. Créer un utilisateur secondaire**
> 
> - Créez un compte avec privilèges limités pour les tâches quotidiennes
> - Réservez `admin` pour les tâches critiques
> 
> **2. Activer l'authentification 2FA**
> 
> - Disponible via `System → User Manager`
> - Utilise TOTP (Google Authenticator, Authy...)
> 
> **3. Restreindre l'accès par IP**
> 
> - Limitez l'accès WebGUI à certaines IP sources
> - Configuration dans `System → Advanced → Admin Access`

---

## Configuration du fuseau horaire et nom d'hôte

Si vous souhaitez modifier ces paramètres après l'assistant initial.

### Modification du fuseau horaire

#### Via l'interface web

```
System → General Setup
```

**Dans la page General Setup** :

1. **Localisez "Timezone"**
    
2. **Sélectionnez votre fuseau horaire** dans la liste déroulante
    
    ```
    Timezone: Europe/Paris
    ```
    
3. **Configurez les serveurs NTP** (optionnel)
    
    ```
    Timeserver 1: 0.pfsense.pool.ntp.org
    Timeserver 2: 1.pfsense.pool.ntp.org
    ```
    
4. **Cliquez sur "Save"** en bas de la page
    

> [!info] Vérification de l'heure Pour vérifier que l'heure est correcte :
> 
> - Regardez l'heure affichée en haut à droite de l'interface
> - Ou allez dans `Status → NTP` pour voir la synchronisation NTP

### Modification du nom d'hôte et domaine

Dans la même page `System → General Setup` :

#### Hostname

```
Hostname: pfsense
```

**Règles** :

- Lettres minuscules recommandées
- Pas d'espaces
- Pas de points (réservés pour le domaine)
- Caractères autorisés : `a-z`, `0-9`, `-`

#### Domain

```
Domain: localdomain
```

**Conseils** :

- Utilisez `.local`, `.lan`, ou `.home` pour les réseaux privés
- Évitez d'utiliser des TLD publics réels (.com, .fr, etc.)
- Cohérence avec votre infrastructure existante

#### FQDN résultant

Le système combinera automatiquement :

```
FQDN complet : hostname.domain
Exemple : pfsense.localdomain
```

**Actions** :

- Modifiez le hostname et domain selon vos besoins
- Cliquez sur **"Save"**

> [!warning] Attention Modifier le hostname peut affecter :
> 
> - Les certificats SSL (nécessiteront régénération)
> - Les références DNS internes
> - Les configurations qui utilisent le FQDN

### Configuration DNS pour pfSense

Toujours dans `System → General Setup` :

#### DNS Servers

Configurez les serveurs DNS que pfSense lui-même utilisera :

```
DNS Server 1: 8.8.8.8
DNS Server 2: 8.8.4.4
```

> [!info] DNS vs DNS Resolver/Forwarder Ces DNS sont pour **pfSense lui-même** (mises à jour, résolution de noms, etc.).
> 
> Les clients du réseau utiliseront :
> 
> - **DNS Resolver** (Unbound) - recommandé
> - **DNS Forwarder** (dnsmasq) - legacy
> 
> Configuration dans `Services → DNS Resolver` ou `Services → DNS Forwarder`

#### DNS Server Override

Option importante pour le comportement DNS :

```
☐ Allow DNS server list to be overridden by DHCP/PPP on WAN
```

- **Décoché** : Utilise uniquement vos DNS configurés ✅ Recommandé
- **Coché** : Peut utiliser les DNS fournis par le FAI

#### DNS Resolution Behavior

```
☐ Do not use the DNS Forwarder/DNS Resolver as a DNS server for the firewall
```

- **Décoché** : pfSense utilise son propre DNS Resolver ✅ Recommandé
- **Coché** : pfSense interroge directement les DNS configurés

**Actions** :

- Configurez vos DNS préférés
- Décochez "Allow DNS server list to be overridden"
- Cliquez sur **"Save"**

---

## Pièges courants

### 1. Oubli du changement de mot de passe

> [!warning] Erreur critique **Symptôme** : Conserver le mot de passe par défaut `pfsense`
> 
> **Risque** : Compromission totale du firewall par un attaquant
> 
> **Solution** : Changez **IMMÉDIATEMENT** le mot de passe par défaut

### 2. Mauvais fuseau horaire

> [!warning] Problème de logs **Symptôme** : Les logs montrent des heures incorrectes (décalage de plusieurs heures)
> 
> **Conséquence** :
> 
> - Difficulté à corréler les événements
> - Problèmes de certificats SSL
> - Dysfonctionnements des tâches planifiées
> 
> **Solution** : Vérifiez et corrigez le fuseau horaire dans `System → General Setup`

### 3. Changement d'IP LAN sans préparation

> [!warning] Perte d'accès **Symptôme** : Après avoir changé l'IP LAN, impossible d'accéder à l'interface web
> 
> **Cause** : Votre PC est encore sur l'ancien sous-réseau
> 
> **Solution** :
> 
> 1. Reconfigurez votre PC avec une IP du nouveau sous-réseau
> 2. Ou attendez le renouvellement DHCP
> 3. Accédez à la nouvelle IP de pfSense

### 4. Blocage des réseaux RFC1918 sur WAN

> [!warning] Problème de connectivité **Symptôme** : Pas d'accès Internet alors que WAN utilise une IP privée (ex: derrière une box)
> 
> **Cause** : L'option "Block RFC1918 Private Networks" est cochée sur le WAN
> 
> **Solution** : Décochez cette option si votre WAN est sur un réseau privé
> 
> ```
> Interfaces → WAN → ☐ Block private networks
> ```

### 5. Certificat SSL auto-signé

> [!info] Ce n'est pas un bug **Symptôme** : Avertissement de sécurité du navigateur à chaque connexion
> 
> **Cause** : pfSense utilise un certificat auto-signé par défaut
> 
> **Solutions** :
> 
> 1. **Accepter l'avertissement** à chaque fois (simple mais agaçant)
> 2. **Ajouter une exception permanente** dans le navigateur
> 3. **Installer un certificat valide** (Let's Encrypt ou certificat interne)

### 6. DNS non fonctionnels après configuration

> [!warning] Pas de résolution DNS **Symptôme** : Impossible de résoudre les noms de domaine, mais les IP fonctionnent
> 
> **Causes possibles** :
> 
> 1. DNS mal configurés dans `System → General Setup`
> 2. DNS Resolver/Forwarder non démarré
> 3. Règles firewall bloquant le port 53
> 
> **Diagnostic** :
> 
> ```
> Diagnostics → DNS Lookup
> ```
> 
> **Solutions** :
> 
> - Vérifiez les DNS dans `System → General Setup`
> - Vérifiez `Services → DNS Resolver` (doit être activé)
> - Vérifiez les règles firewall sur LAN

### 7. Nom d'hôte invalide

> [!warning] Erreur de configuration **Symptôme** : Erreur lors de la sauvegarde du hostname
> 
> **Cause** : Caractères invalides dans le nom
> 
> **Règles à respecter** :
> 
> - Pas d'espaces
> - Pas de caractères spéciaux (sauf `-`)
> - Pas de points
> - Pas de majuscules (recommandation)

---

## Bonnes pratiques

### Sécurité de l'accès web

> [!tip] Sécurisez l'accès à l'interface
> 
> **1. Changez le port HTTPS par défaut**
> 
> ```
> System → Advanced → Admin Access
> TCP Port: 8443 (au lieu de 443)
> ```
> 
> **2. Désactivez l'accès HTTP**
> 
> ```
> ☐ WebGUI redirect - Disable webConfigurator redirect rule
> ```
> 
> **3. Restreignez les IP autorisées** Créez une règle firewall pour n'autoriser que certaines IP à accéder au port de gestion.
> 
> **4. Activez le HTTPS strict**
> 
> ```
> ☑ HTTP Strict Transport Security
> ```

### Documentation de votre configuration

> [!tip] Conservez une trace Créez un document avec :
> 
> - **IP LAN** : 192.168.1.1/24
> - **Hostname** : pfsense.localdomain
> - **DNS utilisés** : 8.8.8.8, 8.8.4.4
> - **Fuseau horaire** : Europe/Paris
> - **Port WebGUI** : 443 ou personnalisé
> - **Mot de passe** : [dans gestionnaire de mots de passe]

### Sauvegarde immédiate

> [!tip] Première sauvegarde Dès que la configuration initiale est terminée, créez une sauvegarde :
> 
> ```
> Diagnostics → Backup & Restore → Backup Configuration
> ```
> 
> - Téléchargez le fichier XML
> - Conservez-le en lieu sûr
> - Datez la sauvegarde clairement : `pfsense-backup-2026-01-10.xml`

### Mise à jour du système

> [!tip] Vérifiez les mises à jour Après la configuration initiale :
> 
> ```
> System → Update → Check for Updates
> ```
> 
> - pfSense vérifiera les mises à jour disponibles
> - Installez les mises à jour de sécurité
> - Redémarrez si nécessaire

### Activation du dashboard

> [!tip] Personnalisez votre tableau de bord Le Dashboard affiche des widgets utiles :
> 
> **Widgets recommandés** :
> 
> - **System Information** : infos système
> - **Interfaces** : état des interfaces
> - **Services Status** : état des services
> - **Traffic Graphs** : graphiques de trafic
> - **Gateway Status** : état des passerelles
> 
> **Pour ajouter/supprimer des widgets** :
> 
> - Cliquez sur `+` en haut à droite du Dashboard
> - Glissez-déposez pour réorganiser

### Vérifications post-configuration

> [!tip] Checklist de vérification
> 
> ✅ **Connectivité Internet**
> 
> - Testez depuis pfSense : `Diagnostics → Ping`
> - Testez depuis un client du LAN
> 
> ✅ **Résolution DNS**
> 
> - Testez : `Diagnostics → DNS Lookup`
> - Essayez de résoudre `www.google.com`
> 
> ✅ **Synchronisation horaire**
> 
> - Vérifiez : `Status → NTP`
> - L'horloge doit être synchronisée
> 
> ✅ **Services actifs**
> 
> - Vérifiez : `Status → Services`
> - Tous les services essentiels doivent être démarrés
> 
> ✅ **Accès HTTPS fonctionnel**
> 
> - Reconnectez-vous avec le nouveau mot de passe
> - Vérifiez que l'interface répond correctement

### Utilisation des favoris

> [!tip] Organisez votre navigation pfSense permet de marquer des pages en favoris :
> 
> - Cliquez sur l'icône ⭐ à côté du titre de la page
> - Les favoris apparaissent dans le menu supérieur
> - Pratique pour accéder rapidement aux pages fréquemment utilisées

---

## 🎯 Résumé

Après avoir suivi cette section, vous devriez avoir :

✅ Accédé à l'interface WebGUI de pfSense via HTTPS ✅ Complété l'assistant de configuration initiale ✅ Changé le mot de passe administrateur par défaut ✅ Configuré le fuseau horaire et le nom d'hôte ✅ Vérifié les paramètres DNS ✅ Compris les pièges courants et comment les éviter ✅ Appliqué les bonnes pratiques de sécurité

**Votre pfSense est maintenant prêt pour une configuration avancée !**

> [!success] Configuration initiale terminée Vous avez franchi l'étape critique de la première configuration. Votre firewall est maintenant :
> 
> - Accessible de manière sécurisée
> - Correctement identifié sur le réseau
> - Synchronisé avec l'heure exacte
> - Prêt pour les configurations avancées (règles firewall, VPN, services, etc.)

---

_Document créé pour Obsidian - pfSense Configuration Guide_ _Dernière mise à jour : Janvier 2026_