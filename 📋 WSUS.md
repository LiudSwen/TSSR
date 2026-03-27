## 🔍 Définition

- Rôle intégré à **Windows Server** (gratuit, hors coût de licence)
- Gère la **distribution centralisée des mises à jour** des produits Microsoft
- Remplace le comportement autonome de **Windows Update** sur chaque machine

---

## 🌐 Port & Protocole

|Usage|Protocole|Port|
|---|---|---|
|Communication clients → WSUS (HTTP)|HTTP|**8530**|
|Communication clients → WSUS (HTTPS)|HTTPS|**8531**|
|Synchronisation WSUS → Microsoft Update|HTTPS|443|

> Exemple d'URL client : `http://wsus:8530`

---

## ⚙️ Configuration serveur

**Prérequis matériels recommandés :**

- 2 CPU, 16 Go RAM minimum
- Volume système : 128 Go / Volume stockage : 256 Go
- AD-DS **non obligatoire**

**Maintenance :**

- Utiliser le **Server Cleanup Wizard** pour purger les vieilles MAJ
- Synchronisation avec Microsoft : **2 fois par jour**

---

## 💻 Configuration clients

|Méthode|Contexte|
|---|---|
|`gpedit.msc` (stratégie locale)|Machine hors domaine|
|Clé de registre `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate`|Machine hors domaine|
|**GPO** (Group Policy)|Machine en domaine AD|

**Clés registre à créer/modifier :**

- `WUServer` _(String)_ → URL du serveur WSUS
- `WUStatusServer` _(String)_ → URL du serveur WSUS
- `UseWUServer` _(DWORD)_ → `1`

**Chemin GPO :** `Computer Configuration → Administrative Templates → Windows Components → Windows Update`  
Option : _"Specify Intranet Microsoft update service location"_

---

## ✅ Statuts des MAJ

**Approbation (côté serveur) :**

- **Unapproved** — disponible mais non validée
- **Approved** — validée pour installation
- **Declined** — refusée

**Installation (côté client) :**

- **Needed** — applicable, en attente
- **Failed** — erreur lors de l'installation
- **Failed or Needed** — approuvée en erreur OU non approuvée mais nécessaire
- **Installed / Not Applicable** — installée ou inapplicable

---

## 🚀 Stratégies de déploiement

**Patch Tuesday** → chaque **2ème mardi du mois**, Microsoft publie ses correctifs  
**Exploit Wednesday** → le lendemain, des malwares exploitent les failles publiées ⚠️

**Bonne pratique — déploiement décalé par groupes :**

|Semaine|Groupe cible|
|---|---|
|S2 (Patch Tuesday)|Service-TEST1|
|S3|Service-TEST2|
|S4|Service1 (production)|
|S1|Service2 (production)|

**Groupes d'ordinateurs recommandés :**

- Par OS (clients / serveurs / DC)
- Par service (Direction, DSI, Finance…)
- Par site géographique

**Fréquence de mise à jour recommandée :**

- Clients : hebdomadaire
- Serveurs : hebdomadaire ou mensuelle
- Contrôleurs de domaine (DC) : mensuelle ou planifiée

---

## 🔧 Scénarios avancés

|Scénario|Description|
|---|---|
|**WSUS + SCCM**|WSUS en amont, SCCM gère les MAJ (+ apps tierces, Mac via addons)|
|**PowerShell**|Module `UpdateServices` pour gérer groupes et approbations en CLI|
|**Multi-serveurs**|Serveurs en aval (_Downstream Servers_) pour les grands réseaux|

---

## 📝 À retenir

- WSUS peut fonctionner **avec ou sans AD**
- Les groupes d'ordinateurs peuvent être liés à l'**AD** ou gérés en autonomie
- La configuration clients et groupes est gérable via **GPO**
- Les serveurs WSUS peuvent s'organiser en **hiérarchie amont/aval**
- Les MAJ doivent être **approuvées manuellement** avant déploiement

---

_Historique : SUS (2002) → WSUS v2 (2005) → WSUS 3 (2006) → WSUS 4 (2012) → WSUS 5 (2016) → WSUS 10 (2019/2022)_