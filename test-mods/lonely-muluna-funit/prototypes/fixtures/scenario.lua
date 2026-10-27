-- Data-final-fixes checks for the Lonely Muluna scenario ruleset.
--
-- These fixtures run after lonely-muluna's data-final-fixes, so they inspect
-- the same final prototype set that a player receives.
local results = require("lib.results")

local SUITE = "scenario"

---@param a string
---@param b string
---@return table|nil
local function find_connection(a, b)
  for _, connection in pairs(data.raw["space-connection"] or {}) do
    if
      (connection.from == a and connection.to == b)
      or (connection.from == b and connection.to == a)
    then
      return connection
    end
  end
  return nil
end

---@param technology table
---@param recipe string
---@return boolean
local function unlocks_recipe(technology, recipe)
  for _, effect in pairs(technology.effects or {}) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe then
      return true
    end
  end
  return false
end

---@param technology table
---@param prerequisite string
---@return boolean
local function has_prerequisite(technology, prerequisite)
  for _, entry in pairs(technology.prerequisites or {}) do
    if entry == prerequisite then
      return true
    end
  end
  return false
end

results.check(SUITE, "start-planet-forced-to-muluna", function()
  local setting = settings.startup["aps-planet"]
  assert(setting, "aps-planet setting is missing")
  assert(setting.value == "muluna", "aps-planet value is not muluna")
end)

results.check(SUITE, "map-gen-preset", function()
  local presets = data.raw["map-gen-presets"]
  assert(presets and presets["default"], "default map-gen-presets prototype is missing")
  local preset = presets["default"]["default"]
  assert(preset, "the default map-gen preset is missing")
  assert(preset.basic_settings, "the default preset has no basic_settings")
  local controls = preset.basic_settings.autoplace_controls
  assert(controls, "the default preset has no autoplace_controls")

  assert(controls["iron-ore"], "iron-ore is missing from the preset")
  assert(controls["iron-ore"].richness == 0.5, "iron-ore richness is not 0.5")
  assert(controls["stone"] == nil, "stone should be excluded from the 0.5 richness rule")
  assert(controls["uranium-ore"] == nil, "uranium-ore should be excluded from the 0.5 richness rule")
end)

results.check(SUITE, "fulgora-is-a-space-location", function()
  assert(data.raw["planet"]["fulgora"] == nil, "Fulgora is still a planet")
  local fulgora = data.raw["space-location"]["fulgora"]
  assert(fulgora, "Fulgora is missing from space-location")
  assert(fulgora.type == "space-location", "Fulgora has the wrong prototype type")
end)

results.check(SUITE, "nauvis-is-a-scrap-world", function()
  local nauvis = data.raw["planet"]["nauvis"]
  assert(nauvis, "Nauvis is missing")
  local map_gen = nauvis.map_gen_settings
  assert(map_gen, "Nauvis has no map_gen_settings")
  local controls = map_gen.autoplace_controls
  assert(controls, "Nauvis has no autoplace_controls")
  assert(controls["scrap"], "Nauvis scrap autoplace control is missing")
  assert(controls["water"] == nil, "Nauvis water autoplace control is still present")
  assert(controls["trees"] == nil, "Nauvis trees autoplace control is still present")

  local entity_settings = map_gen.autoplace_settings
    and map_gen.autoplace_settings["entity"]
    and map_gen.autoplace_settings["entity"]["settings"]
  assert(entity_settings and entity_settings["scrap"], "Nauvis scrap entity autoplace setting is missing")

  local tile_settings = map_gen.autoplace_settings
    and map_gen.autoplace_settings["tile"]
    and map_gen.autoplace_settings["tile"]["settings"]
  assert(tile_settings, "Nauvis has no tile autoplace settings")
  for tile_name in pairs(tile_settings) do
    assert(not tile_name:find("grass"), "grass tile " .. tile_name .. " is still present on Nauvis")
  end
end)

