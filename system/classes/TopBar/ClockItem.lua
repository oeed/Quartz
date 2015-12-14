
class "ClockItem" extends "TopBarItem" {
    
    pin = Number( TopBarItem.pins.RIGHT );

    text = String( "0:00am" );

    isAnalouge = Boolean( true );
    isTwentyFourHour = Boolean( false );

}

function ClockItem:initialise( ... )
    self:super( ... )
    self.isAnalouge = false
    self:event( ActionInterfaceEvent, self.onAction )
    self:event( ReadyInterfaceEvent, self.onReady )
end

function ClockItem:onDraw()
    self:super()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas

    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    if self.isAnalouge then
        local analougeDiameter = theme:value( "analougeDiameter" )
        local circleMask = CircleMask( leftMargin + 1, math.floor( ( height - analougeDiameter ) / 2 + 0.5 ), analougeDiameter )
        canvas:fill( theme:value( "analougeFillColour" ), circleMask )
        canvas:outline( theme:value( "analougeOutlineColour" ), circleMask, theme:value( "analougeOutlineThickness" ) )

        local time = os.time()
        local seconds = time % 60
        local minutes = math.floor( ( time / 60 ) % 60 )
        local hours = math.floor( ( time / 60 / 60 ) % 24 )
        if hours >= 13 then
            hours = hours - 12
        end

        local analougeRadius = analougeDiameter / 2
        local centreX, centreY = math.floor( 1 + leftMargin + analougeRadius ), math.floor( ( height - analougeDiameter ) / 2 + 0.5 + analougeRadius)
        local function position( timePercentage, length, object )
            local angle = 2 * math.pi * timePercentage
            local rawWidth = length * math.sin( angle )
            local rawHeight = length * math.cos( angle )
            local width = math.floor(math.max(math.abs(rawWidth), 1) + 0.5)
            local height = math.floor(math.max(math.abs(rawHeight), 1) + 0.5)
            local isFromTopLeft = rawWidth * rawHeight <= 0
            return rawWidth > 0 and centreX or (1 + math.floor( centreX - width + 0.5 )),
                   rawHeight < 0 and centreY or (1 + math.floor( centreY - height + 0.5 )),
                   width,
                   height,
                   isFromTopLeft
        end
        
        local secondsMask = LineMask( position( seconds / 60, theme:value( "secondsLength" ) ) )
        local minutesMask = LineMask( position( minutes / 60, theme:value( "minutesLength" ) ) )
        local hoursMask = LineMask( position( hours / 12 + (minutes > 40 and minutes / 60 / 12 or 0), theme:value( "hoursLength" ) ) )

        canvas:fill( theme:value( "hoursColour" ), hoursMask )
        canvas:fill( theme:value( "minutesColour" ), minutesMask )
        canvas:fill( theme:value( "secondsColour" ), secondsMask )
    else
        canvas:fill( theme:value( "contentColour" ), TextMask( 1 + leftMargin, 1 + topMargin, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, theme:value( "font" ) ) )
    end
end

function ClockItem:updateThemeStyle()
    self.theme.style = self.isAnalouge and "analouge" or "disabled"
end

function ClockItem:onAction( ActionInterfaceEvent event, Event.phases phase )
    self.isAnalouge = not self.isAnalouge
end

function ClockItem:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self:updateClock()
end

function ClockItem.isAnalouge:set( isAnalouge )
    self.isAnalouge = isAnalouge
    self:updateClock( true )
    local parent = self.parent
    if parent then
        parent.needsLayoutUpdate = true
    end
end

function ClockItem:updateClock( dontSchedule )
    local isAnalouge = self.isAnalouge
    if not isAnalouge then
        local time = os.time()
        local seconds = time % 60
        local minutes = math.floor( ( time / 60 ) % 60 )
        local hours = math.floor( ( time / 60 / 60 ) % 24 )
        local ampm
        if not self.isTwentyFourHour then
            if hours >= 12 then
                ampm = "pm"
            else
                ampm = "am"
            end
            if hours >= 13 then
                hours = hours - 12
            end
        end
        if ampm then
            self.text = string.format( "%d:%02d%s", hours, minutes, ampm )
        else
            self.text = string.format( "%d:%02d", hours, minutes )
        end
    end
    if not dontSchedule then
        self.application:schedule(self.updateClock, isAnalouge and 2 or 1, self)
    end
end

function ClockItem.text:set( text )
    if self.text ~= text then
        self.text = text
        self.needsDraw = true
        local parent = self.parent
        if parent then
            parent.needsLayoutUpdate = true
        end
    end
end

-- TODO: this is being called twice each update
function ClockItem.size:get()
    local theme = self.theme
    local margin = theme:value( "leftMargin" ) + theme:value( "rightMargin" ) + 1
    if self.isAnalouge then
        return theme:value( "analougeDiameter" ) + margin
    end

    local text = self.text
    local fontWidth = self.theme:value( "font" ):getWidth( text )
    return fontWidth + margin
end