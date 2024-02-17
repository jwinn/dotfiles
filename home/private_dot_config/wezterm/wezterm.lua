-- Pull in the wezterm API
local wezterm = require "wezterm"

-- variables
local config = {} -- The table holding the configuration
local base_dir = wezterm.config_dir
local is_i3wm = os.getenv("I3SOCK")
local show_bg = (not is_i3wm)

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

if is_i3wm then
  --config.font = wezterm.font "monospace"
  --config.font = wezterm.font "FiraCode Nerd Font"
  --config.font = wezterm.font "ComicShannsMono Nerd Font"
  config.font = wezterm.font "IntoneMono Nerd Font"
  config.font_size = 10.0
  --config.enable_tab_bar = false
  config.hide_tab_bar_if_only_one_tab = true
  config.enable_scroll_bar = false
  config.use_fancy_tab_bar = false
  config.window_background_opacity = 0.8
  --config.text_background_opacity = 0.3
  --config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
else
  config.min_scroll_bar_height = "2cell"
  config.colors = {
    scrollbar_thumb = "white",
  }
end

--
-- window background
--

if show_bg then
  -- for text, so we're going to dim it down to 10% of its normal brightness
  -- The art is a bit too bright and colorful to be useful as a backdrop
  local dimmer = { brightness = 0.1 }
  local bg_base_dir = base_dir .. "/assets/Alien_Ship_bg_vert_images"

  config.background = {
    -- This is the deepest/back-most layer. It will be rendered first
    {
      source = {
        File = bg_base_dir .. "/Backgrounds/spaceship_bg_1.png",
      },
      -- The texture tiles vertically but not horizontally.
      -- When we repeat it, mirror it so that it appears "more seamless".
      -- An alternative to this is to set `width = "100%"` and have
      -- it stretch across the display
      repeat_x = "Mirror",
      hsb = dimmer,
      -- When the viewport scrolls, move this layer 10% of the number of
      -- pixels moved by the main viewport. This makes it appear to be
      -- further behind the text.
      attachment = { Parallax = 0.1 },
    },

    -- Subsequent layers are rendered over the top of each other
    {
      source = {
        File = bg_base_dir .. "/Overlays/overlay_1_spines.png",
      },
      width = "100%",
      repeat_x = "NoRepeat",

      -- position the spins starting at the bottom, and repeating every
      -- two screens.
      vertical_align = "Bottom",
      repeat_y_size = "200%",
      hsb = dimmer,

      -- The parallax factor is higher than the background layer, so this
      -- one will appear to be closer when we scroll
      attachment = { Parallax = 0.2 },
    },

    {
      source = {
        File = bg_base_dir .. "/Overlays/overlay_2_alienball.png",
      },
      width = "100%",
      repeat_x = "NoRepeat",

      -- start at 10% of the screen and repeat every 2 screens
      vertical_offset = "10%",
      repeat_y_size = "200%",
      hsb = dimmer,
      attachment = { Parallax = 0.3 },
    },

    {
      source = {
        File = bg_base_dir .. "/Overlays/overlay_3_lobster.png",
      },
      width = "100%",
      repeat_x = "NoRepeat",

      vertical_offset = "30%",
      repeat_y_size = "200%",
      hsb = dimmer,
      attachment = { Parallax = 0.4 },
    },

    {
      source = {
        File = bg_base_dir .. "/Overlays/overlay_4_spiderlegs.png",
      },
      width = "100%",
      repeat_x = "NoRepeat",

      vertical_offset = "50%",
      repeat_y_size = "150%",
      hsb = dimmer,
      attachment = { Parallax = 0.5 },
    },
  }
end

--
-- color scheme
--

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
---@return string
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return "Dark"
end

---@param appearance string
---@return string
local function scheme_for_appearance(appearance)
  local scheme = ""

  if appearance:find "Dark" then
    --scheme = "Catppuccin"
    --scheme = "Hybrid (terminal.sexy)"
    scheme = "Jellybeans"
    --scheme = "Kanagawa (Gogh)"
    --scheme = "Kanagawabones"
    --scheme = "nord"
    --scheme = "Tokyo Night"
    --scheme = "Tokyo Night Moon"
  else
    --scheme = "Catppuccin Latte"
    scheme = "Jellybeans"
    --scheme = "nord-light"
    --scheme = "Tokyo Night Day"
  end

  return scheme
end

-- set the color scheme
config.color_scheme = scheme_for_appearance(get_appearance())

-- Update the color scheme on appearance change
wezterm.on("window-config-reloaded", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local color_scheme = scheme_for_appearance(get_appearance())

  if overrides.color_scheme ~= color_scheme then
    overrides.color_scheme = color_scheme
    window:set_config_overrides(overrides)
  end
end)

--
-- neovim zen-mode
-- https://github.com/folke/zen-mode.nvim#wezterm
--
wezterm.on("user-var-changed", function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}

  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while (number_value > 0) do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end

  window:set_config_overrides(overrides)
end)

-- and finally, return the configuration to wezterm
return config
