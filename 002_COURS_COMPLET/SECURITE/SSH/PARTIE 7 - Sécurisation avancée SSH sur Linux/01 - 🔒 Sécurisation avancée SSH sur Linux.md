

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

## 🎯 Introduction

La sécurisation avancée de SSH constitue une étape cruciale dans le durcissement d'un serveur Linux. Par défaut, SSH est configuré pour maximiser la compatibilité plutôt que la sécurité. Cette partie couvre les techniques de durcissement de la configuration serveur qui permettent de réduire significativement la surface d'attaque.

> [!info] Fichier de configuration Toutes les modifications s'effectuent dans le fichier `/etc/ssh/sshd_config`. Après chaque modification, il est impératif de :
> 
> 1. Vérifier la syntaxe : `sudo sshd -t`
> 2. Redémarrer le service : `sudo systemctl restart sshd`

> [!warning] Risque de verrouillage **ATTENTION** : Avant de modifier la configuration SSH, assurez-vous d'avoir :
> 
> - Une session SSH active en parallèle pour tester
> - Un accès physique ou console au serveur en cas de problème
> - Une sauvegarde de la configuration originale : `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup`

---

## 🛡️ Durcissement de la configuration serveur

### 1. Désactivation de l'authentification par mot de passe

#### 📖 Concept et importance

L'authentification par mot de passe présente plusieurs faiblesses :

- Vulnérable aux attaques par force brute
- Sensible aux attaques par dictionnaire
- Peut être compromise par du phishing ou de l'ingénierie sociale
- Les mots de passe faibles sont fréquents

L'authentification par clé SSH est beaucoup plus robuste car elle repose sur une cryptographie asymétrique avec des clés de plusieurs milliers de bits.

#### ⚙️ Configuration

Éditez `/etc/ssh/sshd_config` :

```bash
# Désactiver l'authentification par mot de passe
PasswordAuthentication no

# Désactiver l'authentification challenge-response (qui peut contourner PasswordAuthentication)
ChallengeResponseAuthentication no

# Désactiver l'authentification basée sur le clavier (méthode alternative)
KbdInteractiveAuthentication no

# S'assurer que l'authentification par clé publique est activée
PubkeyAuthentication yes
```

> [!warning] Prérequis obligatoire **Avant de désactiver l'authentification par mot de passe**, assurez-vous que :
> 
> 1. Votre clé publique est bien présente dans `~/.ssh/authorized_keys`
> 2. Vous pouvez vous connecter avec votre clé : `ssh -i ~/.ssh/ma_cle user@serveur`
> 3. Les permissions sont correctes (voir ci-dessous)

#### 🔍 Vérification des permissions

Les permissions SSH sont strictes et doivent être respectées :

```bash
# Répertoire .ssh
chmod 700 ~/.ssh

# Fichier authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Clé privée (côté client)
chmod 600 ~/.ssh/id_rsa  # ou id_ed25519, etc.

# Vérifier le propriétaire
ls -la ~/.ssh/
```

> [!tip] Astuce de test Pour tester la désactivation sans risque, utilisez d'abord `Match` pour appliquer la règle à un seul utilisateur de test :
> 
> ```bash
> Match User utilisateur_test
>     PasswordAuthentication no
> ```

#### 🎯 Cas d'usage

|Scénario|Recommandation|
|---|---|
|Serveur de production|**Désactivation obligatoire**|
|Serveur de développement personnel|Recommandé|
|Serveur avec multiples administrateurs|Désactivation + distribution des clés|
|Environnement d'apprentissage|Optionnel (mais bonne pratique)|

---

### 2. Désactivation de l'authentification root

#### 📖 Concept et importance

Permettre la connexion directe en tant que root présente plusieurs risques :

- **Cible privilégiée** : Les attaquants ciblent toujours le compte root
- **Absence de traçabilité** : Impossible de savoir quel administrateur a effectué une action
- **Pas de barrière supplémentaire** : Pas de séparation entre connexion et élévation de privilèges
- **Surface d'attaque maximale** : Accès direct aux privilèges absolus

La bonne pratique consiste à :

1. Se connecter avec un compte utilisateur standard
2. Utiliser `sudo` pour les commandes nécessitant des privilèges
3. Bénéficier ainsi d'un audit trail complet

#### ⚙️ Configuration

```bash
# Dans /etc/ssh/sshd_config
PermitRootLogin no
```

> [!info] Options alternatives La directive `PermitRootLogin` accepte plusieurs valeurs :
> 
> - `no` : Interdiction totale (recommandé)
> - `yes` : Autorisation complète (dangereux)
> - `prohibit-password` : Root peut se connecter uniquement par clé (compromis)
> - `forced-commands-only` : Root peut exécuter uniquement des commandes spécifiques

