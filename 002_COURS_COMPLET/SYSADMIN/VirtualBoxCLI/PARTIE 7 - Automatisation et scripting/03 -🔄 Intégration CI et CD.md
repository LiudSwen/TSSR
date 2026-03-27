

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

## Introduction à l'intégration CI/CD

L'intégration de VirtualBox dans vos pipelines CI/CD permet d'automatiser les tests dans des environnements isolés et reproductibles. Cela garantit que votre application fonctionne correctement dans différentes configurations système avant le déploiement.

> [!info] Pourquoi utiliser VirtualBox en CI/CD ?
> 
> - **Isolation complète** : Chaque test s'exécute dans un environnement vierge
> - **Reproductibilité** : Les mêmes conditions de test à chaque exécution
> - **Parallélisation** : Exécution de tests simultanés sur plusieurs VMs
> - **Tests multi-plateformes** : Windows, Linux, BSD dans le même pipeline

> [!warning] Limitations importantes
> 
> - **Virtualisation imbriquée** : Nécessite un runner avec support de la virtualisation
> - **Performance** : Plus lent que les conteneurs Docker
> - **Ressources** : Consomme plus de RAM et CPU qu'une approche conteneurisée

---

## VBoxManage dans les pipelines

### Configuration de l'environnement

Avant d'utiliser VBoxManage dans un pipeline, il faut s'assurer que l'environnement est correctement configuré.

#### Vérification des prérequis

```bash
# Vérifier que VirtualBox est installé
VBoxManage --version

# Vérifier que la virtualisation est activée
if [ -d /sys/module/kvm_intel ] || [ -d /sys/module/kvm_amd ]; then
    echo "✓ Virtualisation matérielle disponible"
else
    echo "✗ Virtualisation matérielle non disponible"
    exit 1
fi

# Vérifier les ressources disponibles
free -h  # Mémoire
df -h    # Espace disque
```

> [!tip] Optimisation des runners CI Configurez vos runners CI avec au moins 8 GB de RAM et 4 cœurs CPU pour exécuter des VMs de manière fluide.

### Intégration avec GitLab CI

#### Exemple de pipeline complet

```yaml
# .gitlab-ci.yml
stages:
  - prepare
  - test
  - cleanup

variables:
  VM_NAME: "test-vm-${CI_PIPELINE_ID}"
  VM_MEMORY: "2048"
  VM_CPUS: "2"

# Préparation de la VM
prepare_vm:
  stage: prepare
  script:
    # Cloner une VM de base
    - VBoxManage clonevm "base-ubuntu-template" --name "$VM_NAME" --register
    
    # Configurer la VM
    - VBoxManage modifyvm "$VM_NAME" --memory $VM_MEMORY --cpus $VM_CPUS
    - VBoxManage modifyvm "$VM_NAME" --nic1 nat --natpf1 "ssh,tcp,,2222,,22"
    
    # Démarrer la VM
    - VBoxManage startvm "$VM_NAME" --type headless
    
    # Attendre que la VM soit prête
    - |
      for i in {1..60}; do
        if VBoxManage guestproperty get "$VM_NAME" "/VirtualBox/GuestInfo/Net/0/V4/IP" | grep -q "Value:"; then
          echo "✓ VM prête"
          break
        fi
        echo "Attente de la VM... ($i/60)"
        sleep 5
      done
  artifacts:
    reports:
      dotenv: vm-info.env
  only:
    - merge_requests
    - main

# Exécution des tests
run_tests:
  stage: test
  dependencies:
    - prepare_vm
  script:
    # Copier les fichiers de test dans la VM
    - VBoxManage guestcontrol "$VM_NAME" copyto test_suite.sh /tmp/test_suite.sh --username ci --password ci123
    
    # Exécuter les tests
    - |
      VBoxManage guestcontrol "$VM_NAME" run --exe /bin/bash \
        --username ci --password ci123 --wait-stdout --wait-stderr \
        -- /bin/bash -c "/tmp/test_suite.sh"
    
    # Récupérer les résultats
    - VBoxManage guestcontrol "$VM_NAME" copyfrom /tmp/test_results.xml ./test_results.xml --username ci --password ci123
  artifacts:
    reports:
      junit: test_results.xml
  only:
    - merge_requests
    - main

# Nettoyage systématique
cleanup_vm:
  stage: cleanup
  script:
    # Arrêter la VM
    - VBoxManage controlvm "$VM_NAME" poweroff || true
    - sleep 5
    
    # Supprimer la VM
    - VBoxManage unregistervm "$VM_NAME" --delete || true
  when: always
  only:
    - merge_requests
    - main
```

> [!example] Explication du pipeline
> 
> - **prepare_vm** : Clone une VM template, la configure et la démarre
> - **run_tests** : Copie les tests, les exécute et récupère les résultats
> - **cleanup_vm** : Nettoie toujours, même en cas d'échec (when: always)

### Intégration avec GitHub Actions

