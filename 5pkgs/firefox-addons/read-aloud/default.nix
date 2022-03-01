{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "read-aloud";
  url = "https://addons.mozilla.org/firefox/downloads/file/3911582/read_aloud_a_text_to_speech_voice_reader-1.52.1-an+fx.xpi";
  sha256 = "0cnwaslfznkrsqvqqfx31pdrspzyj8axa3sbcr3afhc4pvvlc887";
}
