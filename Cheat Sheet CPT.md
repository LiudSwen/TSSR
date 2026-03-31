
Bravo pour la réussite de l'atelier ! C'est souvent en "mettant les mains dans le cambouis" qu'on apprend le mieux, même si c'est laborieux au début.

Voici une **Cheat Sheet (antisèche)** structurée pour Cisco IOS (le système d'exploitation des routeurs et switchs), couvrant l'essentiel de ce que tu utiliseras dans Packet Tracer pour le CCNA et au-delà.

---

### 1. Navigation et Modes

Il est crucial de savoir où tu te trouves (regarde le symbole après le nom du routeur).

|**Mode**|**Prompt**|**Commande pour y accéder**|**Description**|
|---|---|---|---|
|**Utilisateur**|`Router>`|(Défaut)|Mode lecture seule très limité.|
|**Privilégié**|`Router#`|`enable`|Accès complet aux commandes de vérification (`show`).|
|**Config Globale**|`Router(config)#`|`configure terminal`|Pour modifier la configuration de l'appareil.|
|**Interface**|`Router(config-if)#`|`interface [nom]`|Pour configurer un port spécifique (IP, activation).|
|**Ligne**|`Router(config-line)#`|`line console 0`|Pour configurer les accès (mot de passe console/SSH).|

- **Revenir en arrière :** `exit` (recule d'un niveau) ou `end` (retour direct au mode `#`).
    

---

### 2. Configuration de Base (La routine de départ)

À faire sur chaque nouvel équipement.

Bash

```
hostname R1                  # Changer le nom du routeur/switch
no ip domain-lookup          # Empêche la recherche DNS en cas de faute de frappe (très utile !)
banner motd #MESSAGE#        # Message d'avertissement à la connexion
service password-encryption  # Chiffre les mots de passe dans le fichier de config
```

**Sécuriser les accès :**

Bash

```
enable secret [mdp]          # Mot de passe pour passer du mode > au mode # (chiffré)

line console 0               # Configuration du port console
 password [mdp]
 login

line vty 0 4                 # Configuration de l'accès distant (Telnet/SSH)
 password [mdp]
 login
```

---

### 3. Gestion des Interfaces (Layer 3)

Pour donner une IP à un routeur.

Bash

```
interface gigabitEthernet 0/0/0  # Sélectionner l'interface (ou g0/0)
 ip address 192.168.1.1 255.255.255.0  # Assigner l'IP et le masque
 description Vers_LAN_Compta       # Toujours documenter !
 no shutdown                       # ALLUMER l'interface (éteinte par défaut)
```

---

### 4. Le Routage (Layer 3)

Comment relier les réseaux entre eux.

**Routage Statique :**

Bash

```
# Syntaxe : ip route [réseau_dest] [masque] [prochain_saut_ou_interface]
ip route 192.168.20.0 255.255.255.0 10.0.0.2
ip route 0.0.0.0 0.0.0.0 203.0.113.1   # Route par défaut (Gateway of last resort)
```

**Routage Dynamique (Ex: OSPF) :**

Bash

```
router ospf 1
 router-id 1.1.1.1
 network 192.168.1.0 0.0.0.255 area 0  # Attention : masque inversé (wildcard)
 passive-interface g0/1                # Ne pas envoyer de hello OSPF vers le LAN
```

---

### 5. Le Switching (Layer 2)

VLANs et Trunks.

**Créer des VLANs :**

Bash

```
vlan 10
 name COMPTA
vlan 20
 name RH
```

**Configurer les ports (Access vs Trunk) :**

Bash

```
interface range f0/1 - 10     # Configurer plusieurs ports d'un coup
 switchport mode access       # Port relié à un PC
 switchport access vlan 10    # Assigner au VLAN 10

interface g0/1                # Port relié à un autre switch ou routeur
 switchport mode trunk        # Laisse passer tous les VLANs
 switchport trunk native vlan 99 # (Sécurité) Changer le VLAN natif
```

---

### 6. Commandes de Vérification (`Show`)

**C'est ici que 90% du dépannage se fait.** À lancer en mode privilégié (`#`).

|**Commande**|**À quoi ça sert ? (Le "Must Have")**|
|---|---|
|`show ip interface brief`|**LA commande vitale.** Résumé des IPs et de l'état (Up/Up) des ports.|
|`show running-config`|Affiche la configuration actuelle complète (ce qui est en mémoire).|
|`show ip route`|Affiche la table de routage (C = Connecté, S = Static, O = OSPF).|
|`show vlan brief`|Voir quels ports sont dans quels VLANs.|
|`show interfaces trunk`|Vérifier si le lien entre switchs fonctionne bien.|
|`show cdp neighbors`|Voir les équipements Cisco directement connectés (magique pour faire un schéma !).|
|`ping [ip]`|Tester la connectivité.|

---

### 7. Sauvegarde et Gestion de fichiers

Sur Cisco, si tu redémarres sans sauvegarder, tu perds tout ce qui est dans la `running-config`.

Bash

```
copy running-config startup-config  # Sauvegarde la config actuelle vers la mémoire flash
# OU le raccourci (ancienne école mais marche toujours) :
write memory  (ou juste "wr")
```

Pour effacer un routeur et recommencer à zéro :

Bash

```
erase startup-config
reload
```

---

### 8. Raccourcis et Astuces Clavier (Les "Life Hacks")

1. **Tabulation (`Tab`)** : Complète automatiquement la commande (Ex: tape `int` + Tab -> `interface`).
    
2. **Point d'interrogation (`?`)** : Ne sais plus la commande ? Tape `co?` ou `router ospf ?` pour voir les options disponibles.
    
3. **Flèche Haut/Bas** : Naviguer dans l'historique des commandes précédentes.
    
4. **`do`** : Permet de lancer une commande `show` ou `ping` sans quitter le mode de configuration.
    
    - _Exemple :_ Tu es dans `Router(config-if)#` et tu veux voir les IP. Au lieu de faire `exit` `exit`, tape `do show ip int brief`.
        
5. **`no`** : Sert à annuler n'importe quelle commande.
    
    - _Exemple :_ Tu as mis une mauvaise IP ? Tape `no ip address`. Tu veux éteindre le port ? `shutdown` (le contraire de `no shutdown`).
        

Tu peux copier/coller cette liste dans un fichier texte pour tes prochains TPs ! Bonne continuation avec Packet Tracer !