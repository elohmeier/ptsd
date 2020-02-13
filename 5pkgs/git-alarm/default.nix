{ pkgs, stdenv, python3Packages, writeText, systemd }:

let
  runGitAlarm = pkgs.writeDash "runGitAlarm" ''
    ${systemd}/bin/systemctl --user start git-alarm.service
  '';
in
python3Packages.buildPythonApplication {
  name = "git-alarm";
  src = ./.;
  postInstall = ''
    mkdir -p $out/share/hooks
    ln -s ${runGitAlarm} $out/share/hooks/post-commit
    ln -s ${runGitAlarm} $out/share/hooks/post-merge
    ln -s ${runGitAlarm} $out/share/hooks/post-update
  '';
}