results.check(SUITE, "solar-multiplier", function()
  local muluna = data.raw["planet"]["muluna"]
  assert(muluna, "Muluna is missing")
  assert(muluna.surface_properties["solar-power"] == 75, "Muluna surface solar-power is not 75")
  assert(muluna.solar_power_in_space == 90, "Muluna solar_power_in_space is not 90")

  local nauvis = data.raw["planet"]["nauvis"]
  assert(nauvis.surface_properties["solar-power"] == 150, "Nauvis fallback solar-power is not 150")
end)

results.check(SUITE, "gleba-lightning-and-render-parameters", function()
  local gleba = data.raw["planet"]["gleba"]
  assert(gleba, "Gleba is missing")
  assert(gleba.lightning_properties, "Gleba has no lightning_properties")
  assert(gleba.surface_render_parameters, "Gleba has no surface_render_parameters")

  local nauvis = data.raw["planet"]["nauvis"]
  assert(nauvis.surface_render_parameters, "Nauvis has no surface_render_parameters")
end)

results.check(SUITE, "space-route-muluna-fulgora", function()
  assert(find_connection("muluna", "fulgora"), "no space connection connects Muluna and Fulgora")
end)

results.check(SUITE, "space-route-solar-system-edge", function()
  assert(
    find_connection("muluna", "solar-system-edge"),
    "no space connection connects Muluna and the solar system edge"
  )
end)

results.check(SUITE, "space-route-maraxsis-when-installed", function()
  if mods["maraxsis"] then
    assert(find_connection("muluna", "maraxsis"), "no space connection connects Muluna and Maraxsis")
  end
end)

results.check(SUITE, "fulgora-discovery-gate", function()
  local technology = data.raw["technology"]["planet-discovery-fulgora"]
  assert(technology, "planet-discovery-fulgora is missing")
  assert(technology.unit and technology.unit.count == 100, "Fulgora discovery cost is not 100")
  assert(
    has_prerequisite(technology, "asteroid-collector"),
    "Fulgora discovery does not require asteroid-collector"
  )
end)

results.check(SUITE, "technology-prerequisites", function()
  local steam = data.raw["technology"]["steam-power"]
  local steel = data.raw["technology"]["steel-axe"]
  local electronics = data.raw["technology"]["electronics"]
  assert(steam, "steam-power is missing")
  assert(steel, "steel-axe is missing")
  assert(electronics, "electronics is missing")
  assert(
    has_prerequisite(steam, "metallic-asteroid-crushing"),
    "steam-power does not require metallic-asteroid-crushing"
  )
  assert(
    has_prerequisite(steel, "metallic-asteroid-crushing"),
    "steel-axe does not require metallic-asteroid-crushing"
  )
  assert(
    has_prerequisite(electronics, "muluna-aluminum-processing"),
    "electronics does not require muluna-aluminum-processing"
  )
end)

results.check(SUITE, "lightning-rod-moved-to-gleba", function()
  local fulgora = data.raw["technology"]["planet-discovery-fulgora"]
  local gleba = data.raw["technology"]["planet-discovery-gleba"]
  assert(fulgora, "planet-discovery-fulgora is missing")
  assert(gleba, "planet-discovery-gleba is missing")
  assert(not unlocks_recipe(fulgora, "lightning-rod"), "Fulgora still unlocks lightning-rod")
  assert(unlocks_recipe(gleba, "lightning-rod"), "Gleba does not unlock lightning-rod")
end)

results.check(SUITE, "recycling-is-a-scrap-trigger", function()
  local technology = data.raw["technology"]["recycling"]
  assert(technology, "recycling technology is missing")
  local trigger = technology.research_trigger
  assert(trigger, "recycling has no research_trigger")
  assert(trigger.type == "mine-entity", "recycling trigger is not mine-entity")
  assert(
    trigger.entities and #trigger.entities == 1 and trigger.entities[1] == "scrap",
    "recycling does not trigger on scrap"
  )
  assert(technology.unit == nil, "recycling still has a science cost")
  assert(
    technology.prerequisites
      and #technology.prerequisites == 1
      and technology.prerequisites[1] == "planet-discovery-nauvis",
    "recycling does not require planet-discovery-nauvis"
  )
end)

