
class "HomeItem" extends "TopBarItem" {
    
    pin = Number( TopBarItem.pins.LEFT );
    homeContainer = HomeContainer.allowsNil;
    size = Number( 29 ).allowsNil;

}

function HomeItem:initialise( ... )
    self:super( ... )
    self:event( ActionInterfaceEvent, self.onAction )
    self:event( ReadyInterfaceEvent, self.onReady )
end

function HomeItem:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self.homeContainer = self.application.container.homeContainer
end

function HomeItem:onDraw()
    self:super()
    local canvas, theme = self.canvas, self.theme
    local symbol = theme:value( "symbol" )
    local leftMargin = theme:value( "leftMargin" )
    canvas:fill( theme:value( "fillColour" ) )
    canvas:fill( theme:value( "contentColour" ), SymbolMask( 1 + leftMargin, 1 + math.floor( ( self.height - symbol.height ) / 2 ), symbol ) )
end

function HomeItem:onAction( ActionInterfaceEvent event, Event.phases phase )
   self.homeContainer:focus() 
end
