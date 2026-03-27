

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

## 🔰 Introduction aux Targets

Les **targets** dans systemd sont des unités spéciales qui regroupent d'autres unités pour définir des états ou des points de synchronisation du système. Elles remplacent les anciens **runlevels** de SysV Init.

> [!info] Concept clé Une target ne fait rien par elle-même : elle sert de point de regroupement pour démarrer ou arrêter un ensemble cohérent de services. C'est comme un "mode de fonctionnement" du système.

### 🎯 Pourquoi utiliser les Targets ?

- **Définir l'état du système** : mode console, mode graphique, mode rescue, etc.
- **Synchronisation** : s'assurer que certains services sont démarrés avant d'autres
- **Faciliter l'administration** : changer rapidement le mode de fonctionnement du système
- **Compatibilité** : maintenir une logique similaire aux runlevels traditionnels

### 📊 Équivalence Runlevels vs Targets

|Ancien Runlevel|Target Systemd|Description|
|---|---|---|
|0|poweroff.target|Extinction du système|
|1, s, single|rescue.target|Mode rescue (utilisateur root seul)|
|2, 3, 4|multi-user.target|Mode multi-utilisateur sans interface graphique|
|5|graphical.target|Mode multi-utilisateur avec interface graphique|
|6|reboot.target|Redémarrage du système|

---

## 🖥️ Les Targets Principales

### multi-user.target

La target **multi-user.target** représente un système en mode multi-utilisateur complet, mais **sans interface graphique**. C'est l'équivalent du runlevel 3.

> [!example] Cas d'usage typiques
> 
> - Serveurs sans environnement graphique
> - Systèmes embarqués
> - Machines administrées uniquement en ligne de commande
> - Optimisation des ressources (pas de serveur X)

#### 📦 Caractéristiques

```bash
# Afficher les détails de multi-user.target
systemctl cat multi-user.target
```

La target inclut généralement :

- Les services réseau (NetworkManager, sshd, etc.)
- Les services système essentiels
- Les démons en arrière-plan
- **Pas de gestionnaire de fenêtres ni de serveur X**

#### 🔍 Services associés

```bash
# Lister tous les services requis par multi-user.target
systemctl list-dependencies multi-user.target

# Lister uniquement les services actifs
systemctl list-dependencies multi-user.target --state=active

# Vue inverse : voir quelles targets dépendent d'une unité
systemctl list-dependencies --reverse sshd.service
```

> [!tip] Astuce Utilisez `--all` pour voir également les dépendances désactivées : `systemctl list-dependencies multi-user.target --all`

---

### graphical.target

La target **graphical.target** représente un système avec interface graphique complète. C'est l'équivalent du runlevel 5.

> [!info] Relation avec multi-user.target **graphical.target** hérite de **multi-user.target**. Cela signifie que tous les services de multi-user.target sont également démarrés, plus les services graphiques.

#### 📦 Services additionnels

En plus de tout ce que fournit multi-user.target, graphical.target démarre :

- Le serveur d'affichage (X11 ou Wayland)
- Le gestionnaire de connexion (GDM, LightDM, SDDM, etc.)
- Les services de l'environnement de bureau

```bash
# Voir la dépendance directe
systemctl show graphical.target | grep Requires

# Exemple de sortie typique :
# Requires=multi-user.target display-manager.service
```

#### 🔧 Configuration

```bash
# Vérifier si graphical.target est disponible
systemctl status graphical.target

# Voir quel display manager est actif
systemctl status display-manager.service
```

> [!warning] Attention Si aucun gestionnaire d'affichage n'est installé, graphical.target échouera au démarrage. Le système se rabattra sur multi-user.target.

---

### Autres Targets Courantes

#### 🚨 rescue.target

Mode de maintenance avec shell root uniquement (équivalent au runlevel 1).

```bash
# Services minimaux uniquement
# Réseau généralement désactivé
# Systèmes de fichiers en lecture seule possible
```

> [!example] Quand l'utiliser ?
> 
> - Réparation du système de fichiers
> - Récupération de mot de passe root
> - Dépannage de services critiques

#### 🔌 emergency.target

Mode encore plus minimal que rescue.target.

```bash
# Shell root avec système de fichiers racine en lecture seule
# Pratiquement aucun service démarré
```

#### ⚡ Targets de gestion d'énergie

|Target|Description|
|---|---|
|poweroff.target|Éteint le système|
|reboot.target|Redémarre le système|
|suspend.target|Met en veille (RAM alimentée)|
|hibernate.target|Hibernation (sur disque)|
|hybrid-sleep.target|Veille hybride|

