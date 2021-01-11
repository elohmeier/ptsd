{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.pulseaudio;
in
{
  options.ptsd.pulseaudio = {
    virtualAudioMixin = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "pulseaudio-virtualAudioMixin";
          microphone = mkOption {
            type = types.str;
            example = "alsa_input.pci-0000_00_1b.0.analog-stereo";
          };
          speakers = mkOption {
            type = types.str;
            example = "alsa_output.pci-0000_00_1b.0.analog-stereo";
          };
          aecArgs = mkOption {
            type = types.str;
            default = "analog_gain_control=0 digital_gain_control=1 experimental_agc=1 noise_suppression=1 voice_detection=1 extended_filter=1";

            # e.g. for Logitech C920:
            example = "beamforming=1 mic_geometry=-0.04,0,0,0.04,0,0 noise_suppression=1 analog_gain_control=0 digital_gain_control=1 agc_start_volume=200";
          };
        };
      };
      default = { };
    };
  };

  config = mkIf cfg.virtualAudioMixin.enable {

    # Virtual audio mixin into mic audio config
    # from https://wiki.archlinux.org/index.php/PulseAudio/Examples#Mixing_additional_audio_into_the_microphone's_audio
    # Symbology: (Application), {Audio source}, [Audio sink], {m} = Monitor of audio sink
    #
    # {Microphone}
    #    ||                                             Input
    # {mic_ec} -------------> [vsink_fx_mic]{m} ------------> (Voice chat)
    #             Loopback               ^                         |
    #                            Loopback|                   Output|
    #                                    |                         |
    #              Output                |      Loopback           v
    # (Soundboard) ---------> [vsink_fx]{m} ----------------> [spk_ec]
    #                                                            ||
    #                                                         [Speakers]
    hardware.pulseaudio.extraConfig = ''
      load-module module-echo-cancel use_master_format=1 source_master=${cfg.virtualAudioMixin.microphone} source_name=mic_ec source_properties=device.description=mic_ec sink_master=${cfg.virtualAudioMixin.speakers} sink_name=spk_ec sink_properties=device.description=spk_ec aec_method=webrtc aec_args="${cfg.virtualAudioMixin.aecArgs}"
      load-module module-null-sink sink_name=vsink_fx     sink_properties=device.description=vsink_fx
      load-module module-null-sink sink_name=vsink_fx_mic sink_properties=device.description=vsink_fx_mic
      load-module module-loopback latency_msec=30 adjust_time=3 source=mic_ec           sink=vsink_fx_mic
      load-module module-loopback latency_msec=30 adjust_time=3 source=vsink_fx.monitor sink=vsink_fx_mic
      load-module module-loopback latency_msec=30 adjust_time=3 source=vsink_fx.monitor sink=spk_ec
      set-default-source vsink_fx_mic.monitor
      set-default-sink   spk_ec
    '';

    hardware.pulseaudio.package = (
      pkgs.pulseaudioFull.overrideAttrs (
        old: {
          patches = [
            # mitigate https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/issues/89
            ../2configs/patches/echo-cancel-make-webrtc-beamforming-parameter-parsing-locale-independent.patch
          ];
        }
      )
    );
  };
}
