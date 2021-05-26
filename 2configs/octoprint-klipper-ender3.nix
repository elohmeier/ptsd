{ config, lib, pkgs, ... }:

{
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ config.services.octoprint.port ];

  services.octoprint = {
    enable = true;
    port = config.ptsd.nwtraefik.ports.octoprint;
    plugins = plugins: with plugins; [
      printtimegenius
      (callPackage ../5pkgs/octoprint-plugins/telegram.nix { })
      curaenginelegacy
      gcodeeditor
      octoklipper
      (callPackage ../5pkgs/octoprint-plugins/bedlevelvisualizer.nix { })
      (callPackage ../5pkgs/octoprint-plugins/m73progress.nix { })
    ];
    extraConfig = {
      plugins = {
        _disabled = [
          "announcements"
          "tracking"
          "backup"
          "discovery"
          "errortracking"
          "firmware_check"
          "softwareupdate"
          "virtual_printer"
        ];
        bedlevelvisualizer.command = ''
          BED_MESH_CALIBRATE
          @BEDLEVELVISUALIZER
          BED_MESH_OUTPUT
        '';
        klipper = {
          configuration.configpath = "/etc/klipper.cfg";
          connection.port = "/run/klipper/tty";
        };
      };
      serial = {
        # recommended for klipper plugin
        disconnectOnErrors = false;

        # prevent octoprint timeouts
        longRunningCommands = [ "G4" "G28" "M400" "M226" "M600" "START_PRINT" ];
      };
      webcam = {
        stream = "http://eee1.nw/mjpg/?action=stream";
        snapshot = "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.mjpg-streamer}/?action=snapshot";
      };
    };
  };

  services.klipper = {
    enable = true;
    octoprintIntegration = true;
    settings = {

      stepper_x = {
        step_pin = "PD7";
        dir_pin = "!PC5";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^PC2";
        position_endstop = "0";
        position_max = "235";
        homing_speed = "50";
      };

      stepper_y = {
        step_pin = "PC6";
        dir_pin = "!PC7";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^PC3";
        position_endstop = "0";
        position_max = "235";
        homing_speed = "50";
      };

      stepper_z = {
        step_pin = "PB3";
        dir_pin = "PB2";
        enable_pin = "!PA5";
        microsteps = "16";
        rotation_distance = "8";
        endstop_pin = "probe:z_virtual_endstop";
        position_max = "250";
        position_min = "-2"; # fix out of range error...
      };

      extruder = {
        max_extrude_only_distance = "100.0";
        step_pin = "PB1";
        dir_pin = "PB0";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "9.524 # 336 steps/mm as specified in matrix extruder doc";
        nozzle_diameter = "0.400";
        filament_diameter = "1.750";
        heater_pin = "PD5";
        sensor_type = "EPCOS 100K B57560G104F";
        sensor_pin = "PA7";
        control = "pid";
        pid_Kp = "21.527";
        pid_Ki = "1.063";
        pid_Kd = "108.982";
        min_temp = "0";
        max_temp = "250";
      };

      heater_bed = {
        heater_pin = "PD4";
        sensor_type = "EPCOS 100K B57560G104F";
        sensor_pin = "PA6";
        control = "pid";
        pid_Kp = "54.027";
        pid_Ki = "0.770";
        pid_Kd = "948.182";
        min_temp = "0";
        max_temp = "130";
      };

      fan = {
        pin = "PB4";
      };

      mcu = {
        serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
      };

      printer = {
        kinematics = "cartesian";
        max_velocity = "300";
        max_accel = "3000";
        max_z_velocity = "5";
        max_z_accel = "100";
      };

      display = {
        lcd_type = "st7920";
        cs_pin = "PA3";
        sclk_pin = "PA1";
        sid_pin = "PC1";
        encoder_pins = "^PD2, ^PD3";
        click_pin = "^!PC0";
      };

      bltouch = {
        sensor_pin = "^PC4";
        control_pin = "PA4";
        x_offset = "67"; # make sure to update bed_mesh
        y_offset = "0";
        z_offset = "1.4"; # calibrated 04.05.2021
        speed = "5.0";
      };

      safe_z_home = {
        home_xy_position = "120,120";
        z_hop = "10.0";
      };

      bed_mesh = {
        speed = "200";
        horizontal_move_z = "5";
        #mesh_min = "10,30";
        mesh_min = "77,30"; # added bltouch offsets
        #mesh_max = "180, 230";
        mesh_max = "217,230"; # added bltouch offsets
        probe_count = "3,3";
      };

      # prevent M205 warnings
      "gcode_macro M205".gcode = "\n  G4";

      # use this start code in prusa slicer:
      # START_PRINT BED_TEMP=[first_layer_bed_temperature] EXTRUDER_TEMP=[first_layer_temperature]
      "gcode_macro START_PRINT".gcode = ''
        ''\n''\t{% set BED_TEMP = params.BED_TEMP|default(60)|float %}
        ''\t{% set EXTRUDER_TEMP = params.EXTRUDER_TEMP|default(190)|float %}
        ''\t# Start bed heating
        ''\tM140 S{BED_TEMP}
        ''\t# Use absolute coordinates
        ''\tG90
        ''\t# Reset the G-Code Z offset (adjust Z offset if needed)
        ''\tSET_GCODE_OFFSET Z=0.0
        ''\t# Home the printer
        ''\tG28
        ''\tBED_MESH_CALIBRATE
        ''\tBED_MESH_OUTPUT
        ''\tG1 Z30 F240
        ''\tG1 X28 Y30 F3000
        ''\t# Wait for bed to reach temperature
        ''\tM190 S{BED_TEMP}
        ''\t# Set and wait for nozzle to reach temperature
        ''\tM109 S{EXTRUDER_TEMP}
        ''\tG1 Z0.28 F240
        ''\tG92 E0
        ''\tG1 Y160 E10 F1500 ; intro line
        ''\tG1 X28.3 F5000
        ''\tG92 E0
        ''\tG1 Y30 E10 F1200 ; intro line
        ''\tG92 E0
      '';

      "gcode_macro END_PRINT".gcode = ''
        ''\n''\t# Turn off bed, extruder, and fan
        ''\tM140 S0
        ''\tM104 S0
        ''\tM106 S0
        ''\t# Move nozzle away from print while retracting
        ''\tG91
        ''\tG1 X-2 Y-2 E-3 F300
        ''\t# Raise nozzle by 10mm
        ''\tG1 Z10 F3000
        ''\tG90
        ''\t# Disable steppers
        ''\tM84
      '';
    };
  };

  # start klipper on usb connect
  systemd.services.klipper =
    let deviceService = "sys-devices-pci0000:00-0000:00:1d.0-usb2-2\\x2d2-2\\x2d2:1.0-ttyUSB0-tty-ttyUSB0.device"; in
    {
      bindsTo = [ deviceService ];
      wantedBy = [ deviceService ];
    };
}
