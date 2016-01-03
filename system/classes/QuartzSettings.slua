
class QuartzSettings extends Settings {
    
    isClockAnalogue = Boolean( false );
    isClockTwentyFourHour = Boolean( false );
    backgroundImagePath = String( "/system/resources/Wallpapers/Europe/Arc de Triomphe.ucg" );

}

function QuartzSettings.backgroundImagePath:set( backgroundImagePath )
    local container = self.application.container
    if container then
        local homeContainer = container.homeContainer 
        if homeContainer then
            homeContainer.backgroundImage = Image.static:fromPath( backgroundImagePath )
        end
    end
end