results.check(SUITE, "rail-support-foundations-removed", function()
  assert(
    data.raw["technology"]["rail-support-foundations"] == nil,
    "rail-support-foundations technology was not removed"
  )
end)

results.check(SUITE, "magnetic-field-conditions-cleared", function()
  for prototype_type, prototypes in pairs(data.raw) do
    if type(prototypes) == "table" then
      for prototype_name, prototype in pairs(prototypes) do
        if type(prototype) == "table" and prototype.surface_conditions then
          local conditions = prototype.surface_conditions
          if #conditions == 1 and conditions[1].property == "magnetic-field" then
            error(
              "prototype "
                .. tostring(prototype_type)
                .. "/"
                .. tostring(prototype_name)
                .. " still has a magnetic-field-only surface condition"
            )
          end
        end
      end
    end
  end

  for _, recipe_name in ipairs({ "lightning-rod", "lightning-collector" }) do
    local recipe = data.raw["recipe"][recipe_name]
    assert(recipe, recipe_name .. " recipe is missing")
    assert(recipe.surface_conditions == nil, recipe_name .. " still has surface conditions")
  end
end)

results.check(SUITE, "muluna-orbit", function()
  local muluna = data.raw["planet"]["muluna"]
  assert(muluna, "Muluna is missing")
  assert(math.abs(muluna.distance - 45) < 0.001, "Muluna distance is not 45")
  assert(math.abs(muluna.orientation - 0.4) < 0.001, "Muluna orientation is not 0.4")
end)

results.check(SUITE, "discovery-icons", function()
  local expected_icons = {
    ["planet-discovery-fulgora"] = "__lonely-muluna__/graphics/starmap-shattered-fulgora.png",
    ["planet-discovery-nauvis"] = "__lonely-muluna__/graphics/starmap-planet-nauvis.png",
    ["planet-discovery-gleba"] = "__lonely-muluna__/graphics/starmap-planet-gleba.png",
  }

  for technology_name, icon in pairs(expected_icons) do
    local technology = data.raw["technology"][technology_name]
    assert(technology, technology_name .. " is missing")
    assert(technology.icons and #technology.icons == 3, technology_name .. " does not have three icons")
    assert(
      technology.icons[1].icon == "__muluna-graphics__/graphics/technology/planet-technology.png",
      technology_name .. " does not use the Muluna planet technology icon"
    )
    assert(technology.icons[2].icon == icon, technology_name .. " does not use " .. icon)
  end

  assert(
    data.raw["planet"]["nauvis"].icon == "__lonely-muluna__/graphics/nauvis.png",
    "Nauvis planet icon was not replaced"
  )
  assert(
    data.raw["planet"]["gleba"].icon == "__lonely-muluna__/graphics/gleba.png",
    "Gleba planet icon was not replaced"
  )
end)

results.check(SUITE, "er-hcg-optional-patch", function()
  local recipe = data.raw["recipe"]["er-hcg"]
  if not recipe then
    -- The optional eradicators-hand-crank-redux integration is allowed to be
    -- absent. The important part is that the guarded data.lua path did not
    -- crash and did not require the 2.0-only mod.
    return
  end

  assert(recipe.enabled, "er-hcg is present but not enabled")
  assert(#recipe.ingredients == 3, "er-hcg does not have the expected three ingredients")
  assert(recipe.ingredients[1].name == "iron-plate", "er-hcg first ingredient is not iron-plate")
  assert(recipe.ingredients[1].amount == 10, "er-hcg iron-plate amount is not 10")
  assert(recipe.ingredients[2].name == "iron-gear-wheel", "er-hcg second ingredient is not iron-gear-wheel")
  assert(recipe.ingredients[3].name == "electronic-circuit", "er-hcg third ingredient is not electronic-circuit")
end)