#### 🔧 Préparation nécessaire

Avant de désactiver root, configurez `sudo` :

```bash
# 1. Créer un utilisateur administrateur si nécessaire
sudo useradd -m -s /bin/bash admin_user
sudo passwd admin_user

# 2. Ajouter l'utilisateur au groupe sudo (Debian/Ubuntu) ou wheel (RHEL/CentOS)
sudo usermod -aG sudo admin_user    # Debian/Ubuntu
sudo usermod -aG wheel admin_user   # RHEL/CentOS

# 3. Tester la capacité sudo AVANT de désactiver root
su - admin_user
sudo whoami  # Doit retourner "root"
```

> [!warning] Piège fréquent Si vous utilisez des scripts d'automatisation qui se connectent en root via SSH, vous devrez les modifier pour :
> 
> - Utiliser un compte de service avec clé SSH
> - Utiliser `sudo` pour les commandes privilégiées
> - Configurer `sudoers` pour autoriser ces commandes sans mot de passe si nécessaire

#### 💡 Configuration sudo avancée

Pour permettre à un utilisateur d'exécuter certaines commandes sans mot de passe :

```bash
# Éditer avec visudo (JAMAIS directement)
sudo visudo

# Exemple : permettre à admin_user de redémarrer des services sans mot de passe
admin_user ALL=(ALL) NOPASSWD: /bin/systemctl restart *, /bin/systemctl stop *, /bin/systemctl start *
```

> [!tip] Audit et traçabilité Avec cette configuration, toutes les actions privilégiées sont tracées :
> 
> ```bash
> # Voir qui a utilisé sudo
> sudo cat /var/log/auth.log | grep sudo
> 
> # Historique sudo d'un utilisateur
> sudo cat /var/log/auth.log | grep "admin_user.*sudo"
> ```

---

### 3. Restriction des utilisateurs autorisés

#### 📖 Concept et importance

Sur un système avec de nombreux comptes utilisateurs (équipes, comptes de service, etc.), tous n'ont pas besoin d'un accès SSH. Limiter explicitement les utilisateurs autorisés réduit la surface d'attaque et simplifie la gestion.

Les directives de restriction d'utilisateurs permettent d'implémenter un contrôle d'accès granulaire au niveau SSH, indépendamment des permissions système.

#### ⚙️ Directives disponibles

##### AllowUsers

Spécifie une liste blanche d'utilisateurs autorisés. Seuls ces utilisateurs peuvent se connecter.

```bash
# Dans /etc/ssh/sshd_config

# Syntaxe basique : liste d'utilisateurs séparés par des espaces
AllowUsers alice bob charlie

# Syntaxe avec restriction d'hôte : utilisateur@hôte
AllowUsers alice@192.168.1.100 bob@10.0.0.* charlie@*.example.com

# Combinaison
AllowUsers admin@10.0.0.5 dev@192.168.1.* monitoring
```

##### DenyUsers

Spécifie une liste noire d'utilisateurs interdits. Tous les utilisateurs peuvent se connecter sauf ceux listés.

```bash
# Dans /etc/ssh/sshd_config

# Interdire des comptes spécifiques
DenyUsers guest test temporaire

# Interdire depuis certaines sources
DenyUsers *@suspicious-network.com

# Interdire un utilisateur de partout
DenyUsers old_employee
```

> [!warning] Ordre de priorité L'ordre de traitement est crucial :
> 
> 1. `DenyUsers` est évalué en premier
> 2. `AllowUsers` est évalué ensuite
> 
> Si un utilisateur est dans les deux listes, **le DENY l'emporte** (il sera bloqué).

#### 🎯 Stratégies de configuration

|Approche|Quand l'utiliser|Configuration|
|---|---|---|
|**Liste blanche** (AllowUsers)|Petit nombre d'administrateurs connus|`AllowUsers admin1 admin2 admin3`|
|**Liste noire** (DenyUsers)|Grand nombre d'utilisateurs légitimes, quelques interdictions|`DenyUsers guest test`|
|**Restriction réseau**|Limiter l'accès par provenance|`AllowUsers admin@10.0.0.*`|
|**Combinaison**|Contrôle fin|Les deux directives ensemble|

#### 💡 Exemples pratiques

##### Cas 1 : Serveur d'administration dédié

```bash
# Seuls les administrateurs système peuvent se connecter
AllowUsers sysadmin1 sysadmin2 sysadmin3

# Avec restriction réseau (réseau admin uniquement)
AllowUsers sysadmin1@10.0.0.* sysadmin2@10.0.0.* sysadmin3@10.0.0.*
```

