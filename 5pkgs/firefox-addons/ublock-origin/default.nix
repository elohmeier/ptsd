{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "ublock-origin";
  url = "https://addons.mozilla.org/firefox/downloads/file/3816867/ublock_origin-1.37.2-an+fx.xpi";
  sha256 = "sha256-s6PIGJGstGIOM91Ui1A3Wq2CY3YESmFDtalH0EBqVZ4=";
}
