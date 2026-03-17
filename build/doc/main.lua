local api = require("love-api.love_api")
local align = require("align")

-- Local variables
local INDENT_STRING = "    "
local TAG_PREFIX = "LOVE-"
local TAG_ALT_PREFIX = "love-"
local NEW_LINE_S = "\n"
local NEW_LINE_D = "\n\n"

local PAGE_WIDTH = 80
align.setDefaultWidth(PAGE_WIDTH)

local TOC_NAME_WIDTH_LIMIT = 40
local TOC_NAME_REF_SPACING = 2

local LOVE_TYPES = {}

-- Misc. functions
-- Helper function to format string values with backticks and proper quotes
local function formatDefaultValue(value, valueType)
    valueType = valueType or value
    if valueType == "string" then
        if value:find('"') then
            return "`" .. value .. "`"
        end
        return "`" .. value .. "`"
    elseif valueType == "constants" then
        if value:find('"') then
            return "'" .. value .. "'"
        end
        return '"' .. value .. '"'
    end

    return "`" .. tostring(value):gsub("%s+", "") .. "`"
end

local function getIndentation(indentLevel, indentString, defaultIndentLevel)
    indentLevel = indentLevel or defaultIndentLevel or 0
    indentString = indentString or INDENT_STRING
    local indent = indentString:rep(indentLevel)

    return indentLevel, indentString, indent
end

local function getLoveTypes(tab)
    for _, attribute in ipairs({ "enums", "types" }) do
        for _, t in ipairs(tab[attribute] or {}) do
            LOVE_TYPES[t.name] = true
        end
    end
end

-- Formatting functions
local function section()
    return ("="):rep(PAGE_WIDTH)
end

local function subsection()
    return ("-"):rep(PAGE_WIDTH)
end

local function formatAsTag(str)
    return ("*%s*"):format(str)
end

local function formatTags(fullName, suffix)
    suffix = suffix or ""
    local tags = {
        formatAsTag(TAG_PREFIX .. fullName .. suffix), -- LOVE-...
        formatAsTag(TAG_ALT_PREFIX .. fullName .. suffix), -- love-...
    }
    return align.right(table.concat(tags, " "))
end

local function formatAsReference(str)
    return ("|%s|"):format(str)
end

local function concat(tab, sep, func)
    local elements = {}

    for i, v in ipairs(tab) do
        table.insert(elements, func(i, v))
    end

    return table.concat(elements, sep)
end

local function concatAttribute(tab, sep, attr, formatFunc)
    formatFunc = formatFunc or function(value)
        return value
    end
    return concat(tab, sep, function(_, v)
        return formatFunc(v[attr])
    end)
end

-- Trims text that is surrounded by formatting without removing the formatting
local function trimFormattedText(str, width, formatFunc)
    local formattedStr = formatFunc(str)

    while #formattedStr > width do
        str = str:sub(1, -2)
        formattedStr = formatFunc(str .. "-")
    end

    return formattedStr
end

