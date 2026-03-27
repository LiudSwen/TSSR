
---

## 📑 Table des matières

```table-of-contents
```toc
minLevel: 2
maxLevel: 2
```
---

## 📚 Introduction aux systèmes de numération

### Qu'est-ce qu'un système de numération ?

Un **système de numération** est une méthode pour représenter des nombres en utilisant un ensemble de symboles. Chaque système est caractérisé par sa **base**, qui détermine le nombre de symboles différents utilisés.

> [!info] Concept fondamental La base d'un système de numération indique :
> 
> - Le nombre de symboles différents utilisés (0 à base-1)
> - La valeur de chaque position dans le nombre (puissances de la base)

### Pourquoi apprendre plusieurs systèmes ?

> [!tip] Importance dans l'informatique
> 
> - **Binaire** : Langage natif des ordinateurs (électricité = 0 ou 1)
> - **Hexadécimal** : Notation compacte pour les développeurs (couleurs, adresses mémoire, debugging)
> - **Décimal** : Notre système quotidien, interface humaine

### Structure positionnelle

Tous ces systèmes utilisent une **notation positionnelle** : la position d'un chiffre détermine sa valeur.

**Exemple en décimal (123)** :

```
  1    2    3
  ↓    ↓    ↓
10²  10¹  10⁰
100   10    1

Valeur = (1 × 100) + (2 × 10) + (3 × 1) = 123
```

---

## 🔟 Le système décimal (base 10)

### Présentation

Le système décimal est notre système de numération quotidien. Il utilise **10 symboles** : 0, 1, 2, 3, 4, 5, 6, 7, 8, 9.

> [!info] Caractéristiques
> 
> - **Base** : 10
> - **Symboles** : 0-9 (10 chiffres)
> - **Origine** : Probablement lié à nos 10 doigts
> - **Usage** : Mathématiques courantes, vie quotidienne

### Structure et valeur positionnelle

Chaque position représente une puissance de 10 :

```
Position :    4     3     2     1     0
              ↓     ↓     ↓     ↓     ↓
Puissance :  10⁴   10³   10²   10¹   10⁰
Valeur :    10000  1000  100    10    1
```

> [!example] Exemple : Décomposition de 5 847
> 
> ```
> 5 847 = (5 × 1000) + (8 × 100) + (4 × 10) + (7 × 1)
>       = (5 × 10³) + (8 × 10²) + (4 × 10¹) + (7 × 10⁰)
>       = 5000 + 800 + 40 + 7
> ```

### Notation

En informatique, on peut spécifier explicitement qu'un nombre est en décimal de plusieurs façons :

```bash
# Notations possibles
42        # Implicitement décimal
42₁₀      # Notation mathématique avec indice
42d       # Parfois utilisé en programmation
```

> [!warning] Point de référence Le décimal est notre système de référence. Toutes les conversions passent généralement par le décimal comme étape intermédiaire.

---

## 🤖 Le système binaire (base 2)

### Présentation

Le système binaire est le langage fondamental des ordinateurs. Il utilise **2 symboles** : 0 et 1.

> [!info] Caractéristiques
> 
> - **Base** : 2
> - **Symboles** : 0 et 1 (appelés "bits")
> - **Origine** : Électronique digitale (courant passe / ne passe pas)
> - **Usage** : Stockage informatique, circuits logiques, réseaux

### Pourquoi le binaire en informatique ?

> [!tip] Raisons techniques
> 
> 1. **Fiabilité** : Facile de distinguer deux états (tension haute/basse)
> 2. **Simplicité** : Circuits électroniques simples (transistors = interrupteurs)
> 3. **Résistance au bruit** : Moins d'erreurs de transmission
> 4. **Algèbre booléenne** : Base mathématique solide (ET, OU, NON)

### Structure et valeur positionnelle

Chaque position représente une puissance de 2 :

```
Position :   7    6    5    4    3    2    1    0
             ↓    ↓    ↓    ↓    ↓    ↓    ↓    ↓
