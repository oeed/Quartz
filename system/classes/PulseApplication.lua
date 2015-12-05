
class "PulseApplication" extends "Application" {
	
	name = "Pulse";
	interfaceName = "pulse";
	programManager = false;

}

-- For the demo the below code isn't really needed, it's just for debug

--[[
	@constructor
	@desc Initialise the custom application
]]
function PulseApplication:initialise()
	self.super:initialise()
	self.programManager = ProgramManager( self )

	self:event( CharacterEvent, self.onChar )
		
	self:schedule(function() self.programManager:run( Program( Folder( "applications/Test.application" ) ) ) end,0.05)
end

function PulseApplication:update()
	self.programManager:update()
	self.super:update()
end

--[[
	@instance
	@desc React to a character being fired
	@param [Event] event -- description
	@return [boolean] stopPropagation
]]
function PulseApplication:onChar( event )
	if event.character == 'r' then
		-- self:schedule(function()self.programManager:run( Program( "applications/Test.application/startup" ) )end,0.05)
		self.programManager:run( Program( Folder( "applications/Test.application" ) ) )
	elseif event.character == '\\' then
		os.reboot()
	end
	return false
end