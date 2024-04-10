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

      ctrl1 = {
        hostname = "2a01:4f8:c17:da68::1";
        user = "root";
      };

      ctrl2 = {
        hostname = "2a01:4f8:c17:a98::1";
        user = "root";
      };

      ctrl3 = {
        hostname = "2a01:4f8:c013:2c9f::1";
        user = "root";
      };

      app1 = {
        hostname = "2a01:4f8:c17:1868::1";
        user = "root";
      };

      app2 = {
        hostname = "2a01:4f8:c012:2e6e::1";
        user = "root";
      };

      blob1 = {
        hostname = "2a01:4f8:c012:1a76::1";
        user = "root";
      };

      blob2 = {
        hostname = "2a01:4f8:c010:b1f2::1";
        user = "root";
      };

      blob3 = {
        hostname = "2a01:4f8:c013:232a::1";
        user = "root";
      };

      blob4 = {
        hostname = "2a01:4f8:1c17:4c78::1";
        user = "root";
      };

      db = {
        hostname = "2a01:4f8:c012:b551::1";
        user = "root";
      };

      convexio-mon = {
        hostname = "2a01:4f8:c012:cd1::1";
        user = "root";
      };

      lb1 = {
        hostname = "2a01:4f8:1c17:6902::1";
        user = "root";
      };

      lb2 = {
        hostname = "2a01:4f8:c17:4c9e::1";
        user = "root";
      };

      #"awsbuilder" = {
      #  hostname = "35.157.132.66";
      #  user = "admin";
      #  identityFile = "/var/src/secrets/ssh.id_ed25519";
      #};
    };
  };
}
