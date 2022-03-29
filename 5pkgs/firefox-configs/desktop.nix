{ wrapFirefox
, firefox-unwrapped
, ptsd-firefoxAddons
, extraExtensions ? [ ]
, writeText
, runCommand
, jq
, ...
}:

let
  nixExtensions = with ptsd-firefoxAddons; [
    # auto-tab-discard
    browserpass
    # cookie-autodelete
    # react-devtools
    # read-aloud
    surfingkeys
    ublock-origin
  ] ++ extraExtensions;

  # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin
  ublockJson = writeText "ublock.json" (builtins.toJSON {
    name = "uBlock0@raymondhill.net";
    description = "ignored";
    type = "storage";
    # backup conversion similar to http://raymondhill.net/ublock/adminSetting.html
    data.adminSettings = builtins.readFile (runCommand "ublock-config-backup" { preferLocalBuild = true; } "cat ${./my-ublock-backup.txt} | ${jq}/bin/jq -c > $out");
  });
  ublockConfig = runCommand "ublock-managed-config" { preferLocalBuild = true; } ''
    mkdir -p $out/lib/mozilla/managed-storage
    cp ${ublockJson} $out/lib/mozilla/managed-storage/uBlock0@raymondhill.net.json
  '';
in
wrapFirefox firefox-unwrapped
{
  applicationName = "firefox";
  managedStorage = [ ublockConfig ];

  #inherit nixExtensions;

  forceWayland = true;

  # see https://github.com/mozilla/policy-templates/blob/master/README.md
  # https://gitlab.com/librewolf-community/settings/-/blob/master/distribution/policies.json
  extraPolicies = {
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

        "https://addons.cdn.mozilla.net/user-media/addons/607454/ublock_origin-1.41.8-an+fx.xpi"
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

  # adapted from https://gitlab.com/librewolf-community/settings/-/blob/0822d491d2b377b5cd7f0429cee5aa916538fa50/librewolf.cfg
  extraPrefs = ''
    // Show more ssl cert infos
    lockPref("security.identityblock.show_extended_validation", true);
    

    /** INDEX
     * the file is organized in categories, and each one has a number of sections:
     * 
     * PRIVACY [ISOLATION, SANITIZING, CACHE AND STORAGE, HISTORY AND SESSION RESTORE, QUERY STRIPPING]
     * NETWORKING [HTTPS, REFERERS, WEBRTC, PROXY, DNS, PREFETCHING AND SPECULATIVE CONNECTIONS, OFFLINE]
     * FINGERPRINTING [RFP, WEBGL]
     * SECURITY [SITE ISOLATION, CERTIFICATES, TLS/SSL, PERMISSIONS, FONTS, SAFE BROWSING, OTHERS]
     * REGION [LOCATION, LANGUAGE]
     * BEHAVIOR [DRM, SEARCH AND URLBAR, DOWNLOADS, AUTOPLAY, POP-UPS AND WINDOWS, MOUSE]
     * EXTENSIONS [USER INSTALLED, SYSTEM, EXTENSION FIREWALL]
     * BUILT-IN FEATURES [UPDATER, SYNC, LOCKWISE, CONTAINERS, DEVTOOLS, OTHERS]
     * UI [BRANDING, HANDLERS, FIRST LAUNCH, NEW TAB PAGE, ABOUT, RECOMMENDED]
     * TELEMETRY
     */



    /** [CATEGORY] PRIVACY */

    /** [SECTION] ISOLATION
     * default to strict mode, which includes:
     * 1. dFPI for both normal and private windows
     * 2. strict blocking lists for trackers
     * 3. shims to avoid breakage caused by blocking lists
     * 4. stricter policies for xorigin referrers
     * 5. dFPI specific cookie cleaning mechanism
     * 
     * the desired category must be set with pref() otherwise it won't stick.
     * the UI that allows to change mode manually is hidden.
     */
    pref("browser.contentblocking.category", "strict");
    defaultPref("network.cookie.cookieBehavior", 5); // enforce dFPI
    defaultPref("privacy.partition.serviceWorkers", true); // isolate service workers

    /** [SECTION] SANITIZING */
    defaultPref("network.cookie.lifetimePolicy", 2); // keep cookies until end of the session, then clear
    // make third party and http cookies session-only
    defaultPref("network.cookie.thirdparty.sessionOnly", true);
    defaultPref("network.cookie.thirdparty.nonsecureSessionOnly", true);
    /**
     * this way of sanitizing cookies would override the exceptions set by the users and just delete everything,
     * we disable it but cookies and site data are still cleared per session unless exceptions are set.
     * all the cleaning prefs true by default except for siteSetting and offlineApps, which is what we want.
     */
    defaultPref("privacy.clearOnShutdown.cookies", false);
    defaultPref("privacy.sanitize.sanitizeOnShutdown", true);
    defaultPref("privacy.sanitize.timeSpan", 0);

    /** [SECTION] CACHE AND STORAGE */
    defaultPref("browser.cache.disk.enable", false); // disable disk cache
    /** prevent media cache from being written to disk in pb, but increase max cache size to avoid playback issues */
    defaultPref("browser.privatebrowsing.forceMediaMemoryCache", true);
    defaultPref("media.memory_cache_max_size", 65536);
    // disable favicons in profile folder and page thumbnail capturing
    defaultPref("browser.shell.shortcutFavicons", false);
    defaultPref("browser.pagethumbnails.capturing_disabled", true);
    defaultPref("browser.helperApps.deleteTempFileOnExit", true); // delete temporary files opened with external apps

    /** [SECTION] HISTORY AND SESSION RESTORE
     * since we hide the UI for modes other than custom we want to reset it for
     * everyone. same thing for always on PB mode.
     */
    pref("privacy.history.custom", true);
    pref("browser.privatebrowsing.autostart", false);
    defaultPref("browser.formfill.enable", false); // disable form history
    defaultPref("browser.sessionstore.privacy_level", 2); // prevent websites from storing session data like cookies and forms
    defaultPref("browser.sessionstore.interval", 60000); // increase time between session saves

    /** [SECTION] QUERY STRIPPING
     * enable query stripping and set the strip list.
     * currently we use the same one that brave uses:
     * https://github.com/brave/brave-core/blob/f337a47cf84211807035581a9f609853752a32fb/browser/net/brave_site_hacks_network_delegate_helper.cc#L29
     */
    defaultPref("privacy.query_stripping.enabled", true);
    defaultPref("privacy.query_stripping.strip_list", "__hsfp __hssc __hstc __s _hsenc _openstat dclid fbclid gbraid gclid hsCtaTracking igshid mc_eid ml_subscriber ml_subscriber_hash msclkid oly_anon_id oly_enc_id rb_clickid s_cid twclid vero_conv vero_id wbraid wickedid yclid");
    /**
     * librewolf specific pref that allows to include the query stripping lists in uBO by default.
     * the asset file is fetched every 7 days.
     */
    defaultPref("librewolf.uBO.assetsBootstrapLocation", "https://gitlab.com/librewolf-community/browser/source/-/raw/main/assets/uBOAssets.json");



    /** [CATEGORY] NETWORKING */

    /** [SECTION] HTTPS */
    defaultPref("dom.security.https_only_mode", true); // only allow https in all windows, including private browsing
    defaultPref("network.auth.subresource-http-auth-allow", 1); // block HTTP authentication credential dialogs
    defaultPref("security.mixed_content.block_display_content", true); // block insecure passive content

    /** [SECTION] REFERERS
     * to enhance privacy but keep a certain level of usability we trim cross-origin
     * referers, instead of completely avoid sending them.
     * as a general rule, the behavior of referes which are not cross-origin should not
     * be changed.
     */
    defaultPref("network.http.referer.XOriginPolicy", 0); // default, might be worth changing to 2 to stop sending them completely
    defaultPref("network.http.referer.XOriginTrimmingPolicy", 2); // trim referer to only send scheme, host and port

    /** [SECTION] WEBRTC
     * there's no point in disabling webrtc as mDNS protects the private IP on linux, osx and win10+.
     * with the below preference we protect the value even in trusted environments and for win7/8 users,
     * although this will likely cause breakage.
     */
    defaultPref("media.peerconnection.ice.no_host", true); // don't use any private IPs for ICE candidate
    defaultPref("media.peerconnection.ice.default_address_only", true); // use a single interface for ICE candidates, the vpn one when a vpn is used

    /** [SECTION] PROXY */
    defaultPref("network.gio.supported-protocols", ""); // disable gio as it could bypass proxy
    defaultPref("network.file.disable_unc_paths", true); // hidden, disable using uniform naming convention to prevent proxy bypass
    defaultPref("network.proxy.socks_remote_dns", true); // forces dns query through the proxy when using one
    defaultPref("media.peerconnection.ice.proxy_only_if_behind_proxy", true); // force webrtc inside proxy when one is used

    /** [SECTION] DNS */
    defaultPref("network.trr.confirmationNS", "skip"); // skip undesired doh test connection
    defaultPref("network.dns.disablePrefetch", true); // disable dns prefetching
    /**
     * librewolf doesn't use DoH, but it can be enabled with the following prefs:
     * pref("network.trr.mode", 2);
     * pref("network.trr.uri", "https://dns.quad9.net/dns-query");
     * 
     * the possible modes are:
     * 0 = default
     * 1 = browser picks faster
     * 2 = DoH with system dns fallback
     * 3 = DoH without fallback
     * 5 = DoH is off, default currently
     */

    /** [SECTION] PREFETCHING AND SPECULATIVE CONNECTIONS
     * disable prefecthing for different things such as links, bookmarks and predictors.
     */
    lockPref("network.predictor.enabled", false);
    lockPref("network.prefetch-next", false);
    lockPref("network.http.speculative-parallel-limit", 0);
    defaultPref("browser.places.speculativeConnect.enabled", false);
    // disable speculative connections and domain guessing from the urlbar
    defaultPref("browser.urlbar.dnsResolveSingleWordsAfterSearch", 0);
    defaultPref("browser.urlbar.speculativeConnect.enabled", false);
    lockPref("browser.fixup.alternate.enabled", false);

    /** [SECTION] OFFLINE
     * let users set the browser as offline, without the browser trying to guess.
     */
    defaultPref("network.manage-offline-status", false);



    /** [CATEGORY] FINGERPRINTING */

    /** [SECTION] RFP
     * librewolf should stick to RFP for fingerprinting. we should not set prefs that interfere with it
     * and disabling API for no good reason will be counter productive, so it should also be avoided.  
     */
    defaultPref("privacy.resistFingerprinting", true);
    // rfp related settings
    defaultPref("privacy.resistFingerprinting.block_mozAddonManager", true); // prevents rfp from breaking AMO
    defaultPref("browser.startup.blankWindow", false); // if set to true it breaks RFP windows resizing
    defaultPref("browser.display.use_system_colors", false); // default but enforced due to RFP
    /**
     * increase the size of new RFP windows for better usability, while still using a rounded value.
     * if the screen resolution is lower it will stretch to the biggest possible rounded value.
     * also, expose hidden letterboxing pref but do not enable it for now.
     */
    defaultPref("privacy.window.maxInnerWidth", 1600);
    defaultPref("privacy.window.maxInnerHeight", 900);
    defaultPref("privacy.resistFingerprinting.letterboxing", true);

    /** [SECTION] WEBGL */
    defaultPref("webgl.disabled", true);



    /** [CATEGORY] SECURITY */

    /** [SECTION] SITE ISOLATION
     * https://wiki.mozilla.org/Project_Fission
     * this has been rolled out and is now a default on most FF releases
     */
    defaultPref("fission.autostart", true);

    /** [SECTION] CERTIFICATES */
    defaultPref("security.cert_pinning.enforcement_level", 2); // enable strict public key pinning, might cause issues with AVs
    defaultPref("security.pki.sha1_enforcement_level", 1); // disable sha-1 certificates
    /**
     * enable safe negotiation and show warning when it is not supported. might cause breakage.
     */
    defaultPref("security.ssl.require_safe_negotiation", true);
    defaultPref("security.ssl.treat_unsafe_negotiation_as_broken", true);
    /**
     * our strategy with revocation is to perform all possible checks with CRL, but when a cert
     * cannot be checked with it we use OCSP stapled with hard-fail, to still keep privacy and
     * increase security.
     * switching to crlite mode 3 (v99+) would allow us to detect false positive with OCSP.
     */
    defaultPref("security.remote_settings.crlite_filters.enabled", true);
    defaultPref("security.pki.crlite_mode", 2); // mode 2 means enforce CRL checks
    defaultPref("security.OCSP.enabled", 1); // default
    defaultPref("security.OCSP.require", true); // set to hard-fail

    /** [SECTION] TLS/SSL */
    lockPref("security.tls.enable_0rtt_data", false); // disable 0 RTT to improve tls 1.3 security
    pref("security.tls.version.enable-deprecated", false); // make TLS downgrades session only by enforcing it with pref()
    // show relevant and advanced issues on warnings and error screens
    defaultPref("browser.ssl_override_behavior", 1);
    defaultPref("browser.xul.error_pages.expert_bad_cert", true);

    /** [SECTION] PERMISSIONS */
    lockPref("permissions.delegation.enabled", false); // force permission request to show real origin
    lockPref("permissions.manager.defaultsUrl", ""); // revoke special permissions for some mozilla domains

    /** [SECTION] FONTS */
    defaultPref("gfx.font_rendering.opentype_svg.enabled", false); // disale svg opentype fonts

    /** [SECTION] SAFE BROWSING
     * disable safe browsing, including the fetch of updates. reverting the 7 prefs below
     * allows to perform local checks and to fetch updated lists from google.
     */
    defaultPref("browser.safebrowsing.malware.enabled", false);
    defaultPref("browser.safebrowsing.phishing.enabled", false);
    defaultPref("browser.safebrowsing.blockedURIs.enabled", false);
    defaultPref("browser.safebrowsing.provider.google4.gethashURL", "");
    defaultPref("browser.safebrowsing.provider.google4.updateURL", "");
    defaultPref("browser.safebrowsing.provider.google.gethashURL", "");
    defaultPref("browser.safebrowsing.provider.google.updateURL", "");
    /**
     * disable safe browsing checks on downloads, both local and remote. the locked prefs
     * control remote checks, while the first one is for local checks only.
     */
    defaultPref("browser.safebrowsing.downloads.enabled", false);
    lockPref("browser.safebrowsing.downloads.remote.enabled", false);
    lockPref("browser.safebrowsing.downloads.remote.url", "");
    lockPref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
    lockPref("browser.safebrowsing.downloads.remote.block_uncommon", false);
    // other safe browsing options, all default but enforce
    lockPref("browser.safebrowsing.passwords.enabled", false);
    lockPref("browser.safebrowsing.provider.google4.dataSharing.enabled", false);
    lockPref("browser.safebrowsing.provider.google4.dataSharingURL", "");

    /** [SECTION] OTHERS */
    lockPref("security.csp.enable", true); // enforce csp, default
    defaultPref("network.IDN_show_punycode", true); // use punycode in idn to prevent spoofing
    defaultPref("pdfjs.enableScripting", false); // disable js scripting in the built-in pdf reader



    /** [CATEGORY] REGION */

    /** [SECTION] LOCATION
     * replace google with mozilla as the default geolocation provide and prevent use of OS location services
     */
    defaultPref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");
    lockPref("geo.provider.ms-windows-location", false); // [WINDOWS]
    lockPref("geo.provider.use_corelocation", false); // [MAC]
    lockPref("geo.provider.use_gpsd", false); // [LINUX]

    /** [SECTION] LANGUAGE
     * show language as en-US for all users, regardless of their OS language and browser language.
     * both prefs must use pref() and not defaultPref to work.
     */
    pref("javascript.use_us_english_locale", true);
    pref("intl.accept_languages", "en-US, en");
    // disable region specific updates from mozilla
    lockPref("browser.region.network.url", "");
    lockPref("browser.region.update.enabled", false);



    /** [CATEGORY] BEHAVIOR */

    /** [SECTION] DRM */
    defaultPref("media.eme.enabled", false); // master switch for drm content
    defaultPref("media.gmp-manager.url", "data:text/plain,"); // prevent checks for plugin updates when drm is disabled
    // disable the widevine and the openh264 plugins
    defaultPref("media.gmp-provider.enabled", false);
    defaultPref("media.gmp-gmpopenh264.enabled", false);

    /** [SECTION] SEARCH AND URLBAR
     * disable search suggestion by default and do not update opensearch engines. urls should also be
     * displayed in full instead of trimming them.
     */
    defaultPref("browser.urlbar.suggest.searches", false);
    defaultPref("browser.search.suggest.enabled", false);
    defaultPref("browser.search.update", false);
    defaultPref("browser.urlbar.trimURLs", false);
    /**
     * quicksuggest is a feature of firefox that shows sponsored suggestions. we disable it in full
     * but the list could and should be trimmed at some point. the scenario controls the opt-in, while
     * the second pref disables the feature and hides it from the ui.
     */
    lockPref("browser.urlbar.quicksuggest.scenario", "history");
    lockPref("browser.urlbar.quicksuggest.enabled", false);
    lockPref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
    lockPref("browser.urlbar.suggest.quicksuggest.sponsored", false);
    lockPref("browser.urlbar.quicksuggest.dataCollection.enabled", false); // default

    /** [SECTION] DOWNLOADS
     * user interaction should always be required for downloads, as a way to enhance security by asking
     * the user to specific a certain save location. 
     */
    defaultPref("browser.download.useDownloadDir", false);
    defaultPref("browser.download.autohideButton", false); // do not hide download button automatically
    defaultPref("browser.download.manager.addToRecentDocs", false); // do not add downloads to recents
    defaultPref("browser.download.alwaysOpenPanel", false); // do not expand toolbar menu for every download, we already have enough interaction

    /** [SECTION] AUTOPLAY
     * block autoplay unless element is clicked, and apply the policy to all elements
     * including muted ones.
     */
    defaultPref("media.autoplay.blocking_policy", 2);
    defaultPref("media.autoplay.default", 5);

    /** [SECTION] POP-UPS AND WINDOWS
     * disable annoyin pop-ups and limit events that can trigger them.
     */
    defaultPref("dom.disable_beforeunload", true); // disable "confirm you want to leave" pop-ups
    defaultPref("dom.disable_open_during_load", true); // block pop-ups windows
    defaultPref("dom.popup_allowed_events", "click dblclick mousedown pointerdown");
    /**
     * prevent scripts from resizing existing windows and opening new ones, by forcing them into
     * new tabs that can't be resized as well.
     */
    defaultPref("dom.disable_window_move_resize", true);
    defaultPref("browser.link.open_newwindow", 3);
    defaultPref("browser.link.open_newwindow.restriction", 0);

    /** [SECTION] MOUSE */
    defaultPref("middlemouse.contentLoadURL", false); // prevent mouse middle click from opening links



    /** [CATEGORY] EXTENSIONS */

    /** [SECTION] USER INSTALLED
     * extensions are allowed to operate on restricted domains, while their scope
     * is set to profile+applications (https://mike.kaply.com/2012/02/21/understanding-add-on-scopes/).
     * an installation prompt should always be displayed.
     */
    defaultPref("extensions.webextensions.restrictedDomains", "");
    defaultPref("extensions.enabledScopes", 5); // hidden
    defaultPref("extensions.postDownloadThirdPartyPrompt", false);

    /** [SECTION] SYSTEM
     * built-in extension are not allowed to auto-update. additionally the reporter extension
     * of webcompat is disabled. urls are stripped for defense in depth.
     */
    defaultPref("extensions.systemAddon.update.enabled", false);
    defaultPref("extensions.systemAddon.update.url", "");
    lockPref("extensions.webcompat-reporter.enabled", false);
    lockPref("extensions.webcompat-reporter.newIssueEndpoint", "");

    /** [SECTION] EXTENSION FIREWALL
     * the firewall can be enabled with the below prefs, but it is not a sane default:
     * defaultPref("extensions.webextensions.base-content-security-policy", "default-src 'none'; script-src 'none'; object-src 'none';");
     * defaultPref("extensions.webextensions.base-content-security-policy.v3", "default-src 'none'; script-src 'none'; object-src 'none';");
     */



    /** [CATEGORY] BUILT-IN FEATURES */

    /** [SECTION] UPDATER
     * since we do not bake auto-updates in the browser it doesn't make sense at the moment.
     */
    lockPref("app.update.auto", false);

    /** [SECTION] SYNC
     * this functionality is disabled by default but it can be activated in one click.
     * this pref fully controls the feature, including its ui.
     */
    defaultPref("identity.fxaccounts.enabled", false);

    /** [SECTION] LOCKWISE
     * disable the default password manager built into the browser, including its autofill
     * capabilities and formless login capture.
     */
    defaultPref("signon.rememberSignons", false);
    defaultPref("signon.autofillForms", false);
    defaultPref("extensions.formautofill.available", "off");
    defaultPref("extensions.formautofill.addresses.enabled", false);
    defaultPref("extensions.formautofill.creditCards.enabled", false);
    defaultPref("extensions.formautofill.creditCards.available", false);
    defaultPref("extensions.formautofill.heuristics.enabled", false);
    defaultPref("signon.formlessCapture.enabled", false);

    /** [SECTION] CONTAINERS
     * enable containers and show the settings to control them in the stock ui
     */
    defaultPref("privacy.userContext.enabled", true);
    defaultPref("privacy.userContext.ui.enabled", true);

    /** [SECTION] DEVTOOLS
     * disable chrome and remote debugging.
     */
    defaultPref("devtools.chrome.enabled", false);
    defaultPref("devtools.debugger.remote-enabled", false);
    defaultPref("devtools.remote.adb.extensionURL", "");
    defaultPref("devtools.selfxss.count", 0); // required for devtools console to work

    /** [SECTION] OTHERS */
    lockPref("browser.translation.engine", ""); // remove translation engine
    defaultPref("accessibility.force_disabled", 1); // block accessibility services
    defaultPref("webchannel.allowObject.urlWhitelist", ""); // do not receive objects through webchannels



    /** [CATEGORY] UI */

    /** [SECTION] BRANDING
     * set librewolf support and releases urls in the UI, so that users land in the proper places.
     */
    defaultPref("app.support.baseURL", "https://librewolf.net/docs/faq/#");
    defaultPref("browser.search.searchEnginesURL", "https://librewolf.net/docs/faq/#how-do-i-add-a-search-engine");
    defaultPref("browser.geolocation.warning.infoURL", "https://librewolf.net/docs/faq/#how-do-i-enable-location-aware-browsing");
    defaultPref("app.feedback.baseURL", "https://librewolf.net/#questions");
    defaultPref("app.releaseNotesURL", "https://gitlab.com/librewolf-community/browser");
    defaultPref("app.releaseNotesURL.aboutDialog", "https://gitlab.com/librewolf-community/browser");
    defaultPref("app.update.url.details", "https://gitlab.com/librewolf-community/browser");
    defaultPref("app.update.url.manual", "https://gitlab.com/librewolf-community/browser");

    /** [SECTION] FIRST LAUNCH
     * disable what's new and ui tour on first start and updates. the browser
     * should also not stress user about being the default one.
     */
    defaultPref("browser.startup.homepage_override.mstone", "ignore");
    defaultPref("startup.homepage_override_url", "about:blank");
    defaultPref("startup.homepage_welcome_url", "about:blank");
    defaultPref("startup.homepage_welcome_url.additional", "");
    lockPref("browser.messaging-system.whatsNewPanel.enabled", false);
    lockPref("browser.uitour.enabled", false);
    lockPref("browser.uitour.url", "");
    defaultPref("browser.shell.checkDefaultBrowser", false);

    /** [SECTION] NEW TAB PAGE
     * we want the new tab page to display nothing but the search bar without anything distracting.
     */
    defaultPref("browser.newtab.preload", false);
    defaultPref("browser.newtabpage.activity-stream.section.highlights.includeDownloads", false);
    defaultPref("browser.newtabpage.activity-stream.section.highlights.includeVisited", false);
    defaultPref("browser.newtabpage.activity-stream.feeds.topsites", false);
    // hide pocket and sponsored content, from new tab page and search bar
    lockPref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
    lockPref("browser.newtabpage.activity-stream.feeds.system.topstories", false);
    lockPref("browser.newtabpage.activity-stream.feeds.telemetry", false);
    lockPref("browser.newtabpage.activity-stream.feeds.section.topstories.options", "{\"hidden\":true}"); // hide buggy pocket section from about:preferences#home
    lockPref("browser.newtabpage.activity-stream.showSponsored", false);
    lockPref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
    lockPref("browser.newtabpage.activity-stream.telemetry", false);
    lockPref("browser.newtabpage.activity-stream.default.sites", "");
    lockPref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false);
    lockPref("browser.newtabpage.activity-stream.discoverystream.enabled", false);
    lockPref("browser.newtabpage.activity-stream.feeds.snippets", false); // default

    /** [SECTION] ABOUT
     * remove annoying ui elements from the about pages, including about:protections
     */
    defaultPref("browser.contentblocking.report.lockwise.enabled", false);
    defaultPref("browser.contentblocking.report.monitor.enabled", false);
    lockPref("browser.contentblocking.report.hide_vpn_banner", true);
    lockPref("browser.contentblocking.report.vpn.enabled", false);
    lockPref("browser.contentblocking.report.show_mobile_app", false);
    // ...about:addons recommendations sections and more
    defaultPref("extensions.htmlaboutaddons.recommendations.enabled", false);
    defaultPref("extensions.getAddons.showPane", false);
    defaultPref("extensions.getAddons.cache.enabled", false); // disable fetching of extension metadata
    defaultPref("lightweightThemes.getMoreURL", ""); // disable button to get more themes
    // ...about:preferences#home
    defaultPref("browser.topsites.useRemoteSetting", false); // hide sponsored shortcuts button
    // ...and about:config
    defaultPref("browser.aboutConfig.showWarning", false);
    // hide about:preferences#moreFromMozilla
    defaultPref("browser.preferences.moreFromMozilla", false);

    /** [SECTION] RECOMMENDED
     * disable all "recommend as you browse" activity.
     */
    lockPref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
    lockPref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);



    /** [CATEGORY] TELEMETRY
     * telemetry is already disabled elsewhere and most of the stuff in here is just for redundancy.
     */
    lockPref("toolkit.telemetry.unified", false); // master switch
    lockPref("toolkit.telemetry.enabled", false);  // master switch
    lockPref("toolkit.telemetry.server", "data:,");
    lockPref("toolkit.telemetry.archive.enabled", false);
    lockPref("toolkit.telemetry.newProfilePing.enabled", false);
    lockPref("toolkit.telemetry.updatePing.enabled", false);
    lockPref("toolkit.telemetry.firstShutdownPing.enabled", false);
    lockPref("toolkit.telemetry.shutdownPingSender.enabled", false);
    lockPref("toolkit.telemetry.shutdownPingSender.enabledFirstSession", false); // default
    lockPref("toolkit.telemetry.bhrPing.enabled", false);
    lockPref("toolkit.telemetry.reportingpolicy.firstRun", false); // default
    lockPref("toolkit.telemetry.cachedClientID", "");
    lockPref("toolkit.telemetry.previousBuildID", "");
    lockPref("toolkit.telemetry.server_owner", "");
    lockPref("toolkit.coverage.opt-out", true); // hidden
    lockPref("toolkit.telemetry.coverage.opt-out", true); // hidden
    lockPref("toolkit.coverage.enabled", false);
    lockPref("toolkit.coverage.endpoint.base", "");
    lockPref("toolkit.crashreporter.infoURL", "");
    lockPref("datareporting.healthreport.uploadEnabled", false);
    lockPref("datareporting.policy.dataSubmissionEnabled", false);
    lockPref("security.protectionspopup.recordEventTelemetry", false);
    lockPref("browser.ping-centre.telemetry", false);
    // opt-out of normandy and studies
    lockPref("app.normandy.enabled", false);
    lockPref("app.normandy.api_url", "");
    lockPref("app.shield.optoutstudies.enabled", false);
    // disable personalized extension recommendations
    lockPref("browser.discovery.enabled", false);
    lockPref("browser.discovery.containers.enabled", false);
    lockPref("browser.discovery.sites", "");
    // disable crash report
    lockPref("browser.tabs.crashReporting.sendReport", false);
    lockPref("breakpad.reportURL", "");
    // disable connectivity checks
    lockPref("network.connectivity-service.enabled", false);
    // disable captive portal
    lockPref("network.captive-portal-service.enabled", false);
    lockPref("captivedetect.canonicalURL", "");
    // prevent sending server side analytics
    lockPref("beacon.enabled", false);


  '';
}
