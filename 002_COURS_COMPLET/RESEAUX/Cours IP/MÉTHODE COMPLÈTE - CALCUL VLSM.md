

## PRINCIPE DU VLSM

Le VLSM permet de créer des **sous-réseaux de tailles différentes** à partir d'un même réseau principal pour optimiser l'utilisation des adresses IP.

**Différence avec le subnetting classique :**

- Subnetting classique : tous les sous-réseaux ont la **même taille**
- VLSM : chaque sous-réseau a une **taille adaptée** à ses besoins

**Avantage :** Évite le gaspillage d'adresses IP

---

## RÈGLE D'OR DU VLSM

### ⚠️ TOUJOURS COMMENCER PAR LE PLUS GRAND SOUS-RÉSEAU

**Ordre obligatoire : du PLUS GRAND au PLUS PETIT**

**Pourquoi ?**

- Si on commence par les petits, on "fragmente" l'espace d'adressage
- On ne pourra plus créer les grands sous-réseaux ensuite
- Risque de chevauchement et de gaspillage

---

## ÉTAPE 1 : ANALYSE ET TRI DES BESOINS

**Données à rassembler :**

- Réseau de base (ex: 192.168.1.0/24)
- Liste de tous les besoins en hôtes

**Action : Créer un tableau et TRIER par ordre DÉCROISSANT**

**Exemple :**

|Priorité|Site/Service|Hôtes demandés|
|---|---|---|
|1|Siège social|500|
|2|Agence Nord|100|
|3|Agence Sud|50|
|4|DMZ|25|
|5|Liaison WAN 1|2|
|6|Liaison WAN 2|2|

---

## ÉTAPE 2 : CALCUL DU MASQUE POUR CHAQUE BESOIN

**Pour chaque ligne du tableau :**

### 2.1 - Trouver le nombre de bits hôtes nécessaires

**Formule : 2^h - 2 ≥ nombre d'hôtes demandés**

**Méthode :** Tester les puissances de 2 jusqu'à trouver la bonne

**Exemple 1 : 500 hôtes**

```
2^8 - 2 = 254 (insuffisant)
2^9 - 2 = 510 ✓ (suffisant)

→ Il faut 9 bits pour les hôtes
```

**Exemple 2 : 100 hôtes**

```
2^6 - 2 = 62 (insuffisant)
2^7 - 2 = 126 ✓ (suffisant)

→ Il faut 7 bits pour les hôtes
```

**Exemple 3 : 2 hôtes (liaisons)**

```
2^1 - 2 = 0 (insuffisant)
2^2 - 2 = 2 ✓ (suffisant)

→ Il faut 2 bits pour les hôtes
```

### 2.2 - Calculer le masque CIDR

**Formule : CIDR = 32 - bits hôtes**

**Exemples :**

- 500 hôtes → 9 bits hôtes → 32 - 9 = **/23**
- 100 hôtes → 7 bits hôtes → 32 - 7 = **/25**
- 2 hôtes → 2 bits hôtes → 32 - 2 = **/30**

### 2.3 - Convertir en masque décimal

**Tableau de référence :**

|CIDR|Masque décimal|Bits hôtes|Hôtes max|
|---|---|---|---|
|/30|255.255.255.252|2|2|
|/29|255.255.255.248|3|6|
|/28|255.255.255.240|4|14|
|/27|255.255.255.224|5|30|
|/26|255.255.255.192|6|62|
|/25|255.255.255.128|7|126|
|/24|255.255.255.0|8|254|
|/23|255.255.254.0|9|510|
|/22|255.255.252.0|10|1022|
|/21|255.255.248.0|11|2046|

### 2.4 - Calculer l'incrément

**Formule : Incrément = 256 - valeur du masque dans l'octet variable**

**Exemples :**

- /23 (255.255.254.0) → Incrément = 256 - 254 = **2** (sur 3ème octet)
- /25 (255.255.255.128) → Incrément = 256 - 128 = **128** (sur 4ème octet)
- /30 (255.255.255.252) → Incrément = 256 - 252 = **4** (sur 4ème octet)

---

## ÉTAPE 3 : TABLEAU RÉCAPITULATIF DES CALCULS

**Créer ce tableau AVANT d'attribuer les adresses :**

