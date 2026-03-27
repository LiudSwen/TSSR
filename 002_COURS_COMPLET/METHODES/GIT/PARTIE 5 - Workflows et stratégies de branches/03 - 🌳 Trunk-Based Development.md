

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

## 🎯 Principe du Trunk-Based Development

### Qu'est-ce que le Trunk-Based Development ?

Le **Trunk-Based Development** (TBD) est une stratégie de gestion de branches où tous les développeurs commitent fréquemment (au moins quotidiennement) sur une seule branche principale appelée **trunk** (ou `main`/`master`).

> [!info] Philosophie du TBD Le TBD repose sur l'idée que **l'intégration continue** réduit drastiquement les risques de conflits et facilite la livraison continue. Au lieu d'isoler le travail pendant des jours ou semaines, on intègre constamment de petits changements.

### Caractéristiques principales

|Aspect|Trunk-Based Development|Workflows traditionnels|
|---|---|---|
|**Branche principale**|Une seule (trunk)|Multiples (develop, release, etc.)|
|**Durée des branches**|< 1-2 jours|Plusieurs jours/semaines|
|**Fréquence d'intégration**|Plusieurs fois par jour|Moins fréquente|
|**Complexité des merges**|Faible|Élevée|
|**Code review**|Rapide, petits changements|Plus long, gros changements|

### Pourquoi utiliser le Trunk-Based Development ?

**Avantages :**

- **Moins de conflits de merge** : Les intégrations fréquentes limitent les divergences
- **Feedback rapide** : Les problèmes sont détectés plus tôt
- **Déploiement simplifié** : Le trunk est toujours dans un état déployable
- **Collaboration facilitée** : Tout le monde travaille sur la même base de code
- **Moins de branches à gérer** : Réduction de la complexité

**Inconvénients :**

- **Exige une discipline rigoureuse** : Tests automatisés obligatoires
- **Demande des outils** : CI/CD performant, feature flags
- **Changement culturel** : Requiert l'adhésion de toute l'équipe

> [!warning] Prérequis essentiels Le TBD ne fonctionne que si :
> 
> - Les tests automatisés sont fiables et rapides
> - Le pipeline CI/CD est performant
> - L'équipe est formée et disciplinée
> - Le code est régulièrement intégré

### Mise en pratique

```bash
# Workflow quotidien typique en TBD

# 1. Toujours partir de la dernière version du trunk
git checkout main
git pull origin main

# 2. Créer une branche de courte durée (si nécessaire)
git checkout -b petite-feature

# 3. Faire des changements minimaux et atomiques
# ... modifications du code ...

# 4. Commiter fréquemment avec des messages clairs
git add .
git commit -m "feat: ajoute validation email dans le formulaire"

# 5. Rebaser sur main pour rester à jour (optionnel mais recommandé)
git fetch origin
git rebase origin/main

# 6. Pousser et créer une PR (ou commiter directement selon la taille de l'équipe)
git push origin petite-feature

# 7. Après merge rapide, supprimer la branche
git checkout main
git pull origin main
git branch -d petite-feature
```

> [!tip] Commit direct vs Branches courtes
> 
> - **Petites équipes (< 5 devs)** : Commit direct sur trunk possible avec pre-commit hooks
> - **Équipes moyennes/grandes** : Short-lived branches avec review rapide (< 24h)

### Bonnes pratiques

**DO :**

- ✅ Intégrer au moins une fois par jour
- ✅ Garder le trunk toujours déployable
- ✅ Faire des commits petits et atomiques
- ✅ Utiliser des feature flags pour le code incomplet
- ✅ Automatiser tous les tests
- ✅ Faire des code reviews rapides (< 2 heures)

**DON'T :**

- ❌ Laisser une branche vivre plus de 2 jours
- ❌ Commiter du code qui casse les tests
- ❌ Développer des features massives d'un coup
- ❌ Négliger les tests automatisés
- ❌ Ignorer les conflits ou les reporter

