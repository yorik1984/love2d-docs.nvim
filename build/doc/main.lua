local api = require("love-api.love_api")
local align = require("align")

-- Local variables
local INDENT_STRING = "    "
local TAG_PREFIX = "love2d-docs-"
local NEW_LINE_S = "\n"
local NEW_LINE_D = "\n\n"

local PAGE_WIDTH = 80
align.setDefaultWidth(PAGE_WIDTH)

local TOC_NAME_WIDTH_LIMIT = 40
local TOC_NAME_REF_SPACING = 2

local LOVE_TYPES = {}

-- Misc. functions
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

local function formatAsReference(str)
    return ("|%s|"):format(str)
end

-- Formats arguments and return values
-- I'm not actually sure if there's a specific name for this formatting
local function formatSpecial(str)
    return ("`%s`"):format(str)
end

local function concat(tab, sep, func)
    local elements = {}

    for i, v in ipairs(tab) do
        table.insert(elements, func(i, v))
    end

    return table.concat(elements, sep)
end

local function concatAttribute(tab, sep, attr, formatFunc)
    formatFunc = formatFunc or function(v)
        return v
    end
    return concat(tab, sep, function(_, v)
        return formatFunc(v[attr])
    end)
end

-- Trims text that is surrounded by formatting without removing the formatting
-- `ThisIsTooLong` -> `ThisIs-` if with = 7
local function trimFormattedText(str, width, formatFunc)
    local formattedStr = formatFunc(str)

    -- Allows for the formatting func perform differently based on #str
    while #formattedStr > width do
        str = str:sub(1, -2)
        formattedStr = formatFunc(str .. "-")
    end

    return formattedStr
end

-- Prints a table of contents of `tab` in the format:
--
-- attributeName              tagPrefix .. attributeName
--
-- Where `attributeName` is either `tab[i].name` or `tab[i]`
-- `attributeName` is trimmed to be within `TOC_NAME_WIDTH_LIMIT` (including indent)
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

