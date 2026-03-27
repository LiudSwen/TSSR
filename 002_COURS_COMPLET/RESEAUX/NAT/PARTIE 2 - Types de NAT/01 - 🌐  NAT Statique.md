

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

## 🎯 Introduction au NAT statique

Le **NAT statique** (Static NAT) est le type de NAT le plus simple et le plus prévisible. Il établit une correspondance **permanente et bidirectionnelle** entre une adresse IP privée et une adresse IP publique.

> [!info] Caractéristique principale Contrairement aux autres types de NAT, le mapping est **fixe** et **configuré manuellement** par l'administrateur réseau. Une fois configuré, il reste actif tant qu'il n'est pas supprimé.

### Pourquoi utiliser le NAT statique ?

- **Accès permanent** : Les serveurs internes doivent être joignables de l'extérieur avec la même adresse IP publique
- **Prévisibilité** : Le mapping ne change jamais, facilitant la configuration des pare-feu et des ACL
- **Simplicité** : Facile à comprendre et à dépanner
- **Traçabilité** : Chaque adresse interne a toujours la même adresse externe

---

## ⚙️ Principe de fonctionnement

Le NAT statique fonctionne selon un principe de **traduction fixe** dans les deux sens.

### Flux sortant (Inside Local → Inside Global)

```
[Réseau Interne]        [Routeur NAT]        [Internet]
192.168.1.10     →      Traduction    →      203.0.113.50
                        (statique)
```

1. Le paquet part de `192.168.1.10` (inside local)
2. Le routeur remplace l'adresse source par `203.0.113.50` (inside global)
3. Le paquet arrive sur Internet avec l'adresse publique

### Flux entrant (Inside Global → Inside Local)

```
[Internet]              [Routeur NAT]        [Réseau Interne]
203.0.113.50     ←      Traduction    ←      192.168.1.10
                        (statique)
```

1. Un paquet arrive destiné à `203.0.113.50`
2. Le routeur traduit l'adresse destination en `192.168.1.10`
3. Le paquet est routé vers le serveur interne

> [!warning] Bidirectionnalité Le NAT statique fonctionne **dans les deux sens automatiquement**. Dès qu'une traduction inside local ↔ inside global est configurée, elle s'applique au trafic entrant ET sortant.

### Table de traduction NAT statique

Le routeur maintient une table de correspondance permanente :

|Inside Local|Inside Global|Type|État|
|---|---|---|---|
|192.168.1.10|203.0.113.50|static|permanent|
|192.168.1.20|203.0.113.51|static|permanent|
|192.168.1.30|203.0.113.52|static|permanent|

---

## 🔗 Mapping 1:1

Le **mapping 1:1** (one-to-one) est le principe fondamental du NAT statique.

### Concept

```
1 adresse IP privée  ←→  1 adresse IP publique
```

Chaque adresse privée est associée à **une seule et unique** adresse publique, et vice-versa.

> [!example] Exemple de mapping 1:1
> 
> ```
> Serveur Web interne    : 192.168.1.10
> Adresse publique       : 203.0.113.50
> 
> Serveur Mail interne   : 192.168.1.20
> Adresse publique       : 203.0.113.51
> 
> Serveur FTP interne    : 192.168.1.30
> Adresse publique       : 203.0.113.52
> ```
> 
> Chaque serveur dispose de sa propre adresse IP publique dédiée.

### Implications du mapping 1:1

#### Consommation d'adresses IP publiques

|Serveurs internes|Adresses publiques nécessaires|
|---|---|
|1 serveur|1 adresse publique|
|10 serveurs|10 adresses publiques|
|50 serveurs|50 adresses publiques|

> [!warning] Coût en adresses IP Le NAT statique nécessite **autant d'adresses IP publiques que de machines à traduire**. C'est son principal inconvénient dans un contexte de pénurie d'IPv4.

#### Avantages du 1:1

- **Isolation parfaite** : Chaque serveur a son identité publique propre
- **Logs simplifiés** : Facile d'identifier quel serveur interne a généré du trafic
- **Pas de conflit de ports** : Plusieurs serveurs peuvent utiliser le même port (ex: 443)
- **Performance** : Aucune surcharge de traduction de ports

#### Inconvénients du 1:1

- **Consommation excessive** d'adresses IPv4
- **Coût financier** : Les adresses publiques ont un prix
- **Inflexibilité** : Difficile de réorganiser sans reconfig

---

## 💼 Cas d'usage

Le NAT statique est particulièrement adapté à certains scénarios spécifiques.

### 1. Hébergement de serveurs publics

