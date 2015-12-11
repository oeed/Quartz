
class "QuartzApplicationContainer" extends "ApplicationContainer" {

    topBar = InterfaceOutlet();
    homeContainer = InterfaceOutlet();

}

function QuartzApplicationContainer:initialise( ... )
    self.super:initialise( ... )
    self:event( ReadyInterfaceEvent, self.onInterfaceReady, EventManager.phase.AFTER )
end

function QuartzApplicationContainer:onInterfaceReady( event )
    self.homeContainer:focus( )
end
