
class FilesApplication extends Application {

	name = String( "Files" );
	interfaceName = String( "files" ).allowsNil;

}

function FilesApplication:initialise()
	self:super()
	self:event( CharacterEvent, self.onChar )
end

--[[
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function FilesApplication:onChar( CharacterEvent event, Event.phases phase )
	if not self:hasFocus() and event.character == '\\' then
		os.reboot()
	end
end
