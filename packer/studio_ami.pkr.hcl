packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variables {
  image_name             = "studio-selfhosted"
  image_description      = "Iterative Studio Selfhosted - {{isotime `2006-01-02`}}"
  aws_build_region       = "us-east-1"
  aws_build_instance     = "c6a.large"
  aws_build_ubuntu_image = "*ubuntu-*-22.04-amd64-server-*"
  skip_create_ami        = true
  kh_klipper_tag         = "latest"
}

locals {
  aws_tags = {
    ManagedBy   = "packer"
    Name        = var.image_name
    Environment = "prod"
    BuildDate   = "{{isotime `2006-01-02`}}"
  }

  aws_release_regions = [
    "af-south-1",
    "ap-east-1",
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-northeast-3",
    "ap-south-1",
    "ap-south-2",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-southeast-3",
    "ap-southeast-4",
    "ca-central-1",
    "eu-central-1",
    "eu-central-2",
    "eu-north-1",
    "eu-south-1",
    "eu-south-2",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "me-central-1",
    "me-south-1",
    "sa-east-1",
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
  ]
}

data "amazon-ami" "ubuntu" {
  region      = var.aws_build_region
  owners      = ["099720109477"]
  most_recent = true

  filters = {
    name                = "ubuntu/images/${var.aws_build_ubuntu_image}"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }

  #  assume_role {
  #    role_arn     = var.aws_role_arn
  #    session_name = var.aws_role_session_name
  #  }
}

source "amazon-ebs" "source" {
  ami_groups      = ["all"]
  ami_name        = var.skip_create_ami ? "studio-selfhosted {{isotime `2006-01-02_15-04-05`}}" : var.image_name
  ami_description = var.image_description
  ami_regions     = local.aws_release_regions
  skip_create_ami = var.skip_create_ami

  region              = var.aws_build_region
  spot_price          = "0.2"
  spot_instance_types = [var.aws_build_instance]
  #  instance_type = var.aws_build_instance

  source_ami   = data.amazon-ami.ubuntu.id
  ssh_username = "ubuntu"

  force_delete_snapshot = !var.skip_create_ami
#   force_deregister      = !var.skip_create_ami

  tags            = local.aws_tags
  run_tags        = local.aws_tags
  run_volume_tags = local.aws_tags

  temporary_security_group_source_public_ip = true
}

build {
  sources = ["source.amazon-ebs.source"]

  provisioner "shell" {
    inline = [
      "mkdir /home/ubuntu/.studio_install",
    ]
  }

  provisioner "file" {
    source      = "k3s.sh"
    destination = "/home/ubuntu/.studio_install/k3s.sh"
  }

  provisioner "file" {
    source      = "helm3.sh"
    destination = "/home/ubuntu/.studio_install/helm3.sh"
  }

  provisioner "file" {
    source      = "create-support-bundle.sh"
    destination = "/home/ubuntu/.studio_install/create-support-bundle"
  }

  provisioner "file" {
    destination = "/home/ubuntu/.studio_install/setup_root.sh"
    content = templatefile("setup_root.sh", {
      kh_klipper_tag = var.kh_klipper_tag
    })
  }

  provisioner "file" {
    source      = "setup_ubuntu.sh"
    destination = "/home/ubuntu/.studio_install/setup_ubuntu.sh"
  }

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  # Install script running as 'root'
  provisioner "shell" {
    inline = ["sudo bash /home/ubuntu/.studio_install/setup_root.sh"]
  }

  # Install script running as 'ubuntu'
  provisioner "shell" {
    inline = ["bash /home/ubuntu/.studio_install/setup_ubuntu.sh"]
  }
}
