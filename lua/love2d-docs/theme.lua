local M = {}

function M.setup(configColors, configStyle)
    local style      = configStyle
    local LOVEColors = configColors

    return {
        ["@variable.global.lua.love"]        = { fg = LOVEColors.LOVElove,     style = style.love,     nocombine = true },
        ["@module.bulitin.lua.love"]         = { fg = LOVEColors.LOVEmodule,   style = style.module,   nocombine = true },
        ["@function.lua.love"]               = { fg = LOVEColors.LOVEfunction, style = style.func,     nocombine = true },
        ["@type.lua.love"]                   = { fg = LOVEColors.LOVEtype,     style = style.type,     nocombine = true },
        ["@function.call.lua.love.callback"] = { fg = LOVEColors.LOVEcallback, style = style.callback, nocombine = true },
        ["@function.call.lua.love.conf"]     = { fg = LOVEColors.LOVEconf,     style = style.conf,     nocombine = true },
    }

end

return M
