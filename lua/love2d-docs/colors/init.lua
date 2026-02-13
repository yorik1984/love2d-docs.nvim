local util = require("love2d-docs.colors.util")

local M = {}

function M.setup(config)

    local LOVEColors = {
        LOVElove     = (vim.o.background == "dark") and "#E54D95" or "#E54D95",
        LOVEmodule   = (vim.o.background == "dark") and "#E54D95" or "#E54D95",
        LOVEfunction = (vim.o.background == "dark") and "#2FA8DC" or "#2FA8DC",
        LOVEtype     = (vim.o.background == "dark") and "#2FA8DC" or "#2FA8DC",
        LOVEcallback = (vim.o.background == "dark") and "#2FA8DC" or "#2FA8DC",
        LOVEconf     = (vim.o.background == "dark") and "#2FA8DC" or "#2FA8DC",
    }

    if config.colors then
        util.colorOverrides(LOVEColors, config.colors)
    end

    M.colors = LOVEColors
    return LOVEColors
end

function M.get_colors()
    return M.colors
end

return M
