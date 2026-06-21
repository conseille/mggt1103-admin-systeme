# ==============================================================================
# MGGT1103 - TP3 : Infrastructure-as-Code avec Terraform
# Étudiant : MUPINI KABWE ALBERT
# Objectif : générer un fichier de configuration DNS avec Terraform
# ==============================================================================

terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}

variable "dns_primary_ip" {
  description = "Adresse IP du serveur de resolution DNS primaire"
  type        = string
  default     = "192.168.56.200"
}

resource "local_file" "dns_config" {
  filename = "/tmp/dns_config.txt"
  content  = "nameserver ${var.dns_primary_ip}\nnameserver 8.8.8.8"
}
