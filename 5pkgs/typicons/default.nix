{ lib, fetchFromGitHub }:
let
  version = "2.0.9";
in
fetchFromGitHub {
  name = "typicons-${version}";
  owner = "stephenhutchings";
  repo = "typicons.font";
  rev = "v${version}";

  postFetch = ''
    tar xf $downloadedFile --strip=1
    mkdir -p $out/share/fonts/{eot,truetype,woff}
    cp src/font/*.eot $out/share/fonts/eot/
    cp src/font/*.ttf $out/share/fonts/truetype/
    cp src/font/*.woff $out/share/fonts/woff/
  '';
  sha256 = "1r8kn3ycpvy9dyxvf5afgr6zlrqplmj9g7819qdfblnipl22qrdv";
}
