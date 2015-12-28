
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
        local font, leftMargin, componentLeftMargin, componentRightMargin = theme:value( "componentFont" ), theme:value( "leftMargin" ), theme:value( "componentLeftMargin" ), theme:value( "componentRightMargin" )
        local x = leftMargin
        for text in path:gmatch( "/([^/]*)" ) do
            local width = componentLeftMargin + font:getWidth( text ) + componentRightMargin,
            table.insert( pathComponents, {
                x = x;
                width = math.min( width, MAX_COMPONENT_WIDTH );
                text = text;
            } )
            x = x + width
        end
    end
end

function ToolbarPathTextBox:onDraw()
    self:super()
    local isFocused = self.isFocused
    if isFocused then
        local width, height, theme, canvas, path, pathComponents = self.width, self.height, self.theme, self.canvas, self.path, self.pathComponents
    
        local leftMargin, rightMargin, topMargin, bottomMargin, componentLeftMargin, componentRightMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" ), theme:value( "componentLeftMargin" ), theme:value( "componentRightMargin" )

        -- if there are too many components we'll chop out the first few until there is room
        local totalWidth = leftMargin + rightMargin
        local firstFullComponent = 1
        for i = #pathComponents, 1, -1 do
            local component = components[i]
            totalWidth = totalWidth + component.width
            if totalWidth > width then
                firstFullComponent = i + 1
            end
        end

        -- local pathComponents = path:match( "/([^/]*)" )
        -- log(textutils.serialize(pathComponents))
    end
end