```yaml
# .github/workflows/vm-tests.yml
name: VirtualBox Tests

on:
  pull_request:
  push:
    branches: [ main ]

jobs:
  test-on-vm:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Install VirtualBox
        run: |
          sudo apt-get update
          sudo apt-get install -y virtualbox virtualbox-ext-pack
      
      - name: Create and configure VM
        run: |
          VM_NAME="test-vm-${{ github.run_id }}"
          
          # Importer une VM pré-configurée
          VBoxManage import base-vm.ova --vsys 0 --vmname "$VM_NAME"
          
          # Configuration réseau
          VBoxManage modifyvm "$VM_NAME" --nic1 nat
          VBoxManage modifyvm "$VM_NAME" --natpf1 "ssh,tcp,,2222,,22"
          
          # Démarrage
          VBoxManage startvm "$VM_NAME" --type headless
          
          # Sauvegarder le nom pour les étapes suivantes
          echo "VM_NAME=$VM_NAME" >> $GITHUB_ENV
      
      - name: Wait for VM ready
        run: |
          timeout 300 bash -c '
            while ! VBoxManage guestproperty get "$VM_NAME" "/VirtualBox/GuestInfo/Net/0/V4/IP" | grep -q "Value:"; do
              echo "Waiting for VM..."
              sleep 5
            done
          '
      
      - name: Run tests
        run: |
          # Copier les fichiers de test
          VBoxManage guestcontrol "$VM_NAME" copyto ./tests /home/testuser/tests --username testuser --password test123 --recursive
          
          # Exécuter les tests
          VBoxManage guestcontrol "$VM_NAME" run --exe /bin/bash \
            --username testuser --password test123 \
            --wait-stdout --wait-stderr \
            -- /bin/bash -c "cd /home/testuser/tests && ./run_all_tests.sh"
      
      - name: Cleanup
        if: always()
        run: |
          VBoxManage controlvm "$VM_NAME" poweroff || true
          sleep 5
          VBoxManage unregistervm "$VM_NAME" --delete || true
```

> [!warning] Attention aux secrets Ne jamais hardcoder les mots de passe dans les pipelines. Utilisez les secrets du CI/CD :
> 
> ```yaml
> --password ${{ secrets.VM_PASSWORD }}
> ```

### Intégration avec Jenkins

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    environment {
        VM_NAME = "test-vm-${BUILD_ID}"
        VM_TEMPLATE = "ubuntu-20.04-template"
    }
    
    stages {
        stage('Prepare VM') {
            steps {
                script {
                    // Cloner la VM template
                    sh "VBoxManage clonevm ${VM_TEMPLATE} --name ${VM_NAME} --register --snapshot base-snapshot --options link"
                    
                    // Configuration réseau
                    sh "VBoxManage modifyvm ${VM_NAME} --nic1 nat --natpf1 'ssh,tcp,,2222,,22'"
                    
                    // Démarrage
                    sh "VBoxManage startvm ${VM_NAME} --type headless"
                    
                    // Attendre que SSH soit disponible
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            script {
                                def result = sh(script: "nc -z localhost 2222", returnStatus: true)
                                return result == 0
                            }
                        }
                    }
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    // Copier l'application
                    sh """
                        VBoxManage guestcontrol ${VM_NAME} copyto \
                            ${WORKSPACE}/app.tar.gz /tmp/app.tar.gz \
                            --username jenkins --password ${VM_PASSWORD}
                    """
                    
                    // Extraire et installer
                    sh """
                        VBoxManage guestcontrol ${VM_NAME} run --exe /bin/bash \
                            --username jenkins --password ${VM_PASSWORD} \
                            --wait-stdout --wait-stderr \
                            -- /bin/bash -c 'cd /tmp && tar -xzf app.tar.gz && ./install.sh'
                    """
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                script {
                    // Exécuter les tests
                    sh """
                        VBoxManage guestcontrol ${VM_NAME} run --exe /usr/bin/pytest \
                            --username jenkins --password ${VM_PASSWORD} \
                            --wait-stdout --wait-stderr \
                            -- /usr/bin/pytest /app/tests --junitxml=/tmp/results.xml
                    """
                    
                    // Récupérer les résultats
                    sh """
                        VBoxManage guestcontrol ${VM_NAME} copyfrom \
                            /tmp/results.xml ${WORKSPACE}/test-results.xml \
                            --username jenkins --password ${VM_PASSWORD}
                    """
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Nettoyage de la VM
                sh "VBoxManage controlvm ${VM_NAME} poweroff || true"
                sleep 5
                sh "VBoxManage unregistervm ${VM_NAME} --delete || true"
            }
            
            // Publier les résultats
            junit 'test-results.xml'
        }
    }
}
```

> [!tip] Clonage lié (Linked Clone) L'option `--options link` crée un clone lié qui partage le disque de base avec le template, économisant énormément d'espace disque et accélérant la création.

### Gestion des snapshots pour les tests

```bash
#!/bin/bash
# Créer un snapshot avant les tests

VM_NAME="test-vm-${BUILD_ID}"
SNAPSHOT_NAME="pre-test-$(date +%Y%m%d-%H%M%S)"

# Créer un snapshot
VBoxManage snapshot "$VM_NAME" take "$SNAPSHOT_NAME" \
    --description "État avant les tests du build ${BUILD_ID}"

# Exécuter les tests
./run_tests.sh

# En cas d'échec, restaurer le snapshot
if [ $? -ne 0 ]; then
    echo "⚠️  Tests échoués, restauration du snapshot"
    VBoxManage snapshot "$VM_NAME" restore "$SNAPSHOT_NAME"
    VBoxManage startvm "$VM_NAME" --type headless
fi
```

---

## Tests automatisés sur VMs

### Architecture des tests

L'automatisation des tests sur VMs nécessite une approche structurée pour gérer le cycle de vie complet de la VM et des tests.

#### Cycle de vie d'un test

```bash
#!/bin/bash
# test-lifecycle.sh

set -e  # Arrêt en cas d'erreur

VM_NAME="$1"
TEST_SUITE="$2"

# 1. Vérification de l'état de la VM
echo "📍 Vérification de l'état de la VM..."
VM_STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)

if [ "$VM_STATE" != "running" ]; then
    echo "⚠️  VM non démarrée, démarrage..."
    VBoxManage startvm "$VM_NAME" --type headless
    sleep 30
