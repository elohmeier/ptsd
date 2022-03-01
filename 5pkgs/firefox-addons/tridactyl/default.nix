{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "tridactyl-vim";
  url = "https://addons.mozilla.org/firefox/downloads/file/3874829/tridactyl-1.22.0-an+fx.xpi";
  sha256 = "13ldqkd56vyimg7yqnk1rvndhf2rzyxmvaqhj6635qi14539hc5m";
}
