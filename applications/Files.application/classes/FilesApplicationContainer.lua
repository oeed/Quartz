
class FilesApplicationContainer extends ApplicationContainer {
    
    height = Number( 186 );
    path = String.allowsNil;
    pathTextBox = ToolbarPathTextBox.link;

}

function FilesApplicationContainer:initialise( ... )
    self:super( ... )

   self:event( ReadyInterfaceEvent, self.onReady )
end

function FilesApplicationContainer:onReady( ReadyInterfaceEvent event, Event.phases phase )
    self.path = self.application.arguments[1] or "/user"
end

function FilesApplicationContainer.path:set( path )
    if path:sub( 1, 1) ~= "/" then
        path = "/" .. path
    end
    path = FileSystemItem.static:resolve( path )
    if FileSystemItem.static:exists( path ) then
        self.path = path
        self.pathTextBox.path = path
    end
end