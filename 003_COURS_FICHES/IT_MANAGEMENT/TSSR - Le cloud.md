## ⚡ L'essentiel en 5 minutes - Cloud Computing TSSR

### 📌 C'est quoi en 2 lignes ?

Le Cloud = Fourniture de services informatiques (serveurs, stockage, BDD, réseau) sur Internet via virtualisation + automatisation. Permet d'externaliser l'infrastructure pour gagner en flexibilité et réduire les coûts matériels.

---

### 💡 Concepts clés à retenir :

- **IaaS (Infrastructure as a Service)** : Location de ressources virtualisées (serveurs, stockage) - ex: AWS EC2, Azure VM
- **PaaS (Platform as a Service)** : Environnement de développement/déploiement clé en main (runtime, middleware) - ex: Azure App Service
- **SaaS (Software as a Service)** : Logiciels en ligne par abonnement - ex: Office 365, Adobe Suite
- **Hyperviseur Type 1 (Bare Metal)** : S'exécute directement sur le matériel physique - ex: ESXi, Hyper-V, Proxmox (datacenters)
- **Hyperviseur Type 2 (Hosted)** : S'exécute sur un OS hôte - ex: VirtualBox, VMware Workstation (dev/test)
- **Scalabilité Verticale** : Augmenter CPU/RAM d'un serveur existant (Scale Up/Down)
- **Scalabilité Horizontale** : Ajouter/supprimer des serveurs (Scale Out/In) - meilleure résilience
- **Élasticité** : Ajustement automatique des ressources selon la demande réelle
- **Availability Zones** : Datacenters physiquement séparés dans une même région (protection pannes locales)
- **RGPD** : Obligation de localiser les données sensibles en Europe (région du datacenter)

---

### 💻 Commandes essentielles :

```bash
# 🐧 Diagnostic Linux/SSH Cloud
ssh -i cle.pem user@ip-vm              # Connexion SSH à une VM cloud
ping ip-publique-vm                     # Test connectivité réseau
nslookup -type=MX domaine.fr            # Vérif. DNS pour emails M365

# 🔍 Troubleshooting VM
systemctl status service                # Statut d'un service
df -h                                   # Vérif. espace disque
top / htop                              # Monitoring CPU/RAM en live
journalctl -xe                          # Logs système
```

```powershell
# 🪟 Diagnostic Windows/RDP Cloud
Test-NetConnection ip-vm -Port 3389    # Test RDP (port 3389)
Test-NetConnection ip-vm -Port 443     # Test HTTPS
Get-NetIPAddress                        # Vérif. config IP
```

```yaml
# 🐳 Docker (Conteneurisation Cloud)
docker run -d nginx:latest              # Lancer conteneur nginx
docker ps                               # Lister conteneurs actifs
docker logs conteneur-id                # Consulter logs conteneur

# ☸️ Infrastructure as Code (Terraform)
terraform init                          # Initialiser projet Terraform
terraform plan                          # Prévisualiser changements
terraform apply                         # Déployer infrastructure
terraform destroy                       # ATTENTION: Détruit tout !
```

---

### 📐 Modèles économiques :

- **Forfait** : Montant fixe mensuel/annuel pour ressources définies (besoins prévisibles)
- **Pay-as-you-go** : Facturation selon consommation réelle (flexibilité maximale)

**Types de tarification AWS/Azure :**

- **On-Demand** : Facturation à l'heure/seconde - Prix plein, zéro engagement - ex: 0,10 €/h
- **Reserved Instances** : Engagement 1-3 ans = -30% à -70% (serveurs prod stables)

**Stockage :**

- Coût par Go/mois (ex: 0,02 €/Go S3)
- Transfert ENTRANT gratuit, SORTANT facturé (ex: 0,09 €/Go Egress)

**Exemple d'optimisation :**

```
VM de dev allumée 24/7 = 100 €/mois
VM de dev éteinte hors heures (10h/j) = 40 €/mois (-60%)
```

---

### ⚠️ Pièges à éviter :

- ❌ **Oublier les sauvegardes** : Les données en cloud NÉCESSITENT toujours des backups côté client (même en SaaS)
- ❌ **Laisser tourner des VM inutilisées** : Les instances On-Demand coûtent 24/7 si non éteintes (-60% possible)
- ❌ **Modifier IaC sans précaution** : Supprimer 1 ligne Terraform = Destruction RÉELLE de ressources en prod
- ❌ **Négliger les groupes de sécurité** : Vérifier firewall/NSG avant de dire "ça marche pas" (blocage réseau)
- ❌ **Ignorer le RGPD** : Données sensibles/médicales DOIVENT rester en Europe (région du datacenter)
- ❌ **Oublier le transfert sortant** : Télécharger 1 To depuis le cloud = facturation Egress importante
- ❌ **Pas de MFA sur comptes admin** : Vol de credentials = compromission totale du tenant cloud

---

### ✅ Bonnes pratiques :

