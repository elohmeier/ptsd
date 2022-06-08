{ config, lib, pkgs, ... }:

with lib;
let
  lwcfg = lib.importJSON ../../5pkgs/firefox-configs/librewolf.json;
  # see https://github.com/mozilla/policy-templates/blob/master/README.md
  # https://gitlab.com/librewolf-community/settings/-/blob/master/distribution/policies.json
  policies = {
    AppUpdateUrl = "https://localhost";
    DisableAppUpdate = true;
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";
    DisableSystemAddonUpdate = true;
    DisableProfileImport = false;
    DisableFirefoxStudies = true;
    DisableTelemetry = true;
    DisableFeedbackCommands = true;
    DisablePocket = true;
    DisableSetDesktopBackground = false;
    DisableDeveloperTools = false;
    DNSOverHttps = {
      Enabled = false;
      ProviderURL = "";
      Locked = false;
    };
    NoDefaultBookmarks = true;
    DisableFirefoxAccounts = true;
    DontCheckDefaultBrowser = true;
    FirefoxHome = {
      Pocket = false;
      Snippets = false;
    };
    PasswordManagerEnabled = false;
    PromptForDownloadLocation = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      SkipOnboarding = true;
    };
    # interferes with nixExtensions in wrapFirefox
    Extensions = {
      Install = [
        "https://addons.mozilla.org/firefox/downloads/file/3711209/browserpass-3.7.2-fx.xpi"

        # see https://librewolf.net/docs/faq/#why-is-librewolf-forcing-light-theme
        # "https://addons.mozilla.org/firefox/downloads/file/3904618/dark_reader-4.9.45-an+fx.xpi"

        "https://addons.mozilla.org/firefox/downloads/file/3933192/ublock_origin-1.42.4.xpi"
        "https://addons.mozilla.org/firefox/downloads/file/3904477/surfingkeys-1.0.4-fx.xpi"
      ];

      Uninstall = [
        "google@search.mozilla.org"
        "bing@search.mozilla.org"
        "amazondotcom@search.mozilla.org"
        "ebay@search.mozilla.org"
        "twitter@search.mozilla.org"
      ];
    };
    SearchEngines = {
      PreventInstalls = false;
      Remove = [
        "Google"
        "Bing"
        "Amazon.com"
        "eBay"
        "Twitter"
      ];
      Default = "DuckDuckGo";
      Add = [{
        Name = "DuckDuckGo Lite";
        Description = "Minimal, ad-free version of DuckDuckGo";
        Alias = "";
        Method = "POST";
        URLTemplate = "https://duckduckgo.com/lite/?q={searchTerms}";
        PostData = "q={searchTerms}";
        IconURL = "data:image/x-icon;base64,AAABAAIAEBAAAAEAIABoBAAAJgAAACAgAAABACAAqBAAAI4EAAAoAAAAEAAAACAAAAABACAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADVZ4Ss0Wd+PM1nf1Tpd4PM6XeDzM1nf1TRZ3481WeErAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVYD/BjRa3pRQcOP9tMLy/83q2f/m9uv//f7+//L0/P+qu+7/UHDj/TRa3pRVgP8GAAAAAAAAAAAAAAAAVYD/BjNZ372Jnuv/9/j9/8nT9v+D0pj/R71m/02+a/9Kr3z/XreM//f4/f+Jnuv/M1nfvVWA/wYAAAAAAAAAADRa3pSJnuv/4Ob6/1h25P+8yPT/ntyv/6zhuv+Fvrj/PpKY/0Cbjf9YduT/4Ob6/4me6/80Wt6UAAAAADVZ4StQcOP99/j9/1h25P8zWN7/5+z7////////////Z4Lm/zNY3v8zWd3/M1je/1h25P/3+P3/UHDj/TVZ4Ss0Wd+PrLvx/5ut7v8zWN7/Rmfh/////////////////0Jo4P8neuf/IY/s/yZ85/8yXN//m63u/6y78f80Wd+PM1nf1ert+/9ObuL/M1je/3CK5////////////9j4//8RyPv/J3vn/ytx5P8lg+n/KHjm/05u4v/p7fv/M1nf1Tpd4PP4+f3/M1je/zNY3v+bre7////////////X+P//JNL8/yDJ+v8Utvb/II/t/y9j4P8zWN7/+Pn9/zpd4PM6XeDz+Pn9/zNY3v8zWN7/w871///////////////////////k+v//T5zt/xyc7/8UtPX/L2Ph//j5/f86XeDzM1nf1ert+/9ObuL/M1je/9vi+f//////oXZf////////////oXZf/2N/5f8zWN7/M1je/05u4v/q7fv/M1nf1TRZ34+su/H/m63u/zNY3v/H0fX//////////////////////+js+/83W97/M1je/zNY3v+bre7/rLvx/zRZ3481WeErUHDj/ff4/f9YduT/X3zl//Hz/P////////////j5/f9yi+j/M1je/zNY3v9YduT/9/j9/1Bw4/01WeErAAAAADRa3pSJnuv/4Ob6/1h25P9MbOL/2N/4/73J9P9DZeD/M1je/zNY3v9YduT/4Ob6/4me6/80Wt6UAAAAAAAAAABVgP8GM1nfvYme6//3+P3/m63u/05u4v8zWN7/M1je/05u4v+bre7/9/j9/4me6/8zWd+9VYD/BgAAAAAAAAAAAAAAAFWA/wY0Wt6UUHDj/ay78f/p7fv/+Pn9//j5/f/p7fv/rLvx/1Bw4/00Wt6UVYD/BgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADVZ4Ss0Wd+PM1nf1Tpd4PM6XeDzM1nf1TRZ3481WeErAAAAAAAAAAAAAAAAAAAAAPAPAADAAwAAgAEAAIABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIABAACAAQAAwAMAAPAPAAAoAAAAIAAAAEAAAAABACAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFWA/wY2Wt9HM1nelTRY3780WN7ZM1je8zNY3vM0WN7ZNFjfvzNZ3pU2Wt9HVYD/BgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADVg3xgzWN+WNFne8TNY3v9ceuT/iJ7r/52v7/+ywPL/ssDy/52v7/+Inuv/XHrk/zNY3v80Wd7xM1jfljVg3xgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAElt/wczWOCCM1nf9Ets4v+ouPH/6e37/+vv+//a4Pj/2eD4/9zi+f/c4vn/2eD4/9rg+P/m6vv/6e37/6i48f9LbOL/M1nf9DNY4IJJbf8HAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA1YN8YM1jfxz9i4P+js/D/8fP8/6Cx7/+7x/P/5fbp/1zEd/+o4Lb/9vz4////////////3+T5/zVZ3v9Xed3/obPu//Hz/P+js/D/P2Hf/zNY38c1YN8YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAN1njLjRZ3uNTcuP/4eb6/7PB8v9IaeH/M1je/9rg+f/H69D/Rrxl/0a8Zf9NtV//RrRa/063Yv9fpqf/QqWA/0a8Zf87gqv/SGnh/7TC8v/h5vr/U3Lj/zRZ3uMzW+MtAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADVg3xg0Wd7jZ4Pm/+/x/P+Emuv/M1je/zNY3v87Xt///P3+/7rmxv9GvGX/Rrxl/0azWv9GvGX/Rrxl/0a8ZP9GvGX/Rrxl/zyIo/8zWN7/M1je/4Sa6//v8fz/Z4Lm/zRZ3uM1YN8YAAAAAAAAAAAAAAAAAAAAAAAAAABJbf8HM1jfx1Ny4//v8fz/aoXm/zNY3v8zWN7/M1je/2N/5f//////tOTB/0a8Zf9HvWb/c8mH/1W+bv9IuWj/Qqp7/0a8Zf9GvGX/PIWo/zNY3v8zWN7/M1je/2qF5v/v8fz/U3Lj/zNY38dJbf8HAAAAAAAAAAAAAAAAAAAAADNY4II/YuD/4eb6/4Sa6/8zWN7/M1je/zNY3v8zWN7/j6Ps///////W8d3/pt+1/+X26v//////8/X9/zhc3v80Wdz/PIek/0a4av85d7j/M1je/zNY3v8zWN7/M1je/4Sa6//h5vr/P2Hf/zNY4IIAAAAAAAAAAAAAAAA1YN8YM1nf9KOz8P+0wvL/M1je/zNY3v8zWN7/M1je/zNY3v+6xvP///////////////////////////+zwfL/M1je/zNY3v8zWN7/NFzY/zNZ3f8zWN7/M1je/zNY3v8zWN7/M1je/7TC8v+js/D/M1nf9DVg3xgAAAAAAAAAADNY35ZLbOL/8fP8/0hp4f8zWN7/M1je/zNY3v8zWN7/M1je/+Xq+v///////////////////////////32U6v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/SGnh//Hz/P9LbOL/M1jflgAAAABVgP8GNFne8ai48f+hsu//M1je/zNY3v8zWN7/M1je/zNY3v9DZeD/////////////////////////////////V3bj/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/obLv/6i48f80Wd7xVYD/BjZa30czWN7/6e37/1Z04/8zWN7/M1je/zNY3v8zWN7/M1je/2+J5/////////////////////////////////9RcOL/Lmfi/yKN7P8XrPP/EML5/w3K+/8Suvf/HZnu/y5n4v8zWN7/M1je/zNY3v9WdOP/6e37/zNY3v82Wt9HM1nelVx65P/j6Pr/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/mavu////////////////////////////7/z//yK79v8K0v3/Fq/0/yKN7P8iiev/IY7s/xqh8P8Suff/Dcr7/y5o4v8zWN7/M1je/zNY3v/j6Pr/XHrk/zNZ3pU0WN+/iJ7r/6++8v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v/DzvX///////////////////////////9k4/7/CtL9/xK59/8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/6++8v+Inuv/NFjfvzRY3tmdr+//mqzu/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/+7x/P///////////////////////////2Xj/v8K0v3/C9D9/xmm8f8YqfP/Gafy/yKN7P8vZuH/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/mqzu/52v7/80WN7ZM1je87LA8v+Fm+v/M1je/zNY3v8zWN7/M1je/zNY3v9La+H/////////////////////////////////+P7//3Pm/v8P0/3/CtL9/wrS/f8K0v3/CtL9/wrR/f8VsvX/JYPp/zNb3v8zWN7/M1je/zNY3v+Fm+v/ssDy/zRZ3vIzWN7zssDy/4Wb6/8zWN7/M1je/zNY3v8zWN7/M1je/3SN6P////////////////////////////////////////////b+///T9///vPP//1q/9v8WrfT/DMv8/wrS/f8K0v3/DsX6/yl25v8zWN7/M1je/4Wb6/+ywPL/M1je8zRY3tmdr+//mqzu/zNY3v8zWN7/M1je/zNY3v8zWN7/m63u////////////0LWn/7qTfv/////////////////////////////+/v//////s8Dy/zNY3v8zWt7/KXbm/x2b7v8bn/D/KnPl/zNY3v8zWN7/mqzu/52v7/80WN7ZNFjfv4me6/+vvvL/M1je/zNY3v8zWN7/M1je/zNY3v+zwPL///////////+sfWT/om5R//v59///////////////////////pHFV/8Cdiv+ruvH/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v+vvvL/iJ7r/zRY378zWd6VXHrk/+Po+v8zWN7/M1je/zNY3v8zWN7/M1je/7/K9P////////////z6+f/38u/////////////////////////////NsKH/4dDH/3uT6f8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/+Po+v9ceuT/M1nelTZa30czWN7/6e37/1Z04/8zWN7/M1je/zNY3v8zWN7/p7fw///////k1c3////////////////////////////////////////////3+f3/Q2Xg/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v9WdOP/6e37/zNY3v82Wt9HVYD/BjRZ3vGouPH/oLHv/zNY3v8zWN7/M1je/zNY3v92j+j//////+7l3//gz8b/+/j2///////////////////////p3db/2MK2/6mz5P8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/6Gy7/+ouPH/NFne8VWA/wYAAAAAM1jflkts4v/x8/z/SGnh/zNY3v8zWN7/M1je/zNY3v/U3Pj////////////////////////////////////////////s7/z/RWfg/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v9IaeH/8fP8/0ts4v8zWN+WAAAAAAAAAAA1YN8YM1nf9KOz8P+zwfL/M1je/zNY3v8zWN7/M1je/0Fj4P/DzvX/////////////////////////////////8PP8/2WB5v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/7TC8v+js/D/M1nf9DVg3xgAAAAAAAAAAAAAAAAzWOCCP2Lg/+Hm+v+Emuv/M1je/zNY3v8zWN7/R2jh/0do4f97k+n/1dz4////////////7/L8/4Oa6/9CZOD/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v+Fm+v/4eb6/z9i4P8zWOCCAAAAAAAAAAAAAAAAAAAAAElt/wczWN/HU3Lj/+/x/P9qheb/M1je/zNY3v+Xqe7/7vH8/////////////////87X9/9TcuP/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/aoXm/+/x/P9TcuP/M1jfx0lt/wcAAAAAAAAAAAAAAAAAAAAAAAAAADVg3xg0Wd7jZ4Lm/+/x/P+Emuv/M1je/2J+5f+puPH/rrzx/5Kl7f9PbuL/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/4Sa6//v8fz/Z4Lm/zRZ3uM1YN8YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADdZ4y40Wd7jU3Lj/+Hm+v+0wvL/SGnh/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/0hp4f+0wvL/4eb6/1Ny4/80Wd7jM1vjLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADVg3xgzWN/HP2Lg/6Oz8P/x8/z/obLv/1Z04/8zWN7/M1je/zNY3v8zWN7/M1je/zNY3v8zWN7/M1je/1Z04/+hsu//8fP8/6Oz8P8/Yd//M1jfxzVg3xgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAElt/wczWOCCM1nf9Ets4v+ouPH/6e37/+Po+v+vvvL/mqzu/4Wb6/+Fm+v/mqzu/6++8v/j6Pr/6e37/6i48f9LbOL/M1nf9DNY4IJJbf8HAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA1YN8YM1jfljRZ3vEzWN7/XHrk/4ie6/+dr+//ssDy/7LA8v+dr+//iJ7r/1x65P8zWN7/NFne8TNY35Y1YN8YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVYD/BjZa30czWd6VNFjfvzRY3tkzWN7zM1je8zRY3tk0WN+/M1nelTZa30dVgP8GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/AA///AAD//AAAP/gAAB/wAAAP4AAAB8AAAAPAAAADgAAAAYAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAABgAAAAcAAAAPAAAAD4AAAB/AAAA/4AAAf/AAAP/8AAP//wAP/";
      }];
    };
  };
