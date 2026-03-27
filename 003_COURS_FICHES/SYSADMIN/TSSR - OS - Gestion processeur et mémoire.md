## ⚡ L'essentiel en 5 minutes - Gestion Processeurs et Mémoire

### 📌 C'est quoi en 2 lignes ?

Le système d'exploitation orchestre le partage du CPU entre programmes (processus) via l'ordonnancement et protège la mémoire grâce à la pagination. Chaque processus dispose d'un espace mémoire isolé et peut être contrôlé par des signaux standardisés.

---

### 💡 Concepts clés à retenir :

- **Programme** : Code statique stocké sur disque (binaire exécutable)
- **Processus** : Programme en cours d'exécution en mémoire avec un PID unique
- **Multitâche préemptif** : Le noyau interrompt automatiquement les processus pour partager le CPU
- **Mémoire virtuelle** : Abstraction permettant à chaque processus de croire qu'il a toute la mémoire (MMU = Memory Management Unit)
- **Swap** : Extension de la RAM sur disque pour stocker les pages mémoire non utilisées
- **Thread** : Processus léger partageant la mémoire d'un processus parent (exécution parallèle)
- **PCB** : Structure de données du noyau contenant toutes les infos d'un processus (PID, état, contexte)
- **Signal** : Message inter-processus standardisé (interruption, arrêt, etc.)

---

### 💻 Commandes essentielles :

```bash
# 🐧 Linux - Gestion processus
ps aux                      # Liste tous les processus (BSD style)
ps -ef                      # Liste tous les processus (UNIX style)
pstree                      # Arborescence des processus
top                         # Processus par conso CPU (temps réel)
htop                        # Version interactive améliorée de top
kill -9 <PID>              # Tuer un processus (SIGKILL brutal)
kill -15 <PID>             # Arrêt propre d'un processus (SIGTERM)
killall <nom>              # Tuer tous les processus d'un nom
fg                         # Ramène un processus en premier plan
bg                         # Reprend un processus en arrière-plan
nohup ./script.sh &        # Lance détaché de la session (survit à la déconnexion)
nohup cmd > log.txt 2>&1 & # Redirige stdout+stderr vers fichier

# Mémoire et swap
free -h                    # Affiche RAM et swap utilisés (human readable)
swapon -s                  # Liste les swaps actifs
swapoff /dev/sdX           # Désactive un swap
mkswap /dev/sdX            # Initialise une partition swap

# Planification
crontab -e                 # Édite les tâches cron de l'utilisateur
at 14:30                   # Planifie une tâche unique

# Services (systemd)
systemctl status <service> # État d'un service
systemctl start/stop <srv> # Démarre/arrête un service
systemctl enable <service> # Active au démarrage
```

```powershell
# 🪟 Windows PowerShell
Get-Process                         # Liste tous les processus
Get-Process -Name "firefox"         # Filtre par nom
Stop-Process -Id <PID>              # Arrête un processus
Stop-Process -Name "chrome" -Force  # Arrêt forcé par nom
Start-Process "notepad.exe"         # Lance un processus

Get-Service                         # Liste tous les services
Start-Service -Name "Spooler"       # Démarre un service
Stop-Service -Name "Spooler"        # Arrête un service
Restart-Service -Name "Spooler"     # Redémarre un service
Set-Service -Name "Spooler" -StartupType Automatic  # Configure le démarrage

Get-ComputerInfo                    # Infos système et mémoire
```

---

### ⚠️ Pièges à éviter :

- ❌ **kill -9 systématique** : SIGKILL ne laisse pas le processus se terminer proprement (fichiers corrompus, verrous non relâchés). Toujours essayer `kill -15` (SIGTERM) d'abord
- ❌ **Swap sur SSD sans précaution** : L'usure des cellules est accélérée. Privilégier un fichier swap avec swappiness réduit
- ❌ **Oublier le `&` avec nohup** : Sans `&`, le processus reste attaché au terminal même avec nohup
- ❌ **Redirection mal formée** : `2>&1` doit être APRÈS `>` → `cmd > log.txt 2>&1` (et non `2>&1 > log.txt`)
- ❌ **Confondre PID et PPID** : Le PPID est l'identifiant du processus parent (ex: bash qui lance un script)

---

### ✅ Bonnes pratiques :

