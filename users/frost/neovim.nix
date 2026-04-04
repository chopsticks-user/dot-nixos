{ inputs, ... }: {
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings = {
      vim = {
        viAlias = true;
        options = {
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
          textwidth = 80;
          relativenumber = true;
          number = true;
          colorcolumn = "80";
        };
        theme = {
          enable = true;
          name = "catppuccin";
          transparent = true;
          style = "mocha";
        };
        languages = {
          nix.enable = true;
          rust.enable = true;
          go.enable = true;
        };
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
      };
    };
  };
                 }
