
local ANIMATION_FLY_TIME = 0.6
local ANIMATION_FLY_UP_TIME = 0.5
local ANIMATION_SCALE_TIME = 0.5
local ANIMATION_FLY_DELAY = 0.05
local ANIMATION_FLY_EASING = Animation.easings.IN_SINE
local ANIMATION_SCALE_EASING = Animation.easings.OUT_SINE
local ANIMATION_SCALE = 0.8
local ANIMATION_OVERLAP_TIME = 0.20

class "ProgramView" extends "View" implements "ISwitchableView" {
    
    redirect = Table;
    program = Program;
    terminalObject = TerminalObject;
    scale = Number( 1 );
    isClosing = Boolean( false );
    isOpening = Boolean( true );
    isFocusDismissable = Boolean( false );
    termSizes = Table( { width = 1; height = 1 } );
    buffer = Table( {} )

}

function ProgramView:initialise( ... )
    self:super( ... )

    local termSizes = self.termSizes
    termSizes.width = self.width
    termSizes.height = self.height
    self.redirect = self:getRedirect()

    self:event( MouseEvent, self.onMouseEvent )
    self:event( KeyEvent, self.onKeyEvent )
    self:event( CharacterEvent, self.onCharacterEvent )
    self:event( FocusesChangedInterfaceEvent, self.onFocusesChanged )
    self:event( ParentChangedInterfaceEvent, self.onParentChanged )
end

function ProgramView:onDraw()
    local width, height, theme, canvas, buffer, scale = self.width, self.height, self.theme, self.canvas, self.buffer, self.scale

    local pixels = canvas.pixels
    local fillColour = theme:value( "fillColour" )
    local TRANSPARENT = Graphics.colours.TRANSPARENT

    local termSizes = self.termSizes
    if termSizes.needsDraw then
        termSizes.needsDraw = false
    end

    if scale == 1 then
        for i = 1, #buffer do
            local colour = buffer[i] or fillColour
            pixels[i] = colour == TRANSPARENT and fillColour or colour
        end
    else
        local scaledWidth, scaledHeight = math.floor( width * scale + 0.5 ), math.floor( height * scale + 0.5 )
        local ceil = math.ceil
        local widthRatio = width / scaledWidth
        local heightRatio = height / scaledHeight
        local xMin, yMin = math.floor( ( width - scaledWidth ) / 2 ) + 1, math.floor( ( height - scaledHeight ) / 2 )

        for x = 1, scaledWidth do
            for y = 0, scaledHeight - 1 do -- just so there's no need for y-1 below
                local colour = buffer[ceil( y * heightRatio ) * width + ceil( x * widthRatio )] or TRANSPARENT
                local nx, ny = x + xMin, y + yMin
                if colour ~= TRANSPARENT and nx >= 1 and ny >= 1 and nx <= width and ny <= height then
                    pixels[( ny - 1 ) * width + nx] = colour
                end
            end
        end
    end
end

function ProgramView.width:set( width )
    self:super( width )
    self.termSizes.width = width
end

function ProgramView.height:set( height )
    self:super( height )
    self.termSizes.height = height
end

function ProgramView.scale:set( scale )
    if self.scale ~= scale then
        self.scale = scale
        self.needsDraw = true
    end
end

function ProgramView:onParentChanged( ParentChangedInterfaceEvent event, Event.phases phase )
    self.scale = ANIMATION_SCALE
    self.y = self.height + 1
    self:animate( "y", 15, ANIMATION_FLY_UP_TIME, function()
        self.isOpening = false
    end, ANIMATION_SCALE_EASING, ANIMATION_SCALE_TIME )
    self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_SCALE_TIME + ANIMATION_FLY_UP_TIME - ANIMATION_OVERLAP_TIME, false)
    -- self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_SCALE_TIME + ANIMATION_FLY_UP_TIME - ANIMATION_OVERLAP_TIME, false)
end

function ProgramView.isFocused:set( isFocused )
    self:super( isFocused )
end

function ProgramView:onFocusesChanged( FocusesChangedInterfaceEvent event, Event.phases phase )
    local oldContains = event:didContain( self )
    local contains = event:contains( self )
    if oldContains ~= contains then
        -- local program = self.program
        if contains and not self.isOpening then
            local oldSwitchableView = self.application:focusesOfType( ISwitchableView, event.oldFocuses )[1]
            local fromLeft = false
            if oldSwitchableView:typeOf( ProgramView ) then
                if oldSwitchableView and oldSwitchableView.program.index > self.program.index then
                    fromLeft = true
                end
            end
            self:flyInFocused( fromLeft )
        elseif oldContains and not self.isClosing then
            self.isOpening = false
            local newSwitchableView = self.application:focusesOfType( ISwitchableView )[1]
            local toRight = true
            if newSwitchableView:typeOf( ProgramView ) then
                if newSwitchableView and newSwitchableView.program.index > self.program.index then
                    toRight = false
                end
            end
            self:flyOutFocused( toRight )
        end
    end
