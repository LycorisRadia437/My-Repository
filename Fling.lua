-- Modernized Touch Fling + Anti-Fling GUI (MAX SENSITIVITY)
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
Frame.Size = UDim2.new(0, 158, 0, 160) -- Tăng chiều cao để chứa 2 nút

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

-- Logic Kéo/Di chuyển GUI
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

-- Logic Fling (Tấn công)
local isFlinging = false
local flingThread

local function fling()
	local c, hrp, vel, movel = nil, nil, nil, 0.1
	
	while isFlinging do
		RunService.Heartbeat:Wait()
		c = lp.Character
		hrp = c and c:FindFirstChild("HumanoidRootPart")
		
		if hrp then
			vel = hrp.AssemblyLinearVelocity
			
			hrp.AssemblyLinearVelocity = vel * 99999 + Vector3.new(0, 99999, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
			
			RunService.RenderStepped:Wait()
			
			hrp.AssemblyLinearVelocity = vel
			hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			
			RunService.Stepped:Wait()
			
			hrp.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
			movel = -movel
		end
	end
end

FlingBtn.MouseButton1Click:Connect(function()
	isFlinging = not isFlinging
	FlingBtn.Text = isFlinging and "Fling: ON" or "Fling: OFF"
	
	if isFlinging then
		flingThread = coroutine.create(fling)
		coroutine.resume(flingThread)
	else
		local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
			hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
		end
	end
end)

-- Logic Anti-Fling (Phòng thủ)
local isAntiFling = false
local antiFlingConnection

AntiFlingBtn.MouseButton1Click:Connect(function()
	isAntiFling = not isAntiFling
	AntiFlingBtn.Text = isAntiFling and "Anti-Fling: ON" or "Anti-Fling: OFF"
	
	if isAntiFling then
		-- Chạy trên Stepped (kích hoạt ngay trước khi engine vật lý tính toán va chạm)
		antiFlingConnection = RunService.Stepped:Connect(function()
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= lp and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							-- Nếu vận tốc của người khác lớn hơn mức bình thường (>250)
							if part.AssemblyLinearVelocity.Magnitude > 250 or part.AssemblyAngularVelocity.Magnitude > 250 then
								-- Ép vận tốc của họ về 0 ở máy của bạn
								part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
								part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
							end
						end
					end
				end
			end
		end)
	else
		-- Tắt Anti-Fling
		if antiFlingConnection then
			antiFlingConnection:Disconnect()
			antiFlingConnection = nil
		end
	end
end)
