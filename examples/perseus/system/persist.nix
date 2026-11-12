{
  directories = [
    # /bin, /lib64, /usr -> /nix symlinks
    # /nix, /boot -> own mounts
    # /proc, /sys, /dev, /run, /tmp -> virtual/runtime
    # /srv, /media, /lost+found -> not needed

    "/var/log"
    "/var/db/sudo/lectured"
    "/var/lib/nixos"
    "/var/lib/sops-nix"
    "/var/lib/NetworkManager"
    "/var/lib/systemd/coredump"
    "/var/lib/bluetooth"
    "/etc/ssh"
    "/etc/NetworkManager/system-connections"

    "/var/lib/private/seanime"
  ];
  files = [ "/etc/machine-id" ];
}
