PlanetsLib:update{
    name = "muluna",
    type = "planet",
    draw_orbit = true,
    subgroup = data.raw["planet"]["nauvis"].subgroup,
    orbit = {
        parent = {
            type = "space-location",
            name = "star",
        },
        distance = 45,
        orientation = 0.4,
    }
    

}

local gleba_plants = {"yumako-tree","jellystem"}
local fulgora_ruin = data.raw["simple-entity"]["fulgoran-ruin-big"]
for _,plant_name in pairs(gleba_plants) do
    local plant=data.raw["plant"][plant_name]
    local electric_resistance = {type = "electric", percent = 100}
    if plant.resistances then 
        rro.soft_insert(plant.resistances,electric_resistance)
    else
        plant.resistances = {electric_resistance}
    end
end
-- PlanetsLib:update{
--     name = "muluna-stargate",
--     type = "space-location",
--     subgroup = data.raw["planet"]["nauvis"].subgroup,
--     orbit = {
--         parent = {
--             type = "planet",
--             name = "muluna",
--         },
--         distance = 3,
--         orientation = 0.5,
--     }
    

-- }