- ✅ **MFA obligatoire** : Activer l'authentification multi-facteurs sur TOUS les comptes admin (protection vol credentials)
- ✅ **RBAC - Principe du moindre privilège** : Donner uniquement les droits nécessaires (Lecteur/Contributeur/Propriétaire)
- ✅ **Right-Sizing** : Dimensionner correctement les ressources (pas de VM surdimensionnée = économies)
- ✅ **Haute disponibilité** : Déployer sur plusieurs Availability Zones (résilience pannes locales)
- ✅ **Automatisation avec IaC** : Terraform/ARM/CloudFormation pour déploiements reproductibles et versionnés
- ✅ **Monitoring actif** : Azure Monitor, CloudWatch pour surveiller CPU/RAM/Réseau (détecter throttling)
- ✅ **Nettoyage régulier** : Supprimer snapshots/disques/IP publiques inutilisés (coûts cachés)
- ✅ **Accès conditionnel** : Bloquer connexions depuis pays étrangers ou exiger MFA hors VPN entreprise

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Cloud Public**|Ressources partagées via Internet (AWS, Azure, GCP) - Scalable et économique|
|**Cloud Privé**|Ressources dédiées à 1 organisation - Contrôle et sécurité renforcés|
|**Cloud Hybride**|Mix public + privé - Flexibilité et portabilité des données/apps|
|**VPS**|Serveur virtuel dédié sur serveur physique partagé - Équilibre coût/performance|
|**Bare Metal**|Serveur physique 100% dédié - Performances max, coût élevé|
|**Block Storage**|Disque virtuel attaché à 1 VM (OS, BDD) - Performance élevée, 1 disque = 1 VM|
|**File Storage**|Stockage objet sans hiérarchie (photos, logs) - ex: s3://bucket/backup/fichier.zip|
|**Docker**|Conteneurisation d'apps - Image (template) → Conteneur (instance en exec)|
|**Kubernetes (K8s)**|Orchestrateur de conteneurs multi-machines - AKS/EKS/GKE|
|**RTO**|Recovery Time Objective = Temps max avant restauration (ex: 4h)|
|**RPO**|Recovery Point Objective = Perte de données acceptable (ex: 1h)|
|**Load Balancer**|Répartition du trafic entre plusieurs serveurs - Évite surcharge unique|
|**MFA**|Multi-Factor Authentication - Mdp + Code SMS/App/Token physique|
|**SPF/DKIM/MX**|Enregistrements DNS pour validation emails (anti-spam)|
|**Throttling**|Limitation de bande passante/requêtes par le fournisseur cloud|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : IaaS = Infrastructure / PaaS = Plateforme / SaaS = Logiciel | Responsabilités partagées selon modèle
2. 💻 **Pratique** : `nslookup -type=MX domaine.fr` pour diagnostiquer emails M365 | Toujours vérifier NSG/Firewall avant troubleshooting réseau
3. ⚠️ **Piège** : Terraform destroy = DESTRUCTION RÉELLE | Pay-as-you-go ≠ Gratuit (éteindre VMs inutilisées = -60% coûts)

---

### 🔧 Cas d'usage TSSR typiques :

**Problème : "Je ne peux pas me connecter à ma VM"**

```
1. Vérifier groupes de sécurité (NSG Azure / Security Groups AWS)
2. Vérifier assignation IP publique
3. Tester : ping ip-vm, ssh user@ip-vm, Test-NetConnection ip-vm -Port 3389
```

**Problème : "Mon application est lente"**

```
1. Consulter métriques hyperviseur : CPU/RAM/Disque
2. Vérifier bande passante réseau (Throttling ?)
3. Analyser logs applicatifs (Azure Monitor / CloudWatch)
```

**Problème : "L'email ne part pas depuis M365"**

```
1. Vérifier DNS : nslookup -type=MX domaine.fr
2. Vérifier SPF, DKIM, MX dans registrar
3. Consulter Centre de messages M365 (incidents en cours ?)
```

---

### 🏢 Cloud bureautiques (Administration TSSR) :

**Microsoft 365 (Office 365) :**

- Services : Exchange Online, SharePoint, Teams, OneDrive
- Admin : Portail M365 Admin Center
- Tâches : Création/suppression comptes, gestion licences, config DNS (MX/SPF/DKIM), MFA/accès conditionnel

**Google Workspace (G Suite) :**

- Services : Gmail, Drive, Meet, Calendar
- Admin : Console d'administration Google
- Tâches : Unités organisationnelles, groupes de distribution, synchro AD

---

### 📊 Certifications cloud à connaître :

- **ISO 27001** : Management sécurité de l'information
- **SOC 2** : Contrôles disponibilité/confidentialité
- **HDS** : Hébergement Données de Santé (obligatoire données médicales France)

---

### 🌍 Régions géographiques (exemples) :

- **AWS** : eu-west-3 = Paris | us-east-1 = Virginie
- **Azure** : France Central | West Europe
- **RGPD** : Données sensibles → Europe UNIQUEMENT