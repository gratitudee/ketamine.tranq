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

	local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Menu")
	SettingsGroup:AddToggle("KeybindMenuOpen", {
		Default = Interface.Library.KeybindFrame.Visible,
		Text = "Open Keybind Menu",
		Callback = function(value)
			Interface.Library.KeybindFrame.Visible = value
		end,
	})
	SettingsGroup:AddToggle("ShowCustomCursor", {
		Text = "Custom Cursor",
		Default = true,
		Callback = function(Value)
			Interface.Library.ShowCustomCursor = Value
		end,
	})
	SettingsGroup:AddDivider()
	SettingsGroup:AddLabel("Menu bind")
		:AddKeyPicker("MenuKeybind", { Default = "Z", NoUI = true, Text = "Menu keybind" })

	SettingsGroup:AddButton("Unload", function()
		Globals:Unload()
	end)
	Interface.Library.ToggleKeybind = Options.MenuKeybind
	Interface.Library:OnUnload(function()
		Interface.Library.Unloaded = true
	end)

	Interface.SaveManager:SetLibrary(Interface.Library)
	Interface.ThemeManager:SetLibrary(Interface.Library)
	Interface.SaveManager:IgnoreThemeSettings()
	Interface.ThemeManager:SetFolder("ketamine.tranq")
	Interface.SaveManager:SetFolder("ketamine.tranq")
	Interface.SaveManager:BuildConfigSection(Tabs.Configuration)
	Interface.ThemeManager:ApplyToTab(Tabs.Configuration)
	Interface.SaveManager:LoadAutoloadConfig()
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
