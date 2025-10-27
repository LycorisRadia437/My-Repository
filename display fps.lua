-- ⚡ FPS Counter - bản thu nhỏ gọn gàng
-- Đặt trong StarterPlayerScripts

local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSDisplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(0, 70, 0, 22) -- nhỏ hơn
fpsLabel.Position = UDim2.new(0, 8, 0, 8)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextSize = 14 -- chữ nhỏ hơn
fpsLabel.Text = "FPS: 0"
fpsLabel.Parent = screenGui
fpsLabel.BorderSizePixel = 0
fpsLabel.TextStrokeTransparency = 0.7
fpsLabel.ZIndex = 10

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = fpsLabel

local frames = 0
local fps = 0
local runService = game:GetService("RunService")

task.spawn(function()
	while true do
		fps = frames
		fpsLabel.Text = "FPS: " .. fps
		if fps >= 50 then
			fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Xanh (mượt)
		elseif fps >= 30 then
			fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Vàng (trung bình)
		else
			fpsLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Đỏ (lag)
		end
		frames = 0
		task.wait(1)
	end
end)

runService.RenderStepped:Connect(function()
	frames += 1
end)