fi

# 2. Vérification de la connectivité réseau
echo "🌐 Vérification de la connectivité..."
timeout 60 bash -c "
    until VBoxManage guestproperty get '$VM_NAME' '/VirtualBox/GuestInfo/Net/0/V4/IP' | grep -q 'Value:'; do
        sleep 2
    done
"

# 3. Installation des Guest Additions si nécessaire
echo "🔧 Vérification des Guest Additions..."
GUEST_VERSION=$(VBoxManage guestproperty get "$VM_NAME" "/VirtualBox/GuestAdd/Version" | cut -d' ' -f2)
if [ -z "$GUEST_VERSION" ]; then
    echo "Installation des Guest Additions..."
    VBoxManage guestcontrol "$VM_NAME" run --exe /bin/bash \
        --username testuser --password test123 \
        -- /bin/bash -c "sudo mount /dev/cdrom /mnt && sudo /mnt/VBoxLinuxAdditions.run"
fi

# 4. Préparation de l'environnement de test
echo "📦 Préparation de l'environnement..."
VBoxManage guestcontrol "$VM_NAME" mkdir /tmp/test-suite --username testuser --password test123 --parents

# 5. Copie des fichiers de test
echo "📂 Copie des fichiers de test..."
VBoxManage guestcontrol "$VM_NAME" copyto "$TEST_SUITE" /tmp/test-suite/ \
    --username testuser --password test123 --recursive

# 6. Exécution des tests
echo "🧪 Exécution des tests..."
VBoxManage guestcontrol "$VM_NAME" run --exe /bin/bash \
    --username testuser --password test123 \
    --wait-stdout --wait-stderr \
    -- /bin/bash -c "cd /tmp/test-suite && ./run_tests.sh" \
    | tee test-output.log

# 7. Récupération des résultats
echo "📊 Récupération des résultats..."
VBoxManage guestcontrol "$VM_NAME" copyfrom /tmp/test-suite/results ./results \
    --username testuser --password test123 --recursive

# 8. Analyse des résultats
echo "📈 Analyse des résultats..."
if grep -q "FAILED" test-output.log; then
    echo "❌ Tests échoués"
    exit 1
else
    echo "✅ Tous les tests ont réussi"
fi
```

### Tests parallèles sur plusieurs VMs

Pour accélérer les tests, vous pouvez exécuter plusieurs VMs en parallèle.

```bash
#!/bin/bash
# parallel-tests.sh

# Configuration
BASE_VM="test-template"
NUM_VMS=4
TEST_SUITES=("unit" "integration" "e2e" "performance")

# Fonction pour exécuter des tests sur une VM
run_tests_on_vm() {
    local vm_id=$1
    local test_suite=$2
    local vm_name="test-vm-${vm_id}"
    
    echo "🚀 Démarrage de la VM ${vm_name} pour ${test_suite}"
    
    # Cloner la VM
    VBoxManage clonevm "$BASE_VM" --name "$vm_name" --register --options link
    
    # Configuration
    VBoxManage modifyvm "$vm_name" --memory 2048 --cpus 2
    VBoxManage modifyvm "$vm_name" --nic1 nat --natpf1 "ssh${vm_id},tcp,,$((2222+vm_id)),,22"
    
    # Démarrage
    VBoxManage startvm "$vm_name" --type headless
    
    # Attendre que la VM soit prête
    sleep 30
    
    # Exécuter les tests
    VBoxManage guestcontrol "$vm_name" run --exe /bin/bash \
        --username testuser --password test123 \
        --wait-stdout --wait-stderr \
        -- /bin/bash -c "cd /tests && ./${test_suite}_tests.sh" \
        > "${test_suite}_results.log" 2>&1
    
    local exit_code=$?
    
    # Nettoyage
    VBoxManage controlvm "$vm_name" poweroff
    sleep 5
    VBoxManage unregistervm "$vm_name" --delete
    
    return $exit_code
}

# Lancer les tests en parallèle
pids=()
for i in $(seq 0 $((NUM_VMS-1))); do
    run_tests_on_vm $i "${TEST_SUITES[$i]}" &
    pids+=($!)
done

# Attendre que tous les tests se terminent
failed=0
for i in "${!pids[@]}"; do
    wait ${pids[$i]}
    if [ $? -ne 0 ]; then
        echo "❌ Test suite ${TEST_SUITES[$i]} a échoué"
        failed=$((failed+1))
    else
        echo "✅ Test suite ${TEST_SUITES[$i]} réussie"
    fi
done

# Résultat final
if [ $failed -eq 0 ]; then
    echo "🎉 Tous les tests ont réussi !"
    exit 0
else
    echo "❌ $failed test suite(s) ont échoué"
    exit 1
fi
```

> [!warning] Limites de parallélisation
> 
> - Surveillez la mémoire disponible : 4 VMs × 2GB = 8GB minimum
> - Vérifiez la charge CPU pour éviter la contention
> - L'I/O disque peut devenir un goulot d'étranglement

### Tests de régression automatisés

```bash
#!/bin/bash
# regression-tests.sh

VM_NAME="regression-test-vm"
BASELINE_SNAPSHOT="baseline-v1.0"
RESULTS_DIR="./regression-results"

mkdir -p "$RESULTS_DIR"

# 1. Restaurer l'état baseline
echo "🔄 Restauration du snapshot baseline..."
VBoxManage snapshot "$VM_NAME" restore "$BASELINE_SNAPSHOT"
VBoxManage startvm "$VM_NAME" --type headless
sleep 30