> [!example] Exemple concret **Développement d'une nouvelle page de profil utilisateur :**
> 
> Au lieu de créer une branche `feature/user-profile` pendant 2 semaines, on découpe :
> 
> - Jour 1 : Structure HTML basique (merged)
> - Jour 2 : Styles CSS (merged)
> - Jour 3 : Récupération données API (merged, derrière feature flag)
> - Jour 4 : Logique d'édition (merged, derrière feature flag)
> - Jour 5 : Activation du feature flag en production
> 
> Chaque jour = une PR indépendante qui enrichit progressivement la fonctionnalité.

---

## ⚡ Short-lived Branches

### Concept des branches de courte durée

Les **short-lived branches** (branches éphémères) sont des branches qui existent pour une durée très limitée, typiquement **moins de 24 à 48 heures**, avant d'être mergées dans le trunk.

> [!info] Différence avec les feature branches classiques
> 
> - **Feature branch classique** : Peut vivre des semaines, contient une fonctionnalité complète
> - **Short-lived branch** : Vit quelques heures/jours, contient un petit incrément de travail

### Règles des short-lived branches

**Durée maximale :**

- **Idéal** : < 1 jour
- **Acceptable** : < 2 jours
- **Limite absolue** : 3 jours maximum

**Taille du changement :**

- **Lignes de code** : Généralement < 400 lignes
- **Fichiers modifiés** : < 10 fichiers
- **Commits** : 1 à 5 commits maximum

> [!warning] Signal d'alarme Si votre branche :
> 
> - Existe depuis plus de 2 jours
> - Contient plus de 500 lignes modifiées
> - A plus de 10 commits
> 
> ⚠️ Vous devez la découper ou la merger immédiatement !

### Workflow avec short-lived branches

```bash
# Matin : Démarrer une nouvelle tâche
git checkout main
git pull origin main
git checkout -b fix-login-validation

# Faire des modifications ciblées (1-2 heures de travail)
# ... code ...

# Commiter
git add .
git commit -m "fix: améliore validation regex email"

# Pousser rapidement
git push origin fix-login-validation

# Créer une PR immédiatement
# (via interface GitHub/GitLab ou CLI)

# Après-midi : Review et merge rapide
# La PR est reviewée en < 2 heures
# Merge dès validation

# Nettoyer localement
git checkout main
git pull origin main
git branch -d fix-login-validation

# Recommencer pour la tâche suivante
git checkout -b add-password-strength-indicator
```

### Stratégies pour maintenir les branches courtes

#### 1. Découper le travail en tranches verticales

```bash
# ❌ MAUVAIS : Feature branch massive
git checkout -b feature-nouveau-dashboard
# ... 15 jours de développement ...
# Résultat : 2000 lignes, 50 fichiers, impossible à reviewer

# ✅ BON : Découper en mini-tâches
git checkout -b dashboard-structure-html      # Jour 1
git checkout -b dashboard-api-endpoint         # Jour 2
git checkout -b dashboard-styles               # Jour 3
git checkout -b dashboard-graphiques           # Jour 4
git checkout -b dashboard-filtres              # Jour 5
```

#### 2. Utiliser le rebase pour rester à jour

```bash
# Maintenir la branche à jour avec main
git fetch origin

# Rebaser régulièrement (plusieurs fois par jour si nécessaire)
git rebase origin/main

# Résoudre les conflits immédiatement
# ... résolution ...

git rebase --continue

# Force push (acceptable sur short-lived branches)
git push --force-with-lease origin ma-branche
```

> [!tip] Fréquence de rebase Sur une short-lived branch :
> 
> - Rebaser **au minimum** une fois avant de créer la PR
> - Rebaser **plusieurs fois par jour** si le trunk est très actif
> - Rebaser **immédiatement** en cas de conflit signalé par la CI

#### 3. Merger partiellement du code incomplet

```bash
# Merger du code "en construction" avec des feature flags
git checkout -b new-payment-system

# Code incomplet mais fonctionnel (n'explose pas)
# Ajout de la nouvelle logique derrière un flag
if (isFeatureEnabled('new_payment_system')) {
    // Nouveau code
} else {
    // Ancien code (actif en production)
}

# Commit et merge même si la feature n'est pas terminée
git add .
git commit -m "feat: ajoute base nouveau système paiement (behind flag)"
git push origin new-payment-system
# Merge après review rapide
```

### Gestion des code reviews

