# Options

Generated from the option declarations by `just docs`; do not edit by hand.
`nix flake check` fails when this file is out of date. Module `enable` flags
are listed in the module table of [guide.md](guide.md#76-modules).

## NixOS options

Set in `system/`.

- `machine.directories.home` (attribute set of string): Well-known home directories, relative to each user's home; each can be overridden on its own. The user key (`identity`) must be inside a directory of home, because that directory is persisted with mode 0700

  Default:

  ```nix
  {
    bin = ".local/bin";
    boxes = "boxes";
    cache = ".cache";
    config = ".config";
    data = ".local/share";
    desktop = ".local/share/.xdg-ignore";
    documents = "documents";
    download = "downloads";
    identity = ".ssh/id_ed25519";
    media = "media";
    music = "media/audio";
    pictures = "media/images";
    projects = "projects";
    publicShare = ".local/share/.xdg-ignore";
    screencasts = "media/videos/screencasts";
    screenshots = "media/images/screenshots";
    state = ".local/state";
    templates = ".local/share/.xdg-ignore";
    videos = "media/videos";
    wallpapers = "media/images/wallpapers";
  }
  ```

- `machine.directories.identity` (string): Host SSH key, also the age identity for host secrets

  Default: `"/etc/ssh/ssh_host_ed25519_key"`

- `machine.directories.nixos` (string): Where users check out the machine repository, used by the scripts and nh; `$HOME` is expanded at runtime

  Default: `"$HOME/.config/nixos"`

- `modules.core.ethernet.priority` (signed integer): Autoconnect priority of the ethernet profile

  Default: `100`

- `modules.core.wifi` (attribute set of (submodule)): Wi-Fi networks by name; each reads `networking/wifi/<name>/ssid` and `.../password` from the host secrets

  Default: `{ }`

- `modules.core.wifi.<name>.autoconnect` (boolean): Whether to connect to this network automatically

  Default: `true`

- `modules.core.wifi.<name>.priority` (signed integer): Autoconnect priority of this network

  Default: `10`

## Home Manager options

Set in `users/<name>/home.nix`.

- `modules.git.identityFromSecrets` (boolean): Whether to enable reading the identity from git/name and git/email in the user's secrets.yaml, so it stays out of the repository.

  Default: `false`

- `modules.git.user` (null or (submodule)): Identity written in plain text into the git config

  Default: `null`

- `modules.git.user.email` (string): Author email

- `modules.git.user.name` (string): Author name

- `modules.obs.plugins` (list of (attribute set)): OBS plugin packages

  Default: `[ ]`

- `modules.obs.profiles` (attribute set of (attribute set)): Profiles by name, each written to its `basic.ini`; recordings go to `user.directories.screencasts`

  Default:

  ```nix
  {
    Untitled = { };
  }
  ```

- `modules.obs.settings` (submodule): OBS settings files; changes made in OBS are overwritten on the next activation

  Default: `{ }`

- `modules.obs.settings.global` (attribute set): INI sections written to `obs-studio/global.ini` on every activation

  Default: `{ }`

- `modules.obs.settings.user` (attribute set): INI sections written to `obs-studio/user.ini` on every activation

  Default: `{ }`

- `modules.open.audio` (null or package or (submodule)): Default application for audio files: a package, or `{ package; desktopEntry; }`

  Default: `null`

- `modules.open.directory` (null or package or (submodule)): Default application for directory files: a package, or `{ package; desktopEntry; }`

  Default: `null`

- `modules.open.html` (null or package or (submodule)): Default application for html files: a package, or `{ package; desktopEntry; }`

  Default: `null`

- `modules.open.image` (null or package or (submodule)): Default application for image files: a package, or `{ package; desktopEntry; }`

  Default: `null`

- `modules.open.pdf` (null or package or (submodule)): Default application for pdf files: a package, or `{ package; desktopEntry; }`

  Default: `null`

- `modules.open.video` (null or package or (submodule)): Default application for video files: a package, or `{ package; desktopEntry; }`

  Default: `null`

- `modules.theme.variant` (one of "dark", "light"): Color scheme for GTK, Qt and the cursor

  Default: `"dark"`

- `user.allowUnfree` (list of string): Unfree package names this user installs; allowed machine-wide, because all users share the system's nixpkgs

  Default: `[ ]`

- `user.description` (string): Account description (full name)

  Default: `""`

- `user.directories` (attribute set of string): Absolute paths of well-known home directories, by default machine.directories.home resolved against home.homeDirectory; each can be overridden on its own

  Default: each of `machine.directories.home` under `home.homeDirectory`

- `user.groups` (list of string): Groups of the account

  Default:

  ```nix
  [
    "wheel"
    "networkmanager"
  ]
  ```

- `user.shell` (package): Login shell, also exported as SHELL; modules.zsh makes it zsh by default

  Default: `pkgs.bashInteractive`

- `user.terminal` (null or package): Terminal emulator exported as TERMINAL; modules.hyprland makes it kitty by default

  Default: `null`

