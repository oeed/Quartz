
local ICON_WIDTH = 9
local ICON_HEIGHT = 9

local ICON_TITLE_GAP = 3
local TITLE_STATUS_GAP = 4
local MIN_MARGIN = 4

class "ProgramItem" extends "TopBarItem" {
    
    isActive = false;
    
    program = false;

    titleObject = false;
    statusObject = false;
    iconObject = false;

}

function ProgramItem:initialiseCanvas()
    self:super()
    local width, height, theme, canvas, program = self.width, self.height, self.theme, self.canvas, self.program
    local titleObject = canvas:insert( Text( 1, 4, width, 8, program and program.title or "", Font.systemFont ) )
    local statusObject = canvas:insert( Text( 1, 4, width, 8, program and program.status or "", Font.systemFont ) )
    local iconObject = canvas:insert( Rectangle( 1, 3, ICON_WIDTH, ICON_HEIGHT, Graphics.colours.GREEN ) )

    theme:connect( titleObject, "textColour", "titleColour" )
    theme:connect( statusObject, "textColour", "statusColour" )
    
    self.titleObject = titleObject
    self.statusObject = statusObject
    self.iconObject = iconObject
end

function ProgramItem:updateThemeStyle()
    self.theme.style = self.isPressed and "pressed" or ( self.program.programView.isFocused and "focused" or "default" )
end

function ProgramItem.program:set( program )
    self.program = program
    local titleObject, statusObject = self.titleObject, self.statusObject
    local title, status = program.title, program.status
    titleObject.text = title
    titleObject.width = titleObject.font:getWidth( title )

    statusObject.text = status
    statusObject.width = statusObject.font:getWidth( status )
    self:updateThemeStyle()
end

function ProgramItem:updateWidth( width )
    self:super( width )

    local titleObject, iconObject, statusObject = self.titleObject, self.iconObject, self.statusObject
    local titleWidth = titleObject.width
    local statusWidth = statusObject.width
    
    local iconX, titleX, statusX

    local maxContentWidth = width - 2 * MIN_MARGIN

    local configs = {
        { ICON_WIDTH + ICON_TITLE_GAP + titleWidth + TITLE_STATUS_GAP + statusWidth, true, true, true };
        { titleWidth + TITLE_STATUS_GAP + statusWidth, false, true, true };
        { ICON_WIDTH + ICON_TITLE_GAP + titleWidth, true, true, false };
        { titleWidth, false, true, false };
        { ICON_WIDTH, true, false, false };
    }

    local selectedConfig
    for i, config in ipairs( configs ) do
        if maxContentWidth >= config[1] then
            selectedConfig = config
            break
        end
    end
    selectedConfig = selectedConfig or configs[#configs] -- none of them fit, revert to icon

    local x = math.floor( ( width - selectedConfig[1] ) / 2 ) + 1
    -- Icon
    if selectedConfig[2] then
        iconObject.x = x
        x = x + ICON_WIDTH + (selectedConfig[3] and ICON_TITLE_GAP or 0)
        iconObject.isVisible = true
    else
        iconObject.isVisible = false
    end

    -- Title
    if selectedConfig[3] then
        titleObject.x = x
        x = x + titleWidth + (selectedConfig[4] and TITLE_STATUS_GAP or 0)
        titleObject.isVisible = true
    else
        titleObject.isVisible = false
    end

    -- Status
    if selectedConfig[4] then
        statusObject.x = x
        statusObject.isVisible = true
    else
        statusObject.isVisible = false
    end

end

function ProgramItem:onGlobalMouseUp( event )
    local wasPressed = true--self.isPressed
    self:super( event )
    if wasPressed and self:hitTestEvent( event ) then
        if event.mouseButton == MouseEvent.mouseButtons.LEFT then
            self.program:focus()
            self:updateThemeStyle()
        elseif event.mouseButton == MouseEvent.mouseButtons.MIDDLE then
            self.program:close()
        end
    end
end