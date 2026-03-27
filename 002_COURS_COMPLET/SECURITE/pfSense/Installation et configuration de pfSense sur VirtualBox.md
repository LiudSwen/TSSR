

## Vue d'ensemble

Ce tutoriel vous guide pour installer pfSense sur VirtualBox avec :

- Une interface WAN en mode NAT (accès Internet)
- Une interface LAN en réseau interne (réseau privé)
- Configuration du routage pour permettre aux machines internes d'accéder à Internet

## Prérequis

- VirtualBox installé
- Image ISO de pfSense téléchargée depuis le site officiel
- Au moins 2 Go de RAM disponibles
- 10 Go d'espace disque

## Étape 1 : Création de la VM pfSense

1. Ouvrez VirtualBox et cliquez sur **Nouvelle**
2. Configurez la VM :
    - Nom : `pfSense`
    - Type : `BSD`
    - Version : `FreeBSD (64-bit)`
    - Mémoire : `2048 MB` minimum
    - Disque dur : Créer un disque virtuel de `10 GB`

## Étape 2 : Configuration des interfaces réseau

1. Sélectionnez la VM pfSense, puis **Configuration**
2. Allez dans **Réseau**

### Interface 1 - WAN (Internet)

- **Adapter 1** (activé)
- Mode d'accès réseau : `NAT`
- Type de carte : `Intel PRO/1000 MT Desktop`

### Interface 2 - LAN (Réseau interne)

- **Adapter 2** (activé)
- Mode d'accès réseau : `Réseau interne`
- Nom : `intnet` (ou autre nom de votre choix)
- Type de carte : `Intel PRO/1000 MT Desktop`

## Étape 3 : Installation de pfSense

1. Démarrez la VM et montez l'ISO pfSense
2. Appuyez sur **Entrée** pour démarrer l'installateur
3. Acceptez les droits d'auteur en appuyant sur **Entrée**
4. Sélectionnez **Install** et appuyez sur **Entrée**
5. Partitionnement : choisissez **Auto (ZFS)** puis **Stripe** (configuration simple)
6. Sélectionnez le disque virtuel et confirmez
7. Attendez la fin de l'installation
8. Sélectionnez **No** pour ne pas ouvrir de shell
9. Sélectionnez **Reboot**
10. Démontez l'ISO avant le redémarrage

## Étape 4 : Configuration initiale des interfaces

Après le redémarrage, pfSense détecte automatiquement les interfaces.

1. Si demandé, configurez les VLANs : tapez `n` (non)
2. Attribution des interfaces :
    - **WAN** → `em0` (ou première interface détectée)
    - **LAN** → `em1` (ou deuxième interface détectée)
3. Confirmez avec `y`

## Étape 5 : Configuration de l'interface LAN

1. Au menu principal, tapez `2` pour **Set interface(s) IP address**
2. Sélectionnez `2` pour LAN
3. Configurez l'adresse IP LAN :
    - Adresse IPv4 : `192.168.100.1`
    - Masque : `24` (soit 255.255.255.0)
4. Pour IPv6 : appuyez sur **Entrée** (pas de configuration)
5. Activez le serveur DHCP : `y`
6. Plage DHCP :
    - Début : `192.168.100.10`
    - Fin : `192.168.100.200`
7. HTTP pour WebGUI : `n` (utilisez HTTPS)

## Étape 6 : Création d'une VM cliente de test

1. Créez une nouvelle VM (Windows, Linux, etc.)
2. Dans **Configuration** → **Réseau** :
    - **Adapter 1** : `Réseau interne`
    - Nom : `intnet` (le même que pour pfSense LAN)
3. Démarrez la VM cliente

Elle devrait automatiquement obtenir une IP via DHCP (192.168.100.x) et avoir accès à Internet.

## Étape 7 : Accès à l'interface Web de pfSense

Depuis une VM sur le réseau interne :

1. Ouvrez un navigateur web
2. Accédez à : `https://192.168.100.1`
3. Acceptez le certificat auto-signé
4. Identifiants par défaut :
    - Utilisateur : `admin`
    - Mot de passe : `pfsense`

## Étape 8 : Configuration avancée (interface Web)

### Premier démarrage - Assistant de configuration

1. Cliquez sur **Next**
2. Hostname : `pfsense`
3. Domain : `localdomain` (ou votre domaine)
4. DNS primaire : `8.8.8.8` (Google DNS)
5. DNS secondaire : `8.8.4.4`
6. Fuseau horaire : sélectionnez votre zone
7. WAN : laissez DHCP (configuré via NAT)
8. LAN : déjà configuré (192.168.100.1/24)
9. **Changez le mot de passe admin** (important !)
10. Cliquez sur **Reload** puis **Finish**

### Vérification du routage NAT

Le NAT devrait être automatiquement configuré. Pour vérifier :

1. Allez dans **Firewall** → **NAT** → **Outbound**
2. Mode : devrait être sur `Automatic outbound NAT`

### Règles de pare-feu LAN

Par défaut, pfSense autorise tout le trafic sortant depuis le LAN. Vérifiez :

1. **Firewall** → **Rules** → **LAN**
2. Vous devriez voir une règle par défaut autorisant tout le trafic

## Tests de connectivité

Depuis votre VM cliente :

### Test 1 : Ping vers la passerelle

```bash
ping 192.168.100.1
```

### Test 2 : Ping vers Internet

```bash
ping 8.8.8.8
```

### Test 3 : Résolution DNS

```bash
ping google.com
```

Si les trois tests fonctionnent, votre configuration est réussie !

## Schéma réseau final

```
Internet
   ↓
[VirtualBox NAT]
   ↓
WAN (em0) - pfSense - LAN (em1)
                        ↓
                  [Réseau interne: intnet]
                        ↓
                   VM Clientes
              (192.168.100.10-200)
```

## Dépannage

### Les VMs clientes n'obtiennent pas d'IP

- Vérifiez que le serveur DHCP est activé dans pfSense (Status → Services)
- Vérifiez que la VM cliente est bien sur le réseau interne `intnet`

### Pas d'accès Internet depuis les VMs

- Vérifiez que l'interface WAN a bien une IP (Status → Interfaces)
- Vérifiez les règles de pare-feu LAN
- Vérifiez que le NAT est activé (Firewall → NAT → Outbound)

### Impossible d'accéder à l'interface Web

- Vérifiez que vous êtes sur une VM du réseau interne
- Vérifiez l'adresse IP de votre VM cliente (`ipconfig` ou `ip addr`)
- Essayez en HTTP : `http://192.168.100.1`

## Fonctionnalités avancées à explorer

- **VPN** : Configurez OpenVPN ou IPsec pour accès distant
- **Filtrage de contenu** : Installez pfBlockerNG ou Squid
- **IDS/IPS** : Activez Suricata ou Snort
- **QoS** : Gestion de la bande passante avec Traffic Shaping
- **Multi-WAN** : Ajoutez une deuxième connexion WAN pour la redondance

## Conclusion

Vous avez maintenant un routeur/firewall pfSense fonctionnel sur VirtualBox ! Cette configuration est idéale pour des tests, de l'apprentissage ou pour créer des labs de sécurité réseau.