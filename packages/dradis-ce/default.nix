{ bundlerEnv
, fetchFromGitHub
, lib
, icu
, makeWrapper
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

  extraConfig = runCommand "extraConfig" { } ''
    mkdir -p $out
    cp -r ${src}/{engines,lib} $out/
    substituteInPlace $out/engines/dradis-api/dradis-api.gemspec \
      --replace "git ls-files" "find . -type f"
  '';

  rubyEnv = bundlerEnv {
    inherit ruby;
    name = "dradis-ce-bundler-env";
    gemdir = ./.;
    extraConfigPaths = [ "${extraConfig}/engines" "${extraConfig}/lib" ];

    gemset =
      # let gems = import "${srcWithGemset}/gemset.nix";
      let gems = import ./gemset.nix;
      in gems // {
        mini_racer = gems.mini_racer // {
          buildInputs = [ icu ];
          dontBuild = false;
          NIX_LDFLAGS = "-licui18n";
        };

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

    buildPhase = ''
      runHook preBuild

      mv config config.dist
      mv public public.dist
      rm -rf log

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -r . $out/share/dradis

      ln -sf /run/dradis/config $out/share/dradis/config
      ln -sf /run/dradis/public $out/share/dradis/public
      ln -sf /var/lib/dradis/attachments $out/share/dradis/attachments
      ln -sf /var/lib/dradis/tmp $out/share/dradis/tmp
      ln -sf /var/log/dradis $out/share/dradis/log

      runHook postInstall
    '';

    passthru = {
      inherit rubyEnv;
      ruby = rubyEnv.wrappedRuby;
    };
  };
in
dradis
