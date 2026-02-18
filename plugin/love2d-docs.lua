local function set_highlight_state(enabled)
    local util = require("love2d-docs.util")
    local configModule = require("love2d-docs.config")
    local new_state
    if type(enabled) == "boolean" then
        new_state = enabled
    else
        new_state = not configModule.config.enable_on_start
    end

    configModule.config.enable_on_start = new_state

    util.load()
    if configModule.config.notifications == true then
        local msg = configModule.config.enable_on_start and "Enabled" or "Disabled"
        local level = configModule.config.enable_on_start and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify("LÖVE2D Highlights " .. msg, level, { title = "LÖVE2D Docs" })
    end
end

vim.api.nvim_create_user_command("LOVEHighlightEnable", function()
    set_highlight_state(true)
end, {})

vim.api.nvim_create_user_command("LOVEHighlightDisable", function()
    set_highlight_state(false)
end, {})

vim.api.nvim_create_user_command("LOVEHighlightToggle", function()
    set_highlight_state()
end, {})
