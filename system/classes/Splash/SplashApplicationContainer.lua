
class "SplashApplicationContainer" extends "ApplicationContainer" {
    -- splashView = InterfaceOutlet( "splashView" )
}

function SplashApplicationContainer:initialise( ... )
    self:super( ... )
    self:event( ReadyInterfaceEvent, self.onReady)
end

function SplashApplicationContainer:onReady( ReadyInterfaceEvent event, Event.phases phase )
    -- self:animate( 'fillColour', { Graphics.colours.BLACK, Graphics.colours.GREY, Graphics.colours.LIGHT_GREY, Graphics.colours.WHITE }, 0.5, nil, Animation.easings.IN_SINE)
    -- self.fillColour = colours.red
    -- self.application:schedule(self.splashView.firstJump, 0.2, self.splashView)
    -- self.application.interfaceName = "quartz"
end
