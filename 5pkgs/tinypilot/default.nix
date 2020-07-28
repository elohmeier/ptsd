{ buildPythonApplication, fetchFromGitHub, nix-gitignore, eventlet, flask, flask-socketio, flask_wtf }:

buildPythonApplication rec {
  pname = "tinypilot";
  version = "2020-07-25";
  propagatedBuildInputs = [ eventlet flask flask-socketio flask_wtf ];

  # src = fetchFromGitHub {
  #   owner = "mtlynch";
  #   repo = pname;
  #   rev = "b402bacd1cb069f111cc3107dcae6d9a8a277f20";
  #   sha256 = "1wfihy3mrnbym2kvxn34ag0snhkp39zp5ixr9sh85smc33bn4igd";
  # };

  src = fetchFromGitHub {
    owner = "elohmeier";
    repo = pname;
    rev = "1a716b21080870c6a20a032ec99cfe111309a98a";
    sha256 = "1gkkmnzbvl27pshiag9s7nqafvb9ji8rd8pqjfd4gmjjx5wjnjp1";
  };

  # src = nix-gitignore.gitignoreSource [ "build" ] /home/enno/repos/tinypilot;

  doCheck = false; # no tests
}
