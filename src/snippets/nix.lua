return {
    parse("flake-module-vm", [[
{
  description = "$1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      overlay = final: prev: { };

      # defaultPackage = forAllSystems (system: (import nixpkgs {
      #   inherit system;
      #   overlays = [ self.overlay ];
      # }).XXX);

      devShell = forAllSystems
        (system: (with (import nixpkgs { inherit system; });
        mkShell { buildInputs = with pkgs; [ ]; }));

      nixosModules.$1 = ({ config, lib, pkgs, ... }: with lib;
        let
          cfg = config.services.$1;
        in
        {
          options.services.$1 = {
            enable = mkEnableOption "services.$1";
          };

          config = mkIf cfg.enable {
            nixpkgs.overlays = [ self.overlay ];
          };
        });

      nixosConfigurations.prod-vm = nixpkgs.lib.nixosSystem {
        system = "${2|aarch64-linux,x86_64-linux|}";
        modules = [
          self.nixosModules.$1
          ({ config, lib, modulesPath, pkgs, ... }: {
            imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
            virtualisation.forwardPorts = [
              { host.port = 9080; guest.port = 8000; }
            ];
            services.getty.autologinUser = lib.mkDefault "root";
            console.keyMap = "de-latin1";
            services.$1 = {
              enable = true;
            };
            networking.firewall.allowedTCPPorts = [ 8000 ];
            system.stateVersion = "22.05";
          })
        ];
      };
    };
}
]]), parse("nix-module-empty", [[
{ config, lib, pkgs, ... }:

{
  $1
}]]), parse("nix-python-package", [[
{ buildPythonPackage, fetchFromGitHub, lib }:

buildPythonPackage rec {
  pname = "$1";
  version = "$2";

  src = fetchFromGitHub {
    owner = "$1";
    repo = "$1";
    rev = "v\${version}";
    sha256 = lib.fakeSha256;
  };

  doCheck = false;

  propagatedBuildInputs = [ ];
}]]), parse("nix-flake-django-venv", [[
{
  description = "$1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      devShell = forAllSystems
        (system: (with (import nixpkgs { inherit system; });
        let
          py3 = python3.override
            {
              packageOverrides = self: super: rec {
                django = self.django_3;
                django-stubs-ext = self.buildPythonPackage rec {
                  pname = "django-stubs-ext";
                  version = "0.5.0";
                  src = fetchFromGitHub {
                    owner = "typeddjango";
                    repo = "django-stubs";
                    rev = "django-stubs-ext@${version}";
                    sha256 = "sha256-Y3FZIjQ9li51LCf//zqvxfYQ7qJnvV0rs/qWrQSThvU=";
                  };
                  sourceRoot = "${src.name}/django_stubs_ext";
                  propagatedBuildInputs = with super; [ django typing-extensions ];
                  doCheck = false;
                };
                django-stubs = self.buildPythonPackage rec {
                  pname = "django-stubs";
                  version = "1.12.0";
                  src = self.fetchPypi {
                    inherit pname version;
                    sha256 = "sha256-6os10NpJ97LumaeRJfGUPgM0Md0RRybWZDzDXeYZIw4=";
                  };
                  propagatedBuildInputs = with super; [ django mypy django-stubs-ext tomli typing-extensions types-pytz types-pyyaml ];
                  doCheck = false;
                };
                pyinstrument = self.buildPythonPackage rec {
                  pname = "pyinstrument";
                  version = "4.1.1";
                  src = self.fetchPypi {
                    inherit pname version;
                    sha256 = "sha256-HcJ5HSzS/TRZy1UBAASlzCqai0YloMvqRaSxrrviw6I=";
                  };
                  doCheck = false;
                };
              };
            };
          venv = py3.withPackages (ps: with ps; [
            django
            django-debug-toolbar
            django-stubs
            django_environ
            pyinstrument
            whitenoise
          ]);
        in
        mkShell {
          buildInputs = with pkgs; [
            venv
          ];
          DEBUG = "1";
          PYTHONPATH = "${venv}/${py3.sitePackages}";
        }));
    };
}]]), parse("nix-flake-python-venv", [[
{
  description = "$1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      devShell = forAllSystems
        (system: (with (import nixpkgs { inherit system; });
        let
          py3 = python3.override
            {
              packageOverrides = self: super: rec { };
            };
          venv = py3.withPackages (ps: with ps; [ ]);
        in
        mkShell {
          buildInputs = with pkgs; [ venv ];
        }));
    };
}]])
}
