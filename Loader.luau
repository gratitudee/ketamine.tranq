local Entity = require("./.vscode/OldSRC/Modules/Entity")
if not Ketamine then
	getgenv().Ketamine = {}
end

function Ketamine:Notify(...)
	if Ketamine and Ketamine.Library and not Ketamine.StreamMode then
		Ketamine.Library:Notify(...)
	end
end

function Ketamine:SecureCall(Function, ...)
	if typeof(Function) ~= "function" then
		print(`[K.T]: Function expected got {typeof(Function)}`)
		return
	end

	local Success, Result = pcall(Function, ...)
	if not Success and Result then
		local Traceback = debug.traceback()
		if Ketamine.Notify then
			Ketamine:Notify({
				Title = "!",
				Description = "Exception Caught, Check F9 Logs",
			})
		end

		print(`[K.T]: Exception Caught: {Result}, Traceback: {Traceback}`)
	end

	return Success, Result
end

function Ketamine:SecureSpawn(Function, ...)
	task.spawn(Ketamine.SecureCall, Ketamine, Function, ...)
end

function Ketamine:Import(Path)
	local _, Response = Ketamine:SecureCall(request, {
		Url = `{Ketamine.Repo}{Path}`,
		Method = "GET",
	})

	if not Response.Success then
		return nil
	end

	local Function = loadstring(Response.Body)

	return typeof(Function) == "function" and Ketamine:SecureCall(Function) or nil
end

return function(Options: {
	StreamMode: boolean,
})
	local Success = Ketamine:SecureCall(function()
		if Ketamine and Ketamine.IsLoaded then
			Ketamine:Notify({
				Title = "!",
				Description = "FAILED TO LOAD: Already loaded.",
			})
			return
		end

		Ketamine.Repo = "https://raw.githubusercontent.com/gratitudee/ketamine.tranq/refs/heads/main/"
		Ketamine.IsLoaded = true
		Ketamine.StreamMode = Options and Options.StreamMode or false
		Ketamine.Library = Ketamine:Import("Packages/Library.luau")
		Ketamine.LibraryAddons = {
			Save = Ketamine:Import("Packages/SaveManager.luau"),
			Theme = Ketamine:Import("Packages/ThemeManager.luau"),
		}

		-- Top Level API
		getgenv().Entity = Ketamine:Import("modules/Components/Entity.luau")
		getgenv().Draw = Ketamine:Import("modules/Components/Draw.luau")
		getgenv().Cheat = Ketamine:Import("modules/Components/Cheat.luau")

		-- Private Level Cheat Functions
		local Aimbot = Ketamine:Import("modules/Private/Aimbot.luau")
		local Visuals = Ketamine:Import("modules/Private/Visuals.luau")
		local Settings = Ketamine:Import("modules/Private/Settings.luau")

		local GameSupport = Ketamine:Import(`modules/Support/{game.GameId}`)
		if GameSupport then
			Ketamine.Support = GameSupport
		end

		local Required = {
			Ketamine.Library,
			Ketamine.LibraryAddons.Save,
			Ketamine.LibraryAddons.Theme,
			Entity,
			Draw,
			Cheat,
			Aimbot,
			Visuals,
			Settings,
		}

		for _, v in ipairs(Required) do
			if not v then
				print(`ABORTED LOADING, MISSING DEPENDENCIES`)
				getgenv().Ketamine = nil
				return
			end
		end

		-- Window Creation
		Ketamine.Window = Ketamine.Library:CreateWindow({
			Title = "ketamine.tranq",
			Center = true,
			AutoShow = not Ketamine.StreamMode,
			UnlockMouseWhileOpen = true,
		})

		-- Start Dependencies
		Ketamine:SecureSpawn(Cheat.Load, Cheat)
		Ketamine:SecureSpawn(Entity.Load, Entity)
		Ketamine:SecureSpawn(Draw.Load, Draw)

		-- Start Features
		Ketamine:SecureSpawn(Aimbot.Load, Aimbot)
		Ketamine:SecureSpawn(Visuals.Load, Visuals)
		Ketamine:SecureSpawn(Settings.Load, Settings)

		Cheat:OnUnload(function()
			Ketamine:Notify({
				Title = "!",
				Description = "Unloading Cheat",
			})

			-- Unload Dependencies
			Ketamine:SecureSpawn(Entity.Unload, Entity)
			Ketamine:SecureSpawn(Draw.Unload, Draw)
			Ketamine:SecureSpawn(Cheat.Unload, Cheat)

			-- Unload Features
			Ketamine:SecureSpawn(Aimbot.Unload, Aimbot)
			Ketamine:SecureSpawn(Visuals.Unload, Visuals)
			Ketamine:SecureSpawn(Settings.Unload, Settings)
			Ketamine.Library:Unload()

			task.delay(1, function()
				getgenv().Ketamine = nil
			end)
		end)

		Ketamine.Library:OnUnload(function()
			Ketamine.Library.Unloaded = true
		end)
	end)

	if not Success then
		if Cheat then
			Ketamine:SecureSpawn(Cheat.Unload, Cheat)
		end

		if Ketamine and Ketamine.Library then
			Ketamine.Library:Unload()
			Ketamine.Library.Unloaded = true
		end

		if Ketamine then
			getgenv().Ketamine = nil
		end
	end
end
