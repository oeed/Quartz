
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
    
}

function HomeContainer:initialise( ... )
    self:super( ... )

    self.backgroundImage = Image.static:fromName( "Arc de Triomphe" )

    self:event( FocusesChangedInterfaceEvent, self.onFocusesChanged )
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
end

function HomeContainer:onFocusesChanged( FocusesChangedInterfaceEvent event, Event.phases phase )
    local oldContains = event:didContain( self )
    local contains = event:contains( self )
    if oldContains ~= contains then
        if contains then
            self:flyInFocused()
        elseif oldContains then
            self:flyOutFocused()
        end
    end
end

function HomeContainer:flyInFocused( fromLeft )
    self.scale = ANIMATION_SCALE
    self.x = -self.width
    self:animateX( 1, ANIMATION_FLY_TIME, nil, ANIMATION_EASING, ANIMATION_FLY_TIME / 2 - 0.1 )
    self:animate( "scale", 1, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, ANIMATION_FLY_TIME - 0.1, false )
end

function HomeContainer:flyOutFocused( toRight )
    self:animateX( -self.width, ANIMATION_FLY_TIME, nil, ANIMATION_EASING, ANIMATION_FLY_TIME/2 - 0.1 )
    self:animate( "scale", ANIMATION_SCALE, ANIMATION_SCALE_TIME, nil, ANIMATION_SCALE_EASING, nil, false )
end