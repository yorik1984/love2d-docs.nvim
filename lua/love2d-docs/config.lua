local check = require("love2d-docs.check")

local M = {}

M.defaults = {
    enable_on_start = true,
    style = {
        love     = "bold",
        module   = "NONE",
        func     = "NONE",
        type     = "NONE",
        callback = "NONE",
        conf     = "NONE",
    },
    colors = {},
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