in
{
  programs.firefox = {
    enable = true;

    package =
      if
        pkgs.stdenv.isDarwin
      then
        pkgs.firefox-bin.override { inherit policies; }
      else
        pkgs.wrapFirefox pkgs.firefox-ungrapped { applicationName = "firefox"; forceWayland = true; extraPolicies = policies; };

    profiles.privacy = {
      id = 0; # 0=default
      settings = lwcfg;
    };

    profiles.office = {
      id = 1;

      settings = lwcfg // {
        # keep login info
        "privacy.resistFingerprinting" = false;
        "privacy.resistFingerprinting.letterboxing" = false;
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "network.cookie.lifetimePolicy" = 0;

        # fix video conferencing
        "webgl.disabled" = false;
        "media.peerconnection.ice.no_host" = false;
        "media.autoplay.blocking_policy" = 0;
        "media.autoplay.default" = 0;
      };
    };

    profiles.burp = {
      id = 2;

      settings = lwcfg // {
        "network.proxy.http" = "127.0.0.1";
        "network.proxy.http_port" = 8080;
        "network.proxy.type" = 1;
        "network.proxy.share_proxy_settings" = true;
      };
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "firefox-privacy" "firefox -P privacy")
    (pkgs.writeShellScriptBin "firefox-office" "firefox -P office")
    (pkgs.writeShellScriptBin "firefox-burp" "firefox -P burp")
  ];

  # restore ublock backup
  home.file =
    let
      dir = if pkgs.stdenv.isDarwin then "Library/Application Support/Mozilla/ManagedStorage" else ".mozilla/managed-storage";
      # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin
      ublockJson = pkgs.writeText "ublock.json" (builtins.toJSON {
        name = "uBlock0@raymondhill.net";
        description = "ignored";
        type = "storage";
        # backup conversion similar to http://raymondhill.net/ublock/adminSetting.html
        data.adminSettings = builtins.readFile (pkgs.runCommand "ublock-config-backup" { preferLocalBuild = true; } "cat ${../../5pkgs/firefox-configs/my-ublock-backup.txt} | ${pkgs.jq}/bin/jq -c > $out");
      });
    in
    {
      "${dir}/uBlock0@raymondhill.net.json".source = ublockJson;
    };
}
