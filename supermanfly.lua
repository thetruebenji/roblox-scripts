local UserInputService = game.UserInputService
local TweenService = game.TweenService
local RunService = game["Run Service"]
local CurrentCamera = game.Workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local IdleAnim1 = Instance.new("Animation")
IdleAnim1.AnimationId = "rbxassetid://10921144709"
local IdleAnim2 = Instance.new("Animation")
IdleAnim2.AnimationId = "rbxassetid://10921132962"
local FlyAnim = Instance.new("Animation")
FlyAnim.AnimationId = "rbxassetid://10921294559"
local LoadIdle1 = Humanoid:LoadAnimation(IdleAnim1)
local LoadIdle2 = Humanoid:LoadAnimation(IdleAnim2)
local LoadFly = Humanoid:LoadAnimation(FlyAnim)
LoadIdle1.Priority = Enum.AnimationPriority.Action
LoadIdle2.Priority = Enum.AnimationPriority.Action
LoadFly.Priority = Enum.AnimationPriority.Action
LoadIdle1.Looped = true
LoadIdle2.Looped = true
LoadFly.Looped = true

local FlySpeed = 1
local EquipFunction = false
local Equipped = false
local Enabled = false

local FlyPart = Instance.new("Part")
FlyPart.Anchored = true
FlyPart.CanCollide = false
FlyPart.Transparency = 1
FlyPart.Size = HumanoidRootPart.Size
FlyPart.CFrame = HumanoidRootPart.CFrame
FlyPart.Parent = CurrentCamera

local FlyVelocity = Instance.new("BodyVelocity")
FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
FlyVelocity.Velocity = Vector3.new(0, 0, 0)
FlyVelocity.Parent = FlyPart

local FlyTool = Instance.new("Tool")
FlyTool.Name = "Fly"
FlyTool.RequiresHandle = false
FlyTool.CanBeDropped = false
FlyTool.Parent = LocalPlayer.Backpack

FlyTool.Equipped:Connect(function()
	FlyPart.CFrame = HumanoidRootPart.CFrame
	Equipped = true
end)
FlyTool.Unequipped:Connect(function()
	Equipped = false
	Enabled = false
end)
FlyTool.Activated:Connect(function()
	FlyPart.CFrame = HumanoidRootPart.CFrame
	Enabled = true
end)
FlyTool.Deactivated:Connect(function()
	Enabled = false
end)

HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
	FlyPart.CFrame = HumanoidRootPart.CFrame
end)

LocalPlayer.CharacterAdded:Connect(function()
	Character = LocalPlayer.Character or LocalPlayer.CharactedAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	FlyTool.Parent = LocalPlayer.Backpack

	EquipFunction = false
	Equipped = false
	Enabled = false

	LoadIdle1 = Humanoid:LoadAnimation(IdleAnim1)
	LoadIdle2 = Humanoid:LoadAnimation(IdleAnim2)
	LoadFly = Humanoid:LoadAnimation(FlyAnim)
	LoadIdle1.Priority = Enum.AnimationPriority.Action
	LoadIdle2.Priority = Enum.AnimationPriority.Action
	LoadFly.Priority = Enum.AnimationPriority.Action
	LoadIdle1.Looped = true
	LoadIdle2.Looped = true
	LoadFly.Looped = true

	FlyVelocity.Velocity = Vector3.new(0, 0, 0)

	HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
		FlyPart.CFrame = HumanoidRootPart.CFrame
	end)
end)

LocalPlayer.Chatted:Connect(function(Message)
	local SplitMessage = string.split(Message, " ")
	if string.lower(SplitMessage[1]) == "/e" and string.lower(SplitMessage[2]) == "flyspeed" then
		if tonumber(SplitMessage[3]) ~= nil then
			FlySpeed = tonumber(SplitMessage[3])
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if HumanoidRootPart then
		if Equipped then
			task.spawn(function()
				local Enums = Enum.HumanoidStateType:GetEnumItems()
				table.remove(Enums, table.find(Enums, Enum.HumanoidStateType.None))
				for i,v in pairs(Enums) do
					if Humanoid.Health > 0 then
						Humanoid:SetStateEnabled(v, false)
					else
						Humanoid:SetStateEnabled(v, true)
					end
				end
			end)
			Humanoid.AutoRotate = false
			EquipFunction = true

			HumanoidRootPart.CFrame = FlyPart.CFrame
			HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
			HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
			if Character:FindFirstChild("Animate") then
				Character.Animate.Enabled = false
			end

			if not Enabled then
				if not LoadIdle1.IsPlaying then
					LoadIdle1:Play()
					LoadIdle2:Play()
					LoadIdle2:AdjustWeight(0.5)
				end
				LoadFly:Stop()
				FlyVelocity.Velocity = Vector3.new(0, 0, 0)
				local LookVector = FlyPart.Position + CurrentCamera.CFrame.LookVector
				local IdleCFrame = CFrame.lookAt(FlyPart.Position, LookVector)
				TweenService:Create(FlyPart, TweenInfo.new(0.25), {
					CFrame = IdleCFrame
				}):Play()
			else
				if not LoadFly.IsPlaying then
					LoadFly:Play(0.1)
					LoadFly:AdjustSpeed(0)
					LoadFly.TimePosition = 0.5
				end
				LoadIdle1:Stop()
				LoadIdle2:Stop()
				local LookVector = (Mouse.Hit.Position - CurrentCamera.CFrame.Position).Unit
				local FlyCFrame = CFrame.lookAt(FlyPart.Position, FlyPart.Position + LookVector)*CFrame.Angles(math.rad(-65), 0, 0)
				FlyVelocity.Velocity = Vector3.new(0, 0, 0)
				TweenService:Create(FlyPart, TweenInfo.new(0.25), {
					CFrame = FlyCFrame + (LookVector * 5) * FlySpeed
				}):Play()
			end
		else
			if EquipFunction == true then
				EquipFunction = false
				LoadIdle1:Stop()
				LoadIdle2:Stop()
				LoadFly:Stop()
				task.spawn(function()
					local Enums = Enum.HumanoidStateType:GetEnumItems()
					table.remove(Enums, table.find(Enums, Enum.HumanoidStateType.None))
					for i,v in pairs(Enums) do
						Humanoid:SetStateEnabled(v, true)
					end
				end)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
				Humanoid.AutoRotate = true
				HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
				if Character:FindFirstChild("Animate") then
					Character.Animate.Enabled = true
				end
			end
		end
	end
end)

game:GetService("StarterGui"):SetCore("SendNotification",{
	Title = "Superman Fly",
	Text = "Type '/e flyspeed <speed>' in chat to change speed"
})