
  # services.murmur =
  #   let
  #     secrets = import <secrets/murmur.nix>;
  #   in
  #   {
  #     enable = true;
  #     allowHtml = false;
  #     password = secrets.password;
  #     registerHostname = "fraam.de";
  #     registerName = "fraam.de";
  #     sendVersion = false;
  #     sslCert = "/var/lib/acme/fraam.de/cert.pem";
  #     sslKey = "/var/lib/acme/fraam.de/key.pem";
  #     users = 20;
  #   };
  # users.groups.certs.members = [ "murmur" ];
  # networking.firewall.interfaces.ens3.allowedTCPPorts = [ config.services.murmur.port ];
  # networking.firewall.interfaces.ens3.allowedUDPPorts = [ config.services.murmur.port ];
