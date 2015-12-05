
local colourBytes = {}
for i = 0, 15 do
    colourBytes[("%x"):format( i ):byte()] = 2 ^ i
end

class "TerminalObject" extends "GraphicsObject" {
    
    legacyRedirect = false;
    redirect = false;
    silicaRedirect = false;
    termSizes = {}; -- this is just to cache values so we don't need to index properties all the time
    fillColour = Graphics.colours.BLACK;
    buffer = {};
    scale = 1;

}

function TerminalObject:initialise( ... )
    self.super:initialise( ... )
    local termSizes = self.termSizes
    termSizes.width = self.width
    termSizes.height = self.height
end

function TerminalObject.width:set( width )
    self.super:setWidth( width )
    self.termSizes.width = width
end

function TerminalObject.height:set( height )
    self.super:setHeight( height )
    self.termSizes.height = height
end

function TerminalObject.scale:set( scale )
    if self.scale ~= scale then
        self.hasChanged = true
        self.scale = scale
    end
end

function TerminalObject:drawTo( canvas )
    if self.isVisible then
        local termSizes = self.termSizes
        if termSizes.hasChanged then
            termSizes.hasChanged = false
        end
        
        local width = self.width
        local height = self.height
        local scale = self.scale
        local fillColour = self.fillColour
        local buffer = self.buffer
        local _x = self.x - 1
        local _y = self.y
        

        local TRANSPARENT = Graphics.colours.TRANSPARENT

        local canvasWidth = canvas.width
        local canvasHeight = canvas.height
        local canvasBuffer = canvas.buffer

        if scale == 1 then
            for x = 1, width do
                for y = 0, height - 1 do -- just so there's no need for y-1 below
                    local colour = buffer[y * width + x] or fillColour
                    local nx, ny = x + _x, y + _y
                    if colour ~= TRANSPARENT and nx >= 1 and ny >= 1 and nx <= canvasWidth and ny <= canvasHeight then
                        canvasBuffer[( ny - 1 ) * canvasWidth + nx] = colour
                    end
                end
            end
        else
            local scaledWidth, scaledHeight = math.floor( width * scale + 0.5 ), math.floor( height * scale + 0.5 )
            local ceil = math.ceil
            local widthRatio = width / scaledWidth
            local heightRatio = height / scaledHeight
            local xMin, yMin = math.floor( ( width - scaledWidth ) / 2 ) + 1, math.floor( ( height - scaledHeight ) / 2 )

            for x = 1, scaledWidth do
                for y = 0, scaledHeight - 1 do -- just so there's no need for y-1 below
                    local colour = buffer[ceil( y * heightRatio ) * width + ceil( x * widthRatio )] or TRANSPARENT
                    local nx, ny = x + xMin + _x, y + yMin + _y
                    if colour ~= TRANSPARENT and nx >= 1 and ny >= 1 and nx <= canvasWidth and ny <= canvasHeight then
                        canvasBuffer[( ny - 1 ) * canvasWidth + nx] = colour
                    end
                end
            end
        end
    end
    return self
end

