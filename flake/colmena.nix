{ self, inputs, ... }:

let
  conf = self.nixosConfigurations;

  nodeTags = {
  };

  targetHosts = {
    htz2 = "htz2.nn42.de";
  };
in
{
  flake.colmena =
    {
      meta = {
        nixpkgs = import inputs.nixpkgs { system = "aarch64-linux"; };
        nodeNixpkgs = builtins.mapAttrs (_name: value: value.pkgs) conf;
        nodeSpecialArgs = builtins.mapAttrs (_name: value: value._module.specialArgs) conf;
      };

    }
    // builtins.mapAttrs (name: value: {
      imports = value._module.args.modules;
      deployment.tags =
        if builtins.elem name (builtins.attrNames nodeTags) then nodeTags.${name} else [ ];
      deployment.targetHost = targetHosts.${name};
    }) conf;
}