---

## 🔄 Changement de Target (isolate)

La commande `systemctl isolate` permet de basculer d'une target à une autre **sans redémarrer** le système.

### 📝 Syntaxe

```bash
systemctl isolate <nom-de-la-target>
```

> [!warning] Comportement important `isolate` **arrête tous les services** qui ne sont pas requis par la nouvelle target. C'est un changement radical de l'état du système.

### 🎬 Exemples pratiques

#### Basculer en mode console (multi-user)

```bash
# Arrête l'interface graphique et passe en mode console
sudo systemctl isolate multi-user.target
```

> [!example] Résultat
> 
> - Le serveur X/Wayland est arrêté
> - Vous êtes déconnecté de votre session graphique
> - Vous arrivez sur un TTY en mode console
> - Tous les services graphiques sont arrêtés

#### Basculer en mode graphique

```bash
# Démarre l'interface graphique
sudo systemctl isolate graphical.target
```

#### Mode rescue

```bash
# Bascule en mode maintenance
sudo systemctl isolate rescue.target
```

> [!tip] Raccourcis pratiques Systemd fournit des alias pour les actions courantes :
> 
> ```bash
> systemctl rescue    # Équivalent à : isolate rescue.target
> systemctl emergency # Équivalent à : isolate emergency.target
> ```

### 🔐 Conditions pour isolate

Une target ne peut être utilisée avec `isolate` que si elle possède la directive `AllowIsolate=yes` dans sa configuration.

```bash
# Vérifier si une target peut être isolée
systemctl show -p AllowIsolate multi-user.target

# Sortie attendue :
# AllowIsolate=yes
```

> [!info] Targets isolables par défaut Les targets principales (multi-user, graphical, rescue, emergency) sont isolables par défaut.

### ⚠️ Différence avec start/stop

|Commande|Comportement|
|---|---|
|`systemctl start graphical.target`|**Démarre** les services de la target sans arrêter les autres|
|`systemctl isolate graphical.target`|**Remplace** l'état actuel : arrête ce qui n'est pas nécessaire, démarre ce qui manque|

```bash
# start = additionnel (accumulation)
sudo systemctl start graphical.target  # Ajoute les services graphiques

# isolate = remplacement (substitution)
sudo systemctl isolate graphical.target  # État graphique pur
```

---

## ⚙️ Gestion de la Target par Défaut

La **target par défaut** est celle vers laquelle le système démarre automatiquement lors du boot.

### 🔍 Consulter la target par défaut

```bash
# Méthode 1 : Commande dédiée
systemctl get-default

# Sortie typique :
# graphical.target

# Méthode 2 : Via le lien symbolique
ls -l /etc/systemd/system/default.target

# Sortie :
# /etc/systemd/system/default.target -> /lib/systemd/system/graphical.target
```

> [!info] Implémentation technique La target par défaut est définie par un lien symbolique `/etc/systemd/system/default.target` qui pointe vers la target souhaitée.

### 🔧 Modifier la target par défaut

#### Méthode recommandée

```bash
# Passer en mode graphique par défaut
sudo systemctl set-default graphical.target

# Sortie :
# Removed /etc/systemd/system/default.target.
# Created symlink /etc/systemd/system/default.target → /lib/systemd/system/graphical.target.

# Passer en mode console par défaut
sudo systemctl set-default multi-user.target
```

> [!tip] Pas de redémarrage nécessaire La modification de la target par défaut ne change pas l'état actuel du système. Elle prendra effet au prochain boot.

#### Méthode manuelle (non recommandée)

```bash
# Vous pouvez créer le lien symbolique manuellement, mais c'est déconseillé
sudo ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
```

### 🎯 Cas d'usage

#### Serveur sans interface graphique

```bash
# Optimisation pour un serveur
sudo systemctl set-default multi-user.target

# Économie de ressources (RAM, CPU)
# Pas de X11/Wayland inutile
# Démarrage plus rapide
```

#### Poste de travail graphique

```bash
# Configuration standard pour desktop
sudo systemctl set-default graphical.target

# Interface utilisateur au démarrage
# Gestionnaire de connexion graphique
```

### 🔄 Vérification après modification

```bash
# Vérifier la nouvelle configuration
systemctl get-default

# Vérifier que le système démarrera correctement
systemctl list-dependencies default.target | head -20
```

> [!warning] Attention aux dépendances Assurez-vous que la target choisie et ses dépendances sont installées. Par exemple, graphical.target nécessite un display manager.

