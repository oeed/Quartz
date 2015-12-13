
local SHADOW_SIZE_X = 2
local SHADOW_SIZE_Y = 3

class "HomeTile" extends "Container" implements "IHomeItem" {

}

function HomeTile:onDraw()
    self:super()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas

    local roundedRectangle = RoundedRectangleMask( 1, 1, width, height, theme:value( "cornerRadius" ) )
    canvas:fill( theme:value( "fillColour" ), roundedRectangle )
    canvas:outline( theme:value( "outlineColour" ), roundedRectangle, theme:value( "outlineThickness" ) )

    self.shadowSize = theme:value( "shadowSize" )
end
