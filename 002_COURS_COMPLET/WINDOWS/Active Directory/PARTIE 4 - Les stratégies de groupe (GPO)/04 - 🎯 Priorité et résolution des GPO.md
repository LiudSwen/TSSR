

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🔍 Introduction

La gestion des priorités des GPO est un mécanisme crucial dans Active Directory qui détermine quels paramètres seront réellement appliqués lorsque plusieurs GPO configurent le même paramètre. Comprendre ce système permet d'éviter des conflits de configuration et d'assurer une application cohérente des politiques dans votre infrastructure.

> [!info] Pourquoi c'est important Dans un environnement d'entreprise réel, des dizaines voire des centaines de GPO peuvent s'appliquer à un même utilisateur ou ordinateur. Sans une compréhension claire de la priorité, vous risquez des comportements imprévisibles et des configurations contradictoires.

---

## 📊 Ordre de traitement LSDOU

### Principe fondamental

Les GPO sont traitées dans un ordre spécifique appelé **LSDOU**, qui détermine quelle politique a la priorité en cas de conflit. Cet acronyme représente :

1. **L**ocal (Stratégie locale)
2. **S**ite (Stratégies du site AD)
3. **D**omain (Stratégies du domaine)
4. **O**U (Stratégies des unités organisationnelles)

> [!example] Ordre d'application Imaginez un utilisateur dans l'OU "IT/Admins" du domaine "entreprise.local", dans le site "Paris" :
> 
> 1. **Local** : Stratégie locale de l'ordinateur
> 2. **Site** : GPO liées au site "Paris"
> 3. **Domain** : GPO liées au domaine "entreprise.local"
> 4. **OU** : GPO liées à "IT", puis à "Admins"

### Règle de priorité

**La dernière GPO appliquée a la priorité finale**. Autrement dit, les paramètres définis dans les OU ont la priorité sur ceux du domaine, qui ont eux-mêmes la priorité sur ceux du site, et ainsi de suite.

```
Local  →  Site  →  Domain  →  OU Parent  →  OU Enfant
(Plus faible priorité)              (Plus forte priorité)
```

### Hiérarchie des OU imbriquées

Lorsque plusieurs OU sont imbriquées, l'ordre d'application va de la plus éloignée vers la plus proche de l'objet :

```
Domain
  └─ OU: Département
       └─ OU: Service
            └─ OU: Équipe  ← Plus forte priorité
```

> [!tip] Astuce de visualisation Pour savoir quelles GPO s'appliquent à un objet et dans quel ordre, utilisez la commande :
> 
> ```powershell
> gpresult /Scope User /v
> gpresult /Scope Computer /v
> ```

### Ordre des GPO au même niveau

Si plusieurs GPO sont liées au même conteneur (même OU, même domaine, etc.), elles possèdent un **ordre de liaison** (Link Order) visible dans la console GPMC :

|Link Order|GPO|Priorité|
|---|---|---|
|1|GPO_Security_Baseline|Plus haute|
|2|GPO_Software_Deploy|Moyenne|
|3|GPO_Printer_Config|Plus basse|

> [!warning] Attention à l'ordre inversé Dans la GPMC, le Link Order 1 correspond à la **plus haute priorité**. C'est contre-intuitif car on pourrait penser que 1 = premier appliqué, mais c'est en fait le dernier (et donc celui qui l'emporte).

### Vérification de l'ordre de traitement

Pour vérifier l'ordre d'application des GPO pour un utilisateur ou ordinateur :

```powershell
# Générer un rapport HTML détaillé
gpresult /H C:\GPOReport.html /F

# Afficher la liste des GPO appliquées
Get-GPResultantSetOfPolicy -ReportType Html -Path C:\RSoP.html

# Voir les GPO appliquées en ligne de commande
gpresult /R

# Mode verbose pour voir tous les détails
gpresult /V
```

---

## 🚫 Blocage de l'héritage

### Concept

Le **blocage de l'héritage** (Block Inheritance) est une option qui peut être activée au niveau d'un conteneur (domaine ou OU) pour empêcher les GPO des niveaux supérieurs de s'appliquer.

