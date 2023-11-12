({ config, lib, modulesPath, pkgs, ... }: {
  imports = [
    (modulesPath + "/profiles/installation-device.nix")
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
  ];
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_0.override {
    argsOverride = rec {
      src = pkgs.fetchFromGitHub {
        owner = "torvalds";
        repo = "linux";
        rev = "v${version}";
        sha256 = "sha256-FbXvv2fV/2JA81DRtglQXf0pL1SON5o3bx2hrHv/Dug=";
      };
      version = "6.1-rc6";
      modDirVersion = "6.1.0-rc6";
    };
  });
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-linux${config.boot.kernelPackages.kernel.modDirVersion}.iso";
  users.users.nixos.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;
  users.users.root.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;

  environment.systemPackages =
    with pkgs;
    [
      btop
      gitMinimal
      neovim
      nnn
      tmux
    ];

  boot.supportedFilesystems = [ "ntfs" ];

  console.keyMap = "de-latin1";
  services.xserver.layout = "de";
  i18n.defaultLocale = "de_DE.UTF-8";
  time.timeZone = "Europe/Berlin";
  #hardware.enableAllFirmware = true;
  networking = {
    useNetworkd = true;
    useDHCP = false;
    wireless.enable = false;
    wireless.iwd.enable = true;
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    networkmanager.wifi.backend = "iwd";
    usePredictableInterfaceNames = false;
  };

  system.activationScripts.configure-iwd = nixpkgs.lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /var/lib/iwd
    cat >/var/lib/iwd/Bundesdatenschutzzentrale.psk <<EOF
    [Security]
    Passphrase=
    EOF
  '';

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

})
