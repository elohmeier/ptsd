{ lib, python3, vimUtils, fetchFromGitHub, vim_configurable, vimPlugins }:
let
  # TODO: setup black integration in vim
  py3 = python3.withPackages (
    pythonPackages: with pythonPackages; [
      black
    ]
  );
  vim-renamer = vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-renamer";
    version = "2019-06-10";
    src = fetchFromGitHub {
      owner = "qpkorr";
      repo = "vim-renamer";
      rev = "9c6346eb4556cf2d8ca55de6969247ab14fe2383";
      sha256 = "0gwyn9ff3f9pn5mkk31sxrs230p7fy66399p2yqy43xfqv36mzwl";
    };
  };
  vim-tickscript = vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-tickscript";
    version = "2017-12-01";
    src = fetchFromGitHub {
      owner = "nathanielc";
      repo = "vim-tickscript";
      rev = "399e332b709f034421c83af9ea14380d71e0d743";
      sha256 = "1fnv4vs3lngr3jn74p71dz5xgjlmy6qmr6xnfchx1k32bsidzjxj";
    };
  };
  tabnine-vim = vimUtils.buildVimPluginFrom2Nix rec {
    pname = "tabnine-vim";
    version = "2.8.2";
    src = fetchFromGitHub {
      owner = "zxqfl";
      repo = pname;
      rev = version;
      sha256 = "1rf27wf6il3gj2v05p9dg1j1p688f97zc959kf4wvf4dyxlv6v7x";
    };
  };
  commonrc = ''
    set colorcolumn=88
    set ruler

    " fix not being able to backspace more than beginning of insert-mode
    set backspace=indent,eol,start

    " fix nasty vim yaml defaults
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>
  '';
in
{
  small = (
    vim_configurable.override {
      # disable all the customizations, faster to build (vim from nix cache)
      #features = "huge";
      #guiSupport = "";
      #luaSupport = false;
      #perlSupport = false;
      #pythonSupport = false;
      #rubySupport = false;
      #tclSupport = false;
      #netbeansSupport = false;
    }
  ).customize {
    name = "vim";
    vimrcConfig = {
      customRC = commonrc;

      packages.myVimPackage = with vimPlugins; {
        start = [ vim-nix ];
      };
    };
  };

  big = (
    vim_configurable.override {
      #features = "huge";
      #guiSupport = "";
      #luaSupport = false;
      #perlSupport = false;
      #pythonSupport = true;
      #python = py3;
      #rubySupport = false;
      #tclSupport = false;
      #netbeansSupport = false;
    }
  ).customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        ${commonrc}

        " disable folding e.g. in beancount-files
        set nofoldenable

        map <C-n> :NERDTreeToggle<CR>

        " close vim if the only window left open is a NERDTree
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

        " required by YouCompleteMe
        set encoding=utf-8

        " For mouse click in NERDTree
        set mouse=a
        let g:NERDTreeMouseMode=3

        " Change the default mapping and the default command to invoke CtrlP
        let g:ctrlp_map = '<c-p>'
        let g:ctrlp_cmd = 'CtrlP'

        let g:airline_solarized_bg='dark'
        " let g:airline_theme = 'powerlineish'
        let g:airline_theme = 'solarized'
        let g:airline_powerline_fonts = 1
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#branch#enabled = 1
      '';

      packages.myVimPackage = with vimPlugins; {
        start = [ vim-nix vim-beancount nerdtree nerdtree-git-plugin ale vim-renamer tabnine-vim vim-tickscript vim-airline vim-airline-themes ctrlp-vim fugitive ];
      };
    };
  };
}
