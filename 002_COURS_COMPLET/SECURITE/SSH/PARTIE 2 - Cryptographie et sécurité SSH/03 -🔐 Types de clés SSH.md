

## 📑 Table des matières

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

SSH utilise la **cryptographie asymétrique** pour l'authentification, ce qui signifie qu'il existe deux types d'algorithmes de génération de clés disponibles. Chaque algorithme a ses propres caractéristiques en termes de sécurité, performance et compatibilité.

> [!info] Principe fondamental Une paire de clés SSH se compose de :
> 
> - **Clé publique** : partagée avec les serveurs (fichier `.pub`)
> - **Clé privée** : gardée secrète sur votre machine locale

---

## 🔑 Clés RSA

### Qu'est-ce que RSA ?

**RSA** (Rivest-Shamir-Adleman) est l'algorithme de cryptographie asymétrique le plus ancien et le plus largement utilisé pour SSH. Il repose sur la difficulté mathématique de factoriser de grands nombres premiers.

### Caractéristiques

- **Longueur de clé** : 1024, 2048, 3072, 4096 bits (et plus)
- **Sécurité** : Dépend directement de la longueur de la clé
- **Performance** : Plus lente que les algorithmes modernes
- **Compatibilité** : Excellente, supportée partout

### Génération d'une clé RSA

```bash
# Génération basique (2048 bits par défaut)
ssh-keygen -t rsa

# Génération avec 4096 bits (recommandé)
ssh-keygen -t rsa -b 4096 -C "mon-email@exemple.com"

# Options détaillées
ssh-keygen -t rsa \
  -b 4096 \                    # Longueur de 4096 bits
  -C "commentaire" \           # Commentaire pour identifier la clé
  -f ~/.ssh/id_rsa_projet      # Nom de fichier personnalisé
```

### Longueurs de clés recommandées

|Longueur|Sécurité|Usage|
|---|---|---|
|1024 bits|❌ Obsolète|Ne plus utiliser|
|2048 bits|⚠️ Minimum acceptable|Usage basique, temporaire|
|3072 bits|✅ Bonne|Usage standard|
|4096 bits|✅ Excellente|Usage professionnel recommandé|

> [!warning] Sécurité RSA Les clés RSA de 1024 bits sont considérées comme non sécurisées depuis 2010. Utilisez au minimum 2048 bits, idéalement 4096 bits.

### Avantages et inconvénients

**✅ Avantages :**

- Compatibilité universelle
- Bien testé et éprouvé depuis des décennies
- Support sur tous les systèmes (même anciens)

**❌ Inconvénients :**

- Plus lente que les algorithmes modernes
- Nécessite des clés plus longues pour une sécurité équivalente
- Génération de clé plus lente
- Signature et vérification plus lentes

> [!tip] Quand utiliser RSA ?
> 
> - Lorsque vous devez vous connecter à des systèmes anciens
> - Pour une compatibilité maximale
> - Si votre environnement n'accepte pas les algorithmes plus récents

---

## 🔑 Clés DSA

### Qu'est-ce que DSA ?

**DSA** (Digital Signature Algorithm) est un ancien algorithme standardisé par le gouvernement américain (FIPS 186). Il a été conçu spécifiquement pour les signatures numériques.

### Caractéristiques

- **Longueur de clé** : Fixée à 1024 bits par la spécification OpenSSH
- **Sécurité** : ❌ **Obsolète et non sécurisée**
- **Performance** : Variable
- **Compatibilité** : Désactivée par défaut depuis OpenSSH 7.0 (2015)

### Génération d'une clé DSA (déconseillé)

```bash
# DSA est désactivé par défaut dans les versions récentes
# Cette commande peut échouer ou nécessiter des options spéciales
ssh-keygen -t dsa
```

> [!warning] DSA est obsolète **Ne pas utiliser DSA pour de nouvelles clés !**
> 
> - Limité à 1024 bits (non sécurisé)
> - Désactivé par défaut depuis OpenSSH 7.0
> - Vulnérable si le générateur de nombres aléatoires est faible
> - Support supprimé dans OpenSSH 9.0+

