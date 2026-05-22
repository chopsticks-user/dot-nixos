{
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;

  environment.persistence."/persist" = {
    directories = [
      # /bin, /lib64, /usr -> /nix symlinks
      # /nix, /boot -> own mounts
      # /proc, /sys, /dev, /run, /tmp -> virtual/runtime
      # /srv, /media, /lost+found -> not needed

      "/var/log"
      "/var/lib/nixos"
      "/var/lib/sops-nix"
      "/var/lib/NetworkManager"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"

      "/etc/ssh"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
