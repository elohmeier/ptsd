{
  aliases = {
    gapf = "git commit --amend --no-edit && git push --force";
    gaapf = "git add . && git commit --amend --no-edit && git push --force";
    grep = "grep --color";
    l = "ls -alh --color";
    la = "ls -alh --color";
    ll = "ls -l --color";
    ls = "ls --color";
    ping6 = "ping -6";
    telnet = "screen //telnet";
    nr = "sudo nixos-rebuild --flake /home/enno/repos/ptsd/.#$hostname";
  };

  abbreviations = {
    "br" = "broot";
    "cd.." = "cd ..";
    ga = "git add";
    "ga." = "git add .";
    gc = "git commit";
    gco = "git checkout";
    gd = "git diff";
    gf = "git fetch";
    gl = "git log";
    gs = "git status";
    gp = "git pull";
    gpp = "git push";
    vi = "vim";
  };
}
