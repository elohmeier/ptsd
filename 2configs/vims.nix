{ lib, python3, vimUtils, fetchFromGitHub, vim_configurable, vimPlugins }:

let
  # TODO: setup black integration in vim
  py3 = python3.withPackages (
    pythonPackages: with pythonPackages; [
      black
    ]
  );
  vim-beancount = vimUtils.buildVimPluginFrom2Nix {
    name = "vim-beancount";
    pname = "vim-beancount";
    version = "2017-10-28";
    src = fetchFromGitHub {
      owner = "nathangrigg";
      repo = "vim-beancount";
      rev = "8054352c43168ece62094dfc8ec510e347e19e3c";
      sha256 = "0fd4fbdmhapdhjr3f9bhd4lqxzpdwwvpf64vyqwahkqn8hrrbc4m";
    };
  };
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
  tabnine-vim = vimUtils.buildVimPluginFrom2Nix {
    pname = "tabnine-vim";
    version = "2.11";
    src = fetchFromGitHub {
      owner = "zxqfl";
      repo = "tabnine-vim";
      rev = "f7be9252afe46fa480593bebdd154278b39baa06";
      sha256 = "1jzpsrrdv53gji3sns1xaj3pq8f6bwssw5wwh9sccr9qdz6i6fwa";
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

  # mitigate https://github.com/NixOS/nixpkgs/issues/47452
  vim = vim_configurable.overrideAttrs (
    oa:
      {
        configureFlags = lib.filter
          (f: ! lib.hasPrefix "--enable-gui" f) oa.configureFlags;

      }
  );
in
{
  small = (
    vim.override {
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
    vim.override {
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
        :set mouse=a
        let g:NERDTreeMouseMode=3
      '';

      packages.myVimPackage = with vimPlugins; {
        start = [ vim-nix vim-beancount nerdtree nerdtree-git-plugin ale vim-renamer tabnine-vim ];
      };
    };
  };
}
