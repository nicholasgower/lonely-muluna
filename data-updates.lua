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



