## ⚡ L'essentiel en 5 minutes - La Supervision Réseau

### 📌 C'est quoi en 2 lignes ?

La supervision est la surveillance automatisée du bon fonctionnement d'un système ou réseau via des protocoles (SNMP, NetFlow, Syslog). Elle permet de détecter pannes, incidents, saturation et activités suspectes en temps réel pour maintenir la disponibilité des services.

---

### 💡 Concepts clés à retenir :

- **Supervision** : Surveillance automatisée du fonctionnement d'une infrastructure (matériels, services, performances)
- **Hypervision** : Centralisation de plusieurs systèmes de supervision en console unique
- **Agent** : Programme installé sur les équipements supervisés qui collecte et transmet les données
- **MCO (Maintien en Condition Opérationnelle)** : Ensemble des actions pour garantir la disponibilité d'un système
- **Sonde/Sniffeur** : Outil d'analyse de flux réseau en temps réel pour identifier les saturations

---

### 💻 Protocoles et syntaxes essentiels :

```bash
# 🌐 SNMP (Simple Network Management Protocol)
GET      # Demander des informations à un agent SNMP
SET      # Modifier configuration/comportement d'un équipement (ports, paramètres)
TRAP     # Signalement automatique d'événements spéciaux par l'équipement

# Versions SNMP
SNMPv1   # Version basique, peu sécurisée
SNMPv2c  # Amélioration des performances
SNMPv3   # Version sécurisée (authentification, chiffrement) → À PRIVILÉGIER
```

```bash
# 📊 MIB/OID (Management Information Base / Object Identifier)
MIB      # Base de données locale sur chaque équipement (infos disponibles)
OID      # Identifiant unique universel sous forme d'arborescence (ex: 1.3.6.1.2.1.1.5)

# Exemple OID pour récupérer le nom d'un équipement
snmpget -v3 -l authPriv -u admin IP_DEVICE 1.3.6.1.2.1.1.5.0
```

```bash
# 🔍 Autres protocoles complémentaires
NetFlow  # Protocole Cisco pour analyser le trafic IP (routeurs/switches)
ICMP     # Vérification de disponibilité (ping, traceroute)
WMI      # Windows Management Instrumentation (supervision Windows)
Syslog   # Collecte centralisée des logs système
```

---

### 📐 Types de supervision :

- **Analyse de flux** : Surveillance activité réseau temps réel → identifier liaisons saturées et origine
- **Supervision réseau/système** : État matériels, débits, température, ports, CPU, RAM via SNMP + agents
- **Supervision applicative** : Disponibilité des services du point de vue utilisateur (FTP ouvert ? Web répond ?)

**Différence critique :**

```
Supervision réseau : "Le serveur est allumé et le réseau fonctionne"
Supervision applicative : "Le service web répond bien à la requête utilisateur"
→ Les deux sont nécessaires : un serveur UP ne garantit pas un service fonctionnel !
```

---

### ⚠️ Pièges à éviter :

- ❌ **Utiliser SNMPv1/v2c en production** : Absence de chiffrement → mots de passe en clair, risques de sécurité majeurs
- ❌ **Se limiter à la supervision réseau** : Un lien réseau UP ne signifie pas que le service applicatif fonctionne (ex: Apache planté)
- ❌ **Négliger les OID personnalisés** : Les constructeurs ajoutent des MIB propriétaires → toujours vérifier la documentation constructeur
- ❌ **Confondre supervision et journalisation** : Les logs donnent l'historique, la supervision donne l'état actuel + alertes proactives

---

### ✅ Bonnes pratiques :

- ✅ **Toujours utiliser SNMPv3** : Authentification forte + chiffrement des communications sensibles
- ✅ **Combiner les types de supervision** : Flux + Réseau + Applicatif = vision complète de l'infrastructure
- ✅ **Définir des seuils d'alerte pertinents** : CPU > 80%, disque > 90%, latence > 200ms → adapter au contexte métier
- ✅ **Documenter les OID critiques** : Créer un référentiel des OID utilisés par équipement (gain de temps en dépannage)
- ✅ **Centraliser avec hypervision** : Pour infrastructures complexes, éviter la multiplication des outils de supervision

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**MIB**|Base de données locale des infos qu'un équipement peut envoyer (structure arborescente)|
|**OID**|Identifiant numérique unique et universel d'un objet dans la MIB (ex: 1.3.6.1.2.1.1.1)|
|**TRAP SNMP**|Notification automatique envoyée par l'équipement en cas d'événement (proactif)|
|**Agent**|Logiciel sur l'équipement supervisé qui répond aux requêtes SNMP et collecte données|
|**Collecteur/Sonde**|Outil qui interroge les agents et centralise les données (serveur de supervision)|
|**NetFlow**|Protocole Cisco d'analyse de trafic IP (source, destination, volume, protocoles)|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : SNMP = protocole CENTRAL de supervision (GET pour lire, SET pour modifier, TRAP pour alerter) + SNMPv3 obligatoire
2. 💻 **Pratique** : MIB + OID = système universel d'identification des données supervisées → toujours vérifier les OID constructeur
3. ⚠️ **Piège** : Supervision réseau ≠ supervision applicative → un réseau UP n'assure pas qu'un service fonctionne (ex: MySQL planté)

---

### 🛠️ Logiciels de supervision courants :

**Open Source (gratuit) :**

- **Nagios** : Référence historique, supervision réseau/système/applicatif
- **Zabbix** : Interface moderne, scalable, supporte SNMP/agents/API

**Propriétaires (payants) :**

- **PRTG** : Interface intuitive, idéal PME, licence par capteurs
- **SolarWinds** : Suite complète entreprise, NetFlow expert
- **Nexthink** : Focus supervision poste de travail utilisateur final