Puissance : 2⁷   2⁶   2⁵   2⁴   2³   2²   2¹   2⁰
Valeur :   128   64   32   16    8    4    2    1
```

> [!example] Exemple : Décomposition de 1011₂
> 
> ```
> 1011₂ = (1 × 2³) + (0 × 2²) + (1 × 2¹) + (1 × 2⁰)
>       = (1 × 8) + (0 × 4) + (1 × 2) + (1 × 1)
>       = 8 + 0 + 2 + 1
>       = 11₁₀
> ```

### Vocabulaire important

|Terme|Définition|Exemple|
|---|---|---|
|**Bit**|Binary Digit - Plus petite unité (0 ou 1)|`1`|
|**Nibble**|4 bits|`1011`|
|**Octet (Byte)**|8 bits|`11010110`|
|**Word**|16, 32 ou 64 bits selon l'architecture|`1101011011010110`|

### Notation

```bash
# Notations courantes
0b1010    # Préfixe 0b (C, Python, JavaScript)
1010₂     # Notation mathématique avec indice
1010b     # Parfois utilisé en assembleur
%1010     # Notation en assembleur (certains)
```

> [!example] Compter en binaire (0 à 15)
> 
> ```
> 0000 = 0      0100 = 4      1000 = 8       1100 = 12
> 0001 = 1      0101 = 5      1001 = 9       1101 = 13
> 0010 = 2      0110 = 6      1010 = 10      1110 = 14
> 0011 = 3      0111 = 7      1011 = 11      1111 = 15
> ```

### Cas d'usage réels

> [!tip] Applications pratiques
> 
> - **Permissions Unix** : `rwxr-xr-x` → `111101101` → `755`
> - **Masques de sous-réseau** : `255.255.255.0` → `11111111.11111111.11111111.00000000`
> - **Flags et options** : Chaque bit = une option activée/désactivée
> - **Opérations bit à bit** : Manipulation directe des bits pour l'optimisation

### Pièges courants

> [!warning] Attention ! ❌ Confondre `10` (deux en binaire) avec `10` (dix en décimal) ✅ **Toujours préciser la base** : `10₂` vs `10₁₀` ou utiliser les préfixes `0b10` vs `10`
> 
> ❌ Oublier les zéros non significatifs dans les octets : `11` au lieu de `00000011` ✅ **Compléter à 8 bits** pour les octets : `0b00000011`

---

## 🎨 Le système hexadécimal (base 16)

### Présentation

Le système hexadécimal est une notation compacte très utilisée en informatique. Il utilise **16 symboles** : 0-9 puis A-F.

> [!info] Caractéristiques
> 
> - **Base** : 16
> - **Symboles** : 0-9 et A-F (16 symboles)
> - **Origine** : Notation compacte du binaire (4 bits = 1 chiffre hexa)
> - **Usage** : Couleurs web, adresses mémoire, dumps mémoire, MAC addresses

### Les symboles hexadécimaux

|Hexa|Décimal|Binaire|
|---|---|---|
|0|0|0000|
|1|1|0001|
|2|2|0010|
|3|3|0011|
|4|4|0100|
|5|5|0101|
|6|6|0110|
|7|7|0111|
|8|8|1000|
|9|9|1001|
|**A**|**10**|1010|
|**B**|**11**|1011|
|**C**|**12**|1100|
|**D**|**13**|1101|
|**E**|**14**|1110|
|**F**|**15**|1111|

> [!tip] Astuce mnémotechnique A=10, B=11, C=12, D=13, E=14, F=15 "**A**près 9 vient **10**" → A = 10

### Structure et valeur positionnelle

Chaque position représente une puissance de 16 :

```
Position :    3      2      1      0
              ↓      ↓      ↓      ↓
Puissance :  16³    16²    16¹    16⁰
Valeur :    4096    256     16      1
```

> [!example] Exemple : Décomposition de 2A3F₁₆
> 
> ```
> 2A3F₁₆ = (2 × 16³) + (10 × 16²) + (3 × 16¹) + (15 × 16⁰)
>        = (2 × 4096) + (10 × 256) + (3 × 16) + (15 × 1)
>        = 8192 + 2560 + 48 + 15
>        = 10 815₁₀
> ```

### Notation

```bash
# Notations courantes
0x2A3F    # Préfixe 0x (C, Python, JavaScript, le plus courant)
2A3F₁₆    # Notation mathématique avec indice
#2A3F     # Couleurs HTML/CSS (avec #)
2A3Fh     # Notation assembleur (certains)
\x2A      # Séquences d'échappement
```

### Relation binaire ↔ hexadécimal

> [!info] Correspondance parfaite **4 bits = 1 chiffre hexadécimal**
> 
> Cette relation rend les conversions binaire ↔ hexa très simples !

> [!example] Exemple de conversion directe
> 
> ```
> Binaire : 1101 1010 0011 1111
>            ↓    ↓    ↓    ↓
> Hexa    :  D    A    3    F
> 
> Résultat : 0xDA3F
> ```

### Cas d'usage réels

> [!tip] Applications pratiques
> 
> **1. Couleurs web (RGB)**
> 
> ```css
> /* #RRGGBB - Rouge Vert Bleu */
> #FF0000  →  255,0,0    (rouge pur)
> #00FF00  →  0,255,0    (vert pur)
> #0000FF  →  0,0,255    (bleu pur)
> #FFFFFF  →  255,255,255 (blanc)
> #000000  →  0,0,0      (noir)
> #A020F0  →  160,32,240 (violet)
> ```
> 
> **2. Adresses mémoire**
> 
> ```
> 0x00400000  →  Début du code
> 0x7FFFFFFF  →  Limite stack (32-bit)
> 0xDEADBEEF  →  Valeur de debug célèbre
> ```
> 
> **3. Adresses MAC**
> 
> ```
> 00:1A:2B:3C:4D:5E
> ```
> 
> **4. Codes caractères Unicode**
> 
> ```
> U+0041  →  'A'
> U+20AC  →  '€'
> ```

### Compter en hexadécimal

> [!example] Comptage de 0 à 31
> 
> ```
> 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
> 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F
> 
> Après 09 → 0A (pas 010 !)
> Après 0F → 10 (seize en décimal)
> Après 1F → 20 (trente-deux en décimal)
> ```

### Pièges courants

> [!warning] Attention ! ❌ Confondre `10` hexa avec `10` décimal : `0x10 = 16₁₀` (pas 10 !) ✅ **Toujours utiliser le préfixe** : `0x10` est clair
> 
> ❌ Écrire `#FFFFF` (5 chiffres) pour du blanc en CSS ✅ **Respecter le format** : `#FFFFFF` (6 chiffres pour RGB)
> 
> ❌ Oublier que A-F peuvent être majuscules ou minuscules ✅ **Convention** : Généralement majuscules (`0x2A` > `0x2a`) mais les deux sont valides

