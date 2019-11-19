{ citrix_workspace, extraCerts ? [], timeZone ? "Europe/Berlin", symlinkJoin, writeText }:

let

  mkCertCopy = certPath:
    "cp \"${certPath}\" $out/opt/citrix-icaclient/keystore/cacerts/";

in

if builtins.length extraCerts == 0 then citrix_workspace else symlinkJoin {
  name = "citrix-with-ptsd-config-and-extra-certs-${citrix_workspace.version}";
  paths = [ citrix_workspace ];

  postBuild = ''
    ${builtins.concatStringsSep "\n" (map mkCertCopy extraCerts)}

    # reconfigure timezone
    sed -i -E "s,UTC,${timeZone}," $out/opt/citrix-icaclient/timezone

    # enable middle mouse button
    sed -i -E "s,MouseSendsControlV=\*,MouseSendsControlV=False," $out/opt/citrix-icaclient/config/All_Regions.ini

    # enable Alt+Tab
    sed -i -E "s,TransparentKeyPassthrough=,TransparentKeyPassthrough=Remote," $out/opt/citrix-icaclient/config/All_Regions.ini

    # disable Audio Output
    sed -i -E "s,ClientAudio=\*,ClientAudio=Off," $out/opt/citrix-icaclient/config/All_Regions.ini

    # disable Audio Input
    sed -i -E "s,EnableAudioInput=\*,EnableAudioInput=False," $out/opt/citrix-icaclient/config/All_Regions.ini

    sed -i -E "s,-icaroot (.+citrix-icaclient),-icaroot $out/opt/citrix-icaclient," $out/bin/wfica
  '';
}
