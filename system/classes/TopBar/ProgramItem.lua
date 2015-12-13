
local ICON_WIDTH = 9
local ICON_HEIGHT = 9

local ICON_TITLE_GAP = 3
local TITLE_STATUS_GAP = 4
local MIN_MARGIN = 4

class "ProgramItem" extends "TopBarItem" {
    
    isActive = Boolean( false );
    program = Program;

}

function ProgramItem:onDraw()
    self:super()
    local width, height, theme, canvas, program = self.width, self.height, self.theme, self.canvas, self.program

    local leftMargin, rightMargin, topMargin, bottomMargin, iconTitleMargin, titleStatusMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" ), theme:value( "iconTitleMargin" ), theme:value( "titleStatusMargin" )
    local maxContentWidth = width - leftMargin - rightMargin

    local titleFont, statusFont = theme:value( "titleFont" ), theme:value( "statusFont" )
    local programTitle, programStatus = program.title, program.status or ""
    local titleWidth, statusWidth = titleFont:getWidth( programTitle ), statusFont:getWidth( programStatus )
    
    local configs = {
        { ICON_WIDTH + iconTitleMargin + titleWidth + titleStatusMargin + statusWidth, true, true, true };
        { titleWidth + titleStatusMargin + statusWidth, false, true, true };
        { ICON_WIDTH + iconTitleMargin + titleWidth, true, true, false };
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
        local iconMask = RectangleMask( x, 1 + topMargin, ICON_WIDTH, ICON_HEIGHT )
        canvas:fill( Graphics.colours.GREEN, iconMask )
        x = x + ICON_WIDTH + (selectedConfig[3] and iconTitleMargin or 0)
    end

    -- Title
    if selectedConfig[3] then
        canvas:fill( theme:value( "titleColour" ), TextMask( x, 1 + topMargin, titleWidth, titleFont.height, programTitle, titleFont ) )
        x = x + titleWidth + (selectedConfig[4] and titleStatusMargin or 0)
    end

    -- Status
    if selectedConfig[4] then
        canvas:fill( theme:value( "statusColour" ), TextMask( x, 1 + topMargin, statusWidth, statusFont.height, programStatus, statusFont ) )
    end
end

function ProgramItem:updateThemeStyle()
    self.theme.style = self.isPressed and "pressed" or ( self.program.programView.isFocused and "focused" or "default" )
end

function ProgramItem.program:set( program )
    self.program = program
    self.needsDraw = true
    self:updateThemeStyle()
end

function ProgramItem:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
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