C'est noté pour **Grafana** (et son copain **Prometheus**, car il faut bien quelqu'un pour collecter les données avant de les afficher). C'est la touche finale indispensable pour voir ce qui se passe dans le moteur.

Voici l'**État des Lieux** consolidé. On passe officiellement du mode "Bricolage / Découverte" au mode "DevOps / Production".

---

### 🗺️ ROADMAP DU PROJET F1-VOTE

#### ✅ PHASE 1 : Infrastructure (Terraform)

**Statut : TERMINÉ**

* **Ce qu'on a :**
* Le réseau AWS (VPC, Subnets, Internet Gateway).
* Le Firewall (Security Groups).
* Les 3 serveurs (1 Master + 2 Workers) qui se lancent automatiquement.


* **Reste à faire :** Rien. Le code est propre (`terraform apply` suffit).

#### ⚠️ PHASE 2 : Configuration Système (Ansible)

**Statut : À FAIRE (Actuellement manuel)**

* **État actuel :** On a tapé des commandes SSH à la main (`curl ... | sh`, copie du token, etc.). Si on détruit les serveurs, il faut tout refaire à la main.
* **Objectif :** Écrire un "Playbook" Ansible.
* 1 clic -> Ansible se connecte aux 3 serveurs.
* Il installe K3s Master.
* Il récupère le token tout seul.
* Il installe les K3s Workers et les connecte.
* *Résultat : Cluster prêt en 2 minutes sans toucher au clavier.*



#### ⚠️ PHASE 3 : Déploiement App & DB (Kubernetes)

**Statut : FONCTIONNEL (Mais perfectible)**

* **État actuel :**
* Redis tourne sur le Master (✅).
* L'App tourne sur les Workers (✅).
* La communication interne fonctionne (✅).
* Déploiement via fichiers YAML appliqués à la main.


* **Reste à faire :** Nettoyer les fichiers YAML pour la phase suivante (voir Phase 4).

#### 🛑 PHASE 4 : Réseau & Sécurité (Ingress)

**Statut : À FAIRE (Gros morceau)**

* **État actuel :**
* Accès via `http://IP:30000` (Moche et Dangereux).
* Les Workers sont exposés directement sur Internet.


* **Objectif :**
* Passer les Services en `ClusterIP` (Privé, accessible uniquement dans le cluster).
* Installer/Configurer un **Ingress Controller** (Traefik ou Nginx).
* Configurer un nom de domaine (ex: `f1.mon-site.com`).
* Fermer le port 30000 dans le firewall AWS.



#### 🛑 PHASE 5 : Automatisation (CI/CD - GitHub Actions)

**Statut : À FAIRE**

* **État actuel :**
* Build Docker manuel sur ton PC.
* Push manuel sur DockerHub.
* `kubectl apply` manuel sur le serveur.


* **Objectif :**
* Tu modifies le code VS Code -> `git push`.
* GitHub Actions teste le code.
* GitHub Actions build l'image et la push.
* GitHub Actions parle à ton cluster pour mettre à jour l'app tout seul.



#### 🆕 PHASE 6 : Monitoring (Observabilité)

**Statut : À FAIRE (La cerise sur le gâteau)**

* **État actuel :** On pilote à l'aveugle (on ne sait pas si les serveurs souffrent).
* **Objectif :** Stack **Prometheus + Grafana**.
* **Prometheus :** Aspire les métriques (CPU, RAM, Disque, Nombre de votes/sec).
* **Grafana :** Affiche de beaux tableaux de bord graphiques.
* *Bonus :* Alertes (Recevoir un mail si Redis tombe).



---

### 📅 Programme pour demain

On va suivre l'ordre logique :

1. **Matin :** Automatisation de l'installation du cluster (**Ansible**).
2. **Midi :** Propreté Réseau (**Ingress** & **Domaine**) pour virer le port 30000.
3. **Après-midi :** Pipeline de déploiement (**GitHub Actions**).
4. **Fin de journée :** Monitoring (**Grafana**).

Bonne nuit, repose-toi bien, demain on industrialise tout ça ! 😴🛠️