
class "QuartzApplicationContainer" extends "ApplicationContainer" {

    topBar = InterfaceOutlet();
    homeContainer = InterfaceOutlet();

}

function QuartzApplicationContainer:initialise( ... )
    self:super( ... )
    self:event( ReadyInterfaceEvent, self.onInterfaceReady, Event.phases.AFTER )
end

function QuartzApplicationContainer:onInterfaceReady( event )
    self.homeContainer:focus( )
end
