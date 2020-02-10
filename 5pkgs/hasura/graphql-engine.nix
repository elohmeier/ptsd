{ lib
, mkDerivation
, aeson
, aeson-casing
, ansi-wl-pprint
, asn1-encoding
, asn1-types
, async
, attoparsec
, attoparsec-iso8601
, auto-update
, base
, base64-bytestring
, byteorder
, bytestring
, case-insensitive
, ci-info
, containers
, cryptonite
, data-has
, ekg-core
, ekg-json
, fast-logger
, fetchFromGitHub
, file-embed
, filepath
, graphql-parser
, hashable
, hspec
, http-client
, http-client-tls
, http-types
, insert-ordered-containers
, jose
, lens
, list-t
, mime-types
, monad-control
, monad-time
, monad-validate
, mtl
, mustache
, network
, network-uri
, optparse-applicative
, pem
, pg-client
, postgresql-binary
, postgresql-libpq
, process
, regex-tdfa
, scientific
, semver
, shakespeare
, split
, Spock-core
, stm
, stm-containers
, string-conversions
, template-haskell
, text
, text-builder
, text-conversions
, th-lift-instances
, time
, transformers
, transformers-base
, unix
, unordered-containers
, uuid
, vector
, wai
, wai-websockets
, warp
, websockets
, wreq
, x509
, yaml
, zlib
}:

mkDerivation rec {
  pname = "graphql-engine";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "hasura";
    repo = "graphql-engine";
    sha256 = "1rkw52rhwdkk82db2zf4pnzll5av3a76sjzpdkv0y3417ipiv6jg";
    rev = "v${version}";
  };

  postUnpack = "sourceRoot+=/server";
  preBuild = "export VERSION=${version}";

  isLibrary = true;
  isExecutable = true;
  doCheck = false;
  doHaddock = false;

  libraryHaskellDepends = [
    aeson
    aeson-casing
    ansi-wl-pprint
    asn1-encoding
    asn1-types
    async
    attoparsec
    attoparsec-iso8601
    auto-update
    base
    base64-bytestring
    byteorder
    bytestring
    case-insensitive
    ci-info
    containers
    cryptonite
    data-has
    ekg-core
    ekg-json
    fast-logger
    file-embed
    filepath
    graphql-parser
    hashable
    http-client
    http-types
    insert-ordered-containers
    jose
    lens
    list-t
    mime-types
    monad-control
    monad-time
    monad-validate
    mtl
    mustache
    network
    network-uri
    optparse-applicative
    pem
    pg-client
    postgresql-binary
    postgresql-libpq
    process
    regex-tdfa
    scientific
    semver
    shakespeare
    split
    Spock-core
    stm
    stm-containers
    string-conversions
    template-haskell
    text
    text-builder
    text-conversions
    th-lift-instances
    time
    transformers
    transformers-base
    unordered-containers
    uuid
    vector
    wai
    wai-websockets
    warp
    websockets
    wreq
    x509
    yaml
    zlib
  ];

  executableHaskellDepends = [
    aeson
    base
    bytestring
    http-client
    http-client-tls
    lens
    mtl
    optparse-applicative
    pg-client
    stm
    string-conversions
    template-haskell
    text
    time
    unix
    unordered-containers
    uuid
    warp
    wreq
    yaml
  ];

  testHaskellDepends = [
    base
    hspec
    http-client
    http-client-tls
    optparse-applicative
    pg-client
    time
  ];

  homepage = "https://www.hasura.io";
  description = "GraphQL API over Postgres";
  license = lib.licenses.asl20;
  maintainers = [ lib.maintainers.offline ];
}