# 2. Exécuter les tests baseline
echo "📊 Exécution des tests baseline..."
VBoxManage guestcontrol "$VM_NAME" run --exe /usr/bin/python3 \
    --username testuser --password test123 \
    --wait-stdout \
    -- /usr/bin/python3 /tests/benchmark.py --output /tmp/baseline.json

# Récupérer les résultats baseline
VBoxManage guestcontrol "$VM_NAME" copyfrom /tmp/baseline.json "$RESULTS_DIR/baseline.json" \
    --username testuser --password test123

# 3. Appliquer les changements (nouvelle version)
echo "📦 Déploiement de la nouvelle version..."
VBoxManage guestcontrol "$VM_NAME" copyto ./new-version.tar.gz /tmp/ \
    --username testuser --password test123

VBoxManage guestcontrol "$VM_NAME" run --exe /bin/bash \
    --username testuser --password test123 \
    --wait-stdout --wait-stderr \
    -- /bin/bash -c "cd /tmp && tar -xzf new-version.tar.gz && ./install.sh"

# 4. Exécuter les tests sur la nouvelle version
echo "🧪 Exécution des tests sur la nouvelle version..."
VBoxManage guestcontrol "$VM_NAME" run --exe /usr/bin/python3 \
    --username testuser --password test123 \
    --wait-stdout \
    -- /usr/bin/python3 /tests/benchmark.py --output /tmp/current.json

VBoxManage guestcontrol "$VM_NAME" copyfrom /tmp/current.json "$RESULTS_DIR/current.json" \
    --username testuser --password test123

# 5. Comparer les résultats
echo "📈 Comparaison des résultats..."
python3 <<EOF
import json
import sys

with open('$RESULTS_DIR/baseline.json') as f:
    baseline = json.load(f)

with open('$RESULTS_DIR/current.json') as f:
    current = json.load(f)

regressions = []
improvements = []

for test_name in baseline:
    if test_name not in current:
        print(f"⚠️  Test manquant : {test_name}")
        continue
    
    baseline_time = baseline[test_name]['duration']
    current_time = current[test_name]['duration']
    diff_percent = ((current_time - baseline_time) / baseline_time) * 100
    
    if diff_percent > 10:  # Régression si > 10% plus lent
        regressions.append((test_name, diff_percent))
        print(f"❌ Régression : {test_name} (+{diff_percent:.1f}%)")
    elif diff_percent < -10:  # Amélioration si > 10% plus rapide
        improvements.append((test_name, diff_percent))
        print(f"✅ Amélioration : {test_name} ({diff_percent:.1f}%)")

if regressions:
    print(f"\n⚠️  {len(regressions)} régression(s) détectée(s)")
    sys.exit(1)
else:
    print(f"\n🎉 Aucune régression détectée !")
    if improvements:
        print(f"✨ {len(improvements)} amélioration(s) !")
EOF

exit_code=$?

# 6. Nettoyage
VBoxManage controlvm "$VM_NAME" poweroff
sleep 5

exit $exit_code
```

### Tests de compatibilité multi-plateformes

```bash
#!/bin/bash
# multi-platform-tests.sh

# Définir les plateformes à tester
declare -A PLATFORMS=(
    ["ubuntu-20.04"]="ubuntu-20.04-template"
    ["ubuntu-22.04"]="ubuntu-22.04-template"
    ["debian-11"]="debian-11-template"
    ["centos-8"]="centos-8-template"
)

RESULTS_FILE="compatibility-report.md"

# Initialiser le rapport
cat > "$RESULTS_FILE" <<EOF
# Rapport de compatibilité
Généré le : $(date)

## Résultats par plateforme

EOF

# Fonction pour tester une plateforme
test_platform() {
    local platform_name=$1
    local template_vm=$2
    local vm_name="compat-test-${platform_name}"
    
    echo "🧪 Test sur $platform_name..."
    
    # Cloner et démarrer la VM
    VBoxManage clonevm "$template_vm" --name "$vm_name" --register --options link
    VBoxManage startvm "$vm_name" --type headless
    sleep 30
    
    # Exécuter les tests de compatibilité
    VBoxManage guestcontrol "$vm_name" copyto ./app-installer.sh /tmp/ \
        --username testuser --password test123
    
    local install_result
    VBoxManage guestcontrol "$vm_name" run --exe /bin/bash \
        --username testuser --password test123 \
        --wait-stdout --wait-stderr \
        -- /bin/bash /tmp/app-installer.sh
    install_result=$?
    
    # Tester les fonctionnalités
    local test_result=0
    if [ $install_result -eq 0 ]; then
        VBoxManage guestcontrol "$vm_name" run --exe /usr/local/bin/myapp \
            --username testuser --password test123 \
            --wait-stdout --wait-stderr \
            -- /usr/local/bin/myapp --self-test
        test_result=$?
    fi
    
    # Enregistrer les résultats
    if [ $install_result -eq 0 ] && [ $test_result -eq 0 ]; then
        echo "### ✅ $platform_name" >> "$RESULTS_FILE"
        echo "Installation et tests réussis" >> "$RESULTS_FILE"
    else
        echo "### ❌ $platform_name" >> "$RESULTS_FILE"
        echo "Échec : install=$install_result, test=$test_result" >> "$RESULTS_FILE"
    fi
    echo "" >> "$RESULTS_FILE"
    
    # Nettoyage
    VBoxManage controlvm "$vm_name" poweroff
    sleep 5
    VBoxManage unregistervm "$vm_name" --delete
    
    return $test_result
}

