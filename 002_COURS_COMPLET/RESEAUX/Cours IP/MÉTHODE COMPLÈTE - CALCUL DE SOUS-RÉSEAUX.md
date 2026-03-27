

## ÉTAPE 1 : ANALYSE DU BESOIN

**Données à identifier :**

- Réseau de départ (ex: 192.168.1.0/24)
- Nombre de sous-réseaux demandés (ex: 4 sous-réseaux)

**Calcul du nombre de bits à emprunter :**

Formule : **2^n ≥ nombre de sous-réseaux**

Tester les puissances jusqu'à trouver la bonne :

- 2^1 = 2
- 2^2 = 4
- 2^3 = 8
- 2^4 = 16
- etc.

**Exemple :** Pour 4 sous-réseaux → 2^2 = 4 → **2 bits à emprunter**

---

## ÉTAPE 2 : CALCUL DU NOUVEAU MASQUE

**Masque d'origine en binaire :**

|Classe|CIDR|Masque décimal|Binaire|
|---|---|---|---|
|A|/8|255.0.0.0|11111111.00000000.00000000.00000000|
|B|/16|255.255.0.0|11111111.11111111.00000000.00000000|
|C|/24|255.255.255.0|11111111.11111111.11111111.00000000|

**Nouveau masque = Masque d'origine + bits empruntés**

**Exemple :** /24 + 2 bits = **/26**

**Conversion en décimal :**

Pour /26 :

```
11111111.11111111.11111111.11000000
255     .255     .255     .192
```

**Tableau de correspondance rapide :**

|Bits|Valeur décimale|CIDR (depuis /24)|
|---|---|---|
|00000000|0|/24|
|10000000|128|/25|
|11000000|192|/26|
|11100000|224|/27|
|11110000|240|/28|
|11111000|248|/29|
|11111100|252|/30|

---

## ÉTAPE 3 : CALCUL DE L'INCRÉMENT

**Formule : 256 - valeur du masque dans l'octet variable**

**Identifier l'octet qui varie :**

- 2ème octet : masques /9 à /16
- 3ème octet : masques /17 à /24
- 4ème octet : masques /25 à /30

**Exemple :** Masque /26 = 255.255.255.192

- L'octet variable est le 4ème (192)
- Incrément = 256 - 192 = **64**

**Utilité :** L'incrément indique le "saut" entre chaque sous-réseau.

---

## ÉTAPE 4 : CALCUL DU NOMBRE D'HÔTES

**Formule : 2^h - 2** (où h = bits restants pour les hôtes)

**Calcul des bits hôtes :**

- Bits totaux dans une IP : 32
- Bits pour le réseau : valeur du CIDR
- Bits pour les hôtes : 32 - CIDR

**Pourquoi -2 ?**

- 1 adresse réservée pour l'adresse réseau (tous les bits hôtes à 0)
- 1 adresse réservée pour le broadcast (tous les bits hôtes à 1)

**Exemple :** Pour /26

```
Bits hôtes = 32 - 26 = 6 bits
Nombre d'hôtes = 2^6 - 2 = 64 - 2 = 62 hôtes utilisables
```

---

## ÉTAPE 5 : LISTE DES SOUS-RÉSEAUX

**Méthode séquentielle :**

Partir de l'adresse de base et ajouter l'incrément à chaque fois.

**Exemple : 192.168.1.0/26 (incrément = 64)**

|SR|Adresse réseau|Première IP|Dernière IP|Broadcast|Plage|
|---|---|---|---|---|---|
|1|192.168.1.0|192.168.1.1|192.168.1.62|192.168.1.63|0-63|
|2|192.168.1.64|192.168.1.65|192.168.1.126|192.168.1.127|64-127|
|3|192.168.1.128|192.168.1.129|192.168.1.190|192.168.1.191|128-191|
|4|192.168.1.192|192.168.1.193|192.168.1.254|192.168.1.255|192-255|

**Règles :**

- Adresse réseau : première adresse de la plage (NON utilisable)
- Première IP utilisable : adresse réseau + 1
- Dernière IP utilisable : broadcast - 1
- Broadcast : dernière adresse de la plage (NON utilisable)

---

## ÉTAPE 6 : DÉTAIL D'UN SOUS-RÉSEAU EN BINAIRE

**Exemple avec SR2 : 192.168.1.64/26**

**Analyse du 4ème octet en binaire :**

|Type|Décimal|Binaire|Utilisation|
|---|---|---|---|
|Adresse réseau|64|01000000|NON (réseau)|
|Première IP|65|01000001|OUI|
|...|...|...|OUI|
|Dernière IP|126|01111110|OUI|
|Broadcast|127|01111111|NON (broadcast)|

**Observation :**

- Les 2 premiers bits (01) identifient le sous-réseau
- Les 6 derniers bits varient pour les hôtes (000000 à 111111)

---

## ÉTAPE 7 : VÉRIFICATIONS FINALES

**Checklist de validation :**

✓ **Nombre de sous-réseaux correct**

```
2^(bits empruntés) = nombre obtenu
```

✓ **Pas de chevauchement**

```
Fin du SR1 < Début du SR2
Fin du SR2 < Début du SR3
etc.
```

✓ **Dernier sous-réseau ne dépasse pas 255**

```
Pour /24 d'origine : dernier octet ≤ 255
Pour /16 d'origine : 3ème octet ≤ 255
```

✓ **Calcul des hôtes cohérent**

```
Nombre total d'hôtes théoriques = sous-réseaux × hôtes par SR
Ce total doit être ≤ capacité du réseau d'origine
```

---

## EXEMPLES COMPLETS PAR CLASSE

### EXEMPLE 1 : CLASSE C (sous-réseaux sur le 4ème octet)

