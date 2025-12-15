local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
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

	SettingsMain:AddToggle("StreamMode", {
		Text = "Stream Mode",
		Default = Flags.Settings.StreamMode,
	})

	SettingsMain:AddToggle("ShowWatermark", {
		Text = "Show Watermark",
		Default = Flags.Settings.ShowWatermark,
	})

	SettingsMain:AddToggle("ShowKeybinds", {
		Text = "Stream Mode",
		Default = Flags.Settings.StreamMode,
	})

	SettingsMain:AddDivider()
end

function Component:Load()
	BuildMenu()
end
function Component:Unload() end

return Component
