
class "HomeItemContainer" extends "Container" {
    
    needsLayoutUpdate = false;

}

function HomeItemContainer:initialise( ... )
    self:super( ... )

    self:event( ReadyInterfaceEvent, self.onReady )
    self:event( ThemeChangedInterfaceEvent, self.onThemeChanged )
    self:event( ChildAddedInterfaceEvent, self.onChildAdded )
    self:event( ChildRemovedInterfaceEvent, self.onChildRemoved )
end

function HomeItemContainer:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self.y = 1 + self.theme:value( "parentTopMargin" )
    self:updateLayout( true )
    local delay = 0.5
    for i, childView in ipairs( self.children ) do
        local y = childView.y
        childView.y = self.height + 1
        childView:animate( "y", y, 0.8, nil, Animation.easings.OUT_QUART, delay )
        delay = delay + 0.3
    end
end

function HomeItemContainer:onThemeChanged( ThemeChangedInterfaceEvent event, Event.phases phase )
    self.y = 1 + self.theme:value( "parentTopMargin" )
    self.needsLayoutUpdate = true
end

function HomeItemContainer:updateLayout( dontAnimate )
    local children, width, theme = self.children, self.width, self.theme
    local tileMargin = theme:value( "tileMargin" )
    local y = theme:value( "tileMargin" )

    local time, easing = 0.5, Animation.easings.SINE_IN_OUT

    for i, childView in ipairs( children ) do
        if childView:typeOf( IHomeItem ) then
            if dontAnimate then
                childView.y = y
            else
                childView:animate( "y", y, time, nil, easing )
            end
            childView.x = math.ceil( ( width - childView.width ) / 2 ) + 2
            y = y + childView.height + tileMargin
        end
    end

    self.height = math.max( y + theme:value( "bottomMargin" ) - tileMargin, self.parent.height - self.theme:value( "parentTopMargin" ) )

    self.needsLayoutUpdate = false
end

function HomeItemContainer:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function HomeItemContainer:onChildAdded( ChildAddedInterfaceEvent event, Event.phases phase )
    self.needsLayoutUpdate = true
end

function HomeItemContainer:onChildRemoved( ChildRemovedInterfaceEvent event, Event.phases phase )
    self.needsLayoutUpdate = true
end
