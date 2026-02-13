local M = {}

function M.contains(tbl, value)
    if type(tbl) ~= "table" then
        return false
    end

    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end

    return false
end

---@param value string
---@return boolean
function M.isHex(value)
    if type(value) ~= "string" then
        return false
    end
    return value:match("^#%x%x%x%x%x%x$") ~= nil
end

---@param plugin string
---@return boolean
function M.isLoaded(plugin)
    local ok, _ = pcall(require, plugin)
    return ok
end

---@param userConfig table
---@param config table
---@param key_type string
---@param help string?
function M.keyExistsError(userConfig, config, key_type, help)
    local error_help = {
        style      = "Use: style = { love = '<style>', module = '<style>', func = '<style>', type = '<style>', callback = '<style>', conf = '<style>' }",
        colors     = "Use: colors = { LOVE<Type> = '#XXXXXX' }",
    }
    for key, _ in pairs(userConfig or {}) do
        if config[key] == nil then
            local hint = ""
            if help and help ~= "" then
                hint = " " .. tostring(help)
            elseif error_help and error_help[key] then
                hint = " " .. tostring(error_help[key])
            end

            error(string.format(
                "love2d-docs.nvim: %s `%s` does not exist.%s",
                key_type or "Option", key, hint
            ), 2)
        end
    end
end

function M.notTableError(key, value, help)
    if value ~= nil then
        if type(value) ~= "table" then
            error("love2d-docs.nvim: user `config." .. key .. " = " .. tostring(value) .. "` not a table. " .. help)
        end
    end
end

---@param plugin string
---@param help string?
function M.requiresPluginError(plugin, help)
    if not M.isLoaded(plugin) then
        help = help or ""
        error(string.format(
            "love2d-docs.nvim: Plugin `%s` not loaded or not installed. %s",
            plugin, help
        ))
    end
end

--- Validate user_settings argument for setup
---@param user_settings any
function M.validateUserSettings(user_settings)
    if user_settings ~= nil and type(user_settings) ~= "table" then
        error("love2d-docs.nvim: Error in `setup(config)`. `config` must be a table or nil", 2)
    end
end

---@param userConfig table
function M.typeError(userConfig)
    -- Rules:
    --  - validators[key] = "string"  -> compare type(value) == "string"
    --  - validators[key] = { ... }   -> if all elements are primitive type names ("string","number","boolean","table")
    -- then treat as allowed types list;
    -- otherwise treat as enumeration of allowed literal values (string/number/boolean)
    -- Only top-level fields of userConfig are checked. No deep inspection of tables.
    local function is_primitive_type_name(s)
        return s == "string" or s == "number" or s == "boolean" or s == "table"
    end

    local function table_all_types(tbl)
        if type(tbl) ~= "table" or #tbl == 0 then return false end
        for _, v in ipairs(tbl) do
            if type(v) ~= "string" or not is_primitive_type_name(v) then
                return false
            end
        end
        return true
    end

    local function value_in_literals(value, literals)
        for _, lit in ipairs(literals) do
            if value == lit then
                return true
            end
        end
        return false
    end

    local validators = {
        enable_on_start = "boolean",
        style           = "table", -- preset table
        colors          = "table", -- preset table
    }

    local function is_allowed_type_or_value(value, expected)
        if type(expected) == "string" then
            return type(value) == expected
        end

        if type(expected) == "table" then
            if table_all_types(expected) then
                for _, t in ipairs(expected) do
                    if type(value) == t then
                        return true
                    end
                end
                return false
            else
                return value_in_literals(value, expected)
            end
        end

        return false
    end
    for key, value in pairs(userConfig or {}) do
        local expected = validators[key]
        if expected ~= nil then
            if not is_allowed_type_or_value(value, expected) then
                local expected_repr
                if type(expected) == "string" then
                    expected_repr = expected
                else
                    if table_all_types(expected) then
                        expected_repr = "{" .. table.concat(expected, ",") .. "}"
                    else
                        local reprs = {}
                        for _, v in ipairs(expected) do
                            if type(v) == "string" then
                                reprs[#reprs + 1] = ("'%s'"):format(v)
                            else
                                reprs[#reprs + 1] = tostring(v)
                            end
                        end
                        expected_repr = "[" .. table.concat(reprs, ", ") .. "]"
                    end
                end
                error(string.format(
                    "love2d-docs.nvim: Invalid value/type for config.%s. Expected %s, got %s",
                    key, expected_repr, type(value)
                ))
            end
        end
    end
end

return M