> [!info] Définition Quand le blocage d'héritage est activé sur une OU, seules les GPO liées directement à cette OU (et aux OU enfants) seront appliquées. Les GPO du domaine et des OU parents sont ignorées.

### Activation du blocage

Dans la console GPMC :

1. Clic droit sur l'OU concernée
2. Sélectionner **"Block Inheritance"**
3. L'OU affiche alors un symbole d'exclamation bleu (!)

### Cas d'usage

|Scénario|Justification|
|---|---|
|OU d'administrateurs|Éviter que les restrictions utilisateurs s'appliquent aux comptes admin|
|Filiale autonome|Permettre une gestion indépendante des politiques|
|Environnement de test|Isoler les machines de test des politiques de production|
|Serveurs critiques|Appliquer uniquement des GPO spécifiques aux serveurs|

> [!example] Exemple pratique Vous avez une GPO au niveau du domaine qui désactive l'accès à l'invite de commandes pour tous les utilisateurs. Vous créez une OU "IT_Support" avec blocage d'héritage pour que vos techniciens conservent cet accès.

### Limitations importantes

> [!warning] Le blocage n'est pas absolu Le blocage d'héritage peut être **contourné** par une GPO configurée en mode "Enforced" (voir section suivante). Une GPO enforced traverse le blocage d'héritage.

```
Domain (GPO avec Enforced)
  ↓  ← Le blocage ne peut pas empêcher une GPO Enforced
OU Parent (Block Inheritance activé)
  └─ OU Enfant  ← La GPO Enforced s'applique quand même
```

### Impact sur les performances

> [!tip] Bonne pratique Utilisez le blocage d'héritage avec parcimonie. Chaque blocage ajoute de la complexité et peut rendre le dépannage plus difficile. Préférez des stratégies de filtrage de sécurité ou WMI quand c'est possible.

---

## 🔒 Application forcée (Enforced)

### Concept

L'option **Enforced** (anciennement appelée "No Override") permet de forcer l'application d'une GPO en lui donnant une priorité absolue. Une GPO enforced ne peut être neutralisée ni par le blocage d'héritage ni par une autre GPO de niveau inférieur.

> [!info] Principe Une GPO en mode Enforced dit : "Mes paramètres doivent s'appliquer, peu importe les autres GPO ou les blocages d'héritage en place."

### Activation d'Enforced

Dans la console GPMC :

1. Développer le conteneur où la GPO est liée
2. Clic droit sur le **lien de la GPO** (pas la GPO elle-même)
3. Sélectionner **"Enforced"**
4. Le lien affiche alors une icône de cadenas 🔒

```powershell
# Via PowerShell
Set-GPLink -Name "GPO_Security_Critical" -Target "DC=entreprise,DC=local" -Enforced Yes

# Vérifier le statut Enforced
Get-GPInheritance -Target "OU=IT,DC=entreprise,DC=local" | Select-Object -ExpandProperty GpoLinks
```

### Cas d'usage

|Scénario|Justification|
|---|---|
|Politique de sécurité corporate|S'assurer que les paramètres de sécurité s'appliquent partout|
|Conformité réglementaire|Garantir l'application de paramètres obligatoires (RGPD, ISO 27001)|
|Restrictions critiques|Désactivation de fonctionnalités dangereuses sur tous les postes|
|Standards techniques|Imposer une configuration réseau ou système uniforme|

> [!example] Exemple concret Votre entreprise doit appliquer une politique de mots de passe complexes pour être conforme à une norme de sécurité. Vous créez une GPO "Password_Policy" au niveau du domaine et l'activez en mode Enforced pour être certain qu'aucune OU ne pourra contourner ces règles.

### Hiérarchie avec plusieurs GPO Enforced

Si plusieurs GPO en mode Enforced s'appliquent au même objet, l'ordre LSDOU reste valable entre elles :

```
GPO_Domain_Enforced (Enforced au niveau Domain)
  ↓  Plus faible priorité parmi les Enforced
GPO_OU_Enforced (Enforced au niveau OU)
  ↓  Plus forte priorité parmi les Enforced
```

> [!tip] Règle à retenir Entre deux GPO Enforced, c'est celle qui est la plus proche de l'objet (la plus basse dans la hiérarchie) qui gagne.

### Interactions avec le blocage d'héritage

