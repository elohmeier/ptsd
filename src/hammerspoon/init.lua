hs.hotkey.bind({"cmd", "shift"}, "return", function()
    -- hs.application.launchOrFocus("/Users/enno/.nix-profile/bin/alacritty") -- focuses old instances
    -- hs.execute("/Users/enno/.nix-profile/bin/alacritty") -- blocking
    io.popen("/Users/enno/.nix-profile/bin/alacritty")
end)


-- meh key:
hs.hotkey.bind({"control", "shift", "alt"}, "t", function()
  hs.application.launchOrFocusByBundleID("com.googlecode.iterm2")
end)

hs.hotkey.bind({"control", "shift", "alt"}, "f", function()
  app = hs.application.find("org.mozilla.firefox")
  if app and app:isRunning() then
    app:activate()
  else
    hs.application.launchOrFocusByBundleID("org.mozilla.firefox")  -- always opens new window
  end

end)


