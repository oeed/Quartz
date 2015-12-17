
class "QuartzApplication" extends "Application" {
	
	name = String( "Quartz" );
	interfaceName = String( "quartz" ).allowsNil;
	programManager = ProgramManager;
	userDataPath = String( "/system/" );

}

-- For the demo the below code isn't really needed, it's just for debug

--[[
	@constructor
	@desc Initialise the custom application
]]
function QuartzApplication:initialise()
	self:super()
	self.programManager = ProgramManager( self )

	self:event( CharacterEvent, self.onChar )
end

function QuartzApplication:initialiseSettings()
	self.settings = QuartzSettings()
end

function QuartzApplication:update()
	self:super()
	self.programManager:update()
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function QuartzApplication:onChar( CharacterEvent event, Event.phases phase )
	if event.character == 'r' then
		-- self.programManager:run( Program( Bundle( "applications/Test.application" ) ) )
		self.programManager:run( SilicaProgram( Bundle( "applications/Silica.application" ) ) )
	elseif event.character == '\\' then
		os.reboot()
	end
	return false
end