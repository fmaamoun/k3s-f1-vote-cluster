# k3s-f1-vote-cluster

k3s-f1-vote-cluster/
│
├── .gitignore               # Pour ignorer les clés secrètes et les node_modules
├── README.md                # La documentation du projet (très important pour le CV)
│
├── 📂 app/                  # --- PHASE 1 : CODE SOURCE ---
│   ├── src/                 # Le code SvelteKit
│   ├── static/              # Images (logos F1)
│   ├── Dockerfile           # La recette pour créer l'image
│   ├── package.json         # Dépendances Node.js
│   └── svelte.config.js     # Config Svelte
│
├── 📂 infra/                # --- PHASE 2 : TERRAFORM ---
│   ├── main.tf              # Le code principal (EC2, VPC, SG)
│   ├── outputs.tf           # Ce qui affiche les IP à la fin
│   ├── provider.tf          # Config AWS
│   └── variables.tf         # (Optionnel) Pour rendre le code propre
│
├── 📂 k8s/                  # --- PHASE 4 : KUBERNETES YAML ---
│   ├── 01-namespace.yaml    # Pour isoler le projet
│   ├── 02-redis.yaml        # Déploiement de la DB (sur le Master)
│   ├── 03-app.yaml          # Déploiement de l'App (sur les Workers)
│   └── 04-ingress.yaml      # (Optionnel) Si on ajoute un nom de domaine
│
└── 📂 ansible/              # --- PHASE 3/5 : AUTOMATISATION ---
    ├── inventory.ini        # Liste des IPs (remplie après Terraform)
    └── playbook.yml         # Le script d'installation K3s (pour plus tard)