{ pkgs
, lib
, nodejs
, stdenv
, writeShellScript
, runCommand
}:

let
  # parse the version from package.json
  version =
    let
      packageJson = lib.importJSON ./package.json;
      splits = builtins.split "^.*#v(.*)$" (builtins.getAttr "logseq-query" (builtins.head packageJson));
      matches = builtins.elemAt splits 1;
      elem = builtins.head matches;
    in
    elem;

  logseqQueryPkg = "logseq-query-git+https://github.com/cldwalker/logseq-query.git#v${version}";

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  pkg = nodePackages."${logseqQueryPkg}";

  script = writeShellScript "${pkg.packageName}-starter-${pkg.version}" ''
    ${nodejs}/bin/node ${pkg}/lib/node_modules/logseq-query/index.mjs "$@"
  '';
in
runCommand "${pkg.packageName}-${pkg.version}" { } ''
  mkdir -p $out/bin
  ln -s ${script} $out/bin/logseq-query
''
