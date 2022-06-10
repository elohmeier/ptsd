{ config, lib, pkgs, ... }:

let
  nnn-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2022-03-11";
    src = pkgs.fetchFromGitHub {
      owner = "luukvbaal";
      repo = "nnn.nvim";
      rev = "9462b759b546efee2646c8f0f765d472399a28cb";
      sha256 = "sha256-piqu6unJjYyNBaPj9BMQMQY3mbMCdGEs9sJZIa/NuXw=";
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
}