> [!example] Serveur Web accessible depuis Internet Une entreprise héberge son site web en interne et veut qu'il soit accessible depuis Internet avec une adresse IP publique fixe.
> 
> ```
> Serveur Web interne : 10.0.10.50
> IP publique         : 198.51.100.25
> DNS                 : www.entreprise.com → 198.51.100.25
> ```
> 
> Les visiteurs externes accèdent toujours à la même IP publique, qui est traduite vers le serveur interne.

### 2. Serveurs nécessitant des connexions entrantes

**Applications typiques :**

- Serveurs de messagerie (SMTP, IMAP)
- Serveurs de base de données accessibles à distance
- Serveurs VPN
- Serveurs de jeux multijoueurs
- APIs REST publiques

> [!info] Pourquoi le NAT statique ? Ces services **reçoivent** des connexions initiées depuis l'extérieur. Le NAT statique garantit que les requêtes entrantes arrivent toujours au bon serveur, sans configuration de port forwarding.

### 3. Conformité réglementaire et audit

Certains secteurs (finance, santé) exigent :

- **Traçabilité stricte** : Savoir quelle machine interne a généré quel trafic
- **IP fixe pour la liste blanche** : Les partenaires autorisent une IP publique spécifique
- **Séparation des flux** : Chaque service critique a sa propre IP publique

> [!example] Exemple bancaire
> 
> ```
> Serveur transactions : 172.16.1.10 → 203.0.113.100
> Serveur reporting    : 172.16.1.20 → 203.0.113.101
> Serveur backup       : 172.16.1.30 → 203.0.113.102
> ```
> 
> Les auditeurs peuvent facilement identifier les flux par adresse IP publique.

### 4. Intégration avec des systèmes externes

**Cas typique :** Un partenaire B2B accepte uniquement le trafic provenant d'adresses IP spécifiques.

```
Partenaire configure firewall :
  Autorisé : 198.51.100.50
  
Votre serveur : 192.168.5.100 → NAT statique → 198.51.100.50
```

> [!tip] Alternative impossible Le NAT dynamique ou PAT ne convient pas ici car l'adresse source changerait, et le partenaire bloquerait les connexions.

### 5. DMZ (Zone démilitarisée)

Les serveurs en DMZ exposés à Internet utilisent souvent du NAT statique :

```
[Internet] ←→ [Firewall] ←→ [DMZ avec NAT statique] ←→ [LAN interne]
                              |
                              ├─ Serveur Web : 10.10.10.10 → 203.0.113.10
                              ├─ Serveur Mail : 10.10.10.20 → 203.0.113.20
                              └─ Serveur DNS : 10.10.10.30 → 203.0.113.30
```

### Comparaison avec d'autres types de NAT

|Besoin|NAT Statique|NAT Dynamique|PAT|
|---|---|---|---|
|Serveur accessible depuis Internet|✅ Oui|❌ Non|⚠️ Avec port forwarding|
|IP publique fixe par machine|✅ Oui|❌ Non|❌ Non|
|Économie d'IP publiques|❌ Non|⚠️ Partiel|✅ Oui|
|Connexions entrantes simples|✅ Oui|❌ Non|⚠️ Config manuelle|
|Traçabilité parfaite|✅ Oui|⚠️ Moyenne|❌ Difficile|

---

## 🛠️ Configuration

### Syntaxe Cisco IOS

```bash
# Configuration du NAT statique basique
Router(config)# ip nat inside source static <IP_LOCALE> <IP_GLOBALE>

# Désignation des interfaces
Router(config)# interface <INTERFACE_INTERNE>
Router(config-if)# ip nat inside

Router(config)# interface <INTERFACE_EXTERNE>
Router(config-if)# ip nat outside
```

> [!example] Configuration complète
> 
> ```bash
> # Exemple : Traduire 192.168.1.10 en 203.0.113.50
> Router(config)# ip nat inside source static 192.168.1.10 203.0.113.50
> 
> # Interface interne (vers le LAN)
> Router(config)# interface GigabitEthernet0/0
> Router(config-if)# ip address 192.168.1.1 255.255.255.0
> Router(config-if)# ip nat inside
> Router(config-if)# no shutdown
> Router(config-if)# exit
> 
> # Interface externe (vers Internet)
> Router(config)# interface GigabitEthernet0/1
> Router(config-if)# ip address 203.0.113.1 255.255.255.0
> Router(config-if)# ip nat outside
> Router(config-if)# no shutdown
> Router(config-if)# exit
> ```

### Configuration de plusieurs mappings

```bash
# Serveur Web
Router(config)# ip nat inside source static 192.168.1.10 203.0.113.50

# Serveur Mail
Router(config)# ip nat inside source static 192.168.1.20 203.0.113.51

# Serveur FTP
Router(config)# ip nat inside source static 192.168.1.30 203.0.113.52

# Serveur DNS
Router(config)# ip nat inside source static 192.168.1.40 203.0.113.53
```