# Tester toutes les plateformes
failed_platforms=0
for platform in "${!PLATFORMS[@]}"; do
    test_platform "$platform" "${PLATFORMS[$platform]}"
    if [ $? -ne 0 ]; then
        failed_platforms=$((failed_platforms+1))
    fi
done

# Résumé final
cat >> "$RESULTS_FILE" <<EOF

## Résumé
- Plateformes testées : ${#PLATFORMS[@]}
- Échecs : $failed_platforms
- Taux de réussite : $(( (${#PLATFORMS[@]} - failed_platforms) * 100 / ${#PLATFORMS[@]} ))%
EOF

echo "📊 Rapport généré : $RESULTS_FILE"

if [ $failed_platforms -eq 0 ]; then
    echo "🎉 Application compatible avec toutes les plateformes !"
    exit 0
else
    echo "⚠️  Application incompatible avec $failed_platforms plateforme(s)"
    exit 1
fi
```

> [!tip] Optimisation des tests multi-plateformes
> 
> - Utilisez des clones liés pour économiser l'espace disque
> - Créez des templates avec les dépendances pré-installées
> - Mettez en cache les résultats pour éviter de re-tester des versions identiques

---

## Nettoyage automatique

Le nettoyage automatique est crucial pour éviter l'accumulation de VMs et libérer les ressources. Un mauvais nettoyage peut rapidement saturer le disque et la mémoire.

### Stratégies de nettoyage

#### Nettoyage basique après tests

```bash
#!/bin/bash
# cleanup-basic.sh

VM_NAME="$1"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <vm_name>"
    exit 1
fi

echo "🧹 Nettoyage de la VM $VM_NAME..."

# 1. Arrêt forcé si la VM est en cours d'exécution
VM_STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable 2>/dev/null | grep "VMState=" | cut -d'"' -f2)

if [ "$VM_STATE" == "running" ] || [ "$VM_STATE" == "paused" ]; then
    echo "⏹️  Arrêt de la VM..."
    VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
    sleep 5
fi

# 2. Désenregistrer et supprimer la VM
echo "🗑️  Suppression de la VM..."
VBoxManage unregistervm "$VM_NAME" --delete 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ VM supprimée avec succès"
else
    echo "⚠️  Erreur lors de la suppression"
fi
```

#### Nettoyage avec gestion des erreurs

```bash
#!/bin/bash
# cleanup-robust.sh

set -e

VM_NAME="$1"
MAX_RETRIES=3
RETRY_DELAY=5

# Fonction de nettoyage robuste
cleanup_vm() {
    local vm_name=$1
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        echo "🔄 Tentative de nettoyage $((retry_count+1))/$MAX_RETRIES..."
        
        # Vérifier si la VM existe
        if ! VBoxManage showvminfo "$vm_name" &>/dev/null; then
            echo "✅ VM déjà supprimée"
            return 0
        fi
        
        # Obtenir l'état de la VM
        local vm_state
        vm_state=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "VMState=" | cut -d'"' -f2)
        
        # Arrêter la VM selon son état
        case "$vm_state" in
            "running"|"paused")
                echo "⏹️  Arrêt de la VM (état: $vm_state)..."
                VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
                sleep $RETRY_DELAY
                ;;
            "stuck"|"guru meditation")
                echo "⚠️  VM bloquée, arrêt forcé..."
                VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
                sleep $RETRY_DELAY
                ;;
        esac
        
        # Supprimer les snapshots (peuvent bloquer la suppression)
        echo "📸 Suppression des snapshots..."
        VBoxManage snapshot "$vm_name" list --machinereadable 2>/dev/null | \
            grep "SnapshotName" | cut -d'"' -f2 | \
            while read snapshot_name; do
                VBoxManage snapshot "$vm_name" delete "$snapshot_name" 2>/dev/null || true
            done
        
        # Tenter la suppression
        echo "🗑️  Suppression de la VM..."
        if VBoxManage unregistervm "$vm_name" --delete 2>/dev/null; then
            echo "✅ VM supprimée avec succès"
            return 0
        fi
        
        retry_count=$((retry_count+1))
        if [ $retry_count -lt $MAX_RETRIES ]; then
            echo "⏳ Attente de ${RETRY_DELAY}s avant nouvelle tentative..."
            sleep $RETRY_DELAY
        fi
    done
    
    echo "❌ Échec du nettoyage après $MAX_RETRIES tentatives"
    return 1
}

# Exécuter le nettoyage
cleanup_vm "$VM_NAME"
exit $?
```

> [!warning] Gestion des VMs bloquées Parfois, une VM peut rester dans un état "stuck" ou "guru meditation". Dans ce cas, seul un arrêt forcé suivi d'une suppression manuelle fonctionne.

#### Nettoyage planifié (cron job)

```bash
#!/bin/bash
# cleanup-scheduled.sh - À exécuter quotidiennement via cron

LOG_FILE="/var/log/vbox-cleanup.log"
MAX_AGE_DAYS=7

echo "=== Nettoyage VirtualBox - $(date) ===" >> "$LOG_FILE"

# 1. Nettoyer les VMs anciennes
echo "🔍 Recherche des VMs de test anciennes..." | tee -a "$LOG_FILE"

VBoxManage list vms | grep -E "test-vm-|ci-vm-" | while read line; do
    VM_NAME=$(echo "$line" | cut -d'"' -f2)
    
    # Obtenir la date de création (approximation via les fichiers)
    VM_DIR=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "CfgFile=" | cut -d'"' -f2 | xargs dirname)
    
    if [ -d "$VM_DIR" ]; then
        VM_AGE_DAYS=$(( ($(date +%s) - $(stat -c %Y "$VM_DIR")) / 86400 ))
        
        if [ $VM_AGE_DAYS -gt $MAX_AGE_DAYS ]; then
            echo "🗑️  Suppression de $VM_NAME (âge: ${VM_AGE_DAYS} jours)" | tee -a "$LOG_FILE"
            
            VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null || true
            sleep 5
            VBoxManage unregistervm "$VM_NAME" --delete 2>&1 | tee -a "$LOG_FILE"
        fi
    fi