function TerminalObject.redirect:get()
    local redirect = self.redirect
    if redirect then return redirect end

    local term = {}
    local termSizes = self.termSizes

    local colour, termX, termY, cursorBlink = Graphics.colours.BLACK, 1, 1

    local buffer = self.buffer
    local TRANSPARENT = Graphics.colours.TRANSPARENT
    local function setPixel( x, y, c )
        local termWidth = termSizes.width
        if c ~= TRANSPARENT and x >= 1 and y >= 1 and x <= termWidth and y <= termSizes.height then
            local pos = ( y - 1 ) * termWidth + x
            if buffer[ pos ] ~= c then
                buffer[ pos ] = c
                if not termSizes.hasChanged then
                    termSizes.hasChanged = true
                    self.hasChanged = true
                end
            end
        end
    end

    function term.write( s )
        s = tostring( s ) -- we don't really care what s is. this whole thing will need to be redone when we actually get the real thing
        for i = 1, math.min( #s, termSizes.width - termX + 1 ) do
            setPixel( termX + i - 1, termY, colour )
        end
        termX = termX + #s
    end

    function term.blit( s, t, b )
        if #s ~= #b or #s ~= #t then
            return error "arguments must be the same length"
        end
        for i = 1, math.min( #s, termSizes.width - termX + 1 ) do
            setPixel( termX + i - 1, termY, colourBytes[ b:byte( i ) ] )
        end
        termX = termX + #s
    end

    function term.clear()
        for x = 1, termSizes.width do
            for y = 1, termSizes.height do
                setPixel( x, y, colour )
            end
        end
    end

    function term.clearLine()
        for x = 1, termSizes.width do
            setPixel( x, termY, colour )
        end
    end

    function term.getCursorPos()
        return termX, termY
    end

    function term.setCursorPos( x, y )
        termX = math.floor( x )
        termY = math.floor( y )
    end

    function term.setCursorBlink( state )
        -- This does zilch
    end

    function term.getSize()
        return termSizes.width, termSizes.height
    end

    function term.scroll( n )
        local offset = n * termSizes.width
        local n, f, s = n < 0 and termSizes.width * termSizes.height or 1, n < 0 and 1 or termSizes.width * termSizes.height, n < 0 and -1 or 1
        for i = n, f, s do
            buffer[i] = buffer[i + offset] or colour
        end
    end

    function term.isColour()
        return true
    end

    function term.setBackgroundColour( backgroundColour )
        colour = backgroundColour
    end

    function term.setTextColour( colour )
        -- This does zilch
    end

    function term.getBackgroundColour()
        return colour
    end

    function term.getTextColour()
        return colours.white
    end

    term.isColor = term.isColour
    term.setBackgroundColor = term.setBackgroundColour
    term.setTextColor = term.setTextColour
    term.getBackgroundColor = term.getBackgroundColour
    term.getTextColor = term.getTextColour

    self.redirect = term
    return term
end

-- TODO: add a wrapper than will draw the the pre-CraftOS 2 graphics
-- function TerminalObject:getLegacyRedirect()
--     local redirect = self.redirect
--     if redirect then return redirect end

--     local term = {}

--     local backgroundColour, textColour, termX, termY, cursorBlink = Graphics.colours.BLACK, Graphics.colours.WHITE, 1, 1, false

--     function term.write( s )
--         s = tostring( s )
--         local pos = ( termY - 1 ) * termSizes.width + termX
--         local pixels = {}
--         local bc, tc = backgroundColour, textColour
--         for i = 1, math.min( #s, termSizes.width - termX + 1 ) do
--             pixels[#pixels + 1] = { pos, { bc, tc, s:sub( i, i ) } }
--             pos = pos + 1
--         end
--         termX = termX + #s
--         self:mapPixels( pixels )
--     end

--     function term.blit( s, t, b )
--         if #s ~= #b or #s ~= #t then
--             return error "arguments must be the same length"
--         end
--         local pixels = {}
--         local pos = ( termY - 1 ) * termSizes.width + termX
--         for i = 1, math.min( #s, termSizes.width - termX + 1 ) do
--             pixels[#pixels + 1] = { pos, { colourBytes[b:byte( i )], colourBytes[t:byte( i )], s:sub( i, i ) } }
--             pos = pos + 1
--         end
--         termX = termX + #s
--         self:mapPixels( pixels )
--     end

--     function term.clear()
--         self:clear( backgroundColour )
--     end

--     function term.clearLine()
--         local px = { backgroundColour, 1, " " }
--         local pixels = {}
--         local offset = termSizes.width * ( termY - 1 )
--         for i = 1, termSizes.width do
--             pixels[#pixels + 1] = { i + offset, px }
--         end
--         self:mapPixels( pixels )
--     end

--     function term.getCursorPos()
--         return termX, self.term_y
--     end

--     function term.setCursorPos( x, y )
--         termX = math.floor( x )
--         termY = math.floor( y )
--     end

--     function term.setCursorBlink( state )
--         self.term_cb = state
--     end

--     function term.getSize()
--         return termSizes.width, termSizes.height
--     end

--     function term.scroll( n )
--         local buffer = self.buffer
--         local offset = n * termSizes.width
--         local n, f, s = n < 0 and termSizes.width * termSizes.height or 1, n < 0 and 1 or termSizes.width * termSizes.height, n < 0 and -1 or 1
--         local pixels = {}
--         local px = { backgroundColour, textColour, " " }
--         for i = n, f, s do
--             pixels[#pixels + 1] = { i, buffer[i + offset] or px }
--         end
--         self:mapPixels( pixels )
--     end

--     function term.isColour()
--         return true
--     end

--     function term.setBackgroundColour( colour )
--         backgroundColour = colour
--     end

--     function term.setTextColour( colour )
--         textColour = colour
--     end

--     function term.getBackgroundColour()
--         return backgroundColour
--     end

--     function term.getTextColour()
--         return textColour
--     end

--     term.isColor = term.isColour
--     term.setBackgroundColor = term.setBackgroundColour
--     term.setTextColor = term.setTextColour
--     term.getBackgroundColor = term.getBackgroundColour
--     term.getTextColor = term.getTextColour

--     self.redirect = term
--     return term
-- end