### Vérification de la configuration

```bash
# Afficher les traductions NAT statiques
Router# show ip nat translations

# Afficher les statistiques NAT
Router# show ip nat statistics

# Voir les interfaces NAT
Router# show ip nat nvi statistics
```

> [!example] Exemple de sortie
> 
> ```
> Router# show ip nat translations
> Pro Inside global      Inside local       Outside local      Outside global
> --- 203.0.113.50       192.168.1.10       ---                ---
> --- 203.0.113.51       192.168.1.20       ---                ---
> --- 203.0.113.52       192.168.1.30       ---                ---
> ```

### Suppression d'un mapping statique

```bash
# Supprimer une traduction spécifique
Router(config)# no ip nat inside source static 192.168.1.10 203.0.113.50

# Effacer toutes les traductions dynamiques (ne supprime pas les statiques)
Router# clear ip nat translation *
```

---

## ⚠️ Pièges courants

### 1. Oubli de désigner les interfaces inside/outside

> [!warning] Erreur fréquente
> 
> ```bash
> # ❌ Configuration incomplète - ne fonctionnera PAS
> Router(config)# ip nat inside source static 192.168.1.10 203.0.113.50
> # Les interfaces ne sont pas configurées avec ip nat inside/outside
> ```
> 
> **Symptôme :** Le NAT ne fonctionne pas du tout, les paquets ne sont pas traduits.
> 
> **Solution :** Toujours configurer `ip nat inside` et `ip nat outside` sur les bonnes interfaces.

### 2. Routage manquant

Le NAT ne crée pas de routes automatiquement. Il faut que le routage soit correct.

```bash
# ✅ Vérifier les routes
Router# show ip route

# Si nécessaire, ajouter une route par défaut
Router(config)# ip route 0.0.0.0 0.0.0.0 <IP_GATEWAY_EXTERNE>
```

> [!tip] Vérification Avant de configurer le NAT, assure-toi que le routage fonctionne en testant avec des pings depuis le routeur lui-même.

### 3. Conflit d'adresses IP

```bash
# ❌ Erreur : Deux machines traduites vers la même IP publique
Router(config)# ip nat inside source static 192.168.1.10 203.0.113.50
Router(config)# ip nat inside source static 192.168.1.20 203.0.113.50
                                                                    ^
% NAT: translation already exists
```

> [!warning] Mapping 1:1 strict Chaque adresse IP publique ne peut être associée qu'à **une seule** adresse IP privée en NAT statique.

### 4. Pare-feu bloquant le trafic

Le NAT traduit les adresses, mais ne gère pas le filtrage. Les ACL ou pare-feu peuvent bloquer le trafic.

```bash
# Vérifier les ACL appliquées
Router# show ip access-lists
Router# show ip interface <INTERFACE>

# Vérifier si une ACL bloque le trafic NAT
Router# debug ip nat
Router# debug ip packet
```

### 5. Utilisation d'une IP publique déjà routée

> [!warning] Problème de routage Si l'adresse IP publique utilisée pour le NAT statique appartient au sous-réseau de l'interface externe, il peut y avoir des conflits.
> 
> ```bash
> # ❌ Configuration problématique
> interface GigabitEthernet0/1
>  ip address 203.0.113.1 255.255.255.0  # Sous-réseau /24
> 
> ip nat inside source static 192.168.1.10 203.0.113.50  # Dans le même /24
> ```
> 
> **Conséquence :** Le routeur peut avoir du mal à déterminer si un paquet pour 203.0.113.50 doit être NAT ou routé localement.

### 6. Oubli de la connectivité retour

Le NAT traduit l'adresse source en sortie, mais il faut que les réponses puissent revenir.

```
[Serveur 192.168.1.10] → NAT → [203.0.113.50] → [Internet]
                          ✅ Aller fonctionne
                          
[Internet] → [203.0.113.50] → NAT → [192.168.1.10]
             ❌ Le retour nécessite que l'IP publique soit routable sur Internet
```

> [!info] Vérification L'adresse IP publique doit être une adresse **routable** et **autorisée** par ton FAI ou opérateur. Les adresses privées (RFC 1918) ne fonctionneront pas.

---

## ✅ Bonnes pratiques

### 1. Documentation systématique

Maintiens un tableau de correspondance à jour :

|Serveur|IP Privée|IP Publique|Usage|Contact|
|---|---|---|---|---|
|web-prod|192.168.1.10|203.0.113.50|Site web|admin@domain|
|mail-srv|192.168.1.20|203.0.113.51|Messagerie|admin@domain|
|ftp-backup|192.168.1.30|203.0.113.52|Backups|ops@domain|

