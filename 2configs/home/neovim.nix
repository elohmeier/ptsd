p@{ config, lib, pkgs, ... }:

let
  nnn-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2022-06-06";
    src = pkgs.fetchFromGitHub {
      owner = "luukvbaal";
      repo = "nnn.nvim";
      rev = "dc6c5253a5822e2199d7bac318c38a63cfa189ac";
      sha256 = "sha256-AimlWrGoj29aEg9Rf6PVskZX1Ashloq7zvMdfQo+1ZM=";
    };
  };

  copilot-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "copilot.vim";
    version = "1.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "da286d8c52159026f9cba16cd0f98b609c056841";
      sha256 = "sha256-0cZS1wK884YBIAF4mbLTTS+D26OzpMh1mZtWfFYz7ng=";
    };
    meta.homepage = "https://github.com/github/copilot.vim/";
  };

  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        cmp-buffer
        cmp-nvim-lsp
        cmp-path
        cmp_luasnip
        copilot-vim
        editorconfig-nvim
        formatter-nvim
        hop-nvim
        lualine-nvim
        luasnip
        nnn-nvim
        nvim-cmp
        nvim-lspconfig
        nvim-web-devicons
        telescope-fzf-native-nvim
        telescope-nvim

        (nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-beancount
          tree-sitter-go
          tree-sitter-java
          tree-sitter-nix
          tree-sitter-norg
          tree-sitter-python
        ]))
      ];
    };
  };
in
{
  # package & EDITOR env are configured in ../nwhost-mini.nix

  home.file.".config/nvim".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/nvim else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/nvim";
  home.file.".local/share/nvim/site/pack".source = "${pluginPack}/pack";

  home.packages = with pkgs;[
    gopls
    luaformatter
    nodejs # for copilot
    pyright
    ripgrep # for telescope
    rnix-lsp
  ];

  home.sessionVariables.EDITOR = "nvim";
}
