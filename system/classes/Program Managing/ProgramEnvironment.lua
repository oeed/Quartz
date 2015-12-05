
class "ProgramEnvironment" {

    program = false;
    environment = {};

}

function ProgramEnvironment:initialise( program )
    self.program = program
    self:loadDefaultVariables()
end

function ProgramEnvironment:loadDefaultVariables()
    local environment = self.environment
    local program = self.program
    local programManager, application = program.programManager, self.application

    -- TODO: maybe we should work out what these are at boot, rather than being hard coded
    local names = { "tostring", "tonumber", "assert", "error", "pcall", "xpcall", "setmetatable", "getmetatable", "rawget", "rawset", "rawequal", "type", "next", "pairs", "ipairs", "unpack", "select", "setfenv", "getfenv", "coroutine", "string", "math", "table", "__inext", "_MC_VERSION", "_VERSION", "_LUAJ_VERSION", "_CC_VERSION", "print", "read", "write", "printError", "keys", "colours", "help", "parallel", "rednet", "textutils", "bit", "bit32", "vector", "colors", "term", "window", "paintutils", "peripheral", "disk", "http", "gps", "rs", "redstone" 
        -- ,"fs" -- TODO: fs sandboxing
        ,"log" -- TODO: just temporarily
    }
    environment.error = log -- TODO: temporary

    for i, name in ipairs( names ) do
        environment[name] = _G[name]
    end

    environment._G = environment

    local bundle = program.bundle
    environment.fs = bundle.fs
    environment.io = bundle.io

    local envOS = {}
    environment.os = envOS

    envOS.version = os.version
    envOS.getComputerID = os.getComputerID
    envOS.computerID = os.computerID
    envOS.setAlarm = os.setAlarm
    envOS.cancelAlarm = os.cancelAlarm
    envOS.setComputerLabel = os.setComputerLabel
    envOS.getComputerLabel = os.getComputerLabel
    envOS.computerLabel = os.computerLabel
    envOS.time = os.time
    envOS.day = os.day
    envOS.clock = os.clock
    envOS.pullEvent = os.pullEvent
    envOS.pullEventRaw = os.pullEventRaw

    function envOS.shutdown()
        program:close( true )
    end
    function envOS.reboot()
        program:close( true )
        -- TODO: sandbox reboot
        -- application.session:launchAndView( application.path )
    end

    function envOS.queueEvent( ... )
        local t = {...}
        program:queueEvent( ... )
    end

    local environmentTimers = {}
    local function startTimer( time )
        if type( time ) ~= "number" then return error "expected number" end
        id = application:schedule( function()
            environmentTimers[id] = nil
            program:queueEvent( "timer", id )
        end, time )
        environmentTimers[id] = true

        return id
    end
    envOS.startTimer = startTimer

    function envOS.cancelTimer( timer )
        if environmentTimers[id] then
            application:unschedule( id )
        end
    end

    local function sleep( time )
        local timer = startTimer( time )
        repeat
            local sEvent, param = coroutine.yield( "timer" )
        until param == timer
    end
    envOS.sleep = sleep
    environment.sleep = sleep

end

