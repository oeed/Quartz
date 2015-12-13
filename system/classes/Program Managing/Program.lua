
local states = {
    UNINTIALISED = 0;
    RUNNING = 1;
    PAUSED = 2;
    FINISHED = 3;
}

class "Program" {
    
    state = states.UNINTIALISED;
    isRunning = false; -- whether the COROUTINE is running (not just the program)

    programManager = false;
    index = false;
    bundle = false;

    title = "Blah";
    status = "boo";

    states = Enum( Number, states );

    eventQueue = {};
    environment = {};
    coroutine = false;
    arguments = false;
    programView = false;

}

local n = 1
function Program:initialise( bundle, ... )
    local arguments = { ... }

    self.title = "Favourites "..n
    for k, v in pairs(colours) do
        if v == 2^n then
            self.status = k
        end
    end
    arguments = {n}
    n = n + 1

    self.bundle = bundle
    self.arguments = arguments
    self.eventQueue = { arguments }
    local environment = ProgramEnvironment( self )
    self.environment = environment
    self.coroutine = coroutine.create( function()
        local func = loadfile( bundle.path .. "/startup" )
        setfenv( func, environment.environment )
        func( arguments )
    end )
end

function Program:close( isForced )
    local state = self.state
    local willClose = isForced or state == states.FINISHED
    if not isForced then
        willClose = true
        -- TODO: probe the program and see if it can close (for 'are you sure you want to close...' dialouges)
    end

    if willClose then
        state = states.FINISHED
        -- self.programView:dispose()
        self.programManager:onProgramClosed( self )
        self.application.event:handleEvent( ProgramClosedInterfaceEvent( self ) )
    end
end

function Program:queueEvent( ... )
    table.insert( self.eventQueue, { ... } )
end

function Program.environment:get()
    if self.environment then return self.environment end

    -- Create the environment as it doesn't exist yet
    -- TODO: clean environment
    self.environment = setmetatable( {}, { __index = _G } )
    return self.environment
end

function Program:update()
    local eventQueue, redirect, programCoroutine = self.eventQueue, self.programView.redirect, self.coroutine
    local firstEvent = eventQueue[1]
    while self.state == states.RUNNING and firstEvent do
        -- TODO: maybe redirect outside this loop
        local previousTarget = term.redirect( redirect )
        local ok, data = coroutine.resume( programCoroutine, unpack( firstEvent ) )
        term.redirect( previousTarget )

        if coroutine.status( programCoroutine )== "dead" then
            log("dead")
            self.state = states.FINISHED
            self:close()
        end

        if ok then
            -- TODO: not sure what filter does
            -- self.filter = data
        else
            -- TODO: error handling
            log("Program crashed")
            log(data)
            -- self:throw( data )
        end

        table.remove( eventQueue, 1 )
        firstEvent = eventQueue[1]
    end
end

function Program:focus()
    self.programView:focus( ISwitchableView )
end
