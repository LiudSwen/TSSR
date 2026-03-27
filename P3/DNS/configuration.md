# Configuration DNS sur un serveur AD DS (zones directe et inverse)

## Sommaire

1. [Vue d’ensemble](#1-vue-densemble)
2. [Zone de recherche directe (Forward Lookup Zone)](#2-zone-de-recherche-directe-forward-lookup-zone)
3. [Zone de recherche inversée (Reverse Lookup Zone)](#3-zone-de-recherche-inversee-reverse-lookup-zone)
4. [Paramètres de sécurité et mises à jour dynamiques](#4-parametres-de-securite-et-mises-a-jour-dynamiques)
5. [Vérifications et résultats attendus](#5-verifications-et-resultats-attendus)
6. [Conclusion](#6-conclusion)

---

## 1. Rôle DNS dans une infrastructure Active Directory

Dans un environnement Active Directory, le DNS est un **composant critique** :
- Résolution de noms des contrôleurs de domaine
- Localisation des services AD (LDAP, Kerberos, GC)
- Enregistrement dynamique des machines du domaine

Lorsque le rôle DNS est installé **en même temps que la promotion AD DS**, certaines configurations sont créées automatiquement.

---

## 3. Zone de recherche directe (Forward Lookup Zone)

### Principe
La zone de recherche directe permet de résoudre :
- **Nom → Adresse IP** (enregistrements A et AAAA)

Dans notre cas, la zone `**billu.lan**` est créée **automatiquement**.

![Zone DNS directe créée automatiquement](Ressources/dns-forward-zone-existante.png)


### Pourquoi aucune action manuelle n’est nécessaire
La zone Forward Lookup est générée lors des étapes suivantes :
1. Installation du rôle **Active Directory Domain Services**
2. Promotion du serveur en **contrôleur de domaine**
3. Activation du rôle **DNS** pendant la promotion

Cette zone est :
- Intégrée à Active Directory
- Répliquée entre contrôleurs de domaine
- Configurée pour les mises à jour dynamiques sécurisées

**Aucune création manuelle n’est effectuée** pour la zone Forward Lookup.

---
## 4. Zone de recherche inversée (Reverse Lookup Zone)

### Principe
La zone de recherche inversée permet de résoudre :
- **Adresse IP → Nom** (enregistrements PTR)

Contrairement à la zone directe, **elle n’est pas créée automatiquement** et doit être configurée manuellement.

---
### Création de la zone Reverse Lookup
#### Accès à la console DNS
- Ouvrir **DNS Manager**
- Déployer le serveur DNS
- Clic droit sur **Reverse Lookup Zones**
- **New Zone**

![Création d’une nouvelle zone DNS inverse](Ressources/dns-reverse-zone-new.png)

---

### Type de zone
- Sélectionner **Primary Zone**

![Sélection du type de zone DNS](Ressources/dns-reverse-zone-type.png)

Cette option permet une intégration avec Active Directory.

---

### Intégration Active Directory

Sélectionner :
- **To all DNS servers running on domain controllers in this domain: billu.lan**

![Réplication de la zone DNS via Active Directory](Ressources/dns-reverse-zone-replication.png)

Cette configuration assure :
- Réplication automatique
- Haute disponibilité
- Cohérence DNS entre contrôleurs de domaine

---
### Type de zone inverse
- Sélectionner **IPv4 Reverse Lookup Zone**

![Sélection du type IPv4 pour la zone inverse](Ressources/dns-reverse-zone-ipv4.png)

---
### Configuration du Network ID

Renseigner :
- **Network ID** : `172.16.12`

![Configuration du Network ID de la zone inverse](Ressources/dns-reverse-zone-network-id.png)

Cette valeur correspond au réseau utilisé par l’infrastructure.

---
### Mises à jour dynamiques

Choisir :
- **Allow only secure dynamic updates**

![Activation des mises à jour dynamiques sécurisées](Ressources/dns-reverse-zone-secure-updates.png)

Cette configuration garantit que :
- Seuls les objets **authentifiés du domaine** peuvent créer ou modifier des enregistrements
- Les enregistrements PTR sont protégés contre les modifications non autorisées

---
## 5. Résultat attendu et validation

### Zone créée
La zone inverse suivante est générée automatiquement :
`12.16.172.in-addr.arpa`

### Fonctionnement attendu
Cette zone permet :

- L’enregistrement automatique des **enregistrements PTR**
- La résolution inverse pour :
    - serveurs
    - postes clients du domaine

Elle complète la zone Forward Lookup et assure une résolution DNS cohérente dans l’ensemble de l’infrastructure.