- ✅ **Signaux en cascade** : SIGTERM (15) → attendre 5s → SIGKILL (9) si nécessaire
- ✅ **Logs pour nohup** : Toujours rediriger stdout/stderr (`nohup cmd > /dev/null 2>&1 &` ou vers fichier)
- ✅ **Vérifier avant kill** : `ps aux | grep <nom>` pour confirmer le bon PID avant `kill`
- ✅ **Swap = 1-2x RAM** : Dimensionnement standard (mais dépend de l'usage)
- ✅ **systemctl pour les services** : Remplace les anciens scripts init.d (plus fiable, gère les dépendances)

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**PID**|Process ID - identifiant unique d'un processus|
|**PPID**|Parent Process ID - PID du processus qui a lancé celui-ci|
|**UID/GID**|User/Group ID - identifiants du propriétaire du processus|
|**TTY**|Terminal associé au processus (pts/0, tty1, etc.)|
|**SIGTERM**|Signal 15 - demande d'arrêt propre (peut être intercepté)|
|**SIGKILL**|Signal 9 - destruction immédiate par le noyau (non interceptable)|
|**SIGINT**|Signal 2 - Ctrl+C, demande d'interruption|
|**MMU**|Memory Management Unit - circuit traduisant adresses virtuelles ↔ physiques|
|**Page fault**|Défaut de page - accès à une page swappée, nécessite rechargement|
|**Ordonnanceur**|Scheduler - composant du noyau décidant quel processus utilise le CPU|
|**CFS**|Completely Fair Scheduler - ordonnanceur principal de Linux|
|**systemd**|Système d'init moderne de Linux (PID 1, gère services et dépendances)|
|**MBR/GPT**|Master Boot Record / GUID Partition Table - tables de partitionnement|
|**UEFI**|Unified Extensible Firmware Interface - remplaçant du BIOS|
|**ESP**|EFI System Partition - partition contenant les bootloaders UEFI|

---

### 🔢 Métadonnées processus (identifiants clés) :

**Linux :**

```bash
ps -eo pid,ppid,user,cmd  # Colonnes personnalisées
```

- **PID** : Identifiant unique du processus
- **PPID** : PID du parent (ex: bash qui a lancé la commande)
- **CMD** : Commande de lancement
- **UID** : Utilisateur propriétaire
- **État** : R (running), S (sleeping), Z (zombie), T (stopped)

**Windows (PowerShell) :**

```powershell
Get-Process | Select-Object Id,ProcessName,CPU,WorkingSet
```

- **Id** : Équivalent du PID
- **ParentId** : Équivalent du PPID
- **Handles** : Nombre de handles ouverts (équivalent fichiers ouverts)

---

### 🚀 Boot et services - Séquence de démarrage :

**Linux (UEFI + systemd) :**

1. **UEFI** → lit l'ESP (EFI System Partition)
2. **Bootloader (GRUB2)** → charge le noyau Linux
3. **Noyau** → initialise le matériel, monte le système de fichiers
4. **systemd (PID 1)** → lance les services en parallèle selon les dépendances

**Windows :**

1. **UEFI/BIOS** → charge `bootmgr.exe`
2. **bootmgr** → lit le BCD (Boot Configuration Data)
3. **winload.exe** → charge les pilotes et le noyau
4. **SCM** (Service Control Manager) → démarre les services de la base de registre

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Un processus = programme + contexte d'exécution isolé en mémoire (PID, espace virtuel, état)
2. 💻 **Pratique** : `kill -15 <PID>` (propre) avant `kill -9 <PID>` (brutal) | `systemctl restart <service>` pour les services
3. ⚠️ **Piège** : `nohup` sans `&` ne détache PAS du terminal | Redirection `2>&1` APRÈS `>` sinon stderr non capturé

---

### 🔥 Antisèche signaux Linux :

|Signal|N°|Action|Usage|
|---|---|---|---|
|**SIGTERM**|15|Arrêt propre|`kill <PID>` (défaut)|
|**SIGKILL**|9|Destruction forcée|`kill -9 <PID>` (dernier recours)|
|**SIGINT**|2|Interruption|Ctrl+C|
|**SIGTSTP**|20|Suspension|Ctrl+Z (reprise avec `fg`/`bg`)|
|**SIGHUP**|1|Hang up|Fermeture terminal (nohup l'ignore)|
