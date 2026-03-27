## 1. Le Pare-feu (Firewall)

**Définition** : Nœud placé à l'intersection de réseaux (en coupure) qui filtre les paquets selon des règles définies.

- Opère **au minimum au niveau 4** (Transport) du modèle OSI
- Associé à des fonctions de **routage**
- Objectif : connectivité **contrôlée** entre réseaux de niveaux de confiance différents

**Actions possibles sur un paquet :**

|Action|Effet|
|---|---|
|`ACCEPT`|Le paquet passe|
|`DROP`|Le paquet est silencieusement ignoré|
|`REJECT`|Le paquet est refusé avec notification|

---

## 2. Sécurisation Réseau

### Pourquoi filtrer ?

- Tous les systèmes ont des **failles de sécurité**
- Les configurations par défaut sont souvent insuffisantes
- De nombreux services inutiles sont actifs par défaut

### Politique de filtrage

|Approche|Principe|Recommandée ?|
|---|---|---|
|**Liste de blocage**|Bloquer ce qui est connu comme dangereux|❌ Non|
|**Liste d'autorisation**|`deny all` + autoriser uniquement le légitime|✅ Oui|

### Défense en profondeur

- Ne **jamais** faire confiance aveuglément à une seule défense
- Combiner défense **périmétrique** + sécurité **interne**

---

## 3. Architecture Réseau & Zones

### Zones de confiance

Segmentation du réseau en groupes de machines ayant les **mêmes besoins en sécurité**.

- Séparation physique ou via **VLAN**
- Filtrage défini par une **matrice des flux**

### DMZ — _DeMilitarized Zone_

- Héberge les serveurs accessibles depuis l'extérieur (web, mail…)
- Surveillance et filtrage renforcés
- **Point d'entrée potentiel** dans le réseau → à surveiller de près

### Exemple de zones typiques

```
Internet → [FIREWALL] → DMZ (web, mail)
                      → Utilisateurs
                      → Serveurs internes
                      → Administration
                      → Wifi / Visiteurs
```

---

## 4. Types de Pare-feux

### Pare-feu sans état _(Stateless)_

- Filtre paquet par paquet, **sans mémoire**
- Critères : IP source/dest, ports, protocoles
- ✅ Rapide | ❌ Règles nombreuses, pas de contexte

### Pare-feu à états _(Stateful)_

- Suit les **connexions TCP** et vérifie la cohérence des paquets
- Autorise implicitement les réponses aux connexions établies
- ✅ Filtrage plus fin, règles allégées | ❌ Plus gourmand en ressources

### Pare-feu applicatif _(DPI — Deep Packet Inspection)_

- Analyse **l'intégralité** de la pile protocolaire jusqu'aux données
- Vérifie la conformité avec le protocole applicatif
- ✅ Filtrage de protocoles complexes (ex : FTP) | ❌ Inefficace en cas de **chiffrement de bout en bout**
- Variante spécialisée : **WAF** (_Web Application Firewall_) → HTTP/HTTPS

### Pare-feu personnel

- Logiciel sur une **machine unique**
- ✅ Filtrage interactif | ❌ Moins sûr (service parmi d'autres)

---

## 5. Ports & Protocoles Clés

|Protocole|Port|Usage|
|---|---|---|
|HTTP|80/TCP|Web non chiffré|
|HTTPS|443/TCP|Web chiffré (TLS)|
|FTP|20-21/TCP|Transfert de fichiers (difficile à filtrer)|
|SSH|22/TCP|Accès distant sécurisé|
|SMTP|25/TCP|Envoi de mails|
|DNS|53/UDP-TCP|Résolution de noms|
|IMAP|143/TCP|Réception mails|
|IMAPS|993/TCP|Réception mails chiffrée|
|RDP|3389/TCP|Bureau à distance Windows|
|ICMP|—|Ping / diagnostics réseau|

**Protocoles de transport surveillés :**

- **TCP** — orienté connexion, suivi d'état possible
- **UDP** — sans connexion, plus difficile à filtrer

---

## 6. Solutions Entreprise

|Solution|Points forts|Idéal pour|
|---|---|---|
|**Check Point**|Pionnier stateful, ThreatCloud AI|Grands comptes, conformité|
|**Fortinet (FortiGate)**|Rapport qualité/prix, Security Fabric|PME/ETI, multi-sites|
|**Cisco ASA + FirePower**|Intégration native Cisco, fiabilité|Environnements Cisco existants|
|**Palo Alto**|App-ID, WildFire, visibilité applicative|Protection zero-day|

---

## 7. À retenir

> 💡 La cybersécurité moderne ne se résume pas à un seul firewall. Elle repose sur une approche **"Security by Design & Resilience by Default"** : segmentation, Zero Trust, contrôle des accès privilégiés, détection & réponse.