##### Cas 2 : Serveur de développement

```bash
# Tous les développeurs peuvent se connecter, sauf les comptes temporaires
DenyUsers guest temp test demo

# Bloquer un ancien employé spécifiquement
DenyUsers ancien_dev
```

##### Cas 3 : Serveur de production avec zones

```bash
# Les admins peuvent venir de partout
AllowUsers sysadmin@*

# Les développeurs uniquement depuis le réseau interne
AllowUsers dev1@192.168.1.* dev2@192.168.1.*

# Le compte de monitoring depuis le serveur de monitoring uniquement
AllowUsers monitoring@10.0.5.100
```

##### Cas 4 : Combinaison défense en profondeur

```bash
# Bloquer explicitement les comptes système dangereux
DenyUsers bin daemon sys sync games man lp mail news uucp proxy www-data backup nobody

# Puis autoriser uniquement les administrateurs légitimes
AllowUsers admin1 admin2 operations@10.0.0.*
```

> [!tip] Patterns avec wildcards Les patterns acceptés :
> 
> - `*` : N'importe quelle chaîne
> - `?` : N'importe quel caractère unique
> - `user@192.168.1.*` : Utilisateur depuis un sous-réseau
> - `*@10.0.0.5` : N'importe quel utilisateur depuis une IP spécifique
> - `admin@*.internal.corp` : Utilisateur depuis un domaine

#### 🔍 Vérification et test

```bash
# Tester la configuration avant de redémarrer
sudo sshd -t

# Voir les utilisateurs système actuels
cat /etc/passwd | cut -d: -f1

# Tester une connexion avec un utilisateur spécifique
ssh utilisateur@serveur

# Vérifier les logs en cas de refus
sudo tail -f /var/log/auth.log | grep sshd
# Vous verrez : "User username from host not allowed because listed in DenyUsers"
```

> [!warning] Pièges courants
> 
> 1. **Oublier son propre compte** : N'oubliez pas d'inclure votre compte actuel dans AllowUsers
> 2. **Conflits entre Allow et Deny** : Si vous utilisez les deux, soyez très explicite
> 3. **Wildcards trop larges** : `AllowUsers *@192.168.*` peut être trop permissif
> 4. **Comptes de service** : N'oubliez pas les comptes utilisés par les outils d'automatisation/monitoring

---

### 4. Limitation des groupes

#### 📖 Concept et importance

La limitation par groupe offre une gestion plus structurée et évolutive que la limitation par utilisateur. Au lieu de maintenir une longue liste d'utilisateurs individuels, vous gérez l'appartenance aux groupes.

Avantages :

- **Scalabilité** : Ajouter/retirer des utilisateurs ne nécessite pas de modifier `sshd_config`
- **Organisation** : Reflète la structure organisationnelle (équipe dev, équipe ops, etc.)
- **Flexibilité** : Un utilisateur peut appartenir à plusieurs groupes pour des besoins différents
- **Cohérence** : Un groupe peut contrôler plusieurs aspects (SSH, sudo, accès fichiers, etc.)

#### ⚙️ Directives disponibles

##### AllowGroups

Seuls les membres des groupes listés peuvent se connecter via SSH.

```bash
# Dans /etc/ssh/sshd_config

# Autoriser un seul groupe
AllowGroups sshusers

# Autoriser plusieurs groupes
AllowGroups admins developers operations

# Avec restriction réseau (moins courant pour les groupes)
AllowGroups admins@10.0.0.* developers@192.168.1.*
```

##### DenyGroups

Interdit la connexion SSH aux membres des groupes listés.

```bash
# Dans /etc/ssh/sshd_config

# Bloquer un groupe
DenyGroups restricted

# Bloquer plusieurs groupes
DenyGroups guests temporary locked
```

> [!info] Ordre de priorité Comme pour les utilisateurs :
> 
> 1. `DenyGroups` est évalué en premier
> 2. `AllowGroups` est évalué ensuite
> 3. Si conflit, le DENY l'emporte

#### 🔧 Gestion des groupes Linux

##### Créer un groupe SSH dédié

```bash
# Créer le groupe
sudo groupadd sshusers

# Ajouter des utilisateurs au groupe
sudo usermod -aG sshusers alice
sudo usermod -aG sshusers bob
sudo usermod -aG sshusers charlie

# Vérifier l'appartenance
groups alice
# Sortie : alice : alice sshusers

# Voir tous les membres d'un groupe
getent group sshusers
# Sortie : sshusers:x:1001:alice,bob,charlie
```

##### Retirer un utilisateur d'un groupe

