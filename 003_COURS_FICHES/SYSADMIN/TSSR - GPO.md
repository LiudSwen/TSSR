# ⚡ L'essentiel en 5 minutes - Les GPO (Group Policy Objects)

## 📌 C'est quoi en 2 lignes ?

Les GPO sont des **collections virtuelles de politiques de sécurité** qui permettent de gérer centralement un parc informatique Windows via Active Directory. Elles automatisent la configuration des ordinateurs et utilisateurs (sécurité, logiciels, interface, scripts).

---

## 💡 Concepts clés à retenir :

- **GPO** : Objet de stratégie de groupe permettant la gestion centralisée des configurations Windows via AD
- **LSDOU** : Ordre d'application des GPO = Local → Site → Domain → OU (la dernière écrase les précédentes)
- **Enforced** : GPO forcée qui ignore le blocage d'héritage et prioritaire sur les niveaux inférieurs
- **Link Enabled** : Active/désactive le **lien** entre une GPO et une OU (pas la GPO elle-même)
- **Security Filtering** : Mécanisme de filtrage par permissions (Read + Apply Group Policy) pour cibler les objets AD

---

## 💻 Structure technique d'une GPO :

```bash
# 📁 3 composantes essentielles
1. Entrée LDAP : CN=Policies,CN=System,DC=domaine,DC=local
   → Nom, GUID, droits d'édition (infos administratives)

2. Contenu GPO : \\serveur\SYSVOL\domaine\Policies\{GUID}
   → Fichiers d'instructions (actions concrètes)

3. Attribut gPLink : Sur OU/Site/Domaine
   → GUID, chemin LDAP, ordre, état d'application
```

```powershell
# 🪟 Consoles Windows
gpedit.msc         # Stratégies locales (sur chaque machine)
gpmc.msc           # Gestion centralisée GPO (sur serveur AD)
gpupdate /force    # Forcer application des GPO
gpresult /r        # Vérifier les GPO appliquées
```

---

## 📐 Règles de priorité :

**LSDOU = Ordre d'application des GPO**

```
1. Local     → Stratégies locales (gpedit.msc)
2. Site      → GPO liées au site AD
3. Domain    → GPO du domaine
4. OU        → GPO des OU (parent → enfant)

⚠️ Principe : La dernière appliquée gagne (LIFO)
```

**Sur une OU avec plusieurs GPO :**

```
GPO1 (ordre 3) → appliquée en 1er
GPO2 (ordre 2) → appliquée en 2ème  
GPO3 (ordre 1) → appliquée en dernier ✅ (prioritaire)

💡 LIFO : Last In, First Out
```

**Exceptions prioritaires :**

```
1. GPO Enforced → Ignore tout (même blocage héritage)
2. Blocage d'héritage sur OU → Bloque GPO niveaux supérieurs
3. Security Filtering → Si pas de droit "Apply", GPO ignorée
```

---

## ⚠️ Pièges à éviter :

- ❌ **Modifier Default Domain Policy** : Ne JAMAIS toucher aux GPO par défaut du domaine
- ❌ **Confondre Link Enabled et GPO Status** : Link = lien OU↔GPO / Status = état global de la GPO
- ❌ **Abuser de Enforced** : Réservé au Tier 0 (contrôleurs de domaine), complexifie le dépannage
- ❌ **Utiliser dossiers Users/Computers par défaut** : Créer une hiérarchie d'OU propre
- ❌ **Bloquer l'héritage systématiquement** : Crée des incohérences, privilégier le filtrage de sécurité
- ❌ **GPO monolithiques** : Préférer plusieurs petites GPO spécialisées qu'une énorme

---

## ✅ Bonnes pratiques :

- ✅ **Hiérarchie OU logique** : Structure claire = gestion simplifiée des GPO
- ✅ **Nomenclature descriptive** : Nom explicite (ex: "SEC-WIN10-Bureautique" au lieu de "GPO1")
- ✅ **Désactiver sections inutiles** : Si GPO ne contient que du "User", désactiver "Computer" (et vice-versa)
- ✅ **Supprimer lien vs désactiver** : Retirer le lien plutôt que mettre "Link Enabled = No"
- ✅ **Security Filtering ciblé** : Retirer "Authenticated Users" et ajouter groupes AD spécifiques
- ✅ **Tester avant prod** : Valider sur OU de test avec `gpresult /r`

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**GUID**|Identifiant unique de la GPO (ex: {6AC1786C-016F-11D2-945F-00C04fB984F9})|
|**SYSVOL**|Partage réseau AD contenant les fichiers GPO (\domaine\SYSVOL)|
|**Authenticated Users**|Groupe par défaut ayant "Apply Group Policy" = tous les utilisateurs/ordinateurs du domaine|
|**WMI Filtering**|Filtre avancé basé sur requêtes WMI (OS, RAM, disque...) pour appliquer GPO|
|**Loopback Processing**|Mode spécial pour appliquer GPO utilisateur basé sur l'ordinateur (serveurs RDS)|
|**gPLink**|Attribut LDAP d'une OU listant les GPO liées + ordre + état|

---

## 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : LSDOU = ordre priorité (Local < Site < Domain < OU), dernière appliquée gagne sauf si Enforced
2. 💻 **Pratique** : Pour appliquer GPO = lier à OU + objet AD doit avoir droits "Read" ET "Apply Group Policy"
3. ⚠️ **Piège** : Enforced ignore TOUT (héritage bloqué inclus) → usage exceptionnel uniquement (Tier 0)

---

## 🔍 Droits d'application GPO :

```bash
# Condition d'application
GPO appliquée SI :
  ✅ Liée à Site/Domaine/OU
  ET
  ✅ Objet AD possède : Read + Apply Group Policy

# Workflow Security Filtering
1. Par défaut → "Authenticated Users" a "Apply Group Policy"
2. Restreindre → Retirer "Authenticated Users"
3. Ajouter → Groupe AD spécifique avec "Read + Apply"
```

**Cas pratique :**

```
❌ Mauvais : GPO liée à OU mais utilisateur n'a pas "Apply"
   → GPO ignorée

✅ Bon : GPO liée + Groupe "Comptables" a "Read + Apply"  
   → Seuls membres de "Comptables" reçoivent GPO
```

---

## 📊 Compatibilité OS :

|OS|Support GPO|Notes|
|---|---|---|
|**Windows**|✅ Complet|Client et serveur|
|**Linux**|⚠️ Partiel|Implémentations tierces très limitées (ignorer la plupart des GPO)|
|**Sans domaine**|🔒 Local uniquement|`gpedit.msc` sur machine isolée|