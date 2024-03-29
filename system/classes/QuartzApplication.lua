
class "QuartzApplication" extends "Application" {
	
	name = String( "Quartz" );
	interfaceName = String( "quartz" ).allowsNil;
	programManager = ProgramManager;

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
		
	self:schedule(function() self.programManager:run( Program( Folder( "applications/Test.application" ) ) ) end,0.05)
end

function QuartzApplication:update()
	self.programManager:update()
	self:super()
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function QuartzApplication:onChar( CharacterEvent event, Event.phases phase )
	if event.character == 'r' then
		-- self:schedule(function()self.programManager:run( Program( "applications/Test.application/startup" ) )end,0.05)
		self.programManager:run( Program( Folder( "applications/Test.application" ) ) )
	elseif event.character == '\\' then
		os.reboot()
	end
	return false
end