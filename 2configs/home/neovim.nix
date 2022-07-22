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
    version = "2022-06-07";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "aa9e451dda857c6615f531f8d4e4f201e43d7a03";
      sha256 = "1i272gzvm4psqynw7pqyb00zlmx9q0r8z9l5iswy6kjwgvzz9298";
    };
    meta.homepage = "https://github.com/github/copilot.vim/";
  };

  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        copilot-vim
        editorconfig-nvim
        formatter-nvim
        hop-nvim
        lualine-nvim
        nnn-nvim
        nvim-compe
        nvim-lspconfig
        nvim-web-devicons
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
    rnix-lsp
  ];

  home.sessionVariables.EDITOR = "nvim";
}
