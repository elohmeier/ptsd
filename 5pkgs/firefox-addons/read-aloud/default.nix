{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "read-aloud";
  url = "https://addons.mozilla.org/firefox/downloads/file/3829895/read_aloud_a_text_to_speech_voice_reader-1.45.1-an+fx.xpi";
  sha256 = "sha256-ZjU0h1a1vYXbO5egUE5PbnQOdDrHbEdp3BBeycJ1Dw0=";
}
