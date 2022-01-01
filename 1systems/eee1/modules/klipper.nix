{ config
, lib
, pkgs
, ...
}:

with lib;

let
  indentGcode = s: "\n${concatMapStringsSep "\n" (x: "  ${x}") (splitString "\n" s)}";
in
{
  # https://simons.tech.blog/2020/01/19/creality-ender-3-v-1-1-3-tmc2208-uart-mod/

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
      virtual_sdcard.path = "/var/lib/klipper/gcode_files";

      stepper_x = {
        step_pin = "PD7";
        dir_pin = "!PC5";
        enable_pin = "!PD6";
        microsteps = "16";
        rotation_distance = "40";
        endstop_pin = "^PC2";
        position_endstop = "-23";
        position_min = "-23";
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
        position_endstop = "-17";
        position_min = "-17";
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

      skew_correction = { };

      # prevent M205 warnings
      "gcode_macro M205".gcode = "\n  G4";

      # use this start code in prusa slicer:
      # START_PRINT BED_TEMP=[first_layer_bed_temperature] EXTRUDER_TEMP=[first_layer_temperature]
      # skew measured using 50mm model from https://www.thingiverse.com/thing:2972743
      "gcode_macro START_PRINT".gcode = indentGcode ''
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
        G1 Z50 F240
        G1 X2 Y10 F3000
        # Wait for bed to reach temperature
        M190 S{BED_TEMP}
        # Set and wait for nozzle to reach temperature
        M109 S{EXTRUDER_TEMP}
        G1 Z0.28 F240
        G92 E0
        G1 Y140 E10 F1500 ; intro line
        G1 X2.3 F5000
        G92 E0
        G1 Y10 E10 F1200 ; intro line
        G92 E0
      '';

      "gcode_macro END_PRINT".gcode = indentGcode ''
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
      deviceService = "sys-devices-pci0000:00-0000:00:1d.0-usb2-2\\x2d2-2\\x2d2:1.0-ttyUSB0-tty-ttyUSB0.device";
    in
    {
      bindsTo = [ deviceService ];
      wantedBy = [ deviceService ];
      serviceConfig = {
        Nice = -10;
        StateDirectory = "klipper";
      };
    };
}
