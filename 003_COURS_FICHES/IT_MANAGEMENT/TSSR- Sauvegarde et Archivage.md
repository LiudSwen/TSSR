## ⚡ L'essentiel en 5 minutes - Sauvegarde & Archivage

### 📌 C'est quoi en 2 lignes ?

**Sauvegarde** : copie des données sur un support distinct pour récupération en cas d'incident. **Archivage** : conservation long terme de données non nécessaires immédiatement, avec contraintes légales et techniques spécifiques.

---

### 💡 Concepts clés à retenir :

- **Règle 3-2-1** : 3 copies des données, sur 2 types de supports différents, dont 1 hors-site
- **Sauvegarde complète** : duplication totale des données (lente, volumineuse, restauration simple)
- **Sauvegarde incrémentale** : uniquement les modifs depuis dernière sauvegarde (rapide, restauration complexe)
- **Sauvegarde différentielle** : uniquement les modifs depuis dernière complète (compromis entre les 2)
- **Clonage** : image complète d'une machine pour reprise rapide après sinistre

---

### 💻 Supports & Technologies essentiels :

```bash
# 📦 Supports physiques
Disques externes          # Accessible mais vulnérable aux pannes simultanées
Bandes LTO               # Longue durée, hors-ligne (anti-ransomware)
Cloud (S3, etc.)         # Hors-site automatique, chiffrement obligatoire
Serveur distant          # Réplication temps réel possible

# 🛠️ Outils libres courants
bareos-fd                # Client Bareos (fork de Bacula)
borgbackup              # Sauvegarde incrémentale déduplication
clonezilla              # Clonage de disques/partitions
rsync -avz --delete     # Synchronisation miroir
```

```powershell
# 🪟 Windows natif
wbadmin start backup -backupTarget:E: -include:C: -allCritical
# Sauvegarde Windows complète

Get-WBBackupSet        # Lister les sauvegardes disponibles
```

---

### 📐 Calculs de planification :

- **Fréquence classique** : 1 complète/semaine + 1 incrémentale/jour
- **Péremption standard** : Quotidiennes 7j → Hebdo 1-2 mois → Mensuelles 1-2 ans
- **RPO (Recovery Point Objective)** : Perte de données maximale acceptable = intervalle entre sauvegardes

**Exemple concret :**

```
Activité : Base de données critique
RPO souhaité : 1h max de perte
Solution : Sauvegarde incrémentale toutes les heures + complète quotidienne
Stockage : Disque local + réplication cloud chiffrée
```

---

### ⚠️ Pièges à éviter :

- ❌ **Confiance aveugle** : Ne JAMAIS supposer que les sauvegardes fonctionnent → tester la restauration régulièrement
- ❌ **Copie unique sur-site** : Vulnérable au sinistre physique (incendie, inondation, ransomware si en ligne)
- ❌ **Clés de chiffrement perdues** : Sauvegarde chiffrée = irrécupérable sans la clé → backup sécurisé des clés obligatoire
- ❌ **Impact production ignoré** : Sauvegardes saturent disques/réseau → planifier en heures creuses (nuit)
- ❌ **Catalogue absent** : Impossible de savoir quelle sauvegarde contient quel fichier → documenter

---

### ✅ Bonnes pratiques :

- ✅ **Vérification automatisée** : Scripts de contrôle d'intégrité (checksums) et alertes si échec
- ✅ **Entraînement restauration** : Simuler des pannes et chronométrer la remise en prod (valider le PRA)
- ✅ **Hors-ligne + hors-site** : Bandes/disques déconnectés du réseau + copie géographiquement distante
- ✅ **Compression systématique** : gzip/zstd réduit l'espace de 50-80% selon le type de données
- ✅ **Snapshots pour cohérence** : LVM/ZFS snapshot avant sauvegarde pour état figé (BDD, VMs)

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**PRA**|Plan Reprise Activité : procédures pour restaurer le SI après incident majeur|
|**PCA**|Plan Continuité Activité : maintenir l'activité pendant l'incident (redondance)|
|**Catalogue**|Index des fichiers sauvegardés par date/support pour restauration sélective|
|**Snapshot**|Image instantanée d'un système de fichiers à un instant T (non modifiable)|
|**Péremption**|Durée de conservation d'une sauvegarde avant suppression automatique|
|**LTO**|Linear Tape-Open : standard de bandes magnétiques (LTO-9 = 18To natif)|
|**Déduplication**|Élimination des données redondantes (même bloc = 1 seule copie)|

---

### ⏱️ Obligations légales (France) :

|Type de données|Durée minimale|Source|
|---|---|---|
|**Comptabilité**|10 ans|Code commerce|
|**Factures/Contrats**|5 ans|Code civil|
|**Logs de connexion**|6-12 mois|CNIL/LPM|
|**Données personnelles (RGPD)**|Durée de finalité uniquement|CNIL|

⚠️ **Archivage ≠ Sauvegarde** : l'archivage supprime les données de prod après copie.

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Règle 3-2-1** : 3 copies / 2 supports / 1 hors-site (non négociable)
2. 💻 **Tester la restauration** : Une sauvegarde non testée = pas de sauvegarde (drill mensuel minimum)
3. ⚠️ **Hors-ligne contre ransomware** : Copie déconnectée du réseau obligatoire (bande/disque externe démonté)

---

### 🔧 Checklist rapide opérationnelle :

```
☐ Politique écrite (quoi, quand, où, combien de temps)
☐ Automatisation des sauvegardes (cron/tâches planifiées)
☐ Alertes en cas d'échec (mail/monitoring)
☐ Test restauration mensuel documenté
☐ Copie hors-site synchronisée
☐ Chiffrement activé si cloud/externe
☐ Gestion des clés sécurisée
☐ Documentation à jour (procédures de restauration)
```