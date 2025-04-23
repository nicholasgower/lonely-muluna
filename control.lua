local function init_storage() 
    if not storage.respawn_location then storage.respawn_location = {} end
end


script.on_init(init_storage)

--/c __lonely-muluna__ storage.respawn_location = {}
script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    --if surface.name == TENEBRIS then
        --surface.freeze_daytime = true
        --surface.daytime = 0.35
        game.forces["enemy"].set_evolution_factor(0.95, surface)
        if surface.name == "muluna" then
            game.forces["enemy"].set_evolution_factor(0.95, "nauvis")
        end
        if not storage.respawn_location then storage.respawn_location = {} end
    --end
end)


script.on_event(defines.events.on_player_respawned, function(event)
    --game.print("player died")
    --init_storage()
    --if storage.respawn_location[event.player_index] then
        game.players[event.player_index].teleport({0,0},"muluna")
        --storage.respawn_location[event.player_index] = nil
    --end
    
    
end)

-- script.on_event(defines.events.on_player_changed_surface, function(event)
--     init_storage()
--     if event.surface_index == nil then
--         game.players[event.player_index].teleport({0,0},"muluna")
--         game.players[event.player_index].get_main_inventory().clear()
--         if game.players[event.player_index].character then
--             storage.respawn_location[event.player_index] = "muluna"
--             game.print(tostring(storage.respawn_location[event.player_index]))
--             --game.players[event.player_index].character.die("enemy")
--         end
        
--         local corpses = game.planets["muluna"].surface.find_entities_filtered{type = "character-corpse"}

--         for _,corpse in pairs(corpses) do
--             if corpse.character_corpse_player_index == event.player_index then
--                 corpse.destroy()
--             end
--         end
--         --if not storage.respawn_location then storage.respawn_location = {} end
        
--     end
-- end)


-- e

-- script.on_event(defines.events.on_pre_player_died,function(event)  


    
--     local player = game.players[event.player_index]
--     game.print("player died")
--         if player.character then
--             if player.character.surface.platform then
--                 if storage.respawn_location == nil then storage.respawn_location = {} end
--                 storage.respawn_location[event.player_index] = "muluna"
--             end
--         end
    

--     end
-- )