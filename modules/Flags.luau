return {
	Aimbot = {
		Enabled = false,
		KeybindHeld = false,

		Smoothness = {
			Enabled = false,
			SmoothnessX = 50,
			SmoothnessY = 50,
		},

		MultipointScale = 0,

		FieldOfView = {
			DrawingEnabled = false,
			Degrees = 70,
			Color = {
				Fill = {
					Color = Color3.new(1, 1, 1),
					Transparency = 0.7,
				},
				Outline = {
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
				},
			},
		},

		Deadzone = {
			DrawingEnabled = false,
			Degrees = 0,
			Color = {
				Fill = {
					Color = Color3.new(1, 1, 1),
					Transparency = 0.7,
				},
				Outline = {
					Color = Color3.new(0, 0, 0),
					Transparency = 0,
				},
			},
		},

		AimMethod = "Mouse",
		AimStyle = "Linear",
		AimTargetting = "Closest To Crosshair",
		AimChecks = {
			Forcefield = false,
			["Local Dead"] = false,
			Invisible = false,
			Visible = false,
			Team = true,
		},
		MaxDistance = 500,
	},
	Visuals = {},
	Settings = {
		MenuKeybind = "Z",
		RaycastOrigin = "Camera",
		StreamMode = false,
		ShowWatermark = false,
		ShowKeybinds = false,

		EntityLogs = {
			Enabled = false,
			PlaySoundOnLog = false,
			SoundToPlay = nil,
			Types = {
				Added = false,
				Removed = false,
				Hit = false,
				Killed = false,
			},
		},

		Hitmarkers = {
			Enabled = false,
			AnimateHitmarker = false,
			RotationSpeed = 1,
			HitmarkerSound = false,
			HitmarkerSoundVolume = 0.3,
			SoundToPlay = nil,
		},
	},
}
