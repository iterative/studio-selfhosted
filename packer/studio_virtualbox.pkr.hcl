packer {
  required_version = ">= 1.7.0, < 2.0.0"

  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = ">= 1.0.0, < 2.0.0"
    }
  }
}

variables {
  cpus              = 4
  memory            = 8192
  disk_size         = "50000"
  headless          = false
  iso_path_external = "https://releases.ubuntu.com/releases/jammy"
  iso_file          = "ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum      = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
  keep_registered   = false
  packer_cache_dir  = "${env("PACKER_CACHE_DIR")}"
  skip_export       = false
  ssh_username      = "ubuntu"
  ssh_password      = "ubuntu"
  ssh_port          = "22"
  vm_name           = "{{isotime `2006-01-02_15-04`}}_studio-selfhosted"
  kh_klipper_tag    = "latest"
}


# The "legacy_isotime" function has been provided for backwards compatability,
# but we recommend switching to the timestamp and formatdate functions.
locals {
  output_directory = "build/"
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
  boot_wait            = "1s"
  bundle_iso           = false
  cpus                 = var.cpus
  disk_size            = var.disk_size
  format               = "ova"
  guest_additions_mode = "disable"
  guest_os_type        = "Ubuntu_64"
  #  hard_drive_discard       = false
  #  hard_drive_interface     = "sata"
  #  hard_drive_nonrotational = false
  headless       = var.headless
  host_port_min  = 2222
  host_port_max  = 4444
  http_directory = "./"
  http_port_min  = 8000
  http_port_max  = 9000
  iso_checksum   = var.iso_checksum
  #  iso_interface            = "sata"
  iso_target_extension = "iso"
  iso_target_path      = "${regex_replace(var.packer_cache_dir, "^$", "/tmp")}/${var.iso_file}"
  iso_urls = [
    "${var.iso_path_external}/${var.iso_file}"
  ]
  keep_registered              = var.keep_registered
  memory                       = var.memory
  output_directory             = local.output_directory
  post_shutdown_delay          = "0s"
  shutdown_command             = "echo '${var.ssh_password}' | sudo -E -S poweroff"
  shutdown_timeout             = "10m"
  skip_export                  = var.skip_export
  skip_nat_mapping             = false
  ssh_agent_auth               = false
  ssh_clear_authorized_keys    = true
  ssh_disable_agent_forwarding = false
  ssh_file_transfer_method     = "scp"
  ssh_handshake_attempts       = 100
  ssh_keep_alive_interval      = "5s"
  ssh_username                 = var.ssh_username
  ssh_password                 = var.ssh_password
  ssh_port                     = var.ssh_port
  ssh_pty                      = false
  ssh_timeout                  = "30m"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--rtc-use-utc", "on"],
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
  ]
  virtualbox_version_file = "/tmp/.vbox_version"
  vm_name                 = var.vm_name
  vrdp_bind_address       = "0.0.0.0"
  vrdp_port_min           = 5900
  vrdp_port_max           = 6000
}

build {

  sources = ["source.virtualbox-iso.vbox"]

  provisioner "shell" {
    binary            = false
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "cloud-init status --wait"
    ]
    inline_shebang      = "/bin/sh -e"
    skip_clean          = false
    start_retry_timeout = "5m"
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
    start_retry_timeout = "5m"
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
