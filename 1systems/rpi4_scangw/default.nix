{ pkgs, ... }: {

  imports = [
    ../../2configs
    ../../2configs/fish.nix
    ../../2configs/rpi3b_4.nix

    ./home-assistant.nix
  ];

  users.users.root.openssh.authorizedKeys.keys =
    let sshPubKeys = import ../../2configs/users/ssh-pubkeys.nix; in sshPubKeys.authorizedKeys_enno;

  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.firewall.trustedInterfaces = [ "eth0" "wlan0" "end0" ];
  networking.hostName = "rpi4";
  ptsd.tailscale.enable = true;
  ptsd.tailscale.cert.enable = true;
  services.getty.autologinUser = "root";
  services.openssh.enable = true;
  system.stateVersion = "23.11";

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp --dport 445 -j DNAT --to-destination 100.92.45.113:445
    iptables -t nat -I POSTROUTING -d 100.92.45.113 -p tcp --dport 445 -j MASQUERADE
  '';

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  environment.systemPackages = with pkgs; [
    btop
    tcpdump
  ];
}
