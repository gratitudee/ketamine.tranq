local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
	local Tab = Ketamine.Window:AddTab("Aimbot")
	local AimbotTabBox = Tab:AddLeftTabbox()
	local AimbotMain = AimbotTabBox:AddTab("Main")
	local AimbotSettings = AimbotTabBox:AddTab("Settings")

	-- Aimbot Main
	AimbotMain:AddToggle("AimEnabled", {
		Text = "Enabled",
		Default = Flags.Aimbot.Enabled,
	}):AddKeyPicker("AimKeybind", {
		Mode = "Hold",
		Text = "Aimbot",
		Default = "MB1",
	})

	AimbotMain:AddToggle("DrawAimFOV", {
		Text = "Draw FOV",
		Default = Flags.Aimbot.DrawFOV,
	})
	AimbotMain:AddSlider("AimFOV", {
		Text = "Field Of View",
		Default = Flags.Aimbot.FieldOfView,
		Min = 1,
		Max = 500,
		Rounding = 1,
	})
	AimbotMain:AddToggle("DrawAimDeadzoneFOV", {
		Text = "Draw FOV",
		Default = Flags.Aimbot.DrawDeadzone,
	})
	AimbotMain:AddSlider("AimDeadzoneFOV", {
		Text = "Deadzone Field Of View",
		Default = Flags.Aimbot.DeadzoneFieldOfView,
		Min = 1,
		Max = 500,
		Rounding = 1,
	})
	-- Aimbot Settings
	AimbotSettings:AddDropdown("AimMethod", {
		Values = { "Mouse", "Camera" },
		Default = Flags.Aimbot.AimMethod,
		Text = "Aim Method",
	})

	AimbotSettings:AddDropdown("AimStyle", {
		Values = { "Linear", "Exponential", "Spring" },
		Default = Flags.Aimbot.AimStyle,
		Text = "Aim Easing",
	})

	AimbotSettings:AddDropdown("AimPriority", {
		Values = { "Closest To Crosshair", "Closest To Player", "Lowest HP", "Highest HP" },
		Default = Flags.Aimbot.AimTargetting,
		Text = "Aim Priority",
	})

	AimbotSettings:AddDropdown("AimChecks", {
		Values = { "Forcefield", "Local Dead", "Invisible", "Visible", "Team" },
		AllowNull = true,
		Multi = true,
		Default = Flags.Aimbot.AimChecks,
		Text = "Aim Checks",
	})

	AimbotSettings:AddSlider("AimMaxDistance", {
		Text = "Max Distance",
		Default = Flags.Aimbot.MaxDistance,
		Min = 1,
		Max = 5000,
		Rounding = 1,
	})
end

function Component:Load()
	BuildMenu()
end
function Component:Unload() end

return Component
