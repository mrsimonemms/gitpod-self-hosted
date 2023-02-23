terraform {
  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = ">=2.6.0, < 3.0.0"
    }
  }
}

module "common" {
  source = "../common"
}
