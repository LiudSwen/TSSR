## ⚡ L'essentiel en 5 minutes - Active Directory (AD)

### 📌 C'est quoi en 2 lignes ?
Active Directory est un service d'annuaire Microsoft (implémentation LDAP) qui centralise la gestion des utilisateurs, ordinateurs et ressources réseau dans un domaine Windows. Il fournit l'authentification, l'autorisation et organise les objets dans une base de données hiérarchique répliquée entre contrôleurs de domaine.

---

### 💡 Concepts clés à retenir :

* **AD DS** : Service principal qui gère domaine, annuaire, authentification et contrôle d'accès aux ressources
* **LDAP** : Protocole standardisé pour interroger et modifier l'annuaire (Lightweight Directory Access Protocol)
* **Domaine** : Unité administrative de sécurité avec contrôle centralisé, périmètre de sécurité et authentification commune
* **Arbre** : Arborescence de plusieurs domaines partageant schéma commun avec relations d'approbation (espace de noms contigu)
* **Forêt** : Collection d'arbres partageant catalogue global, schéma unique et fonctionnant indépendamment
* **OU (Organizational Unit)** : Conteneur le plus bas dans la hiérarchie pour organiser objets et appliquer GPO
* **DC (Domain Controller)** : Serveur hébergeant la base AD, indispensable au domaine (domaine inutilisable si DC éteint)
* **RODC** : DC en lecture seule pour sites distants (équilibrage de charge, continuité de service)
* **Catalogue Global** : DC étendu contenant réplica partiel de tous domaines de la forêt pour localiser objets
* **Réplication** : Synchronisation automatique des données AD entre DC (base annuaire, GPO, scripts, DNS)
* **KCC** : Service générant la topologie de réplication entre DC à chaque modification
* **FSMO** : 5 rôles uniques (Schema Master, Domain Naming Master, RID Master, Infrastructure Master, PDC Emulator)
* **Kerberos** : Protocole d'authentification par défaut depuis Windows 2000 (authentification mutuelle client/serveur)

---

### 💻 Commandes essentielles :

```powershell
# 🪟 PowerShell AD
Get-ADObject -Filter {Name -like "*serveur*"}                # Chercher un objet
Get-ADOrganizationalUnit -Filter {Name -like "*IT*"}         # Lister les OUs
Get-ADDomain | Select Name,DomainSID,DomainMode             # Infos domaine
Get-ADForest                                                 # Infos forêt
Get-ADDomainController                                       # Infos DC
Get-ADUser -Filter * -Properties *                           # Lister utilisateurs avec tous attributs
Get-ADUser -Filter * -Properties * | Where-Object {$_.Name -eq "User1"}  # Infos user spécifique
```

```bash
# 🌐 Structure LDAP
dc=entreprise,dc=fr                                          # Domaine racine
ou=users,dc=entreprise,dc=fr                                 # OU utilisateurs
cn=user1,ou=users,dc=entreprise,dc=fr                        # Distinguished Name complet
uid=user1,ou=users,dc=entreprise,dc=fr                       # Identifiant utilisateur
```

---

### 📐 Hiérarchie / Architecture :

* **Structure logique** : Forêt → Arbre(s) → Domaine(s) → OU → Objets (users, computers, groups)
* **Réplication inter-site** : 180 min par défaut (15 min minimum)
* **Réplication intra-site** : 5 min par défaut (sauf actions sécurité)
* **Limite objets** : +2 milliards d'objets maximum par domaine
* **Limite GPO** : 999 GPO applicables par objet maximum
* **Limite groupes** : 1015 appartenances de groupe par objet maximum

**Processus réplication :**
```
1. Modification objet sur DC1
2. DC1 demande au KCC si autres DC existent
3. KCC indique présence DC2
4. DC1 interroge DNS pour localiser DC2
5. DC1 notifie DC2 des modifications
6. DC2 demande détails modifications
7. DC1 transmet modifications
8. DC2 met à jour sa BDD
```

---

### ⚠️ Pièges à éviter :