```bash
# Retirer l'utilisateur du groupe
sudo gpasswd -d alice sshusers

# Alternative : redéfinir tous les groupes de l'utilisateur
sudo usermod -G groupe1,groupe2 alice  # Attention : remplace tous les groupes secondaires
```

##### Vérifications utiles

```bash
# Lister tous les groupes du système
cat /etc/group

# Voir les groupes d'un utilisateur
id alice
# Sortie : uid=1001(alice) gid=1001(alice) groups=1001(alice),1002(sshusers)

# Voir tous les membres de tous les groupes
for group in $(cut -d: -f1 /etc/group); do
    echo "=== $group ==="
    getent group $group
done
```

#### 💡 Stratégies de configuration

##### Stratégie 1 : Groupe SSH unique (Simple)

```bash
# Dans /etc/ssh/sshd_config
AllowGroups sshusers

# Gestion
# Tous les utilisateurs SSH sont ajoutés à ce groupe unique
sudo usermod -aG sshusers nouvel_admin
```

**Avantages** : Simple, facile à comprendre **Inconvénients** : Pas de granularité, tous ont les mêmes droits d'accès

##### Stratégie 2 : Groupes par rôle (Recommandé)

```bash
# Dans /etc/ssh/sshd_config
AllowGroups ssh-admins ssh-developers ssh-monitoring

# Création des groupes
sudo groupadd ssh-admins
sudo groupadd ssh-developers
sudo groupadd ssh-monitoring

# Attribution
sudo usermod -aG ssh-admins alice
sudo usermod -aG ssh-developers bob
sudo usermod -aG ssh-monitoring monitoring-user
```

**Avantages** : Structure claire, évolutif, peut s'intégrer avec d'autres politiques **Inconvénients** : Nécessite une organisation plus rigoureuse

##### Stratégie 3 : Groupe SSH + configuration Match (Avancé)

```bash
# Dans /etc/ssh/sshd_config

# Autoriser le groupe global
AllowGroups sshusers

# Puis affiner par sous-groupe avec Match
Match Group ssh-admins
    AllowTcpForwarding yes
    PermitTunnel yes

Match Group ssh-developers
    AllowTcpForwarding yes
    PermitTunnel no
    
Match Group ssh-readonly
    ForceCommand /usr/bin/restricted-shell
    AllowTcpForwarding no
```

> [!tip] Intégration avec sudo Les groupes SSH peuvent être alignés avec les groupes sudo :
> 
> ```bash
> # Groupe pour SSH et sudo
> sudo groupadd admins
> sudo usermod -aG admins alice
> 
> # Dans /etc/ssh/sshd_config
> AllowGroups admins
> 
> # Dans /etc/sudoers (avec visudo)
> %admins ALL=(ALL:ALL) ALL
> ```

#### 🎯 Exemples pratiques complets

##### Exemple 1 : Organisation d'entreprise

```bash
# Structure des groupes
sudo groupadd ssh-c-level        # Direction
sudo groupadd ssh-sysadmins     # Administrateurs système
sudo groupadd ssh-devops        # DevOps
sudo groupadd ssh-developers    # Développeurs
sudo groupadd ssh-support       # Support technique
sudo groupadd ssh-contractors   # Prestataires externes

# Configuration SSH
AllowGroups ssh-c-level ssh-sysadmins ssh-devops ssh-developers ssh-support ssh-contractors

# Match pour restrictions spécifiques
Match Group ssh-contractors
    ForceCommand /usr/local/bin/contractor-shell
    PermitTTY yes
    PermitTunnel no
    AllowTcpForwarding no
```

##### Exemple 2 : Environnement éducatif

```bash
# Groupes
sudo groupadd ssh-teachers
sudo groupadd ssh-students
sudo groupadd ssh-ta  # Teaching assistants

# Configuration
AllowGroups ssh-teachers ssh-ta

# Les étudiants ne peuvent pas se connecter directement
DenyGroups ssh-students

# Mais les TA ont des restrictions
Match Group ssh-ta
    ForceCommand /usr/local/bin/grading-tools
```

##### Exemple 3 : Défense en profondeur

```bash
# Bloquer les groupes système dangereux
DenyGroups nogroup nobody www-data

# N'autoriser que les groupes SSH explicites
AllowGroups ssh-access

# Tout utilisateur devant accéder au serveur doit être dans ssh-access
# Puis utiliser d'autres groupes pour des permissions supplémentaires
```

#### 🔍 Débogage et vérification

```bash
# Vérifier la configuration
sudo sshd -t

# Voir pourquoi un utilisateur ne peut pas se connecter
sudo tail -f /var/log/auth.log

# Exemples de messages d'erreur :
# "User bob from 192.168.1.10 not allowed because none of user's groups are listed in AllowGroups"
# "User alice from 192.168.1.10 not allowed because user's group is listed in DenyGroups"

# Tester l'appartenance aux groupes
id -Gn utilisateur  # Montre tous les noms de groupes

# Lister les utilisateurs d'un groupe spécifique
getent group ssh-admins
```