### Pourquoi DSA est-il dangereux ?

1. **Longueur fixe de 1024 bits** : Trop court pour les standards modernes
2. **Faille cryptographique** : Si le même nombre aléatoire est utilisé deux fois lors de la signature, la clé privée peut être récupérée
3. **Génération aléatoire critique** : Nécessite un générateur de nombres aléatoires parfait

> [!info] Historique DSA était populaire dans les années 2000, mais a été complètement abandonné au profit d'algorithmes plus sûrs. Si vous avez encore des clés DSA, migrez immédiatement vers Ed25519 ou RSA 4096.

---

## 🔑 Clés ECDSA

### Qu'est-ce que ECDSA ?

**ECDSA** (Elliptic Curve Digital Signature Algorithm) est un algorithme basé sur les **courbes elliptiques**. Il offre une sécurité équivalente à RSA avec des clés beaucoup plus courtes.

### Caractéristiques

- **Longueur de clé** : 256, 384, 521 bits
- **Sécurité** : Bonne (mais controverses sur certaines courbes)
- **Performance** : Excellente (rapide)
- **Compatibilité** : Bonne sur les systèmes modernes

### Génération d'une clé ECDSA

```bash
# Génération avec la courbe 256 bits (par défaut)
ssh-keygen -t ecdsa

# Génération avec une courbe spécifique
ssh-keygen -t ecdsa -b 521 -C "mon-email@exemple.com"

# Options détaillées
ssh-keygen -t ecdsa \
  -b 521 \                     # Taille de la courbe (256, 384, ou 521)
  -C "commentaire" \
  -f ~/.ssh/id_ecdsa_projet
```

### Courbes disponibles

|Courbe|Bits|Équivalent RSA|Recommandation|
|---|---|---|---|
|nistp256|256|~3072 bits|⚠️ Acceptable|
|nistp384|384|~7680 bits|✅ Bien|
|nistp521|521|~15360 bits|✅ Excellent|

> [!info] Note sur les courbes NIST Les courbes utilisées par ECDSA sont des **courbes NIST** (National Institute of Standards and Technology). Leur nom complet est `nistp256`, `nistp384`, et `nistp521`.

### Avantages et inconvénients

**✅ Avantages :**

- Clés beaucoup plus courtes que RSA pour une sécurité équivalente
- Génération et signature rapides
- Bonne compatibilité moderne
- Performance excellente

**❌ Inconvénients :**

- Controverses autour des courbes NIST (soupçons de backdoor NSA)
- Moins transparent que Ed25519
- Complexité mathématique des courbes elliptiques

> [!warning] Controverses NIST Les courbes NIST ont été soupçonnées d'avoir été potentiellement affaiblies par la NSA. Bien qu'aucune preuve concrète n'existe, beaucoup préfèrent Ed25519 qui utilise une courbe plus transparente (Curve25519).

> [!tip] Quand utiliser ECDSA ?
> 
> - Si Ed25519 n'est pas disponible
> - Pour des systèmes modernes qui ne supportent pas encore Ed25519
> - Si vous faites confiance aux courbes NIST
> - Préférez la courbe 521 bits pour une sécurité maximale

---

## 🔑 Clés Ed25519

### Qu'est-ce que Ed25519 ?

**Ed25519** est un algorithme de signature basé sur les courbes elliptiques, utilisant la **courbe Curve25519**. C'est le **standard moderne recommandé** pour SSH.

### Caractéristiques

- **Longueur de clé** : Fixe à 256 bits
- **Sécurité** : ✅ Excellente (équivalent à RSA 3072 bits)
- **Performance** : ⚡ La plus rapide
- **Compatibilité** : Bonne (OpenSSH 6.5+, sorti en 2014)

### Génération d'une clé Ed25519

```bash
# Génération basique (recommandé pour la plupart des cas)
ssh-keygen -t ed25519

# Génération avec commentaire
ssh-keygen -t ed25519 -C "mon-email@exemple.com"

# Options détaillées
ssh-keygen -t ed25519 \
  -C "commentaire" \
  -f ~/.ssh/id_ed25519_projet \
  -a 100                       # Nombre de tours KDF (Key Derivation Function)
```

