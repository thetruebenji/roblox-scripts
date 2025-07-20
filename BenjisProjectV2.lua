-- Load Rayfield
local success, RayfieldLib = pcall(function()
	return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not RayfieldLib then
	warn("❌ Failed to load Rayfield library.")
	return
end

-- Create Main Window
local Window = RayfieldLib:CreateWindow({
	Name = "🔥 Benjiz Project",
	LoadingTitle = "Benjiz Project",
	LoadingSubtitle = "Script Hub",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false,
	ToggleUIKeybind = Enum.KeyCode.LeftControl
})

-- Create Tab and Section
local ScriptsTab = Window:CreateTab("Scripts", 4483362458)
local MainSection = ScriptsTab:CreateSection("Available Scripts")

-- Define scripts
local scripts = {
	{Name = "Infinite Yield", URL = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
	{Name = "Wisl's Project", URL = "https://raw.githubusercontent.com/wisl884/wisl-i-Universal-Project1/main/Wisl'i%20Universal%20Project.lua"},
	{Name = "AnnaBypasser", URL = "https://raw.githubusercontent.com/AnnaRoblox/AnnaBypasser/refs/heads/main/AnnaBypasser.lua"},
	{Name = "Superman Fly (R6)", URL = "https://raw.githubusercontent.com/thetruebenji/roblox-scripts/main/supermanfly2.lua.txt"},
	{Name = "Superman Fly (R15)", URL = "https://raw.githubusercontent.com/thetruebenji/roblox-scripts/main/SupermanFlyR15.lua"},
	{Name = "Hamsterball Roll", URL = "https://raw.githubusercontent.com/thetruebenji/roblox-scripts/main/hamsterball.lua"},
	{Name = "Just a baseplate scripts", URL = "https://raw.githubusercontent.com/Zmain/v3.lua"},
	{Name = "Aimlock V1", URL = "https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"}

}

-- Add buttons
for _, script in ipairs(scripts) do
	ScriptsTab:CreateButton({
		Name = script.Name,
		Callback = function()
			local ok, err = pcall(function()
				loadstring(game:HttpGet(script.URL))()
			end)
			if not ok then
				warn("❌ Error running " .. script.Name .. ": " .. err)
			end
		end
	})
end
