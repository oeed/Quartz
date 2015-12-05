
local SHADOW_SIZE_X = 2
local SHADOW_SIZE_Y = 3

class "HomeTile" extends "Container" implements "IHomeItem" {
    
    backgroundObject = false;
    shadowObject = false;

}


function HomeTile:initialiseCanvas()
    self.super:initialiseCanvas()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local shadowObject = canvas:insert( RoundedRectangle( 1 + SHADOW_SIZE_X, 1 + SHADOW_SIZE_Y, width - SHADOW_SIZE_X, height - SHADOW_SIZE_Y, theme.shadowColour ) )
    local backgroundObject = canvas:insert( RoundedRectangle( 1, 1, width - SHADOW_SIZE_X, height - SHADOW_SIZE_Y, theme.fillColour, theme.outlineColour, cornerRadius ) )

    theme:connect( backgroundObject, "fillColour" )
    theme:connect( backgroundObject, "outlineColour" )
    theme:connect( backgroundObject, "radius", "cornerRadius" )
    theme:connect( shadowObject, "fillColour", "shadowColour" )
    theme:connect( shadowObject, "radius", "cornerRadius" )

    self.backgroundObject = backgroundObject
    self.shadowObject = shadowObject
end

function HomeTile:updateWidth( width )
    self.backgroundObject.width = width - SHADOW_SIZE_X
    self.shadowObject.width = width - SHADOW_SIZE_X
end

function HomeTile:updateHeight( height )
    self.backgroundObject.height = height - SHADOW_SIZE_Y
    self.shadowObject.height = height - SHADOW_SIZE_Y
end