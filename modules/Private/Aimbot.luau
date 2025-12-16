local Options, Toggles = Ketamine.Library.Options, Ketamine.Library.Toggles
local Component = {}

local function BuildMenu()
	local Tab = Ketamine.Window:AddTab("Aimbot")
	local AimbotMain = Tab:AddLeftGroupbox("Assist")

	local AimToggle = AimbotMain:AddToggle("AimEnabled", {
		Text = "Enabled",
		Default = Flags.Aimbot.AimEnabled,
	})
	AimToggle:OnChanged(function(value)
		print("this got changed!", value)
		Flags.Aimbot.AimEnabled = value
	end)

	local AimKey = AimToggle:AddKeyPicker("AimKeybind", {
		Mode = "Hold",
		Text = "Aimbot",
		Default = "MB1",
	})
	Options.AimKeybind:OnClick(function(state)
		Flags.Aimbot.AimKeybindActive = state
	end)
	-- TODO: ADD UNIVERSAL KEYBIND MANAGER FOR HOLD/ALWAYS KEYPCIKERS

	local StickyToggle = AimbotMain:AddToggle("AimStickyEnabled", {
		Text = "Sticky Aim",
		Default = Flags.Aimbot.StickyAim.Enabled,
	})
	StickyToggle:OnChanged(function(value)
		Flags.Aimbot.StickyAim.Enabled = value
	end)

	local StickyMethod = AimbotMain:AddDropdown("StickyAimMethod", {
		Values = { "Weak", "Strong" },
		Default = Flags.Aimbot.StickyAim.Method,
		Text = "Sticky Aim Method",
	})
	StickyMethod:OnChanged(function(value)
		Flags.Aimbot.StickyAim.Method = value
	end)

	local AimMethod = AimbotMain:AddDropdown("AimMethod", {
		Values = { "Mouse", "Camera" },
		Default = Flags.Aimbot.AimMethod,
		Text = "Aim Method",
	})
	AimMethod:OnChanged(function(value)
		Flags.Aimbot.AimMethod = value
	end)

	local AimStyle = AimbotMain:AddDropdown("AimStyle", {
		Values = { "Linear", "Exponential", "Spring" },
		Default = Flags.Aimbot.AimStyle,
		Text = "Aim Easing",
	})
	AimStyle:OnChanged(function(value)
		Flags.Aimbot.AimStyle = value
	end)

	local AimPriority = AimbotMain:AddDropdown("AimPriority", {
		Values = { "Closest To Crosshair", "Closest To Player", "Lowest HP", "Highest HP" },
		Default = Flags.Aimbot.AimTargetting,
		Text = "Aim Priority",
	})
	AimPriority:OnChanged(function(value)
		Flags.Aimbot.AimTargetting = value
	end)

	local AimChecks = AimbotMain:AddDropdown("AimChecks", {
		Values = { "Forcefield", "Local Dead", "Invisible", "Visible", "Team" },
		AllowNull = true,
		Multi = true,
		Default = Flags.Aimbot.AimChecks,
		Text = "Aim Checks",
	})
	AimChecks:OnChanged(function()
		local values = AimChecks.Value
		for k in pairs(Flags.Aimbot.AimChecks) do
			Flags.Aimbot.AimChecks[k] = values[k] == true
		end
	end)

	local AimHitboxes = AimbotMain:AddDropdown("AimHitboxes", {
		Values = { "Head", "Torso", "Arms", "Legs" },
		AllowNull = true,
		Multi = true,
		Default = Flags.Aimbot.AimHitboxes,
		Text = "Aim Hitboxes",
	})
	AimHitboxes:OnChanged(function()
		local values = AimHitboxes.Value
		for k in pairs(Flags.Aimbot.AimHitboxes) do
			Flags.Aimbot.AimHitboxes[k] = values[k] == true
		end
	end)

	local SmoothToggle = AimbotMain:AddToggle("SmoothnessEnabled", {
		Text = "Smoothness",
		Default = Flags.Aimbot.Smoothness.Enabled,
	})
	SmoothToggle:OnChanged(function(value)
		Flags.Aimbot.Smoothness.Enabled = value
	end)

	local SmoothX = AimbotMain:AddSlider("AimSmoothnessX", {
		Text = "Smoothness (X)",
		Default = Flags.Aimbot.Smoothness.SmoothnessX,
		Min = 0,
		Max = 100,
		Rounding = 1,
	})
	SmoothX:OnChanged(function(value)
		Flags.Aimbot.Smoothness.SmoothnessX = value
	end)

	local SmoothY = AimbotMain:AddSlider("AimSmoothnessY", {
		Text = "Smoothness (Y)",
		Default = Flags.Aimbot.Smoothness.SmoothnessY,
		Min = 0,
		Max = 100,
		Rounding = 1,
	})
	SmoothY:OnChanged(function(value)
		Flags.Aimbot.Smoothness.SmoothnessY = value
	end)

	local PredictionToggle = AimbotMain:AddToggle("PredictionEnabled", {
		Text = "Prediction",
		Default = Flags.Aimbot.Prediction.Enabled,
	})
	PredictionToggle:OnChanged(function(value)
		Flags.Aimbot.Prediction.Enabled = value
	end)

	local PredictionMode = AimbotMain:AddDropdown("PredictionMode", {
		Text = "Prediction Mode",
		Values = { "Manual", "Automatic" },
		Default = Flags.Aimbot.Prediction.Mode,
	})
	PredictionMode:OnChanged(function(value)
		Flags.Aimbot.Prediction.Mode = value
	end)

	local PredictX = AimbotMain:AddSlider("ManualPredictionX", {
		Text = "Predict (X)",
		Default = Flags.Aimbot.Prediction.PredictionX,
		Min = 0,
		Max = 10,
		Rounding = 1,
	})
	PredictX:OnChanged(function(value)
		Flags.Aimbot.Prediction.PredictionX = value
	end)

	local PredictY = AimbotMain:AddSlider("ManualPredictionY", {
		Text = "Predict (Y)",
		Default = Flags.Aimbot.Prediction.PredictionY,
		Min = 0,
		Max = 10,
		Rounding = 1,
	})
	PredictY:OnChanged(function(value)
		Flags.Aimbot.Prediction.PredictionY = value
	end)

	local Multipoint = AimbotMain:AddSlider("AimMultipointScale", {
		Text = "Multipoint Scale",
		Default = Flags.Aimbot.MultipointScale,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Suffix = "%",
	})
	Multipoint:OnChanged(function(value)
		Flags.Aimbot.MultipointScale = value
	end)

	local FOVToggle = AimbotMain:AddToggle("DrawAimFOV", {
		Text = "Draw FOV",
		Default = Flags.Aimbot.FieldOfView.DrawingEnabled,
	})
	FOVToggle:OnChanged(function(value)
		Flags.Aimbot.FieldOfView.DrawingEnabled = value
	end)

	local FOVSlider = AimbotMain:AddSlider("AimFOV", {
		Text = "Field Of View",
		Default = Flags.Aimbot.FieldOfView.Degrees,
		Min = 0,
		Max = 500,
		Rounding = 1,
	})
	FOVSlider:OnChanged(function(value)
		Flags.Aimbot.FieldOfView.Degrees = value
	end)

	local FOVFill = FOVToggle:AddColorPicker("FOVFillColor", {
		Title = "FOV Fill Color",
		Default = Flags.Aimbot.FieldOfView.Color.Fill.Color,
		Transparency = Flags.Aimbot.FieldOfView.Color.Fill.Transparency,
	})
	FOVFill:OnChanged(function(color, trans)
		Flags.Aimbot.FieldOfView.Color.Fill.Color = color
		Flags.Aimbot.FieldOfView.Color.Fill.Transparency = trans
	end)

	local FOVOutline = FOVToggle:AddColorPicker("FOVOutlineColor", {
		Title = "FOV Outline Color",
		Default = Flags.Aimbot.FieldOfView.Color.Outline.Color,
		Transparency = Flags.Aimbot.FieldOfView.Color.Outline.Transparency,
	})
	FOVOutline:OnChanged(function(color, trans)
		Flags.Aimbot.FieldOfView.Color.Outline.Color = color
		Flags.Aimbot.FieldOfView.Color.Outline.Transparency = trans
	end)

	local DeadzoneToggle = AimbotMain:AddToggle("DrawAimDeadzoneFOV", {
		Text = "Draw Deadzone",
		Default = Flags.Aimbot.Deadzone.DrawingEnabled,
	})
	DeadzoneToggle:OnChanged(function(value)
		Flags.Aimbot.Deadzone.DrawingEnabled = value
	end)

	local DeadzoneSlider = AimbotMain:AddSlider("AimDeadzoneFOV", {
		Text = "Deadzone FOV",
		Default = Flags.Aimbot.Deadzone.Degrees,
		Min = 0,
		Max = 500,
		Rounding = 1,
	})
	DeadzoneSlider:OnChanged(function(value)
		Flags.Aimbot.Deadzone.Degrees = value
	end)

	local DeadzoneFill = DeadzoneToggle:AddColorPicker("DeadzoneFillColor", {
		Title = "Deadzone Fill Color",
		Default = Flags.Aimbot.Deadzone.Color.Fill.Color,
		Transparency = Flags.Aimbot.Deadzone.Color.Fill.Transparency,
	})
	DeadzoneFill:OnChanged(function(color, trans)
		Flags.Aimbot.Deadzone.Color.Fill.Color = color
		Flags.Aimbot.Deadzone.Color.Fill.Transparency = trans
	end)

	local DeadzoneOutline = DeadzoneToggle:AddColorPicker("DeadzoneOutlineColor", {
		Title = "Deadzone Outline Color",
		Default = Flags.Aimbot.Deadzone.Color.Outline.Color,
		Transparency = Flags.Aimbot.Deadzone.Color.Outline.Transparency,
	})
	DeadzoneOutline:OnChanged(function(color, trans)
		Flags.Aimbot.Deadzone.Color.Outline.Color = color
		Flags.Aimbot.Deadzone.Color.Outline.Transparency = trans
	end)

	local MaxDistance = AimbotMain:AddSlider("AimMaxDistance", {
		Text = "Max Distance",
		Default = Flags.Aimbot.MaxDistance,
		Min = 1,
		Max = 5000,
		Rounding = 1,
		Suffix = "m",
	})
	MaxDistance:OnChanged(function(value)
		Flags.Aimbot.MaxDistance = value
	end)
end

function Component:Load()
	BuildMenu()
end
function Component:Unload() end

return Component
