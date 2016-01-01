
class QuartzProxy {

    screenBuffer = Table.allowsNil;
    silicaApplication = Table.allowsNil; -- we have to use table because the Application class will be different, we just have to presume it's an Application
    _program = Program;
    fs = Table( fs ); -- TODO: .isReadOnly

    userDataPath = String;

    status = String.allowsNil;
    
}

function QuartzProxy:initialise( Program program )
    self._program = program
    local applicationUserDataFolder = self.application.userDataFolder
    local identifier = program.identifier
    local folder = applicationUserDataFolder:folderFromPath( identifier )
    if not folder then
        folder = applicationUserDataFolder:makeSubfolder( identifier )
    end

    self.userDataPath = folder.path
end

function QuartzProxy:redraw( Table.allowsNil pixels )
    local programView = self._program.programView
    if pixels then
        programView.buffer = pixels
    end
    programView.needsDraw = true
end

function QuartzProxy.status:get()
    return self._program.status
end

function QuartzProxy.status:set( status )
    self._program.status = status
end
