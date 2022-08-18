{ config, lib, pkgs, ... }:

let
  indentGcode = s: "\n${lib.concatMapStringsSep "\n" (x: "  ${x}") (lib.splitString "\n" s)}";
  universe = import ./universe.nix;
in
{
  users = {
    users.klipper = { isSystemUser = true; group = "klipper"; };
    groups.klipper = { };
  };

  services.klipper = {
    enable = true;

    user = "klipper";
    group = "klipper";

    settings = {

      # moonraker config requirements
      pause_resume = { };
      display_status = { };
      virtual_sdcard.path = "/var/lib/klipper/";

      # hide octoprint menu item
      "menu __main __octoprint".type = "disabled";

      # https://simons.tech.blog/2020/01/19/creality-ender-3-v-1-1-3-tmc2208-uart-mod/
      "tmc2208 stepper_x" = {
        uart_pin = "PA0";
        run_current = "0.800";
      };
      "tmc2208 stepper_y" = {
        run_current = "0.800";
        uart_pin = "PB7";
      };
      "tmc2208 stepper_z" = {
        run_current = "0.650";
        uart_pin = "PB6";
      };
      "tmc2208 extruder" = {
        run_current = "0.800";
        uart_pin = "PB5";
      };

      stepper_x = {
        dir_pin = "!PC5";
        enable_pin = "!PD6";
        endstop_pin = "^PC2";
        homing_speed = "50";
        microsteps = "16";
        position_endstop = "-23";
        position_max = "235";
        position_min = "-23";
        rotation_distance = "40";
        step_pin = "PD7";
      };

      stepper_y = {
        dir_pin = "!PC7";
        enable_pin = "!PD6";
        endstop_pin = "^PC3";
        homing_speed = "50";
        microsteps = "16";
        position_endstop = "-17";
        position_max = "235";
        position_min = "-17";
        rotation_distance = "40";
        step_pin = "PC6";
      };

      stepper_z = {
        dir_pin = "PB2";
        enable_pin = "!PA5";
        endstop_pin = "probe:z_virtual_endstop";
        microsteps = "16";
        position_max = "250";
        position_min = "-2"; # fix out of range error...
        rotation_distance = "8";
        step_pin = "PB3";
      };

      extruder = {
        control = "pid";
        dir_pin = "PB0";
        enable_pin = "!PD6";
        filament_diameter = "1.750";
        heater_pin = "PD5";
        max_extrude_only_distance = "100.0";
        max_temp = "250";
        microsteps = "16";
        min_extrude_temp = "0";
        min_temp = "0";
        nozzle_diameter = "0.400";
        pid_Kd = "108.982";
        pid_Ki = "1.063";
        pid_Kp = "21.527";
        pressure_advance = "0.039"; # calibrated 2022-08-17 0.4mm nozzle, PETG 240°C
        rotation_distance = "9.524"; # 336 steps/mm as specified in matrix extruder doc"
        sensor_pin = "PA7";
        sensor_type = "EPCOS 100K B57560G104F";
        step_pin = "PB1";
      };

      heater_bed = {
        control = "pid";
        heater_pin = "PD4";
        max_temp = "130";
        min_temp = "0";
        pid_Kd = "948.182";
        pid_Ki = "0.770";
        pid_Kp = "54.027";
        sensor_pin = "PA6";
        sensor_type = "EPCOS 100K B57560G104F";
      };

      fan = {
        pin = "PB4";
      };

      mcu = {
        serial = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
      };

      printer = {
        kinematics = "cartesian";
        max_accel = "3000";
        max_velocity = "300";
        max_z_accel = "100";
        max_z_velocity = "5";
      };

      display = {
        click_pin = "^!PC0";
        cs_pin = "PA3";
        encoder_pins = "^PD2, ^PD3";
        lcd_type = "st7920";
        sclk_pin = "PA1";
        sid_pin = "PC1";
      };

      bltouch = {
        control_pin = "PA4";
        sensor_pin = "^PC4";
        speed = "5.0";
        x_offset = "67"; # make sure to update bed_mesh
        y_offset = "0";
        z_offset = "1.6";
      };

      safe_z_home = {
        home_xy_position = "120,120";
        z_hop = "5.0";
      };

      bed_mesh = {
        #mesh_max = "180, 230";
        #mesh_min = "10,30";
        horizontal_move_z = "5";
        mesh_max = "217,230"; # added bltouch offsets
        mesh_min = "77,30"; # added bltouch offsets
        probe_count = "3,3";
        speed = "200";
      };

      skew_correction = { };

      # use this start code in prusa slicer:
      # -------------------------------------------------------------------------------------------
      # M190 S0
      # M104 S0
      # _START_PRINT BED_TEMP=[first_layer_bed_temperature] EXTRUDER_TEMP=[first_layer_temperature]
      # -------------------------------------------------------------------------------------------
      # (M190/M104 prevent pruser slicer inserting heatup commands before the start code)
      #
      # skew measured using 50mm model from https://www.thingiverse.com/thing:2972743
      "gcode_macro _START_PRINT".gcode = indentGcode ''
        {% set BED_TEMP = params.BED_TEMP|default(60)|float %}
        {% set EXTRUDER_TEMP = params.EXTRUDER_TEMP|default(190)|float %}
        # Start bed heating
        M140 S{BED_TEMP}
        # Use absolute coordinates
        G90
        # Reset the G-Code Z offset (adjust Z offset if needed)
        SET_GCODE_OFFSET Z=0.0
        # Home the printer
        G28
        BED_MESH_CALIBRATE
        BED_MESH_OUTPUT
        SET_SKEW XY=704,698,496 XZ=705,702,495 YZ=698,699,497
        G1 Z10 F240
        # prevent filement dripping on the bed during heating up
        G1 X-8 Y10 F5000
        # Wait for bed to reach temperature
        M190 S{BED_TEMP}
        # Set and wait for nozzle to reach temperature
        M109 S{EXTRUDER_TEMP}
        G1 Z0.28 F240
        G1 X2 Y10 F5000
        G92 E0
        G1 Y140 E10 F1500 ; intro line
        G1 X2.3 F5000
        G92 E0
        G1 Y10 E10 F1200 ; intro line
        G92 E0
      '';

      "gcode_macro _END_PRINT".gcode = indentGcode ''
        # Turn off bed, extruder, and fan
        M140 S0
        M104 S0
        M106 S0
        # Move nozzle away from print while retracting
        G91
        G1 X-2 Y-2 E-3 F300
        # Raise nozzle by 10mm
        G1 Z10 F3000
        G90
        # Disable steppers
        M84
      '';


      # fluidd macros (see https://docs.fluidd.xyz/configuration/initial_setup#macros)
      "gcode_macro PAUSE" = {
        description = "Pause the actual running print";
        rename_existing = "PAUSE_BASE";
        variable_extrude = "1.0"; # change this if you need more or less extrusion
        gcode = indentGcode ''
          ##### read E from pause macro #####
          {% set E = printer["gcode_macro PAUSE"].extrude|float %}
          ##### set park positon for x and y #####
          # default is your max posion from your printer.cfg
          {% set x_park = printer.toolhead.axis_maximum.x|float - 5.0 %}
          {% set y_park = printer.toolhead.axis_maximum.y|float - 5.0 %}
          ##### calculate save lift position #####
          {% set max_z = printer.toolhead.axis_maximum.z|float %}
          {% set act_z = printer.toolhead.position.z|float %}
          {% if act_z < (max_z - 2.0) %}
              {% set z_safe = 2.0 %}
          {% else %}
              {% set z_safe = max_z - act_z %}
          {% endif %}
          ##### end of definitions #####
          PAUSE_BASE
          G91
          {% if printer.extruder.can_extrude|lower == 'true' %}
            G1 E-{E} F2100
          {% else %}
            {action_respond_info("Extruder not hot enough")}
          {% endif %}
          {% if "xyz" in printer.toolhead.homed_axes %}
            G1 Z{z_safe} F900
            G90
            G1 X{x_park} Y{y_park} F6000
          {% else %}
            {action_respond_info("Printer not homed")}
          {% endif %}
        '';
      };

      "gcode_macro RESUME" = {
        description = "Resume the actual running print";
        rename_existing = "RESUME_BASE";
        gcode = indentGcode ''
          ##### read E from pause macro #####
          {% set E = printer["gcode_macro PAUSE"].extrude|float %}
          #### get VELOCITY parameter if specified ####
          {% if 'VELOCITY' in params|upper %}
            {% set get_params = ('VELOCITY=' + params.VELOCITY)  %}
          {%else %}
            {% set get_params = "" %}
          {% endif %}
          ##### end of definitions #####
          {% if printer.extruder.can_extrude|lower == 'true' %}
            G91
            G1 E{E} F2100
          {% else %}
            {action_respond_info("Extruder not hot enough")}
          {% endif %}  
          RESUME_BASE {get_params}
        '';
      };

      "gcode_macro CANCEL_PRINT" = {
        description = "Cancel the actual running print";
        rename_existing = "CANCEL_PRINT_BASE";
        gcode = indentGcode ''
          TURN_OFF_HEATERS
          CANCEL_PRINT_BASE
        '';
      };
    };
  };

  # start klipper on usb connect
  systemd.services.klipper =
    let
      deviceService = "dev-ttyUSB0.device";
    in
    {
      bindsTo = [ deviceService ];
      wantedBy = [ deviceService ];
      serviceConfig = {
        Nice = -10;
        UMask = "0012"; # allow group access to klipper api socket
      };
    };

  # group-accessible state dir for moonraker upload
  systemd.tmpfiles.rules = [
    "d /var/lib/klipper 0775 klipper klipper - -"
  ];

  services.moonraker = {
    enable = true;
    settings = {
      server = {
        enable_debug_logging = false;
      };
      authorization = {
        trusted_clients = [ "100.0.0.0/8" "192.168.0.0/16" ];
        cors_domains = [ "http://${config.networking.hostName}.pug-coho.ts.net" "http://${config.networking.hostName}.fritz.box" ];
      };

      octoprint_compat = { }; # allow file upload from slicer
    };

    address = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ config.services.moonraker.port 80 ];

  systemd.services.moonraker = {
    serviceConfig.SupplementaryGroups = "klipper";
    restartTriggers = [ (toString config.environment.etc."moonraker.cfg".source) ]; # restart on config change
  };

  services.fluidd = {
    enable = true;
    #hostName = "${config.networking.hostName}.pug-coho.ts.net";
    hostName = "${config.networking.hostName}.fritz.box";
    nginx = {
      # allow large uploads from slicer
      extraConfig = ''
        client_max_body_size 20M;
      '';
    };
  };
}
