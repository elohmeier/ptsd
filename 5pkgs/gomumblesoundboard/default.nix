{ buildGoModule, fetchFromGitHub, libopus, pkg-config, lib }:

buildGoModule {
  pname = "gomumblesoundboard";
  version = "2022-04-22";
  src = fetchFromGitHub {
    owner = "elohmeier";
    repo = "gomumblesoundboard";
    rev = "b6afffe3a610091f16b34410e3126240c4e8dcb6";
    sha256 = "sha256-3XfA73gmnuCgqWSs1MSoTapfNQOH2TnAswMcboIz8OI=";
  };
  vendorSha256 = "sha256-i859sY9eYYjDMB/NYMvSbSXgV7Z/fbup8rhNiXAVQ3E=";
  buildInputs = [ libopus ];
  nativeBuildInputs = [ pkg-config ];
}
