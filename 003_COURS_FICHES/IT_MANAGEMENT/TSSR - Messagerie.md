## ⚡ L'essentiel en 5 minutes - Messagerie électronique

### 📌 C'est quoi en 2 lignes ?

Système de communication **asynchrone** (différé) utilisant le protocole SMTP pour envoyer et POP3/IMAP pour recevoir des emails. Architecture client/serveur avec agents spécialisés (MUA, MTA, MDA) et résolution DNS via enregistrements MX.

---

### 💡 Concepts clés à retenir :

- **Adresse email** : `partie_locale@domaine` (ex: bob@entreprise.fr) - RFC 5322
- **BAL (Boîte Aux Lettres)** : Espace de stockage des emails, identifié par l'adresse email
- **Email** : Composé d'un **en-tête** (expéditeur, destinataire, objet, date) + **corps** (texte/HTML)
- **MX Record** : Enregistrement DNS indiquant les serveurs de messagerie d'un domaine (ex: `MX10 mail.domain.fr`)
- **Client lourd** : Logiciel installé (Outlook, Thunderbird) vs **Webmail** : Interface web (Gmail, Roundcube)

---

### 💻 Architecture et agents :

```
📧 ENVOI D'EMAIL (Bob → Alice)
┌─────────────────────────────────────────────────────────────┐
│ Bob@domaine1.fr                                             │
│   ↓ rédaction                                               │
│ MUA (Mail User Agent) ← Client de messagerie               │
│   ↓ SMTP                                                    │
│ MSA (Mail Submission Agent) ← Vérifie contenu              │
│   ↓ SMTP                                                    │
│ MTA (Mail Transfer Agent) ← Serveur SMTP domaine1.fr       │
│   ↓ DNS query (MX de domaine2.fr)                          │
│ DNS Server → Retourne IP du serveur mail domaine2.fr       │
│   ↓ SMTP                                                    │
│ MTA domaine2.fr ← Vérifie que alice@domaine2.fr existe     │
│   ↓                                                         │
│ MDA (Mail Delivery Agent) ← Place email dans BAL Alice     │
│   ↓ POP3 ou IMAP                                            │
│ MUA Alice ← Consulte ses emails                            │
│ Alice@domaine2.fr                                           │
└─────────────────────────────────────────────────────────────┘
```

---

### 💻 Protocoles et ports :

|Protocole|Port|Fonction|Sécurisé|
|---|---|---|---|
|**SMTP**|25|Envoi/Transfert emails entre serveurs|Non|
|**SMTP**|465/587|Envoi avec chiffrement|Oui (TLS/SSL)|
|**POP3**|110|Réception simple (téléchargement)|Non|
|**IMAP**|143|Réception avancée (synchronisation)|Non|

---

### 🆚 POP3 vs IMAP :

|Critère|POP3|IMAP|
|---|---|---|
|**Fonctionnement**|Télécharge emails → supprime serveur|Synchronise client ↔ serveur|
|**Multi-postes**|❌ (emails sur 1 seul appareil)|✅ (mêmes emails partout)|
|**Gestion**|Basique (lecture, suppression)|Avancée (dossiers, flags, recherche)|
|**Stockage**|Local uniquement|Local + Serveur|
|**Usage**|Mono-poste, connexion stable|Multi-postes, mobilité|
|**Hors ligne**|✅ (après téléchargement)|⚠️ (synchronisation nécessaire)|

**Exemple POP3 :**

```
Serveur → [Email 1, Email 2, Email 3]
         ↓ téléchargement sur PC
PC     → [Email 1, Email 2, Email 3]
Serveur → [vide ou marqué comme lu]
Mobile → [rien] ❌
```

**Exemple IMAP :**

```
Serveur → [Email 1, Email 2, Email 3]
         ↕ synchronisation
PC     → [Email 1, Email 2, Email 3] ✅
Mobile → [Email 1, Email 2, Email 3] ✅
```

---

### ⚠️ Pièges à éviter :

