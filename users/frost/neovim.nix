{inputs, ...}: {
  imports = [inputs.nvf.homeManagerModules.default];

  wayland.windowManager.hyprland.settings.input = {
    kb_options = "caps:escape_shifted_capslock";
  };

  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings = {
      vim = {
        viAlias = true;
        theme = {
          enable = true;
          name = "catppuccin";
          transparent = true;
          style = "mocha";
        };
        options = {
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
          textwidth = 80;
          relativenumber = true;
          number = true;
          colorcolumn = "80";
        };
        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };
        keymaps = [
          {
            key = "<leader>pv";
            mode = "n";
            silent = true;
            action = ":Ex<CR>";
          }
          {
            key = "<C-s>";
            mode = "n";
            silent = false;
            action = ":w<CR>";
          }
          {
            key = "<leader>u";
            mode = "n";
            silent = true;
            action = ":UndotreeToggle<CR>";
          }
          {
            key = "<leader>gs";
            mode = "n";
            silent = false;
            action = ":Git<CR>";
          }
          {
            key = "<C-w>";
            mode = "n";
            silent = false;
            action = ":q<CR>";
          }
        ];
        lsp = {
          enable = true;
          formatOnSave = true;
        };
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          nix.enable = true;
          rust.enable = true;
          go.enable = true;
          ts.enable = true;
          clang.enable = true;
          cmake.enable = true;
        };
        statusline.lualine.enable = true;
        telescope = {
          enable = true;
          mappings = {
            findFiles = "pf";
            liveGrep = "ps";
            gitFiles = "pg";
          };
        };
        autocomplete.nvim-cmp.enable = true;
        git = {
          vim-fugitive.enable = true;
        };
        utility = {
          undotree.enable = true;
        };
      };
    };
  };
}
