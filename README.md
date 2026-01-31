# Cloud-Native DevOps Architecture Showcase

Ce projet est une démonstration technique d'une architecture Cloud Native & DevOps de bout en bout. Il matérialise les concepts d'Infrastructure-as-Code, d'orchestration et d'automatisation CI/CD pour garantir la résilience d'un service critique (application de vote en temps réel) sur un environnement cloud auto-géré.

![Status](https://img.shields.io/github/actions/workflow/status/fmaamoun/k3s-f1-vote-cluster/deploy.yml?label=Pipeline&logo=github)
![AWS](https://img.shields.io/badge/AWS-Infrastructure-FF9900?logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-v1.5+-purple?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-2.14+-red?logo=ansible)
![Kubernetes](https://img.shields.io/badge/K3s-Cluster-blue?logo=kubernetes)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=github-actions&logoColor=white)

## 🏗️ Architecture Technique

### 1. Infrastructure (AWS & Terraform)
*   **Réseau (VPC)** :
    *   **Public Zone (DMZ)** : Répartie sur 2 AZs (eu-west-3a/b) hébergeant l'Application Load Balancer (ALB) pour la haute disponibilité et le Bastion Host.
    *   **Private Zone (The Vault)** : Sous-réseau isolé hébergeant le cluster Kubernetes (Master + Workers), inaccessible directement depuis Internet.
    *   **Gateways** : Internet Gateway (IGW) pour le trafic public et **NAT Gateway** pour permettre aux nœuds privés de télécharger des mises à jour/images de manière sécurisée sans être exposés.
*   **Security (Firewalls)** : Stratégie de **Security Groups** "Least Privilege" :
    *   **Bastion SG** : Seul point d'entrée SSH (Port 22) ouvert sur le monde.
    *   **ALB SG** : Filtre le trafic Web entrant et ne le redirige vers le cluster que s'il est légitime.
    *   **Internal SG** : Verrouillage total des nœuds K3s. Ils n'acceptent que le trafic venant du Bastion (SSH/API), de l'ALB (HTTP), et entre eux (VXLAN/Flannel).
*   **Compute (EC2)** :
    *   **Bastion** : Instance proxy (`t3.micro`) pour l'administration sécurisée.
    *   **Master Node** : Instance de contrôle (`t3.small`) gérant l'API Server et la base de données cluster.
    *   **Worker Nodes** : Flotte de 2 instances (`t3.micro`) dédiées à l'exécution des conteneurs applicatifs.
*   **Traffic Management (ALB)** : ALB AWS opérant au Layer 7, gérant la terminaison SSL (optionnelle) et routant le trafic HTTP vers les ports 80 des Workers (où écoute l'Ingress Controller Traefik).
*   **Automation & Intelligence** :
    *   **Dynamic OS** : Utilisation dynamique de la dernière AMI **Ubuntu 22.04 LTS** disponible pour garantir un OS patché et sécurisé.
    *   **IaC Glueing** : Terraform génère automatiquement l'inventaire Ansible et les clés SSH, supprimant toute intervention manuelle entre le provisioning et la configuration.

### 2. Orchestration & Cluster (Kubernetes/K3s)
*   **Distribution** : **K3s**, distribution Kubernetes légère certifiée CNCF.
*   **Ingress Controller** : **Traefik** (natif K3s) assurant le routage interne vers les services.
*   **Placement des Workloads** :
    *   **Redis** : Pinned sur le **Master Node** via `nodeSelector` pour isoler la donnée du calcul intensif.
    *   **App (F1 Vote)** : Pinned sur les **Worker Nodes** via `nodeAffinity` (Anti-affinity Control-Plane).
*   **Scaling** : HPA (Horizontal Pod Autoscaler) configuré pour scaler les pods de **2 à 8 réplicas** suivant l'utilisation CPU.

### 3. Configuration (Ansible)
*   **Bootstrapping** : Installation automatisée de K3s.
*   **Join Token** : Récupération dynamique du token sur le Master et propagation sécurisée aux Workers pour l'assemblage du cluster.
*   **OS Hardening** : Pré-configuration des paquets essentiels et mises à jour de sécurité.

### 4. CI/CD (GitHub Actions)
*   **Smart Pipeline** : Détection intelligente des changements (Paths Filter) pour déclencher le build Docker uniquement si le code source change.
*   **Secure Deployment** : Déploiement via **SSH Tunneling (ProxyCommand)** à travers le Bastion pour atteindre le Master privé.
*   **Zero-Downtime** : Utilisation de `kubectl rollout status` pour garantir que la nouvelle version est saine avant de terminer le déploiement.
*   **Registry** : Utilisation de **GHCR** (GitHub Container Registry) pour stocker les images docker taggées par SHA de commit.

## 📦 Workload Applicatif

L'application déployée ("F1 Voting App") sert de témoin pour valider la résilience de l'infrastructure. Le scénario retenu simule le vote "Driver of the Day" de la Formule 1, un cas d'usage caractérisé par des pics de charge intenses et soudains (Burst Traffic) en fin de course. Elle est composée de deux micro-services :
* **Frontend/Backend** : SvelteKit (Node.js) gérant l'interface et l'API.
* **Data Store** : Redis pour la persistance volatile haute performance.

**Fonctionnalités exposées :**
* **Route Publique (`/`)** : Interface utilisateur connectée via WebSocket pour le vote temps réel.
* **Route Administration (`/admin`)** : Interface de pilotage permettant de modifier l'état du système (Ouverture/Fermeture des votes, Reset) et de visualiser les métriques Redis en direct.

## 🚀 Guide de Déploiement

Cette procédure permet de répliquer l'intégralité de l'infrastructure sur un compte AWS vierge.

### 1. Pré-requis
* Un compte AWS avec accès programmatique (Access Key/Secret Key).
* Terraform & Ansible installés sur la machine de contrôle.

### 2. Provisioning Infrastructure (Terraform)
Initialisation et application du plan d'infrastructure :
```bash
cd terraform
terraform init
terraform apply
```

### 3. Configuration Cluster (Ansible)

Mise à jour de l'inventaire avec les IPs provisionnées et exécution du playbook :

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 4. Configuration CI/CD (GitHub)

Configurer les secrets suivants dans le dépôt pour permettre au pipeline de piloter le cluster :

| Secret | Description |
| --- | --- |
| `MASTER_HOST` | IP Privée du nœud Master (Accessible via Bastion) |
| `BASTION_HOST` | IP Publique du Bastion |
| `SSH_PRIVATE_KEY` | Contenu de la clé privée SSH utilisée par Ansible |

**Variable d'environnement :**

* `APP_URL` : DNS du Load Balancer AWS (requis pour les environnements de déploiement).

### 5. Lancement

Pour le premier déploiement, rendez-vous dans l'onglet **Actions** de GitHub, sélectionnez le workflow **"Production Deployment"** et cliquez sur **Run workflow**.

Par la suite, tout commit poussé sur la branche `main` impactant l'application (`app/`) ou les manifestes Kubernetes (`kubernetes/`) déclenchera automatiquement le pipeline de mise à jour.

> [!WARNING]
> **Cost Management :** Cette infrastructure utilise des ressources AWS réelles (EC2, VPC, ELB). Pour éviter des coûts inutiles après utilisation, n'oubliez pas de détruire les ressources :
> ```bash
> cd terraform && terraform destroy
> ```

## 🛠️ Stack Technologique

### DevOps & Cloud
*   **AWS** : Infrastructure & Services Cloud Natifs.
*   **Terraform** : Infrastructure as Code.
*   **Ansible** : Configuration Management.
*   **Kubernetes (K3s)** : Orchestration de conteneurs.
*   **GitHub Actions** : CI/CD.
*   **Docker** : Container Registry.

### Application Components
*   **SvelteKit** : Framework Frontend & API.
*   **Redis** : Base de données clé-valeur.
*   **TailwindCSS** : Utilitaire CSS.
*   **WebSocket** : Communication temps réel.