* ❌ **DC unique avec tous rôles FSMO** : En panne = forêt inutilisable, séparer rôles forêt/domaine sur minimum 2 DC
* ❌ **Droits directs sur utilisateurs** : Jamais donner permissions directement, toujours via groupes (méthode AGDLP)
* ❌ **Mauvaise synchro temps** : Cause échecs authentification Kerberos, réplication, connexions et certificats
* ❌ **Niveau fonctionnel inadapté** : Impossible retour arrière après montée de niveau, niveau = OS le plus ancien
* ❌ **Problèmes DNS** : DNS obligatoire pour AD, toute panne DNS impacte directement Active Directory
* ❌ **Admin T0 sur serveurs inférieurs** : Compte Tier 0 ne doit JAMAIS se connecter sur T1/T2 (propagation attaque)
* ❌ **Comptes admin permanents** : Privilèges permanents = trou sécurité en cas de compromission (utiliser JIT)

---

### ✅ Bonnes pratiques :

* ✅ **Principe moindre privilège (JEA)** : Droits strictement nécessaires pour tâches précises uniquement
* ✅ **Comptes séparés** : Compte admin distinct du compte quotidien (Tiering Model : T0/T1/T2)
* ✅ **DC protégés** : Isoler DC dans VLAN dédié/DMZ, maintenir MAJ régulières, LDAPS pour communications
* ✅ **Audits et logs** : Surveillance continue, audit régulier, règle sauvegarde 3-2-1 (3 copies, 2 supports, 1 externe)
* ✅ **AGDLP** : Account → Global groups (métier) → Domain Local groups (droits) → Permissions (ressources)
* ✅ **LAPS** : Rotation automatique des mots de passe administrateur local sur postes clients
* ✅ **JIT (Just-In-Time)** : Privilèges temporaires avec approbation et révocation automatique après expiration
* ✅ **Minimum 2 DC** : Haute disponibilité, répartir rôles FSMO, idéal = 5 DC (1 rôle chacun)

---

### 📚 Vocabulaire technique :

| Terme | Définition courte |
|-------|------------------|
| **BDD hiérarchique** | Base de données arborescente (vs relationnelle avec tables) type annuaire téléphonique |
| **Schéma** | Définition des attributs/classes d'objets dans l'annuaire (comme champs/tables BDD) |
| **Attributs** | Caractéristiques/informations d'un objet (Name, SID, GUID, last-logon, etc.) |
| **Distinguished Name (DN)** | Chemin complet unique d'un objet (ex: cn=user1,ou=IT,dc=entreprise,dc=fr) |
| **ObjectGUID** | Identifiant unique global immuable (même si objet renommé/déplacé) |
| **ObjectSID** | Security Identifier unique pour contrôle d'accès et authentification |
| **Workgroup** | Mode sans domaine, connexion locale uniquement, pas de centralisation (limite ~10 PC) |
| **GPO** | Group Policy Object pour contrôler environnement utilisateurs/ordinateurs via stratégies |
| **Tiering Model** | Modèle sécurité Microsoft séparant ressources en 3 niveaux hermétiques (T0/T1/T2) |
| **PDC Emulator** | Rôle FSMO primordial gérant synchro temps et verrouillage comptes domaine |
| **RID Master** | Rôle FSMO attribuant pools de RID (Relative ID) pour création SID uniques |

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : AD = annuaire LDAP hiérarchique (Forêt > Arbre > Domaine > OU > Objets) avec réplication automatique entre DC pour authentification Kerberos centralisée
2. 💻 **Pratique** : `Get-ADUser -Filter * -Properties *` pour infos complètes utilisateur / AGDLP obligatoire (jamais droits directs)
3. ⚠️ **Piège** : DC éteint = domaine mort / Admin T0 sur T1/T2 = faille critique / Temps désynchronisé = Kerberos KO

---

**Rôles AD :** AD DS (principal), AD CS (certificats), AD FS (SSO), AD RMS (droits fichiers), AD LDS (annuaire light)  
**Protocoles clés :** LDAP (requêtes), Kerberos (auth), DNS (résolution obligatoire), SNTP (temps), X.509 (certificats), NTFS (ACL)  
**5 FSMO :** Forêt (Schema Master + Domain Naming Master) | Domaine (RID Master + Infrastructure Master + PDC Emulator)
