
class "TopBarSeparatorView" extends "SeparatorView" {
    
    activeSeparatorObject = false;

}

function TopBarSeparatorView:initialiseCanvas()
    self.super:initialiseCanvas()
    local theme, canvas = self.theme, self.canvas
    local activeSeparatorObject = canvas:insert( Separator( 1, 1, 1, self.height ) )

    theme:connect( activeSeparatorObject, "fillColour", "activeSeparatorColour" )
    theme:connect( activeSeparatorObject, "isDashed", "activeSeparatorIsDashed" )

    self.activeSeparatorObject = activeSeparatorObject
end

function TopBarSeparatorView.activeX:set( x )
   self.activeSeparatorObject.x = x 
end

function TopBarSeparatorView.activeWidth:set( width )
    self.activeSeparatorObject.width = width 
end

function TopBarSeparatorView.activeX:get( x )
    return self.activeSeparatorObject.x
end

function TopBarSeparatorView.activeWidth:get( width )
    return self.activeSeparatorObject.width
end