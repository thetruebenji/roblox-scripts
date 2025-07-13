local UIS = game:GetService("UserInputService")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 360)
mainFrame.Position = UDim2.new(0, 20, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- Title (also drag handle)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🔥 Benjis Project"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

-- Make draggable
local dragging = false
local dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
									   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Layout
local layout = Instance.new("UIListLayout", mainFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local spacer = Instance.new("Frame", mainFrame)
spacer.Size = UDim2.new(1, 0, 0, 5)
spacer.BackgroundTransparency = 1

-- Button maker
local function makeButton(name, url)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Position = UDim2.new(0, 5, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.Text = name
	btn.Parent = mainFrame

	btn.MouseButton1Click:Connect(function()
		local success, err = pcall(function()
			loadstring(game:HttpGet(url, true))()
		end)
		if not success then
			warn("Failed to load " .. name .. ": " .. err)
		end
	end)
end

-- Your scripts
makeButton("Infinite Yield", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
makeButton("Wisl's Project", "https://raw.githubusercontent.com/wisl884/wisl-i-Universal-Project1/main/Wisl'i%20Universal%20Project.lua")
makeButton("AnnaBypasser", "https://raw.githubusercontent.com/AnnaRoblox/AnnaBypasser/refs/heads/main/AnnaBypasser.lua")
makeButton("Superman Fly (R6)", "https://raw.githubusercontent.com/thetruebenji/roblox-scripts/main/supermanfly2.lua.txt")
makeButton("Superman Fly (R15)", "https://raw.githubusercontent.com/thetruebenji/roblox-scripts/main/SupermanFlyR15.lua")
makeButton("Hamsterball Roll", "https://raw.githubusercontent.com/thetruebenji/roblox-scripts/main/hamsterball.lua")
makeButton("Hat Hub (Just a baseplate)", "https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua")

-- Left Ctrl toggles GUI
local isVisible = true
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
		isVisible = not isVisible
		mainFrame.Visible = isVisible
	end
end)
