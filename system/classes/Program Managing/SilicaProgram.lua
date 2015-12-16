
class "SilicaProgram" extends "Program" {
    
}

function SilicaProgram:initialiseEnvironment()
    self.environment = SilicaProgramEnvironment( self )
end

function SilicaProgram:update()
    local eventQueue, redirect, programCoroutine = self.eventQueue, self.coroutine
    local firstEvent = eventQueue[1]
    while self.state == states.RUNNING and firstEvent do
        -- TODO: maybe redirect outside this loop
        local ok, data = coroutine.resume( programCoroutine, unpack( firstEvent ) )

        if coroutine.status( programCoroutine ) == "dead" then
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