---

## 🔄 Conversions entre les systèmes

### Vue d'ensemble

```
        Binaire (base 2)
             ↕
        Décimal (base 10) ← Centre de conversion
             ↕
     Hexadécimal (base 16)
```

> [!info] Stratégie générale Le décimal sert souvent d'**intermédiaire** pour les conversions complexes.
> 
> Exception : Binaire ↔ Hexadécimal (conversion directe très simple !)

---

### 🔟→🤖 Décimal vers Binaire

#### Méthode : Divisions successives par 2

> [!example] Principe
> 
> 1. Diviser le nombre par 2
> 2. Noter le **reste** (0 ou 1)
> 3. Continuer avec le **quotient**
> 4. S'arrêter quand le quotient = 0
> 5. Lire les restes de **bas en haut**

> [!example] Exemple : Convertir 45₁₀ en binaire
> 
> ```
> 45 ÷ 2 = 22  reste 1  ↑
> 22 ÷ 2 = 11  reste 0  |
> 11 ÷ 2 = 5   reste 1  |
> 5  ÷ 2 = 2   reste 1  | Lire de bas en haut
> 2  ÷ 2 = 1   reste 0  |
> 1  ÷ 2 = 0   reste 1  ↓
> 
> Résultat : 45₁₀ = 101101₂
> ```

> [!example] Vérification
> 
> ```
> 101101₂ = (1×32) + (0×16) + (1×8) + (1×4) + (0×2) + (1×1)
>         = 32 + 8 + 4 + 1
>         = 45₁₀ ✓
> ```

#### Méthode alternative : Soustraction des puissances de 2

```
Puissances de 2 : 128 64 32 16 8 4 2 1

Pour 45 :
- 128 > 45 → 0
- 64 > 45  → 0
- 32 ≤ 45  → 1  (45 - 32 = 13)
- 16 > 13  → 0
- 8 ≤ 13   → 1  (13 - 8 = 5)
- 4 ≤ 5    → 1  (5 - 4 = 1)
- 2 > 1    → 0
- 1 ≤ 1    → 1  (1 - 1 = 0)

Résultat : 00101101₂
```

---

### 🤖→🔟 Binaire vers Décimal

#### Méthode : Somme pondérée

> [!example] Principe Multiplier chaque bit par la puissance de 2 correspondante, puis additionner.

> [!example] Exemple : Convertir 11010110₂ en décimal
> 
> ```
> Position :   7   6   5   4   3   2   1   0
> Binaire  :   1   1   0   1   0   1   1   0
> Puissance: 128  64  32  16   8   4   2   1
> 
> Calcul :
> (1 × 128) + (1 × 64) + (0 × 32) + (1 × 16) + (0 × 8) + (1 × 4) + (1 × 2) + (0 × 1)
> = 128 + 64 + 16 + 4 + 2
> = 214₁₀
> ```

> [!tip] Astuce rapide Ne calculer que les bits à 1 :
> 
> ```
> 11010110₂
>   ↓ ↓  ↓↓
> 128+64+16+4+2 = 214₁₀
> ```

---

### 🔟→🎨 Décimal vers Hexadécimal

#### Méthode : Divisions successives par 16

> [!example] Principe
> 
> 1. Diviser le nombre par 16
> 2. Noter le **reste** (0-15, convertir 10-15 en A-F)
> 3. Continuer avec le **quotient**
> 4. S'arrêter quand le quotient = 0
> 5. Lire les restes de **bas en haut**

> [!example] Exemple : Convertir 2547₁₀ en hexadécimal
> 
> ```
> 2547 ÷ 16 = 159  reste 3   ↑
> 159  ÷ 16 = 9    reste 15  | (F en hexa)
> 9    ÷ 16 = 0    reste 9   ↓
> 
> Résultat : 2547₁₀ = 9F3₁₆ (ou 0x9F3)
> ```