> [!info] Longueur de clé fixe Contrairement à RSA, Ed25519 n'a pas d'option `-b` pour la longueur de clé. La taille est fixe à 256 bits car l'algorithme est conçu spécifiquement pour cette taille.

### Avantages et inconvénients

**✅ Avantages :**

- 🚀 **Performance exceptionnelle** : la plus rapide de tous les algorithmes
- 🔒 **Sécurité maximale** : résistant aux attaques par canal auxiliaire
- 📦 **Clés compactes** : seulement 256 bits
- 🔍 **Transparence** : algorithme open source, sans backdoor possible
- ⚡ **Génération instantanée** : création de clés ultra-rapide
- 🛡️ **Signature rapide** : authentification quasi-instantanée

**❌ Inconvénients :**

- Incompatible avec les très vieux systèmes (pré-2014)
- Nécessite OpenSSH 6.5 ou supérieur

> [!tip] 🏆 Recommandation officielle **Ed25519 est le choix par défaut recommandé** pour toute nouvelle clé SSH. Utilisez-le sauf si vous devez absolument supporter des systèmes très anciens.

### Pourquoi Ed25519 est-il supérieur ?

1. **Conception moderne** : Créé pour éviter les pièges cryptographiques classiques
2. **Curve25519** : Courbe elliptique conçue par Daniel J. Bernstein, réputé pour sa sécurité
3. **Résistance aux timing attacks** : Protégé contre les attaques par analyse du temps d'exécution
4. **Pas de choix à faire** : Une seule taille de clé, optimale par conception
5. **Code simple** : Implémentation claire, facile à auditer

---

## 🔍 Empreintes de clés (Fingerprints)

### Qu'est-ce qu'une empreinte ?

Une **empreinte de clé SSH** (fingerprint) est un **hash cryptographique** de la clé publique. C'est une représentation courte et unique de la clé, utilisée pour vérifier son identité.

### Pourquoi les empreintes sont-elles importantes ?

> [!warning] Sécurité critique Les empreintes permettent de vérifier que vous vous connectez bien au bon serveur et d'éviter les attaques de type **Man-in-the-Middle (MITM)**.

Lors de votre première connexion à un serveur, SSH affiche l'empreinte du serveur :

```bash
The authenticity of host 'serveur.exemple.com (192.168.1.10)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no)?
```

### Formats d'empreintes

SSH peut afficher les empreintes dans différents formats de hash :

|Format|Exemple|Usage|
|---|---|---|
|**MD5**|`16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48`|Ancien format (lisible)|
|**SHA256**|`SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8`|Moderne (par défaut)|

> [!info] Format par défaut Depuis OpenSSH 6.8 (2015), le format par défaut est **SHA256** car il est plus sécurisé que MD5.

### Afficher l'empreinte d'une clé publique

```bash
# Afficher l'empreinte SHA256 (défaut)
ssh-keygen -lf ~/.ssh/id_ed25519.pub

# Afficher l'empreinte MD5 (ancien format)
ssh-keygen -lf ~/.ssh/id_ed25519.pub -E md5

# Afficher l'empreinte SHA256 explicitement
ssh-keygen -lf ~/.ssh/id_ed25519.pub -E sha256

# Format visuel ASCII art (pour reconnaissance visuelle)
ssh-keygen -lvf ~/.ssh/id_ed25519.pub
```

**Exemple de sortie :**

```bash
$ ssh-keygen -lf ~/.ssh/id_ed25519.pub
256 SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8 user@hostname (ED25519)
```

Décomposition :

- `256` : Longueur de la clé en bits
- `SHA256:...` : Empreinte au format SHA256
- `user@hostname` : Commentaire de la clé
- `(ED25519)` : Type d'algorithme

### Afficher l'empreinte d'une clé serveur

```bash
# Depuis les clés d'hôte du serveur
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub

# Depuis le fichier known_hosts (local)
ssh-keygen -lf ~/.ssh/known_hosts

# Scanner un serveur distant (sans se connecter)
ssh-keyscan serveur.exemple.com | ssh-keygen -lf -
```