> [!warning] Pièges à éviter
> 
> 1. **Groupe primaire vs groupes secondaires** : SSH vérifie TOUS les groupes (primaire + secondaires)
> 2. **Changements de groupe** : L'utilisateur doit se déconnecter/reconnecter pour que les changements de groupe prennent effet
> 3. **Conflits Allow/Deny** : Soyez explicite et testez soigneusement
> 4. **Oubli du groupe principal** : N'oubliez pas votre propre groupe avant de redémarrer sshd
> 5. **Groupes système** : Faites attention à ne pas bloquer des groupes nécessaires au fonctionnement

---

### 5. Changement du port SSH

#### 📖 Concept et importance

Par défaut, SSH écoute sur le port 22. Ce choix standard présente un inconvénient : **tous les scanners automatisés et bots ciblent prioritairement ce port**.

Le changement de port SSH est une mesure de **sécurité par l'obscurité** (security through obscurity). Bien que cette technique ne soit pas une vraie sécurité en soi, elle offre plusieurs bénéfices :

**Avantages :**

- ✅ Réduit drastiquement le bruit dans les logs (moins de tentatives automatisées)
- ✅ Diminue la charge serveur due aux scans
- ✅ Complique la tâche des attaquants non déterminés
- ✅ Ajoute une couche de défense en profondeur

**Limites :**

- ❌ N'empêche pas un attaquant déterminé (scan de ports)
- ❌ Ne remplace pas une vraie sécurité (clés SSH, firewall, etc.)
- ❌ Peut compliquer l'administration si mal documenté

> [!info] Philosophie de sécurité Le changement de port SSH ne doit **JAMAIS** être la seule mesure de sécurité. C'est un complément à :
> 
> - Authentification par clé uniquement
> - Désactivation de l'accès root
> - Firewall correctement configuré
> - Fail2ban ou équivalent
> - Mises à jour régulières

#### ⚙️ Configuration du port

##### Choix du port

```bash
# Règles pour choisir un port :
# - Éviter les ports privilégiés (< 1024) si possible
# - Éviter les ports standards connus (80, 443, 3306, etc.)
# - Éviter les ports couramment scannés
# - Choisir un port > 1024 et < 65535
# - Vérifier qu'il n'est pas déjà utilisé

# Ports couramment choisis (exemples) :
# 2222, 2200, 22000, 4444, 50022, etc.
```

> [!tip] Recommandation de port Privilégiez un port dans la plage **49152-65535** (ports dynamiques/privés) qui a moins de chance d'entrer en conflit avec d'autres services.

##### Vérifier qu'un port est disponible

```bash
# Vérifier si le port est déjà utilisé
sudo netstat -tlnp | grep :2222
sudo ss -tlnp | grep :2222

# Alternative avec lsof
sudo lsof -i :2222

# Si aucune sortie, le port est libre
```

##### Modification dans sshd_config

```bash
# Éditer /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config

# Trouver et modifier la ligne Port
Port 2222

# Ou ajouter si la ligne n'existe pas
# Par défaut, si commentée, SSH écoute sur le port 22
```

> [!warning] Configuration multi-ports (phase de transition) Pour une transition en douceur, vous pouvez temporairement écouter sur deux ports :
> 
> ```bash
> Port 22
> Port 2222
> ```
> 
> Cela permet de tester le nouveau port avant de fermer l'ancien.

##### Vérification de la configuration

```bash
# Tester la syntaxe
sudo sshd -t

# Redémarrer le service SSH
sudo systemctl restart sshd

# Vérifier que SSH écoute sur le nouveau port
sudo ss -tlnp | grep sshd
# Devrait montrer : LISTEN 0 128 0.0.0.0:2222 0.0.0.0:* users:(("sshd",pid=1234,fd=3))

# Vérifier le statut du service
sudo systemctl status sshd
```

#### 🔥 Configuration du firewall

Le changement de port SSH **nécessite impérativement** de mettre à jour le firewall.

##### UFW (Uncomplicated Firewall - Ubuntu/Debian)

```bash
# Autoriser le nouveau port SSH
sudo ufw allow 2222/tcp comment 'SSH custom port'

# Vérifier les règles
sudo ufw status numbered

# Une fois confirmé que le nouveau port fonctionne, retirer l'ancien
sudo ufw delete allow 22/tcp

# Recharger UFW
sudo ufw reload
```

##### firewalld (RHEL/CentOS/Fedora)

