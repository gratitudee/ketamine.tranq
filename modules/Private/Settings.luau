local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Library = require("../../packages/Library")
local Flags = require("../Flags")
local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
	local function BindToggle(id, tbl, key)
		if tbl[key] == nil then
			print(`UI ERROR | Failed to bind {key}, key not found.`)
			return
		end

		Toggles[id]:OnChanged(function(v)
			tbl[key] = v
		end)
	end

	local function BindOption(id, tbl, key)
		if tbl[key] == nil then
			print(`UI ERROR | Failed to bind {key}, key not found.`)
			return
		end
		Options[id]:OnChanged(function(v)
			tbl[key] = v
		end)
	end

	local function BindMultiselect(id, tbl)
		Options[id]:OnChanged(function()
			local values = Options[id].Value
			for k in pairs(tbl) do
				tbl[k] = values[k] == true
			end
		end)
	end

	local function BindColorPicker(id, setter)
		Options[id]:OnChanged(function()
			setter(Options[id].Value, Options[id].Transparency)
		end)
	end

	local function BindKeybind(id, callback)
		if not callback then
			return
		end
		local key = Options[id]
		key:OnClick(function()
			callback(key:GetState())
		end)
	end

	local SettingsTab = Ketamine.Window:AddTab("Settings")
	local SettingsMain = SettingsTab:AddLeftGroupbox("Main")

	SettingsMain:AddLabel("Menu Keybind")
		:AddKeyPicker("MenuKeybind", { Default = "Z", NoUI = true, Text = "Menu keybind" })
	SettingsMain:AddButton("Unload", function()
		Cheat:Unload()
	end)
	Ketamine.Library.ToggleKeybind = Options.MenuKeybind

	SettingsMain:AddDivider()

	SettingsMain:AddDropdown("RaycastOrigin", {
		Values = { "Camera", "Character" },
		Default = Flags.Settings.RaycastOrigin,
		Text = "Raycast Origin",
	})
	BindOption("RaycastOrigin", Flags.Settings, "RaycastOrigin")

	SettingsMain:AddToggle("StreamMode", {
		Text = "Stream Mode",
		Default = Flags.Settings.StreamMode,
	})
	BindToggle("StreamMode", Flags.Settings, "StreamMode")

	SettingsMain:AddToggle("ShowWatermark", {
		Text = "Show Watermark",
		Default = Flags.Settings.ShowWatermark,
	})
	BindToggle("ShowWatermark", Flags.Settings, "ShowWatermark")

	SettingsMain:AddToggle("ShowKeybinds", {
		Text = "Show Keybinds",
		Default = Flags.Settings.ShowKeybinds,
	})
	BindToggle("ShowKeybinds", Flags.Settings, "ShowKeybinds")

	SettingsMain:AddDivider()
end

local FrameCounter = {
	Count = 0,
	Timer = tick(),
	FPS = 60,
}
function Component:MenuLoop(IsGeorgeFloyd)
	if IsGeorgeFloyd then -- george floyd is false, continue on.
		return
	end

	Ketamine.Library.KeybindFrame.Visible = false
	Ketamine:SecureSpawn(function()
		if not Flags.Settings.ShowWatermark then
			Ketamine.Library:SetWatermarkVisibility(false)
			return
		end

		FrameCounter.Count += 1
		if (tick() - FrameCounter.Timer) >= 1 then
			FrameCounter.FPS = FrameCounter.Count
			FrameCounter.Timer = tick()
			FrameCounter.Count = 0
		end

		Ketamine.Library:SetWatermark(`ketamine.tranq | {Players.LocalPlayer.Name} | {FrameCounter.FPS}`)
	end)
end

function Component:Load()
	BuildMenu()
	Cheat:Connect(RunService.RenderStepped, function(...)
		Component:MenuLoop(false)
	end)
end
function Component:Unload() end

return Component
