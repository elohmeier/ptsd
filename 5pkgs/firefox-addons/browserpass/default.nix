{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "browserpass";
  fixedExtid = "browserpass@maximbaz.com"; # required for nativeMessagingHost integration
  url = "https://addons.mozilla.org/firefox/downloads/file/3711209/browserpass-3.7.2-fx.xpi";
  sha256 = "sha256-sXgUBbRvMnRpeIW1MTkmTcoqtW/8RDXAkxAq1evFkpc=";
}