> [!example] Vérification
> 
> ```
> 9F3₁₆ = (9 × 256) + (15 × 16) + (3 × 1)
>       = 2304 + 240 + 3
>       = 2547₁₀ ✓
> ```

#### Table de conversion rapide pour les restes

|Reste|Hexa|Reste|Hexa|
|---|---|---|---|
|0|0|8|8|
|1|1|9|9|
|2|2|10|**A**|
|3|3|11|**B**|
|4|4|12|**C**|
|5|5|13|**D**|
|6|6|14|**E**|
|7|7|15|**F**|

---

### 🎨→🔟 Hexadécimal vers Décimal

#### Méthode : Somme pondérée

> [!example] Principe Multiplier chaque chiffre par la puissance de 16 correspondante, puis additionner.

> [!example] Exemple : Convertir 0xA3C en décimal
> 
> ```
> Position :   2     1     0
> Hexa     :   A     3     C
> Décimal  :  10     3    12  (conversion A→10, C→12)
> Puissance: 256    16     1
> 
> Calcul :
> (10 × 256) + (3 × 16) + (12 × 1)
> = 2560 + 48 + 12
> = 2620₁₀
> ```

> [!tip] Méthode progressive (de gauche à droite)
> 
> ```
> 0xA3C
> 
> A × 16 = 160
> 160 + 3 = 163
> 163 × 16 = 2608
> 2608 + 12 = 2620₁₀
> ```

---

### 🤖↔🎨 Binaire ↔ Hexadécimal (Conversion directe !)

#### 🤖→🎨 Binaire vers Hexadécimal

> [!info] Méthode ultra-rapide **1 chiffre hexa = 4 bits exactement**
> 
> Grouper par 4 bits (de droite à gauche), puis convertir chaque groupe.

> [!example] Exemple 1 : Convertir 11010110₂ en hexadécimal
> 
> ```
> Étape 1 : Grouper par 4 bits (depuis la droite)
> 1101 0110
> 
> Étape 2 : Convertir chaque groupe
> 1101 → 13 → D
> 0110 → 6  → 6
> 
> Résultat : 0xD6
> ```

> [!example] Exemple 2 : Avec complétion de zéros
> 
> ```
> Binaire : 110101101₂ (9 bits)
> 
> Étape 1 : Compléter à gauche pour avoir un multiple de 4
> 0001 1010 1101
> 
> Étape 2 : Convertir
> 0001 → 1
> 1010 → 10 → A
> 1101 → 13 → D
> 
> Résultat : 0x1AD
> ```

#### Tableau de conversion binaire ↔ hexa

|Binaire|Hexa|Binaire|Hexa|
|---|---|---|---|
|0000|0|1000|8|
|0001|1|1001|9|
|0010|2|1010|A|
|0011|3|1011|B|
|0100|4|1100|C|
|0101|5|1101|D|
|0110|6|1110|E|
|0111|7|1111|F|

> [!tip] Mémorisation Apprendre ce tableau par cœur ! Il est fondamental pour tous les développeurs.

#### 🎨→🤖 Hexadécimal vers Binaire

> [!info] Méthode ultra-rapide (inverse) Convertir chaque chiffre hexa en 4 bits.

> [!example] Exemple : Convertir 0x2BF en binaire
> 
> ```
> 2 → 0010
> B → 1011 (B = 11)
> F → 1111 (F = 15)
> 
> Résultat : 0010 1011 1111₂
> Ou sans espaces : 001010111111₂
> ```

> [!example] Cas pratique : Couleur CSS
> 
> ```css
> #A3F → Convertir en RGB binaire
> 
> A → 1010
> 3 → 0011
> F → 1111
> 
> Rouge (A)   : 1010 → 10₁₀
> Vert (3)    : 0011 → 3₁₀
> Bleu (F)    : 1111 → 15₁₀
> 
> rgb(10, 3, 15) en décimal
> ```

---

### 🔄 Tableau récapitulatif des méthodes

|Conversion|Méthode|Complexité|
|---|---|---|
|Déc → Bin|Divisions par 2|Moyenne|
|Bin → Déc|Somme pondérée (puissances de 2)|Facile|
|Déc → Hex|Divisions par 16|Moyenne|
|Hex → Déc|Somme pondérée (puissances de 16)|Facile|
|**Bin → Hex**|**Groupement par 4 bits**|**Très facile**|
|**Hex → Bin**|**4 bits par chiffre hexa**|**Très facile**|

> [!tip] Stratégie optimale
> 
> - Pour Bin ↔ Hex : **Conversion directe** (très rapide !)
> - Pour Déc ↔ Bin/Hex : Passer par les méthodes de division/multiplication
> - Pour Bin ↔ Déc via Hex : Parfois plus rapide de passer par l'hexa comme intermédiaire