|Scénario|Résultat|
|---|---|
|GPO normale + Block Inheritance|La GPO est bloquée ✋|
|GPO Enforced + Block Inheritance|La GPO s'applique quand même ✅|
|GPO Enforced haute + GPO normale basse|Les deux s'appliquent, la plus basse gagne en cas de conflit ⚔️|
|GPO Enforced haute + GPO Enforced basse|Les deux s'appliquent, la plus basse gagne ⚔️|

> [!warning] Attention à l'abus L'utilisation excessive de l'option Enforced peut créer une rigidité excessive et compliquer la gestion. Utilisez-la uniquement pour les paramètres vraiment critiques qui doivent absolument s'appliquer partout.

---

## ⚔️ Résolution de conflits

### Types de conflits

Lorsque plusieurs GPO configurent le même paramètre, il existe plusieurs scénarios possibles :

#### 1. Paramètres non conflictuels

Si les GPO configurent des paramètres différents, il n'y a pas de conflit. Tous les paramètres sont appliqués :

```
GPO_1 : Active le pare-feu Windows
GPO_2 : Configure les paramètres proxy
GPO_3 : Déploie un fond d'écran
→ Les trois paramètres sont appliqués ✅
```

#### 2. Paramètres conflictuels

Quand plusieurs GPO configurent **exactement le même paramètre**, seule la GPO ayant la **plus haute priorité** l'emporte :

```
GPO_Domain : Définit le fond d'écran = "Logo_Entreprise.jpg"
GPO_OU : Définit le fond d'écran = "Logo_Service.jpg"
→ Résultat : "Logo_Service.jpg" (OU plus prioritaire) ✅
```