-- Handles the most basic and common case of a table of contents, with a basic
-- tag and description
local function printTOCWithTagAndDesc(tab, attribute, tagPrefix, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    return align.right(formatAsTag(TAG_PREFIX .. tab.name .. "-" .. attribute))
        .. NEW_LINE_S
        -- Basic identifier
        .. align.left(attribute:gsub("^%l", string.upper) .. ": ~", indent)
        .. NEW_LINE_S
        -- Table of contents
        .. printTableOfContents(tab[attribute], TAG_PREFIX .. tagPrefix, indentLevel + 1, indentString)
end

-- Gets a *very* basic (aligned/indented) description
local function getBasicDescription(attribute, moduleName, indent)
    indent = indent or ""
    return align.left("The " .. attribute .. " of " .. formatAsReference(moduleName) .. ":", indent)
end

-- Functions
-- Gets a synopsis of a function variant
-- Synopsis: return1, return2 = func(arg1, arg2)
local function formatDefaultValue(value)
    if type(value) == "table" then
        return "{...}"
    else
        return tostring(value):gsub("%s+", "")
    end
end

local function formatTypedAttribute(value, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local typedAttribute =
        align.left(formatSpecial(value.name) .. ": " .. ((formatDefaultValue(value.type)) or "any"), indent)

    if LOVE_TYPES[value.type] then
        typedAttribute = typedAttribute .. " |love2d-docs-" .. value.type .. "|"
    end

    if value.default ~= nil then
        typedAttribute = typedAttribute .. " (default: `" .. formatDefaultValue(value.default) .. "`)"
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
        .. "} (`"
        .. (formatDefaultValue(param.type) or "any")
        .. "`)"

    if LOVE_TYPES[param.type] then
        paramLine = paramLine .. " |love2d-docs-" .. param.type .. "|"
    end

    if param.default ~= nil then
        paramLine = paramLine .. " (default: `" .. formatDefaultValue(param.default) .. "`)"
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

    local typeStr = formatDefaultValue(ret.type) or "any"

    local returnLine = prefix .. "(`" .. typeStr .. "`)"

    if ret.name and ret.name ~= "" then
        returnLine = returnLine .. " `" .. ret.name .. "`"
    end

    if LOVE_TYPES[ret.type] then
        returnLine = returnLine .. " |love2d-docs-" .. ret.type .. "|"
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

    -- Return values
    if #(variant.returns or {}) > 0 then
        local returns = concatAttribute(variant.returns, ", ", "name", formatSpecial)
        synopsis = returns .. " = " .. synopsis
    end

    -- Arguments
    if #(variant.arguments or {}) == 0 then
        synopsis = synopsis .. "()"
    else
        local arguments = concatAttribute(variant.arguments, ", ", "name", formatSpecial)
        synopsis = synopsis .. "(" .. arguments .. ")"
    end

    return synopsis
end

-- Assembles a list of a function's synopses as a table
local function getSynopses(func, fullName)
    local synopses = {}

    for _, variant in ipairs(func.variants) do
        table.insert(synopses, getSynopsis(variant, fullName))
    end

    return synopses
end

-- Lists all of a function's synopses
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

-- Formats the arguments/return values of a function variant
local function getTypedAttributes(variant, attribute, indentLevel, indentString)
    local indent
    indentString, indent = select(2, getIndentation(indentLevel, indentString))

    -- Begins the typedAttributes information
    local typedAttributes = indent .. attribute .. ": ~" .. NEW_LINE_D

    -- Handles formatting for functions that don't have any arguments/returns
    if #(variant[attribute] or {}) == 0 then
        typedAttributes = typedAttributes .. indentString:rep(indentLevel + 1) .. "None"
    elseif attribute == "arguments" then
        typedAttributes = typedAttributes .. formatNeovimParameters(variant[attribute], indentLevel + 1, indentString)
    elseif attribute == "returns" then
        typedAttributes = typedAttributes .. formatNeovimReturns(variant[attribute], indentLevel + 1, indentString)
    else
        typedAttributes = typedAttributes
            -- Separates all of the attributes
            .. concat(variant[attribute], NEW_LINE_D, function(_, attr)
                return formatTypedAttribute(attr, indentLevel + 1, indentString)
            end)
    end

    return typedAttributes
end

-- Gets the all of a variant's information
local function getFormattedVariant(variant, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local result = ""

    if variant.arguments and #variant.arguments > 0 then
        result = result .. NEW_LINE_D
    else
        result = result .. NEW_LINE_S
    end

    -- Prevent if description is empty
    if variant.description == nil then
        result = align.left("See function description", indent) .. result
    elseif variant.description == "" then
        result = ""
    else
        result = align.left(variant.description, indent) .. result
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

-- Formats the contents of all of a function's variants
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

-- Compiles all of the information about a function
-- Includes details such as the function's description, variants and their parameters, etc.
local function getFunctionOverview(func, parentName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local fullName = parentName .. func.name

    local overview = align.right(formatAsTag(TAG_PREFIX .. fullName))
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

-- Lists the functions of a module (or type) in a properly formatted list
local function listModulesFunctions(functions, functionPrefix, indentLevel, indentString)
    return printTableOfContents(functions, TAG_PREFIX .. functionPrefix, indentLevel, indentString)
end

-- Gets a module's formatted functions (descriptions, parameters, return values, etc.)
local function getFormattedModuleFunctions(tab, functionPrefix, indentLevel, indentString)
    indentLevel, indentString = getIndentation(indentLevel, indentString)

    return concat(tab, NEW_LINE_S, function(_, func)
        return subsection() .. NEW_LINE_S .. getFunctionOverview(func, functionPrefix, indentLevel, indentString)
    end)
end

-- Shows all of the functions of a module, then gives the formatted functions
-- `attribute` is either 'callbacks' or 'functions'
local function compileFormattedModuleFunctions(module, attribute, parentName, funcSeparator, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local functionPrefix = parentName .. funcSeparator
    module[attribute] = module[attribute] or {}

    local formattedModuleFunctions = subsection()
        .. NEW_LINE_S
        .. align.right(formatAsTag(TAG_PREFIX .. parentName .. "-" .. attribute))
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
-- Gets all of a type's information (constructors, supertypes, subtypes, etc.)
-- Also includes its description and tag
local function getFormattedType(Type, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    Type.functions = Type.functions or {}
    local typePrefix = Type.name .. ":"

    local formattedType = subsection()
        .. NEW_LINE_S
        .. align.right(formatAsTag(TAG_PREFIX .. Type.name))
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

-- Combines all of a module's formatted types
local function getFormattedTypes(types, indentLevel, indentString)
    return concat(types, NEW_LINE_D, function(_, Type)
        return getFormattedType(Type, indentLevel, indentString)
    end)
end

-- Lists the types of a module in a properly formatted list
local function listModulesTypes(types, indentLevel, indentString)
    return printTableOfContents(types, TAG_PREFIX, indentLevel, indentString)
end

-- Shows all the formatted types of a module, then gets the formatted the types
-- Also includes a basic description and tag
local function compileFormattedModuleTypes(module, parentName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    module.types = module.types or {}

    local formattedModuleTypes = subsection()
        .. NEW_LINE_S
        .. align.right(formatAsTag(TAG_PREFIX .. parentName .. "-types"))
        .. NEW_LINE_S
        .. getBasicDescription("types", parentName, indent)
        .. NEW_LINE_D
        .. listModulesTypes(module.types, indentLevel + 1, indentString)

    -- Gets the formatted types
    if #module.types == 0 then
        return formattedModuleTypes
    else
        return formattedModuleTypes .. NEW_LINE_D .. getFormattedTypes(module.types, indentLevel, indentString)
    end
end

-- Enums
-- Gets all of an enum's information
-- Also includes its tag, description, etc.
local function getFormattedEnum(enum, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    -- Adds a type to all constants to work with getTypedAttributes
    for i in ipairs(enum.constants) do
        enum.constants[i].type = "string"
    end

    return subsection()
        .. NEW_LINE_S
        .. align.right(formatAsTag(TAG_PREFIX .. enum.name))
        .. NEW_LINE_S
        .. align.left(formatAsReference(enum.name))
        .. NEW_LINE_D
        .. align.left(enum.description, indent)
        .. NEW_LINE_D
        .. getTypedAttributes(enum, "constants", indentLevel + 1, indentString)
end

-- Combines all of a module's formatted enums
local function getFormattedEnums(enums, indentLevel, indentString)
    return concat(enums, NEW_LINE_D, function(_, enum)
        return getFormattedEnum(enum, indentLevel, indentString)
    end)
end

-- Lists the enums of a module in a properly formatted list
local function listModulesEnums(enums, indentLevel, indentString)
    return printTableOfContents(enums, TAG_PREFIX, indentLevel, indentString)
end

-- Assembles all of a module's enums and information, including enums' constants, etc.
local function compileFormattedModuleEnums(module, parentName, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    module.enums = module.enums or {}

    local formattedEnums = subsection()
        .. NEW_LINE_S
        .. align.right(formatAsTag(TAG_PREFIX .. parentName .. "-enums"))
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

-- Output-- Combines all of a module's information
local function compileModuleInformation(module, namePrefix, indentLevel, indentString)
    local indent
    indentLevel, indentString, indent = getIndentation(indentLevel, indentString)

    local fullName = namePrefix .. module.name

    return section()
        .. NEW_LINE_S
        .. align.right(formatAsTag(TAG_PREFIX .. fullName))
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

print(([[*love2d-docs.txt* *love2d-docs*      Documentation for the LÖVE game framework.

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

-- Gets table information to know how to format types
getLoveTypes(api)
for _, module in ipairs(api.modules) do
    getLoveTypes(module)
end

-- Gives the love module basic information
api.name = "love"
api.description = "The LÖVE framework"
print(compileModuleInformation(api, ""))

for _, module in ipairs(api.modules) do
    print(compileModuleInformation(module, "love."))
end

-- Prints modeline (spelling/capitalization errors are ugly; use correct file type)
-- (Uses concat to prevent vim from interpreting THIS as a modeline)
print(" vim" .. ":nospell:ft=help:tw=" .. PAGE_WIDTH)
