{ config, pkgs, ... }:
with import <ptsd/lib>;

let
  # TODO: setup black integration in vim
  py3 = pkgs.python3.withPackages (
    pythonPackages: with pythonPackages; [
      black
    ]
  );
  vc = pkgs.vim_configurable.override {
    features = "huge";
    guiSupport = "";
    luaSupport = false;
    perlSupport = false;
    pythonSupport = true;
    python = py3;
    rubySupport = false;
    tclSupport = false;
    netbeansSupport = false;
  };
  vim-beancount = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "vim-beancount";
    pname = "vim-beancount";
    version = "2017-10-28";
    src = pkgs.fetchFromGitHub {
      owner = "nathangrigg";
      repo = "vim-beancount";
      rev = "8054352c43168ece62094dfc8ec510e347e19e3c";
      sha256 = "0fd4fbdmhapdhjr3f9bhd4lqxzpdwwvpf64vyqwahkqn8hrrbc4m";
    };
  };
  vim-renamer = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-renamer";
    version = "2019-06-10";
    src = pkgs.fetchFromGitHub {
      owner = "qpkorr";
      repo = "vim-renamer";
      rev = "9c6346eb4556cf2d8ca55de6969247ab14fe2383";
      sha256 = "0gwyn9ff3f9pn5mkk31sxrs230p7fy66399p2yqy43xfqv36mzwl";
    };
  };
  tabnine-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "tabnine-vim";
    version = "2.11";
    src = pkgs.fetchFromGitHub {
      owner = "zxqfl";
      repo = "tabnine-vim";
      rev = "f7be9252afe46fa480593bebdd154278b39baa06";
      sha256 = "1jzpsrrdv53gji3sns1xaj3pq8f6bwssw5wwh9sccr9qdz6i6fwa";
    };
  };
  vim = vc.customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        set colorcolumn=88
        set ruler

        " fix nasty vim yaml defaults
        autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

        " disable folding e.g. in beancount-files
        set nofoldenable

        map <C-n> :NERDTreeToggle<CR>

        " close vim if the only window left open is a NERDTree
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

        " fix not being able to backspace more than beginning of insert-mode
        set backspace=indent,eol,start

        " required by YouCompleteMe
        set encoding=utf-8
      '';

      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ vim-nix vim-beancount nerdtree nerdtree-git-plugin ale vim-renamer tabnine-vim ];
      };
    };
  };
in
{
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.packages = [ vim ];
}
