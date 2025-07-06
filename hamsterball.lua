-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local hamsterMode = true
local speed = 30
local jumpPower = 60
local braking = false

-- MAIN FUNCTION TO INIT SYSTEM PER CHARACTER
local function setupHamsterSystem(character)
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	-- Clean old UI and parts
	if player:FindFirstChild("PlayerGui"):FindFirstChild("HamsterUI") then
		player.PlayerGui.HamsterUI:Destroy()
	end
	if workspace:FindFirstChild("HamsterBallPart") then
		workspace.HamsterBallPart:Destroy()
	end

	-- BALL SETUP
	local ball = Instance.new("Part")
	ball.Name = "HamsterBallPart"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(5, 5, 5)
	ball.Material = Enum.Material.SmoothPlastic
	ball.Transparency = 1
	ball.CanCollide = true
	ball.Anchored = false
	ball.Position = root.Position
	ball.Parent = workspace

	local shell = Instance.new("Part")
	shell.Shape = Enum.PartType.Ball
	shell.Size = ball.Size + Vector3.new(0.1, 0.1, 0.1)
	shell.Transparency = 0.8
	shell.Anchored = false
	shell.CanCollide = false
	shell.Massless = true
	shell.Material = Enum.Material.ForceField
	shell.Color = Color3.fromRGB(0, 255, 255)
	shell.Parent = ball

	local shellWeld = Instance.new("WeldConstraint", shell)
	shellWeld.Part0 = ball
	shellWeld.Part1 = shell

	local weld = Instance.new("WeldConstraint", ball)
	weld.Part0 = ball
	weld.Part1 = root

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.CanCollide = false
		end
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {character}

	-- CAMERA & MODE TOGGLE
	local function activateBallMode()
		ball.Position = root.Position
		humanoid.PlatformStand = true
		Camera.CameraSubject = ball
	end

	local function deactivateBallMode()
		humanoid.PlatformStand = false
		ball.Velocity = Vector3.zero
		ball.RotVelocity = Vector3.zero
		Camera.CameraSubject = humanoid
	end

	-- UI SETUP
	local gui = Instance.new("ScreenGui", player.PlayerGui)
	gui.Name = "HamsterUI"
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 250, 0, 200)
	frame.Position = UDim2.new(0.05, 0, 0.5, -100)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Active = true
	frame.Draggable = true
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

	local toggleBtn = Instance.new("TextButton", frame)
	toggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
	toggleBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
	toggleBtn.Text = "Mode: HamsterBall"
	toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Font = Enum.Font.Gotham
	toggleBtn.TextSize = 14

	toggleBtn.MouseButton1Click:Connect(function()
		hamsterMode = not hamsterMode
		if hamsterMode then
			toggleBtn.Text = "Mode: HamsterBall"
			activateBallMode()
		else
			toggleBtn.Text = "Mode: Normal"
			deactivateBallMode()
		end
	end)

	local function createSlider(parent, labelText, yPos, minVal, maxVal, defaultVal, callback)
		local label = Instance.new("TextLabel", parent)
		label.Size = UDim2.new(0.9, 0, 0, 20)
		label.Position = UDim2.new(0.05, 0, yPos, 0)
		label.Text = labelText .. ": " .. defaultVal
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 14

		local slider = Instance.new("TextButton", parent)
		slider.Size = UDim2.new(0.9, 0, 0, 20)
		slider.Position = UDim2.new(0.05, 0, yPos + 0.05, 0)
		slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		slider.Text = ""

		local fill = Instance.new("Frame", slider)
		fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
		fill.BorderSizePixel = 0
		fill.Name = "Fill"

		local dragging = false
		slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		RunService.RenderStepped:Connect(function()
			if dragging then
				local mouseX = UserInputService:GetMouseLocation().X
				local absPos = slider.AbsolutePosition.X
				local size = slider.AbsoluteSize.X
				local alpha = math.clamp((mouseX - absPos) / size, 0, 1)
				fill.Size = UDim2.new(alpha, 0, 1, 0)
				local value = math.floor(minVal + (maxVal - minVal) * alpha)
				label.Text = labelText .. ": " .. value
				callback(value)
			end
		end)
	end

	createSlider(frame, "Speed", 0.35, 10, 100, speed, function(val)
		speed = val
	end)

	createSlider(frame, "Jump", 0.6, 10, 200, jumpPower, function(val)
		jumpPower = val
	end)

	-- MOVEMENT
	RunService.RenderStepped:Connect(function(dt)
		if not hamsterMode or not character or not character:IsDescendantOf(workspace) then return end
		if UserInputService:GetFocusedTextBox() then return end

		if braking then
			-- Smooth brake: lerp velocities toward zero (keep Y velocity for gravity)
			ball.Velocity = ball.Velocity:Lerp(Vector3.new(0, ball.Velocity.Y, 0), dt * 8)
			ball.RotVelocity = ball.RotVelocity:Lerp(Vector3.new(0, 0, 0), dt * 8)
		else
			-- Normal control speed
			local effectiveSpeed = speed

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				ball.RotVelocity -= Camera.CFrame.RightVector * dt * effectiveSpeed
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				ball.RotVelocity -= Camera.CFrame.LookVector * dt * effectiveSpeed
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				ball.RotVelocity += Camera.CFrame.RightVector * dt * effectiveSpeed
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				ball.RotVelocity += Camera.CFrame.LookVector * dt * effectiveSpeed
			end
		end
	end)

	UserInputService.JumpRequest:Connect(function()
		if not hamsterMode then return end
		local result = workspace:Raycast(
			ball.Position,
			Vector3.new(0, -((ball.Size.Y / 2) + 0.3), 0),
			rayParams
		)
		if result then
			ball.Velocity += Vector3.new(0, jumpPower, 0)
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R then
			braking = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R then
			braking = false
		end
	end)

	-- DEATH CLEANUP
	humanoid.Died:Connect(function()
		if gui then gui:Destroy() end
		if ball then ball:Destroy() end
	end)

	-- INITIALIZE
	activateBallMode()
end

-- ON CHARACTER SPAWN
player.CharacterAdded:Connect(function(char)
	task.wait(1) -- Wait for character parts to settle
	setupHamsterSystem(char)
end)

-- If already loaded
if player.Character then
	setupHamsterSystem(player.Character)
end
