{ pkgs, ... }:

let
  # generate using node2nix -i collection.json -16 -c node-composition.nix
  myNodePkgs = pkgs.callPackage ./node-composition.nix { };
  joined = pkgs.symlinkJoin {
    name = "prettier-with-plugins";
    paths = with myNodePkgs; [
      prettier
      prettier-plugin-svelte
      prettier-plugin-toml
    ];
  };
  config = pkgs.writeText "prettier.config.cjs" ''
    module.exports = {
      plugins: [
        require.resolve('prettier-plugin-svelte'),
        require.resolve('prettier-plugin-toml')
      ]
    };
  '';
in
myNodePkgs.prettier.overrideAttrs (old: {
  nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/prettier \
      --set NODE_PATH ${joined}/lib/node_modules \
      --add-flags "--config ${config}"
  '';
})
