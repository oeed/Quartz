
class "ProgramInformationChangedInterfaceEvent" extends "InterfaceEvent" {
    
    static = {
        eventType = "interface_program_info_changed";
    };

    program = Program;

}

function ProgramInformationChangedInterfaceEvent:initialise( Program program )
    self.program = program
end