**Énoncé : 192.168.10.0/24 → 8 sous-réseaux**

**Solution :**

**1) Bits à emprunter**

- 2^3 = 8 → **3 bits**

**2) Nouveau masque**

- /24 + 3 = **/27**
- Masque : 255.255.255.224

**3) Incrément**

- 256 - 224 = **32**

**4) Nombre d'hôtes**

- 2^(32-27) - 2 = 2^5 - 2 = **30 hôtes**

**5) Sous-réseaux**

|SR|Réseau|Plage utilisable|Broadcast|
|---|---|---|---|
|1|192.168.10.0/27|.1 à .30|.31|
|2|192.168.10.32/27|.33 à .62|.63|
|3|192.168.10.64/27|.65 à .94|.95|
|4|192.168.10.96/27|.97 à .126|.127|
|5|192.168.10.128/27|.129 à .158|.159|
|6|192.168.10.160/27|.161 à .190|.191|
|7|192.168.10.192/27|.193 à .222|.223|
|8|192.168.10.224/27|.225 à .254|.255|

---

### EXEMPLE 2 : CLASSE B (sous-réseaux sur le 3ème octet)

**Énoncé : 172.16.0.0/16 → 16 sous-réseaux**

**Solution :**

**1) Bits à emprunter**

- 2^4 = 16 → **4 bits**

**2) Nouveau masque**

- /16 + 4 = **/20**
- Binaire : 11111111.11111111.11110000.00000000
- Masque : 255.255.240.0

**3) Incrément**

- 256 - 240 = **16** (sur le 3ème octet)

**4) Nombre d'hôtes**

- 2^(32-20) - 2 = 2^12 - 2 = **4094 hôtes**

**5) Sous-réseaux (premiers et derniers)**

|SR|Réseau|Plage|
|---|---|---|
|1|172.16.0.0/20|172.16.0.0 → 172.16.15.255|
|2|172.16.16.0/20|172.16.16.0 → 172.16.31.255|
|3|172.16.32.0/20|172.16.32.0 → 172.16.47.255|
|...|...|...|
|16|172.16.240.0/20|172.16.240.0 → 172.16.255.255|

---

### EXEMPLE 3 : CLASSE A (sous-réseaux sur le 2ème octet)

**Énoncé : 10.0.0.0/8 → 4 sous-réseaux**

**Solution :**

**1) Bits à emprunter**

- 2^2 = 4 → **2 bits**

**2) Nouveau masque**

- /8 + 2 = **/10**
- Binaire : 11111111.11000000.00000000.00000000
- Masque : 255.192.0.0

**3) Incrément**

- 256 - 192 = **64** (sur le 2ème octet)

**4) Nombre d'hôtes**

- 2^(32-10) - 2 = 2^22 - 2 = **4 194 302 hôtes**

**5) Sous-réseaux**

|SR|Réseau|Plage|
|---|---|---|
|1|10.0.0.0/10|10.0.0.0 → 10.63.255.255|
|2|10.64.0.0/10|10.64.0.0 → 10.127.255.255|
|3|10.128.0.0/10|10.128.0.0 → 10.191.255.255|
|4|10.192.0.0/10|10.192.0.0 → 10.255.255.255|

---

## TABLEAU RÉCAPITULATIF DES MASQUES

|CIDR|Masque|Incr.|Hôtes|Usage typique|
|---|---|---|---|---|
|/30|255.255.255.252|4|2|Liaison point-à-point|
|/29|255.255.255.248|8|6|Très petit réseau|
|/28|255.255.255.240|16|14|Petit réseau|
|/27|255.255.255.224|32|30|Département|
|/26|255.255.255.192|64|62|Service|
|/25|255.255.255.128|128|126|Grand service|
|/24|255.255.255.0|1|254|Réseau standard|
|/23|255.255.254.0|2|510|Double classe C|
|/22|255.255.252.0|4|1022|Moyen réseau|
|/21|255.255.248.0|8|2046|Grand réseau|
|/20|255.255.240.0|16|4094|Très grand réseau|
|/16|255.255.0.0|1|65534|Classe B|

---

## FORMULES ESSENTIELLES

**À connaître par cœur :**

```
Nombre de sous-réseaux = 2^n
(n = nombre de bits empruntés)

Nombre d'hôtes = 2^h - 2
(h = bits restants pour les hôtes)

Incrément = 256 - valeur du masque

Nouveau CIDR = CIDR d'origine + bits empruntés

Bits hôtes = 32 - CIDR
```

---

## MÉTHODE RAPIDE POUR L'EXAMEN

**1.** Identifier le besoin (X sous-réseaux) **2.** Trouver n : 2^n ≥ X **3.** Nouveau masque = ancien + n **4.** Incrément = 256 - valeur masque **5.** Hôtes = 2^(32-nouveau masque) - 2 **6.** Lister les réseaux avec l'incrément **7.** Vérifier : pas de chevauchement

---

## ERREURS COURANTES À ÉVITER

❌ Oublier le "-2" dans le calcul d'hôtes ❌ Confondre adresse réseau et première IP utilisable ❌ Utiliser le broadcast comme IP d'hôte ❌ Se tromper d'octet pour l'incrément ❌ Ne pas vérifier les chevauchements ❌ Dépasser 255 dans les octets

---

## CONSEIL FINAL

**Sur votre brouillon, tracez toujours ce schéma :**

```
Réseau d'origine : X.X.X.X/Y
↓
Besoin : Z sous-réseaux
↓
Bits empruntés : 2^n = Z → n bits
↓
Nouveau masque : /Y+n
↓
Incrément : 256 - masque
↓
Hôtes : 2^h - 2
↓
Liste des sous-réseaux
```

Cette structure garantit que vous n'oubliez aucune étape !