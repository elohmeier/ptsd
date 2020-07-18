{ pkgs, stdenv, lib, fetchFromGitHub, python3 }:
let
  mkOverride = attrname: version: sha256:
    self: super: {
      "${attrname}" = super.${attrname}.overridePythonAttrs (
        oldAttrs: {
          inherit version;
          src = oldAttrs.src.override {
            pname = attrname;
            inherit version sha256;
          };
        }
      );
    };

  py = python3.override {
    self = py;

    packageOverrides = lib.foldr lib.composeExtensions (self: super: { }) (
      [
        (mkOverride "click" "6.7" "02qkfpykbq35id8glfgwc38yc430427yd05z1wc5cnld8zgicmgi")
        (mkOverride "tqdm" "4.14.0" "13p82pqjnzch87xmsdk1k928bzgziy0qmpw04l942pqkgjspqjr8")
        (mkOverride "piexif" "1.1.2" "0dj6wiw4mk65zn7p0qpghra39mf88m3ph2xn7ff9jvasgczrgkb0")
        (mkOverride "python-dateutil" "2.6.1" "1jkahssf0ir5ssxc3ydbp8cpv77limn8d4s77szb2nrgl2r3h749")
        #(mkOverride "pytest" "3.6.4" "0h85kzdi5pfkz9v0z8xyrsj1rvnmyyjpng7cran28jmnc41w27il")
        #(mkOverride "pluggy" "0.7.1" "1qbn70mksmr03hac6jgp6fiqc4l7859z8dchx2x950vhlij87swm")
        (mkOverride "py" "1.5.1" "18xkhkz4z604l1nrh4rxh5c3dybzpvps9cky73316x435qyalnp8")

        (
          self: super: rec {
            pyicloud-ipd = self.callPackage ../pyicloud-ipd { };

            schema = self.buildPythonPackage rec {

              pname = "schema";
              version = "0.6.6";

              src = super.fetchPypi {
                inherit pname version;
                sha256 = "1lw28j9w9vxyigg7vkfkvi6ic9lgjkdnfvnxdr7pklslqvzmk2vm";
              };

              checkInputs = with super; [ pytest ];
            };

            pytest_3_6_4 = self.buildPythonPackage rec {
              version = "3.6.4";
              pname = "pytest";

              preCheck = ''
                # don't test bash builtins
                rm testing/test_argcomplete.py
              '';

              src = super.fetchPypi {
                inherit pname version;
                sha256 = "0h85kzdi5pfkz9v0z8xyrsj1rvnmyyjpng7cran28jmnc41w27il";
              };

              checkInputs = with super; [ hypothesis mock ];
              buildInputs = with super; [ setuptools_scm ];
              propagatedBuildInputs = with super; [ attrs py setuptools six pluggy more-itertools atomicwrites ]
                ++ (stdenv.lib.optional (!isPy3k) funcsigs);

              checkPhase = ''
                runHook preCheck
                $out/bin/py.test -x testing/
                runHook postCheck
              '';

              # Don't create .pytest-cache when using py.test in a Nix build
              setupHook = pkgs.writeText "pytest-hook" ''
                export PYTEST_ADDOPTS="-p no:cacheprovider"
              '';
            };
          }
        )

        (
          self: super: {
            icloud-photos-downloader = self.buildPythonPackage rec {
              pname = "icloud-photos-downloader";
              version = "2020-06-01";

              src = fetchFromGitHub {
                owner = "ndbroadbent";
                repo = "icloud_photos_downloader";
                rev = "e5f304941e2a74b1fbda06c4270ec2fc100e6a49";
                sha256 = "0pwlyxv44dc7096y08c4h337qaylag2ifdy41s68k45yf12d9bx2";
              };

              propagatedBuildInputs = with super; [
                pyicloud-ipd
                docopt
                schema
                click
                python-dateutil
                requests
                tqdm
                piexif
              ];

              checkInputs = with super; [ pytest_3_6_4 mock vcrpy freezegun ];

              preCheck = ''
                export HOME=$TMP
              '';
            };
          }
        )


      ]
    );
  };
in
with py.pkgs; toPythonApplication icloud-photos-downloader