> [!info] Code review optimisée pour short-lived branches
> 
> - **Temps de review** : < 2 heures (idéalement < 1 heure)
> - **Taille idéale** : 200-400 lignes maximum
> - **Priorité** : Les PR courtes doivent être reviewées en priorité
> - **Automatisation** : Linting, tests, security checks automatiques

```bash
# Configuration pour forcer les branches courtes (pre-push hook)
# .git/hooks/pre-push

#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)
MAIN_BRANCH="main"

# Vérifier l'âge de la branche
BRANCH_AGE=$(git log --since="3 days ago" $MAIN_BRANCH..$BRANCH --oneline | wc -l)

if [ "$BRANCH" != "$MAIN_BRANCH" ] && [ $BRANCH_AGE -eq 0 ]; then
    echo "❌ Erreur : Cette branche existe depuis plus de 3 jours !"
    echo "Mergez-la ou découpez-la en plus petites branches."
    exit 1
fi

# Vérifier le nombre de commits
COMMIT_COUNT=$(git rev-list --count $MAIN_BRANCH..$BRANCH)

if [ $COMMIT_COUNT -gt 10 ]; then
    echo "❌ Erreur : Trop de commits ($COMMIT_COUNT) !"
    echo "Squashez ou découpez en branches plus petites."
    exit 1
fi

exit 0
```

### Pièges courants

|Piège|Solution|
|---|---|
|**Branche qui s'éternise**|Découper en sous-tâches et merger progressivement|
|**Conflits massifs au merge**|Rebaser quotidiennement sur main|
|**Code review bloquée**|Réduire la taille des PR, < 400 lignes|
|**Tests qui échouent**|Ne jamais pousser sans vérifier localement|
|**Dépendance entre branches**|Merger la première avant de démarrer la seconde|

> [!warning] Anti-pattern : La branche "presque finie" Évitez de garder une branche en disant "j'ai presque fini". Si vous avez du code fonctionnel :
> 
> - Mergez ce qui est prêt maintenant
> - Créez une nouvelle branche pour le reste
> - Utilisez des feature flags si nécessaire

---

## 🚩 Feature Flags

### Qu'est-ce qu'un feature flag ?

Un **feature flag** (ou feature toggle) est un mécanisme qui permet d'activer ou désactiver une fonctionnalité **sans déployer de nouveau code**. C'est un interrupteur logiciel.

> [!info] Concept clé Les feature flags permettent de **découpler le déploiement du code de l'activation des fonctionnalités**. Vous pouvez déployer du code "incomplet" en production, mais gardé inactif jusqu'à ce qu'il soit prêt.

### Pourquoi utiliser des feature flags en TBD ?

Dans le contexte du Trunk-Based Development, les feature flags sont **essentiels** car ils permettent :

1. **Merger du code incomplet** : Intégrer une fonctionnalité par petits morceaux
2. **Tester en production** : Activer pour un sous-ensemble d'utilisateurs
3. **Rollback instantané** : Désactiver sans redéployer en cas de problème
4. **A/B testing** : Comparer différentes versions d'une feature
5. **Déploiement progressif** : Activer graduellement (1%, 10%, 100%)

### Types de feature flags

|Type|Durée de vie|Utilisation|
|---|---|---|
|**Release flags**|Courte (jours/semaines)|Cacher une feature en développement|
|**Experiment flags**|Moyenne (semaines/mois)|A/B testing, expérimentation|
|**Ops flags**|Longue (permanente)|Circuit breaker, performance tuning|
|**Permission flags**|Longue (permanente)|Contrôle d'accès, plans premium|

### Implémentation basique

#### 1. Configuration simple (JSON/YAML)

```bash
# Configuration dans un fichier ou base de données
# config/features.json
{
  "new_dashboard": false,
  "payment_v2": false,
  "dark_mode": true,
  "advanced_filters": true
}
```

#### 2. Utilisation dans le code

```javascript
// Exemple JavaScript
function isFeatureEnabled(flagName) {
  const config = require('./config/features.json');
  return config[flagName] || false;
}

// Utilisation
if (isFeatureEnabled('new_dashboard')) {
  // Nouveau code
  renderNewDashboard();
} else {
  // Ancien code (stable)
  renderOldDashboard();
}
```