---

## 📊 Tableau récapitulatif

### Comparaison des trois systèmes

|Critère|Décimal|Binaire|Hexadécimal|
|---|---|---|---|
|**Base**|10|2|16|
|**Symboles**|0-9|0-1|0-9, A-F|
|**Préfixe courant**|aucun|`0b`|`0x`|
|**Usage principal**|Humains|Machines|Développeurs|
|**Compacité**|⭐⭐⭐|⭐|⭐⭐⭐⭐|
|**Lisibilité**|⭐⭐⭐⭐⭐|⭐⭐|⭐⭐⭐⭐|
|**Conversion bin**|Complexe|-|Triviale|

### Table de conversion rapide (0-255)

|Déc|Bin|Hex|Déc|Bin|Hex|
|---|---|---|---|---|---|
|0|00000000|0x00|16|00010000|0x10|
|1|00000001|0x01|32|00100000|0x20|
|2|00000010|0x02|64|01000000|0x40|
|4|00000100|0x04|128|10000000|0x80|
|8|00001000|0x08|255|11111111|0xFF|
|10|00001010|0x0A|256|100000000|0x100|
|15|00001111|0x0F|512|1000000000|0x200|
|16|00010000|0x10|1024|10000000000|0x400|

### Puissances utiles à mémoriser

```
Puissances de 2 :           Puissances de 16 :
2⁰  = 1                     16⁰ = 1
2¹  = 2                     16¹ = 16
2²  = 4                     16² = 256
2³  = 8                     16³ = 4 096
2⁴  = 16                    16⁴ = 65 536
2⁵  = 32
2⁶  = 64
2⁷  = 128
2⁸  = 256    (1 octet)
2¹⁰ = 1 024  (1 Ko)
2¹⁶ = 65 536
2²⁰ = 1 048 576 (1 Mo)
```

---

## 🏋️ Exercices pratiques

### Niveau Débutant

> [!example] Exercice 1 : Binaire vers Décimal Convertir les nombres binaires suivants en décimal :
> 
> 1. `1010₂`
> 2. `11001₂`
> 3. `10000000₂`
> 
> <details> <summary>Solutions</summary>
> 
> 4. `1010₂ = (1×8) + (0×4) + (1×2) + (0×1) = 8 + 2 = 10₁₀`
> 5. `11001₂ = (1×16) + (1×8) + (0×4) + (0×2) + (1×1) = 16 + 8 + 1 = 25₁₀`
> 6. `10000000₂ = (1×128) = 128₁₀`
> 
> </details>

> [!example] Exercice 2 : Décimal vers Binaire Convertir les nombres décimaux suivants en binaire :
> 
> 7. `13₁₀`
> 8. `31₁₀`
> 9. `100₁₀`
> 
> <details> <summary>Solutions</summary>
> 
> 10. `13₁₀ = 1101₂`
>     
>     ```
>     13 ÷ 2 = 6 reste 1
>     6 ÷ 2 = 3 reste 0
>     3 ÷ 2 = 1 reste 1
>     1 ÷ 2 = 0 reste 1
>     Lecture : 1101
>     ```
>     
> 11. `31₁₀ = 11111₂` (5 bits à 1)
>     
> 12. `100₁₀ = 1100100₂`
>     
>     ```
>     100 ÷ 2 = 50 reste 0
>     50 ÷ 2 = 25 reste 0
>     25 ÷ 2 = 12 reste 1
>     12 ÷ 2 = 6 reste 0
>     6 ÷ 2 = 3 reste 0
>     3 ÷ 2 = 1 reste 1
>     1 ÷ 2 = 0 reste 1
>     Lecture : 1100100
>     ```
>     
> 
> </details>

