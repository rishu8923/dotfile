local theme_file = vim.fn.expand("~/.cache/hellwal/last-theme")

-- Maps hellwal theme name → { colorscheme, background, [extra setup fn] }
local theme_map = {
  -- Dark themes
  ["catppuccin"]            = { cs = "catppuccin",          bg = "dark" },
  ["dracula"]               = { cs = "dracula",              bg = "dark" },
  ["everforest-medium-dark"]= { cs = "everforest",           bg = "dark",
    setup = function() vim.g.everforest_background = "medium" end },
  ["everforest-hard-dark"]  = { cs = "everforest",           bg = "dark",
    setup = function() vim.g.everforest_background = "hard" end },
  ["github"]                = { cs = "github_dark_default",  bg = "dark" },
  ["gruvbox"]               = { cs = "gruvbox",              bg = "dark" },
  ["gruvbox-material"]      = { cs = "gruvbox-material",     bg = "dark",
    setup = function()
      vim.g.gruvbox_material_background       = "hard"
      vim.g.gruvbox_material_palette          = "material"
      vim.g.gruvbox_material_foreground       = "material"
      vim.g.gruvbox_material_enable_italic    = 1
      vim.g.gruvbox_material_better_performance = 1
    end },
  ["kanagawa"]              = { cs = "kanagawa",             bg = "dark" },
  ["nord"]                  = { cs = "nord",                 bg = "dark" },
  ["onedark"]               = { cs = "onedark",              bg = "dark" },
  ["poimandres"]            = { cs = "poimandres",           bg = "dark" },
  ["tokyo-night"]           = { cs = "tokyonight",           bg = "dark" },
  ["vague"]                 = { cs = "vague",                bg = "dark" },
  ["zenbones"]              = { cs = "zenbones",             bg = "dark" },

  -- Light themes
  ["catppuccin-latte"]      = { cs = "catppuccin-latte",     bg = "light" },
  ["gruvbox-light"]         = { cs = "gruvbox",              bg = "light" },
  ["kanagawa-lotus"]        = { cs = "kanagawa-lotus",       bg = "light" },
  ["zenbones-light"]        = { cs = "zenbones",             bg = "light" },
}

local function apply_theme()
  local f = io.open(theme_file, "r")
  if not f then return end
  local theme = f:read("*l")
  f:close()
  if not theme or theme == "" then return end

  local entry = theme_map[theme]
  if not entry then return end

  vim.o.background = entry.bg
  if entry.setup then entry.setup() end
  vim.cmd.colorscheme(entry.cs)
end

apply_theme()

-- Live reload: watch ~/.cache/hellwal/last-theme for changes
local function watch_theme_file()
  local handle = vim.uv.new_fs_event()
  if not handle then return end
  handle:start(theme_file, {}, function(err, _, _)
    if err then return end
    vim.schedule(apply_theme)
  end)
end

watch_theme_file()
