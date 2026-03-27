## ⚡ L'essentiel en 5 minutes - Suivi des Incidents (ITIL)

### 📌 C'est quoi en 2 lignes ?

Méthodologie ITIL pour gérer efficacement les incidents informatiques (pannes, dysfonctionnements) et les problèmes (causes racines) en suivant une procédure structurée en 8 étapes, de la détection à la clôture. Objectif : minimiser l'impact sur l'entreprise, réduire les temps d'arrêt et documenter les solutions.

---

### 💡 Concepts clés à retenir :

- **ITIL** : Framework de bonnes pratiques pour la gestion des services IT (ITSM = IT Service Management)
- **Incident** : Événement imprévu qui perturbe/diminue le fonctionnement du SI → baisse de la QoS (Quality of Service)
- **Problème** : Cause inconnue d'un ou plusieurs incidents → Incident = effet / Problème = cause
- **Criticité** : Combinaison Gravité × Impact → détermine la priorité de traitement (Mineur/Majeur/Critique)
- **SLA** : Service Level Agreement = contrat définissant les niveaux de service attendus (temps réponse, disponibilité, qualité)

---

### 📋 Procédure de gestion des incidents (8 étapes) :

```
1. IDENTIFICATION/DÉTECTION
   → Détection manuelle (utilisateur) ou automatique (supervision)
   → Distinguer incident / demande de service / demande d'info

2. NOTIFICATION
   → Signalement au support : téléphone, mail, SMS, outil ticketing, face-à-face
   → Inclure : état actuel, détails, type d'incident

3. ENREGISTREMENT
   → Création du ticket dans la BDD (formulaire web ou logiciel)

4. CATÉGORISATION ET PRIORISATION
   → Gravité : Faible / Normal / Urgent / Critique
   → Impact : Utilisateur / Service / Site / Entreprise
   → Priorité résultante : Mineur / Majeur / Critique

5. DIAGNOSTIC ET INVESTIGATION
   → Analyser la situation pour comprendre la cause
   → Utiliser : logs, outils diagnostic, entretiens utilisateurs

6. SUIVI (ou ESCALADE)
   → Pour résolutions longues : relances intervenant/prestataire
   → Escalade N1 → N2 → N3 si nécessaire

7. RÉSOLUTION ET DOCUMENTATION
   → Mise en œuvre des actions correctives
   → DOCUMENTER : wiki, FAQ, base de connaissances
   → COMMUNIQUER : informer les utilisateurs

8. CLÔTURE
   → Confirmation que le service est restauré
   → Validation satisfaction utilisateurs
```

---

### 👥 Niveaux de support :

|Niveau|Rôle|Actions|
|---|---|---|
|**N0**|Enregistrement|Catégorisation seulement|
|**N1**|Support initial|Priorisation + résolution via procédures|
|**N2**|Support avancé|Analyse + résolution complexe + suivi|
|**N3**|Expertise|Analyse approfondie + expertise technique + suivi|

---

### 🎯 Matrice de priorisation (Gravité × Impact) :

```
                    IMPACT
           Utilisateur | Service | Site | Entreprise
Faible        🟢          🟢       🟡        🟡
Normal        🟢          🟡       🟡        🟡
Urgent        🟡          🟡       🔴        🔴
Critique      🟡          🔴       🔴        🔴

🟢 = Priorité MINEUR (résolution différée)
🟡 = Priorité MAJEUR (intervention rapide)
🔴 = Priorité CRITIQUE (procédure de crise)
```

**Définitions Gravité** :

- **Faible** : utilisateur peut continuer, peu gênant
- **Normal** : gênant mais travail possible, solution de contournement
- **Urgent** : utilisateur bloqué
- **Critique** : utilisateur ne peut plus travailler

---

### 🔍 Démarche de diagnostic (5 étapes) :

```
1. RECUEIL D'INFORMATIONS
   → Entretiens utilisateurs
   → Logs système/application
   → Outils de supervision
   → Outils de diagnostic (Wireshark, SolarWinds, PRTG...)

2. ANALYSE DES INFORMATIONS
   → Analyse de la chaîne de valeur (décomposer le système, ex: modèle OSI)
   → Analyse de la cause première (diagramme d'Ishikawa)

3. TEST DES HYPOTHÈSES
   → Test de régression (vérifier que modif n'a pas cassé autre chose)
   → Test de charge (performance sous forte utilisation)
   → Test de sécurité (détecter failles)

4. DÉTERMINATION DE LA CAUSE
   → Utiliser résultats tests + infos pour identifier cause EXACTE
   → ⚠️ Précision cruciale (sinon actions inappropriées + récurrence)

5. PLANIFICATION DE LA RÉSOLUTION
   → Priorité incident + Disponibilité ressources + Impact utilisateurs
```

---

### ⚠️ Pièges à éviter :

- ❌ **Confondre incident et demande de service** : Un incident perturbe le fonctionnement normal, une demande de service est prévisible (création compte, reset mot de passe)
- ❌ **Agir sans diagnostic précis** : Remplacer du matériel alors que c'est un problème de configuration → coûts inutiles + incident persiste
- ❌ **Ne pas documenter** : Même incident se reproduit, pas de capitalisation des solutions
- ❌ **Oublier la communication** : Utilisateurs non informés, insatisfaction même si incident résolu
- ❌ **Ignorer la matrice de priorisation** : Traiter incidents mineurs avant les critiques → perte de temps, impact métier

---

### ✅ Bonnes pratiques :

- ✅ **Toujours suivre la procédure en 8 étapes** : Structure = efficacité + traçabilité
- ✅ **Catégoriser ET prioriser systématiquement** : Gérer l'urgence sans négliger l'important
- ✅ **Documenter chaque résolution** : Wiki/FAQ/base de connaissances = gain de temps futur
- ✅ **Communiquer proactivement** : Informer de l'avancement même si non résolu = confiance utilisateurs
- ✅ **Tester les hypothèses avant d'agir** : Éviter les actions inappropriées coûteuses
- ✅ **Utiliser le CMDB** : Base de données de configuration = info contexte pour diagnostic

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**ITIL**|Information Technology Infrastructure Library = framework ITSM|
|**ITSM**|IT Service Management = gestion des services informatiques|
|**Incident**|Événement imprévu perturbant le SI (effet)|
|**Problème**|Cause inconnue d'un ou plusieurs incidents (cause)|
|**QoS**|Quality of Service = qualité de service|
|**SLA**|Service Level Agreement = contrat de niveau de service|
|**CMDB**|Configuration Management Database = BDD des configurations IT|
|**Ticket**|Enregistrement formalisé d'un incident dans l'outil de gestion|
|**Escalade**|Transfert de l'incident vers un niveau de support supérieur|
|**Solution de contournement**|Solution temporaire permettant de travailler malgré l'incident|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : **Incident ≠ Problème** → Incident = symptôme (effet), Problème = maladie (cause). Un problème peut générer plusieurs incidents.
2. 💻 **Pratique** : **Procédure en 8 étapes OBLIGATOIRE** → Détection → Notification → Enregistrement → Catégorisation → Diagnostic → Suivi → Résolution → Clôture (avec documentation à chaque étape).
3. ⚠️ **Piège** : **Ne JAMAIS agir sans diagnostic précis** → Exemple classique : remplacer carte réseau alors que c'est la config routeur → coûts inutiles + incident persiste + perte de confiance.

---

**💡 Astuce terrain** : En cas de doute sur la priorité, poser la question : _"Si je ne traite pas cet incident maintenant, combien de personnes ne peuvent plus travailler et pendant combien de temps ?"_ → La réponse donne la criticité réelle.