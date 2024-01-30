packer {}

source "arm" "ubuntu" {
  file_urls                    = ["ubuntu-22.04-base.img"]
  file_checksum_url            = "ubuntu-22.04-base.sha256"
  file_target_extension        = "img"
  file_checksum_type           = "sha256"
  image_build_method           = "reuse"
  image_size                   = "3.1G"
  image_type                   = "dos"
  image_chroot_env             = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  qemu_binary_source_path      = "/usr/bin/qemu-aarch64-static"
  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
  image_partitions {
    name         = "boot"
    type         = "c"
    start_sector = "2048"
    filesystem   = "fat"
    size         = "256M"
    mountpoint   = "/boot/firmware"
  }
  image_partitions {
    name         = "root"
    type         = "83"
    start_sector = "526336"
    filesystem   = "ext4"
    size         = "2.8G"
    mountpoint   = "/"
  }
}

build {
  source "base.arm.ubuntu" {
    image_path = "ubuntu-22.04-${var.type}-${local.node_hostname}.img"
  }
  provisioner "file" {
    content     = replace(file("cloud-init/arm-ubuntu-${var.type}/network-config"), "$node", local.node_ip)
    destination = "/boot/firmware/network-config"
  }
  provisioner "file" {
    content     = replace(file("cloud-init/arm-ubuntu-${var.type}/user-data"), "$node", local.node_hostname)
    destination = "/boot/firmware/user-data"
  }
}

locals {
  node          = var.node
  node_hostname = var.type == "kube" ? format("node%02.0f", var.node) : var.node
  node_ip       = var.type == "kube" ? convert(var.node, number) + 5 : ""
}

variable "node" {
  type    = string
  default = 0
}

variable "type" {
  type    = string
  default = "kube"
}
