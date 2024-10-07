{ ... }:

{
  # see also nixcfg git config
  programs.git = {
    signing = {
      key = "0x807BC3355DA0F069";
      signByDefault = false;
    };
  };
}
