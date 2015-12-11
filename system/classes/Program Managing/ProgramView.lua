
local ANIMATION_FLY_TIME = 0.6
local ANIMATION_FLY_UP_TIME = 0.5
local ANIMATION_SCALE_TIME = 0.5
local ANIMATION_FLY_DELAY = 0.05
local ANIMATION_FLY_EASING = Animation.easings.IN_SINE
local ANIMATION_SCALE_EASING = Animation.easings.OUT_SINE
local ANIMATION_SCALE = 0.8
local ANIMATION_OVERLAP_TIME = 0.20

class "ProgramView" extends "View" implements "ISwitchableView" {
    
    redirect = false;
    program = false;
    terminalObject = false;
    scale = 1;
    isClosing = false;
    isOpening = true;
    isFocusDismissable = false;

}

function ProgramView:initialise( ... )
    self.super:initialise( ... )

    self:event( MouseDownEvent, self.onMouseEvent )
    self:event( MouseDragEvent, self.onMouseEvent )
    self:event( MouseUpEvent, self.onMouseEvent )
    self:event( KeyUpEvent, self.onKeyEvent )
    self:event( KeyDownEvent, self.onKeyEvent )
    self:event( CharacterEvent, self.onCharacterEvent )
    self:event( FocusesChangedInterfaceEvent, self.onFocusesChanged )
    self:event( ParentChangedInterfaceEvent, self.onParentChanged )
end

function ProgramView:initialiseCanvas()
    self.super:initialiseCanvas()
    local terminalObject = self.canvas:insert( TerminalObject( 1, 1, self.width, self.height ) )
    self.redirect = terminalObject.redirect
    self.terminalObject = terminalObject
end

function ProgramView:onParentChanged( event )
    self.scale = ANIMATION_SCALE
    self.y = self.height + 1
    self:animateY( 15, ANIMATION_FLY_UP_TIME, function()
        self.isOpening = false
    end, ANIMATION_EASING, ANIMATION_SCALE_TIME )
    self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_SCALE_TIME + ANIMATION_FLY_UP_TIME - ANIMATION_OVERLAP_TIME, false)
    -- self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_SCALE_TIME + ANIMATION_FLY_UP_TIME - ANIMATION_OVERLAP_TIME, false)
end

function ProgramView.isFocused:set( isFocused )
    self.super:setIsFocused( isFocused )
end

function ProgramView:onFocusesChanged( event )
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
    self:animateY( -self.height, ANIMATION_FLY_UP_TIME, function()
        self:dispose()
    end, ANIMATION_EASING, ANIMATION_SCALE_TIME - ANIMATION_OVERLAP_TIME )--ANIMATION_FLY_DELAY )
end

function ProgramView:flyInFocused( fromLeft )
    self.scale = 0.8
    local width = self.width
    self.x = fromLeft and -width or 1 + width
    self:animateX( 1, ANIMATION_FLY_TIME, nil, ANIMATION_EASING, ANIMATION_FLY_TIME/2 - 0.1 )
    self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_FLY_TIME - 0.1, false )
end

function ProgramView:flyOutFocused( toRight )
    local width = self.width
    local x = toRight and 1 + width or -width
    self:animateX( x, ANIMATION_FLY_TIME, nil, ANIMATION_EASING, ANIMATION_FLY_TIME/2 - 0.1 )
    self:animate( "scale", 0.8, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, nil, false )

end

function ProgramView.scale:set( scale )
    self.scale = scale
    self.terminalObject.scale = scale
end

function ProgramView:updateWidth( width )
    self.terminalObject.width = width
end

function ProgramView:updateHeight( height )
    self.terminalObject.height = height
end

function ProgramView:onMouseEvent( event )
    self.program:queueEvent( event.eventType, event.mouseButton, event.x, event.y  )
    return true
end

function ProgramView:onKeyEvent( event )
    self.program:queueEvent( event.eventType, event.keyCode  )
end

function ProgramView:onCharacterEvent( event )
    self.program:queueEvent( event.eventType, CharacterEvent  )
end

