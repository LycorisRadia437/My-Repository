--// Exploit Fix & Mobile Compatibility \\--
local ProtectGUI = function(gui)
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

--// Services \\--
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Variables \\--
local Player = Players.LocalPlayer
local RemoteWeapon = ReplicatedStorage:WaitForChild("Remote", 5)
local Event = RemoteWeapon and RemoteWeapon:WaitForChild("Weapon", 5) and RemoteWeapon.Weapon:WaitForChild("Use", 5)

--// UI & ESP Library \-- 
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))() 
local Library = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/Just-Egg-Salad/roblox-scripts/main/uwuware'))()

--// ESP Settings \\--
if ESP then
    ESP.TeamMates = false
    ESP:Toggle(false)
end

--// UI \\--
local Window = Library:CreateWindow("Smacker Mobile - Fixed Click")
Window:AddToggle({
    text = "Enabled"
})
Window:AddToggle({
    text = "Player ESP",
    callback = function(state)
        if ESP then ESP:Toggle(state) end
    end
})
Window:AddButton({
    text = "Reset",
    callback = function()
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        if Humanoid then
            Humanoid.Health = 0
        end
    end
})

local Folder = Window:AddFolder("Transformations")

-- Khối xử lý giả lập Touch Interest an toàn
local function safeTouch(part1, part2)
    if firetouchinterest then
        firetouchinterest(part1, part2, 0)
        task.wait()
        firetouchinterest(part1, part2, 1)
    end
end

if firetouchinterest then
    local Found = {}
    local Scripted = Workspace:WaitForChild("Scripted", 5)
    local TransformBrick = Scripted and Scripted:WaitForChild("TransformBrick", 5)
    
    if TransformBrick then
        for _, A_1 in next, TransformBrick:GetChildren() do
            local Touch = A_1:FindFirstChild("TouchInterest", true)
            if Touch and A_1:FindFirstChild("Type") and table.find(Found, A_1.Type.Value) == nil then
                table.insert(Found, A_1.Type.Value)
                local TouchParent = Touch.Parent
                Folder:AddButton({
                    text = A_1.Type.Value,
                    callback = function()
                        local Primary = Player.Character and Player.Character.PrimaryPart
                        if Primary and TouchParent then
                            safeTouch(Primary, TouchParent)
                        end
                    end
                })
            end
        end
        
        if TransformBrick:FindFirstChild("Shade") then
            Folder:AddButton({
                text = "Shade",
                callback = function()
                    local Primary = Player.Character and Player.Character.PrimaryPart
                    local ShadeBrick = TransformBrick.Shade:FindFirstChild("TouchInterest", true)
                    if Primary and ShadeBrick then
                        safeTouch(Primary, ShadeBrick.Parent)
                    end
                end
            })
        end
    end
end

local ToxicRabbit = ReplicatedStorage:FindFirstChild("ToxicPuddleTransformed")
if ToxicRabbit then
    Folder:AddButton({
        text = "Toxic Rabbit",
        callback = function()
            for i = 1, 6 do
                ToxicRabbit:FireServer()
            end
        end
    })
end

-- Khởi tạo Menu gốc trước khi bọc sửa lỗi click
Library:Init()

--// 🛠️ ĐOẠN CODE FIX LỖI CLICK CHO MOBILE (CRITICAL FIX) 🛠️ \\--
local uiContainer = game:GetService("CoreGui"):FindFirstChild("uwuware") or game:GetService("CoreGui"):FindFirstChildOfClass("ScreenGui")
if uiContainer then
    ProtectGUI(uiContainer)
    
    -- Duyệt qua toàn bộ các nút bấm và tùy chọn của Menu để ép nhận Touch Input
    local function FixMobileInputs(instance)
        if instance:IsA("TextButton") or instance:IsA("ImageButton") then
            instance.Active = true
            -- Giả lập click chuột khi người chơi chạm màn hình điện thoại
            instance.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch and instance.Visible then
                    -- Kích hoạt sự kiện bấm nút gốc của thư viện
                    if instance.MouseButton1Click then
                        for _, connection in pairs(getconnections(instance.MouseButton1Click)) do
                            connection:Fire()
                        end
                    end
                end
            end)
        end
    end
    
    for _, obj in pairs(uiContainer:GetDescendants()) do
        FixMobileInputs(obj)
    end
    uiContainer.DescendantAdded:Connect(FixMobileInputs)
end

--// 📱 TẠO NÚT NỔI ĐỂ ẨN/HIỆN MENU CẢM ỨNG \\--
local MobileGui = Instance.new("ScreenGui")
local TouchButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

MobileGui.Name = "MobileTouchMenu"
ProtectGUI(MobileGui)

TouchButton.Name = "TouchButton"
TouchButton.Parent = MobileGui
TouchButton.Position = UDim2.new(0.1, 0, 0.25, 0)
TouchButton.Size = UDim2.new(0, 65, 0, 65)
TouchButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TouchButton.BackgroundTransparency = 0.2
TouchButton.Text = "ẨN/HIỆN"
TouchButton.TextColor3 = Color3.fromRGB(0, 255, 150) -- Đổi màu chữ sang xanh neon cho dễ nhìn
TouchButton.TextSize = 13
TouchButton.Font = Enum.Font.SourceSansBold
TouchButton.Active = true

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = TouchButton

local menuVisible = true
TouchButton.MouseButton1Click:Connect(function()
    if uiContainer then
        menuVisible = not menuVisible
        uiContainer.Enabled = menuVisible
    end
end)

-- Code xử lý kéo rê (Drag) nút nổi mượt mà trên Mobile
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(TouchButton, TweenInfo.new(0.08), {Position = targetPos}):Play()
end

TouchButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = TouchButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TouchButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)


--// Get Weapon \\--
function GetWeapon()
    if not Player.Character or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then
        return false
    end
    local Char = Player.Character
    local Tool = Char:FindFirstChildOfClass("Tool")
    if Tool and Tool:FindFirstChild("Handle") then
        return Tool
    end
    return false
end

--// Get Closest Enemy Player \\--
function GetEnemy()
    local Enemy = false
    local Range = 5.8
    for _, A_1 in next, Players:GetPlayers() do
        local Char = A_1.Character
        if A_1 ~= Player and A_1.Team ~= Player.Team and Char and Char:FindFirstChild("HumanoidRootPart") and Char:FindFirstChild("Humanoid") and Char.Humanoid.Health > 0 and Char:FindFirstChild("ForceField") == nil then
            local Distance = Player:DistanceFromCharacter(Char.HumanoidRootPart.Position)
            if Distance < Range then
                Range = Distance
                Enemy = Char.HumanoidRootPart
            end
        end
    end
    return Enemy
end

--// Smacker Loop \\--
task.spawn(function()
    while true do
        task.wait(0.1)
        if Library.flags and Library.flags.Enabled then
            local Weapons = GetWeapon()
            local Enemy = GetEnemy()
            if Weapons ~= false and Enemy ~= false and Event then
                for i = 1, 5 do
                    Event:FireServer(Enemy)
                end
                task.wait(1.1)
            end
        end
    end
end)
