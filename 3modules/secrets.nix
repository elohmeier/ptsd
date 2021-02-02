{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.secrets;

  # Escape as required by: https://www.freedesktop.org/software/systemd/man/systemd.unit.html
  escapeUnitName = name:
    lib.concatMapStrings (s: if lib.isList s then "-" else s)
      (builtins.split "[^a-zA-Z0-9_.\\-]+" name);

  generateUnit = name: file:
    nameValuePair "secret-${escapeUnitName name}" {
      description = "secret: ${name}";
      wantedBy = [ "multi-user.target" ];
      before = file.dependants;
      requiredBy = file.dependants;
      path = with pkgs; [ coreutils ];

      script = ''
        echo "copying ${file.source-path} to ${file.path}"
        install \
          -D \
          --compare \
          --verbose \
          --mode=${escapeShellArg file.mode} \
          --owner=${escapeShellArg file.owner} \
          --group=${escapeShellArg file.group-name} \
          ${escapeShellArg file.source-path} \
          ${escapeShellArg file.path}
      '';

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
      };
    };
in
{
  options = {
    ptsd.secrets = {
      files = mkOption {
        type = types.attrsOf (
          types.submodule (
            { config, ... }: {
              options = {
                name = mkOption {
                  type = types.str;
                  default = config._module.args.name;
                };
                path = mkOption {
                  type = types.str;
                  default = "/run/keys/${config.name}";
                };
                mode = mkOption {
                  type = types.str;
                  default = "0400";
                };
                owner = mkOption {
                  type = types.str;
                  default = "root";
                };
                group-name = mkOption {
                  type = types.str;
                  default = "root";
                };
                source-path = mkOption {
                  type = types.str;
                  default = toString <secrets> + "/${config.name}";
                };
                dependants = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };
              };
            }
          )
        );
        default = { };
      };
    };
  };

  config = mkIf (cfg.files != { }) {
    systemd.services = mapAttrs' generateUnit cfg.files;
  };
}