done

# 2. Nettoyer les médias orphelins
echo "💿 Nettoyage des médias orphelins..." | tee -a "$LOG_FILE"
VBoxManage list hdds | grep -A 3 "^UUID:" | grep "Location:" | cut -d':' -f2- | while read disk_path; do
    # Vérifier si le disque est utilisé par une VM
    if ! VBoxManage list vms | xargs -I {} VBoxManage showvminfo {} --machinereadable | grep -q "$disk_path"; then
        echo "🗑️  Suppression du disque orphelin: $disk_path" | tee -a "$LOG_FILE"
        VBoxManage closemedium disk "$disk_path" --delete 2>&1 | tee -a "$LOG_FILE"
    fi
done

# 3. Compacter les disques virtuels
echo "🗜️  Compactage des disques virtuels..." | tee -a "$LOG_FILE"
VBoxManage list hdds | grep "^UUID:" | cut -d':' -f2 | xargs | while read uuid; do
    DISK_SIZE=$(VBoxManage showmediuminfo disk "$uuid" | grep "^Capacity:" | awk '{print $2}')
    
    # Compacter si le disque fait plus de 10GB
    if [ "$DISK_SIZE" -gt 10000 ]; then
        echo "🗜️  Compactage du disque $uuid (${DISK_SIZE}MB)" | tee -a "$LOG_FILE"
        VBoxManage modifymedium disk "$uuid" --compact 2>&1 | tee -a "$LOG_FILE"
    fi
done

# 4. Statistiques finales
echo "📊 Statistiques:" | tee -a "$LOG_FILE"
echo "  - VMs actives: $(VBoxManage list vms | wc -l)" | tee -a "$LOG_FILE"
echo "  - VMs en cours: $(VBoxManage list runningvms | wc -l)" | tee -a "$LOG_FILE"
echo "  - Disques virtuels: $(VBoxManage list hdds | grep -c '^UUID:')" | tee -a "$LOG_FILE"

# 5. Espace disque
VBOX_DIR="${HOME}/.config/VirtualBox"
if [ -d "$VBOX_DIR" ]; then
    DISK_USAGE=$(du -sh "$VBOX_DIR" | cut -f1)
    echo "  - Espace utilisé: $DISK_USAGE" | tee -a "$LOG_FILE"
fi

echo "=== Nettoyage terminé - $(date) ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
```

Pour planifier ce script avec cron :

```bash
# Éditer le crontab
crontab -e

# Ajouter la ligne suivante pour exécuter tous les jours à 2h du matin
0 2 * * * /path/to/cleanup-scheduled.sh
```

> [!tip] Rotation des logs Configurez logrotate pour gérer les logs de nettoyage :
> 
> ```
> /var/log/vbox-cleanup.log {
>     daily
>     rotate 30
>     compress
>     missingok
>     notifempty
> }
> ```

### Nettoyage dans les hooks Git

#### Hook pre-push

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "🧹 Nettoyage des VMs de test locales avant push..."

# Nettoyer les VMs de développement local
VBoxManage list vms | grep "dev-test-" | cut -d'"' -f2 | while read vm_name; do
    echo "🗑️  Suppression de $vm_name"
    VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
    sleep 2
    VBoxManage unregistervm "$vm_name" --delete 2>/dev/null || true
done

echo "✅ Nettoyage terminé"
```

#### Hook post-merge

```bash
#!/bin/bash
# .git/hooks/post-merge

# Après un merge, nettoyer les anciennes VMs de test
echo "🧹 Nettoyage post-merge..."

# Supprimer les VMs des branches mergées
MERGED_BRANCHES=$(git branch --merged | grep -v "^\*" | grep -v "main" | grep -v "master")

if [ -n "$MERGED_BRANCHES" ]; then
    echo "$MERGED_BRANCHES" | while read branch; do
        branch_clean=$(echo "$branch" | tr -d ' ' | tr '/' '-')
        vm_pattern="test-${branch_clean}-"
        
        VBoxManage list vms | grep "$vm_pattern" | cut -d'"' -f2 | while read vm_name; do
            echo "🗑️  Suppression de $vm_name (branche mergée)"
            VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
            sleep 2
            VBoxManage unregistervm "$vm_name" --delete 2>/dev/null || true
        done
    done
fi

echo "✅ Nettoyage post-merge terminé"
```

### Nettoyage avec gestion des quotas

