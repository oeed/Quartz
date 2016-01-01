
local states = Program.states

class SilicaProgram extends Program {
    
}

function SilicaProgram:initialiseEnvironment()
    self.environment = SilicaProgramEnvironment( self )
end

function SilicaProgram:update()
    self:super( false )
    local silicaApplication = self.quartzProxy.silicaApplication
    if silicaApplication then
        silicaApplication:update()
    end
end

function SilicaProgram:run()
    self:super()
    local environment = self.environment.environment
    local silicaFunction = loadfile( "system/OldSilica.resourcepkg", "Silica Injection" )
    setfenv( silicaFunction, environment )
    silicaFunction()
end