data:extend{{
    type = "bool-setting",
    name = "override-space-connection",
    setting_type = "startup",
    default_value = false,
    hidden =true,
    forced_value = false,
    order = "za",
  },
  {
    type = "bool-setting",
    name = "disable-muluna-music",
    setting_type = "startup",
    default_value = false,
    hidden = true,
    order = "zb",
  },
  {
    type = "bool-setting",
    name = "muluna-hardcore-restrict-crusher",
    setting_type = "startup",
    default_value = false,
    forced_value = true,
    hidden = true,
    order = "ab",
  },
  {
    type = "bool-setting",
    name = "muluna-hardcore-restrict-asteroid-collector",
    setting_type = "startup",
    default_value = false,
    forced_value = true,
    hidden = true,
    order = "ac",
  },
  {
    type = "bool-setting",
    name = "muluna-hardcore-require-helium-3-in-fusion-cell",
    setting_type = "startup",
    default_value = false,
    forced_value = true,
    hidden = true,
    order = "ad",
  },
  
  {
    type = "bool-setting",
    name = "muluna-change-quality-science-pack-drain",
    setting_type = "startup",
    default_value = true,
    forced_value = true,
    hidden = true,
    order = "cc",
  },
  {
    type = "int-setting",
    name = "space-science-pack-output",
    setting_type = "startup",
    hidden = true,
    default_value = 2,
    forced_value = 2,
    min = 1,
    max = 10,
    order = "ca",
  },
  {
    type = "double-setting",
    name = "space-science-pack-energy",
    setting_type = "startup",
    hidden = true,
    default_value = 7,
    forced_value = 7,
    min = 0.01,
    max = 60,
    order = "cb",
  },
--   {
--     type = "double-setting",
--     name = "planet-power-consumption",
--     setting_type = "startup",
--     default_value = 300,
--     minimum_value = 1,
--     maximum_value = 1000,
--     order = "a"
-- },
{
    type = "double-setting",
    name = "platform-power-consumption",
    setting_type = "startup",
    hidden = true,
    default_value = 100,
    forced_value = 100,
    minimum_value = 0.3,
    maximum_value = 1000,
    order = "bb"
},
{
  type = "bool-setting",
  name = "enable-nav-beacon",
  setting_type = "startup",
  hidden = true,
  forced_value = false,
  default_value = true,
  order = "ba"
},}


data.raw["string-setting"]["aps-planet"].hidden = true
data.raw["string-setting"]["aps-planet"].allowed_values = {"muluna"}
data.raw["string-setting"]["aps-planet"].default_value = "muluna"
data.raw["string-setting"]["aps-planet"].forced_value = "muluna"
-- {
--   type = "double-setting",
--   name = "nav-beacon-update-ticks",
--   setting_type="runtime-global",
--   default_value = 60,
--   minimum_value = 1,
--   maximum_value = 360,
--   order = "a",
-- }}