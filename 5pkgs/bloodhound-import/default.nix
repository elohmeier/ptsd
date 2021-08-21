{ buildPythonPackage, fetchFromGitHub, ijson, neo4j-driver }:

buildPythonPackage rec {
  pname = "bloodhound-import";
  version = "2021-02-22";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = pname;
    rev = "10276278b8bebebca7db2278e1ca4d0613c029ee";
    sha256 = "sha256-39rAfkEhcJhGvIvBS7p4EEtmWECMKELWSez4IcYBGDw=";
  };

  propagatedBuildInputs = [
    ijson
    neo4j-driver
  ];
}
