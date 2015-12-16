
class "SilicaProgramEnvironment" extends "ProgramEnvironment" {
    
}

function SilicaProgramEnvironment:loadDefaultVariables()
    self:super()
    log("here")
    local environment = self.environment
    log("env "..tostring(environment))
    local silicaFunction = loadfile( "system/OldSilica.resourcepkg", "Silica Injection" )
    setfenv( silicaFunction, environment )
    silicaFunction()
end