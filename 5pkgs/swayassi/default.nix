{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper }:

buildGoModule rec {
  name = "swayassi";
  vendorSha256 = "sha256-er5u2j0v9Y21kVWVNy96Wn67CSq6F2or1kKXsaBp0t4=";
  src = ./.;
  # nativeBuildInputs = [ makeWrapper ];
  # postInstall = ''
  #   wrapProgram $out/bin/nwi3status \
  #     --set PATH "$out/bin:${gsimplecal}/bin:${wirelesstools}/bin"
  # '';
}
