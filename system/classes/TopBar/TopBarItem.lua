
class "TopBarItem" extends "View" {
    
    isPressed = false;
    separatorObject = false;
    backgroundObject = false;
    isCanvasHitTested = false;
    pin = false;
    isRemoving = false;
    size = false;
    height = 14;

}

function TopBarItem:initialise( ... )
    self.super:initialise( ... )
    self:event( MouseDownEvent, self.onMouseDown )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, EventManager.phase.BEFORE )
end

function TopBarItem:initialiseCanvas()
    log("top bar item initialiseCanvas")
    log(tostring(self))
    self.super:initialiseCanvas()
    local width, height, theme, canvas, isPinnedRight = self.width, self.height, self.theme, self.canvas, self.pin == "right"
    local separatorObject = canvas:insert( Separator( isPinnedRight and 1 or width, 3, 1, height - 4 ) )
    local backgroundObject = canvas:insert( Rectangle( isPinnedRight and 2 or 1, 1, width - 1, height - 1 ) )

    theme:connect( backgroundObject, "fillColour" )
    
    self.separatorObject = separatorObject
    self.backgroundObject = backgroundObject
end

function TopBarItem:updateWidth( width )
    self.separatorObject.x = self.pin == "right" and 1 or width
    self.backgroundObject.width = width - 1
end

function TopBarItem:updateHeight( height )
    self.separatorObject.height = height - 4
    self.backgroundObject.height = height - 1
end

function TopBarItem:updateThemeStyle()
    self.theme.style = self.isPressed and "pressed" or "default"
end

function TopBarItem.isPressed:set( isPressed )
    self.isPressed = isPressed
    self:updateThemeStyle()
end

function TopBarItem:onMouseDown( event )
    if event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self.isPressed = true
        self.parent.activeView = self
    end
    return true
end

function TopBarItem:onGlobalMouseUp( event )
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