|Priorité|Site|Hôtes|Bits h|CIDR|Masque|Incrément|Hôtes réels|
|---|---|---|---|---|---|---|---|
|1|Siège|500|9|/23|255.255.254.0|2|510|
|2|Agence N|100|7|/25|255.255.255.128|128|126|
|3|Agence S|50|6|/26|255.255.255.192|64|62|
|4|DMZ|25|5|/27|255.255.255.224|32|30|
|5|WAN 1|2|2|/30|255.255.255.252|4|2|
|6|WAN 2|2|2|/30|255.255.255.252|4|2|

---

## ÉTAPE 4 : ATTRIBUTION SÉQUENTIELLE DES ADRESSES

**Point de départ : Réseau de base (ex: 192.168.1.0/24)**

### Principe :

1. Commencer à l'adresse de base
2. Attribuer le premier sous-réseau (le plus grand)
3. Passer à l'adresse suivante disponible
4. Attribuer le deuxième sous-réseau
5. Continuer jusqu'au dernier

---

### SOUS-RÉSEAU 1 : Siège (500 hôtes → /23)

**Adresse de départ : 192.168.1.0**

**Calculs :**

- Masque : /23
- Incrément : 2 (sur le 3ème octet)
- Plage : 192.168.0.0 → 192.168.1.255

⚠️ **Attention :** Pour un /23 commençant à 192.168.1.0, il faut "remonter" au réseau pair :

- 192.168.1.0/23 n'est PAS valide
- Le bon réseau est **192.168.0.0/23**

**Détail du sous-réseau :**

```
Adresse réseau :     192.168.0.0
Première IP utile :  192.168.0.1
Dernière IP utile :  192.168.1.254
Broadcast :          192.168.1.255
Hôtes disponibles :  510
```

**Prochaine adresse libre : 192.168.2.0**

---

### SOUS-RÉSEAU 2 : Agence Nord (100 hôtes → /25)

**Adresse de départ : 192.168.2.0**

**Calculs :**

- Masque : /25
- Incrément : 128
- Plage : 192.168.2.0 → 192.168.2.127

**Détail du sous-réseau :**

```
Adresse réseau :     192.168.2.0
Première IP utile :  192.168.2.1
Dernière IP utile :  192.168.2.126
Broadcast :          192.168.2.127
Hôtes disponibles :  126
```

**Prochaine adresse libre : 192.168.2.128**

---

### SOUS-RÉSEAU 3 : Agence Sud (50 hôtes → /26)

**Adresse de départ : 192.168.2.128**

**Calculs :**

- Masque : /26
- Incrément : 64
- Plage : 192.168.2.128 → 192.168.2.191

**Détail du sous-réseau :**

```
Adresse réseau :     192.168.2.128
Première IP utile :  192.168.2.129
Dernière IP utile :  192.168.2.190
Broadcast :          192.168.2.191
Hôtes disponibles :  62
```

**Prochaine adresse libre : 192.168.2.192**

---

### SOUS-RÉSEAU 4 : DMZ (25 hôtes → /27)

**Adresse de départ : 192.168.2.192**

**Calculs :**

- Masque : /27
- Incrément : 32
- Plage : 192.168.2.192 → 192.168.2.223

**Détail du sous-réseau :**

```
Adresse réseau :     192.168.2.192
Première IP utile :  192.168.2.193
Dernière IP utile :  192.168.2.222
Broadcast :          192.168.2.223
Hôtes disponibles :  30
```

**Prochaine adresse libre : 192.168.2.224**

---

### SOUS-RÉSEAU 5 : Liaison WAN 1 (2 hôtes → /30)

**Adresse de départ : 192.168.2.224**

**Calculs :**

- Masque : /30
- Incrément : 4
- Plage : 192.168.2.224 → 192.168.2.227

**Détail du sous-réseau :**

```
Adresse réseau :     192.168.2.224
IP Routeur 1 :       192.168.2.225
IP Routeur 2 :       192.168.2.226
Broadcast :          192.168.2.227
Hôtes disponibles :  2
```

**Prochaine adresse libre : 192.168.2.228**

---

### SOUS-RÉSEAU 6 : Liaison WAN 2 (2 hôtes → /30)

