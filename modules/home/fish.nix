p@{ config, lib, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      enter_accept = false;
      invert = true;
      sync_address = "http://100.92.45.113:8888"; # htz2
    };
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      gaapf = "git add . && git commit --amend --no-edit && git push --force-with-lease";
      gapf = "git commit --amend --no-edit && git push --force-with-lease";
      gg = "gitu";
      grep = "grep --color";
      l = "eza -al";
      la = "eza -al";
      lg = "eza -al --git";
      ll = "eza -l";
      ls = "eza";
      nbconvert = "jupyter nbconvert --to script --stdout";
      ping6 = lib.mkIf pkgs.stdenv.isLinux "ping -6";
      slvpn-set-dns = "sudo busctl call org.freedesktop.resolve1 /org/freedesktop/resolve1 org.freedesktop.resolve1.Manager SetLinkDNS 'ia(iay)' (ip -j link show dev tun0 | jq '.[0].ifindex') 1 2 4 172 16 0 1 && resolvectl status tun0";
      telnet = "screen //telnet";
      tree = "eza --tree";
      vi = "nvim";
      vim = "nvim";
    };

    shellAbbrs = {
      "cd.." = "cd ..";
      "ga." = "git add .";
      br = "broot";
      etm = "et -c \"tmux -CC new -A -s main\"";
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gcf = "git commit --fixup";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gp = "git pull";
      gpp = "git push";
      gst = "git status";
      kc = "kubectl";
      nb = "nix build";
      nr = "nix run";
      nf = "nix flake";
      nfu = "nix flake update";
    };

    interactiveShellInit = ''
      set -U fish_greeting
      source ${../../scripts/iterm2-integration.fish}
      fzf_configure_bindings --directory=\ct

      function h
        set _h_dir (${pkgs.h}/bin/h --resolve "${config.home.homeDirectory}/repos" $argv)
        set _h_ret $status
        if test "$_h_dir" != "$PWD"
          cd "$_h_dir"
        end
        return $_h_ret
      end

      # TokyoNight Color Palette
      set -l foreground c0caf5
      set -l selection 283457
      set -l comment 565f89
      set -l red f7768e
      set -l orange ff9e64
      set -l yellow e0af68
      set -l green 9ece6a
      set -l purple 9d7cd8
      set -l cyan 7dcfff
      set -l pink bb9af7

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
      set -g fish_pager_color_selected_background --background=$selection
    '';
    # + lib.optionalString config.wayland.windowManager.sway.enable ''
    #   if status is-login
    #     if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
    #       # pass sway log output to journald
    #       exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --unsupported-gpu
    #     end
    #   end
    # '';
    plugins = with pkgs.fishPlugins; [
      #{ name = "done"; src = done.src; } # disabled, now solved via iterm2 integration
      { name = "fzf"; inherit (fzf-fish) src; }
      { name = "tide"; src = tide.src; }
    ];
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_poetry() {
          PYPROJECT_TOML="''${PYPROJECT_TOML:-pyproject.toml}"
          if [[ ! -f "$PYPROJECT_TOML" ]]; then
              log_status "No pyproject.toml found. Executing \`poetry init\` to create a \`$PYPROJECT_TOML\` first."
              poetry init
          fi

          if [[ -d ".venv" ]]; then
              VIRTUAL_ENV="$(pwd)/.venv"
          else
              VIRTUAL_ENV=$(poetry env info --path 2>/dev/null ; true)
          fi

          if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
              log_status "No virtual environment exists. Executing \`poetry install\` to create one."
              poetry install
              VIRTUAL_ENV=$(poetry env info --path)
          fi

          PATH_add "$VIRTUAL_ENV/bin"
          export POETRY_ACTIVE=1  # or VENV_ACTIVE=1
          export VIRTUAL_ENV
      }
    '';
  };

  home.packages = with pkgs; [ eza fd fzf-no-fish ];

  home.file.".config/fish/functions".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/fish else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/fish";

  # vivid generate molokai
  home.sessionVariables.LS_COLORS = "*~=0;38;2;122;112;112:bd=0;38;2;102;217;239;48;2;51;51;51:ca=0:cd=0;38;2;249;38;114;48;2;51;51;51:di=0;38;2;102;217;239:do=0;38;2;0;0;0;48;2;249;38;114:ex=1;38;2;249;38;114:fi=0:ln=0;38;2;249;38;114:mh=0:mi=0;38;2;0;0;0;48;2;255;74;68:no=0:or=0;38;2;0;0;0;48;2;255;74;68:ow=0:pi=0;38;2;0;0;0;48;2;102;217;239:rs=0:sg=0:so=0;38;2;0;0;0;48;2;249;38;114:st=0:su=0:tw=0:*.a=1;38;2;249;38;114:*.c=0;38;2;0;255;135:*.d=0;38;2;0;255;135:*.h=0;38;2;0;255;135:*.m=0;38;2;0;255;135:*.o=0;38;2;122;112;112:*.p=0;38;2;0;255;135:*.r=0;38;2;0;255;135:*.t=0;38;2;0;255;135:*.z=4;38;2;249;38;114:*.7z=4;38;2;249;38;114:*.as=0;38;2;0;255;135:*.bc=0;38;2;122;112;112:*.bz=4;38;2;249;38;114:*.cc=0;38;2;0;255;135:*.cp=0;38;2;0;255;135:*.cr=0;38;2;0;255;135:*.cs=0;38;2;0;255;135:*.di=0;38;2;0;255;135:*.el=0;38;2;0;255;135:*.ex=0;38;2;0;255;135:*.fs=0;38;2;0;255;135:*.go=0;38;2;0;255;135:*.gv=0;38;2;0;255;135:*.gz=4;38;2;249;38;114:*.hh=0;38;2;0;255;135:*.hi=0;38;2;122;112;112:*.hs=0;38;2;0;255;135:*.jl=0;38;2;0;255;135:*.js=0;38;2;0;255;135:*.ko=1;38;2;249;38;114:*.kt=0;38;2;0;255;135:*.la=0;38;2;122;112;112:*.ll=0;38;2;0;255;135:*.lo=0;38;2;122;112;112:*.md=0;38;2;226;209;57:*.ml=0;38;2;0;255;135:*.mn=0;38;2;0;255;135:*.nb=0;38;2;0;255;135:*.pl=0;38;2;0;255;135:*.pm=0;38;2;0;255;135:*.pp=0;38;2;0;255;135:*.ps=0;38;2;230;219;116:*.py=0;38;2;0;255;135:*.rb=0;38;2;0;255;135:*.rm=0;38;2;253;151;31:*.rs=0;38;2;0;255;135:*.sh=0;38;2;0;255;135:*.so=1;38;2;249;38;114:*.td=0;38;2;0;255;135:*.ts=0;38;2;0;255;135:*.ui=0;38;2;166;226;46:*.vb=0;38;2;0;255;135:*.wv=0;38;2;253;151;31:*.xz=4;38;2;249;38;114:*.aif=0;38;2;253;151;31:*.ape=0;38;2;253;151;31:*.apk=4;38;2;249;38;114:*.arj=4;38;2;249;38;114:*.asa=0;38;2;0;255;135:*.aux=0;38;2;122;112;112:*.avi=0;38;2;253;151;31:*.awk=0;38;2;0;255;135:*.bag=4;38;2;249;38;114:*.bak=0;38;2;122;112;112:*.bat=1;38;2;249;38;114:*.bbl=0;38;2;122;112;112:*.bcf=0;38;2;122;112;112:*.bib=0;38;2;166;226;46:*.bin=4;38;2;249;38;114:*.blg=0;38;2;122;112;112:*.bmp=0;38;2;253;151;31:*.bsh=0;38;2;0;255;135:*.bst=0;38;2;166;226;46:*.bz2=4;38;2;249;38;114:*.c++=0;38;2;0;255;135:*.cfg=0;38;2;166;226;46:*.cgi=0;38;2;0;255;135:*.clj=0;38;2;0;255;135:*.com=1;38;2;249;38;114:*.cpp=0;38;2;0;255;135:*.css=0;38;2;0;255;135:*.csv=0;38;2;226;209;57:*.csx=0;38;2;0;255;135:*.cxx=0;38;2;0;255;135:*.deb=4;38;2;249;38;114:*.def=0;38;2;0;255;135:*.dll=1;38;2;249;38;114:*.dmg=4;38;2;249;38;114:*.doc=0;38;2;230;219;116:*.dot=0;38;2;0;255;135:*.dox=0;38;2;166;226;46:*.dpr=0;38;2;0;255;135:*.elc=0;38;2;0;255;135:*.elm=0;38;2;0;255;135:*.epp=0;38;2;0;255;135:*.eps=0;38;2;253;151;31:*.erl=0;38;2;0;255;135:*.exe=1;38;2;249;38;114:*.exs=0;38;2;0;255;135:*.fls=0;38;2;122;112;112:*.flv=0;38;2;253;151;31:*.fnt=0;38;2;253;151;31:*.fon=0;38;2;253;151;31:*.fsi=0;38;2;0;255;135:*.fsx=0;38;2;0;255;135:*.gif=0;38;2;253;151;31:*.git=0;38;2;122;112;112:*.gvy=0;38;2;0;255;135:*.h++=0;38;2;0;255;135:*.hpp=0;38;2;0;255;135:*.htc=0;38;2;0;255;135:*.htm=0;38;2;226;209;57:*.hxx=0;38;2;0;255;135:*.ico=0;38;2;253;151;31:*.ics=0;38;2;230;219;116:*.idx=0;38;2;122;112;112:*.ilg=0;38;2;122;112;112:*.img=4;38;2;249;38;114:*.inc=0;38;2;0;255;135:*.ind=0;38;2;122;112;112:*.ini=0;38;2;166;226;46:*.inl=0;38;2;0;255;135:*.ipp=0;38;2;0;255;135:*.iso=4;38;2;249;38;114:*.jar=4;38;2;249;38;114:*.jpg=0;38;2;253;151;31:*.kex=0;38;2;230;219;116:*.kts=0;38;2;0;255;135:*.log=0;38;2;122;112;112:*.ltx=0;38;2;0;255;135:*.lua=0;38;2;0;255;135:*.m3u=0;38;2;253;151;31:*.m4a=0;38;2;253;151;31:*.m4v=0;38;2;253;151;31:*.mid=0;38;2;253;151;31:*.mir=0;38;2;0;255;135:*.mkv=0;38;2;253;151;31:*.mli=0;38;2;0;255;135:*.mov=0;38;2;253;151;31:*.mp3=0;38;2;253;151;31:*.mp4=0;38;2;253;151;31:*.mpg=0;38;2;253;151;31:*.nix=0;38;2;166;226;46:*.odp=0;38;2;230;219;116:*.ods=0;38;2;230;219;116:*.odt=0;38;2;230;219;116:*.ogg=0;38;2;253;151;31:*.org=0;38;2;226;209;57:*.otf=0;38;2;253;151;31:*.out=0;38;2;122;112;112:*.pas=0;38;2;0;255;135:*.pbm=0;38;2;253;151;31:*.pdf=0;38;2;230;219;116:*.pgm=0;38;2;253;151;31:*.php=0;38;2;0;255;135:*.pid=0;38;2;122;112;112:*.pkg=4;38;2;249;38;114:*.png=0;38;2;253;151;31:*.pod=0;38;2;0;255;135:*.ppm=0;38;2;253;151;31:*.pps=0;38;2;230;219;116:*.ppt=0;38;2;230;219;116:*.pro=0;38;2;166;226;46:*.ps1=0;38;2;0;255;135:*.psd=0;38;2;253;151;31:*.pyc=0;38;2;122;112;112:*.pyd=0;38;2;122;112;112:*.pyo=0;38;2;122;112;112:*.rar=4;38;2;249;38;114:*.rpm=4;38;2;249;38;114:*.rst=0;38;2;226;209;57:*.rtf=0;38;2;230;219;116:*.sbt=0;38;2;0;255;135:*.sql=0;38;2;0;255;135:*.sty=0;38;2;122;112;112:*.svg=0;38;2;253;151;31:*.swf=0;38;2;253;151;31:*.swp=0;38;2;122;112;112:*.sxi=0;38;2;230;219;116:*.sxw=0;38;2;230;219;116:*.tar=4;38;2;249;38;114:*.tbz=4;38;2;249;38;114:*.tcl=0;38;2;0;255;135:*.tex=0;38;2;0;255;135:*.tgz=4;38;2;249;38;114:*.tif=0;38;2;253;151;31:*.tml=0;38;2;166;226;46:*.tmp=0;38;2;122;112;112:*.toc=0;38;2;122;112;112:*.tsx=0;38;2;0;255;135:*.ttf=0;38;2;253;151;31:*.txt=0;38;2;226;209;57:*.vcd=4;38;2;249;38;114:*.vim=0;38;2;0;255;135:*.vob=0;38;2;253;151;31:*.wav=0;38;2;253;151;31:*.wma=0;38;2;253;151;31:*.wmv=0;38;2;253;151;31:*.xcf=0;38;2;253;151;31:*.xlr=0;38;2;230;219;116:*.xls=0;38;2;230;219;116:*.xml=0;38;2;226;209;57:*.xmp=0;38;2;166;226;46:*.yml=0;38;2;166;226;46:*.zip=4;38;2;249;38;114:*.zsh=0;38;2;0;255;135:*.zst=4;38;2;249;38;114:*TODO=1:*hgrc=0;38;2;166;226;46:*.bash=0;38;2;0;255;135:*.conf=0;38;2;166;226;46:*.dart=0;38;2;0;255;135:*.diff=0;38;2;0;255;135:*.docx=0;38;2;230;219;116:*.epub=0;38;2;230;219;116:*.fish=0;38;2;0;255;135:*.flac=0;38;2;253;151;31:*.h264=0;38;2;253;151;31:*.hgrc=0;38;2;166;226;46:*.html=0;38;2;226;209;57:*.java=0;38;2;0;255;135:*.jpeg=0;38;2;253;151;31:*.json=0;38;2;166;226;46:*.less=0;38;2;0;255;135:*.lisp=0;38;2;0;255;135:*.lock=0;38;2;122;112;112:*.make=0;38;2;166;226;46:*.mpeg=0;38;2;253;151;31:*.opus=0;38;2;253;151;31:*.orig=0;38;2;122;112;112:*.pptx=0;38;2;230;219;116:*.psd1=0;38;2;0;255;135:*.psm1=0;38;2;0;255;135:*.purs=0;38;2;0;255;135:*.rlib=0;38;2;122;112;112:*.sass=0;38;2;0;255;135:*.scss=0;38;2;0;255;135:*.tbz2=4;38;2;249;38;114:*.tiff=0;38;2;253;151;31:*.toml=0;38;2;166;226;46:*.webm=0;38;2;253;151;31:*.webp=0;38;2;253;151;31:*.woff=0;38;2;253;151;31:*.xbps=4;38;2;249;38;114:*.xlsx=0;38;2;230;219;116:*.yaml=0;38;2;166;226;46:*.cabal=0;38;2;0;255;135:*.cache=0;38;2;122;112;112:*.class=0;38;2;122;112;112:*.cmake=0;38;2;166;226;46:*.dyn_o=0;38;2;122;112;112:*.ipynb=0;38;2;0;255;135:*.mdown=0;38;2;226;209;57:*.patch=0;38;2;0;255;135:*.scala=0;38;2;0;255;135:*.shtml=0;38;2;226;209;57:*.swift=0;38;2;0;255;135:*.toast=4;38;2;249;38;114:*.xhtml=0;38;2;226;209;57:*README=0;38;2;0;0;0;48;2;230;219;116:*passwd=0;38;2;166;226;46:*shadow=0;38;2;166;226;46:*.config=0;38;2;166;226;46:*.dyn_hi=0;38;2;122;112;112:*.flake8=0;38;2;166;226;46:*.gradle=0;38;2;0;255;135:*.groovy=0;38;2;0;255;135:*.ignore=0;38;2;166;226;46:*.matlab=0;38;2;0;255;135:*COPYING=0;38;2;182;182;182:*INSTALL=0;38;2;0;0;0;48;2;230;219;116:*LICENSE=0;38;2;182;182;182:*TODO.md=1:*.desktop=0;38;2;166;226;46:*.gemspec=0;38;2;166;226;46:*Doxyfile=0;38;2;166;226;46:*Makefile=0;38;2;166;226;46:*TODO.txt=1:*setup.py=0;38;2;166;226;46:*.DS_Store=0;38;2;122;112;112:*.cmake.in=0;38;2;166;226;46:*.fdignore=0;38;2;166;226;46:*.kdevelop=0;38;2;166;226;46:*.markdown=0;38;2;226;209;57:*.rgignore=0;38;2;166;226;46:*COPYRIGHT=0;38;2;182;182;182:*README.md=0;38;2;0;0;0;48;2;230;219;116:*configure=0;38;2;166;226;46:*.gitconfig=0;38;2;166;226;46:*.gitignore=0;38;2;166;226;46:*.localized=0;38;2;122;112;112:*.scons_opt=0;38;2;122;112;112:*CODEOWNERS=0;38;2;166;226;46:*Dockerfile=0;38;2;166;226;46:*INSTALL.md=0;38;2;0;0;0;48;2;230;219;116:*README.txt=0;38;2;0;0;0;48;2;230;219;116:*SConscript=0;38;2;166;226;46:*SConstruct=0;38;2;166;226;46:*.gitmodules=0;38;2;166;226;46:*.synctex.gz=0;38;2;122;112;112:*.travis.yml=0;38;2;230;219;116:*INSTALL.txt=0;38;2;0;0;0;48;2;230;219;116:*LICENSE-MIT=0;38;2;182;182;182:*MANIFEST.in=0;38;2;166;226;46:*Makefile.am=0;38;2;166;226;46:*Makefile.in=0;38;2;122;112;112:*.applescript=0;38;2;0;255;135:*.fdb_latexmk=0;38;2;122;112;112:*CONTRIBUTORS=0;38;2;0;0;0;48;2;230;219;116:*appveyor.yml=0;38;2;230;219;116:*configure.ac=0;38;2;166;226;46:*.clang-format=0;38;2;166;226;46:*.gitattributes=0;38;2;166;226;46:*.gitlab-ci.yml=0;38;2;230;219;116:*CMakeCache.txt=0;38;2;122;112;112:*CMakeLists.txt=0;38;2;166;226;46:*LICENSE-APACHE=0;38;2;182;182;182:*CONTRIBUTORS.md=0;38;2;0;0;0;48;2;230;219;116:*.sconsign.dblite=0;38;2;122;112;112:*CONTRIBUTORS.txt=0;38;2;0;0;0;48;2;230;219;116:*requirements.txt=0;38;2;166;226;46:*package-lock.json=0;38;2;122;112;112:*.CFUserTextEncoding=0;38;2;122;112;112";
}
