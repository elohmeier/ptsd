{ buildPythonPackage, requests, django_3, pandas, holidays, monday, defusedxml, python-dateutil, icalendar, django_environ }:

buildPythonPackage rec {
  pname = "fraamdb";
  version = "1.0.0";

  #src = builtins.fetchGit {
  #  url = "git@git.fraam.de:fraam/fraamdb.git";
  #  rev = "c79d274c149cdc3fa151235ffd7a57df42fa3492";
  #};

  src = /home/enno/repos/fraamdb;

  propagatedBuildInputs = [ requests django_3 pandas holidays monday defusedxml python-dateutil icalendar django_environ ];
}
