{ stdenv, fetchFromGitHub, nodejs, yarn, nodePackages }:

stdenv.mkDerivation rec {
  pname = "peertube";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "Chocobozzz";
    repo = "PeerTube";
    rev = "v${version}";
    sha256 = "0zrrhc5kml7mqxafmr8yggiakjh3a33wvn2m1i6ij112nkjyv1bc";
  };

  nativeBuildInputs = [ nodejs yarn ];

  yarnCache = stdenv.mkDerivation {
    name = "${pname}-${version}-yarn-cache";
    inherit src;
    phases = [ "unpackPhase" "buildPhase" ];
    nativeBuildInputs = [ yarn nodePackages.node-gyp-build ];
    buildPhase = ''
      export HOME=$NIX_BUILD_ROOT
      yarn config set yarn-offline-mirror $out
      yarn --frozen-lockfile --ignore-scripts --ignore-platform \
        --ignore-engines --no-progress --non-interactive
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "0kid60vyvy8jqqa4kza1c0ak1gy8fjrx234ic3gaxcbch5kc85qj";
  };

  configurePhase = ''
    export HOME=$NIX_BUILD_ROOT
    yarn config --offline set yarn-offline-mirror ${yarnCache}
  '';

  buildPhase = ''
    yarn install --offline --frozen-lockfile --no-progress --non-interactive
    patchShebangs scripts/ node_modules/
    npm run build
    rm -r ./node_modules ./client/node_modules
    yarn install --offline --frozen-lockfile --no-progress --non-interactive --production
    yarn cache clean --no-progress --non-interactive
  '';

  installPhase = ''
    mkdir -p $out/
    cp -r . $out/
  '';
}
