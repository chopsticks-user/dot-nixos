{ self, inputs, ... }: {
  flake.nixosModules.laptopConfiguration = { config, pkgs, lib, ... }: {
    imports = [ 
      self.nixosModules.laptopHardware
      self.nixosModules.hyprland
      self.nixosModules.homeManager
    ];

# Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "perseus"; # Define your hostname.
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

# Configure network proxy if necessary
# networking.proxy.default = "http://user:password@proxy:port/";
# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# Enable networking
      networking.networkmanager.enable = true;

# Set your time zone.
    time.timeZone = "America/New_York";

# Select internationalisation properties.
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          ignoreUserConfig = true;
          addons = with pkgs; [
            fcitx5-mozc
              fcitx5-rime
              fcitx5-gtk
              qt6Packages.fcitx5-unikey
          ];
          settings = {
            inputMethod = {
              "Groups/0" = {
                Name = "Default";
                "Default Layout" = "us";
                DefaultIM = "keyboard-us";
              };
              "Groups/0/Items/0".Name = "keyboard-us";
              "Groups/0/Items/1".Name = "mozc";
              "Groups/0/Items/2".Name = "rime";
              "Groups/0/Items/3".Name = "unikey";
            };
          };
        };
      };
    };

# Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

# Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.frost = {
      isNormalUser = true;
      description = "Frost";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ ];
      shell = pkgs.zsh;
    };

# Allow unfree packages
    nixpkgs.config.allowUnfree = true;

# List packages installed in system profile. To search, run:
# $ nix search wget
    environment.systemPackages = with pkgs; [
      lshw
        fastfetch
        nvitop
        glances
        wget
    ];

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 8";
    };
    environment.sessionVariables = {
      NH_OS_FLAKE = "$HOME/.nixos";
    };

    programs.zsh.enable = true;

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = self.stateVersion; # Did you read the comment?
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.kernelParams = [ 
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];
    boot.initrd.kernelModules = [ 
      "nvidia" 
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      NVD_BACKEND = "direct";
    };
    hardware.graphics = {
      enable = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    hardware.nvidia-container-toolkit.enable = true;
  };
                       }

