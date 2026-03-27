## ⚡ L'essentiel en 5 minutes - Filtrage Réseau (Firewalls)

### 📌 C'est quoi en 2 lignes ?

Un **pare-feu (firewall)** est un nœud placé à l'intersection de réseaux qui contrôle et filtre les paquets selon des règles de sécurité. Son objectif est de fournir une **connectivité contrôlée et maîtrisée** entre des réseaux de différents niveaux de confiance (Internet ↔ réseau interne).

---

### 💡 Concepts clés à retenir :

- **Niveau OSI 4 minimum** : Le firewall travaille au moins au niveau Transport (TCP/UDP) pour filtrer les paquets
- **Filtrage en coupure** : Positionné entre réseaux, il inspecte le trafic entrant/sortant/traversant
- **Actions possibles** : Accept (autoriser), Drop (rejeter silencieusement), Reject (rejeter avec notification)
- **Défense en profondeur** : Ne jamais faire aveuglément confiance à une seule couche de sécurité
- **Deny all / Allow by exception** : Politique recommandée = tout bloquer par défaut, n'autoriser que le légitime

---

### 🏗️ Architecture réseau sécurisée :

**Zones de confiance :**

- Segmentation logique/physique du réseau (VLAN ou câblage séparé)
- Regroupement des nœuds ayant les mêmes besoins en sécurité
- Filtrage appliqué **entre** zones (matrice des flux)
- Exemples : Zone Utilisateurs, Zone Serveurs, Zone Administration

**DMZ (DeMilitarized Zone) :**

- Zone spéciale pour services accessibles depuis l'extérieur (Web, Mail, DNS publics)
- **Double filtrage** : entre Internet↔DMZ ET DMZ↔réseau interne
- Point d'entrée potentiel → surveillance renforcée
- Principe : si la DMZ est compromise, le réseau interne reste protégé

---

### 🛡️ Types de pare-feux (du plus simple au plus avancé) :

| Type                      | Fonctionnement                                                         | Avantages                                                 | Limites                                                     |
| ------------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------- | ----------------------------------------------------------- |
| **Stateless (sans état)** | Règles simples sur en-têtes IP/TCP/UDP (IP src/dst, ports, protocole)  | ⚡ Rapide, efficace, peu de ressources                     | ⚠️ Chaque paquet traité indépendamment, règles complexes    |
| **Stateful (à états)**    | Suivi des connexions TCP, validation dans le contexte                  | ✅ Autorisation implicite des réponses, règles simplifiées | 🧠 Consomme mémoire/CPU                                     |
| **Applicatif (DPI)**      | Deep Packet Inspection : analyse complète de la pile jusqu'aux données | 🔍 Filtrage protocoles complexes (FTP), détection contenu | ❌ Impossible si chiffrement bout-en-bout, gourmand          |
| **Personnel**             | Logiciel sur l'OS (Windows Defender, iptables local)                   | 🖥️ Filtrage interactif par machine                       | ⚠️ Moins fiable (compromission OS = compromission firewall) |

**Spécialisation DPI :** WAF (Web Application Firewall) = pare-feu applicatif spécialisé HTTP/HTTPS

---

### 📐 Politique de filtrage :

**Approche recommandée (liste d'autorisation) :**

```
1. DENY ALL (tout bloquer par défaut)
2. ALLOW légitime (autoriser uniquement le trafic métier nécessaire)
3. LOG (journaliser les tentatives de connexion)
```

**Approche déconseillée (liste de blocage) :**

```
❌ ALLOW ALL (tout autoriser par défaut)
❌ DENY malveillant (bloquer les menaces connues)
→ Oubli fréquent, peu d'alertes en cas d'échec
```

---

### ⚠️ Pièges à éviter :

- ❌ **Confiance aveugle** : Un firewall seul ne suffit pas → défense périmétrique + défense en profondeur
- ❌ **Règles trop permissives** : "ANY ANY ALLOW" annule toute sécurité
- ❌ **Oublier les flux de retour** : Avec un pare-feu stateless, il faut autoriser les réponses manuellement
- ❌ **DMZ mal segmentée** : Si la DMZ peut accéder librement au réseau interne, elle ne sert à rien
- ❌ **Négliger les logs** : Sans surveillance des logs firewall, impossible de détecter les attaques

---

### ✅ Bonnes pratiques :

- ✅ **Deny all / Allow by exception** : Politique de base de toute sécurité réseau
- ✅ **Segmentation réseau** : Créer des zones de confiance (Utilisateurs, Serveurs, Admin, DMZ, Invités)
- ✅ **Matrice des flux** : Documenter les communications légitimes entre chaque zone
- ✅ **Logging et monitoring** : Journaliser tous les refus et alerter sur les anomalies
- ✅ **Mise à jour régulière** : Règles de filtrage, signatures antivirus/IPS, firmware
- ✅ **Défense en profondeur** : Firewall périmétrique + firewalls internes + pare-feux personnels + segmentation VLAN

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Stateful Inspection**|Suivi des connexions TCP (mémorisation des sessions légitimes)|
|**DPI (Deep Packet Inspection)**|Analyse complète du paquet jusqu'au contenu applicatif|
|**DMZ**|Zone démilitarisée : réseau intermédiaire entre Internet et LAN interne|
|**Drop vs Reject**|Drop = silence total / Reject = notification de refus (peut aider au debug)|
|**Zone de confiance**|Segment réseau regroupant des équipements de même niveau de sécurité|
|**Matrice des flux**|Tableau définissant les communications autorisées entre zones|
|**WAF**|Web Application Firewall : pare-feu applicatif spécialisé HTTP/HTTPS|
|**NGFW**|Next-Gen Firewall : firewall + IPS + antivirus + filtrage URL + contrôle applicatif|

---

### 🏢 Solutions entreprise (sélection) :

|Éditeur|Points forts|Cas d'usage idéal|
|---|---|---|
|**Check Point**|Expertise historique (pionnier), gestion unifiée (R80), IA globale (ThreatCloud)|Grands comptes, conformité stricte|
|**Fortinet (FortiGate)**|Meilleur rapport perf/prix, suite unifiée (Security Fabric)|PME/ETI, multi-sites|
|**Cisco ASA/FirePower**|Intégration native avec infra Cisco, fiabilité éprouvée|Environnements Cisco existants|
|**Palo Alto Networks**|Contrôle applicatif fin (App-ID), sandbox cloud (WildFire)|Visibilité applicative, protection zero-day|

**Critères de choix :**

- Complexité infrastructure / Intégration existant
- Budget / Performance nécessaire
- Compétences internes / Support éditeur
- Orientation Cloud/Hybride

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Politique "Deny all / Allow by exception" + Défense en profondeur = piliers de la sécurité réseau
2. 🏗️ **Pratique** : DMZ = zone tampon entre Internet et réseau interne (double filtrage obligatoire)
3. ⚠️ **Piège** : Un firewall sans logs/monitoring = faux sentiment de sécurité (attaques invisibles)

---

**🔑 Principe d'architecture moderne :**

```
Security by Design & Resilience by Default
↓
Résister → Détecter → Contenir → Se relever
```

La cybersécurité ne se résume plus à un pare-feu : c'est une **architecture globale** (firewalls multiples + IDS/IPS + antivirus + SIEM + segmentation + authentification forte + sauvegardes + plan de continuité).