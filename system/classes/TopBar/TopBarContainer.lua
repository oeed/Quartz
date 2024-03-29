
local ANIMATION_TIME = 0.5
local ANIMATION_EASING = Animation.easings.OUT_SINE
local pins = TopBarItem.pins

class "TopBarContainer" extends "Container" {
    
    interfaceName = "topbarcontainer";
    separatorView = TopBarSeparatorView.link;
    homeItem = HomeItem.link;
    needsLayoutUpdate = false;
    activeView = TopBarItem.allowsNil;
    switchableItems = {};

}

function TopBarContainer:initialise( ... )
    self:super( ... )

    self:event( ReadyInterfaceEvent, self.onReady )
    self:event( ChildAddedInterfaceEvent, self.onChildAdded )
    self:event( ChildRemovedInterfaceEvent, self.onChildRemoved )
    self:event( FocusesChangedInterfaceEvent, self.onFocusesChanged )
    self:event( ProgramOpenedInterfaceEvent, self.onProgramOpened )
    self:event( ProgramClosedInterfaceEvent, self.onProgramClosed )
end

function TopBarContainer:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self.switchableItems[self.application.container.homeContainer] = self.homeItem
    self:updateLayout( true )
end

function TopBarContainer:updateWidth( width )
    self:updateLayout( true )
    self.separatorView.width = width
end

function TopBarContainer:updateHeight( height )
    self.separatorView.y = height
    self.needsLayoutUpdate = false
end

 -- this is the view with the separator under it. not neccesarily the active program/area (during mouse down)
function TopBarContainer.activeView:set( activeView )
    local oldView = self.activeView
    if not activeView then
        local focusedSwitchableView = self.application:focusesOfType( ISwitchableView )[1]
        activeView = self.switchableItems[focusedSwitchableView]
    end
    activeView:updateThemeStyle()
    self.activeView = activeView
    local separatorView = self.separatorView
    local pin = activeView.pin
    local x, width = activeView.x + (pin == "right" and 1 or 0), activeView.width - 1
    separatorView:animate( "activeX", x, ANIMATION_TIME, nil, ANIMATION_EASING )
    separatorView:animate( "activeWidth", width, ANIMATION_TIME, nil, ANIMATION_EASING )
end

function TopBarContainer:updateLayout( dontAnimate )
    local width = self.width
    local remainingWidth = width + 1 -- add one to hide the last separator between the left and right pinned items
    local leftX, rightX = 1, -1
    local dynamicItems = {}
    local activeIndex
    local activeView, separatorView = self.activeView, self.separatorView

    local function updateFrame( childView, x, width )
        local isVisible = dontAnimate and true or childView.isVisible
        local separatorX, separatorWidth = x + (pin == "right" and 1 or 0), width - 1
        if dontAnimate or not isVisible then
            childView.x = x
            childView.width = width
            if not isVisible then
                childView:animate( "y", 1, ANIMATION_TIME, function() childView.isSeparatorVisible = true end, Animation.easings.IN_SINE )
                childView.isVisible = true
            end
        else
            childView:animate( "x", x, ANIMATION_TIME, nil, ANIMATION_EASING )
            childView:animate( "width", width, ANIMATION_TIME, nil, ANIMATION_EASING )
        end
        if childView == activeView then
            separatorView:animate( "activeX", separatorX, ANIMATION_TIME, nil, ANIMATION_EASING )
            separatorView:animate( "activeWidth", separatorWidth, ANIMATION_TIME, nil, ANIMATION_EASING )
        end
    end

    for i, childView in ipairs( self.children ) do
        if not childView:typeOf( SeparatorView ) and not childView.isRemoving then
            local pin, size = childView.pin, childView.size
            if size then
                if pin == pins.LEFT then
                    updateFrame( childView, leftX, size )
                    remainingWidth = remainingWidth - size
                    leftX = leftX + size
                elseif pin == pins.RIGHT then
                    rightX = rightX + size
                    updateFrame( childView, width - rightX, size )
                    remainingWidth = remainingWidth - size
                end
            else
                if not activeIndex and childView.isActive then
                    activeIndex = #dynamicItems + 1
                end
                table.insert( dynamicItems, childView )
            end
        end
    end

    activeIndex = activeIndex or 1

    local itemCount = #dynamicItems
    if itemCount > 0 then
        local eachWidthDecimal = remainingWidth / itemCount
        local standardWidth = math.ceil( eachWidthDecimal )
        local activeWidth = remainingWidth - (itemCount - 1) * standardWidth

        for i, childView in ipairs( dynamicItems) do
            local size = activeIndex == i and activeWidth or standardWidth
            updateFrame( childView, leftX, size )
            leftX = leftX + size
        end
    end

    self.needsLayoutUpdate = false
end

function TopBarContainer:update( deltaTime )
    self:super( deltaTime )
    if self.needsLayoutUpdate then
        self:updateLayout()
    end
end

function TopBarContainer:animateRemove( childView )
    childView:animate( "y", 1 - childView.height, ANIMATION_TIME, function() self:remove( childView )  end, ANIMATION_EASING )
    childView.isRemoving = true
    childView.isSeparatorVisible = false
    self.needsLayoutUpdate = true
end

function TopBarContainer:onProgramOpened( ProgramOpenedInterfaceEvent event, Event.phases phase )
    local program = event.program
    self.switchableItems[program.programView] = self:insert( ProgramItem( { program = program } ) )
end

function TopBarContainer:onProgramClosed( ProgramClosedInterfaceEvent event, Event.phases phase )
    self:animateRemove( self.switchableItems[event.program.programView] )
end

function TopBarContainer:onChildAdded( ChildAddedInterfaceEvent event, Event.phases phase )
    local childView = event.childView
    if childView:typeOf( TopBarItem ) then
        childView.y = self.height + 1
        childView.isVisible = false
        childView.isSeparatorVisible = false
        childView.isRemoving = false
    end

    self.needsLayoutUpdate = true
    self:sendToFront( self.separatorView )
end

function TopBarContainer:onChildRemoved( ChildRemovedInterfaceEvent event, Event.phases phase )
    self.needsLayoutUpdate = true
end

function TopBarContainer:onFocusesChanged( FocusesChangedInterfaceEvent event, Event.phases phase )
    local oldFocusedSwitchableViews = self.application:focusesOfType( ISwitchableView, event.oldFocuses )
    local focusedSwitchableViews = self.application:focusesOfType( ISwitchableView, event.newFocuses )

    if #focusedSwitchableViews > 0 then
        local oldSwitchableView = oldFocusedSwitchableViews[1]
        local switchableView = focusedSwitchableViews[1]
        if switchableView ~= oldSwitchableView then
            if oldSwitchableView then
                self.switchableItems[oldSwitchableView]:updateThemeStyle()
            end
            self.activeView = self.switchableItems[switchableView]
        end
    else
        self.activeView = nil
    end
end
