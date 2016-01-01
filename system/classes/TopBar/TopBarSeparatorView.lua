
class TopBarSeparatorView extends SeparatorView {
    
    activeX = Number( 1 );
    activeWidth = Number( 1 );

}

function TopBarSeparatorView:onDraw()
    self:super()
    local theme = self.theme
    self.canvas:fill( theme:value( "activeSeparatorColour" ), theme:value( "activeSeparatorIsDashed" ) and SeparatorMask( self.activeX, 1, self.activeWidth, self.height ) or RectangleMask( self.activeX, 1, self.activeWidth, self.height ) )
end

function TopBarSeparatorView.activeX:set( activeX )
   self.activeX = activeX
   self.needsDraw = true
end

function TopBarSeparatorView.activeWidth:set( activeWidth )
    self.activeWidth = activeWidth
    self.needsDraw = true
end
