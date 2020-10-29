{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  mdiwf = fetchFromGitHub
    {
      name = "materialdesign-webfont-variables-5.8.55";
      owner = "Templarian";
      repo = "MaterialDesign-Webfont";
      rev = "v5.8.55";
      sha256 = "0p6vh5j90h7mf30rclily2m5p0rbvlf2yqc7ffqkhgmj4g2k3vwx";
      postFetch = ''
        tar xf $downloadedFile --strip=1
        install -m444 -Dt $out/mdi scss/_variables.scss
      '';
    };
  fa5 = fetchFromGitHub
    {
      name = "font-awesome-iconsyml-5.10.2";
      owner = "FortAwesome";
      repo = "Font-Awesome";
      rev = "5.10.2";
      sha256 = "12dbhqcll6x6c1cz5xch6rylia6ch9l7mi12gihqqyf74gmy3kgx";
      postFetch = ''
        tar xf $downloadedFile --strip=1
        install -m444 -Dt $out/fa5 metadata/icons.yml
      '';
    };
  typ =
    fetchFromGitHub {
      name = "typicons-configyml-2.0.9";
      owner = "stephenhutchings";
      repo = "typicons.font";
      rev = "v2.0.9";
      sha256 = "0m803k32cnlimljz1nw7n8bjmszrxi0flxv6qgw32wcp08323w7z";
      postFetch = ''
        tar xf $downloadedFile --strip=1
        install -m444 -Dt $out/typ config.yml
      '';
    };
in
stdenv.mkDerivation {
  name = "nwi3status-iconfontsgobindata";
  srcs = [ mdiwf fa5 typ ];
  dontUnpack = true;
  buildInputs = [ go-bindata ];
  buildPhase = ''
    mkdir fonts
    cp ${mdiwf}/mdi/_variables.scss fonts/mdi_variables.scss
    cp ${fa5}/fa5/icons.yml fonts/fa5_icons.yml
    cp ${typ}/typ/config.yml fonts/typ_config.yml
    go-bindata -pkg fonts fonts
  '';
  installPhase = ''
    mkdir -p $out
    cp bindata.go $out/
  '';
}
