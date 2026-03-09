local M = {}

function M.setup(configColors, configStyle)
    local style      = configStyle
    local LOVEColors = configColors

    return {
        ["@variable.global.love.lua"]        = { fg = LOVEColors.LOVElove,     style = style.love,     nocombine = true },
        ["@module.bulitin.love.lua"]         = { fg = LOVEColors.LOVEmodule,   style = style.module,   nocombine = true },
        ["@type.love.lua"]                   = { fg = LOVEColors.LOVEtype,     style = style.type,     nocombine = true },
        ["@punctuation.dot.love.lua"]        = { fg = LOVEColors.LOVEdot,      style = style.dot,      nocombine = true },
        ["@function.love.lua"]               = { fg = LOVEColors.LOVEfunction, style = style.func,     nocombine = true },
        ["@function.method.love.lua"]        = { fg = LOVEColors.LOVEmethod,   style = style.method,   nocombine = true },
        ["@function.call.love.callback.lua"] = { fg = LOVEColors.LOVEcallback, style = style.callback, nocombine = true },
        ["@function.call.love.conf.lua"]     = { fg = LOVEColors.LOVEconf,     style = style.conf,     nocombine = true },
    }

end

return M
