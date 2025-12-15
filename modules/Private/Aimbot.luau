local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
	local Tab = Ketamine.Window:AddTab("Aimbot")
	local AimbotTabBox = Tab:AddLeftTabBox()
	local AimbotMain = AimbotTabBox:AddTab("Main")
	local AimbotSettings = AimbotTabBox:AddTab("Settings")

	-- Main

	-- Settings
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
		Values = { "Invisible", "Visible", "Target Team" },
		AllowNull = true,
		Multi = true,
		Default = nil,
	})
end

function Component:Load()
	BuildMenu()
end
function Component:Unload() end

return Component
