{ config, lib, pkgs, ... }:

with lib;
{
  services.mysqlBackup = {
    enable = true;
    databases = [ "wordpress" ];
  };

  environment.systemPackages = with pkgs; [
    (
      writers.writeDashBin "fraam-update-static-web" ''
        ROOT="''${1?must provide static root}"

        # fetch website
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/karriere/
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/impressum/
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/pentests/

        # remove absolute links
        ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\/\/dev.fraam.de\//\//g' {} +
        ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\\\/\\\/dev.fraam.de\\\//\\\//g' {} +
        ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\/\/fraam.de\//\//g' {} +

        # fix missing slash in impressum link
        ${findutils}/bin/find "$ROOT" -type f -name "*.html" -exec ${gnused}/bin/sed -i 's/"\/impressum"/"\/impressum\/"/g' {} +

        # remove ?ver=... suffices from css/js files
        ${findutils}/bin/find "$ROOT" -type f -name "*?ver=*" | ${findutils}/bin/xargs -I % sh -c 'newname=$(echo % | ${gnused}/bin/sed "s/?ver=.*//"); ${coreutils}/bin/mv % $newname'
      ''
    )
  ];
}
