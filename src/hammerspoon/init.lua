hs.hotkey.bind({"option"}, "return", function()
  hs.application.launchOrFocus("/Users/enno/.nix-profile/bin/alacritty")
end)

hs.loadSpoon("WindowHalfsAndThirds")

-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html#bindHotkeys
spoon.WindowHalfsAndThirds:bindHotkeys({
  left_half = {{"alt", "shift"}, "Left"},
  right_half = {{"alt", "shift"}, "Right"},
})