### Format ASCII Art (RandomArt)

SSH peut générer une représentation visuelle de l'empreinte :

```bash
ssh-keygen -lvf ~/.ssh/id_ed25519.pub
```

**Exemple de sortie :**

```
256 SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8 user@host (ED25519)
+--[ED25519 256]--+
|        .        |
|       + .       |
|      . B .      |
|     o * +       |
|    X * S .      |
|   + X o o E     |
|    + = o . .    |
|     . o         |
|                 |
+----[SHA256]-----+
```

> [!tip] Reconnaissance visuelle L'ASCII art permet une vérification rapide et intuitive : il est plus facile de mémoriser un motif visuel qu'une longue chaîne de caractères.

### Vérifier une empreinte lors de la connexion

```bash
# Se connecter en affichant l'empreinte serveur
ssh -o VisualHostKey=yes user@serveur.exemple.com

# Vérifier l'empreinte sans se connecter
ssh-keyscan serveur.exemple.com > temp_key
ssh-keygen -lf temp_key
rm temp_key
```

### Gestion du fichier known_hosts

Le fichier `~/.ssh/known_hosts` stocke les empreintes des serveurs connus :

```bash
# Voir les empreintes de tous les serveurs connus
ssh-keygen -lf ~/.ssh/known_hosts

# Supprimer l'entrée d'un serveur spécifique
ssh-keygen -R serveur.exemple.com

# Rechercher un serveur dans known_hosts
ssh-keygen -F serveur.exemple.com
```

> [!warning] Changement d'empreinte Si l'empreinte d'un serveur change, SSH vous avertira :
> 
> ```
> WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
> ```
> 
> Cela peut indiquer :
> 
> - ✅ Le serveur a été réinstallé (légitime)
> - ❌ Une attaque Man-in-the-Middle (danger !)
> 
> Vérifiez toujours avec l'administrateur du serveur avant de continuer.

### Bonnes pratiques avec les empreintes

1. **Vérifiez toujours lors de la première connexion** : Contactez l'administrateur pour confirmer l'empreinte
2. **Utilisez un canal sécurisé** : Vérifiez l'empreinte par téléphone, Signal, ou en personne
3. **Documentez les empreintes** : Gardez une trace des empreintes de vos serveurs importants
4. **Ne désactivez jamais la vérification** : N'utilisez jamais `StrictHostKeyChecking no` en production
5. **ASCII Art** : Activez l'affichage visuel pour une mémorisation plus facile

---

## 📊 Comparaison des types de clés

### Tableau récapitulatif

|Algorithme|Longueur typique|Sécurité|Performance|Compatibilité|Recommandation|
|---|---|---|---|---|---|
|**Ed25519**|256 bits|✅ Excellente|⚡ Très rapide|✅ Moderne (2014+)|🏆 **Recommandé**|
|**RSA**|4096 bits|✅ Bonne|🐌 Lente|✅ Universelle|⚠️ Fallback uniquement|
|**ECDSA**|521 bits|✅ Bonne|⚡ Rapide|✅ Moderne|⚠️ Si Ed25519 indisponible|
|**DSA**|1024 bits|❌ Obsolète|🐌 Moyenne|❌ Désactivée|❌ **Ne pas utiliser**|

### Équivalence de sécurité

Pour comprendre la force de chaque algorithme :

|Algorithme|Taille|Équivalent de sécurité|
|---|---|---|
|Ed25519|256 bits|~3072 bits RSA|
|ECDSA nistp256|256 bits|~3072 bits RSA|
|ECDSA nistp384|384 bits|~7680 bits RSA|
|ECDSA nistp521|521 bits|~15360 bits RSA|
|RSA|2048 bits|2048 bits RSA (minimum)|
|RSA|4096 bits|4096 bits RSA|

> [!info] Courbes elliptiques vs RSA Les algorithmes basés sur les courbes elliptiques (Ed25519, ECDSA) offrent une sécurité équivalente avec des clés beaucoup plus courtes, ce qui les rend plus rapides.

### Vitesse de génération et signature

Ordre de rapidité (du plus rapide au plus lent) :

