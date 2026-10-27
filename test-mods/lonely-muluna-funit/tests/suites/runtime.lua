-- Runtime checks for the Lonely Muluna scenario.
--
-- The headless scenario has no connected player, so these tests focus on
-- world state that can be created and inspected without one.
local runner = require("__funit__.test_runner")
local helpers = require("__lonely-muluna-funit__.tests.helpers")

local EVOLUTION_SURFACE = "lonely-muluna-funit-evolution"

runner.test("lonely-muluna is active", function()
  runner.assert(script.active_mods["lonely-muluna"], "lonely-muluna is not active")
  runner.assert(
    settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "muluna",
    "aps-planet is not set to muluna"
  )
end)

runner.test("the scenario starts on Muluna", function()
  local planet = helpers.get_muluna_planet()
  local surface = helpers.get_muluna_surface()
  runner.assert(surface.planet and surface.planet.name == "muluna", "the Muluna surface is not attached to Muluna")
  runner.assert(game.planets["nauvis"] ~= nil, "Nauvis planet is missing")
end)

runner.test("Fulgora is not a runtime planet", function()
  runner.assert(game.planets["fulgora"] == nil, "Fulgora is still present as a runtime planet")
end)

runner.test("Muluna uses the scenario solar multiplier", function()
  local surface = helpers.get_muluna_surface()
  local solar = surface.get_property("solar-power")
  runner.assert(
    helpers.approx(solar, 75),
    "Muluna surface solar-power should be 75, got " .. tostring(solar)
  )
end)

runner.test("new surfaces receive the scenario evolution factor", function()
  helpers.delete_surface_if_present(EVOLUTION_SURFACE)

  local surface = game.create_surface(EVOLUTION_SURFACE)
  local ok, err = pcall(function()
    local factor = game.forces["enemy"].get_evolution_factor_by_time(surface)
    runner.assert(
      helpers.approx(factor, 0.95),
      "new surface time evolution should be 0.95, got " .. tostring(factor)
    )
  end)

  helpers.delete_surface_if_present(EVOLUTION_SURFACE)
  runner.assert(ok, err)
end)
