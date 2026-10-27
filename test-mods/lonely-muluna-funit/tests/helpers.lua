-- Shared helpers for the Lonely Muluna FUnit runtime suite.
local helpers = {}

---@param actual number
---@param expected number
---@param epsilon? number
---@return boolean
function helpers.approx(actual, expected, epsilon)
  return math.abs(actual - expected) <= (epsilon or 1e-6)
end

---@return LuaPlanet
function helpers.get_muluna_planet()
  local planet = game.planets["muluna"]
  assert(planet, "Muluna planet prototype is missing")
  return planet
end

---@return LuaSurface
function helpers.get_muluna_surface()
  local planet = helpers.get_muluna_planet()
  local surface = planet.surface
  -- The headless FUnit scenario has no connected player, so the starting
  -- planet surface is not automatically generated. Create it explicitly; this
  -- still exercises the real planet surface creation path.
  if not surface then
    surface = planet.create_surface()
  end
  assert(surface and surface.valid, "Muluna surface could not be created")
  return surface
end

---@param name string
function helpers.delete_surface_if_present(name)
  local surface = game.surfaces[name]
  if surface and surface.valid then
    game.delete_surface(surface)
  end
end

return helpers
