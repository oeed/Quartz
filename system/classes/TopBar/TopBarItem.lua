
local pins = {
    LEFT = 0;
    RIGHT = 1;
}

class "TopBarItem" extends "View" {
    
    pins = Enum( Number, pins );
    
    isPressed = Boolean( false );
    isCanvasHitTested = Boolean( false );
    pin = Number( pins.LEFT ); -- TODO: this doesn't work: TopBarItem.pins( TopBarItem.pins.LEFT );
    isRemoving = Boolean( false );
    size = Number.allowsNil;
    height = Number( 14 );
    isSeparatorVisible = Boolean( true );

}

function TopBarItem:initialise( ... )
    self:super( ... )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )
end

function TopBarItem:onDraw()
    self:super()
    local width, height, theme, canvas, isPinnedRight = self.width, self.height, self.theme, self.canvas, self.pin == pins.RIGHT

    canvas:fill( theme:value( "fillColour" ) )

    if self.isSeparatorVisible then
        local separatorTopMargin, separatorBottomMargin = theme:value( "separatorTopMargin" ), theme:value( "separatorBottomMargin" )
        canvas:fill( theme:value( "separatorColour" ), theme:value( "separatorIsDashed" ) and SeparatorMask( isPinnedRight and 1 or width, 1 + separatorTopMargin, 1, height - separatorTopMargin - separatorBottomMargin ) or RectangleMask( isPinnedRight and 1 or width, 1 + separatorTopMargin, 1, separatorHeight ) )
    end
end

function TopBarItem:updateThemeStyle()
    self.theme.style = self.isPressed and "pressed" or "default"
end

function TopBarItem.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

function TopBarItem:onMouseDown( MouseDownEvent event, Event.phases phase )
    if event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
        self.parent.activeView = self
    end
    return true
end

function TopBarItem:onGlobalMouseUp( MouseUpEvent event, Event.phases phase )
    if self.isPressed and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        local parent = self.parent
        if parent.activeView == self then
            parent.activeView = false
        end
        self.isPressed = false
        if self:hitTestEvent( event ) then
            self.event:handleEvent( ActionInterfaceEvent( self, event ) )
            local result = self.event:handleEvent( event )
            return result == nil and true or result
        end
    end
end
