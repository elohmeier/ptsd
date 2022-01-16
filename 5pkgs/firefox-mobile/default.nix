{ lib
, wrapFirefox
, firefox-esr-unwrapped
, mobile-config-firefox
, ptsd-firefoxAddons
, ...
}:

let
  mobilePolicies = lib.importJSON "${mobile-config-firefox}/etc/firefox/policies/policies.json";
in
wrapFirefox firefox-esr-unwrapped {
  forceWayland = true;
  #nixExtensions = with ptsd-firefoxAddons;
  #  [ ublock-origin ];

  extraPolicies = mobilePolicies.policies;
  extraPrefs = builtins.readFile "${mobile-config-firefox}/usr/lib/firefox/defaults/pref/mobile-config-prefs.js";
}