```bash
# Ajouter le nouveau port SSH
sudo firewall-cmd --permanent --add-port=2222/tcp

# Recharger la configuration
sudo firewall-cmd --reload

# Vérifier
sudo firewall-cmd --list-ports

# Une fois confirmé, retirer l'ancien port si vous l'aviez ajouté explicitement
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --reload
```

##### iptables (Manuel)

```bash
# Autoriser le nouveau port
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT

# Sauvegarder les règles
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# Ou sur RHEL/CentOS
sudo service iptables save
```

> [!warning] Ordre des opérations crucial **Procédure sécurisée de changement de port :**
> 
> 1. ✅ Ajouter le nouveau port dans le firewall
> 2. ✅ Configurer SSH pour écouter sur DEUX ports (22 et 2222)
> 3. ✅ Redémarrer SSH
> 4. ✅ Tester la connexion sur le nouveau port depuis une NOUVELLE session
> 5. ✅ Une fois confirmé, retirer le port 22 de sshd_config
> 6. ✅ Redémarrer SSH
> 7. ✅ Retirer le port 22 du firewall

#### 🔌 Connexion avec un port personnalisé

##### Depuis la ligne de commande

```bash
# Spécifier le port avec -p
ssh -p 2222 user@serveur

# Avec verbosité pour déboguer
ssh -vv -p 2222 user@serveur
```

##### Configuration SSH client persistante

Évitez de spécifier le port à chaque fois en configurant `~/.ssh/config` :

```bash
# Éditer ~/.ssh/config
nano ~/.ssh/config

# Ajouter une entrée pour votre serveur
Host monserveur
    HostName 192.168.1.100
    Port 2222
    User admin
    IdentityFile ~/.ssh/id_ed25519

Host prod-server
    HostName prod.example.com
    Port 2222
    User deploy

# Utilisation simplifiée
ssh monserveur       # Utilise automatiquement le port 2222
ssh prod-server
```

##### Configuration pour outils

De nombreux outils doivent être configurés pour le port personnalisé :

```bash
# SCP (secure copy)
scp -P 2222 fichier.txt user@serveur:/chemin/

# RSYNC
rsync -avz -e "ssh -p 2222" /local/path/ user@serveur:/remote/path/

# Git
git clone ssh://user@serveur:2222/chemin/repo.git

# Ou dans .git/config
[remote "origin"]
    url = ssh://user@serveur:2222/chemin/repo.git

# Ansible
# Dans inventory ou ansible.cfg
[serveurs]
serveur1 ansible_port=2222
serveur2 ansible_port=2222
```

#### 🛡️ SELinux et ports SSH

Sur les systèmes avec SELinux (RHEL/CentOS/Fedora), vous devez autoriser explicitement le nouveau port :

```bash
# Vérifier le statut SELinux
sestatus

# Voir les ports SSH autorisés par SELinux
sudo semanage port -l | grep ssh

# Ajouter le nouveau port
sudo semanage port -a -t ssh_port_t -p tcp 2222

# Si le port était déjà assigné à un autre service
sudo semanage port -m -t ssh_port_t -p tcp 2222

# Vérifier
sudo semanage port -l | grep ssh_port_t
# Devrait montrer : ssh_port_t tcp 22, 2222
```

> [!warning] Sans cette configuration SELinux SSH ne pourra pas démarrer sur le nouveau port et vous verrez dans les logs :
> 
> ```
> SELinux is preventing /usr/sbin/sshd from name_bind access on the tcp_socket port 2222
> ```

#### 📊 Monitoring et logs

##### Vérifier les tentatives de connexion

```bash
# Voir les connexions SSH récentes
sudo tail -f /var/log/auth.log    # Debian/Ubuntu
sudo tail -f /var/log/secure       # RHEL/CentOS

# Filtrer par port spécifique
sudo grep "port 2222" /var/log/auth.log

# Voir les tentatives de connexion échouées
sudo grep "Failed password" /var/log/auth.log
sudo grep "Invalid user" /var/log/auth.log

# Compter les tentatives par IP
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# Voir les connexions réussies
sudo grep "Accepted" /var/log/auth.log
```

##### Statistiques avant/après

```bash
# Avant changement de port (sur port 22, beaucoup de bruit)
sudo grep "Failed password" /var/log/auth.log | wc -l
# Résultat typique : plusieurs milliers par jour

# Après changement de port (sur port personnalisé)
sudo grep "Failed password" /var/log/auth.log | wc -l
# Résultat typique : quelques unités par jour (voire zéro)
```

#### 🎯 Scénarios et stratégies