```python
# Exemple Python
import json

def is_feature_enabled(flag_name):
    with open('config/features.json') as f:
        config = json.load(f)
    return config.get(flag_name, False)

# Utilisation
if is_feature_enabled('payment_v2'):
    # Nouveau système de paiement
    process_payment_v2(order)
else:
    # Ancien système (stable)
    process_payment_v1(order)
```

### Implémentation avancée

#### 1. Feature flags avec ciblage utilisateur

```javascript
// Système de feature flags avancé
class FeatureFlags {
  constructor(config, user) {
    this.config = config;
    this.user = user;
  }

  isEnabled(flagName) {
    const flag = this.config[flagName];
    
    if (!flag) return false;
    
    // Flag complètement désactivé
    if (flag.enabled === false) return false;
    
    // Flag complètement activé
    if (flag.enabled === true) return true;
    
    // Activation par pourcentage d'utilisateurs
    if (flag.percentage) {
      return this.isInPercentage(flagName, flag.percentage);
    }
    
    // Activation pour des utilisateurs spécifiques
    if (flag.users && flag.users.includes(this.user.id)) {
      return true;
    }
    
    // Activation par attribut utilisateur
    if (flag.attributes) {
      return this.matchesAttributes(flag.attributes);
    }
    
    return false;
  }
  
  isInPercentage(flagName, percentage) {
    // Hash déterministe basé sur user.id + flagName
    const hash = this.simpleHash(this.user.id + flagName);
    return (hash % 100) < percentage;
  }
  
  matchesAttributes(attributes) {
    // Vérifier si l'utilisateur correspond aux critères
    for (const [key, value] of Object.entries(attributes)) {
      if (this.user[key] !== value) return false;
    }
    return true;
  }
  
  simpleHash(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = ((hash << 5) - hash) + str.charCodeAt(i);
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}

// Configuration avancée
const config = {
  "new_dashboard": {
    "enabled": true,
    "percentage": 10  // Activé pour 10% des utilisateurs
  },
  "payment_v2": {
    "enabled": true,
    "users": ["user123", "user456"]  // Activé pour des users spécifiques
  },
  "premium_features": {
    "enabled": true,
    "attributes": {
      "plan": "premium"  // Activé seulement pour les users premium
    }
  }
};

// Utilisation
const user = { id: 'user789', plan: 'free' };
const flags = new FeatureFlags(config, user);

if (flags.isEnabled('new_dashboard')) {
  renderNewDashboard();
}
```

#### 2. Rollout progressif

```bash
# Étapes d'un déploiement progressif avec feature flags

# Étape 1 : Merger le code (flag à 0%)
git checkout main
git pull origin main
git checkout -b payment-v2-implementation
# ... code avec flag "payment_v2": { "enabled": true, "percentage": 0 }
git commit -m "feat: implémente payment v2 (behind flag, 0%)"
git push origin payment-v2-implementation
# Merge dans main

# Étape 2 : Activer pour l'équipe interne (users spécifiques)
# Modification config :
# "payment_v2": { "enabled": true, "users": ["dev1", "dev2", "qa1"] }
# Validation interne

# Étape 3 : Canary release (1% des utilisateurs)
# "payment_v2": { "enabled": true, "percentage": 1 }
# Monitoring intensif, 24-48h

# Étape 4 : Élargissement progressif
# "percentage": 5    # +48h
# "percentage": 10   # +24h
# "percentage": 25   # +24h
# "percentage": 50   # +24h
# "percentage": 100  # Activation complète

# Étape 5 : Nettoyage du code (supprimer le flag)
git checkout -b cleanup-payment-v2-flag
# Supprimer tous les if/else liés au flag
# Garder seulement le nouveau code
git commit -m "chore: supprime feature flag payment_v2"
```

### Outils de gestion de feature flags

> [!tip] Solutions populaires **Open-source :**
> 
> - **Unleash** : Self-hosted, complet, avec UI
> - **Flagsmith** : Open-source avec option cloud
> - **GrowthBook** : Focus A/B testing
> 
> **SaaS (payants) :**
> 
> - **LaunchDarkly** : Leader du marché, très complet
> - **Split** : Feature flags + expérimentation
> - **Optimizely** : A/B testing + feature flags

### Bonnes pratiques

**DO :**

