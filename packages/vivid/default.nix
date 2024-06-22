{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "vivid";
  version = "2024-04-07"; # not released yet

  src = fetchFromGitHub
    {
      owner = "sharkdp";
      repo = pname;
      rev = "0415e630c752500d34591a0d86bf796e73b87baa";
      hash = "sha256-YTf00F1jqK1UjsPm0ZsYZ6mV0S/k5Nt3PIUlhlTk4kY=";
    };

  cargoHash = "sha256-KUjRAeXMQpoqKvz4xWPmX+8Mdf4r3KK4W794Tww54tM=";

  meta = with lib; {
    description = "Generator for LS_COLORS with support for multiple color themes";
    homepage = "https://github.com/sharkdp/vivid";
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = [ maintainers.dtzWill ];
    platforms = platforms.unix;
    mainProgram = "vivid";
  };
}