|Scénario|Port recommandé|Firewall|Commentaire|
|---|---|---|---|
|**Serveur personnel/VPS**|2222-65535|Strict (nouveau port uniquement)|Réduction massive du bruit|
|**Serveur d'entreprise**|Port standardisé documenté|Restriction par IP source|Cohérence entre serveurs|
|**Serveur de production**|Port non-standard + VPN|Firewall + VPN obligatoire|Défense en profondeur|
|**Serveur de développement**|2222 (convention)|Ouvert réseau interne|Facilite l'accès équipe|
|**Jump server / Bastion**|Port standard possible|Strict + 2FA|Doit être très visible et sécurisé|

#### 💡 Bonnes pratiques et astuces

##### Documentation

> [!tip] Documentation essentielle Documentez TOUJOURS le port SSH personnalisé :
> 
> - Dans votre gestionnaire de mots de passe
> - Dans la documentation serveur
> - Dans les runbooks d'urgence
> - Dans `~/.ssh/config` sur vos machines
> 
> Un port oublié = impossibilité de se connecter

##### Scripts d'urgence

Créez un script pour revenir rapidement au port 22 en cas de problème :

```bash
#!/bin/bash
# /usr/local/bin/ssh-emergency-reset.sh

echo "=== SSH Emergency Reset ==="
echo "Resetting SSH to port 22"

# Backup de la config actuelle
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.emergency-backup

# Reset vers port 22
sed -i 's/^Port .*/Port 22/' /etc/ssh/sshd_config

# Test de la config
sshd -t
if [ $? -eq 0 ]; then
    echo "Configuration valid, restarting SSH..."
    systemctl restart sshd
    
    # Ouvrir le port 22 dans UFW
    ufw allow 22/tcp
    
    echo "SSH reset to port 22 - CHECK IMMEDIATELY"
else
    echo "ERROR: Invalid configuration"
    cp /etc/ssh/sshd_config.emergency-backup /etc/ssh/sshd_config
fi
```

##### Monitoring automatisé

```bash
# Script de vérification que SSH écoute sur le bon port
#!/bin/bash
# /usr/local/bin/check-ssh-port.sh

EXPECTED_PORT=2222

if ss -tlnp | grep -q ":$EXPECTED_PORT.*sshd"; then
    echo "OK: SSH listening on port $EXPECTED_PORT"
    exit 0
else
    echo "CRITICAL: SSH not listening on port $EXPECTED_PORT"
    # Alerter l'administrateur
    mail -s "SSH Port Alert" admin@example.com <<< "SSH is not listening on expected port $EXPECTED_PORT"
    exit 2
fi

# Ajouter dans crontab pour vérification régulière
# */5 * * * * /usr/local/bin/check-ssh-port.sh
```

#### ⚠️ Pièges et erreurs courantes

> [!warning] Erreur #1 : Changer le port sans mettre à jour le firewall **Symptôme** : Impossible de se connecter après le changement **Solution** : Toujours configurer le firewall AVANT de changer le port dans sshd_config
> 
> ```bash
> # Bon ordre :
> ufw allow 2222/tcp
> # puis modifier sshd_config
> # puis redémarrer sshd
> ```

> [!warning] Erreur #2 : Tester depuis la même session **Symptôme** : On pense que ça marche mais on est déjà connecté **Solution** : TOUJOURS tester depuis une NOUVELLE connexion
> 
> ```bash
> # Dans une nouvelle fenêtre terminal
> ssh -p 2222 user@serveur
> ```

> [!warning] Erreur #3 : Oublier SELinux **Symptôme** : SSH ne démarre pas sur RHEL/CentOS après changement **Solution** : Vérifier SELinux
> 
> ```bash
> sudo semanage port -a -t ssh_port_t -p tcp 2222
> ```

> [!warning] Erreur #4 : Ne pas documenter le changement **Symptôme** : Mois plus tard, vous ne savez plus sur quel port SSH écoute **Solution** : Documentez dans `~/.ssh/config` et votre documentation système

> [!warning] Erreur #5 : Choisir un port déjà utilisé **Symptôme** : SSH refuse de démarrer **Solution** : Vérifier avant
> 
> ```bash
> sudo netstat -tlnp | grep :2222
> ```

#### 🔍 Dépannage

##### SSH ne démarre pas après changement

```bash
# 1. Vérifier la configuration
sudo sshd -t

# 2. Voir les erreurs dans les logs
sudo journalctl -u sshd -n 50
sudo tail -30 /var/log/auth.log

# 3. Vérifier que le port n'est pas déjà utilisé
sudo ss -tlnp | grep :2222

# 4. Vérifier SELinux (si applicable)
sudo ausearch -m avc -ts recent | grep sshd

# 5. Revenir à la configuration précédente
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
sudo systemctl restart sshd
```

