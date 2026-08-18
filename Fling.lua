-- Modernized Touch Fling + Anti-Fling GUI (FIXED VOID & COLLISION BUG)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local guiParent = pcall(function() return CoreGui.Name end) and CoreGui or lp:WaitForChild("PlayerGui")

if guiParent:FindFirstChild("TouchFling") then
	guiParent.TouchFling:Destroy()
end

-- Bố cục GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TouchFling"
ScreenGui.Parent = guiParent
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.4, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 158, 0, 160)

local TitleFrame = Instance.new("Frame")
TitleFrame.Parent = Frame
TitleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
TitleFrame.BorderSizePixel = 0
TitleFrame.Size = UDim2.new(1, 0, 0, 25)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleFrame
TitleText.BackgroundTransparency = 1.000
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Font = Enum.Font.Sarpanch
TitleText.Text = "Touch Fling"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 22.000

local FlingBtn = Instance.new("TextButton")
FlingBtn.Parent = Frame
FlingBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.Position = UDim2.new(0.11, 0, 0.25, 0)
FlingBtn.Size = UDim2.new(0.78, 0, 0.25, 0)
FlingBtn.Font = Enum.Font.SourceSansItalic
FlingBtn.Text = "Fling: OFF"
FlingBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
FlingBtn.TextSize = 20.000

local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Parent = Frame
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AntiFlingBtn.Position = UDim2.new(0.11, 0, 0.6, 0)
AntiFlingBtn.Size = UDim2.new(0.78, 0, 0.25, 0)
AntiFlingBtn.Font = Enum.Font.SourceSansItalic
AntiFlingBtn.Text = "Anti-Fling: OFF"
AntiFlingBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
AntiFlingBtn.TextSize = 20.000

-- Logic Kéo GUI
local dragging, dragInput, dragStart, startPos
TitleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TitleFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- LOGIC FLING (Tối ưu vận tốc không bị rớt map)
local isFlinging = false
local flingRunning = false

local function startFlingLoop()
	if flingRunning then return end
	flingRunning = true

	task.spawn(function()
		local movel = 0.1
		while isFlinging do
			RunService.Heartbeat:Wait()
			local c = lp.Character
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			local hum = c and c:FindFirstChildOfClass("Humanoid")

			if hrp and hum and hum.Health > 0 then
				local vel = hrp.AssemblyLinearVelocity
				-- Giảm vận tốc xuống mức an toàn chuẩn (10000) đủ hất văng người khác mà không bay mất nhân vật
				hrp.AssemblyLinearVelocity = Vector3.new(0, 999999, 0)
				hrp.AssemblyAngularVelocity = Vector3.new(0, 999999, 0)

				RunService.RenderStepped:Wait()
				hrp.AssemblyLinearVelocity = vel
				hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

				RunService.Stepped:Wait()
				hrp.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
				movel = -movel
			end
		end
		flingRunning = false
	end)
end

FlingBtn.MouseButton1Click:Connect(function()
	isFlinging = not isFlinging
	FlingBtn.Text = isFlinging and "Fling: ON" or "Fling: OFF"

	if isFlinging then
		startFlingLoop()
	else
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
	end
end)

-- LOGIC ANTI-FLING (Tắt va chạm CanCollide với người chơi khác)
local isAntiFling = false

task.spawn(function()
	while true do
		RunService.Stepped:Wait()
		if isAntiFling then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= lp and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end
		end
	end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
	isAntiFling = not isAntiFling
	AntiFlingBtn.Text = isAntiFling and "Anti-Fling: ON" or "Anti-Fling: OFF"
end)

-- Tự động chạy lại khi Respawn
lp.CharacterAdded:Connect(function(newChar)
	local hum = newChar:WaitForChild("Humanoid", 10)
	if hum and isFlinging then
		task.wait(0.5)
		startFlingLoop()
	end
end)
