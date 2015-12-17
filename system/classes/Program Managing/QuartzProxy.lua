
class "QuartzProxy" {

    screenBuffer = Table.allowsNil;
    silicaApplication = Table.allowsNil; -- we have to use table because the Application class will be different, we just have to presume it's an Application
    _program = Program;

    title = String.allowsNil;
    status = String.allowsNil;
    
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

function QuartzProxy.title:get()
    return self._program.title
end

function QuartzProxy.title:set( title )
    self._program.title = title
end

function QuartzProxy.status:get()
    return self._program.status
end

function QuartzProxy.status:set( status )
    self._program.status = status
end
