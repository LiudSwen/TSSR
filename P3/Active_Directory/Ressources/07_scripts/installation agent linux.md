# Installation GLPI Agent sur Debian (Container Proxmox)

## Méthode 1 : Installation via les dépôts officiels FusionInventory

```bash
# 1. Installer les prérequis
sudo apt update
sudo apt install -y wget gnupg2 lsb-release

# 2. Ajouter la clé GPG
wget -O- http://debian.fusioninventory.org/debian/archive.key | sudo apt-key add -

# 3. Ajouter le dépôt
echo "deb http://debian.fusioninventory.org/debian/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/fusioninventory.list

# 4. Mettre à jour et installer
sudo apt update
sudo apt install -y fusioninventory-agent

# 5. Configuration
sudo nano /etc/fusioninventory/agent.cfg
```

**Contenu du fichier de configuration :**
```ini
server = http://172.16.13.1
tag = ServeurLinux
```

```bash
# 6. Redémarrer le service
sudo systemctl restart fusioninventory-agent
sudo systemctl enable fusioninventory-agent

# 7. Forcer un inventaire
sudo fusioninventory-agent --server http://172.16.13.1
```

---

## Méthode 2 : Installation manuelle depuis GitHub

```bash
# 1. Installer les dépendances
sudo apt update
sudo apt install -y \
    libwww-perl \
    libparse-edid-perl \
    libproc-daemon-perl \
    libfile-which-perl \
    libhttp-daemon-perl \
    libxml-treepp-perl \
    libtext-template-perl \
    libuniversal-require-perl \
    libnet-cups-perl \
    libnet-ip-perl \
    libdigest-md5-file-perl \
    libsocket-getaddrinfo-perl \
    libnet-snmp-perl \
    perl-modules \
    dmidecode \
    pciutils \
    usbutils \
    hdparm

# 2. Télécharger GLPI Agent depuis GitHub
cd /tmp
wget https://github.com/glpi-project/glpi-agent/archive/refs/tags/1.11.tar.gz
tar -xzf 1.11.tar.gz
cd glpi-agent-1.11

# 3. Installer
sudo perl Makefile.PL
sudo make
sudo make install

# 4. Créer le fichier de configuration
sudo mkdir -p /etc/glpi-agent
sudo nano /etc/glpi-agent/agent.cfg
```

**Contenu :**
```ini
server = http://172.16.13.1
tag = ServeurLinux
logger = stderr
```

```bash
# 5. Créer un service systemd
sudo nano /etc/systemd/system/glpi-agent.service
```

**Contenu du service :**
```ini
[Unit]
Description=GLPI Agent
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/glpi-agent --daemon --config=/etc/glpi-agent/agent.cfg
PIDFile=/var/run/glpi-agent.pid

[Install]
WantedBy=multi-user.target
```

```bash
# 6. Activer et démarrer
sudo systemctl daemon-reload
sudo systemctl enable glpi-agent
sudo systemctl start glpi-agent

# 7. Test
/usr/local/bin/glpi-agent --server http://172.16.13.1 --force
```

---

## Méthode 3 : Installation ultra-simple (Script tout-en-un)

```bash
# Télécharger et exécuter le script d'installation
curl -s https://raw.githubusercontent.com/glpi-project/glpi-agent/develop/contrib/unix/glpi-agent-deployment.sh | sudo bash -s -- --server=http://172.16.13.1 --tag=ServeurLinux
```

---

## Vérification

```bash
# Vérifier que le service tourne
sudo systemctl status fusioninventory-agent
# OU
sudo systemctl status glpi-agent

# Vérifier les logs
sudo journalctl -u fusioninventory-agent -f
# OU
sudo journalctl -u glpi-agent -f
```

---

## Note importante pour container Proxmox

Si tu utilises un container LXC, assure-toi que :
- Le container a accès au réseau
- Il peut joindre l'IP 172.16.13.1
- Test : `ping 172.16.13.1`
- Test : `curl http://172.16.13.1`


---------------------------------------------------


# 1. Installer les dépendances minimales
```bash
sudo apt update
sudo apt install -y perl libwww-perl dmidecode
```
# 2. Télécharger le script d'installation
```bash
cd /tmp
wget https://github.com/glpi-project/glpi-agent/releases/download/1.15/glpi-agent-1.15-linux-installer.pl
```
# 3. Vérifier qu'il est bien téléchargé
```bash
ls -lh glpi-agent-1.15-linux-installer.pl
```
# 4. L'exécuter avec tes paramètres
```bash
sudo perl glpi-agent-1.15-linux-installer.pl --install --server=http://172.16.13.1 --tag=ServeurLinux
```
# 5. Vérifier l'installation
```bash
glpi-agent --version
```
# 6. Faire un test d'inventaire
```bash
sudo glpi-agent --server=http://172.16.13.1 --force
```
