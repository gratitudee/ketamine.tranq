local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
	local Tab = Ketamine.Window:AddTab("Aimbot")
	local AimbotMain = Tab:AddLeftGroupbox("Assist")

	-- Aimbot Main
	AimbotMain:AddToggle("AimEnabled", {
		Text = "Enabled",
		Default = Flags.Aimbot.Enabled,
	}):AddKeyPicker("AimKeybind", {
		Mode = "Hold",
		Text = "Aimbot",
		Default = "MB1",
	})

	AimbotMain:AddDivider()

	AimbotMain:AddDropdown("AimMethod", {
		Values = { "Mouse", "Camera" },
		Default = Flags.Aimbot.AimMethod,
		Text = "Aim Method",
	})

	AimbotMain:AddDropdown("AimStyle", {
		Values = { "Linear", "Exponential", "Spring" },
		Default = Flags.Aimbot.AimStyle,
		Text = "Aim Easing",
	})

	AimbotMain:AddDropdown("AimPriority", {
		Values = { "Closest To Crosshair", "Closest To Player", "Lowest HP", "Highest HP" },
		Default = Flags.Aimbot.AimTargetting,
		Text = "Aim Priority",
	})

	AimbotMain:AddDropdown("AimChecks", {
		Values = { "Forcefield", "Local Dead", "Invisible", "Visible", "Team" },
		AllowNull = true,
		Multi = true,
		Default = Flags.Aimbot.AimChecks,
		Text = "Aim Checks",
	})

	AimbotMain:AddDivider()

	AimbotMain:AddToggle("SmoothnessEnabled", {
		Text = "Smoothness",
		Default = Flags.Aimbot.Smoothness.Enabled,
	})

	local SmoothnessDependency = AimbotMain:AddDependencyBox()
	SmoothnessDependency:AddSlider("AimSmoothnessX", {
		Text = "Smoothness (X)",
		Default = Flags.Aimbot.Smoothness.SmoothnessX,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Compact = true,
	})
	SmoothnessDependency:AddSlider("AimSmoothnessY", {
		Text = "Smoothness (Y)",
		Default = Flags.Aimbot.Smoothness.SmoothnessY,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Compact = true,
	})

	SmoothnessDependency:SetupDependencies({ { Toggles.SmoothnessEnabled, true } })

	AimbotMain:AddSlider("AimMultipointScale", {
		Text = "Multipoint Scale",
		Default = Flags.Aimbot.MultipointScale,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Suffix = "%",
		Compact = true,
	})

	AimbotMain:AddToggle("PredictionEnabled", {
		Text = "Prediction",
		Default = Flags.Aimbot.Prediction.Enabled,
	})

	local PredictionDependency = AimbotMain:AddDependencyBox()
	PredictionDependency:AddDropdown("PredictionMode", {
		Text = "Prediction Mode",
		Values = { "Manual", "Automatic" },
		Default = Flags.Aimbot.Prediction.Mode,
	})

	PredictionDependency:SetupDependencies({ { Toggles.PredictionEnabled, true } })

	local SubPredictionDependency = PredictionDependency:AddDependencyBox()
	SubPredictionDependency:AddSlider("ManualPredictionX", {
		Text = "Predict (X)",
		Default = Flags.Aimbot.Prediction.PredictionX,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Compact = true,
	})

	SubPredictionDependency:AddSlider("ManualPredictionY", {
		Text = "Predict (Y)",
		Default = Flags.Aimbot.Prediction.PredictionY,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Compact = true,
	})

	SubPredictionDependency:SetupDependencies({ { Options.PredictionMode, "Manual" } })

	AimbotMain:AddDivider()

	AimbotMain:AddToggle("DrawAimFOV", {
		Text = "Draw FOV",
		Default = Flags.Aimbot.FieldOfView.DrawingEnabled,
	})
		:AddColorPicker("FOVFillColor", {
			Title = "FOV Fill Color",
			Default = Flags.Aimbot.FieldOfView.Color.Fill.Color,
			Transparency = Flags.Aimbot.FieldOfView.Color.Fill.Transparency,
		})
		:AddColorPicker("FOVOutlineColor", {
			Title = "FOV Outline Color",
			Default = Flags.Aimbot.FieldOfView.Color.Outline.Color,
			Transparency = Flags.Aimbot.FieldOfView.Color.Outline.Transparency,
		})

	AimbotMain:AddSlider("AimFOV", {
		Text = "Field Of View",
		Default = Flags.Aimbot.FieldOfView.Degrees,
		Min = 1,
		Max = 500,
		Rounding = 1,
		Suffix = "°",
		Compact = true,
	})

	AimbotMain:AddToggle("DrawAimDeadzoneFOV", {
		Text = "Draw Deadzone",
		Default = Flags.Aimbot.Deadzone.DrawingEnabled,
	})
		:AddColorPicker("DeadzoneFillColor", {
			Title = "Deadzone Fill Color",
			Default = Flags.Aimbot.Deadzone.Color.Fill.Color,
			Transparency = Flags.Aimbot.Deadzone.Color.Fill.Transparency,
		})
		:AddColorPicker("DeadzoneOutlineColor", {
			Title = "Deadzone Outline Color",
			Default = Flags.Aimbot.Deadzone.Color.Outline.Color,
			Transparency = Flags.Aimbot.Deadzone.Color.Outline.Transparency,
		})

	AimbotMain:AddSlider("AimDeadzoneFOV", {
		Text = "Field Of View",
		Default = Flags.Aimbot.Deadzone.Degrees,
		Min = 1,
		Max = 500,
		Rounding = 1,
		Suffix = "°",
		Compact = true,
	})

	AimbotMain:AddDivider()

	AimbotMain:AddSlider("AimMaxDistance", {
		Text = "Max Distance",
		Default = Flags.Aimbot.MaxDistance,
		Min = 1,
		Max = 5000,
		Rounding = 1,
		Suffix = "m",
		Compact = true,
	})
end

function Component:Load()
	BuildMenu()
end
function Component:Unload() end

return Component
