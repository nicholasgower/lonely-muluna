local rro = require("__planet-muluna__.lib.remove-replace-object")
local solar_multiplier = 1.5

local function technology_icon_moon_complete(moon_icon, icon_size,scale)
	icon_size = icon_size or 256
	local icons = util.technology_icon_constant_planet(moon_icon)
    icons[3]=icons[2]
    icons[2]=icons[1]
    icons[1] = {
        icon = "__muluna-graphics__/graphics/technology/planet-technology.png",
        icon_size = 256,
        shift = {0,10},
    }
	icons[2].icon_size = icon_size
    icons[2].scale = scale*128/icon_size
    icons[2].shift = {0,10}
	--icons[3].icon = "__PlanetsLib__/graphics/icons/planet-technology-symbol.png"
	-- End result is an icons object ressembling the following, as of 2.0.37. Future API changes might change this code,
	-- which is why this function is written to reference the base function instead of copying it by hand.
	-- local icons = {
	-- 	{
	-- 		icon = moon_icon,
	-- 		icon_size = icon_size,
	-- 	},
	-- 	{
	-- 		icon = "__PlanetsLib__/graphics/icons/moon-technology-symbol.png",
	-- 		icon_size = 128,
	-- 		scale = 0.5,
	-- 		shift = { 50, 50 },
	-- 		floating = true
	-- 	},
	-- }
	return icons
end



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




nauvis.localised_description = nil
data.raw["technology"]["planet-discovery-fulgora"].icon = "__lonely-muluna__/graphics/starmap-shattered-fulgora.png"
data.raw["technology"]["planet-discovery-fulgora"].icon_size = 512






local fulgora = table.deepcopy(data.raw["planet"]["fulgora"])
local gleba = data.raw["planet"]["gleba"]


gleba.localised_description = nil
nauvis.surface_render_parameters = fulgora.surface_render_parameters
gleba.surface_render_parameters = fulgora.surface_render_parameters
gleba.lightning_properties = fulgora.lightning_properties
fulgora.type = "space-location"


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

data.raw["recipe"]["lightning-rod"].surface_conditions = nil
data.raw["recipe"]["lightning-collector"].surface_conditions = nil

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
table.insert(data.raw["technology"]["planet-discovery-gleba"].effects , 

{
    type = "unlock-recipe",
    recipe = "lightning-rod"
}


)


rro.remove(data.raw["technology"]["planet-discovery-fulgora"].effects , 

{
    type = "unlock-recipe",
    recipe = "lightning-rod"
}
)



data.raw["technology"]["planet-discovery-fulgora"].unit.count = 100
-- local function switch(a,b)

--     temp = table.deepcopy(a)
--     a = table.deepcopy(b)
--     b = temp
-- end

-- local function flip_name(input,a,b)

-- if input == a then
--      return b 
--     elseif input == b then 
--         return a
--      else 
--         return input

--       end

-- end

-- local function recursive_correct(data,nauvis,muluna)
--     --log(nauvis or "nil" .. ", " .. muluna or "nil" .. ", \n" .. serpent.block(data) or "nil")
--     if type(data) == "table" then
--         for key,entry in pairs(data) do
--             entry = recursive_correct(entry,nauvis,muluna)
--             data[key] = entry
--         end
--     else -- type(data) == "string" then
--         return flip_name(data,nauvis,muluna)
--     end
    

-- end

-- local function switch_planets(nauvis,muluna)

--     --recursive_correct(data.raw["space-connection"],nauvis,muluna)
--     for _,connection in pairs(data.raw["space-connection"]) do
--         connection.from = flip_name(connection.from,nauvis,muluna)
--         connection.to = flip_name(connection.to,nauvis,muluna)
--     end

--     for _,technology in pairs(data.raw["technology"]) do

--         if rro.contains(technology.effects,
--         {
--             type = "unlock-space-location",
--             name = nauvis,
--         }) then

--             rro.replace(technology.effects,
--             {
--                 type = "unlock-space-location",
--                 name = nauvis,
--             },
--             {
--                 type = "unlock-space-location",
--                 name = muluna,
--             }
--         )
            
--         elseif rro.contains(technology.effects,
--         {
--             type = "unlock-space-location",
--             name = muluna,
--         }) then
--             rro.replace(technology.effects,
--             {
--                 type = "unlock-space-location",
--                 name = muluna,
--             },
--             {
--                 type = "unlock-space-location",
--                 name = nauvis,
--             }
--         )
--         end

    
--     end

--     switch(data.raw["planet"][nauvis],data.raw["planet"][muluna])
--     local nauvis_obj = table.deepcopy(data.raw["planet"][nauvis])
--     local muluna_obj = table.deepcopy(data.raw["planet"][muluna])
--     nauvis_obj.name = muluna
--     muluna_obj.name = nauvis
--     data:extend{nauvis_obj,muluna_obj}
    
    

-- end

-- switch_planets("nauvis","muluna")

data.raw["technology"]["planet-discovery-fulgora"].icons = technology_icon_moon_complete("__lonely-muluna__/graphics/starmap-shattered-fulgora.png", 512,0.8)
data.raw["technology"]["planet-discovery-nauvis"].icons = technology_icon_moon_complete("__lonely-muluna__/graphics/starmap-planet-nauvis.png", 512,0.9)
data.raw["technology"]["planet-discovery-gleba"].icons = technology_icon_moon_complete("__lonely-muluna__/graphics/starmap-planet-gleba.png", 512,0.9)