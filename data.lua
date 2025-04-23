local rro = require("__planet-muluna__.lib.remove-replace-object")
local lonely_muluna =
{
  order = "a",
  --default = true,
  basic_settings =
  {
    --property_expression_names = {},
    autoplace_controls =
    {
      
    }
  }
}

local muluna_resources = {
    "oxide-asteroid-chunk",
    "metallic-asteroid-chunk",
    "carbonic-asteroid-chunk",
    "anorthite-chunk",
    "helium",
    "stone",
    "uranium-ore",
}

data.raw["recipe"]["er-hcg"].ingredients = {
    {type = "item", name = "iron-plate", amount = 10},
    {type = "item", name = "iron-gear-wheel", amount = 5},
    {type = "item", name = "electronic-circuit", amount = 2},
}
data.raw["recipe"]["er-hcg"].enabled = true
--data.raw["technology"]["er-hcg-technology"] = nil

for _,autoplace in pairs(data.raw["autoplace-control"]) do 
    if autoplace.category == "resource" and not rro.contains(muluna_resources,autoplace.name) then
        lonely_muluna.basic_settings.autoplace_controls[autoplace.name] = {richness = 0.5}
    end
end

data.raw["map-gen-presets"]["default"]["default"] = lonely_muluna
--data.raw["map-gen-presets"]["default"]["default"].default = false
--data.raw["map-gen-presets"]["default"]["default"].order = "aa"


local muluna = data.raw["planet"]["muluna"]
muluna.surface_properties["solar-power"] = 50
muluna.solar_power_in_space = 60
muluna.localised_description = nil

data.raw["space-connection"]["nauvis-muluna"].from = "fulgora"
data.raw["space-connection"]["nauvis-muluna"].length = 42000
data.raw["space-connection"]["nauvis-muluna"].asteroid_spawn_definitions = table.deepcopy(data.raw["space-connection"]["nauvis-corrundum"].asteroid_spawn_definitions)


