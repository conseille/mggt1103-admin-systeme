# Rapport — Séance 3 : Infrastructure-as-Code avec Terraform

**Étudiant :** MUPINI KABWE ALBERT  
**Cours :** MGGT1103 — Administration Système, Cloud-Native & DevOps  
**Titulaire :** Dr. Roméo NIBITANGA  
**Thème :** Infrastructure-as-Code avec Terraform  
**Environnement :** WSL2 Ubuntu  

---

## 1. Objectif du TP

Ce TP avait pour objectif de découvrir l’Infrastructure-as-Code avec Terraform.

Le travail consistait à écrire une configuration déclarative en langage HCL afin de créer automatiquement un fichier de configuration DNS sur la machine locale.

Le fichier généré par Terraform est :

```text
/tmp/dns_config.txt
```

---

## 2. Fichiers principaux du rendu

Les fichiers principaux du TP3 sont :

```text
rendu-final/main.tf
rendu-final/.gitignore
rapport/rapport_seance3.md
```

Les fichiers de preuve sont rangés dans :

```text
resultats/
```

---

## 3. Installation et vérification de Terraform

Terraform a été installé dans WSL2 Ubuntu.

Commande utilisée pour vérifier l’installation :

```bash
terraform --version
```

Le résultat de cette commande est sauvegardé dans :

```text
resultats/terraform-version.txt
```

---

## 4. Configuration Terraform

Le fichier `main.tf` utilise le provider local `hashicorp/local`.

Il déclare une ressource `local_file` qui permet de créer automatiquement un fichier local :

```text
/tmp/dns_config.txt
```

Le contenu attendu du fichier DNS est :

```text
nameserver 192.168.56.200
nameserver 8.8.8.8
```

Cette configuration montre que Terraform peut créer une ressource locale à partir d’un fichier déclaratif.

---

## 5. Workflow Terraform utilisé

Les commandes principales utilisées pendant le TP sont :

```bash
terraform init
terraform plan
terraform apply
```

La commande `terraform init` a permis d’initialiser le projet et d’installer le provider nécessaire.

La commande `terraform plan` a permis de simuler les changements avant application.

La commande `terraform apply` a permis de créer réellement le fichier DNS.

Après `terraform apply`, la commande suivante a permis de vérifier le résultat :

```bash
cat /tmp/dns_config.txt
```

Résultat observé :

```text
nameserver 192.168.56.200
nameserver 8.8.8.8
```

---

## 6. Utilisation d’une variable Terraform

Le fichier `main.tf` contient une variable nommée :

```text
dns_primary_ip
```

Cette variable permet de rendre l’adresse DNS primaire dynamique.

Valeur par défaut utilisée :

```text
192.168.56.200
```

Un test de surcharge de variable a été réalisé avec la commande suivante :

```bash
terraform plan -var="dns_primary_ip=10.10.10.10"
```

Terraform a correctement détecté que le contenu du fichier DNS devait changer de :

```text
nameserver 192.168.56.200
nameserver 8.8.8.8
```

vers :

```text
nameserver 10.10.10.10
nameserver 8.8.8.8
```

Cela montre que la configuration Terraform est réutilisable et dynamique.

---

## 7. Différence entre approche déclarative et approche impérative

Dans une approche impérative, l’administrateur décrit les étapes exactes à exécuter pour obtenir un résultat.  
Par exemple, il écrit une suite de commandes à lancer dans un ordre précis.

Dans une approche déclarative, l’administrateur décrit l’état final souhaité.  
Terraform compare ensuite l’état actuel avec l’état demandé, puis applique uniquement les changements nécessaires.

Terraform suit donc une approche déclarative, car le fichier `main.tf` décrit le résultat attendu et Terraform décide lui-même des actions à réaliser.

---

## 8. Pourquoi terraform.tfstate ne doit pas être envoyé sur GitHub

Le fichier `terraform.tfstate` contient l’état réel de l’infrastructure gérée par Terraform.

Ce fichier peut contenir des informations sensibles comme :

- des adresses IP ;
- des chemins internes ;
- des identifiants ;
- des informations de configuration ;
- des détails sur les ressources créées.

Pour cette raison, il ne doit pas être envoyé sur un dépôt GitHub public.

Le fichier `.gitignore` permet d’ignorer les fichiers sensibles ou générés automatiquement :

```text
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
.terraform.tfstate.lock.info
```

Cette protection évite de publier accidentellement l’état interne de l’infrastructure.

---

## 9. Nettoyage du laboratoire

À la fin du TP, la commande suivante permet de supprimer la ressource créée :

```bash
terraform destroy
```

Cette commande supprime proprement le fichier :

```text
/tmp/dns_config.txt
```

Le nettoyage permet d’éviter de laisser des ressources inutiles sur la machine.

---

## 10. Conclusion

Ce TP m’a permis de comprendre les bases de Terraform et de l’Infrastructure-as-Code.

J’ai appris à écrire une configuration HCL, initialiser un projet Terraform, simuler les changements avec `terraform plan`, appliquer une configuration avec `terraform apply`, utiliser une variable et protéger le fichier d’état avec `.gitignore`.

Ce travail montre l’importance de l’approche déclarative dans l’administration système moderne et les pratiques DevOps.
