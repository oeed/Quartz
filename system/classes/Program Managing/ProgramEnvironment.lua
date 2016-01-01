
class ProgramEnvironment {

    program = Program;
    environment = Table( {} );

}

function ProgramEnvironment:initialise( program )
    self.program = program
    self:loadDefaultVariables()
end

function ProgramEnvironment:loadDefaultVariables()
    local environment = self.environment
    local program = self.program
    local programManager, application = program.programManager, self.application

    local quartzProxy = QuartzProxy( program )
    program.quartzProxy = quartzProxy
    environment.Quartz = quartzProxy

    -- TODO: maybe we should work out what these are at boot, rather than being hard coded
    local names = { "tostring", "tonumber", "assert", "error", "pcall", "xpcall", "setmetatable", "getmetatable", "rawget", "rawset", "rawequal", "type", "next", "pairs", "ipairs", "unpack", "select", "setfenv", "getfenv", "coroutine", "string", "math", "table", "__inext", "_MC_VERSION", "_VERSION", "_LUAJ_VERSION", "_CC_VERSION", "print", "read", "write", "printError", "keys", "colours", "help", "parallel", "rednet", "textutils", "bit", "bit32", "vector", "colors", "term", "window", "paintutils", "peripheral", "disk", "http", "gps", "rs", "redstone"
        ,"log", "logtraceback" -- TODO: just temporarily
    }
    environment.error = log -- TODO: temporary

    for i, name in ipairs( names ) do
        environment[name] = _G[name]
    end

    environment._G = environment

    local bundle = program.bundle
    environment.fs = bundle.fs
    environment.io = bundle.io
    function environment.loadstring( ... )
        local loaded = loadstring( ... )
        setfenv( loaded, environment )
        return loaded
    end

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
    self:loadShell()
end

function ProgramEnvironment:loadShell()
    local bExit = false
    local sDir = ""
    local sPath = ".:/rom/programs"
    local tAliases = {}
    local tProgramStack = { self.program.bootPath }

    local shell = {}
    local tEnv = {
        [ "shell" ] = shell,
    }

    -- Colours
    local promptColour, textColour, bgColour
    if term.isColour() then
        promptColour = colours.yellow
        textColour = colours.white
        bgColour = colours.black
    else
        promptColour = colours.white
        textColour = colours.white
        bgColour = colours.black
    end

    local function run( _sCommand, ... )
        local sPath = shell.resolveProgram( _sCommand )
        if sPath ~= nil then
            tProgramStack[#tProgramStack + 1] = sPath
            if multishell then
                multishell.setTitle( multishell.getCurrent(), fs.getName( sPath ) )
            end
            local result = os.run( tEnv, sPath, ... )
            tProgramStack[#tProgramStack] = nil
            if multishell then
                if #tProgramStack > 0 then
                    multishell.setTitle( multishell.getCurrent(), fs.getName( tProgramStack[#tProgramStack] ) )
                else
                    multishell.setTitle( multishell.getCurrent(), "shell" )
                end
            end
            return result
        else
            printError( "No such program" )
            return false
        end
    end

    local function tokenise( ... )
        local sLine = table.concat( { ... }, " " )
        local tWords = {}
        local bQuoted = false
        for match in string.gmatch( sLine .. "\"", "(.-)\"" ) do
            if bQuoted then
                table.insert( tWords, match )
            else
                for m in string.gmatch( match, "[^ \t]+" ) do
                    table.insert( tWords, m )
                end
            end
            bQuoted = not bQuoted
        end
        return tWords
    end

    -- Install shell API
    function shell.run( ... )
        local tWords = tokenise( ... )
        local sCommand = tWords[1]
        if sCommand then
            return run( sCommand, unpack( tWords, 2 ) )
        end
        return false
    end

    function shell.exit()
        bExit = true
    end

    function shell.dir()
        return sDir
    end

    function shell.setDir( _sDir )
        sDir = _sDir
    end

    function shell.path()
        return sPath
    end

    function shell.setPath( _sPath )
        sPath = _sPath
    end

    function shell.resolve( _sPath )
        local sStartChar = string.sub( _sPath, 1, 1 )
        if sStartChar == "/" or sStartChar == "\\" then
            return fs.combine( "", _sPath )
        else
            return fs.combine( sDir, _sPath )
        end
    end

    function shell.resolveProgram( _sCommand )
        -- Substitute aliases firsts
        if tAliases[ _sCommand ] ~= nil then
            _sCommand = tAliases[ _sCommand ]
        end

        -- If the path is a global path, use it directly
        local sStartChar = string.sub( _sCommand, 1, 1 )
        if sStartChar == "/" or sStartChar == "\\" then
            local sPath = fs.combine( "", _sCommand )
            if fs.exists( sPath ) and not fs.isDir( sPath ) then
                return sPath
            end
            return nil
        end
        
        -- Otherwise, look on the path variable
        for sPath in string.gmatch(sPath, "[^:]+") do
            sPath = fs.combine( shell.resolve( sPath ), _sCommand )
            if fs.exists( sPath ) and not fs.isDir( sPath ) then
                return sPath
            end
        end
        
        -- Not found
        return nil
    end

    function shell.programs( _bIncludeHidden )
        local tItems = {}
        
        -- Add programs from the path
        for sPath in string.gmatch(sPath, "[^:]+") do
            sPath = shell.resolve( sPath )
            if fs.isDir( sPath ) then
                local tList = fs.list( sPath )
                for n,sFile in pairs( tList ) do
                    if not fs.isDir( fs.combine( sPath, sFile ) ) and
                       (_bIncludeHidden or string.sub( sFile, 1, 1 ) ~= ".") then
                        tItems[ sFile ] = true
                    end
                end
            end
        end 

        -- Sort and return
        local tItemList = {}
        for sItem, b in pairs( tItems ) do
            table.insert( tItemList, sItem )
        end
        table.sort( tItemList )
        return tItemList
    end

    function shell.getRunningProgram()
        if #tProgramStack > 0 then
            return tProgramStack[#tProgramStack]
        end
        return nil
    end

    function shell.setAlias( _sCommand, _sProgram )
        tAliases[ _sCommand ] = _sProgram
    end

    function shell.clearAlias( _sCommand )
        tAliases[ _sCommand ] = nil
    end

    function shell.aliases()
        -- Add aliases
        local tCopy = {}
        for sAlias, sCommand in pairs( tAliases ) do
            tCopy[sAlias] = sCommand
        end
        return tCopy
    end

    self.environment.shell = shell
end
