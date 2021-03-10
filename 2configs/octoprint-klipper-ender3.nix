{ config, lib, pkgs, ... }:

{
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ config.services.octoprint.port ];

  services.octoprint = {
    enable = true;
    port = config.ptsd.nwtraefik.ports.octoprint;
    plugins = plugins: with plugins; [
      printtimegenius
      (callPackage <ptsd/5pkgs/octoprint-plugins/telegram.nix> { })
      curaenginelegacy
      gcodeeditor
      octoklipper
      (callPackage <ptsd/5pkgs/octoprint-plugins/bedlevelvisualizer.nix> { })
      (callPackage <ptsd/5pkgs/octoprint-plugins/m73progress.nix> { })
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
      serial.disconnectOnErrors = false;
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
        # position_min="-2"; # only for calibration
        position_min = "-0.1"; # fix out of range error...
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
        serial = "/dev/ttyUSB0";
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
        x_offset = "-38";
        y_offset = "1";
        z_offset = "1.145"; # calibrated 05.02.2021
        speed = "5.0";
      };

      safe_z_home = {
        home_xy_position = "120,120";
        z_hop = "10.0";
      };

      bed_mesh = {
        speed = "200";
        horizontal_move_z = "5";
        mesh_min = "10,30";
        mesh_max = "180, 230";
        probe_count = "3,3";
      };

      "gcode_macro G29" = {
        gcode = "\n BED_MESH_CALIBRATE";
      };
    };
  };
}
