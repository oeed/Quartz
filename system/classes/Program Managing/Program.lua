
local states = {
    UNINTIALISED = 0;
    RUNNING = 1;
    PAUSED = 2;
    FINISHED = 3;
}

local configKeys = {
    PROGRAM_TITLE = "title",
    BOOT_PATH = "bootPath",
}

class "Program" {
    
    state = states.UNINTIALISED;
    isRunning = Boolean( false ); -- whether the COROUTINE is running (not just the program)

    programManager = ProgramManager.allowsNil;
    bundle = Bundle;
    config = Table;

    title = String;
    status = String.allowsNil;

    states = Enum( Number, states );

    eventQueue = Table;
    environment = ProgramEnvironment;
    coroutine = Thread.allowsNil;
    arguments = Table;
    programView = ProgramView.allowsNil;
    index = Number.allowsNil;
    quartzProxy = QuartzProxy.allowsNil;
    hadFirstUpdate = Boolean( false );

    configKeys = Enum( String, configKeys );

}

function Program:initialise( bundle, ... )
    local arguments = { ... }
    local config = bundle.config
    if not config[configKeys.BOOT_PATH] then
        error( "program bundle config invalid" )
    end

    self.title = config.title or bundle.name
    self.config = config
    self.bundle = bundle
    self.arguments = arguments
    self.eventQueue = { arguments }
    self:initialiseEnvironment()
end

function Program:run()
    self.state = states.RUNNING
    self.coroutine = coroutine.create( function()
        local func = loadfile( FileSystemItem.static:tidy( self.bundle.path .. "/" .. self.config[configKeys.BOOT_PATH] ) )
        setfenv( func, self.environment.environment )
        func( arguments )
    end )
end

function Program:initialiseEnvironment()
    self.environment = ProgramEnvironment( self )
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

function Program:update( Boolean( true ) redirectTerm )
    local eventQueue, programCoroutine, redirect = self.eventQueue, self.coroutine
    local previousTarget
    if redirectTerm then
        previousTarget = term.redirect( self.programView.redirect )
    end
    local firstEvent = eventQueue[1]
    while self.state == states.RUNNING and firstEvent do
        local ok, data = coroutine.resume( programCoroutine, unpack( firstEvent ) )

        if coroutine.status( programCoroutine )== "dead" then
            if previousTarget then
                term.redirect( previousTarget )
            end
            self.state = states.FINISHED
            self:close()
            log("Program died")
            log(data)
            return
        end

        if ok then
            -- TODO: not sure what filter does
            -- self.filter = data
        else
            -- TODO: error handling
            log("Program crashed")
            log(data)
            if previousTarget then
                term.redirect( previousTarget )
            end
            -- self:throw( data )
            return
        end

        table.remove( eventQueue, 1 )
        firstEvent = eventQueue[1]
    end
    if previousTarget then
        term.redirect( previousTarget )
    end
    if not self.hadFirstUpdate then
        self.hadFirstUpdate = true
        self:focus()
    end
end

function Program:focus()
    self.programView:focus( ISwitchableView )
end

function Program.status:set( status )
    self.status = status
    self.application.container.topBar.event:handleEvent( ProgramInformationChangedInterfaceEvent( self ) )    
end

function Program.title:set( title )
    self.title = title
    self.application.container.topBar.event:handleEvent( ProgramInformationChangedInterfaceEvent( self ) )    
end
