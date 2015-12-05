
local TOP_MARGIN = 15
local BETWEEN_MARGIN = 10
local BOTTOM_MARGIN = TOP_MARGIN

class "HomeItemContainer" extends "Container" {
    
    needsLayoutUpdate = false;

}

function HomeItemContainer:initialise( ... )
    self.super:initialise( ... )

    self:event( ReadyInterfaceEvent, self.onReady )
    self:event( ChildAddedInterfaceEvent, self.onChildAdded )
    self:event( ChildRemovedInterfaceEvent, self.onChildRemoved )
end

function HomeItemContainer:onReady( event )
    self:updateLayout( true )
end

function HomeItemContainer:updateWidth( width )
    -- self:updateLayout( true )
    self.needsLayoutUpdate = true
end

function HomeItemContainer:updateLayout( dontAnimate )
    log("update layout")
    local children, width = self.children, self.width
    local y = TOP_MARGIN + 1

    local time, easing = 0.5, Animation.easing.SINE_IN_OUT

    for i, childView in ipairs( children ) do
        if childView:typeOf( IHomeItem ) then
            if dontAnimate then
                childView.y = y
            else
                childView:animateY( y, time, nil, easing )
            end
            log(width)
            childView.x = math.ceil( ( width - childView.width ) / 2 ) + 2
            log(math.ceil( ( width - childView.width ) / 2 ) + 2)
            y = y + childView.height + BETWEEN_MARGIN
        end
    end

    self.height = y + BOTTOM_MARGIN - BETWEEN_MARGIN

    self.needsLayoutUpdate = false
end

function HomeItemContainer:update( deltaTime )
    self.super:update( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function HomeItemContainer:onChildAdded( event )
    self.needsLayoutUpdate = true
end

function HomeItemContainer:onChildRemoved( event )
    self.needsLayoutUpdate = true
end
