## 1. Définitions clés

|Terme|Définition|
|---|---|
|**Email**|Système de communication texte **asynchrone** sur réseau informatique|
|**Adresse email**|`identifiant@nom-de-domaine` — définie par la RFC 5322|
|**BAL (boîte aux lettres)**|Destination des emails, identifiée par une adresse électronique|
|**MUA**|Mail User Agent — le logiciel client (ex : Outlook, Thunderbird)|
|**MSA**|Mail Submission Agent — accepte les mails du MUA et les transmet au MTA|
|**MTA**|Mail Transfer Agent — route les mails de serveur en serveur via SMTP|
|**MDA**|Mail Delivery Agent — dépose les mails dans la BAL du destinataire|

---

## 2. Les protocoles & leurs ports

|Protocole|Rôle|Ports|
|---|---|---|
|**SMTP**|Envoi des emails (sortant)|25 (défaut), 465 / 587 (avec chiffrement)|
|**POP3**|Réception — télécharge les mails et les supprime du serveur|110|
|**IMAP**|Réception — synchronise les mails avec le serveur|143|

---

## 3. SMTP — l'envoi

- Protocole de **routage** des emails entre serveurs
- Interroge le **DNS** pour trouver l'enregistrement **MX** du domaine destinataire
- Si le domaine n'existe pas → message d'erreur renvoyé à l'expéditeur

---

## 4. POP3 vs IMAP

| |POP3|IMAP|
|---|---|---|
|Stockage|**Local** (téléchargé, supprimé du serveur)|**Serveur** (synchronisé)|
|Multi-appareils|❌ (un seul appareil reçoit les mails)|✅ (tous les appareils synchronisés)|
|Fonctions avancées|❌ basique|✅ dossiers, marquage, lecture partielle|
|Débit faible|❌|✅ (asynchrone)|
|Usage recommandé|Mono-poste, simple|Professionnel, multi-postes|

---

## 5. Trajet complet d'un email (Bob → Alice)

```
Bob (MUA) → MSA → MTA [DNS: cherche MX de domaine2.fr]
    → MTA domaine2.fr → MDA → BAL d'Alice
        → Alice (MUA via POP ou IMAP)
```

1. Bob écrit et envoie depuis son client (MUA)
2. Le MSA vérifie le contenu et transmet au MTA
3. Le MTA interroge le DNS pour le MX de destination
4. Le mail transite de MTA en MTA jusqu'au domaine destinataire
5. Le MDA dépose le mail dans la BAL d'Alice
6. Alice consulte sa BAL via POP3 ou IMAP

---

## 6. Bonnes pratiques

- 🔒 **Sécurité** : mot de passe fort, 2FA, vigilance sur les pièces jointes et liens
- 🗂️ **Organisation** : dossiers par catégorie, tri régulier, pas de stockage longue durée
- 🤫 **Confidentialité** : adresse pro pour le travail, vérifier les destinataires avant envoi
- 📋 **Usage responsable** : respecter la charte, langage approprié

---

## 7. Exemples concrets

**Exemple d'adresse email :**

```
prenom.nom @ entreprise.fr
   [local]  @  [domaine]
```

**Exemple d'enregistrement MX :**

```
MX 10  mx1.entreprise.fr   ← priorité 10 (plus la valeur est basse, plus prioritaire)
MX 20  mx2.entreprise.fr   ← serveur de secours
```

**POP3 en pratique :** Alice consulte sa BAL depuis son PC fixe → les mails sont téléchargés localement. Si elle se connecte ensuite depuis son téléphone, la boîte est vide.

**IMAP en pratique :** Alice lit un mail sur son téléphone → il apparaît comme "lu" aussi sur son PC et sa tablette, car tout est synchronisé sur le serveur.