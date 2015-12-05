
class "PulseApplicationContainer" extends "ApplicationContainer" {

    topBar = InterfaceOutlet();
    homeContainer = InterfaceOutlet();

}

function PulseApplicationContainer:initialise( ... )
    self.super:initialise( ... )
    self:event( ReadyInterfaceEvent, self.onInterfaceReady, EventManager.phase.AFTER )
end

function PulseApplicationContainer:onInterfaceReady( event )
    self.homeContainer:focus( )
end