**Adresse de départ : 192.168.2.228**

**Calculs :**

- Masque : /30
- Incrément : 4
- Plage : 192.168.2.228 → 192.168.2.231

**Détail du sous-réseau :**

```
Adresse réseau :     192.168.2.228
IP Routeur 1 :       192.168.2.229
IP Routeur 2 :       192.168.2.230
Broadcast :          192.168.2.231
Hôtes disponibles :  2
```

**Prochaine adresse libre : 192.168.2.232**

---

## ÉTAPE 5 : TABLEAU FINAL COMPLET

|Site|Hôtes|CIDR|Réseau|1ère IP|Dernière IP|Broadcast|Hôtes dispo|
|---|---|---|---|---|---|---|---|
|Siège|500|/23|192.168.0.0|.0.1|.1.254|.1.255|510|
|Agence N|100|/25|192.168.2.0|.2.1|.2.126|.2.127|126|
|Agence S|50|/26|192.168.2.128|.2.129|.2.190|.2.191|62|
|DMZ|25|/27|192.168.2.192|.2.193|.2.222|.2.223|30|
|WAN 1|2|/30|192.168.2.224|.2.225|.2.226|.2.227|2|
|WAN 2|2|/30|192.168.2.228|.2.229|.2.230|.2.231|2|

---

## ÉTAPE 6 : VÉRIFICATIONS OBLIGATOIRES

### 6.1 - Vérification des chevauchements

**Méthode :** La fin d'un SR doit être < au début du suivant

```
✓ SR1 : se termine à 192.168.1.255
  SR2 : commence à 192.168.2.0
  1.255 < 2.0 ✓

✓ SR2 : se termine à 192.168.2.127
  SR3 : commence à 192.168.2.128
  127 < 128 ✓

✓ SR3 : se termine à 192.168.2.191
  SR4 : commence à 192.168.2.192
  191 < 192 ✓

etc.
```

### 6.2 - Vérification de l'espace utilisé

**Pour un réseau /24 (192.168.1.0/24) :**

⚠️ **Problème détecté :** Le premier SR déborde sur 192.168.0.0

**Solution :** Utiliser un réseau de base plus grand, comme 192.168.0.0/23 ou adapter le plan.

**Alternative avec 192.168.1.0/24 strict :**

Il faudrait réduire le siège à un /24 (254 hôtes) au lieu de /23.

### 6.3 - Calcul du taux d'utilisation

**Formule :**

```
Adresses utilisées / Adresses disponibles × 100
```

**Exemple :**

- Adresses utilisées : 232 (de .0 à .231)
- Disponibles dans /24 : 256
- Taux : 232/256 = **90,6%** ✓ (Excellent)

---

## REPRÉSENTATION GRAPHIQUE

**Schéma visuel de la répartition :**

```
192.168.0.0/23 (Réseau de base élargi)
│
├─ 192.168.0.0/23    : Siège (510 hôtes)
│  └─ Plage : 0.0 → 1.255
│
├─ 192.168.2.0/25    : Agence Nord (126 hôtes)
│  └─ Plage : 2.0 → 2.127
│
├─ 192.168.2.128/26  : Agence Sud (62 hôtes)
│  └─ Plage : 2.128 → 2.191
│
├─ 192.168.2.192/27  : DMZ (30 hôtes)
│  └─ Plage : 2.192 → 2.223
│
├─ 192.168.2.224/30  : WAN 1 (2 hôtes)
│  └─ Plage : 2.224 → 2.227
│
├─ 192.168.2.228/30  : WAN 2 (2 hôtes)
│  └─ Plage : 2.228 → 2.231
│
└─ 192.168.2.232 → 192.168.2.255 : DISPONIBLE
```

---

## EXEMPLE COMPLET : CLASSE B EN VLSM

**Énoncé : Réseau 10.50.0.0/16**

**Besoins :**

- Site principal : 5000 hôtes
- Site secondaire : 1000 hôtes
- Agence A : 200 hôtes
- Agence B : 50 hôtes
- 3 liaisons routeur : 2 hôtes chacune

---

### SOLUTION DÉTAILLÉE

**1) Tri des besoins**

