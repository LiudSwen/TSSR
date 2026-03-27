
## Sommaire - Guide de configuration GLPI sur Debian

1. [Connexion à l'interface web](#1-connexion-à-linterface-web)
	- 1.1 [Accès à l'interface web](#11-accès-à-linterface-web)
2. [Sécurisation post-installation](#2-sécurisation-post-installation)
	- 2.1 [Créer un compte Super-Admin](#21-créer-un-compte-super-admin)
	- 2.2 [Création de l'utilisateur Super-Admin](#22-création-de-lutilisateur-super-admin)
	- 2.3 [Configuration du compte Super-Admin](#23-configuration-du-compte-super-admin)
	- 2.4 [Suppression de l'entité Self-Service](#24-suppression-de-lentité-self-service-du-compte-super-admin)
	- 2.5 [Connexion avec le compte Super-Admin](#25-connexion-avec-le-compte-super-admin)
	- 2.6 [Désactivation des comptes par défaut](#26-désactivation-des-comptes-par-défaut)
3. [Synchronisation GLPI avec Active Directory](#3-synchronisation-glpi-avec-active-directory)
	- 3.1 [Création d'un compte GLPI dans AD](#31-création-dun-compte-glpi-dans-active-directory--serveur-ad)
	- 3.2 [Installation du module PHP](#32-installation-du-module-php-si-nécessaire)
	- 3.3 [Configuration de l'annuaire LDAP](#33-configuration-de-lannuaire-ldap-dans-glpi)
	- 3.4 [Test de la connexion](#34-test-de-la-connexion)
	- 3.5 [Synchronisation des utilisateurs](#35-synchronisation-des-utilisateurs)
4. [Installation et configuration de GLPI Agent](#4-installation-et-configuration-de-glpi-agent)
	- 4.1 [Activation de l'inventaire GLPI](#41-activation-de-linventaire-glpi)
	- 4.2 [Installation par GPO](#42-installation-par-gpo)
5. [Ressources complémentaires](#5-ressources-complémentaires)

---

### 1. Connexion à l'interface web

#### 1.1 Accès à l'interface web
Ouvrez votre navigateur web et accédez à :
```
http://ADRESSE_IP_DU_SERVEUR_GLPI/  (172.16.13.1)
```

#### 11 : Identifiant de connexion par défaut 

- Entrer les identifiants 
- Noter les informations de connexion par défaut :
  - **Compte super-administrateur** : `glpi` / `glpi`
  - **Compte administrateur** : `tech` / `tech`
  - **Compte normal** : `normal` / `normal`
  - **Compte post-only** : `post-only` / `postonly`
- Sélectionner **Base interne GLPI**
- Cliquer sur **Se connecter**

![img](Ressources/glpi_img/01_glpi_installation_web/12_glpi_installation_web.png)

---

### 2. Sécurisation post-installation

#### 2.1 Créer un compte Super-Admin
- Cliquer sur `Administration > Utilisateurs > +`  

![img](Ressources/glpi_img/02_glpi_configuration/01_glpi_configuration.png)

#### 2.2 Création de l'utilisateur Super-Admin
- **Identifiant** : `administrator_glpi`
- **Mot de passe** : `Azerty1*`
- Cliquer sur `Ajouter`

#### 2.3 Configuration du compte Super-Admin
1) Cliquer sur `Habilitations`
2) Sélectionner `Super-Admin`
3) Mettre **Récursift** sur `Oui`
4) Cliquer sur `Ajouter`
5) Vérification de l'apparition de l'entité

![img](Ressources/glpi_img/02_glpi_configuration/02_glpi_configuration.png)


#### 2.4 Suppression de l'entité Self-Service du compte Super-Admin

1) Cocher l'entité **Self-Service**
2) Cliquer sur **Actions**
3) Cliquer sur **Actions** dans le pop-up
4) Cliquer sur **Supprimer définitivement**

![img](Ressources/glpi_img/02_glpi_configuration/03_glpi_configuration.png)

5) Cliquer sur **Envoyer**

![img](Ressources/glpi_img/02_glpi_configuration/04_glpi_configuration.png)


#### 2.5 Connexion avec le compte Super-Admin

1) Cliquer sur l'icone de votre compte en haut à droite
2) Cliquer sur **Déconnexion**

![img](Ressources/glpi_img/02_glpi_configuration/05_glpi_configuration.png)


#### 2.6 Désactivation des comptes par défaut

- Connexion avec le nouveau compte **Super-Admin**

![img](Ressources/glpi_img/02_glpi_configuration/06_01_glpi_configuration.png)

- Cliquer sur **Administration**
- Cliquer sur **Utilisateurs**

![img](Ressources/glpi_img/02_glpi_configuration/06_glpi_configuration.png)

- Pour les 4 utilisateurs :
    - **glpi**
    - **post-only**
    - **tech**
    - **normal**
- Cliquer sur un utilisateur
- Mettre `Non` dans l'option **Activé**
- Cliquer sur **Sauvegarder** (tout en bas)

![img](Ressources/glpi_img/02_glpi_configuration/07_glpi_configuration.png)
![img](Ressources/glpi_img/02_glpi_configuration/08_glpi_configuration.png)

- Résultat final 

![img](Ressources/glpi_img/02_glpi_configuration/09_glpi_configuration.png)

---

### 3. Synchronisation GLPI avec Active Directory

#### 3.1 Création d'un compte GLPI dans Active Directory ( Serveur AD)

- Créer un utilisateur `svc_glpi` avec le mot de passe `Azerty1*` dans Active Directory

#### 3.2 Installation du module PHP (si nécessaire)

```bash
apt install php-ldap -y
systemctl restart apache2
```

#### 3.3 Configuration de l'annuaire LDAP dans GLPI

1) Cliquer sur **Configuration**
2) Cliquer sur **Authentification**
3) Cliquer sur **Annuaire LDAP**

![img](Ressources/glpi_img/03_glpi_ad/01_glpi_ad.png)

1) Entrer le nom de l'annuaire Àctive Directory BillU`
2) Sélectionner **Oui** pour **Serveur par défaut**
3) Sélectionner **Oui** Pour **Activé**
4) Entrer l'adresse ip du serveur AD `172.16.12.1`
5) Entrer le filtre `(objectClass=user)`
6) Entrer la base DN `dc=billu,dc=lan`
7) Entrer le compte GLPI créé précédemment `svc_glpi@billu.lan`
8) Entrer le mot de passe du compte **svc_glpi@billu.lan** `Azerty1*`
9) Entrer `samaccountname`dans **Champ de l'identifiant**
10) Entrer `objectguid` dans **Champ de synchronisation**
11) Cliquer sur **Ajouter**

