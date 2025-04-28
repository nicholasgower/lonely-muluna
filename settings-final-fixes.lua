for _,type in pairs(data.raw) do --Sets all visible settings to their default value and hides them.
    for _,setting in pairs(type) do
        if (setting.hidden == false or setting.hidden == nil) and setting.setting_type ~= "runtime-per-user" then
            setting.hidden = true
            setting.forced_value = setting.default_value
        end
        
    end
end