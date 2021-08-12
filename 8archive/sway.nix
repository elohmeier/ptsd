
            programs.nushell = {
              settings.startup =
                let
                  script = pkgs.writeShellScript "sway-init" ''
                    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
                      cd $HOME
                      # pass sway log output to journald
                      exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --my-next-gpu-wont-be-nvidia
                    fi
                  '';
                in
                [ script ];
            };
            programs.zsh = {
              loginExtra = ''
                # If running from tty1 start sway
                if [ "$(tty)" = "/dev/tty1" ]; then
                  # pass sway log output to journald
                  exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --my-next-gpu-wont-be-nvidia
                fi
              '';
            };
