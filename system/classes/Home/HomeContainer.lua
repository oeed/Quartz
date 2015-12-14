
local ANIMATION_FLY_TIME = 0.6
local ANIMATION_FLY_UP_TIME = 0.5
local ANIMATION_SCALE_TIME = 0.5
local ANIMATION_FLY_DELAY = 0.05
local ANIMATION_FLY_EASING = Animation.easings.IN_SINE
local ANIMATION_SCALE_EASING = Animation.easings.OUT_SINE
local ANIMATION_SCALE = 0.8
local ANIMATION_OVERLAP_TIME = 0.20

class "HomeContainer" extends "Container" implements "ISwitchableView" {
    
    isFocusDismissable = Boolean( false );
    isOpening = Boolean( true );
    scale = Number( 1 );
    backgroundImage = Image;
    hadFirstFocus = Boolean( false );
    
}

function HomeContainer:initialise( ... )
    self:super( ... )
    self.backgroundImage = Image.static:fromName( "Arc de Triomphe" )
end

function HomeContainer:initialiseCanvas()
    self.canvas = ScaleableCanvas( self.width, self.height, self )
end

function HomeContainer:onDraw()
    self.canvas:image( self.backgroundImage, 1, 1, self.width, self.height ) -- TODO: image fitting options (e.g. centre, squish etc.)
end

function HomeContainer.scale:set( scale )
    self.scale = scale
    local canvas = self.canvas
    canvas.scaleX = scale
    canvas.scaleY = scale
    self.needsDraw = true
end

function HomeContainer.isFocused:set( isFocused )
    self:super( isFocused )
    if not self.hadFirstFocus then
        if isFocused then
            self.hadFirstFocus = true
        end
    elseif isFocused then
        self:flyInFocused()
    else
        self:flyOutFocused()
    end
end

function HomeContainer:flyInFocused( fromLeft )
    self.scale = ANIMATION_SCALE
    self.x = -self.width
    self:animate( "x", 1, ANIMATION_FLY_TIME, nil, ANIMATION_FLY_EASING, ANIMATION_FLY_TIME / 2 - 0.1 )
    self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_FLY_TIME - 0.1, false )
end

function HomeContainer:flyOutFocused( toRight )
    self:animate( "x", -self.width, ANIMATION_FLY_TIME, nil, ANIMATION_FLY_EASING, ANIMATION_FLY_TIME/2 - 0.1 )
    self:animate( "scale", ANIMATION_SCALE, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, nil, false )
end