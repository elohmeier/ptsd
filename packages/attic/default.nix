{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  installShellFiles,
  nix,
  boost,
  darwin,
  fetchFromGitHub,

  # Only build the client
  clientOnly ? false,

  # Only build certain crates
  crates ?
    if clientOnly then
      [ "attic-client" ]
    else
      [
        "attic-client"
        "attic-server"
      ],
}:

let
  ignoredPaths = [
    ".github"
    "target"
    "book"
  ];

in
rustPlatform.buildRustPackage rec {
  pname = "attic";
  version = "2024-03-29";

  src = fetchFromGitHub {
    owner = "zhaofengli";
    repo = "attic";
    rev = "4dbdbee45728d8ce5788db6461aaaa89d98081f0";
    hash = "sha256-0O4v6e4a1toxXZ2gf5INhg4WPE5C5T+SVvsBt+45Mcc=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    nix
    boost
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ SystemConfiguration ]);

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };
  cargoHash = "";
  cargoBuildFlags = lib.concatMapStrings (c: "-p ${c} ") crates;

  ATTIC_DISTRIBUTOR = "attic";

  # See comment in `attic/build.rs`
  NIX_INCLUDE_PATH = "${lib.getDev nix}/include";

  # Recursive Nix is not stable yet
  doCheck = false;

  postInstall = lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    if [[ -f $out/bin/attic ]]; then
      installShellCompletion --cmd attic \
        --bash <($out/bin/attic gen-completions bash) \
        --zsh <($out/bin/attic gen-completions zsh) \
        --fish <($out/bin/attic gen-completions fish)
    fi
  '';

  meta = with lib; {
    description = "Multi-tenant Nix binary cache system";
    homepage = "https://github.com/zhaofengli/attic";
    license = licenses.asl20;
    maintainers = with maintainers; [ zhaofengli ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