```bash
#!/bin/bash
# cleanup-quota.sh

MAX_VMS=10
MAX_DISK_USAGE_GB=50

# 1. Vérifier le nombre de VMs
CURRENT_VMS=$(VBoxManage list vms | wc -l)
echo "📊 VMs actuelles: $CURRENT_VMS / $MAX_VMS"

if [ $CURRENT_VMS -gt $MAX_VMS ]; then
    EXCESS=$((CURRENT_VMS - MAX_VMS))
    echo "⚠️  Quota dépassé de $EXCESS VM(s)"
    
    # Supprimer les VMs les plus anciennes
    echo "🗑️  Suppression des $EXCESS VM(s) les plus anciennes..."
    
    VBoxManage list vms | cut -d'"' -f2 | while read vm_name; do
        if [ $EXCESS -le 0 ]; then
            break
        fi
        
        VM_DIR=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "CfgFile=" | cut -d'"' -f2 | xargs dirname)
        VM_MTIME=$(stat -c %Y "$VM_DIR" 2>/dev/null || echo 0)
        
        echo "$VM_MTIME $vm_name"
    done | sort -n | head -n $EXCESS | cut -d' ' -f2- | while read vm_name; do
        echo "  - Suppression de $vm_name"
        VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
        sleep 2
        VBoxManage unregistervm "$vm_name" --delete
        EXCESS=$((EXCESS - 1))
    done
fi

# 2. Vérifier l'espace disque
VBOX_DIR="${HOME}/.config/VirtualBox"
if [ -d "$VBOX_DIR" ]; then
    DISK_USAGE_KB=$(du -s "$VBOX_DIR" | cut -f1)
    DISK_USAGE_GB=$((DISK_USAGE_KB / 1024 / 1024))
    
    echo "💾 Espace disque utilisé: ${DISK_USAGE_GB}GB / ${MAX_DISK_USAGE_GB}GB"
    
    if [ $DISK_USAGE_GB -gt $MAX_DISK_USAGE_GB ]; then
        echo "⚠️  Quota d'espace disque dépassé"
        echo "🗜️  Compactage de tous les disques virtuels..."
        
        VBoxManage list hdds | grep "^UUID:" | cut -d':' -f2 | xargs | while read uuid; do
            echo "  - Compactage du disque $uuid"
            VBoxManage modifymedium disk "$uuid" --compact
        done
        
        # Vérifier à nouveau
        DISK_USAGE_KB=$(du -s "$VBOX_DIR" | cut -f1)
        DISK_USAGE_GB=$((DISK_USAGE_KB / 1024 / 1024))
        echo "💾 Espace après compactage: ${DISK_USAGE_GB}GB"
        
        # Si toujours au-dessus, supprimer des VMs
        if [ $DISK_USAGE_GB -gt $MAX_DISK_USAGE_GB ]; then
            echo "🗑️  Suppression de VMs supplémentaires..."
            
            # Supprimer les VMs les plus volumineuses
            VBoxManage list vms | cut -d'"' -f2 | while read vm_name; do
                VM_DIR=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "CfgFile=" | cut -d'"' -f2 | xargs dirname)
                VM_SIZE=$(du -s "$VM_DIR" 2>/dev/null | cut -f1)
                echo "$VM_SIZE $vm_name"
            done | sort -rn | head -n 3 | cut -d' ' -f2- | while read vm_name; do
                echo "  - Suppression de $vm_name (VM volumineuse)"
                VBoxManage controlvm "$vm_name" poweroff 2>/dev/null || true
                sleep 2
                VBoxManage unregistervm "$vm_name" --delete
            done
        fi
    fi
fi

echo "✅ Vérification des quotas terminée"
```

### Script de nettoyage d'urgence

```bash
#!/bin/bash
# emergency-cleanup.sh - En cas de saturation critique

echo "🚨 NETTOYAGE D'URGENCE 🚨"
echo "Ce script va supprimer TOUTES les VMs de test"
read -p "Êtes-vous sûr ? (oui/non) : " confirm

if [ "$confirm" != "oui" ]; then
    echo "❌ Annulé"
    exit 0
fi

# 1. Arrêter toutes les VMs en cours
echo "⏹️  Arrêt de toutes les VMs..."
VBoxManage list runningvms | cut -d'"' -f2 | while read vm_name; do
    echo "  - Arrêt de $vm_name"
    VBoxManage controlvm "$vm_name" poweroff
done

sleep 10

# 2. Supprimer toutes les VMs de test
echo "🗑️  Suppression de toutes les VMs de test..."
VBoxManage list vms | grep -E "test-|ci-|dev-" | cut -d'"' -f2 | while read vm_name; do
    echo "  - Suppression de $vm_name"
    VBoxManage unregistervm "$vm_name" --delete 2>/dev/null || true
done

# 3. Nettoyer tous les médias orphelins
echo "💿 Suppression de tous les médias orphelins..."
VBoxManage list hdds | grep "^UUID:" | cut -d':' -f2 | xargs | while read uuid; do
    # Essayer de supprimer (échouera si utilisé)
    VBoxManage closemedium disk "$uuid" --delete 2>/dev/null
done

# 4. Nettoyer le cache
echo "🧹 Nettoyage du cache..."
rm -rf ~/.config/VirtualBox/Machines/test-*
rm -rf ~/.config/VirtualBox/Machines/ci-*
rm -rf ~/.config/VirtualBox/Machines/dev-*

# 5. Statistiques finales
echo ""
echo "📊 État final:"
echo "  - VMs restantes: $(VBoxManage list vms | wc -l)"
echo "  - VMs en cours: $(VBoxManage list runningvms | wc -l)"
echo "  - Disques virtuels: $(VBoxManage list hdds | grep -c '^UUID:')"

VBOX_DIR="${HOME}/.config/VirtualBox"
if [ -d "$VBOX_DIR" ]; then
    DISK_USAGE=$(du -sh "$VBOX_DIR" | cut -f1)
    echo "  - Espace utilisé: $DISK_USAGE"
fi

echo ""
echo "✅ Nettoyage d'urgence terminé"
```

> [!warning] Nettoyage d'urgence Ce script est radical et supprime toutes les VMs de test. À utiliser uniquement en cas de saturation critique du disque ou de la mémoire.

### Monitoring et alertes