##### Connexion refusée sur le nouveau port

```bash
# 1. Vérifier que SSH écoute sur le port
sudo ss -tlnp | grep sshd

# 2. Vérifier le firewall
sudo ufw status
sudo iptables -L -n | grep 2222
sudo firewall-cmd --list-ports

# 3. Tester la connectivité réseau
telnet serveur 2222
nc -zv serveur 2222

# 4. Vérifier depuis le serveur lui-même
ssh -p 2222 localhost
```

##### Port semble bloqué par le FAI/pare-feu réseau

```bash
# Certains FAI/firewalls bloquent des plages de ports
# Tester avec un port différent

# Ports généralement NON bloqués :
# - 443 (HTTPS) - souvent ouvert partout
# - 8080, 8443 - ports web alternatifs
# - 2222, 22000 - moins courants mais généralement OK

# Si vraiment bloqué partout, considérer :
# - VPN
# - Tunnel SSH sur port 443
# - Service de proxy/jump server
```

---

## 📋 Checklist de sécurisation SSH complète

Avant de considérer votre serveur SSH comme sécurisé, vérifiez tous ces points :

### Configuration de base

- [ ] Authentification par clé publique configurée et testée
- [ ] Authentification par mot de passe désactivée (`PasswordAuthentication no`)
- [ ] Challenge-response désactivé (`ChallengeResponseAuthentication no`)
- [ ] Authentification clavier interactive désactivée (`KbdInteractiveAuthentication no`)

### Accès root et utilisateurs

- [ ] Connexion root désactivée (`PermitRootLogin no`)
- [ ] Au moins un utilisateur admin avec sudo configuré
- [ ] Capacité sudo testée pour cet utilisateur
- [ ] `AllowUsers` ou `AllowGroups` configuré (liste blanche)
- [ ] Comptes système dangereux dans `DenyUsers` si nécessaire

### Port et réseau

- [ ] Port SSH changé vers un port non-standard (optionnel mais recommandé)
- [ ] Firewall mis à jour pour le nouveau port
- [ ] SELinux configuré si applicable
- [ ] Nouvelle connexion SSH testée sur le nouveau port
- [ ] Ancienne configuration de port supprimée après validation
- [ ] `~/.ssh/config` mis à jour sur les machines clientes

### Tests et validation

- [ ] Configuration testée avec `sudo sshd -t`
- [ ] Connexion SSH testée depuis une NOUVELLE session
- [ ] Session actuelle maintenue ouverte pendant les tests
- [ ] Logs vérifiés (`/var/log/auth.log` ou `/var/log/secure`)
- [ ] Backup de la configuration originale créée

### Documentation

- [ ] Port SSH documenté (si changé)
- [ ] Utilisateurs autorisés documentés
- [ ] Groupes SSH documentés
- [ ] Procédure d'urgence créée
- [ ] `~/.ssh/config` configuré sur les machines de travail

---

## 🎓 Synthèse des concepts

Cette partie a couvert le **durcissement de la configuration serveur SSH**, qui constitue la première ligne de défense pour sécuriser l'accès à distance. Les cinq piliers abordés forment un ensemble cohérent :

1. **Authentification par clé uniquement** : Élimine les attaques par force brute sur mots de passe
2. **Désactivation root** : Ajoute une couche de défense et améliore la traçabilité
3. **Restriction des utilisateurs** : Contrôle granulaire au niveau individuel
4. **Limitation des groupes** : Gestion scalable et organisée des accès
5. **Changement de port** : Réduit le bruit et complique les attaques automatisées

> [!tip] Défense en profondeur La vraie sécurité vient de la **combinaison** de toutes ces mesures, pas d'une seule. Chaque couche compense les faiblesses des autres et augmente significativement le niveau de sécurité global.

Ces configurations forment la base d'un serveur SSH durci. D'autres mesures complémentaires existent (fail2ban, 2FA, tunneling, etc.) mais elles sortent du périmètre de cette partie et seront abordées dans les sections suivantes du cours SSH.

---

## 🔗 Liens avec d'autres parties du cours

Les concepts de cette partie s'articulent avec :

- **Authentification par clé SSH** : Prérequis pour désactiver les mots de passe (partie précédente)
- **Fail2ban et protection contre les attaques** : Complète les restrictions d'accès (partie suivante)
- **Authentification à deux facteurs (2FA)** : Ajoute une couche supplémentaire (partie suivante)
- **Tunneling et port forwarding** : Peut nécessiter des permissions spécifiques avec Match (partie suivante)
- **Jump servers et Bastion hosts** : Appliquent ces principes dans une architecture réseau (partie suivante)