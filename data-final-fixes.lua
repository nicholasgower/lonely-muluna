local rro = require("__planet-muluna__.lib.remove-replace-object")
local solar_multiplier = 1.5





for _,planet in pairs(data.raw.planet) do 
    planet.solar_power_in_space = planet.solar_power_in_space * solar_multiplier
    if planet.surface_properties["solar-power"] then
        planet.surface_properties["solar-power"] =  planet.surface_properties["solar-power"] * solar_multiplier
    else 
        planet.surface_properties["solar-power"] =  150
    end
    

end



local nauvis = data.raw["planet"]["nauvis"]
local nauvis_map_gen = data.raw["planet"]["nauvis"].map_gen_settings
nauvis_map_gen.autoplace_controls["trees"] = nil
nauvis_map_gen.autoplace_controls["water"] = nil
nauvis_map_gen.autoplace_controls["scrap"] = {}
nauvis_map_gen.autoplace_settings["entity"]["scrap"] = {}
for key,tile in pairs(nauvis_map_gen.autoplace_settings.tile.settings) do
    if string.find(key,"grass") then
        nauvis_map_gen.autoplace_settings.tile.settings[key] = nil
    end
end



nauvis.icon = "__lonely-muluna__/graphics/nauvis.png"
nauvis.starmap_icon = "__lonely-muluna__/graphics/starmap-planet-nauvis.png"
nauvis.localised_description = nil
data.raw["technology"]["planet-discovery-fulgora"].icon = "__lonely-muluna__/graphics/starmap-shattered-fulgora.png"
data.raw["technology"]["planet-discovery-fulgora"].icon_size = 512






local fulgora = table.deepcopy(data.raw["planet"]["fulgora"])

nauvis.surface_render_parameters = fulgora.surface_render_parameters

fulgora.type = "space-location"

fulgora.icon = "__lonely-muluna__/graphics/shattered-fulgora.png"
fulgora.starmap_icon = "__lonely-muluna__/graphics/starmap-shattered-fulgora.png"

data:extend{fulgora}


-- if mods["visible-planets"] then
--     --if mods["slp-dyson-sphere-reworked"] then
--         vp_override_planet_sprite("fulgora", "__core__/graphics/icons/starmap-shattered-fulgora.png", 512)
--     --end
-- end
data.raw["technology"]["recycling"].research_trigger.entity = "scrap"
data.raw["technology"]["recycling"].prerequisites = {"planet-discovery-nauvis"}


data.raw["planet"]["fulgora"] = nil --Shatters Fulgora

--data.raw["surface-property"]["magnetic-field"] = nil --Fully removes the magnetic field surface property. This is how we make Fulgora things craftable on Nauvis

for _,tech in pairs(data.raw["technology"]) do
    if tech.name ~="planet-discovery-fulgora" then
        rro.replace(tech.prerequisites,"asteroid-collector","planet-discovery-fulgora")
    else
        tech.prerequisites = {"asteroid-collector"}
    end
    
end

for _,prototype in pairs(data.raw) do
    
    for _,object in pairs(prototype) do
        --if object.surface_properties then
        --    object.surface_properties["magnetic-field"] = nil
        --end
        if object.surface_conditions then
            for i,condition in ipairs(object.surface_conditions) do
                if condition.property == "magnetic-field" then
                    table.remove(object.surface_conditions,i)
                    table.insert(object.surface_conditions,
                        {
                            property = "pressure",
                            min = 1000,
                            max = 1000,
                        }
                    )
                    break
                end
            end
        end
    end
end

data.raw["technology"]["rocket-part-productivity-fulgora"].localised_name={"",{"technology-name.rocket-part-productivity-fulgora"}," ",tostring(1)}
data.raw["technology"]["rocket-part-productivity-fulgora-2"].localised_name={"",{"technology-name.rocket-part-productivity-fulgora"}," ",tostring(2)}
