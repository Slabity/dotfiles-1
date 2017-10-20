# build with:
# $ nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./install-iso.nix
# $ dd if=result/iso/nixos-*.iso of=/dev/sdb
# iso>
# iso> sgdisk -n 1:0:+300M -N 2 -t 1:ef02 -t 2:8300 /dev/sda
# iso> mkfs.vfat /dev/sda1
# iso> zpool create -f zroot /dev/disk/by-partuuid/046fdb0b-114f-4435-9d8c-957ac73b5cd2
# iso> nc -6 -w 120 -l -p 8023 | zfs receive -F zroot
# host> sudo zfs snapshot -r zroot@zfs-send
# host> sudo zfs send -R zroot@zfs-send | nc -w 20 fe80::6af7:28ff:feb2:8706%enp0s25 8023
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
      ./base-config.nix
  ];
  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "ac174b52";
}

# legay cryptsetup:
# iso> cryptsetup luksFormat /dev/sda2
# iso> cryptsetup luksOpen /dev/sda2 root
# iso> zpool create -f zroot /dev/mapper/root

## New zroot setup
# zfs create -o acltype=posixacl -o xattr=sa -o encryption=aes-256-gcm -o keyformat=passphrase -o compression=lz4 -o mountpoint=none zroot/root
# zfs create -o mountpoint=legacy -o setuid=off -o devices=off -o sync=disabled zroot/root/tmp
# zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=true zroot/root/home
# zfs create -o mountpoint=legacy -o com.sun:auto-snapshot=true zroot/root/nixos
# mount -t zfs zroot/root/nixos /mnt
# mkdir /mnt/{home,tmp,boot}
# mount /dev/sda1 /mnt/boot/
# mount -t zfs zroot/root/home /mnt/home/
# mount -t zfs zroot/root/tmp /mnt/tmp/
# nixos-generate-config  --root /mnt
# nixos-install