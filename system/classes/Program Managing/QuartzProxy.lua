
class "QuartzProxy" {

    screenBuffer = Table.allowsNil;
    silicaApplication = Table.allowsNil; -- we have to use table because the Application class will be different, we just have to presume it's an Application
    _program = Program;
    
}

function QuartzProxy:initialise( Program program )
    self._program = program
end

function QuartzProxy:redraw( Table.allowsNil pixels )
    local programView = self._program.programView
    if pixels then
        programView.buffer = pixels
    end
    programView.needsDraw = true
end
