
class "ProgramManager" {
    
    programs = {};
    owner = false;

}

function ProgramManager:initialise( owner )
    self.owner = owner
end

function ProgramManager:run( program )
    program.programManager = self
    program.state = Program.states.RUNNING
    local programView = ProgramView( { x = 1, y = 15, width = "100%", height = 210-15, program = program } )
    self.owner.container:insert( programView )
    program.programView = programView
    local programs = self.programs
    table.insert( programs, program )
    program.index = #programs
    self.application.event:handleEvent( ProgramOpenedInterfaceEvent( program ) )
    program:focus()
end

function ProgramManager:onProgramClosed( closingProgram )
    local programs = self.programs
    local programOrder = program
    local previousIndex
    local changeIndex = false
    for i, program in ipairs( programs ) do
        if changeIndex then
            program.index = i - 1
        elseif program == closingProgram then
            previousIndex = i
            table.remove( programs, i )
            changeIndex = true
        end
    end
    
    local programView = closingProgram.programView
    if programView.isFocused then
        programView:closeFlyUp(function()
            if #programs == 0 then
                -- TODO: activate the home
                self.application.container.homeContainer:focus()
            elseif programs[previousIndex] then
                programs[previousIndex]:focus()
                log("activate "..previousIndex)
            elseif programs[previousIndex - 1] then
                log("activate "..previousIndex - 1)
                programs[previousIndex - 1]:focus()
            end
        end)
    end
end

function ProgramManager:update()
    local programs = self.programs
    for i, program in ipairs( programs ) do
        program:update()
    end
end
