{ pkgs, ... }:

let
  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        # TODO
      ];
    };
  };
in
{
  environment.systemPackages = [ pkgs.neovim ];

  environment.etc."xdg/nvim/sysinit.vim".text = ''
    set runtimepath^=${pluginPack}
    lua dofile('${../src/nvim/init.lua}')
  '';

  environment.variables.EDITOR = "nvim";
}