1. 🥇 **Ed25519** : Génération et signature quasi-instantanées
2. 🥈 **ECDSA** : Très rapide
3. 🥉 **RSA 2048** : Moyen
4. 🐌 **RSA 4096** : Lent (peut prendre plusieurs secondes)

### Taille des clés générées

Comparaison de la taille des fichiers :

```bash
# Ed25519
-rw------- 1 user user  411 Dec 15 10:00 id_ed25519      # Clé privée
-rw-r--r-- 1 user user   99 Dec 15 10:00 id_ed25519.pub  # Clé publique

# RSA 4096
-rw------- 1 user user 3243 Dec 15 10:00 id_rsa          # Clé privée
-rw-r--r-- 1 user user  738 Dec 15 10:00 id_rsa.pub      # Clé publique

# ECDSA 521
-rw------- 1 user user  736 Dec 15 10:00 id_ecdsa        # Clé privée
-rw-r--r-- 1 user user  281 Dec 15 10:00 id_ecdsa.pub    # Clé publique
```

Ed25519 génère les clés les plus compactes !

---

## ⚠️ Pièges courants et bonnes pratiques

### 🎯 Choix de l'algorithme

> [!tip] Arbre de décision
> 
> **Nouvelle clé en 2024+ ?**
> 
> - ✅ **Ed25519** → C'est le meilleur choix par défaut
> 
> **Serveur trop ancien (pré-2014) ?**
> 
> - ⚠️ **RSA 4096 bits** → Pour la compatibilité
> 
> **Ed25519 refusé mais serveur moderne ?**
> 
> - ⚠️ **ECDSA 521 bits** → Alternative acceptable
> 
> **Absolument jamais DSA !**
> 
> - ❌ Migrez immédiatement vers Ed25519

### 🔐 Sécurité des clés

```bash
# ✅ BONNE PRATIQUE : Créer une clé Ed25519 protégée par passphrase
ssh-keygen -t ed25519 -C "mon-email@exemple.com"

# ✅ BONNE PRATIQUE : Permissions strictes sur les clés privées
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# ❌ MAUVAISE PRATIQUE : Clé sans passphrase
ssh-keygen -t ed25519 -N ""  # NE JAMAIS FAIRE EN PRODUCTION

# ❌ MAUVAISE PRATIQUE : Permissions trop ouvertes
chmod 777 ~/.ssh/id_ed25519  # DANGEREUX !
```

> [!warning] Passphrase obligatoire Toujours protéger vos clés privées avec une **passphrase forte**. Si quelqu'un vole votre clé privée, la passphrase est votre dernière ligne de défense.

### 📝 Nommage et organisation

```bash
# ✅ BONNE PRATIQUE : Nommer les clés selon leur usage
~/.ssh/
├── id_ed25519              # Clé personnelle générale
├── id_ed25519.pub
├── id_ed25519_travail      # Clé professionnelle
├── id_ed25519_travail.pub
├── id_ed25519_github       # Clé spécifique GitHub
├── id_ed25519_github.pub
└── config                  # Configuration SSH

# ❌ MAUVAISE PRATIQUE : Tout mélanger
~/.ssh/
├── id_rsa
├── id_rsa.pub
├── key
├── mykey.pub
└── backup_key
```

### 🔄 Migration d'anciennes clés

Si vous avez encore des clés RSA 2048 bits ou DSA :

```bash
# 1. Générer une nouvelle clé Ed25519
ssh-keygen -t ed25519 -C "migration-2024"

# 2. Copier la nouvelle clé sur tous vos serveurs
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@serveur

# 3. Vérifier que la nouvelle clé fonctionne
ssh -i ~/.ssh/id_ed25519 user@serveur

# 4. Supprimer l'ancienne clé du serveur
# (depuis le serveur)
nano ~/.ssh/authorized_keys  # Retirer l'ancienne ligne

# 5. Archiver l'ancienne clé localement
mv ~/.ssh/id_rsa ~/.ssh/OLD_id_rsa_$(date +%Y%m%d)
mv ~/.ssh/id_rsa.pub ~/.ssh/OLD_id_rsa_$(date +%Y%m%d).pub
```

