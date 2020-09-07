{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.baresip;
in
{
  options.ptsd.baresip = {
    enable = mkEnableOption "baresip: userspace baresip setup";
    username = mkOption { type = types.str; };
    password = mkOption { type = types.str; };
    registrar = mkOption { type = types.str; };
    audioPlayer = mkOption { type = types.str; default = ""; };
    audioSource = mkOption { type = types.str; default = ""; };
    audioAlert = mkOption { type = types.str; default = ""; };
    sipListen = mkOption { type = types.str; default = ""; example = "10.0.0.2:5060"; };
    netInterface = mkOption { type = types.str; default = ""; example = "nwvpn"; };
  };

  config = mkIf cfg.enable {

    home = {

      packages = [ pkgs.baresip ];

      file.".baresip/accounts".text = ''
        <sip:${cfg.username}@${cfg.registrar}>;auth_pass=${cfg.password}
      '';

      # For Fritz!Box supported Audio Codecs, checkout:
      # https://avm.de/service/fritzbox/fritzbox-7590/wissensdatenbank/publication/show/1008_Unterstutzte-Sprach-Codecs-bei-Internettelefonie
      file.".baresip/config".text = ''
          poll_method epoll
          call_local_timeout 120
          call_max_calls 4
          module_path ${pkgs.baresip}/lib/baresip/modules
          module stdio.so  # UI

          module g711.so # Audio codec

          module pulse.so  # Audio driver

          ${optionalString (cfg.audioPlayer != "") ''
          audio_player pulse,${cfg.audioPlayer}
        ''}
          ${optionalString (cfg.audioSource != "") ''
          audio_source pulse,${cfg.audioSource}
        ''}
          ${optionalString (cfg.audioAlert != "") ''
          # Ring
          audio_alert pulse,${cfg.audioAlert}
        ''}

          ${optionalString (cfg.sipListen != "") ''
          sip_listen ${cfg.sipListen}
        ''}

          ${optionalString (cfg.netInterface != "") ''
          net_interface ${cfg.netInterface}
        ''}

          module stun.so
          module turn.so
          module ice.so
          module_tmp uuid.so
          module_tmp account.so
          module_app auloop.so
          module_app contact.so
          module_app menu.so
      '';

    };
  };
}
