{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "tridactyl-vim";
  url = "https://addons.mozilla.org/firefox/downloads/file/3746329/tridactyl-1.21.1-an+fx.xpi";
  sha256 = "sha256-BuLd1D8CCTdMTXIxLcdWYGCgNpyGD2jPVbD8xxlFDs4=";
}