```bash
#!/bin/bash
# monitor-resources.sh

ALERT_EMAIL="admin@example.com"
VM_THRESHOLD=15
DISK_THRESHOLD_GB=80

# Fonction d'envoi d'alerte
send_alert() {
    local subject="$1"
    local message="$2"
    
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
    echo "📧 Alerte envoyée: $subject"
}

# 1. Vérifier le nombre de VMs
VM_COUNT=$(VBoxManage list vms | wc -l)
if [ $VM_COUNT -gt $VM_THRESHOLD ]; then
    send_alert "⚠️  VirtualBox: Trop de VMs" \
        "Nombre de VMs: $VM_COUNT (seuil: $VM_THRESHOLD)
        
Veuillez nettoyer les VMs de test inutilisées."
fi

# 2. Vérifier l'espace disque
VBOX_DIR="${HOME}/.config/VirtualBox"
if [ -d "$VBOX_DIR" ]; then
    DISK_USAGE_KB=$(du -s "$VBOX_DIR" | cut -f1)
    DISK_USAGE_GB=$((DISK_USAGE_KB / 1024 / 1024))
    
    if [ $DISK_USAGE_GB -gt $DISK_THRESHOLD_GB ]; then
        send_alert "⚠️  VirtualBox: Espace disque critique" \
            "Espace utilisé: ${DISK_USAGE_GB}GB (seuil: ${DISK_THRESHOLD_GB}GB)
            
Veuillez compacter ou supprimer des VMs."
    fi
fi

# 3. Vérifier les VMs bloquées
STUCK_VMS=$(VBoxManage list vms | cut -d'"' -f2 | while read vm_name; do
    STATE=$(VBoxManage showvminfo "$vm_name" --machinereadable | grep "VMState=" | cut -d'"' -f2)
    if [ "$STATE" == "stuck" ] || [ "$STATE" == "guru meditation" ]; then
        echo "$vm_name"
    fi
done)

if [ -n "$STUCK_VMS" ]; then
    send_alert "⚠️  VirtualBox: VMs bloquées" \
        "VMs en état bloqué:
$STUCK_VMS

Ces VMs nécessitent un nettoyage manuel."
fi

# 4. Générer un rapport
cat > /tmp/vbox-report.txt <<EOF
=== Rapport VirtualBox - $(date) ===

📊 Statistiques:
  - VMs totales: $VM_COUNT
  - VMs en cours: $(VBoxManage list runningvms | wc -l)
  - Disques virtuels: $(VBoxManage list hdds | grep -c '^UUID:')
  - Espace disque: ${DISK_USAGE_GB}GB

🔍 VMs par type:
$(VBoxManage list vms | cut -d'"' -f2 | sed 's/-.*//' | sort | uniq -c)

💾 Top 5 VMs volumineuses:
$(VBoxManage list vms | cut -d'"' -f2 | while read vm; do
    dir=$(VBoxManage showvminfo "$vm" --machinereadable | grep "CfgFile=" | cut -d'"' -f2 | xargs dirname)
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "$size $vm"
done | sort -rh | head -5)

=== Fin du rapport ===
EOF

echo "📊 Rapport généré: /tmp/vbox-report.txt"
```

Pour automatiser le monitoring :

```bash
# Ajouter au crontab pour vérifier toutes les heures
0 * * * * /path/to/monitor-resources.sh
```

### Bonnes pratiques de nettoyage

> [!tip] Checklist de nettoyage
> 
> 1. **Toujours** utiliser `when: always` dans les pipelines CI/CD
> 2. **Implémenter** des timeouts pour éviter les VMs zombie
> 3. **Définir** des conventions de nommage (ex: `test-vm-${BUILD_ID}`)
> 4. **Automatiser** le nettoyage planifié (cron)
> 5. **Monitorer** les ressources régulièrement
> 6. **Documenter** les procédures de nettoyage d'urgence

> [!warning] Pièges courants
> 
> - Ne jamais supprimer manuellement les fichiers de VM sans passer par VBoxManage
> - Les snapshots peuvent empêcher la suppression d'une VM
> - Un disque virtuel partagé entre plusieurs VMs ne peut être supprimé
> - Les VMs en état "stuck" nécessitent un arrêt forcé avant suppression

---

## 🎯 Synthèse

### Points clés à retenir

**VBoxManage dans les pipelines:**

- Intégration native avec GitLab CI, GitHub Actions, Jenkins
- Utilisation de clones liés pour économiser l'espace disque
- Gestion des snapshots pour les rollbacks rapides

**Tests automatisés:**

- Cycle de vie complet : préparation → exécution → récupération → nettoyage
- Parallélisation pour accélérer les tests
- Tests de régression et compatibilité multi-plateformes

**Nettoyage automatique:**

- Nettoyage systématique avec `when: always`
- Scripts planifiés pour éviter l'accumulation
- Monitoring des quotas et alertes
- Procédures d'urgence en cas de saturation

### Commandes essentielles

```bash
# Cloner une VM pour les tests
VBoxManage clonevm "template" --name "test-vm" --register --options link

# Exécuter une commande dans la VM
VBoxManage guestcontrol "vm-name" run --exe /bin/bash --username user --password pass -- /bin/bash -c "command"

# Copier des fichiers
VBoxManage guestcontrol "vm-name" copyto local-file /remote/path --username user --password pass

# Nettoyage complet
VBoxManage controlvm "vm-name" poweroff
VBoxManage unregistervm "vm-name" --delete
```

> [!example] Workflow CI/CD complet
> 
> ```
> 1. Clone de la VM template → 2. Configuration → 3. Démarrage
> 2. Attente de la disponibilité → 5. Copie des tests
> 3. Exécution → 7. Récupération des résultats
> 4. Analyse → 9. Nettoyage (toujours exécuté)
> ```