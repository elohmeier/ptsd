{ pkgs, stdenv, python3Packages, writeText, systemd }:

let
  runGitAlarm = pkgs.writeDash "runGitAlarm" ''
    ${systemd}/bin/systemctl --user start git-alarm.service
  '';
in
python3Packages.buildPythonApplication {
  name = "git-alarm";
  src = ./.;

  # unfortunately there is no post-push hook, so we can't react to that easily
  postInstall = ''
    mkdir -p $out/share/hooks
    ln -s ${runGitAlarm} $out/share/hooks/post-commit
    ln -s ${runGitAlarm} $out/share/hooks/post-merge
  '';
}
