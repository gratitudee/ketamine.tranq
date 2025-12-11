-- Setup for Globals and Menu
local Interface, Modules = Ketamine.Interface, Ketamine.Modules
local Options = Interface.Library.Options
local Toggles = Interface.Library.Toggles

local Globals = {
	Connections = {},
	UnloadCallbacks = {},
}

function Globals:SetupMenu()
	local Window = Interface.Library:CreateWindow({
		Title = "KETAMINE.TRANQ",
		Center = true,
		AutoShow = not Ketamine.StealthMode,
		UnlockMouseWhileOpen = true,
	})

	local Tabs = {
		Aimbot = Window:AddTab("Assist"),
		Visuals = Window:AddTab("Visuals"),
		Miscellaneous = Window:AddTab("Miscellaneous"),
		Settings = Window:AddTab("Settings"),
		Configuration = Window:AddTab("Configuration"),
	}

	-- Menu setup...
	local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Menu")
	SettingsGroup:AddButton("Unload", function()
		print("Unload button pressed")
		Globals:Unload()
	end)

	Interface.Library.ToggleKeybind = Options.MenuKeybind
	Interface.Library:OnUnload(function()
		print("Library Unloaded")
		Interface.Library.Unloaded = true
	end)
end

function Globals:Load()
	print("Loading modules")
	for _, Module in pairs(Modules) do
		local Success, Error = SecureCall(Module.Load, Module)
		if not Success then
			DebugNotify("Failed to load, Unloading.")
			Globals:Unload()
			break
		end
	end

	local Success, R = SecureCall(Globals.SetupMenu, Globals)
	if not Success then
		print(Success, R)
		Globals:Unload()
		return
	end
end

function Globals:Unload()
	print("Unloading")
	for _, Module in pairs(Modules) do
		SecureSpawn(Module.Unload, Module)
	end

	for _, UnloadCallback in pairs(self.UnloadCallbacks) do
		print("Executing callback")
		SecureSpawn(UnloadCallback)
	end

	getgenv().Globals = nil
end

function Globals:OnUnload(Callback)
	print("Registering callback.")
	table.insert(Globals.UnloadCallbacks, Callback)
end

getgenv().Globals = Globals
return Globals
