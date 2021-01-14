{ pkgs, ... }:
{
  # access it using http://localhost:8080/draw/
  services.tomcat = {
    enable = true;
    package = pkgs.tomcat9;
    purifyOnStart = true;
    webapps = [ pkgs.drawio-web ];
  };
}
