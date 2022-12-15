provider "aws" {
  region  = var.region
  profile = "default"
}

provider "aws" {
  alias   = "central"
  region  = var.alt-region
  profile = "default"
}
