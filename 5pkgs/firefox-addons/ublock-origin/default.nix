{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "ublock-origin";
  url = "https://addons.mozilla.org/firefox/downloads/file/3913320/ublock_origin-1.41.8-an+fx.xpi";
  sha256 = "0pcg9sr1cadkxbv25jfg4kv5d3ai06wxyg4nvgynyv3a24kpaz2j";
}
