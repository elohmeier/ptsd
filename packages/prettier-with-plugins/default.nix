{ pkgs, ... }:

let
  # generate using node2nix -i collection.json -16 -c node-composition.nix
  myNodePkgs = pkgs.callPackage ./node-composition.nix { };
  joined = pkgs.symlinkJoin {
    name = "prettier-with-plugins";
    paths = [
      myNodePkgs.prettier
      myNodePkgs.prettier-plugin-svelte
      myNodePkgs.prettier-plugin-toml
      myNodePkgs."@prettier/plugin-xml"
    ];
  };
  config = pkgs.writeText "prettier.config.cjs" ''
    module.exports = {
      plugins: [
        require.resolve('prettier-plugin-svelte'),
        require.resolve('prettier-plugin-toml'),
        require.resolve('@prettier/plugin-xml')
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
