-- Align monospaced text

-- Variables that control the output
local defaultWidth = 80
local tabWidth = 4
local tolerance = 4
local fillThreshold = 0.7
local tabStr = (" "):rep(tabWidth)

-- Change the global defaultWidth
local function setDefaultWidth(n)
    defaultWidth = n
end

-- Change the global tabWidth
local function setTabWidth(n)
    tabWidth = n
end

-- Set the tab string
local function setTabStr(str)
    tabStr = str
end

-- Add a new line
local function newLine(currentLine, fill, textWidth, determineSpacing)
    local returnString = ""

    -- Ignore blank lines/lines that consist solely of whitespace
    if #currentLine > 0 then
        returnString = fill:rep(determineSpacing(currentLine, textWidth)) .. currentLine
    end

    return returnString .. "\n"
end

-- Loop over words (separated by spaces) with tolerance for widows/orphans
local function loopOverTextByWord(line, fill, textWidth, spacingFunc)
    -- Add space to beginning of line to make linebreaks easier to determine
    line = " " .. line

    -- Used to trim the space added to the beginning of the line
    local first = true

    -- Collect all words for analysis
    local words = {}
    line:gsub("(%s+)(%S+)", function(spacing, word)
        if first then
            spacing = spacing:match("^%s(.*)$")
            first = false
        end
        table.insert(words, { spacing = spacing, word = word })
    end)

    -- Reset first flag for the actual processing
    first = true
    local currentLine, output = "", ""
    local i = 1

    while i <= #words do
        local wordData = words[i]
        local spacing = wordData.spacing
        local word = wordData.word

        -- Check if word fits in current line
        if #currentLine + #spacing + #word <= textWidth then
            currentLine = currentLine .. spacing .. word
            i = i + 1
        else
            -- Line needs to be wrapped
            if #currentLine == 0 then
                -- If currentLine is blank and word is too long, hyphenate it
                while #word > textWidth do
                    currentLine = word:sub(1, textWidth - 1) .. "-"
                    output = output .. newLine(currentLine, fill, textWidth, spacingFunc)
                    word = word:sub(textWidth)
                end
                currentLine = word
                i = i + 1
            else
                -- Check if this is the last word (potential widow/orphan)
                if i == #words then
                    -- If current line is reasonably full, try to keep the word here
                    if #currentLine > textWidth * fillThreshold then
                        -- Check if it fits with tolerance
                        if #currentLine + #spacing + #word <= textWidth + tolerance then
                            currentLine = currentLine .. spacing .. word
                            i = i + 1
                        else
                            output = output .. newLine(currentLine, fill, textWidth, spacingFunc)
                            currentLine = word
                            i = i + 1
                        end
                    else
                        output = output .. newLine(currentLine, fill, textWidth, spacingFunc)
                        currentLine = word
                        i = i + 1
                    end
                else
                    -- Not the last word, normal wrap
                    output = output .. newLine(currentLine, fill, textWidth, spacingFunc)
                    currentLine = word
                    i = i + 1
                end
            end
        end
    end

    -- Add any remaining content
    output = output .. newLine(currentLine, fill, textWidth, spacingFunc)
    return output
end

-- Loop over the string by lines to respect new lines
local function loopOverTextByLine(text, fill, textWidth, spacingFunc)
    -- Add a new line to text to handle all cases (removed later)
    text = text .. "\n"

    local output = ""
    text:gsub("(.-)\n", function(line)
        output = output .. loopOverTextByWord(line, fill, textWidth, spacingFunc)
    end)

    -- Trim the last new line, which was only added for easier looping
    return output:match("^(.-)\n$")
end

-- Determine the number of spaces required to right-align currentLine
local function determineRightAlignSpacing(currentLine, textWidth)
    return textWidth - #currentLine
end

-- Right-align text to a given width
-- TODO: allow multi-character fill
-- fill is what to use to pad the width of the text (must be one character)
local function alignRight(text, fill, textWidth)
    fill = fill or " "
    textWidth = textWidth or defaultWidth

    return loopOverTextByLine(text, fill, textWidth, determineRightAlignSpacing)
end

-- Left-align text to a given width
local function alignLeft(text, indentStr, textWidth, doNotIndentFirstLine)
    indentStr = indentStr or ""
    doNotIndentFirstLine = doNotIndentFirstLine or false

    -- Account for indentStr in text wrapping
    textWidth = (textWidth or defaultWidth) - #indentStr

    return loopOverTextByLine(text, indentStr, textWidth, function()
        local result = doNotIndentFirstLine and 0 or 1
        doNotIndentFirstLine = false
        return result
    end)
end

-- Pad text
-- fill is the character (or series of characters) that should pad the text to the desired with
local function alignPad(text, fill, width)
    fill = fill or " "
    width = width or defaultWidth

    -- Cut text if it's too long
    if #text >= width then
        text = text:sub(1, width - 1) .. "-"
    end

    return (text .. fill:rep(math.ceil(width - #text / #fill))):sub(1, width)
end

return {
    setDefaultWidth = setDefaultWidth,
    setTabWidth = setTabWidth,
    setTabStr = setTabStr,
    right = alignRight,
    left = alignLeft,
    pad = alignPad,
}
