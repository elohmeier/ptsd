{ citrix_workspace, extraCerts ? [ ], timeZone ? "Europe/Berlin" }:

(citrix_workspace.overrideAttrs (
  _oldAttrs: {

    # Tips from
    # https://discussions.citrix.com/topic/260087-middle-mouse-button-on-citrix-application-mousewheel/
    # https://askubuntu.com/questions/195934/alttab-doesnt-work-when-citrix-is-in-full-screen/844109#844109

    postInstall = ''    
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
)).override { inherit extraCerts; }
