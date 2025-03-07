{
  lib,
  pkgs,
  ...
}:

let
  # https://github.com/folke/tokyonight.nvim/blob/main/extras/process_compose/tokyonight_day.yaml
  theme = {
    style = {
      name = "tokyonight_day";
      body = {
        fgColor = "#3760bf";
        bgColor = "#d0d5e3";
        secondaryTextColor = "#6172b0";
        tertiaryTextColor = "\${fg_visual}";
        borderColor = "#a8aecb";
      };
      stat_table = {
        keyFgColor = "#8c6c3e";
        valueFgColor = "#3760bf";
        logoColor = "#8c6c3e";
      };
      proc_table = {
        fgColor = "#2e7de9";
        fgWarning = "#8c6c3e";
        fgPending = "#8990b3";
        fgCompleted = "#587539";
        fgError = "#c64343";
        headerFgColor = "#3760bf";
      };
      help = {
        fgColor = "#188092";
        keyColor = "#3760bf";
        hlColor = "#587539";
        categoryFgColor = "#006a83";
      };
      dialog = {
        fgColor = "#188092";
        bgColor = "#b4b5b9";
        contrastBgColor = "#e1e2e7";
        attentionBgColor = "#c64343";
        buttonFgColor = "#b4b5b9";
        buttonBgColor = "#c4c8da";
        buttonFocusFgColor = "#b4b5b9";
        buttonFocusBgColor = "#2e7de9";
        labelFgColor = "#8c6c3e";
        fieldFgColor = "#b4b5b9";
        fieldBgColor = "#92a6d5";
      };
    };
  };

  yamlFormat = pkgs.formats.yaml { };
  themeFile = yamlFormat.generate "theme.yaml" theme;
in
{
  home.packages = [ pkgs.process-compose ];

  # uses https://github.com/adrg/xdg
  home.file =
    let
      dir =
        if pkgs.stdenv.isDarwin then
          "Library/Application Support/process-compose"
        else
          ".config/process-compose";
    in
    {
      "${dir}/theme.yaml".source = themeFile;
    };
}
