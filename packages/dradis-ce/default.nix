{ bundlerEnv
, fetchFromGitHub
, nodejs_16
, ruby
, runCommand
, stdenv
, writeShellScript
}:

let
  version = "4.10.0";
  src = fetchFromGitHub {
    owner = "dradis";
    repo = "dradis-ce";
    rev = "v${version}";
    hash = "sha256-xO1j5sghbz41U5HiXhG5da1rZFpFuD0gnzY9+BMyJFE=";
  };
  srcWithGemset = runCommand "src-with-gemset" { } ''
    mkdir -p $out
    cp -r ${src}/* $out
    cp ${./gemset.nix} $out/gemset.nix
  '';
  rubyEnv = bundlerEnv {
    inherit ruby;
    name = "dradis-ce-bundler-env";
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;

    gemset =
      let gems = import "${srcWithGemset}/gemset.nix";
      in gems // {
        libv8-node =
          let
            noopScript = writeShellScript "noop" "exit 0";
            linkFiles = writeShellScript "link-files" ''
              cd ../..

              mkdir -p vendor/v8/${stdenv.hostPlatform.system}/libv8/obj/
              ln -s "${nodejs_16.libv8}/lib/libv8.a" vendor/v8/${stdenv.hostPlatform.system}/libv8/obj/libv8_monolith.a

              ln -s ${nodejs_16.libv8}/include vendor/v8/include

              mkdir -p ext/libv8-node
              echo '--- !ruby/object:Libv8::Node::Location::Vendor {}' >ext/libv8-node/.location.yml
            '';
          in
          gems.libv8-node // {
            dontBuild = false;
            postPatch = ''
              cp ${noopScript} libexec/build-libv8
              cp ${noopScript} libexec/build-monolith
              cp ${noopScript} libexec/download-node
              cp ${noopScript} libexec/extract-node
              cp ${linkFiles} libexec/inject-libv8
            '';
          };
      };
  };
  dradis = stdenv.mkDerivation {
    pname = "dradis-ce";
    inherit version src;
    buildInputs = [ rubyEnv rubyEnv.wrappedRuby rubyEnv.bundler ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -r . $out/share/dradis

      runHook postInstall
    '';

    passthru = {
      inherit rubyEnv;
      ruby = rubyEnv.wrappedRuby;
    };
  };
in
dradis
