terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Dynamic container configuration
variable "container_config" {
  type = list(object({
    name = string
    port = number
  }))

  default = [
    {
      name = "web1"
      port = 8083
    },
    {
      name = "web2"
      port = 8084
    },
    {
      name = "web3"
      port = 8085
    }
  ]
}

# Convert list to map for for_each
locals {
  containers = {
    for container in var.container_config :
    container.name => container
  }
}

# Module with for_each
module "nginx" {
  source = "./modules/nginx_container"

  for_each = local.containers

  container_name = each.value.name
  container_port = each.value.port
  image_name     = "nginx:latest"
}

# Output URLs
output "container_urls" {
  value = [
    for c in var.container_config :
    "http://localhost:${c.port}"
  ]
}
