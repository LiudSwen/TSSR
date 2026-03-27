## 1. Concepts fondamentaux

|Concept|Définition|
|---|---|
|**Sauvegarde**|Copie des données sur un autre support pour les récupérer en cas d'incident|
|**Archivage**|Conservation de données inactives pour un usage futur (copie + suppression de la prod)|
|**PRA**|Plan de Reprise d'Activité — comment rétablir le SI après un incident|
|**PCA**|Plan de Continuité d'Activité — comment maintenir le SI pendant un incident|

---

## 2. Types de sauvegardes

|Type|Contenu sauvegardé|Avantage|Inconvénient|
|---|---|---|---|
|**Complète**|Toutes les données|Restauration simple|Lente, gourmande en stockage|
|**Incrémentale**|Modifs depuis la dernière sauvegarde (quelle qu'elle soit)|Rapide, légère|Restauration complexe|
|**Différentielle**|Modifs depuis la dernière **complète**|Compromis|Taille croissante|

> **Pratique classique :** 1 complète/semaine + 1 incrémentale/jour

---

## 3. La règle du 3-2-1

```
3 copies  → 1 prod + 2 sauvegardes
2 supports → 2 types de supports différents
1 hors-site → 1 copie délocalisée (cloud, autre site...)
```

- **Hors-ligne** → protection contre ransomwares
- **Hors-site** → protection contre sinistres (incendie, inondation)

---

## 4. Supports de sauvegarde

|Catégorie|Exemples|
|---|---|
|Disques locaux|Autre disque du même serveur, NAS|
|Serveur distant|Autre serveur, autre site|
|Amovibles|Bandes LTO, disques durs externes, disques optiques|
|Cloud|Prestataire externe (chiffrement obligatoire !)|

---

## 5. Paramètres clés d'une politique de sauvegarde

- **Fréquence** : compromis entre fraîcheur des données, espace et impact sur la prod
- **Péremption** : durée de rétention minimale → jusqu'à la prochaine complète
    - Exemple : hebdomadaires gardées 1-2 mois, mensuelles 1-2 ans
- **Planification** : idéalement la nuit (creux d'utilisation)
- **Compression** : réduit le stockage, légère hausse CPU
- **Chiffrement** : obligatoire pour les sauvegardes externalisées

---

## 6. Archivage — Points spécifiques

- Données copiées **et supprimées** de la prod (≠ sauvegarde)
- Contraintes particulières :
    - Supports adaptés à la **longue durée**
    - Risque d'obsolescence des formats de fichiers
    - Vérification d'intégrité (hash)
    - Indexation pour la recherche

### Durées légales de conservation (France)

|Donnée|Durée|
|---|---|
|Données comptables|10 ans|
|Contrats & factures|5 ans|
|Journaux de connexion|6 mois à 1 an|
|Données personnelles|Conformité RGPD|

---

## 7. Restauration

- **Complète** : en cas de crash total
- **Partielle** : récupérer un fichier spécifique dans une version ancienne
- Nécessite un **catalogue** pour localiser chaque fichier dans les sauvegardes
- **Clonage** : image complète d'une machine → reprise plus rapide (simplifié avec les VMs)

---

## 8. Outils libres courants

|Outil|Usage|
|---|---|
|**Bacula / Bareos**|Solution complète client-serveur|
|**Amanda**|Sauvegarde réseau|
|**Borg**|Sauvegarde dédupliquée et chiffrée|
|**Clonezilla**|Clonage de disques/partitions|

---

## ⚠️ Points essentiels à retenir

> - Une sauvegarde non testée n'est **pas** une sauvegarde fiable
> - **S'entraîner** régulièrement à restaurer
> - Les sauvegardes ont les **mêmes contraintes de sécurité** que la prod
> - Ne pas confondre **sauvegarde** (copie temporaire) et **archivage** (conservation longue durée)