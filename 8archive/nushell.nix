
                  nushell = mkIf cfg.nushell.enable {
                    enable = true;

                    settings = {
                      prompt = "__zoxide_hook;__zoxide_prompt";
                      startup = (mapAttrsToList (alias: cmd: "alias ${alias} = ${cmd}") shellAliases.nuAliases) ++ [
                        "zoxide init nushell --hook prompt | save ~/.zoxide.nu"
                        "source ~/.zoxide.nu"
                      ];
                      env = {
                        PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
                        SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
                      };
                    };
                  };
