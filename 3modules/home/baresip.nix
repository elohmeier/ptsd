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
  };

  config = mkIf cfg.enable {

    home = {

      packages = [ pkgs.baresip ];

      file.".baresip/accounts".text = ''
        <sip:${cfg.username}@${cfg.registrar}>;auth_pass=${cfg.password}
      '';

      # For Fritz!Box supported Audio Codecs, checkout:
      # https://avm.de/service/fritzbox/fritzbox-7590/wissensdatenbank/publication/show/1008_Unterstutzte-Sprach-Codecs-bei-Internettelefonie
      # TODO: fetch audio devices from cfg
      file.".baresip/config".text = ''
        poll_method epoll
        call_local_timeout 120
        call_max_calls 4
        module_path ${pkgs.baresip}/lib/baresip/modules
        module stdio.so  # UI

        module g711.so # Audio codec

        module pulse.so  # Audio driver
        audio_player pulse,bluez_sink.04_52_C7_0C_C1_61.headset_head_unit
        audio_source pulse,bluez_source.04_52_C7_0C_C1_61.headset_head_unit
        audio_alert pulse,alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo

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

    # TODO: Implement address book generation
    #    systemd.user.services.baresip-update-contacts = {
    #      Unit = {
    #        Description = "Update Baresip contact list";
    #        Wants = [ "network-online.target" ];
    #        Requires = [ "gpg-agent.service" ];
    #      };
    #
    #      Service = {
    #        Type = "oneshot";
    #        ExecStart = "...";
    #        TimeoutStartSec = "5min"; # kill if still alive after 5 minutes
    #      };
    #    };
    #
    #    systemd.user.timers.baresip-update-contacts = {
    #      Unit = {
    #        Description = "Update Baresip contact list Timer";
    #        PartOf = [ "graphical-session.target" ];
    #        WantedBy = [ "graphical-session.target" ];
    #      };
    #
    #      Timer = {
    #        OnBootSec = "2min";
    #        OnUnitInactiveSec = "2min";
    #      };
    #    };

  };
}