-- Prints a table of contents
local function printTableOfContents(tab, tagPrefix, indentLevel, indentString)
    local indent = select(3, getIndentation(indentLevel, indentString))
    tab = tab or {}

    if #tab == 0 then
        return indent .. "None"
    else
        return concat(tab, NEW_LINE_S, function(_, attr)
            local attrName = attr.name or tostring(attr)

            local name =
                align.left(trimFormattedText(attrName, TOC_NAME_WIDTH_LIMIT - #indent, formatAsReference), indent)

            local tag = formatAsReference(tagPrefix .. attrName)
            local tagLength = #tag

            local nameLength = #name
            local maxAvailableSpace = PAGE_WIDTH - nameLength

            local minSpacing = TOC_NAME_REF_SPACING

            for spacing = maxAvailableSpace - tagLength, minSpacing, -1 do
                if spacing >= minSpacing and nameLength + spacing + tagLength <= PAGE_WIDTH then
                    return name .. (" "):rep(spacing) .. tag
                end
            end

            return name .. (" "):rep(minSpacing) .. tag
        end)
    end
end

-- Handles TOC with tag and description
local function printTOCWithTagAndDesc(tab, attribute, tagPrefix, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    return formatTags(tab.name .. "-" .. attribute)
        .. NEW_LINE_S
        .. align.left(attribute:gsub("^%l", string.upper) .. ": ~", indent)
        .. NEW_LINE_S
        .. printTableOfContents(tab[attribute], TAG_PREFIX .. tagPrefix, indentLevel + 1, indentString)
end

-- Gets a basic description
local function getBasicDescription(attribute, moduleName, indent)
    indent = indent or ""
    return align.left("The " .. attribute .. " of " .. formatAsReference(moduleName) .. ": ~", indent)
end

-- Functions

local function formatTypedAttribute(value, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local typedAttribute =
        align.left(formatDefaultValue(value.name, value.type or "any") .. ": " .. (value.type or "any"), indent)

    if LOVE_TYPES[value.type] then
        typedAttribute = typedAttribute .. " |" .. TAG_PREFIX .. value.type .. "|"
    end

    if value.default ~= nil then
        typedAttribute = typedAttribute .. " (default: " .. formatDefaultValue(value.default, value.type) .. ")"
    end

    typedAttribute = typedAttribute
        .. NEW_LINE_D
        .. align.left(value.description or "", indentString:rep(indentLevel + 1))

    if value.table and #value.table > 0 then
        typedAttribute = typedAttribute
            .. NEW_LINE_D
            .. concat(value.table, NEW_LINE_D, function(_, nestedValue)
                return formatTypedAttribute(nestedValue, indentLevel + 1, indentString)
            end)
    end

    return typedAttribute
end

local function formatNeovimParameter(param, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local paramLine = indent
        .. "• {"
        .. (param.name or "?")
        .. "} ("
        .. formatDefaultValue(param.type, param.type or "any")
        .. ")"

    if LOVE_TYPES[param.type] then
        paramLine = paramLine .. " |" .. TAG_PREFIX .. param.type .. "|"
    end

    if param.default ~= nil then
        paramLine = paramLine .. " (default: " .. formatDefaultValue(param.default, param.type) .. ")"
    end

    if param.description then
        paramLine = paramLine .. NEW_LINE_S .. align.left(param.description, indentString:rep(indentLevel + 1))
    end

    if param.table and #param.table > 0 then
        paramLine = paramLine
            .. NEW_LINE_S
            .. concat(param.table, NEW_LINE_S, function(_, nestedValue)
                return formatNeovimParameter(nestedValue, indentLevel + 1, indentString)
            end)
    end

    return paramLine
end

local function formatNeovimParameters(params, indentLevel, indentString)
    if not params or #params == 0 then
        return indentString:rep(indentLevel) .. "None"
    end

    local result = {}
    for _, param in ipairs(params) do
        table.insert(result, formatNeovimParameter(param, indentLevel, indentString))
    end

    return table.concat(result, NEW_LINE_S)
end

local function formatNeovimReturn(ret, indentLevel, indentString, index, total)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local prefix = indent
    if total and total > 1 then
        prefix = indent .. index .. ". "
    end

    local returnLine = prefix .. "(" .. formatDefaultValue(ret.type, ret.type) .. ")"

    if ret.name and ret.name ~= "" then
        returnLine = returnLine .. " " .. formatDefaultValue(ret.name, ret.type)
    end

    if LOVE_TYPES[ret.type] then
        returnLine = returnLine .. " |" .. TAG_PREFIX .. ret.type .. "|"
    end

    if ret.description then
        returnLine = returnLine .. NEW_LINE_S .. align.left(ret.description, indentString:rep(indentLevel + 1))
    end

    return returnLine
end

local function formatNeovimReturns(returns, indentLevel, indentString)
    if not returns or #returns == 0 then
        return indentString:rep(indentLevel) .. "None"
    end
    local result = {}
    for i, ret in ipairs(returns) do
        table.insert(result, formatNeovimReturn(ret, indentLevel, indentString, i, #returns))
    end

    return table.concat(result, NEW_LINE_D)
end

local function getSynopsis(variant, fullName)
    local synopsis = formatAsReference(fullName)

    if #(variant.returns or {}) > 0 then
        local returns = concatAttribute(variant.returns, ", ", "name", formatDefaultValue)
        synopsis = returns .. " = " .. synopsis
    end

    if #(variant.arguments or {}) == 0 then
        synopsis = synopsis .. "()"
    else
        local arguments = concatAttribute(variant.arguments, ", ", "name", formatDefaultValue)
        synopsis = synopsis .. "(" .. arguments .. ")"
    end

    return synopsis
end

local function getSynopses(func, fullName)
    local synopses = {}

    for _, variant in ipairs(func.variants) do
        table.insert(synopses, getSynopsis(variant, fullName))
    end

    return synopses
end

local function getFormattedSynopses(func, fullName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local list = {}
    local synopses = getSynopses(func, fullName)
    local variantCount = #synopses

    for index, synopsis in ipairs(synopses) do
        local prefix
        if variantCount > 1 then
            prefix = indent .. align.pad(index .. ". ", "", #indentString)
        else
            prefix = indent
        end

        table.insert(list, align.left(prefix .. synopsis, indentString:rep(indentLevel), nil, true))
    end

    return list
end

local function getTypedAttributes(variant, attribute, indentLevel, indentString)
    local indent
    indentString, indent = select(2, getIndentation(indentLevel, indentString))

    local typedAttributes = indent .. attribute:gsub("^%l", string.upper) .. ": ~" .. NEW_LINE_D

    if #(variant[attribute] or {}) == 0 then
        typedAttributes = typedAttributes .. indentString:rep(indentLevel + 1) .. "None"
    elseif attribute == "arguments" then
        typedAttributes = typedAttributes .. formatNeovimParameters(variant[attribute], indentLevel + 1, indentString)
    elseif attribute == "returns" then
        typedAttributes = typedAttributes .. formatNeovimReturns(variant[attribute], indentLevel + 1, indentString)
    else
        local items = {}
        for _, attr in ipairs(variant[attribute] or {}) do
            local item = indentString:rep(indentLevel + 1)
                .. "• {"
                .. formatDefaultValue(attr.name, attribute)
                .. "} ("
                .. formatDefaultValue(attr.type or "any", attr.type)
                .. ")"
            if attr.description then
                item = item .. NEW_LINE_S .. align.left(attr.description, indentString:rep(indentLevel + 2))
            end

            table.insert(items, item)
        end

        typedAttributes = typedAttributes .. table.concat(items, NEW_LINE_D)
    end

    return typedAttributes
end

local function getFormattedVariant(variant, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local result = ""
    local newLineAfterVariant = NEW_LINE_S

    if (variant.returns and #variant.returns > 0) or (variant.arguments and #variant.arguments > 0) then
        newLineAfterVariant = NEW_LINE_D
    end

    if variant.description == nil then
        result = align.left("See function description", indent) .. newLineAfterVariant
    elseif variant.description == "" then
        result = ""
    else
        result = align.left(variant.description, indent) .. newLineAfterVariant
    end

    if variant.arguments and #variant.arguments > 0 then
        result = result
            .. indent
            .. "Parameters: ~"
            .. NEW_LINE_S
            .. formatNeovimParameters(variant.arguments, indentLevel + 1, indentString)

        if variant.returns and #variant.returns > 0 then
            result = result .. NEW_LINE_D
        else
            result = result .. NEW_LINE_S
        end
    end

    if variant.returns and #variant.returns > 0 then
        result = result
            .. indent
            .. "Return"
            .. (#variant.returns > 1 and "s" or "")
            .. ": ~"
            .. NEW_LINE_S
            .. formatNeovimReturns(variant.returns, indentLevel + 1, indentString)
            .. NEW_LINE_S
    end

    return result
end

local function getFormattedVariants(func, fullName, indentLevel, indentString)
    indentLevel, indentString = getIndentation(indentLevel, indentString)

    local formattedSynopses = getFormattedSynopses(func, fullName, indentLevel, indentString)
    local variantCount = #func.variants
    local resultBegin = "Variant" .. (variantCount > 1 and "s" or "") .. ": ~" .. NEW_LINE_S
    return resultBegin
        .. concat(func.variants, NEW_LINE_S, function(index, variant)
            local result = formattedSynopses[index] .. NEW_LINE_D
            return result .. getFormattedVariant(variant, indentLevel, indentString)
        end)
end

local function getFunctionOverview(func, parentName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local fullName = parentName .. func.name

    local overview = formatTags(fullName)
        .. NEW_LINE_S
        .. align.left(formatAsReference(fullName), indent)
        .. NEW_LINE_D
        .. align.left(func.description, indent)
        .. NEW_LINE_D
        .. indent
        .. "Synopses: ~"
        .. NEW_LINE_S
        .. table.concat(getFormattedSynopses(func, fullName, indentLevel + 1, indentString), NEW_LINE_S)
        .. NEW_LINE_D
        .. indent
        .. getFormattedVariants(func, fullName, indentLevel + 1, indentString)

    return overview
end

local function listModulesFunctions(functions, functionPrefix, indentLevel, indentString)
    return printTableOfContents(functions, TAG_PREFIX .. functionPrefix, indentLevel, indentString)
end

local function getFormattedModuleFunctions(tab, functionPrefix, indentLevel, indentString)
    indentLevel, indentString = getIndentation(indentLevel, indentString)

    return concat(tab, NEW_LINE_S, function(_, func)
        return subsection() .. NEW_LINE_S .. getFunctionOverview(func, functionPrefix, indentLevel, indentString)
    end)
end

local function compileFormattedModuleFunctions(module, attribute, parentName, funcSeparator, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local functionPrefix = parentName .. funcSeparator
    module[attribute] = module[attribute] or {}

    local formattedModuleFunctions = subsection()
        .. NEW_LINE_S
        .. formatTags(parentName .. "-" .. attribute)
        .. NEW_LINE_S
        .. getBasicDescription(attribute, parentName, indent)
        .. NEW_LINE_D
        .. listModulesFunctions(module[attribute], parentName .. funcSeparator, indentLevel + 1, indentString)
        .. NEW_LINE_S

    if #module[attribute] == 0 then
        return formattedModuleFunctions
    else
        return formattedModuleFunctions
            .. NEW_LINE_S
            .. getFormattedModuleFunctions(module[attribute], functionPrefix, indentLevel, indentString)
    end
end

-- Types
local function getFormattedType(Type, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    Type.functions = Type.functions or {}
    local typePrefix = Type.name .. ":"

    local formattedType = subsection()
        .. NEW_LINE_S
        .. formatTags(Type.name)
        .. NEW_LINE_S
        .. align.left(formatAsReference(Type.name))
        .. NEW_LINE_D
        .. align.left(Type.description, indent)
        .. NEW_LINE_D
        .. printTOCWithTagAndDesc(Type, "constructors", "", indentLevel + 1, indentString)
        .. NEW_LINE_D
        .. printTOCWithTagAndDesc(Type, "supertypes", "", indentLevel + 1, indentString)
        .. NEW_LINE_D
        .. printTOCWithTagAndDesc(Type, "subtypes", "", indentLevel + 1, indentString)
        .. NEW_LINE_D
        .. printTOCWithTagAndDesc(Type, "functions", typePrefix, indentLevel + 1, indentString)

    if #Type.functions == 0 then
        return formattedType
    else
        return formattedType
            .. NEW_LINE_D
            .. getFormattedModuleFunctions(Type.functions, typePrefix, indentLevel, indentString)
    end
end

local function getFormattedTypes(types, indentLevel, indentString)
    return concat(types, NEW_LINE_D, function(_, Type)
        return getFormattedType(Type, indentLevel, indentString)
    end)
end

local function listModulesTypes(types, indentLevel, indentString)
    return printTableOfContents(types, TAG_PREFIX, indentLevel, indentString)
end

local function compileFormattedModuleTypes(module, parentName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    module.types = module.types or {}

    local formattedModuleTypes = subsection()
        .. NEW_LINE_S
        .. formatTags(parentName .. "-types")
        .. NEW_LINE_S
        .. getBasicDescription("types", parentName, indent)
        .. NEW_LINE_D
        .. listModulesTypes(module.types, indentLevel + 1, indentString)

    if #module.types == 0 then
        return formattedModuleTypes
    else
        return formattedModuleTypes .. NEW_LINE_D .. getFormattedTypes(module.types, indentLevel, indentString)
    end
end

-- Enums
local function getFormattedEnum(enum, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    for i in ipairs(enum.constants) do
        enum.constants[i].type = "string"
    end

    return subsection()
        .. NEW_LINE_S
        .. formatTags(enum.name)
        .. NEW_LINE_S
        .. align.left(formatAsReference(enum.name))
        .. NEW_LINE_D
        .. align.left(enum.description, indent)
        .. NEW_LINE_D
        .. getTypedAttributes(enum, "constants", indentLevel + 1, indentString)
end

local function getFormattedEnums(enums, indentLevel, indentString)
    return concat(enums, NEW_LINE_D, function(_, enum)
        return getFormattedEnum(enum, indentLevel, indentString)
    end)
end

local function listModulesEnums(enums, indentLevel, indentString)
    return printTableOfContents(enums, TAG_PREFIX, indentLevel, indentString)
end

local function compileFormattedModuleEnums(module, parentName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    module.enums = module.enums or {}

    local formattedEnums = subsection()
        .. NEW_LINE_S
        .. formatTags(parentName .. "-enums")
        .. NEW_LINE_S
        .. getBasicDescription("enums", parentName, indent)
        .. NEW_LINE_D
        .. listModulesEnums(module.enums, indentLevel + 1, indentString)
        .. NEW_LINE_S
    if #module.enums == 0 then
        return formattedEnums
    else
        return formattedEnums .. NEW_LINE_S .. getFormattedEnums(module.enums, indentLevel, indentString) .. NEW_LINE_S
    end
end

-- Output
local function compileModuleInformation(module, namePrefix, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local fullName = namePrefix .. module.name

    return section()
        .. NEW_LINE_S
        .. formatTags(fullName)
        .. NEW_LINE_S
        .. align.left(formatAsReference(fullName))
        .. NEW_LINE_D
        .. align.left(module.description, indent)
        .. NEW_LINE_D
        .. printTableOfContents(
            { "callbacks", "enums", "functions", "types" },
            TAG_PREFIX .. fullName .. "-",
            indentLevel + 1,
            indentString
        )
        .. NEW_LINE_D
        .. compileFormattedModuleFunctions(module, "callbacks", fullName, ".", indentLevel, indentString)
        .. NEW_LINE_S
        .. compileFormattedModuleEnums(module, fullName, indentLevel, indentString)
        .. NEW_LINE_S
        .. compileFormattedModuleFunctions(module, "functions", fullName, ".", indentLevel, indentString)
        .. NEW_LINE_S
        .. compileFormattedModuleTypes(module, fullName, indentLevel, indentString)
        .. NEW_LINE_S
end

print(([[*love2d-docs.txt* *LOVE* *love*       Documentation for the LÖVE game framework.

                               o  o                     ~
                       ╭─╮    ╭──────╮╭─╮    ╭─╮╭─────╮ ~
                       │ │    │ ╭──╮ ││ │    │ ││ ╭───╯ ~
                       │ │    │ │  │ │╰╮╰╮  ╭╯╭╯│ ╰───╮ ~
                       │ │    │ │  │ │ ╰╮╰╮╭╯╭╯ │ ╭───╯ ~
                       │ ╰───╮│ ╰──╯ │  ╰╮╰╯╭╯  │ ╰───╮ ~
                       ╰─────╯╰──────╯   ╰──╯   ╰─────╯ ~
                The complete solution for (Neo)Vim with LÖVE.
                            Includes documentation.

For LÖVE (http://love2d.org) version %s.

Generated from: ~
    https://github.com/love2d-community/love-api

Using: ~
    https://github.com/yorik1984/love2d-docs.nvim

Modified and maintained by: ~
    yorik1984 under the MIT license.

Original work by: ~
    Davis Claiborne under the MIT license.
    https://github.com/davisdude/vim-love-docs

See LICENSE.md for more info.
]]):format(api.version))

getLoveTypes(api)
for _, module in ipairs(api.modules) do
    getLoveTypes(module)
end

api.name = "love"
api.description = "The LÖVE framework"
print(compileModuleInformation(api, ""))

for _, module in ipairs(api.modules) do
    print(compileModuleInformation(module, "love."))
end

print(" vim" .. ":nospell:ft=help:tw=" .. PAGE_WIDTH)
