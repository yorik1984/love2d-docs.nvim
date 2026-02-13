local util = require("love2d-docs.util")
local configModule = require("love2d-docs.config")

local function set_highlight_state(enabled)
    configModule.config.enable_on_start = enabled

    util.load()
    if enabled then
        vim.notify("LÖVE2D Highlights Enabled", vim.log.levels.INFO, { title = "LÖVE2D Docs" })
    else
        vim.notify("LÖVE2D Highlights Disabled", vim.log.levels.WARN, { title = "LÖVE2D Docs" })
    end
end

vim.api.nvim_create_user_command("LOVEHighlightEnable", function()
    set_highlight_state(true)
end, {})

vim.api.nvim_create_user_command("LOVEHighlightDisable", function()
    set_highlight_state(false)
end, {})

vim.api.nvim_create_user_command("LOVEHighlightToggle", function()
    set_highlight_state(not configModule.config.enable_on_start)
end, {})
