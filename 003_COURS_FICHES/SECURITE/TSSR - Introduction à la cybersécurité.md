## ⚡ L'essentiel en 5 minutes - Introduction à la Cybersécurité

### 📌 C'est quoi en 2 lignes ?

La cybersécurité protège le Système d'Information (ressources informatiques collectant/stockant/traitant l'information) contre les actions malveillantes. Elle garantit **D.I.C.P** : Disponibilité, Intégrité, Confidentialité, et Preuve (traçabilité/authentification/imputabilité).

---

### 💡 Concepts clés à retenir :

- **SI (Système d'Information)** : Ensemble organisé de ressources (ordinateurs, réseau) pour gérer l'information
- **PSSI** : Politique de Sécurité du SI = analyse de risques + modèle de menace + solutions à déployer
- **Vulnérabilité** : Faiblesse de conception/configuration exploitable
- **Menace** : Cause potentielle d'un dommage sur le SI
- **Attaque** : Concrétisation d'une menace exploitant une vulnérabilité
- **D.I.C.P** : Disponibilité (accessible quand nécessaire), Intégrité (exactitude des données), Confidentialité (accessible uniquement aux autorisés), Preuve (traçabilité + authentification + imputabilité)
- **RSSI (CISO)** : Responsable de la Sécurité des SI, établit la PSSI

---

### 🎯 Cycle de traitement des vulnérabilités :

1. **Prévenir** : Éviter les vulnérabilités
2. **Détecter** : Savoir si/quand une attaque a lieu
3. **Réagir** : Décider de la réponse appropriée
4. **Réparer** : Remettre le SI en état opérationnel
5. **Évoluer** : Faire évoluer la PSSI

---

### 🎭 Ingénierie sociale (Social Engineering) :

**Définition :** Influencer les utilisateurs légitimes pour qu'ils agissent dans l'intérêt du cybercriminel

**Techniques principales :**

- **Phishing (hameçonnage)** : Imiter un site/mail légitime pour voler identifiants/mots de passe/CB (attaque de masse)
- **Spear phishing (harponnage)** : Phishing ciblé sur une personne/organisation spécifique

---

### 🦠 Malwares (logiciels malveillants) :

**Par nature :**

- **Virus** : Contamine d'autres programmes (exécutable/macro/boot)
- **Vers** : Auto-réplication réseau via vulnérabilités (failles/macro/mail)

**Par charge utile :**

- **Wiper (bombe logique)** : Détruit les données
- **Ransomware (rançongiciel)** : Chiffre les données et demande une rançon
- **Trojan (cheval de Troie)** : Programme malveillant déguisé
- **Backdoor (porte dérobée)** : Accès persistant non autorisé
- **Keylogger** : Enregistre les frappes clavier
- **Spyware (mouchard)** : Collecte des informations
- **Bot/BotNet** : Machines contrôlées à distance pour attaques coordonnées

---

### 🔑 Sécurité des mots de passe :

#### Attaques principales :

- **Force brute** : Test de toutes les combinaisons possibles
    - 4 chiffres = 10 000 essais (0,01s)
    - 8 alphanumériques = 62⁸ ≈ 7 ans
    - 16 caractères ASCII = 95¹⁶ ≈ 10¹⁸ ans
- **Dictionnaire** : Test des mots de passe courants (123456, password, qwerty...)
- **Capture en clair** : Lecture directe (réseau non chiffré, BDD, post-it, keylogger)

#### Stockage sécurisé :

```
Mot de passe → [Hachage + Sel] → Empreinte stockée
                                  + Sel stocké
```

- **Sel** : Valeur aléatoire ajoutée avant hachage (empêche tables arc-en-ciel)
- **Algorithmes recommandés** : yescrypt, scrypt, bcrypt, argon2 (calcul intentionnellement lent)
- ❌ **Ne JAMAIS stocker les mots de passe en clair**

---

### ⚠️ Pièges à éviter :

- ❌ **Réutiliser le même mot de passe** : Une fuite compromet tous vos comptes
- ❌ **Mots de passe courts/simples** : Crackables en secondes par force brute
- ❌ **Stocker les mots de passe en clair** : Exposition totale en cas de compromission
- ❌ **Communiquer ses mots de passe** : Même à l'IT, même par téléphone "urgent"
- ❌ **Cliquer sans vérifier l'URL** : https://mabanque.com vs https://mabanque-secure.tk
- ❌ **Ignorer les métadonnées des mails** : Vérifier l'expéditeur réel, pas l'alias affiché
- ❌ **Utiliser MD5/SHA-1 pour hasher** : Trop rapides, privilégier bcrypt/argon2

---

### ✅ Bonnes pratiques :

**Pour les utilisateurs :**

- ✅ **Gestionnaire de mots de passe** : KeePass, Bitwarden, 1Password (génération aléatoire + auto-remplissage)
- ✅ **Mots de passe longs (16+ caractères)** : "Phrase de passe" > mot de passe complexe court
- ✅ **Vérifier les URL avant connexion** : HTTPS + domaine exact
- ✅ **Regard critique sur les communications** : Vérifier les sources, méfiance par défaut

**Pour les systèmes :**

- ✅ **Principe de moindre privilège** : Limiter les droits au strict nécessaire
- ✅ **Antivirus à jour** : Sur messagerie et postes de travail
- ✅ **Chiffrement réseau (TLS)** : Protège contre la capture en clair
- ✅ **Limitation/ralentissement des tentatives** : Contre force brute/dictionnaire
- ✅ **Interdire les mots de passe courants** : Bloquer les 10 000 plus utilisés
- ✅ **Limiter les périphériques d'entrée** : Contrôler USB, supports externes
- ✅ **Installer uniquement des logiciels de confiance** : Vérifier empreintes/signatures

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**SI**|Système d'Information : ressources informatiques gérant l'information|
|**PSSI**|Politique de Sécurité du SI : document définissant les règles de sécurité|
|**RSSI / CISO**|Responsable Sécurité SI / Chief Information Security Officer|
|**D.I.C.P (CIA)**|Disponibilité, Intégrité, Confidentialité, Preuve|
|**Hachage**|Transformation irréversible d'une donnée en empreinte fixe|
|**Sel (salt)**|Valeur aléatoire ajoutée avant hachage (unique par utilisateur)|
|**TLS**|Transport Layer Security : chiffrement des communications réseau|
|**Phishing**|Hameçonnage : usurpation d'identité pour voler des données|
|**Malware**|Logiciel malveillant portant atteinte au SI|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : **D.I.C.P** = piliers de la cybersécurité (Disponibilité, Intégrité, Confidentialité, Preuve)
    
2. 💻 **Pratique** : **Hasher avec sel** = `bcrypt/argon2(mot_de_passe + sel_aléatoire)` → JAMAIS en clair !
    
3. ⚠️ **Piège** : **L'utilisateur est la faille** = 90% des attaques commencent par ingénierie sociale (phishing)
    

---

**📌 Règle d'or :** La sécurité à 100% n'existe pas → Défense en profondeur (prévention + détection + réaction + évolution continue)