> [!info] Principe de victoire La dernière GPO appliquée (celle avec la plus haute priorité dans l'ordre LSDOU) écrase les paramètres précédents pour ce paramètre spécifique.

### États d'un paramètre

Un paramètre de GPO peut avoir trois états différents :

|État|Description|Impact|
|---|---|---|
|**Non configuré**|Le paramètre n'est pas défini dans la GPO|N'a aucun effet, laisse passer les autres GPO|
|**Activé**|Le paramètre est explicitement activé|Configure le paramètre à "Oui/Activé"|
|**Désactivé**|Le paramètre est explicitement désactivé|Configure le paramètre à "Non/Désactivé"|

> [!warning] Confusion fréquente "Non configuré" ≠ "Désactivé". Un paramètre non configuré n'a aucun effet (comme s'il n'existait pas), tandis qu'un paramètre désactivé force explicitement la valeur à "Non".

### Résolution pas à pas

Voici comment Windows résout les conflits :

1. **Application dans l'ordre LSDOU** : Les GPO sont traitées de Local vers OU
2. **Pour chaque paramètre** :
    - Si le paramètre est "Non configuré", il est ignoré
    - Si le paramètre est "Activé" ou "Désactivé", il remplace la valeur précédente
3. **Résultat final** : La dernière valeur définie (non "Non configuré") est appliquée

> [!example] Exemple de résolution
> 
> **Paramètre** : "Désactiver l'invite de commandes"
> 
> |Niveau|GPO|État du paramètre|Valeur courante|
> |---|---|---|---|
> |Local|Policy|Non configuré|(aucune)|
> |Site|GPO_Site_Paris|Non configuré|(aucune)|
> |Domain|GPO_Security|Activé|Désactivé ✅|
> |OU Parent|GPO_Department|Non configuré|Désactivé ✅|
> |OU Enfant|GPO_IT_Team|Désactivé|Activé ✅|
> 
> **Résultat final** : L'invite de commandes est **activée** (le paramètre à "Désactivé" dans la GPO_IT_Team annule la restriction)

### Paramètres cumulatifs vs paramètres écrasants

Certains paramètres ont un comportement spécial :

#### Paramètres écrasants (la majorité)

La plupart des paramètres sont **écrasants** : seule la valeur de la GPO prioritaire est conservée.

```
GPO_1 : Fond d'écran = "Image1.jpg"
GPO_2 : Fond d'écran = "Image2.jpg"
→ Résultat : "Image2.jpg" uniquement
```

#### Paramètres cumulatifs (minorité)

Quelques paramètres rares sont **cumulatifs** : les valeurs de toutes les GPO sont combinées.

```
GPO_1 : Membres du groupe Administrateurs locaux = "IT_Admin"
GPO_2 : Membres du groupe Administrateurs locaux = "Server_Admin"
→ Résultat : IT_Admin ET Server_Admin sont ajoutés
```

> [!tip] Paramètres cumulatifs courants
> 
> - Membres de groupes locaux (Restricted Groups)
> - Scripts de démarrage/arrêt (s'exécutent tous)
> - Extensions de fichiers bloquées
> - Entrées de registre spécifiques configurées en mode "Update"

### Outils de diagnostic

Pour comprendre quel paramètre a été appliqué et pourquoi :

```powershell
# Rapport détaillé avec GPO gagnante pour chaque paramètre
gpresult /H C:\Rapport_GPO.html /F

# Voir quel paramètre spécifique est appliqué
Get-GPResultantSetOfPolicy -ReportType Html -Path C:\RSoP.html

# Mode super détaillé (logging)
gpresult /Z > C:\GPODebug.txt

# Outil graphique (RSoP)
rsop.msc
```

> [!info] Lecture du rapport GPResult Dans le rapport HTML généré, cherchez la section "Winning GPO" qui indique quelle GPO a appliqué chaque paramètre et pourquoi les autres ont été écrasées.

### Filtrage de sécurité et WMI

Au-delà de la priorité LSDOU, d'autres mécanismes peuvent empêcher l'application d'une GPO :

|Mécanisme|Description|Impact sur la résolution|
|---|---|---|
|**Filtrage de sécurité**|Permissions sur la GPO|Si l'objet n'a pas les droits "Lire" et "Appliquer", la GPO est ignorée complètement|
|**Filtres WMI**|Conditions système|Si la condition WMI n'est pas remplie, la GPO est ignorée complètement|
|**Désactivation des sections**|Computer/User Config désactivée|Seule la section active est traitée|

> [!example] Cas pratique de filtrage Vous avez une GPO_OU prioritaire, mais elle contient un filtre de sécurité qui exclut votre utilisateur. Résultat : la GPO_Domain moins prioritaire s'appliquera quand même, car la GPO_OU est totalement ignorée pour cet utilisateur.

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges fréquents

#### 1. Confusion entre "Non configuré" et "Désactivé"

> [!warning] Erreur classique Penser qu'un paramètre "Non configuré" désactive une fonctionnalité. En réalité, il ne fait strictement rien et laisse les autres GPO agir.

**Solution** : Si vous voulez annuler un paramètre d'une GPO prioritaire, mettez-le explicitement à "Désactivé", pas "Non configuré".

#### 2. Trop de GPO au même niveau

Avoir 15 GPO liées à la même OU avec des Link Orders différents rend le débogage cauchemardesque.

**Solution** : Consolidez les paramètres connexes dans une seule GPO, ou au maximum 3-4 GPO par niveau avec des noms clairs.

#### 3. Abus du mode Enforced

Mettre toutes les GPO en Enforced "par sécurité" supprime toute flexibilité et crée des blocages.

**Solution** : Réservez Enforced aux paramètres vraiment critiques (sécurité, conformité). Pour le reste, utilisez la hiérarchie normale.

#### 4. Oublier l'impact du filtrage de sécurité

Une GPO peut avoir la meilleure priorité du monde, si l'objet n'a pas les droits de lecture/application, elle sera ignorée.

**Solution** : Vérifiez toujours les permissions avec `gpresult /R` ou la délégation dans GPMC.

#### 5. Bloquer l'héritage par défaut

Activer Block Inheritance sur de nombreuses OU "juste au cas où" crée de la complexité inutile.

**Solution** : N'utilisez le blocage que pour des cas spécifiques et documentés. Par défaut, laissez l'héritage fonctionner.

### Bonnes pratiques

#### 📐 Organisation hiérarchique

```
Domain
├─ GPO_Security_Baseline (Enforced) → Paramètres de sécurité obligatoires
├─ GPO_Corporate_Standards → Standards d'entreprise
│
├─ OU: Workstations
│   ├─ GPO_Desktop_Config → Configuration de base des postes
│   └─ OU: IT_Department
│       └─ GPO_IT_Tools → Outils spécifiques IT
│
└─ OU: Servers
    └─ GPO_Server_Hardening → Durcissement des serveurs
```

#### 🎯 Principe de moindre privilège

Appliquez les restrictions au niveau le plus large (domaine), puis assouplissez au niveau des OU spécifiques si nécessaire.

```
Domain → Restrictions strictes
  └─ OU Générale → Hérite des restrictions
      └─ OU Privilégiée → Assouplit certaines restrictions
```

#### 📝 Convention de nommage

Utilisez des noms explicites avec un préfixe indiquant le niveau :

- `DOM_Security_Baseline` → GPO au niveau du domaine
- `OU_IT_SoftwareDeploy` → GPO au niveau d'une OU
- `SITE_Paris_Printer` → GPO au niveau d'un site

#### 🧪 Tester avant de déployer

> [!tip] Méthode de test sécurisée
> 
> 1. Créez une OU de test
> 2. Déplacez-y un objet de test (user ou computer)
> 3. Liez votre nouvelle GPO à cette OU
> 4. Validez avec `gpupdate /force` et `gpresult`
> 5. Si OK, déployez sur les OU de production

#### 📊 Documenter la stratégie

Maintenez un document décrivant :

- La liste des GPO et leur objectif
- Les GPO en mode Enforced et pourquoi
- Les OU avec Block Inheritance et la raison
- Les Link Orders et leur logique
- Les filtres de sécurité ou WMI appliqués

#### 🔍 Monitoring régulier

Auditez périodiquement vos GPO :

```powershell
# Lister toutes les GPO avec leur statut
Get-GPO -All | Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime

# Trouver les GPO non liées (potentiellement obsolètes)
Get-GPO -All | Where-Object {
    $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>"
}

# Identifier les GPO avec Enforced
Get-GPInheritance -Target "DC=entreprise,DC=local" | 
    Select-Object -ExpandProperty GpoLinks | 
    Where-Object { $_.Enforced -eq $true }
```

#### 🚀 Forcer l'application immédiate

Lors de tests ou après modifications :

```powershell
# Sur le poste local
gpupdate /force

# À distance sur un ordinateur spécifique
Invoke-GPUpdate -Computer "PC-001" -Force

# Sur toutes les machines d'une OU
Get-ADComputer -Filter * -SearchBase "OU=IT,DC=entreprise,DC=local" | 
    ForEach-Object { Invoke-GPUpdate -Computer $_.Name -Force }
```

---

## 🎓 Synthèse

### Règles d'or de la priorité des GPO

1. **Ordre LSDOU** : Local → Site → Domain → OU (du parent vers l'enfant)
2. **La dernière gagne** : La GPO la plus proche de l'objet a la priorité
3. **Enforced traverse tout** : Une GPO Enforced ignore le blocage d'héritage
4. **Block Inheritance stoppe l'héritage** : Mais pas les GPO Enforced
5. **Non configuré ≠ Désactivé** : Non configuré n'a aucun effet

### Ordre de priorité complet

```
Priorité la plus faible
    ↓
[Local Policy]
    ↓
[Site GPO] (ordre de lien inversé)
    ↓
[Domain GPO] (ordre de lien inversé)
    ↓
[OU Parent GPO] (ordre de lien inversé)
    ↓
[OU Enfant GPO] (ordre de lien inversé)
    ↓
Priorité la plus forte

Note : Les GPO Enforced prennent le dessus sur toutes les autres
au même niveau et traversent le Block Inheritance
```

### Méthode de dépannage en 5 étapes

1. **Identifier le problème** : Quel paramètre ne s'applique pas comme prévu ?
2. **Lister les GPO appliquées** : `gpresult /R` ou `/H`
3. **Vérifier les priorités** : Ordre LSDOU, Link Order, Enforced
4. **Contrôler les filtres** : Sécurité, WMI, délégation
5. **Tester les modifications** : OU de test, validation progressive

---

> [!tip] Astuce finale Gardez toujours la console GPMC ouverte avec la vue "Group Policy Results" pour visualiser en temps réel quelle GPO s'applique à quel objet. C'est votre meilleur allié pour comprendre la résolution des conflits !