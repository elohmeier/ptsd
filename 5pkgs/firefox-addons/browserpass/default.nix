{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "browserpass-ce";
  url = "https://addons.mozilla.org/firefox/downloads/file/3711209/browserpass-3.7.2-fx.xpi";
  sha256 = "sha256-sXgUBbRvMnRpeIW1MTkmTcoqtW/8RDXAkxAq1evFkpc=";
}
