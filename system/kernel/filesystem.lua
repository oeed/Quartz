
local filesystem = {}
local mounts = {}
local root

local function tidy( path )
	return path
		:gsub( "/.-/%.%./", "/" )
		:gsub( "^.-/%.%./", "" )
		:gsub( "/%./", "/" )
		:gsub( "^%.%./", "" )
		:gsub( "^%.%.$", "" )
		:gsub( "//+", "/" )
		:gsub( "^/", "" )
		:gsub( "/$", "" )
end

local function getDeviceAndLocalPath( path ) -- takes a resolved path
	local l, d, p = 0, nil, path

	for i = 1, #mounts do
		if path:find( mounts[i].pat .. "/" ) or path:find( mounts[i].pat .. "$" ) then
			l, d, p = #path:match( mounts[i].pat ), mounts[i].device, path:gsub( mounts[i].pat, "", 1 )
		end
	end

	return d or root, tidy( p )
end

local function formatDevicePath( path )
	return path:gsub( "([%%%.%(%)%[%]%^%$%*%+%-%?])", "%%%1" )
end

local function invoke( method, path, ... )
	local device, localPath = getDeviceAndLocalPath( tidy( path ) )
	return device[method]( localPath, ... )
end

function filesystem.resolve( path ) -- the thing is,
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end
	return tidy( path )
end

function filesystem.mount( path, device )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	elseif type( device ) ~= "table" then
		return error( "expected table device, got " .. type( device ) )
	end

	path = tidy( path )
	for i = 1, #mounts do
		if mounts[i].path == path then
			mounts[i].device = device
			return
		end
	end

	mounts[#mounts + 1] = {
		path = path;
		pat = "^" .. formatDevicePath( path );
		device = device;
	}
end

function filesystem.unmount( path )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end

	path = tidy( path )
	for i = 1, #mounts do
		if mounts[i].path == path then
			return table.remove( mounts[i] ).device
		end
	end
end

function filesystem.open( path, mode )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end
	return invoke( "open", path, mode )
end

function filesystem.list( path )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end
	local device, localPath = getDeviceAndLocalPath( tidy( path ) )
	return device[method]( localPath, ... )
end

function filesystem.delete( path )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end
	local device, localPath = getDeviceAndLocalPath( tidy( path ) )
	if localPath == "" then
		return error( "cannot delete device", 0 )
	end
	return device.delete( localPath, ... )
end

function filesystem.isDir( path )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end
	local device, localPath = getDeviceAndLocalPath( tidy( path ) )
	if localPath == "" then
		return true
	end
	return device.isDir( localPath, ... )
end

function filesystem.makeDir( path )
	if type( path ) ~= "string" then
		return error( "expected string path, got " .. type( path ) )
	end
	local device, localPath = getDeviceAndLocalPath( tidy( path ) )
	if localPath == "" then
		return
	end
	return device.makeDir( localPath, ... )
end

 -- ... etc

function filesystem.newRedirectDevice( path )

end

function filesystem.setRootDevice( device )
	root = device
end

function filesystem.setRoot( path )
	root = filesystem.newRedirectDevice( path )
end

function filesystem.wrapper()
	local fsFunctions = {}
	local fs = {}
	for i = 1, #fsFunctions do
		fs[fsFunctions[i]] = filesystem[fsFunctions[i]]
	end
	return fs
end

return filesystem
