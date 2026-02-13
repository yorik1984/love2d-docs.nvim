local check = require("love2d-docs.check")
local M     = {}

--- Apply overrides from configColors into color table
--- @param color table
--- @param configColors table?
function M.colorOverrides(color, configColors)
    if configColors == nil then
        return
    end

    if type(configColors) ~= "table" then
        error("love2d-docs.nvim: colorOverrides: configColors must be a table or nil", 2)
    end

    check.keyExistsError(configColors, color, "color", "Use: from love2d-docs/colors/init.lua")

    for key, value in pairs(configColors) do
        if type(color[key]) == "table" then
            M.colorOverrides(color[key], { color = value })
        else
            if type(value) ~= "string" then
                error(("love2d-docs.nvim: color override for '%s' must be a string, got %s"):format(key, type(value)), 2)
            end

            local low = value:lower()
            if low == "none" then
                color[key] = "NONE"
            elseif check.isHex(value) then
                color[key] = value
            elseif not color[value] then
                error(
                    "love2d-docs.nvim: color '" ..
                    value .. "' has wrong format. Use: '#XXXXXX' or existing color group name", 2)
            else
                color[key] = color[value]
            end
        end
    end
end

return M
