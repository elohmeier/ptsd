{ config, lib, pkgs, ... }:

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


  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        vim-css-color
        nvim-web-devicons
        hop-nvim
        nvim-compe
        telescope-nvim
        lualine-nvim
        copilot-vim
        nvim-lspconfig
        formatter-nvim

        (nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-beancount
          tree-sitter-go
          tree-sitter-nix
          tree-sitter-norg
          tree-sitter-python
        ]))

        nnn-nvim
        editorconfig-nvim
      ];
    };
  };
in
{
  # package & EDITOR env are configured in ../nwhost-mini.nix

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/nvim";
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
