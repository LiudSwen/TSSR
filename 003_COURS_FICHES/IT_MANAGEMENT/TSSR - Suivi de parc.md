## ⚡ L'essentiel en 5 minutes - Suivi de Parc Informatique

### 📌 C'est quoi en 2 lignes ?

La gestion de parc informatique consiste à **inventorier, maintenir et optimiser** l'ensemble des ressources matérielles et logicielles d'une entreprise. Elle repose sur 3 piliers : **entretenir** (maintenir opérationnel), **développer** (faire évoluer), **optimiser** (sécuriser et former).

---

### 💡 Concepts clés à retenir :

- **Parc informatique** : Ensemble des ressources matérielles (PC, serveurs, périphériques, réseau) et logicielles (OS, licences) d'une organisation
- **CMDB** : Base de données de gestion de configuration centralisant tous les inventaires et informations du parc
- **MDM** : Mobile Device Management - gestion **active** et en temps réel des appareils mobiles (smartphones, tablettes)
- **GLPI** : Logiciel libre de gestion **passive** de parc combinant inventaire et helpdesk
- **Cycle de vie matériel** : Durée d'utilisation recommandée avant renouvellement (PC fixe 5 ans, portable 3 ans, serveur 5 ans)

---

### 💻 Outils essentiels :

**Logiciels d'inventaire automatique :**

```bash
# Découverte réseau
Fusion Inventory    # Agent d'inventaire automatique
SCCM               # System Center Configuration Manager (Microsoft)
NextThink          # Monitoring et analytics
```

**Gestion de parc (CMDB) :**

```bash
GLPI               # Libre - Inventaire + Helpdesk
Ivanti LanDesk     # Licence - Gestion complète
```

**MDM (appareils mobiles) :**

```bash
IBM Maas 360       # Gestion centralisée mobile
MobileIron         # Configuration et sécurité mobile
```

---

### 📐 Données d'inventaire à collecter :

**Pour chaque ordinateur :**

- **Identification** : Nom, code-barre, numéro de série (S/N)
- **Matériel** : Marque, modèle, CPU, RAM, disque dur, carte-mère
- **Réseau** : Adresse IP, adresse MAC
- **Logiciels** : OS, pilotes, applications installées
- **Domaine** : Domaine AD, OU (Organizational Unit)
- **Statut** : Production / Stock / Réparation / Hors service
- **Budget** : Prix d'achat, date, fournisseur, garantie
- **Utilisateur** : Nom du détenteur

**Exemple de cycle de renouvellement :**

```
Parc de 300 PC avec cycle 6 ans
→ Renouvellement : 300 ÷ 6 = 50 PC/an
→ Budget annuel : 50 × 800€ = 40 000€
```

---

### ⚠️ Pièges à éviter :

- ❌ **Inventaire obsolète** : Base non mise à jour = décisions erronées (matériel déjà remplacé, licences périmées)
- ❌ **Absence de procédures** : Chaque intervenant fait différemment → incohérences et perte de temps
- ❌ **Matériel hétérogène** : Trop de modèles différents → coûts de maintenance explosifs (pièces, formations)
- ❌ **Ignorer les mobiles** : Smartphones/tablettes non gérés = failles de sécurité majeures
- ❌ **Pas de cycle de vie** : Garder du matériel trop vieux → pannes fréquentes, coûts de maintenance > achat neuf

---

### ✅ Bonnes pratiques :

- ✅ **Uniformisation** : 2-3 modèles max par type de matériel → stock de pièces simplifié, formation unique
- ✅ **Automatisation inventaire** : Agent de découverte réseau (Fusion Inventory) → gain de temps + fiabilité
- ✅ **Maintenance préventive** : Planification mensuelle/annuelle → anticiper les pannes au lieu de les subir
- ✅ **Documentation vivante** : Procédures datées, versionnées, validées → référentiel commun à jour
- ✅ **Charte informatique** : Règles d'utilisation claires → responsabilisation des utilisateurs

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**CMDB**|Configuration Management Database - base centralisée de tous les actifs IT|
|**MDM**|Mobile Device Management - gestion active des mobiles (push config, wipe, localisation)|
|**Leasing**|Location longue durée (3 ans standard) - évite l'achat cash, renouvellement automatique|
|**Turn-over matériel**|Rotation programmée : renouveler 1/4 ou 1/3 du parc chaque année|
|**Help-desk**|Service de dépannage utilisateur - classification par criticité (standard/bloquant/urgent)|
|**Méthode 5M**|Ishikawa - analyser un problème via : Main d'œuvre, Matériel, Méthode, Matière, Milieu|
|**IoT**|Internet of Things - objets connectés (capteurs, caméras, etc.)|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : La gestion de parc = **Entretenir + Développer + Optimiser** (maintenir opérationnel, anticiper l'évolution, sécuriser et former)
    
2. 💻 **Pratique** : **GLPI (gestion passive)** pour inventaire/helpdesk vs **MDM (gestion active)** pour contrôle temps réel des mobiles
    
3. ⚠️ **Piège** : Ne JAMAIS négliger le **cycle de vie matériel** → prévoir budget renouvellement annuel (ex: PC portable 3 ans = remplacer 1/3 du parc/an)
    

---

### 🔧 Processus de gestion type :

**1. INVENTAIRE**

```
Méthode automatique → Agent réseau (Fusion Inventory)
Méthode manuelle    → Recensement + Bon de commande
↓
Sauvegarde CMDB (GLPI / Ivanti)
```

**2. MAINTENANCE**

```
Préventive  → Planification mensuelle/annuelle
Corrective  → Helpdesk avec niveaux de criticité
↓
Procédures documentées (date, version, cible)
```

**3. RENOUVELLEMENT**

```
Calcul : Parc total ÷ Cycle de vie = Nb/an
Budgétisation : Sept-Nov année N pour N+1
Mode : Achat direct ou Leasing 3 ans
```

**4. OPTIMISATION**

```
Uniformisation     → Max 3 modèles par type
Sécurité          → Antivirus, firewall, MAJ
Formation         → Utilisateurs + IT
Conformité        → Audits (RGPD, licences)
```

---

### 🛠️ Méthode 5M (diagnostic de problème) :

```
         PROBLÈME
              ↑
    ┌─────────┴─────────┐
  Main d'œuvre      Matériel
(compétences?)    (défaillant?)
    │                  │
  Méthode          Matière
(procédure OK?)  (composants?)
    │                  │
         └──── Milieu ───┘
           (environnement?)
```

**Exemple : "Taux de satisfaction client faible"**

- **Machines** : Imprimantes/serveurs insuffisants
- **Main d'œuvre** : Personnel déprimé, absentéisme
- **Méthodes** : Manque de procédures
- **Matière** : Gaspillage papier
- **Milieu** : Call-center sombre, coupures électricité

---

**💾 Aide-mémoire rapide :**

|Besoin|Solution|Type|
|---|---|---|
|Inventaire automatique|Fusion Inventory|Découverte réseau|
|Gestion parc + helpdesk|GLPI|Passif (enregistrement)|
|Contrôle smartphones|MDM (Maas360, MobileIron)|Actif (temps réel)|
|Procédures|Docs versionnées|Standard qualité|
|Renouvellement|Cycle de vie + budget N+3|Planification|