- ❌ **Confondre serveur SMTP et POP/IMAP** : SMTP = envoi | POP/IMAP = réception
- ❌ **Utiliser POP3 en multi-postes** : Les emails téléchargés disparaissent du serveur
- ❌ **Oublier le MX record DNS** : Sans MX, impossible de recevoir des emails
- ❌ **Saturer la BAL** : Quotas dépassés = refus de nouveaux emails
- ❌ **Envoyer infos sensibles en clair** : Email non chiffré = lisible en transit

---

### ✅ Bonnes pratiques :

- ✅ **IMAP pour usage professionnel** : Synchronisation multi-appareils + sauvegarde serveur
- ✅ **Trier régulièrement** : Dossiers (travail, archivage, personnel) + suppression emails inutiles
- ✅ **Sécuriser le compte** : Mot de passe fort + 2FA (authentification double facteur)
- ✅ **Vérifier avant d'agir** : Expéditeur, destinataires, pièces jointes, liens suspects
- ✅ **Séparer pro/perso** : Adresse professionnelle pour communications d'entreprise uniquement
- ✅ **Sauvegarder emails importants** : Export local régulier (format .pst, .mbox, etc.)

---

### 📚 Vocabulaire technique :

|Terme|Définition|
|---|---|
|**MUA**|Mail User Agent - Client de messagerie (Outlook, Thunderbird)|
|**MSA**|Mail Submission Agent - Réceptionne emails du client, vérifie contenu|
|**MTA**|Mail Transfer Agent - Serveur SMTP qui transfère emails entre domaines|
|**MDA**|Mail Delivery Agent - Livre emails dans les boîtes aux lettres|
|**MX Record**|Enregistrement DNS indiquant le serveur de messagerie d'un domaine|
|**RFC 5322**|Standard définissant le format des adresses et messages email|
|**Webmail**|Interface de messagerie accessible via navigateur web|
|**BAL partagée**|Boîte aux lettres accessible par plusieurs utilisateurs (RW)|
|**Arobase (@)**|Symbole séparant identifiant et domaine (signifie "chez")|
|**On-premises**|Serveur de messagerie hébergé localement (vs Cloud)|

---

### 🔧 Diagnostic rapide :

```bash
# 🌐 Vérifier les enregistrements MX d'un domaine
nslookup -type=MX domaine.fr
dig MX domaine.fr

# 🌐 Tester la connexion SMTP
telnet mail.domaine.fr 25
# ou
nc -vz mail.domaine.fr 25

# 🌐 Tester la connexion POP3
telnet mail.domaine.fr 110

# 🌐 Tester la connexion IMAP
telnet mail.domaine.fr 143

# 🪟 Windows - Tester port SMTP
Test-NetConnection -ComputerName mail.domaine.fr -Port 25
```

**Exemple diagnostic MX :**

```
$ dig MX google.com
google.com.  3599  IN  MX  10 smtp.google.com.
                   ↑       ↑   ↑
                priorité  type  serveur mail
```

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Architecture** : MUA (client) → MSA/MTA (SMTP envoi) → DNS (MX lookup) → MTA destinataire → MDA → BAL → MUA (POP/IMAP réception)
    
2. 💻 **Protocoles** : SMTP port 25/587 (envoi) | POP3 port 110 (réception simple) | IMAP port 143 (réception synchronisée)
    
3. ⚠️ **Choix critique** : POP3 = mono-poste, téléchargement destructif | IMAP = multi-postes, synchronisation serveur (toujours préférer IMAP en entreprise)
    

---

### 🔐 Checklist sécurité :

- [ ] Mot de passe ≥12 caractères + 2FA activé
- [ ] Vérification systématique expéditeur avant ouverture
- [ ] Analyse pièces jointes avec antivirus
- [ ] Survol liens (sans cliquer) pour vérifier URL réelle
- [ ] Pas d'infos confidentielles/sensibles par email
- [ ] Tri BAL hebdomadaire (suppression + archivage)
- [ ] Sauvegarde emails importants (export local)
- [ ] Respect charte entreprise (usage personnel limité)