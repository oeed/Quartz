
class "TopBarSeparatorView" extends "SeparatorView" {
    
    activeX = Number( 1 );
    activeWidth = Number( 1 );

}

function TopBarSeparatorView:initialiseCanvas()
    self:super()
    local theme, canvas = self.theme, self.canvas
    local activeSeparatorObject = canvas:insert( Separator( self.activeX, 1, self.activeWidth, self.height ) )

    theme:connect( activeSeparatorObject, "fillColour", "activeSeparatorColour" )
    theme:connect( activeSeparatorObject, "isDashed", "activeSeparatorIsDashed" )

    self.activeSeparatorObject = activeSeparatorObject
end

function TopBarSeparatorView.activeX:set( activeX )
   self.activeX = activeX
   self.needsDraw = true
end

function TopBarSeparatorView.activeWidth:set( activeWidth )
    self.activeWidth = activeWidth
    self.needsDraw = true
end
