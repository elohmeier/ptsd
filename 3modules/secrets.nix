{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.secrets;

  generateUnit = name: file:
    nameValuePair "secret-${name}" {
      description = "secret: ${name}";
      wantedBy = [ "multi-user.target" ];
      before = file.dependants;
      requiredBy = file.dependants;
      path = with pkgs; [ coreutils ];

      script = ''
        install \
          -D \
          --compare \
          --verbose \
          --mode=${escapeShellArg file.mode} \
          --owner=${escapeShellArg file.owner} \
          --group=${escapeShellArg file.group-name} \
          ${escapeShellArg file.source-path} \
          ${escapeShellArg file.path} \
          || echo "failed to copy ${file.source-path} to ${file.path}"
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
