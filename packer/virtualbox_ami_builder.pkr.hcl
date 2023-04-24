packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variables {
  image_name             = "studio-virtualbox-builder"
  image_description      = "Studio Virtualbox Builder - {{isotime `2006-01-02`}}"
  aws_build_region       = "us-west-1"
  aws_build_instance     = "c6a.large"
  aws_build_ubuntu_image = "*ubuntu-*-22.04-amd64-server-*"
  skip_create_ami        = false
}

locals {
  aws_tags = {
    ManagedBy   = "packer"
    Name        = var.image_name
    Environment = "prod"
    BuildDate   = "{{isotime `2006-01-02`}}"
  }

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
}

source "amazon-ebs" "source" {
  ami_groups      = ["all"]
  ami_name        = var.skip_create_ami ? "studio-virtualbox-builder {{isotime `2006-01-02_15-04-05`}}" : var.image_name
  ami_description = var.image_description
  ami_regions     = ["us-west-1"]
  skip_create_ami = var.skip_create_ami

  region        = var.aws_build_region
    spot_price    = "0.2"
    spot_instance_types = [var.aws_build_instance]
#  instance_type = var.aws_build_instance

  source_ami   = data.amazon-ami.ubuntu.id
  ssh_username = "ubuntu"

  force_delete_snapshot = !var.skip_create_ami
  force_deregister      = !var.skip_create_ami

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
    source      = "setup_virtualbox.sh"
    destination = "/home/ubuntu/setup_virtualbox.sh"
  }

  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    binary            = false
    execute_command   = "{{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline            = [
      "apt-get update",
      "apt-get --yes dist-upgrade",
      "apt-get clean",
      "apt-get install --yes ntp",
    ]
    inline_shebang      = "/bin/sh -e"
    skip_clean          = false
    start_retry_timeout = "5m"
  }

  # Install script running as 'root'
  provisioner "shell" {
    inline              = ["sudo reboot"]
    start_retry_timeout = "5m"
    expect_disconnect   = true
  }

  # Install script running as 'root'
  provisioner "shell" {
    inline              = ["sudo bash /home/ubuntu/setup_virtualbox.sh"]
    start_retry_timeout = "5m"
  }
}
