_:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      #"ws1-osx" = {
      #  hostname = "192.168.178.61";
      #  forwardAgent = true;
      #  extraOptions.RemoteForward = "/Users/enno/.gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra";
      #};

      "utm-nixos-2023-12" = {
        hostname = "192.168.74.8";
        user = "gordon";
      };

      "mb4-nixos" = {
        hostname = "192.168.66.2";
        extraOptions.SendEnv = "TERM_PROGRAM LC_TERMINAL";
      };

      #"awsbuilder" = {
      #  hostname = "35.157.132.66";
      #  user = "admin";
      #  identityFile = "/var/src/secrets/ssh.id_ed25519";
      #};
    };
  };
}
