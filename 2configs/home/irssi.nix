let
  homeSecrets = import /run/keys/home-secrets.nix;
in
{
  programs.irssi = {
    enable = true;

    networks = {
      freenode = {
        nick = "nobbo";
        server = {
          address = "chat.freenode.net";
          port = 6697;
          autoConnect = true;
          ssl = {
            enable = true;
            verify = true;
          };
        };
        channels = {
          "nixos".autoJoin = true;
          "nixos-de".autoJoin = true;
          "krebs".autoJoin = true;
        };
        autoCommands = [
          "/^msg nickserv identify ${homeSecrets.freenode_pw}"
          "wait 250"
        ];
      };
      hackint = {
        nick = "nobbo";
        server = {
          address = "irc.hackint.org";
          port = 6697;
          ssl = {
            enable = true;
            verify = true;
          };
        };
        autoCommands = [
          "/^msg nickserv identify ${homeSecrets.hackint_pw}"
          "wait 250"
        ];
      };
    };

    extraConfig = ''
      settings = { core = { real_name = "nobbo"; user_name = "nobbo"; nick = "nobbo"; }; };
    '';
  };
}
