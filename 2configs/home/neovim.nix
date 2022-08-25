p@{ config, lib, pkgs, ... }:

let
  nnn-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2022-08-23";
    src = pkgs.fetchFromGitHub {
      owner = "luukvbaal";
      repo = "nnn.nvim";
      rev = "f9a4584085d37844c23874d916bc3934c6beabf0";
      sha256 = "sha256-qjGieRXdf50Jo447WkIa2uHJqORW0jHtqXo8IFxkEhA=";
    };
  };

  copilot-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "copilot.vim";
    version = "1.5.2";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "e219dd98b530db1d68adf8e98c3f0e3e67c77bec";
      sha256 = "sha256-zX7it18StK1fVnaRPawQT05YgCFbAt6kqcxgcNCd7Kk=";
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
