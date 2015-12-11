
class "HomeItem" extends "TopBarItem" {
    
    pin = Number( TopBarItem.pins.LEFT );

    size = Number( 29 ).allowsNil;

}

function HomeItem:initialise( ... )
    self.super:initialise( ... )
    self:event( ActionInterfaceEvent, self.onAction )
    self:event( ReadyInterfaceEvent, self.onReady )
end

function HomeItem:onReady( event )
    self.homeContainer = self.application.container.homeContainer
end

function HomeItem:initialiseCanvas()
    log("home item initialiseCanvas")
    log(tostring(self))
    self.super:initialiseCanvas()
    local width, height, theme, canvas = self.width, self.height, self.theme

    -- TODO: !URGENT! path drawing bug


    -- local homeObject = Path( 10, 2, 9, 9, 5, 1 )
    -- homeObject:lineTo( 9, 5 )
    -- homeObject:lineTo( 8, 5 )
    -- homeObject:lineTo( 8, 9 )
    -- homeObject:lineTo( 6, 9 )
    -- homeObject:lineTo( 6, 7 )
    -- homeObject:lineTo( 4, 7 )
    -- homeObject:lineTo( 4, 9 )
    -- homeObject:lineTo( 2, 9 )
    -- homeObject:lineTo( 2, 5 )
    -- homeObject:lineTo( 1, 5 )
    -- homeObject:close()

    -- self.canvas:insert( homeObject )

    -- theme:connect( homeObject, "fillColour", "contentColour" )
    
    -- self.homeObject = homeObject



    -- local homeRoofObject = Path( 11, 3, 9, 9, 5, 1 )
    -- homeRoofObject:lineTo( 9, 5 )
    -- homeRoofObject:lineTo( 1, 5 )
    -- homeRoofObject:close()

    -- log(textutils.serialise(homeRoofObject:getSerialisedPath()))

    -- local homeBodyObject = Path( 11, 3, 9, 9, 8, 5 )
    -- homeBodyObject:lineTo( 8, 9 )
    -- homeBodyObject:lineTo( 6, 9 )
    -- homeBodyObject:lineTo( 6, 9 )
    -- homeBodyObject:lineTo( 6, 7 )
    -- homeBodyObject:lineTo( 4, 7 )
    -- homeBodyObject:lineTo( 4, 9 )
    -- homeBodyObject:lineTo( 2, 9 )
    -- homeBodyObject:lineTo( 2, 5 )
    -- homeBodyObject:close()
    -- log(textutils.serialise(homeBodyObject:getSerialisedPath()))


    local symbolObject = SymbolObject( 11, 3, HomeSymbol )
    -- self.canvas:insert( homeRoofObject )
    self.canvas:insert( symbolObject )

    theme:connect( symbolObject, "fillColour", "contentColour" )
    -- theme:connect( homeBodyObject, "fillColour", "contentColour" )
    
    self.symbolObject = symbolObject

end

function HomeItem:onAction( event )
   self.homeContainer:focus() 
end

function HomeItem:updateWidth( width )
    self.separatorObject.x = width
    self.backgroundObject.width = width - 1
end
