script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    --if surface.name == TENEBRIS then
        --surface.freeze_daytime = true
        --surface.daytime = 0.35
        game.forces["enemy"].set_evolution_factor(0.95, surface)
    --end
end)

-- script.on_event(defines.events.on_player_respawned, function(event)
--     local surface = game.surfaces[event.surface_index]
--     --if surface.name == TENEBRIS then
--         --surface.freeze_daytime = true
--         --surface.daytime = 0.35
--         game.forces["enemy"].set_evolution_factor(0.95, surface)
--     --end
-- end)