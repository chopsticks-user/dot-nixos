{
  utils,
  inputs,
  ...
}@args:
(utils.mkProfile "neovim" {
  imports = [ inputs.nvf.homeManagerModules.default ];

  options = { };

  configs =
    { ... }:
    {
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
              softtabstop = 2;
              expandtab = true;
              textwidth = 80;
              relativenumber = true;
              number = true;
              colorcolumn = "80";
              scrolloff = 8;
              hlsearch = false;
              incsearch = true;
              smartindent = true;
              wrap = false;
              undofile = true;
              undolevels = 10000;
              termguicolors = true;
            };
            luaConfigPost = ''
              vim.api.nvim_create_autocmd("UIEnter", {
                once = true,
                callback = function()
                  local arg = vim.fn.argv(0)
                  if vim.fn.isdirectory(arg) == 1 then
                    vim.cmd("cd " .. vim.fn.fnameescape(arg))
                    vim.cmd("Telescope find_files")
                  end
                end,
              })
            '';
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
              {
                key = "J";
                mode = "v";
                silent = false;
                action = ":m '>+1<CR>gv=gv";
              }
              {
                key = "J";
                mode = "n";
                silent = false;
                action = "mzJ`z";
              }
              {
                key = "K";
                mode = "v";
                silent = false;
                action = ":m '<-2<CR>gv=gv";
              }
              {
                key = "<C-d>";
                mode = "n";
                silent = false;
                action = "<C-d>zz";
              }
              {
                key = "<C-u>";
                mode = "n";
                silent = false;
                action = "<C-u>zz";
              }
              {
                key = "n";
                mode = "n";
                silent = false;
                action = "nzzzv";
              }
              {
                key = "N";
                mode = "n";
                silent = false;
                action = "Nzzzv";
              }
              {
                key = "<leader>p";
                mode = "x";
                silent = false;
                action = "\"_dP";
              }
              {
                key = "<leader>y";
                mode = "n";
                silent = false;
                action = "\"+y";
              }
              {
                key = "<leader>y";
                mode = "v";
                silent = false;
                action = "\"+y";
              }
              {
                key = "<leader>Y";
                mode = "n";
                silent = false;
                action = "\"+Y";
              }
              {
                key = "Q";
                mode = "n";
                silent = false;
                action = "<nop>";
              }
              {
                key = "<leader>s";
                mode = "n";
                silent = false;
                action = ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>";
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
              typescript.enable = true;
              clang.enable = true;
              cmake.enable = true;
            };
            statusline.lualine = {
              enable = true;
              componentSeparator = { };
            };
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
    };
})
  args
