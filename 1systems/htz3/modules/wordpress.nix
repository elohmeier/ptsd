{ config, lib, pkgs, ... }:

let
  domain = "int.fraam.de";
in
{
  services.wordpress = {
    sites."${domain}".database.name = "wordpress_fraam";
    webserver = "nginx";
  };
}
