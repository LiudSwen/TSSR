## Installation de Snort sur Ubuntu

Voici les étapes pour installer et configurer Snort sur Ubuntu.

### 1. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Installer les dépendances

```bash
sudo apt install -y build-essential libpcap-dev libpcre3-dev libnet1-dev zlib1g-dev luajit hwloc libdnet-dev libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake cpputest libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev libluajit-5.1-dev libunwind-dev
```

### 3. Installer Snort

**Option A — Via apt (simple, mais version moins récente) :**
```bash
sudo apt install -y snort
```
Durant l'installation, il vous sera demandé de renseigner l'adresse réseau de votre interface (ex: `192.168.1.0/24`).

**Option B — Compilation depuis les sources (Snort 3) :**
```bash
# Installer DAQ (Data Acquisition library)
wget https://github.com/snort3/libdaq/archive/refs/heads/master.zip
unzip master.zip && cd libdaq-master
./bootstrap && ./configure && make && sudo make install

# Installer Snort 3
wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
unzip master.zip && cd snort3-master
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
cd build && make -j$(nproc) && sudo make install
sudo ldconfig
```

### 4. Vérifier l'installation

```bash
snort --version
```

### 5. Configurer Snort

Le fichier de configuration principal se trouve ici :
```bash
sudo nano /etc/snort/snort.conf   # Pour Snort 2
# ou
sudo nano /usr/local/etc/snort/snort.lua  # Pour Snort 3
```

Définissez votre réseau local dans la variable `HOME_NET` :
```
var HOME_NET 192.168.1.0/24
```

### 6. Tester la configuration

```bash
sudo snort -T -c /etc/snort/snort.conf -i eth0
```

### 7. Lancer Snort en mode IDS

```bash
# Mode écoute avec alertes console
sudo snort -A console -q -c /etc/snort/snort.conf -i eth0

# Mode démon en arrière-plan
sudo snort -D -c /etc/snort/snort.conf -i eth0
```

### 8. (Optionnel) Créer un service systemd

```bash
sudo nano /etc/systemd/system/snort.service
```
```ini
[Unit]
Description=Snort IDS
After=network.target

[Service]
ExecStart=/usr/sbin/snort -D -c /etc/snort/snort.conf -i eth0
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
```bash
sudo systemctl enable --now snort
```

---

**Conseil :** Pour les règles de détection, vous pouvez utiliser les règles communautaires gratuites disponibles sur [snort.org](https://www.snort.org/downloads#rules) ou les règles **Emerging Threats** via le paquet `snort-rules-default`.

---  

## Le paquet `acidbase` n'existe plus dans Ubuntu 24.04

Il a été retiré des dépôts. Installez uniquement Snort et BASE séparément :

### Installez Snort + les dépendances de BASE :

```bash
sudo apt install snort apache2 php php-mysql libapache2-mod-php mysql-server php-gd
```

### Puis téléchargez BASE manuellement :

```bash
cd /var/www/html
sudo wget https://github.com/NathanGibbs3/BASE/releases/download/1.4.5/base-1.4.5.tar.gz
sudo tar -xzf base-1.4.5.tar.gz
sudo mv base-1.4.5 base
sudo chown -R www-data:www-data base
```

Accédez ensuite à `http://votre-ip/base` pour finaliser la configuration.

---

### Cela dit, je vous recommande vraiment l'option pfSense

Puisque pfSense est déjà en place dans votre infrastructure, installer Snort directement dessus via **System → Package Manager** vous évitera toute cette complexité et vous donnera une interface bien plus complète et maintenue.

**Quelle option vous convient le mieux ?**

---  

Non, je ne suis pas sûr à 100% de cette URL ! Laissez-moi vérifier.L'URL que j'avais donnée était incorrecte, désolé ! Le projet BASE est maintenu sur GitHub par NathanGibbs3. Voici la bonne commande pour le télécharger :

```bash
cd /var/www/html
sudo git clone https://github.com/NathanGibbs3/BASE.git base
sudo chown -R www-data:www-data base
```

Ou via le téléchargement direct depuis GitHub :

```bash
cd /var/www/html
sudo wget https://github.com/NathanGibbs3/BASE/archive/refs/heads/master.zip
sudo unzip master.zip
sudo mv BASE-master base
sudo chown -R www-data:www-data base
```

Ensuite accédez à `http://votre-ip/base` pour finaliser la configuration.

---

Cela dit, je vous rappelle que l'option la plus simple reste **Snort directement dans pfSense** via le Package Manager — ça évite toute cette installation manuelle et c'est bien mieux maintenu. Vous souhaitez continuer avec BASE ou tenter la voie pfSense ? 🔍