- ✅ Utiliser des flags pour toute fonctionnalité > 1 jour de dev
- ✅ Supprimer les flags une fois la feature stable (technique debt)
- ✅ Logger les activations/désactivations pour tracer l'historique
- ✅ Tester TOUS les chemins de code (flag ON et OFF)
- ✅ Documenter chaque flag (raison, date création, propriétaire)
- ✅ Monitorer les performances avec flags activés

**DON'T :**

- ❌ Accumuler des centaines de flags obsolètes
- ❌ Utiliser les flags pour du contrôle d'accès permanent (utiliser permissions)
- ❌ Oublier de tester le code quand le flag est désactivé
- ❌ Déployer un flag sans plan de rollback
- ❌ Changer un flag en production sans monitoring

> [!warning] Dette technique Les feature flags créent de la **dette technique** :
> 
> - Complexité du code (multiples chemins)
> - Difficulté de test (combinaisons exponentielles)
> - Confusion pour les nouveaux développeurs
> 
> **Règle d'or** : Supprimez un flag dès que la feature est stable (généralement < 2 semaines après activation à 100%).

### Exemple complet : Workflow TBD + Feature Flags

```bash
# Scénario : Refonte complète du système de notifications

# === Semaine 1 : Infrastructure ===
git checkout -b notif-v2-models
# Ajoute nouveaux modèles de données
# Code inactif, pas de flag nécessaire
git commit -m "feat: ajoute modèles notifications v2"
# Merge immédiatement

# === Semaine 2 : API ===
git checkout -b notif-v2-api
# Ajoute nouveaux endpoints API avec flag
# Code :
if (isFeatureEnabled('notifications_v2')) {
    return notificationServiceV2.send(notification);
} else {
    return notificationServiceV1.send(notification);
}

# Config : "notifications_v2": { "enabled": false }
git commit -m "feat: API notifications v2 (behind flag)"
# Merge

# === Semaine 3 : UI ===
git checkout -b notif-v2-ui
# Nouvelle interface utilisateur avec flag
git commit -m "feat: UI notifications v2 (behind flag)"
# Merge

# === Semaine 4 : Tests internes ===
# Active pour l'équipe
# "notifications_v2": { "users": ["dev1", "dev2", "qa1", "qa2"] }
# Bugs détectés et fixés

# === Semaine 5 : Rollout progressif ===
# "notifications_v2": { "percentage": 1 }   # Lundi
# Monitoring OK
# "percentage": 10  # Mercredi
# "percentage": 50  # Vendredi
# "percentage": 100 # Semaine 6 - Lundi

# === Semaine 7 : Nettoyage ===
git checkout -b remove-notif-v2-flag
# Supprime tout le code v1 et les conditions du flag
# Garde uniquement le code v2
git commit -m "chore: supprime code notifications v1 et feature flag"
# Merge

# Résultat : Refonte complète sans jamais bloquer le trunk
```

> [!example] Cas d'usage réel **Spotify** utilise massivement les feature flags :
> 
> - Toutes les features sont mergées derrière des flags
> - Rollout progressif : 1% → 5% → 25% → 50% → 100%
> - A/B testing permanent sur l'UI et les algorithmes
> - Possibilité de rollback instantané sans redéploiement
> 
> Résultat : Déploiements multiples par jour en production, sans risque.

### Pièges courants avec les feature flags

|Piège|Impact|Solution|
|---|---|---|
|**Flag oublié**|Dette technique croissante|Ticket de suppression obligatoire à chaque flag|
|**Flags imbriqués**|Complexité exponentielle|Max 1 niveau d'imbrication, sinon refactorer|
|**Tests insuffisants**|Bugs selon état du flag|CI doit tester ON et OFF|
|**Config désynchronisée**|Incohérences entre environnements|Source de vérité unique (DB ou service)|
|**Monitoring absent**|Problèmes non détectés|Alertes sur activation/erreurs|

> [!tip] Astuce : Auto-expiration des flags Configurez une date d'expiration automatique pour chaque flag :
> 
> ```javascript
> {
>   "new_feature": {
>     "enabled": true,
>     "expires_at": "2025-03-01",
>     "owner": "team-backend"
>   }
> }
> ```
> 
> Alertez automatiquement les équipes quand un flag approche de sa date d'expiration.