end

function ProgramView:closeFlyUp( ready )
    self.isClosing = true
    self.parent:sendToBack( self )
    self:animate( "scale", ANIMATION_SCALE, ANIMATION_SCALE_TIME, function()
        ready()
    end, ANIMATION_SCALE_EASING, nil, false )
    self:animate( "y", -self.height, ANIMATION_FLY_UP_TIME, function()
        self:dispose()
    end, ANIMATION_SCALE_EASING, ANIMATION_SCALE_TIME - ANIMATION_OVERLAP_TIME )--ANIMATION_FLY_DELAY )
end

function ProgramView:flyInFocused( fromLeft )
    self.scale = 0.8
    local width = self.width
    self.x = fromLeft and -width or 1 + width
    self:animate( "x", 1, ANIMATION_FLY_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_FLY_TIME/2 - 0.1 )
    self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_FLY_TIME - 0.1, false )
end

function ProgramView:flyOutFocused( toRight )
    local width = self.width
    local x = toRight and 1 + width or -width
    self:animate( "x", x, ANIMATION_FLY_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_FLY_TIME/2 - 0.1 )
    self:animate( "scale", 0.8, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, nil, false )

end

function ProgramView:onMouseEvent( MouseEvent event, Event.phases phase )
    self.program:queueEvent( event.eventType, event.mouseButton, event.x, event.y  )
    return true
end

function ProgramView:onKeyEvent( KeyEvent event, Event.phases phase )
    self.program:queueEvent( event.eventType, event.keyCode  )
end

function ProgramView:onCharacterEvent( CharacterEvent event, Event.phases phase )
    self.program:queueEvent( event.eventType, CharacterEvent  )
end

function ProgramView:getRedirect()
    local term = {}
    local termSizes = self.termSizes

    local colour, termX, termY, cursorBlink = Graphics.colours.BLACK, 1, 1

    local buffer = self.buffer
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    local function setPixel( x, y, c )
        local termWidth = termSizes.width
        if c ~= TRANSPARENT and x >= 1 and y >= 1 and x <= termWidth and y <= termSizes.height then
            local pos = ( y - 1 ) * termWidth + x
            if buffer[ pos ] ~= c then
                buffer[ pos ] = c
                if not termSizes.needsDraw then
                    termSizes.needsDraw = true
                    self.needsDraw = true
                end
            end
        end
    end

    function term.write( s )
        s = tostring( s ) -- we don't really care what s is. this whole thing will need to be redone when we actually get the real thing
        for i = 1, math.min( #s, termSizes.width - termX + 1 ) do
            setPixel( termX + i - 1, termY, colour )
        end
        termX = termX + #s
    end

    function term.blit( s, t, b )
        if #s ~= #b or #s ~= #t then
            return error "arguments must be the same length"
        end
        for i = 1, math.min( #s, termSizes.width - termX + 1 ) do
            setPixel( termX + i - 1, termY, colourBytes[ b:byte( i ) ] )
        end
        termX = termX + #s
    end

    function term.clear()
        local height = termSizes.height
        for x = 1, termSizes.width do
            for y = 1, height do
                setPixel( x, y, colour )
            end
        end
    end

    function term.clearLine()
        for x = 1, termSizes.width do
            setPixel( x, termY, colour )
        end
    end

    function term.getCursorPos()
        return termX, termY
    end

    function term.setCursorPos( x, y )
        termX = math.floor( x )
        termY = math.floor( y )
    end

    function term.setCursorBlink( state )
        -- This does zilch
    end

    function term.getSize()
        return termSizes.width, termSizes.height
    end

    function term.scroll( n )
        local offset = n * termSizes.width
        local n, f, s = n < 0 and termSizes.width * termSizes.height or 1, n < 0 and 1 or termSizes.width * termSizes.height, n < 0 and -1 or 1
        for i = n, f, s do
            buffer[i] = buffer[i + offset] or colour
        end
    end

    function term.isColour()
        return true
    end

    function term.setBackgroundColour( backgroundColour )
        colour = backgroundColour
    end

    function term.setTextColour( colour )
        -- This does zilch
    end

    function term.getBackgroundColour()
        return colour
    end

    function term.getTextColour()
        return colours.white
    end

    term.isColor = term.isColour
    term.setBackgroundColor = term.setBackgroundColour
    term.setTextColor = term.setTextColour
    term.getBackgroundColor = term.getBackgroundColour
    term.getTextColor = term.getTextColour

    return term
end
