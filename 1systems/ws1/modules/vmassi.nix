{ config, lib, pkgs, ... }:

let
  kbd-usb = pkgs.writeText "kbd-usb.xml" ''
    <hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <!-- Microsoft Ergonomic Keyboard -->
        <vendor id='0x045e'/>
        <product id='0x082c'/>
      </source>
    </hostdev>
  '';

  mouse-usb = pkgs.writeText "mouse-usb.xml" ''
    <hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <!-- Logitech USB Receiver -->
        <vendor id='0x046d'/>
        <product id='0xc52b'/>
      </source>
    </hostdev>
  '';

  vmname = "win10_3d";
  attach-keyboard = pkgs.writeShellScriptBin "attach-keyboard-${vmname}" ''virsh --connect qemu:///system attach-device "${vmname}" "${kbd-usb}"'';
  detach-keyboard = pkgs.writeShellScriptBin "detach-keyboard-${vmname}" ''virsh --connect qemu:///system detach-device "${vmname}" "${kbd-usb}"'';

  attach-mouse = pkgs.writeShellScriptBin "attach-mouse-${vmname}" ''virsh --connect qemu:///system attach-device "${vmname}" "${mouse-usb}"'';
  detach-mouse = pkgs.writeShellScriptBin "detach-mouse-${vmname}" ''virsh --connect qemu:///system detach-device "${vmname}" "${mouse-usb}"'';

  allpkgs = [
    detach-keyboard
    detach-mouse
    attach-mouse
    attach-keyboard
  ];
in
{
  users.groups.vmassi = { };
  users.users.vmassi = {
    group = "vmassi";
    isNormalUser = true;
    extraGroups = [ "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa32topGz9+YP0Rwo7OH1ofK94GU74knwYw5wv7nCmP gordon@DESKTOP-1ICIFJO"
    ];
    packages = allpkgs;
  };

  environment.systemPackages = allpkgs;

  ptsd.desktop.keybindings = {
    "Control+Shift+Mod1+a" = "exec ${attach-keyboard}/bin/attach-keyboard-${vmname}";
  };
}