---

## ⚠️ Pièges Courants et Bonnes Pratiques

### 🚫 Erreurs fréquentes

#### 1. Utiliser isolate au lieu de start

```bash
# ❌ ERREUR : Arrête l'interface graphique
sudo systemctl isolate multi-user.target

# ✅ CORRECT : Si vous voulez juste arrêter temporairement l'interface
sudo systemctl stop display-manager.service
```

> [!warning] Isolate est radical `isolate` change complètement l'état du système. Utilisez-le uniquement quand vous voulez vraiment basculer de mode de fonctionnement.

#### 2. Modifier default.target manuellement

```bash
# ❌ ERREUR : Risque de syntaxe incorrecte
sudo ln -s /lib/systemd/system/graphical.target /etc/systemd/system/default.target

# ✅ CORRECT : Toujours utiliser set-default
sudo systemctl set-default graphical.target
```

#### 3. Oublier que graphical hérite de multi-user

```bash
# ❌ Idée fausse : "Je dois activer multi-user ET graphical"
# ✅ Réalité : graphical.target inclut automatiquement multi-user.target
```

#### 4. Confondre target par défaut et target actuelle

```bash
# La target par défaut (au boot)
systemctl get-default

# La target actuellement active (état en cours)
systemctl list-units --type=target --state=active
```

### ✅ Bonnes pratiques

#### 1. Vérifier avant d'isoler

```bash
# Toujours vérifier l'état actuel avant un isolate
systemctl list-units --type=target --state=active

# Vérifier ce qui va être arrêté
systemctl list-dependencies --reverse <votre-service-critique>
```

#### 2. Utiliser les raccourcis quand approprié

```bash
# Plus lisible et moins sujet aux erreurs
systemctl rescue
systemctl emergency

# Au lieu de
systemctl isolate rescue.target
systemctl isolate emergency.target
```

#### 3. Tester les changements

```bash
# Après avoir changé la target par défaut
# Vérifiez que le système peut démarrer
sudo systemctl isolate <nouvelle-target>

# Si ça fonctionne, alors le boot fonctionnera
```

#### 4. Documenter les changements

```bash
# Gardez une trace de vos modifications
echo "$(date) - Changed default target to multi-user" | sudo tee -a /var/log/admin-changes.log

systemctl get-default
```

### 🎯 Astuces avancées

#### Créer une target personnalisée

Bien que non couvert en détail ici, sachez qu'il est possible de créer vos propres targets pour des configurations spécifiques :

```bash
# Exemple de structure (simplifié)
# /etc/systemd/system/ma-target.target
[Unit]
Description=Ma target personnalisée
Requires=multi-user.target
After=multi-user.target

[Install]
Alias=custom.target
```

#### Lister toutes les targets disponibles

```bash
# Voir toutes les targets du système
systemctl list-unit-files --type=target

# Voir uniquement les targets actives
systemctl list-units --type=target
```

#### Analyser les dépendances graphiquement

```bash
# Générer un graphe de dépendances (nécessite graphviz)
systemd-analyze dot multi-user.target | dot -Tpng > multi-user-deps.png

# Visualiser le temps de démarrage des targets
systemd-analyze critical-chain
```

> [!tip] Débogage Pour comprendre pourquoi une target est lente à démarrer, utilisez :
> 
> ```bash
> systemd-analyze blame
> systemd-analyze critical-chain graphical.target
> ```

---

## 📝 Récapitulatif des commandes essentielles

```bash
# === Consultation ===
systemctl get-default                    # Target par défaut
systemctl list-units --type=target       # Targets actives
systemctl list-dependencies multi-user.target  # Dépendances

# === Modification ===
systemctl set-default graphical.target   # Changer le défaut (permanent)
systemctl isolate multi-user.target      # Changer immédiatement (temporaire)

# === Raccourcis ===
systemctl rescue                         # Mode rescue
systemctl emergency                      # Mode emergency

# === Analyse ===
systemctl show -p AllowIsolate <target>  # Vérifier si isolable
systemctl cat multi-user.target          # Voir la configuration
```

---

> [!success] Points clés à retenir
> 
> - Les **targets** remplacent les runlevels et définissent des états du système
> - **multi-user.target** = mode console multi-utilisateur
> - **graphical.target** = multi-user + interface graphique
> - `isolate` bascule entre targets (changement d'état complet)
> - `get-default` / `set-default` gèrent la target au boot
> - Toujours vérifier l'état avant d'utiliser `isolate`