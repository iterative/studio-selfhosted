packer {
  required_version = ">= 1.7.0, < 2.0.0"

  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0, < 2.0.0"
    }
  }
}

variable "boot_wait" {
  type    = string
  default = "1s"
}

variable "bundle_iso" {
  type    = string
  default = "false"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "disk_size" {
  type    = string
  default = "50000"
}

variable "guest_os_type" {
  type    = string
  default = "Ubuntu_64"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "host_port_max" {
  type    = string
  default = "4444"
}

variable "host_port_min" {
  type    = string
  default = "2222"
}

variable "http_port_max" {
  type    = string
  default = "9000"
}

variable "http_port_min" {
  type    = string
  default = "8000"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
}

variable "iso_file" {
  type    = string
  default = "ubuntu-22.04.2-live-server-amd64.iso"
}

variable "iso_path_external" {
  type    = string
  default = "https://releases.ubuntu.com/releases/jammy"
}

variable "keep_registered" {
  type    = string
  default = "false"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "packer_cache_dir" {
  type    = string
  default = "${env("PACKER_CACHE_DIR")}"
}

variable "shutdown_timeout" {
  type    = string
  default = "30m"
}

variable "skip_export" {
  type    = string
  default = "false"
}

variable "ssh_agent_auth" {
  type    = string
  default = "false"
}

variable "ssh_clear_authorized_keys" {
  type    = string
  default = "true"
}

variable "ssh_disable_agent_forwarding" {
  type    = string
  default = "false"
}

variable "ssh_file_transfer_method" {
  type    = string
  default = "scp"
}

variable "ssh_handshake_attempts" {
  type    = string
  default = "100"
}

variable "ssh_keep_alive_interval" {
  type    = string
  default = "5s"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_password" {
  type    = string
  default = "ubuntu"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_pty" {
  type    = string
  default = "false"
}

variable "ssh_timeout" {
  type    = string
  default = "60m"
}

variable "start_retry_timeout" {
  type    = string
  default = "5m"
}

variable "version" {
  type    = string
  default = "0.0.0"
}

variable "vm_name" {
  type    = string
  default = "studio-selfhosted"
}

variable "vnc_vrdp_bind_address" {
  type    = string
  default = "127.0.0.1"
}

variable "vnc_vrdp_port_max" {
  type    = string
  default = "6000"
}

variable "vnc_vrdp_port_min" {
  type    = string
  default = "5900"
}

# The "legacy_isotime" function has been provided for backwards compatability,
# but we recommend switching to the timestamp and formatdate functions.
locals {
  output_directory = "build/${legacy_isotime("2006-01-02-15-04-05")}"
}


source "virtualbox-iso" "vbox" {
  boot_command = [
    "<wait5>",
    "c<wait>",
    "set gfxpayload=keep <enter><wait>",
    "linux /casper/vmlinuz <wait>",
    "autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{.HTTPPort}}/' --- <enter><wait>",
    "initrd /casper/initrd <enter><wait>",
    "boot<enter>"

  ]
  boot_wait                = var.boot_wait
  bundle_iso               = var.bundle_iso
  cpus                     = var.cpus
  disk_size                = var.disk_size
  format                   = "ova"
  guest_additions_mode     = "disable"
  guest_os_type            = var.guest_os_type
#  hard_drive_discard       = false
#  hard_drive_interface     = "sata"
#  hard_drive_nonrotational = false
  headless                 = var.headless
  host_port_max            = var.host_port_max
  host_port_min            = var.host_port_min
  http_directory           = "./"
  http_port_max            = var.http_port_max
  http_port_min            = var.http_port_min
  iso_checksum             = var.iso_checksum
#  iso_interface            = "sata"
  iso_target_extension     = "iso"
  iso_target_path          = "${regex_replace(var.packer_cache_dir, "^$", "/tmp")}/${var.iso_file}"
  iso_urls = [
    "${var.iso_path_external}/${var.iso_file}"
  ]
  keep_registered              = var.keep_registered
  memory                       = var.memory
  output_directory             = local.output_directory
  post_shutdown_delay          = "0s"
#  sata_port_count              = "1"
  shutdown_command             = "echo '${var.ssh_password}' | sudo -E -S poweroff"
  shutdown_timeout             = var.shutdown_timeout
  skip_export                  = var.skip_export
  skip_nat_mapping             = false
  ssh_agent_auth               = var.ssh_agent_auth
  ssh_clear_authorized_keys    = var.ssh_clear_authorized_keys
  ssh_disable_agent_forwarding = var.ssh_disable_agent_forwarding
  ssh_file_transfer_method     = var.ssh_file_transfer_method
  ssh_handshake_attempts       = var.ssh_handshake_attempts
  ssh_keep_alive_interval      = var.ssh_keep_alive_interval
  ssh_password                 = var.ssh_password
  ssh_port                     = var.ssh_port
  ssh_pty                      = var.ssh_pty
  ssh_timeout                  = var.ssh_timeout
  ssh_username                 = var.ssh_username
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--rtc-use-utc", "on"],
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
  ]
  virtualbox_version_file = "/tmp/.vbox_version"
  vm_name                 = var.vm_name
  vrdp_bind_address       = var.vnc_vrdp_bind_address
  vrdp_port_max           = var.vnc_vrdp_port_max
  vrdp_port_min           = var.vnc_vrdp_port_min
}

build {

  sources = [ "source.virtualbox-iso.vbox"]

  provisioner "shell" {
    binary            = false
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "cloud-init status --wait"
    ]
    inline_shebang      = "/bin/sh -e"
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }

  provisioner "shell" {
    binary            = false
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "apt-get update",
      "apt-get --yes dist-upgrade",
      "apt-get clean",
      "apt-get install --yes ntp",
      "echo '${var.ssh_username} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
    ]
    inline_shebang      = "/bin/sh -e"
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }
  # Install script running as 'root'
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
    source      = "setup_root.sh"
    destination = "/home/ubuntu/.studio_install/setup_root.sh"
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
