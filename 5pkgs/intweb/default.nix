{ python3Packages }:

python3Packages.buildPythonApplication {
  name = "intweb";
  src = /home/enno/repos/intweb;
  propagatedBuildInputs = with python3Packages;[ authlib jinja2 tabulate ];
}
