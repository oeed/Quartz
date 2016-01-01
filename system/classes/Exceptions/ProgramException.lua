
class ProgramException extends Exception {

    program = Program;
    
}

function ProgramException:initialise( String message, Program program )
    self.program = program
    self:super( message )
end
