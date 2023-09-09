plugins: {
  firmwareupdater = plugins.callPackage ./octoprint-plugins/firmwareupdater.nix { };
  prusalevelingguide = plugins.callPackage ./octoprint-plugins/prusalevelingguide.nix { };
  prusaslicerthumbnails = plugins.callPackage ./octoprint-plugins/prusaslicerthumbnails.nix { };
}
