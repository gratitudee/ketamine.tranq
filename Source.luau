local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Interface, Modules = Ketamine.Interface, Ketamine.Modules
local Options = Interface.Library.Options
local Toggles = Interface.Library.Toggles

local Globals = {
	Connections = {},
	UnloadCallbacks = {},
	Flags = {

		Settings = {
			EntityCacheUpdate = 5, -- ms
		},
	},
}

-- Internal Functions
local function BuildMenu()
	local Window = Interface.Library:CreateWindow({
		Title = "ketamine.tranq",
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

	local function MiscTab()
		local PlayerGroupBox = Tabs.Miscellaneous:AddLeftGroupbox("Players")
		local TeamGroupbox = Tabs.Miscellaneous:AddRightGroupbox("Teams")

		PlayerGroupBox:AddDropdown("EntityDropdown", {
			Values = {},
			Text = "Players",
			Searchable = true,
			AllowNull = true,
		})

		TeamGroupbox:AddDropdown("TeamDropdown", {
			SpecialType = "Team",
			Text = "Teams",
			Searchable = true,
			AllowNull = true,
		})

		Modules.Entity:OnEntityAdded(function(Player)
			local Values = Options.EntityDropdown.Values
			table.insert(Values, Player.Name)
			Options.EntityDropdown:SetValues(Values)
		end)

		Modules.Entity:OnEntityRemoved(function(Player)
			local Values = Options.EntityDropdown.Values
			table.remove(Values, table.remove(Values, table.find(Values, Player.Name)))
			Options.EntityDropdown:SetValues(Values)
		end)
	end

	local function SettingsTab()
		local Watermark = {
			Enabled = false,
			FrameTimer = tick(),
			FrameCounter = 0,
			FPS = 60,
			GetPing = function()
				return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end,
		}

		local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Menu")
		SettingsGroup:AddToggle("ShowWatermark", {
			Default = Watermark.Enabled,
			Text = "Show Watermark",
			Callback = function(value)
				Watermark.Enabled = value
			end,
		})
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
		Interface.Library.ToggleKeybind = Options.MenuKeybind
		SettingsGroup:AddButton("Unload", function()
			Globals:Unload()
		end)

		Cheat:Connect(RunService.Heartbeat, function(a0: number)
			if not Watermark.Enabled then
				return
			end

			Watermark.FrameCounter += 1

			local Now = tick()
			if (Now - Watermark.FrameTimer) >= 1 then
				Watermark.FPS = Watermark.FrameCounter
				Watermark.FrameTimer = Now
				Watermark.FrameCounter = 0
			end

			local Success, Ping = SecureCall(function(...): ...any
				return Watermark.GetPing()
			end)

			if Success and Ping then
				Interface.Library:SetWatermark(`ketamine.tranq | {Watermark.FPS} fps | {Ping} ms`)
			else
				Interface.Library:SetWatermark(`ketamine.tranq | {Watermark.FPS} fps`)
			end
		end)
	end

	local function ConfigTab()
		Interface.SaveManager:SetLibrary(Interface.Library)
		Interface.ThemeManager:SetLibrary(Interface.Library)
		Interface.SaveManager:IgnoreThemeSettings()
		Interface.ThemeManager:SetFolder("ketamine.tranq")
		Interface.SaveManager:SetFolder("ketamine.tranq")
		Interface.SaveManager:BuildConfigSection(Tabs.Configuration)
		Interface.ThemeManager:ApplyToTab(Tabs.Configuration)
		Interface.SaveManager:LoadAutoloadConfig()
	end

	MiscTab()
	SettingsTab()
	ConfigTab()
	Interface.Library:OnUnload(function()
		Interface.Library.Unloaded = true
	end)
end

-- Runtime Functions
function Globals:Load()
	for _, Module in pairs(Modules) do
		local Success, _ = SecureCall(Module.Load, Module)
		if not Success then
			DebugNotify("Failed to load, Unloading.")
			Globals:Unload()
			break
		end
	end

	local Success, Result = SecureCall(BuildMenu)
	if not Success then
		DebugNotify(Result)
		Globals:Unload()
		return
	end
end

function Globals:Unload()
	for _, Connection in pairs(Globals.Connections) do
		if Connection and typeof(Connection) == "RBXScriptConnection" and Connection.Connected then
			Connection:Disconnect()
			Connection = nil
		end
	end
	table.clear(Globals.Connections)

	for _, Module in pairs(Modules) do
		SecureSpawn(Module.Unload, Module)
	end

	for _, UnloadCallback in pairs(self.UnloadCallbacks) do
		SecureSpawn(UnloadCallback)
	end

	getgenv().Globals = nil
end

function Globals:OnUnload(Callback)
	table.insert(Globals.UnloadCallbacks, Callback)
end

getgenv().Globals = Globals
return Globals
