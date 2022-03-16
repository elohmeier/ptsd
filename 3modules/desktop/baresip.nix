{ nixosConfig, config, lib, pkgs, ... }:

with lib;

let
  cfg = nixosConfig.ptsd.desktop;
in
{
  home.file = optionalAttrs cfg.baresip.enable {
    ".baresip/accounts".source = config.lib.file.mkOutOfStoreSymlink nixosConfig.ptsd.secrets.files.baresip-accounts.path;

    # For Fritz!Box supported Audio Codecs, checkout:
    # https://avm.de/service/fritzbox/fritzbox-7590/wissensdatenbank/publication/show/1008_Unterstutzte-Sprach-Codecs-bei-Internettelefonie
    ".baresip/config".text = ''
        poll_method epoll
        call_local_timeout 120
        call_max_calls 4
        module_path ${pkgs.baresip}/lib/baresip/modules
        module stdio.so  # UI

        module g711.so  # Audio codec

        module portaudio.so  # Audio driver
        audio_player portaudio
        audio_source portaudio
        audio_alert portaudio

        ${optionalString (cfg.baresip.sipListen != "") ''
        sip_listen ${cfg.baresip.sipListen}
      ''}

        ${optionalString (cfg.baresip.netInterface != "") ''
        net_interface ${cfg.baresip.netInterface}
      ''}

        module mixminus.so # conferencing

        module sndfile.so # call recording
        snd_path ${cfg.baresip.recordingPath}

        module stun.so
        module turn.so
        module ice.so
        module uuid.so
        module_app account.so
        module_app contact.so
        module_app menu.so
    '';
  };

  home.packages = optional cfg.baresip.enable pkgs.baresip;
}