> [!tip] Automatisation Utilise des outils de documentation réseau (NetBox, phpIPAM) pour gérer automatiquement ces correspondances.

### 2. Nommage cohérent

```bash
# ✅ Utilise des commentaires ou descriptions
Router(config)# ip nat inside source static 192.168.1.10 203.0.113.50
Router(config)# ! Serveur Web Production - web-prod.entreprise.com

# Ou configure des descriptions d'interfaces
Router(config)# interface GigabitEthernet0/0
Router(config-if)# description LAN-INTERNE-SERVEURS
```

### 3. Surveillance et monitoring

```bash
# Activer les logs NAT (avec parcimonie en production)
Router(config)# ip nat log translations syslog

# Monitoring régulier
Router# show ip nat statistics
Router# show ip nat translations
```

> [!warning] Performance `debug ip nat` génère beaucoup de logs. Ne l'active qu'en dépannage, jamais en production continue.

### 4. Planification des adresses IP

- **Réserve un bloc d'IP publiques** dédié au NAT statique
- **Évite les chevauchements** avec d'autres usages (NAT dynamique, PAT)
- **Anticipe la croissance** : Prévois des adresses supplémentaires

> [!example] Exemple de plan d'adressage
> 
> ```
> Bloc public alloué : 203.0.113.0/27 (32 adresses)
> 
> Répartition :
> - 203.0.113.1 - 203.0.113.5   : Équipements réseau (routeurs, FW)
> - 203.0.113.10 - 203.0.113.30 : NAT statique (serveurs)
> - 203.0.113.31                : Pool NAT dynamique
> ```

### 5. Sécurisation

Le NAT statique rend les serveurs **accessibles depuis Internet**. Toujours :

- **Appliquer des ACL** pour filtrer le trafic entrant
- **Utiliser un pare-feu** en complément
- **Activer les logs** pour l'audit
- **Limiter aux ports nécessaires**

```bash
# Exemple : Autoriser uniquement HTTPS vers le serveur web
Router(config)# ip access-list extended WEB-IN
Router(config-ext-nacl)# permit tcp any host 203.0.113.50 eq 443
Router(config-ext-nacl)# deny ip any any log
Router(config-ext-nacl)# exit

Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip access-group WEB-IN in
```

### 6. Tests avant mise en production

> [!tip] Procédure de test
> 
> 1. **Test interne** : Vérifie que le serveur interne fonctionne sur son IP privée
> 2. **Test NAT sortant** : Depuis le serveur, teste l'accès Internet
> 3. **Test NAT entrant** : Depuis l'extérieur, teste l'accès via l'IP publique
> 4. **Test de charge** : Simule du trafic pour vérifier la performance
> 5. **Test de failover** : Vérifie le comportement en cas de panne

### 7. Gestion du changement

Lors de modifications :

- **Planifie une fenêtre de maintenance**
- **Préviens les utilisateurs** en cas de serveur public
- **Mets à jour le DNS** si l'IP publique change
- **Garde une copie de la config** avant modification

```bash
# Sauvegarder la configuration avant changement
Router# copy running-config tftp://192.168.1.100/backup-NAT-20231215.cfg
```

---

## 🎓 Astuces

### Astuce 1 : Identifier rapidement les traductions actives

```bash
# Voir uniquement les traductions statiques
Router# show ip nat translations | include static

# Compter le nombre de traductions
Router# show ip nat translations | count
```

### Astuce 2 : Tester le NAT depuis le routeur

```bash
# Ping depuis le routeur en spécifiant l'interface source
Router# ping 8.8.8.8 source 192.168.1.10

# Vérifier immédiatement la traduction
Router# show ip nat translations | include 192.168.1.10
```

### Astuce 3 : NAT statique avec extendable (cas avancé)

Si tu as besoin qu'une IP interne communique avec plusieurs destinations, utilise l'option `extendable` :

```bash
Router(config)# ip nat inside source static 192.168.1.10 203.0.113.50 extendable
```

> [!info] Usage de extendable Permet des traductions multiples avec la même paire inside/global, utile pour des configurations complexes avec du NAT sur plusieurs routeurs.

### Astuce 4 : Forcer la réinitialisation des translations

```bash
# Si une traduction semble bloquée
Router# clear ip nat translation *
Router# clear ip nat translation inside 192.168.1.10 203.0.113.50
```

---

**📌 Points clés à retenir :**

- Le NAT statique = **mapping 1:1 permanent** entre une IP privée et une IP publique
- Parfait pour les **serveurs accessibles depuis Internet**
- **Consomme** une IP publique par machine traduite
- Fonctionne **automatiquement dans les deux sens**
- Nécessite une **configuration manuelle** de chaque mapping
- Toujours configurer **ip nat inside/outside** sur les interfaces

---