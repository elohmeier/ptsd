{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "cookie-autodelete";
  url = "https://addons.mozilla.org/firefox/downloads/file/3711829/cookie_autodelete-3.6.0-an+fx.xpi";
  sha256 = "sha256-+DZG1C9HbIY4QWT9SGj6nFt0UkkfHzfU4hnD+zxCHe8=";
}
