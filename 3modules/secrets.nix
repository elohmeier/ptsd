{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.secrets;
  secret-file = types.submodule (
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
      };
    }
  );
in
{
  options = {
    ptsd.secrets = {
      files = mkOption {
        type = with types; attrsOf secret-file;
        default = {};
      };
    };
  };

  config = mkIf (cfg.files != {}) {
    system.activationScripts.setup-secrets = let
      files = unique (
        map (flip removeAttrs [ "_module" ])
          (attrValues cfg.files)
      );
      script = ''
        echo setting up secrets...
        ${concatMapStringsSep "\n" (
        file: ''
          ${pkgs.coreutils}/bin/install \
            -D \
            --compare \
            --verbose \
            --mode=${escapeShellArg file.mode} \
            --owner=${escapeShellArg file.owner} \
            --group=${escapeShellArg file.group-name} \
            ${escapeShellArg file.source-path} \
            ${escapeShellArg file.path} \
          || echo "failed to copy ${file.source-path} to ${file.path}"
        ''
      ) files}
      '';
    in
      stringAfter [ "specialfs" "users" "groups" ] "source ${pkgs.writeText "setup-secrets.sh" script}";
  };
}
