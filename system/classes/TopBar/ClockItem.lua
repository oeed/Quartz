
local ANALOUGE_DIAMETER = 11
local MARGIN = 10

local SECONDS_LENGTH = 5
local MINUTES_LENGTH = 5
local HOURS_LENGTH = 4

class "ClockItem" extends "TopBarItem" {
    
    pin = "right";
    isAnalouge = true;

    text = "0:00am";

    textObject = false;

    circleObject = false;
    secondsObject = false;
    minutesObject = false;
    hoursObject = false;
    isTwentyFourHour = false;

    font = false;

}

function ClockItem:initialise( ... )
    self.super:initialise( ... )
    self.isAnalouge = false
    self:event( ActionInterfaceEvent, self.onAction )
    self:event( ReadyInterfaceEvent, self.onReady )
end

function ClockItem:initialiseCanvas()
    self.super:initialiseCanvas()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local textObject = canvas:insert( Text( 1 + MARGIN, 4, width, Font.systemFont.height, "hekdsfksdg" ) )
    local circleObject = canvas:insert( Circle( 1 + MARGIN, 2, ANALOUGE_DIAMETER ) )

    local analougeRadius = ANALOUGE_DIAMETER / 2
    local analougeX = math.floor( 1 + MARGIN + ANALOUGE_DIAMETER / 2 )
    local hoursObject = canvas:insert( Line( analougeX, 2 + math.ceil( analougeRadius - HOURS_LENGTH ), 1, HOURS_LENGTH ) )
    local minutesObject = canvas:insert( Line( analougeX, 2 + math.ceil( analougeRadius - MINUTES_LENGTH ), 1, MINUTES_LENGTH ) )
    local secondsObject = canvas:insert( Line( analougeX, 2 + math.ceil( analougeRadius - SECONDS_LENGTH ), 1, SECONDS_LENGTH ) )

    theme:connect( textObject, "textColour", "contentColour" )

    theme:connect( circleObject, "outlineColour", "analougeOutlineColour" )
    theme:connect( circleObject, "fillColour", "analougeFillColour" )
    theme:connect( secondsObject, "fillColour", "secondsColour" )
    theme:connect( minutesObject, "fillColour", "minutesColour" )
    theme:connect( hoursObject, "fillColour", "hoursColour" )
    
    self.textObject = textObject

    self.circleObject = circleObject
    self.secondsObject = secondsObject
    self.minutesObject = minutesObject
    self.hoursObject = hoursObject
end

function ClockItem:updateWidth( width )
    self.super:updateWidth( width )
    self.textObject.width = width - 2 * MARGIN
end

function ClockItem:onAction( event )
    self.isAnalouge = not self.isAnalouge
end

function ClockItem:onReady( event )
    self:updateClock()
end

function ClockItem.isAnalouge:set( isAnalouge )
    self.isAnalouge = isAnalouge

    self.circleObject.isVisible = isAnalouge
    self.secondsObject.isVisible = isAnalouge
    self.minutesObject.isVisible = isAnalouge
    self.hoursObject.isVisible = isAnalouge
    self.textObject.isVisible = not isAnalouge
    self:updateClock( true )
    local parent = self.parent
    if parent then
        parent.needsLayoutUpdate = true
    end
end

function ClockItem:updateClock( dontSchedule )
    local isAnalouge = self.isAnalouge
    local time = os.time()
    local seconds = time % 60
    local minutes = math.floor( ( time / 60 ) % 60 )
    local hours = math.floor( ( time / 60 / 60 ) % 24 )
    local ampm
    if isAnalouge or not self.isTwentyFourHour then
        if hours >= 12 then
            ampm = "pm"
        else
            ampm = "am"
        end
        if hours >= 13 then
            hours = hours - 12
        end
    end
    if isAnalouge then
        local hoursObject, minutesObject, secondsObject = self.hoursObject, self.minutesObject, self.secondsObject
        local centreX, centreY = math.floor( 1 + MARGIN + ANALOUGE_DIAMETER / 2 ), math.floor( 2 + ANALOUGE_DIAMETER / 2 )
        local function position( timePercentage, length, object )
            local angle = 2 * math.pi * timePercentage
            local rawWidth = length * math.sin( angle )
            local rawHeight = length * math.cos( angle )
            local width = math.floor(math.max(math.abs(rawWidth), 1) + 0.5)
            local height = math.floor(math.max(math.abs(rawHeight), 1) + 0.5)
            local isFromTopLeft = rawWidth * rawHeight <= 0
            object.x = rawWidth > 0 and centreX or (1 + math.floor( centreX - width + 0.5 ))
            object.y = rawHeight < 0 and centreY or (1 + math.floor( centreY - height + 0.5 ))
            object.width = width
            object.height = height
            object.isFromTopLeft = isFromTopLeft
        end
        position( seconds / 60, SECONDS_LENGTH, secondsObject )
        position( minutes / 60, MINUTES_LENGTH, minutesObject )
        position( hours / 12 + (minutes > 40 and minutes / 60 / 12 or 0), HOURS_LENGTH, hoursObject )
    else
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
        self.textObject.text = text
        local parent = self.parent
        if parent then
            parent.needsLayoutUpdate = true
        end
    end
end

-- TODO: this is being called twice each update
function ClockItem.size:get()
    if self.isAnalouge then
        return ANALOUGE_DIAMETER + 2 * MARGIN + 1
    end

    local text, textObject = self.text, self.textObject

    local fontWidth = textObject.font:getWidth( text )
    return fontWidth + 2 * MARGIN + 1
end