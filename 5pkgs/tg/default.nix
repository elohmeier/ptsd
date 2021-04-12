{ python3, fetchFromGitHub, fetchpatch, tdlib }:

let
  py3 = python3.override {
    packageOverrides = self: super: rec {
      python-telegram = super.buildPythonPackage rec {
        pname = "python-telegram";
        version = "0.14.0";
        src = fetchFromGitHub {
          owner = "alexander-akhmetov";
          repo = pname;
          rev = version;
          sha256 = "sha256-JnClppbOUNGJayCfcPH8TgWOlFBGzz+qsrRtai4gyxg=";
        };
        checkInputs = with super; [ pytestCheckHook ];
      };
    };
  };
in
py3.pkgs.buildPythonApplication rec {
  pname = "tg";
  version = "0.7.0";
  src = fetchFromGitHub {
    owner = "paul-nameless";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-IkZTrkCV3wsA6rbs783LQ/DIkOSBqxzxMiC2CjjI4qM=";
  };
  patches = [
    (fetchpatch {
      name = "td-1.6.0-compat.patch";
      url = "https://github.com/paul-nameless/tg/commit/93843719b411d4b05dd917111636bfa540bfdb9d.patch";
      sha256 = "sha256-+Shylbxup0Yk5E1qgRf25sxNFIzeKtABNP8XXu/wgsQ=";
    })
    (fetchpatch {
      name = "td-1.6.10-compat.patch";
      url = "https://github.com/paul-nameless/tg/commit/564696b8c73f1f80ec92a7823bd9d9e7d40992b6.patch";
      sha256 = "sha256-PMEo2CyQi87MeBQ+Ion71k9F8wjqEiS2WLDq7T/sMpE=";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py --replace "python-telegram==0.12.0" "python-telegram>=0.12.0"
    substituteInPlace tg/config.py \
      --replace "TDLIB_PATH = None" "TDLIB_PATH = \"${tdlib}/lib/libtdjson.so\""
  '';
  preBuild = ''
    export HOME=$(mktemp -d)
  '';
  propagatedBuildInputs = with py3.pkgs; [ python-telegram setuptools ];
  doCheck = false; # no tests
  pythonImportsCheck = [ "tg" ];
}
