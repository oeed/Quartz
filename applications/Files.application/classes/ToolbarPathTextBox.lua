
local fs = Quartz.fs
local MAX_COMPONENT_WIDTH = 70

class "ToolbarPathTextBox" extends "TextBox" implements "IToolbarItem" implements "IToolbarDynamicItem" {
    
    path = String( "/" );
    pathComponents = Table;

}

function ToolbarPathTextBox.isFocused:set( isFocused )
    self:super( isFocused )
    if isFocused then
        local path = self.path
        self.text = path
        self.cursorPosition = #path + 1
    else
        local text = self.text
        if text ~= self.path then
            self.path = text
        end
        self.text = ""
    end
end

function ToolbarPathTextBox.path:set( path )
    if path:sub( 1, 1) ~= "/" then
        path = "/" .. path
    end
    path = FileSystemItem.static:resolve( path )
    if fs.exists( path ) then
        self.path = path

        local pathComponents = {}
        local theme = self.theme
        local font, leftMargin, componentLeftMargin, componentRightMargin = theme:value( "componentFont" ), theme:value( "leftMargin" ), theme:value( "componentLeftMargin" ), theme:value( "componentRightMargin" )
        for text in path:gmatch( "/([^/]*)" ) do
            local width = componentLeftMargin + font:getWidth( text ) + componentRightMargin
            table.insert( pathComponents, {
                width = math.min( width, MAX_COMPONENT_WIDTH );
                text = text;
            } )
        end
        self.pathComponents = pathComponents
    end
end

function ToolbarPathTextBox:onDraw()
    self:super()
    local isFocused = self.isFocused
    if not isFocused then
        local width, height, theme, canvas, path, pathComponents = self.width, self.height, self.theme, self.canvas, self.path, self.pathComponents
        local font, componentLeftMargin, componentRightMargin, componentFirstLeftMargin, leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "componentFont" ), theme:value( "componentLeftMargin" ), theme:value( "componentRightMargin" ), theme:value( "componentFirstLeftMargin" ), theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )

        -- if there are too many components we'll chop out the first few until there is room
        local totalWidth = leftMargin + rightMargin
        local firstFullComponent = 1
        local symbol = theme:value( "componentSymbol" )
        local symbolWidth, symbolHeight = symbol.width, symbol.height
        local ellipsisWidth = componentLeftMargin + font:getWidth( "..." ) + componentRightMargin
        local pathComponentsCount = #pathComponents
        for i = pathComponentsCount, 1, -1 do
            local component = pathComponents[i]
            totalWidth = totalWidth + component.width + ( i ~= pathComponentsCount and symbolWidth or 0 )
            if totalWidth + ellipsisWidth > width then
            firstFullComponent = i + 1
            end
        end

        local componentTextColour = theme:value( "componentTextColour" )
        local componentSymbolColour = theme:value( "componentSymbolColour" )
        local x = 1 + leftMargin - componentLeftMargin
        local symbolY = math.ceil( ( height - symbolHeight ) / 2 ) + 1
        for i = 1, pathComponentsCount do
            local text, width
            if firstFullComponent == i + 1 then
                text = "..."
                width = ellipsisWidth
            elseif firstFullComponent <= i then
                local component = pathComponents[i]
                text = component.text
                width = component.width
            end
            if text then
                canvas:fill( componentTextColour, TextMask( x + componentLeftMargin, 1 + topMargin, width - componentLeftMargin - componentRightMargin, height - topMargin - bottomMargin, text, font ) )
                if i ~= pathComponentsCount then
                    canvas:fill( theme:value( "componentSymbolColour" ), SymbolMask( x + width, symbolY, symbol ) )
                end
                x = x + width + symbolWidth
            end
        end
    end
end
