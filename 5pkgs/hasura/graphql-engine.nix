{ mkDerivation
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
, criterion
, cryptonite
, data-has
, deepseq
, dependent-map
, dependent-sum
, ekg-core
, ekg-json
, fast-logger
, fetchgit
, file-embed
, filepath
, generic-arbitrary
, ghc-heap-view
, graphql-parser
, hashable
, hspec
, hspec-core
, hspec-expectations-lifted
, http-client
, http-client-tls
, http-types
, immortal
, insert-ordered-containers
, jose
, lens
, lifted-async
, lifted-base
, list-t
, mime-types
, monad-control
, monad-time
, monad-validate
, mtl
, mustache
, mwc-probability
, mwc-random
, natural-transformation
, network
, network-uri
, optparse-applicative
, pem
, pg-client
, postgresql-binary
, postgresql-libpq
, process
, profunctors
, psqueues
, QuickCheck
, regex-tdfa
, scientific
, semver
, shakespeare
, split
, Spock-core
, stdenv
, stm
, stm-containers
, string-conversions
, template-haskell
, text
, text-builder
, text-conversions
, th-lift-instances
, these
, time
, transformers
, transformers-base
, unix
, unordered-containers
, uri-encode
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
mkDerivation {
  pname = "graphql-engine";
  version = "1.0.0";
  src = fetchgit {
    url = "https://github.com/hasura/graphql-engine.git";
    sha256 = "0v5fs4ma2vxs1bygp45j62jg68bk4skvnf8g9j81b6jydda18lzs";
    rev = "ad07c06e5037f0deb83a2d3ccf1703df6cad1d35";
    fetchSubmodules = true;
  };
  postUnpack = "sourceRoot+=/server; echo source root reset to $sourceRoot";
  isLibrary = true;
  isExecutable = true;
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
    deepseq
    dependent-map
    dependent-sum
    ekg-core
    ekg-json
    fast-logger
    file-embed
    filepath
    generic-arbitrary
    ghc-heap-view
    graphql-parser
    hashable
    http-client
    http-client-tls
    http-types
    immortal
    insert-ordered-containers
    jose
    lens
    lifted-async
    lifted-base
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
    profunctors
    psqueues
    QuickCheck
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
    these
    time
    transformers
    transformers-base
    unix
    unordered-containers
    uri-encode
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
    base
    bytestring
    pg-client
    text
    text-conversions
  ];
  testHaskellDepends = [
    aeson
    base
    bytestring
    hspec
    hspec-core
    hspec-expectations-lifted
    http-client
    http-client-tls
    lifted-base
    monad-control
    mtl
    natural-transformation
    optparse-applicative
    pg-client
    QuickCheck
    time
    transformers-base
    unordered-containers
  ];
  benchmarkHaskellDepends = [
    async
    base
    bytestring
    criterion
    deepseq
    mwc-probability
    mwc-random
    split
    text
    vector
  ];
  doCheck = false;
  homepage = "https://www.hasura.io";
  description = "GraphQL API over Postgres";
  license = stdenv.lib.licenses.asl20;
  maintainers = with stdenv.lib.maintainers; [ offline ];
}
