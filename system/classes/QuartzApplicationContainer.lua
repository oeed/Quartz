
class "QuartzApplicationContainer" extends "ApplicationContainer" {

    topBar = TopBarContainer.link;
    homeContainer = HomeContainer.link;

}

function QuartzApplicationContainer:initialise( ... )
    self:super( ... )
    self:event( ReadyInterfaceEvent, self.onReady, Event.phases.AFTER )
end

function QuartzApplicationContainer:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self.homeContainer:focus()
end
