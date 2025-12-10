local Interface, Modules = Ketamine.Interface, Ketamine.Modules
local Libraries = {
	UI = Interface.Library,
	SaveManager = Interface.SaveManager,
	ThemeManager = Interface.ThemeManager,
}

local Globals = {
	Connections = {},
	UnloadCallbacks = {},
}

function Globals:Load()
	for _, Module in pairs(Modules) do
		SecureSpawn(Module.Load, Module)
	end
end

function Globals:Unload()
	for _, Module in pairs(Modules) do
		SecureSpawn(Module.Unload, Module)
	end

	for _, UnloadCallback in pairs(self.UnloadCallbacks) do
		SecureSpawn(UnloadCallback)
	end
end

function Globals:OnUnload(Callback)
	table.insert(self.UnloadCallbacks, Callback)
end

getgenv().Globals = Globals
return Globals
