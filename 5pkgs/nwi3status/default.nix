{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper, gsimplecal, wirelesstools }:

buildGoModule rec {
  name = "nwi3status";
  goPackagePath = "git.nerdworks.de/nerdworks/ptsd/5pkgs/${name}";
  vendorSha256 = "0kvszm70lpbapdn15sj4b04mhvxg459axq04pikqbv3p6x26wf19";
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/nwi3status \
      --set PATH "$out/bin:${gsimplecal}/bin:${wirelesstools}/bin"
  '';
}
