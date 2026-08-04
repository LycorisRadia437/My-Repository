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

--// Variables \\--
local Player = Players.LocalPlayer
local RemoteWeapon = ReplicatedStorage:WaitForChild("Remote", 5)
local Event = RemoteWeapon and RemoteWeapon:WaitForChild("Weapon", 5) and RemoteWeapon.Weapon:WaitForChild("Use", 5)

--// UI & ESP Library \\--
local ESP = loadstring(game:HttpGet("https://kiriot22.com"))()
local Library = loadstring(game:HttpGetAsync('https://githubusercontent.com'))()

--// ESP Settings \\--
if ESP then
    ESP.TeamMates = false
    ESP:Toggle(false)
end

--// UI \\--
local Window = Library:CreateWindow("Smacker Mobile - Fixed")
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

-- Kiểm tra và bọc hàm firetouchinterest phòng lỗi trên Mobile
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

-- Khởi tạo UI và tự động đưa vào phân vùng ẩn an toàn trên Mobile
local uiContainer = game:GetService("CoreGui"):FindFirstChild("uwuware") or game:GetService("CoreGui"):FindFirstChildOfClass("ScreenGui")
if uiContainer then
    ProtectGUI(uiContainer)
end
Library:Init()

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
-- Sử dụng task.spawn để vòng lặp chạy nền mượt mà không gây đơ máy Mobile
task.spawn(function()
    while true do
        task.wait(0.1) -- Giới hạn tần suất quét nhẹ để tránh quá tải CPU Mobile
        
        if Library.flags and Library.flags.Enabled then
            local Weapons = GetWeapon()
            local Enemy = GetEnemy()
            
            if Weapons ~= false and Enemy ~= false and Event then
                print("Target:", Enemy.Parent.Name, "Distance:", Player:DistanceFromCharacter(Enemy.Position))
                for i = 1, 5 do
                    Event:FireServer(Enemy)
                end
                task.wait(1.1)
            end
        end
    end
end)
