packer {}

source "arm" "ubuntu" {
  file_urls = [
    "ubuntu-22.04.2-preinstalled-server-arm64+raspi.img.xz",
    "https://cdimage.ubuntu.com/releases/22.04.2/release/ubuntu-22.04.2-preinstalled-server-arm64+raspi.img.xz"
  ]
  file_checksum_url     = "https://cdimage.ubuntu.com/releases/22.04.2/release/SHA256SUMS"
  file_checksum_type    = "sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  image_build_method    = "reuse"
  image_size            = "3.1G"
  image_type            = "dos"
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
  source "source.arm.ubuntu" {
    image_path = "ubuntu-22.04-base.img"
  }
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "mv /etc/resolv.conf /etc/resolv.conf.bk",
      "echo 'nameserver 8.8.8.8' > /etc/resolv.conf",
      "apt-get update",
      "apt-get --yes install linux-modules-extra-raspi vlan",
      "apt-get --yes autoremove",
      "apt-get --yes clean",
      "mv /etc/resolv.conf.bk /etc/resolv.conf",
      "rm -rf /var/lib/apt/lists/*",
    ]
  }
  # provisioner "shell" {
  #   inline = [
  #     "ex -s -c 38m35 -c w -c q /etc/cloud/cloud.cfg"
  #     #"sed -i '/- growpart/d' /etc/cloud/cloud.cfg",
  #     #"sed -i '/- resizefs/d' /etc/cloud/cloud.cfg",
  #     #"echo 'growpart:\n   mode: off\nresize_rootfs: false' >> /etc/cloud/cloud.cfg"
  #   ]
  # }
  post-processor "checksum" {
    checksum_types = ["sha256"]
    output = "ubuntu-22.04-base.{{.ChecksumType}}"
  }
}