|Priorité|Site|Hôtes|
|---|---|---|
|1|Site principal|5000|
|2|Site secondaire|1000|
|3|Agence A|200|
|4|Agence B|50|
|5|Liaison 1|2|
|6|Liaison 2|2|
|7|Liaison 3|2|

---

**2) Calculs des masques**

**Site principal : 5000 hôtes**

```
2^12 - 2 = 4094 (insuffisant)
2^13 - 2 = 8190 ✓
→ /19 (32-13)
→ Masque : 255.255.224.0
→ Incrément : 256-224 = 32
```

**Site secondaire : 1000 hôtes**

```
2^10 - 2 = 1022 ✓
→ /22 (32-10)
→ Masque : 255.255.252.0
→ Incrément : 256-252 = 4
```

**Agence A : 200 hôtes**

```
2^8 - 2 = 254 ✓
→ /24
→ Masque : 255.255.255.0
→ Incrément : 1
```

**Agence B : 50 hôtes**

```
2^6 - 2 = 62 ✓
→ /26
→ Masque : 255.255.255.192
→ Incrément : 64
```

**Liaisons : 2 hôtes**

```
2^2 - 2 = 2 ✓
→ /30
→ Masque : 255.255.255.252
→ Incrément : 4
```

---

**3) Attribution séquentielle**

|Site|CIDR|Réseau|Plage complète|
|---|---|---|---|
|Principal|/19|10.50.0.0|10.50.0.0 → 10.50.31.255|
|Secondaire|/22|10.50.32.0|10.50.32.0 → 10.50.35.255|
|Agence A|/24|10.50.36.0|10.50.36.0 → 10.50.36.255|
|Agence B|/26|10.50.37.0|10.50.37.0 → 10.50.37.63|
|Liaison 1|/30|10.50.37.64|10.50.37.64 → 10.50.37.67|
|Liaison 2|/30|10.50.37.68|10.50.37.68 → 10.50.37.71|
|Liaison 3|/30|10.50.37.72|10.50.37.72 → 10.50.37.75|

---

## ERREURS FRÉQUENTES EN VLSM

❌ **Ne pas trier par taille** → Fragmentation de l'espace ❌ **Commencer par les petits réseaux** → Impossible de créer les grands ensuite ❌ **Oublier le -2** dans le calcul d'hôtes ❌ **Ne pas vérifier les chevauchements** ❌ **Confondre l'incrément** selon l'octet ❌ **Attribuer une adresse réseau impaire** pour les masques pairs (/23, /22, /21...)

---

## ASTUCES POUR L'EXAMEN

**1. Préparez un tableau de référence**

Écrivez dès le début :

```
2^2-2=2 (/30)    2^6-2=62 (/26)    2^10-2=1022 (/22)
2^3-2=6 (/29)    2^7-2=126 (/25)   2^11-2=2046 (/21)
2^4-2=14 (/28)   2^8-2=254 (/24)   2^12-2=4094 (/20)
2^5-2=30 (/27)   2^9-2=510 (/23)   2^13-2=8190 (/19)
```

**2. Utilisez des couleurs**

Un code couleur par sous-réseau pour mieux visualiser.

**3. Tracez un schéma**

Une représentation visuelle aide à vérifier les chevauchements.

**4. Double vérification**

- Chaque fin de plage < début de la suivante
- Dernier octet ne dépasse jamais 255
- Total des adresses ≤ réseau de base

---

## FORMULE RÉCAPITULATIVE VLSM

```
POUR CHAQUE BESOIN :
1. Bits hôtes : 2^h - 2 ≥ besoin
2. CIDR : 32 - h
3. Masque : conversion binaire
4. Incrément : 256 - valeur masque
5. Attribution : séquentielle du grand au petit
6. Vérification : pas de chevauchement
```

---

## CHECKLIST FINALE

Avant de rendre votre copie, vérifiez :

✓ Besoins triés du plus grand au plus petit ✓ Calculs de masques corrects pour chaque besoin ✓ Attribution séquentielle respectée ✓ Aucun chevauchement entre sous-réseaux ✓ Adresses réseau valides (respectant les incréments) ✓ Tableau récapitulatif complet et clair ✓ Vérifications finales effectuées

---

**Maîtrisez le VLSM et vous optimiserez vos réseaux comme un pro ! 🎯**