> [!example] Exercice 3 : Hexadécimal vers Décimal Convertir les nombres hexadécimaux suivants en décimal :
> 
> 13. `0x1F`
> 14. `0xA0`
> 15. `0xFF`
> 
> <details> <summary>Solutions</summary>
> 
> 16. `0x1F = (1×16) + (15×1) = 16 + 15 = 31₁₀`
> 17. `0xA0 = (10×16) + (0×1) = 160₁₀`
> 18. `0xFF = (15×16) + (15×1) = 240 + 15 = 255₁₀` (valeur max d'un octet)
> 
> </details>

> [!example] Exercice 4 : Binaire ↔ Hexadécimal Effectuer les conversions suivantes :
> 
> 19. `11011010₂` → Hexadécimal
> 20. `0x3C` → Binaire
> 21. `101111110001₂` → Hexadécimal
> 
> <details> <summary>Solutions</summary>
> 
> 22. `11011010₂ = 0xDA`
>     
>     ```
>     1101 1010
>      ↓    ↓
>      D    A
>     ```
>     
> 23. `0x3C = 00111100₂`
>     
>     ```
>     3 → 0011
>     C → 1100
>     Résultat : 00111100
>     ```
>     
> 24. `101111110001₂ = 0xBF1`
>     
>     ```
>     0000 1011 1111 0001 (ajout de zéros à gauche)
>       0    B    F    1
>     ```
>     
> 
> </details>

---

### Niveau Intermédiaire

> [!example] Exercice 5 : Décimal vers Hexadécimal Convertir les nombres décimaux suivants en hexadécimal :
> 
> 1. `255₁₀`
> 2. `4096₁₀`
> 3. `1000₁₀`
> 
> <details> <summary>Solutions</summary>
> 
> 4. `255₁₀ = 0xFF`
>     
>     ```
>     255 ÷ 16 = 15 reste 15 (F)
>     15 ÷ 16 = 0 reste 15 (F)
>     ```
>     
> 5. `4096₁₀ = 0x1000`
>     
>     ```
>     4096 ÷ 16 = 256 reste 0
>     256 ÷ 16 = 16 reste 0
>     16 ÷ 16 = 1 reste 0
>     1 ÷ 16 = 0 reste 1
>     ```
>     
> 6. `1000₁₀ = 0x3E8`
>     
>     ```
>     1000 ÷ 16 = 62 reste 8
>     62 ÷ 16 = 3 reste 14 (E)
>     3 ÷ 16 = 0 reste 3
>     ```
>     
> 
> </details>

> [!example] Exercice 6 : Conversions multiples Pour le nombre `156₁₀`, donner :
> 
> 7. Sa représentation en binaire
> 8. Sa représentation en hexadécimal
> 9. Vérifier la cohérence binaire ↔ hexadécimal
> 
> <details> <summary>Solutions</summary>
> 
> 10. **Binaire** : `156₁₀ = 10011100₂`
>     
>     ```
>     156 = 128 + 28 = 128 + 16 + 8 + 4
>     = 2⁷ + 2⁴ + 2³ + 2²
>     = 10011100₂
>     ```
>     
> 11. **Hexadécimal** : `156₁₀ = 0x9C`
>     
>     ```
>     156 ÷ 16 = 9 reste 12 (C)
>     9 ÷ 16 = 0 reste 9
>     ```
>     
> 12. **Vérification** :
>     
>     ```
>     10011100₂ → grouper : 1001 1100
>                            ↓    ↓
>                            9    C  → 0x9C ✓
>     ```
>     
> 
> </details>

> [!example] Exercice 7 : Couleurs CSS Décoder les couleurs suivantes et donner leurs valeurs RGB en décimal :
> 
> 13. `#FF5733`
> 14. `#00FF00`
> 15. `#A1B2C3`
> 
> <details> <summary>Solutions</summary>
> 
> 16. `#FF5733` :
>     - Rouge (FF) : 255₁₀
>     - Vert (57) : 87₁₀ → `(5×16) + 7 = 87`
>     - Bleu (33) : 51₁₀ → `(3×16) + 3 = 51`
>     - RGB : `rgb(255, 87, 51)` (Orange vif)
> 17. `#00FF00` :
>     - Rouge (00) : 0₁₀
>     - Vert (FF) : 255₁₀
>     - Bleu (00) : 0₁₀
>     - RGB : `rgb(0, 255, 0)` (Vert pur)
> 18. `#A1B2C3` :
>     - Rouge (A1) : 161₁₀ → `(10×16) + 1 = 161`
>     - Vert (B2) : 178₁₀ → `(11×16) + 2 = 178`
>     - Bleu (C3) : 195₁₀ → `(12×16) + 3 = 195`
>     - RGB : `rgb(161, 178, 195)` (Bleu grisâtre)
> 
> </details>

---

### Niveau Avancé

> [!example] Exercice 8 : Additions en binaire Effectuer les additions suivantes directement en binaire :
> 
> 1. `1010₂ + 0110₂`
> 2. `1111₂ + 0001₂`
> 3. `10101₂ + 11010₂`
> 
> <details> <summary>Solutions</summary>
> 
> 4. `1010₂ + 0110₂ = 10000₂`
>     
>     ```
>       1010
>     + 0110
>     ------
>      10000  (= 16₁₀)
>     
>     Vérification : 10₁₀ + 6₁₀ = 16₁₀ ✓
>     ```
>     
> 5. `1111₂ + 0001₂ = 10000₂`
>     
>     ```
>       1111
>     + 0001
>     ------
>      10000  (= 16₁₀)
>     
>     15₁₀ + 1₁₀ = 16₁₀ ✓
>     ```
>     
> 6. `10101₂ + 11010₂ = 101111₂`
>     
>     ```
>       10101
>     + 11010
>     -------
>      101111  (= 47₁₀)
>     
>     21₁₀ + 26₁₀ = 47₁₀ ✓
>     ```
>     
> 
> </details>

> [!example] Exercice 9 : Conversions avec grands nombres Convertir :
> 
> 7. `2048₁₀` en binaire et hexadécimal
> 8. `0xDEADBEEF` en décimal
> 9. `11111111111111111111111111111111₂` (32 bits) en hexadécimal
> 
> <details> <summary>Solutions</summary>
> 
> 10. **2048₁₀** :
>     
>     - Binaire : `100000000000₂` (2¹¹ = 2048)
>     - Hexadécimal : `0x800`
>     
>     ```
>     1000 0000 0000
>      8    0    0
>     ```
>     
> 11. **0xDEADBEEF** (nombre célèbre en debug) :
>     
>     ```
>     D × 16⁷ = 13 × 268435456 = 3489660928
>     E × 16⁶ = 14 × 16777216 = 234881024
>     A × 16⁵ = 10 × 1048576 = 10485760
>     D × 16⁴ = 13 × 65536 = 851968
>     B × 16³ = 11 × 4096 = 45056
>     E × 16² = 14 × 256 = 3584
>     E × 16¹ = 14 × 16 = 224
>     F × 16⁰ = 15 × 1 = 15
>     
>     Total = 3735928559₁₀
>     ```
>     
> 12. **32 bits à 1** :
>     
>     ```
>     11111111 11111111 11111111 11111111₂
>     = 0xFFFFFFFF
>     = 4294967295₁₀ (valeur max sur 32 bits non signé)
>     ```
>     
> 
> </details>

> [!example] Exercice 10 : Masques réseau Un masque de sous-réseau est `255.255.248.0`. Convertir chaque octet en binaire :
> 
> <details> <summary>Solution</summary>
> 
> ```
> 255 → 11111111
> 255 → 11111111
> 248 → 11111000  (248 = 256 - 8 = 11111000)
> 0   → 00000000
> 
> Masque complet : 11111111.11111111.11111000.00000000
> Notation CIDR : /21 (21 bits à 1)
> ```
> 
> En hexadécimal : `0xFF.FF.F8.00`
> 
> </details>

---

## 💡 Bonnes pratiques et astuces

### Préfixes et notations

> [!tip] Toujours préciser la base
> 
> ```bash
> ✅ BIEN :
> 0b1010    # Clair : binaire
> 0x1A      # Clair : hexadécimal
> 42        # Décimal par défaut
> 
> ❌ ÉVITER :
> 1010      # Ambigu : binaire ou décimal ?
> 1A        # Erreur : ressemble à une variable
> ```

### Formatage pour la lisibilité

> [!tip] Groupement visuel Pour les grands nombres, grouper les chiffres :
> 
> ```bash
> # Binaire : groupes de 4 ou 8 bits
> 1101 1010 1100 0011  # Plus lisible
> 11011010 11000011    # Octets
> 
> # Hexadécimal : groupes de 2 ou 4
> 0xDEAD BEEF  # Séparé par espaces
> 0xDEAD_BEEF  # Underscore (Python 3.6+)
> 
> # Décimal : groupes de 3
> 1 000 000 ou 1_000_000
> ```

### Vérification rapide

> [!tip] Cohérence binaire-hexa Vérifier qu'un nombre binaire et hexa représentent la même valeur :
> 
> 1. Convertir le binaire en hexa (groupes de 4)
> 2. Comparer avec l'hexa donné
> 
> C'est **beaucoup plus rapide** que de passer par le décimal !

### Valeurs mémorables

> [!info] Nombres à connaître par cœur
> 
> ```
> 255₁₀ = 0xFF = 11111111₂  (max 8 bits)
> 256₁₀ = 0x100 = 100000000₂ (9 bits)
> 1024₁₀ = 0x400 = 10000000000₂ (1 Ko)
> 
> Puissances de 2 jusqu'à 2¹⁶ (65536)
> A=10, B=11, C=12, D=13, E=14, F=15
> ```

### Calculatrices et outils

> [!tip] Outils pratiques **En ligne de commande** :
> 
> ```bash
> # Python (interactif)
> bin(42)      # '0b101010'
> hex(42)      # '0x2a'
> int('101010', 2)   # 42
> int('2a', 16)      # 42
> 
> # Calculatrice système (Linux)
> echo "obase=16; 255" | bc    # FF
> echo "obase=2; 255" | bc     # 11111111
> 
> # Calculatrice Windows : mode Programmeur
> # Calculatrice macOS : Affichage > Programmeur
> ```

### Conventions d'écriture

> [!info] Standards courants
> 
> |Contexte|Notation|Exemple|
> |---|---|---|
> |Code C/C++|`0x` pour hexa, `0b` pour binaire|`0xFF`, `0b1010`|
> |Python|`0x` pour hexa, `0b` pour binaire|`0xFF`, `0b1010`|
> |JavaScript|`0x` pour hexa, `0b` pour binaire (ES6+)|`0xFF`, `0b1010`|
> |CSS|`#` pour couleurs|`#FF5733`|
> |Assembleur|`h` ou `0x` pour hexa|`2Ah`, `0x2A`|
> |URLs|`%` suivi de hexa|`%20` (espace)|

### Pièges à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Confusion octal/décimal**
> 
> ```javascript
> // En JavaScript/C, un 0 devant = octal !
> 010 = 8₁₀  // Pas 10 !
> 077 = 63₁₀ // Pas 77 !
> ```
> 
> **2. Majuscules vs minuscules**
> 
> ```
> 0xABCD = 0xabcd  // Identique, mais...
> 0X vs 0x         // Préférer 0x (minuscule)
> A-F vs a-f       // Convention : majuscules
> ```
> 
> **3. Oubli de bits de poids fort**
> 
> ```
> 11₂ ≠ 00000011₂  // Techniquement égaux mais...
> Pour un octet : TOUJOURS écrire 8 bits
> ```
> 
> **4. Débordement (overflow)**
> 
> ```
> Sur 8 bits : max = 255₁₀ = 0xFF = 11111111₂
> 255 + 1 = 0 (en arithmétique 8 bits non signée)
> ```

### Astuces de calcul mental

> [!tip] Calculs rapides
> 
> **Puissances de 2** :
> 
> ```
> Doubler = décaler à gauche (×2)
> 8 × 16 = 8 × 2⁴ = 128
> 
> 1 Ko = 1024 ≈ 1000
> 1 Mo = 1024 Ko ≈ 1 million
> 1 Go = 1024 Mo ≈ 1 milliard
> ```
> 
> **Conversion hexa rapide** :
> 
> ```
> 0x10 = 16₁₀  (1 × 16)
> 0x20 = 32₁₀  (2 × 16)
> 0x100 = 256₁₀ (16²)
> 
> 0xF0 = 240₁₀ (15 × 16)
> 0xFF = 255₁₀ (16² - 1)
> ```
> 
> **Pattern binaire** :
> 
> ```
> Tous les bits à 1 sur n bits = 2ⁿ - 1
> 11111111₂ (8 bits) = 2⁸ - 1 = 255₁₀
> 1111₂ (4 bits) = 2⁴ - 1 = 15₁₀
> ```

### Documentation de code

> [!tip] Bien commenter
> 
> ```python
> # ✅ BIEN : Préciser la base
> mask = 0xFF  # 255 en décimal, masque pour 1 octet
> flags = 0b10110000  # Bits 7,5,4 activés
> color = 0x1A2B3C  # RGB: 26, 43, 60
> 
> # ❌ MAL : Ambigu
> value = 255  # Quel format ?
> number = 1010  # Binaire ou décimal ?
> ```

---

## 🎯 Résumé et points clés

> [!info] À retenir absolument
> 
> **Les trois systèmes** :
> 
> - **Décimal (base 10)** : 0-9, notre système naturel
> - **Binaire (base 2)** : 0-1, langage machine
> - **Hexadécimal (base 16)** : 0-9 A-F, notation compacte
> 
> **Conversions essentielles** :
> 
> - Binaire ↔ Hexadécimal : **4 bits = 1 chiffre hexa** (très facile !)
> - Décimal ↔ Binaire : Divisions/multiplications par 2
> - Décimal ↔ Hexadécimal : Divisions/multiplications par 16
> 
> **Relations importantes** :
> 
> - 1 octet = 8 bits = 2 chiffres hexa
> - 0xFF = 255₁₀ = 11111111₂ (valeur max d'un octet)
> - 0x10 = 16₁₀ (ne pas confondre avec 10₁₀)
> 
> **Usages pratiques** :
> 
> - Binaire : Flags, masques, opérations bit-à-bit
> - Hexadécimal : Couleurs (#RGB), adresses mémoire, debugging
> - Décimal : Interface utilisateur, calculs mathématiques

> [!tip] Pour aller plus loin Maintenant que vous maîtrisez les conversions de base, vous pourrez explorer :
> 
> - Les opérations bit-à-bit (AND, OR, XOR, décalages)
> - La représentation des nombres négatifs (complément à deux)
> - Les nombres à virgule flottante (IEEE 754)
> - L'encodage des caractères (ASCII, Unicode)

---

## 📚 Ressources complémentaires

> [!info] Outils en ligne
> 
> - **Calculatrice programmeur** : Windows (Win + R → calc), macOS, Linux
> - **Python** : Interpréteur interactif pour conversions rapides
> - **Convertisseurs en ligne** : RapidTables, BinaryHexConverter
> - **Visualisateurs** : Pour comprendre les opérations bit-à-bit

> [!tip] Pratique régulière
> 
> - Convertir les chiffres des plaques d'immatriculation
> - Décoder les couleurs de sites web (F12 > DevTools)
> - Analyser les masques réseau en administration système
> - Examiner les dumps mémoire en développement

---

**🎓 Fin du cours - Bonne pratique et n'hésitez pas à revenir consulter ce guide !**