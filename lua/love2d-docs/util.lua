local colors       = require("love2d-docs.colors")
local configModule = require("love2d-docs.config")
local style        = require("love2d-docs.style")
local theme        = require("love2d-docs.theme")
local M            = {}

function M.syntax(syntax)
    for group, color in pairs(syntax) do
        M.highlight(group, color)
    end
end

function M.syntaxClear(syntax)
    for group, _ in pairs(syntax) do
        vim.api.nvim_set_hl(0, group, {})
    end
end

function M.highlight(group, color)
    if color.style then
        if type(color.style) == "table" then
            color = vim.tbl_extend("force", color, color.style)
        elseif color.style:lower() ~= "none" then
            -- handle old string style definitions
            for s in string.gmatch(color.style, "([^,]+)") do
                color[s] = true
            end
        end
        color.style = nil
    end

    vim.api.nvim_set_hl(0, group, color)
end

function M.setup(userConfig)
    local config = configModule.setup(userConfig)
    M.load(config)
end

function M.load(configApply)
    local config = configModule.config

    if configApply then
        configModule.setup(configApply)
        config = configModule.config
    end

    local configColors = colors.setup(config)
    local configStyle = style.setupStyle(config)
    if config.enable_on_start == true then
        M.syntax(theme.setup(configColors, configStyle))
        M.autocmds(theme.setup(configColors, configStyle))
    else
        M.syntaxClear(theme.setup(configColors, configStyle))
        vim.api.nvim_create_augroup("love2d-docs", { clear = true })
    end
end

function M.autocmds(syntax)
    local group = vim.api.nvim_create_augroup("love2d-docs", {})
    vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost" }, {
        group = group,
        pattern = { "*.lua" },
        callback = function()
            require("love2d-docs.util").syntax(syntax)
        end,
    })
end

return M
