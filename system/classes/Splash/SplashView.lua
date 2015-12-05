
local startDiameter = 100
local firstJumpDiameter = 80
local secondJumpDiameter = 20

class "SplashView" extends "View" {
    circleObject = false;
    diameter = startDiameter;
}

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function SplashView:initialiseCanvas()
    self.super:initialiseCanvas()
    local width, height, floor = self.width, self.height, math.floor
    
    local circleObject = self.canvas:insert( Circle( floor( ( width - startDiameter ) / 2 ), floor( ( height - startDiameter ) / 2 ), startDiameter ) )
    circleObject.fillColour = Graphics.colours.BLACK
    self.circleObject = circleObject
end

function SplashView:updateHeight( height )
    self.diameter = self.diameter
end

function SplashView:updateWidth( width )
    self.diameter = self.diameter
end

function SplashView.diameter:set( diameter )
    self.diameter = diameter
    local width, height, floor, circleObject = self.width, self.height, math.floor, self.circleObject
    circleObject.x = floor( ( width - diameter ) / 2 )
    circleObject.y = floor( ( height - diameter ) / 2 )
    circleObject.width = diameter
    circleObject.height = diameter
end

function SplashView.circleColour:set( circleColour )
    self.circleObject.fillColour = circleColour
end

function SplashView:firstJump()
    local circleObject = self.circleObject
    local easing = Animation.easing.LINEAR
    local diameter = firstJumpDiameter
    local time = 0.8

    -- self:animate( 'diameter', diameter, time, nil, easing)
    -- self:animate( 'circleColour', { colours.blue, colours.lightBlue, colours.green }, time, nil, Animation.easing.LINEAR)
    -- self:animate( 'circleColour', { Graphics.colours.BLACK, Graphics.colours.GREY, Graphics.colours.LIGHT_GREY, Graphics.colours.WHITE }, time, self.secondJump, Animation.easing.LINEAR)

end

function SplashView:secondJump()
    local circleObject = self.circleObject
    local easing = Animation.easing.LINEAR
    local diameter = secondJumpDiameter
    local time = 0.7

    -- self:animate( 'diameter', diameter, time, self.thirdJump, easing, 0.1)
    -- self:animate( 'diameter', diameter, time, nil, easing)

    self:animate( 'circleColour', { Graphics.colours.LIGHT_GREY, Graphics.colours.GREY, Graphics.colours.BLACK }, time, self.firstJump, Animation.easing.LINEAR)

end


function SplashView:thirdJump()
    local circleObject = self.circleObject
    local easing = Animation.easing.IN_EXPO
    local diameter = 2 * ((self.width/2)^2 + (self.height/2)^2)^0.5
    local time = 1
    self:animate( 'diameter', diameter, time, nil, easing)

    -- self.application:schedule(self.thirdJump, time, self)
end
