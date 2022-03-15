{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "react-devtools";
  url = "https://addons.mozilla.org/firefox/downloads/file/3920243/react_developer_tools-4.24.0-fx.xpi";
  sha256 = "sha256-rf/o6wxcPGzH2RafwEaOu/h6YwTL+zXmW2jsy/f8Bk8=";
}