### 🎭 Plusieurs clés pour différents services

```bash
# Configuration dans ~/.ssh/config
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github

Host work-server
    HostName serveur.entreprise.com
    User john
    IdentityFile ~/.ssh/id_ed25519_travail

Host personal-vps
    HostName monvps.com
    User root
    IdentityFile ~/.ssh/id_ed25519
```

### 🚨 Erreurs fréquentes à éviter

> [!warning] Pièges classiques
> 
> **1. Partager sa clé privée**
> 
> - ❌ Ne jamais envoyer `id_ed25519` par email/Slack
> - ✅ Seule la clé publique (`.pub`) peut être partagée
> 
> **2. Réutiliser la même clé partout**
> 
> - ❌ Une seule clé pour tous les services
> - ✅ Clés différentes par contexte (perso, pro, services)
> 
> **3. Clés sans passphrase**
> 
> - ❌ Pratique mais dangereux
> - ✅ Toujours utiliser une passphrase + ssh-agent
> 
> **4. Ignorer les avertissements de changement d'empreinte**
> 
> - ❌ Accepter aveuglément avec `StrictHostKeyChecking no`
> - ✅ Toujours vérifier pourquoi l'empreinte a changé
> 
> **5. Utiliser DSA ou RSA 1024**
> 
> - ❌ Obsolète et non sécurisé
> - ✅ Ed25519 ou RSA 4096 minimum

### 🔍 Vérification de vos clés actuelles

```bash
# Lister toutes vos clés SSH
ls -la ~/.ssh/

# Afficher le type et la longueur de chaque clé publique
for key in ~/.ssh/*.pub; do
    echo "=== $key ==="
    ssh-keygen -lf "$key"
done

# Vérifier les permissions
ls -la ~/.ssh/id_*
```

**Sortie attendue :**

```bash
# ✅ CORRECT
-rw------- 1 user user  411 Dec 15 10:00 id_ed25519      # 600
-rw-r--r-- 1 user user   99 Dec 15 10:00 id_ed25519.pub  # 644

# ❌ PROBLÈME DE SÉCURITÉ
-rw-rw-rw- 1 user user  411 Dec 15 10:00 id_ed25519      # 666 - TROP OUVERT !
```

### 💡 Astuces avancées

```bash
# Forcer l'utilisation d'un algorithme spécifique lors de la connexion
ssh -o PubkeyAcceptedKeyTypes=ssh-ed25519 user@serveur

# Tester quelle clé est utilisée pour l'authentification
ssh -vv user@serveur 2>&1 | grep "Offering public key"

# Convertir une clé publique dans différents formats
ssh-keygen -e -f ~/.ssh/id_ed25519.pub        # Format RFC4716
ssh-keygen -i -f clé.pub                      # Importer depuis RFC4716

# Changer la passphrase d'une clé existante (sans recréer)
ssh-keygen -p -f ~/.ssh/id_ed25519

# Supprimer une passphrase (déconseillé)
ssh-keygen -p -f ~/.ssh/id_ed25519 -N ""
```

### 📋 Checklist de sécurité

- [ ] Toutes mes clés privées ont des permissions 600
- [ ] Toutes mes clés privées sont protégées par passphrase
- [ ] Je n'utilise plus de clés DSA
- [ ] Mes clés RSA font au minimum 4096 bits
- [ ] J'utilise Ed25519 par défaut pour les nouvelles clés
- [ ] J'ai des clés séparées pour différents contextes
- [ ] Je vérifie les empreintes lors des premières connexions
- [ ] Je sauvegarde mes clés privées dans un endroit sécurisé (coffre-fort chiffré)
- [ ] Je n'ai jamais envoyé de clé privée par email ou chat

---

> [!tip] 🎓 Points clés à retenir
> 
> 1. **Ed25519** est le meilleur choix pour 99% des cas d'usage modernes
> 2. **RSA 4096** est le fallback universel pour la compatibilité
> 3. **DSA** est obsolète et dangereux - ne jamais l'utiliser
> 4. **ECDSA** est acceptable mais moins transparent qu'Ed25519