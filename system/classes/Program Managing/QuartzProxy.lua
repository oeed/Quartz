
class "QuartzProxy" {

    screenBuffer = Table.allowsNil;
    _program = Program;
    
}

function QuartzProxy:initialise( Program program )
    self._program = program
end

function QuartzProxy:redraw()
    self._program.programView.needsDraw = true
end