![img](Ressources/glpi_img/03_glpi_ad/02_glpi_ad.png)


#### 3.4 Test de la connexion

- Aller dans l'onglet **Tester** pour vérifier la connexion 

![img](Ressources/glpi_img/03_glpi_ad/03_glpi_ad.png)

#### 3.5 Synchronisation des utilisateurs

- Dans l'onglet **Administration** > **Utilisateurs**
    - Si **Liaison annuaire LDAP** (4) n'apparait pas, suivre les étapes :

1) Cliquer sur l'utilisateur en haut à droite
2) Cliquer sur le rôle de l'utilisateur (Super-Admin)
3) Cliquer sur le profil **Super-Admin**
4) Liaison annuaire LDAP (4) apparaitra et cliquer dessus

![img](Ressources/glpi_img/03_glpi_ad/04_glpi_ad.png)

- Cliquer sur **Importation de nouveaux utilisateurs**

![img](Ressources/glpi_img/03_glpi_ad/05_glpi_ad.png)

- Cliquer sur **Rechercher**

![img](Ressources/glpi_img/03_glpi_ad/06_glpi_ad.png)

1) Modifier le nombre de **lignes/pages** à `1000`
2) Cocher la cache à gauche du **Champ de synchronisation** pour sélectionner tous les utilisateurs
3) Cliquer sur **Actions**

![img](Ressources/glpi_img/03_glpi_ad/07_glpi_ad.png)

1) Sélectionner **Importer**
2) Cliquer sur **Envoyer**

![img](Ressources/glpi_img/03_glpi_ad/08_glpi_ad.png)

- La liste des utilisateurs apparaitra dans l'onglet **Administration > Utilisateurs**

![img](Ressources/glpi_img/03_glpi_ad/09_glpi_ad.png)


---

### 4. Installation et configuration de GLPI Agent

#### 4.1 Activation de l'inventaire GLPI

- Naviguer dans l'onget **Administration > Inventaire**
- Cocher la case **Activer l'inventaire**
- Cliquer sur **Sauvegarder**

![img](Ressources/glpi_img/04_glpi_agent/01_glpi_agent.png)

#### 4.2 Installation par GPO 

![Lien de la création de la GPO GLPI-Agent]()

---

## 5. Ressources complémentaires

- **Documentation officielle** : https://glpi-install.readthedocs.io/
- **Forum communautaire** : https://forum.glpi-project.org/
- **GitHub GLPI** : https://github.com/glpi-project/glpi
- **Plugins GLPI** : https://plugins.glpi-project.org/





