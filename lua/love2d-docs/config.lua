local check = require("love2d-docs.check")

local M = {}

---@alias LoveDocsStyleType string | "bold" | "italic" | "underline"
---| "bold,italic" | "bold,underline" | "italic,underline" | "NONE"

---@class LoveDocsStyle
---@field love LoveDocsStyleType Style for 'love' global variable
---@field module LoveDocsStyleType Style for LÖVE modules
---@field func LoveDocsStyleType Style for LÖVE functions
---@field type LoveDocsStyleType Style for LÖVE types/objects
---@field callback LoveDocsStyleType Style for LÖVE callbacks (e.g., love.load)
---@field conf LoveDocsStyleType Style for LÖVE configuration (love.conf)

---@class LoveDocsColors
---@field LOVElove string? HEX color for 'love' global variable
---@field LOVEmodule string? HEX color for LÖVE modules
---@field LOVEfunction string? HEX color for LÖVE functions
---@field LOVEtype string? HEX color for LÖVE types/objects
---@field LOVEcallback string? HEX color for LÖVE callbacks
---@field LOVEconf string? HEX color for LÖVE configuration

---@class LoveDocsConfig
---@field enable_on_start boolean Whether to enable highlighting automatically on startup
---@field notifications boolean Whether to enable notifications
---@field style LoveDocsStyle Custom font styles (supports combinations like "bold,italic")
---@field colors LoveDocsColors Optional table to override default HEX colors

M.defaults = {
    enable_on_start = true,
    notifications = true,
    style = {
        love     = "bold",
        module   = "NONE",
        func     = "NONE",
        type     = "NONE",
        callback = "NONE",
        conf     = "NONE",
    },
    colors = {
        LOVElove     = nil, -- Example: "#E54D95"
        LOVEmodule   = nil,
        LOVEfunction = nil,
        LOVEtype     = nil,
        LOVEcallback = nil,
        LOVEconf     = nil,
    },
}

M.config = vim.deepcopy(M.defaults)

---@param user_settings table?
function M.setup(user_settings)
    user_settings = user_settings or {}

    check.validateUserSettings(user_settings)

    check.typeError(user_settings)

    check.keyExistsError(user_settings, M.defaults, "Option")

    M.config = vim.tbl_deep_extend("force", {}, M.defaults, user_settings)

    for k, v in pairs(M.config) do
        if v == 0 then
            M.config[k] = false
        end
    end
end

return M
