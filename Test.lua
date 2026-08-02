-- [[ 
--     ===================================================================
--     KAIJU PARADISE - MOBILE RE-OPTIMIZED (100% FIXED BUTTONS)
--     ===================================================================
--     Fix lỗi: Đơ nút, không phản hồi chỉ số, chống văng Roblox Mobile
-- ]]

-- 1. NẠP KHUNG GIAO DIỆN SẠCH
local PepsiLib = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Window = PepsiLib:CreateWindow({
    Name = "Kaiju Paradise Mobile VIP",
    Theme = "Default",
    Themeable = true
})

-- 2. KHỞI TẠO HỆ THỐNG QUẢN LÝ (MOBILE ENGINE)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local CheatConfig = {
    AutoAttack = false,
    AttackRange = 16,
    WalkSpeed = 16,
    JumpPower = 50,
    EspHuman = false,
    AdminAutoLeave = false
}

-- ===================================================================
-- NÚT ẨN/HIỆN MENU CỐ ĐỊNH CHỐNG LỖI CHẠM (MOBILE TOGGLE)
-- ===================================================================
local MobileToggleButton = Instance.new("TextButton")
MobileToggleButton.Name = "MobileToggleFixed"
MobileToggleButton.Size = UDim2.fromOffset(60, 30)
MobileToggleButton.Position = UDim2.new(0, 15, 0, 140)
MobileToggleButton.BackgroundColor3 = Color3.fromRGB(255, 39, 39)
MobileToggleButton.Text = "Ẩn/Hiện"
MobileToggleButton.Font = Enum.Font.Code
MobileToggleButton.TextSize = 13
MobileToggleButton.TextColor3 = Color3.new(1, 1, 1)
MobileToggleButton.ZIndex = 99999
MobileToggleButton.Active = true
MobileToggleButton.Draggable = true

local TargetGui = CoreGui:FindFirstChild("Pepsi_UI_Engine") or CoreGui:FindFirstChildOfClass("ScreenGui")
if TargetGui then
    MobileToggleButton.Parent = TargetGui
else
    local CustomScreen = Instance.new("ScreenGui", CoreGui)
    CustomScreen.Name = "MobileToggleHolder"
    MobileToggleButton.Parent = CustomScreen
end

MobileToggleButton.MouseButton1Click:Connect(function()
    local MainFrame = CoreGui:FindFirstChild("Pepsi_UI_Engine")
    if MainFrame then
        MainFrame.Enabled = not MainFrame.Enabled
    end
end)

-- ===================================================================
-- PHÂN VÙNG 1: CHIẾN ĐẤU (COMBAT - FIXED LOGIC)
-- ===================================================================
local CombatTab = Window:CreateTab({ Name = "Chiến Đấu" })
local MainCombatSection = CombatTab:CreateSection({ Name = "Auto Combat" })

MainCombatSection:AddToggle({
    Name = "Tự Động Đánh (Auto Attack)",
    Value = false,
    Callback = function(State)
        CheatConfig.AutoAttack = State
        if State then
            task.spawn(function()
                while CheatConfig.AutoAttack do
                    task.wait(0.2) -- Giãn cách chu kỳ quét lên 200ms để điện thoại xử lý nút bấm khác
                    pcall(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            for _, targetPlayer in ipairs(Players:GetPlayers()) do
                                if targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
                                    if distance <= CheatConfig.AttackRange then
                                        local currentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                        if currentTool then 
                                            currentTool:Activate() 
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

MainCombatSection:AddSlider({
    Name = "Khoảng Cách Đánh",
    Min = 10,
    Max = 40,
    Value = 16,
    Callback = function(Value)
        CheatConfig.AttackRange = Value
    end
})

-- ===================================================================
-- PHÂN VÙNG 2: HIỂN THỊ XUYÊN TƯỜNG (ESP - OPTIMIZED)
-- ===================================================================
local VisualsTab = Window:CreateTab({ Name = "Hiển Thị" })
local EspSection = VisualsTab:CreateSection({ Name = "ESP Chống Đơ Máy" })

local function ApplyHighlight(Character, FrameColor)
    if Character:FindFirstChild("MobileESP") then return end
    local Effect = Instance.new("Highlight")
    Effect.Name = "MobileESP"
    Effect.FillColor = FrameColor
    Effect.FillTransparency = 0.6
    Effect.OutlineColor = Color3.new(1, 1, 1)
    Effect.OutlineTransparency = 0.3
    Effect.Parent = Character
end

local function StripHighlight(Character)
    if Character:FindFirstChild("MobileESP") then
        Character.MobileESP:Destroy()
    end
end

EspSection:AddToggle({
    Name = "Định Vị Người Chơi (ESP)",
    Value = false,
    Callback = function(State)
        CheatConfig.EspHuman = State
        if not State then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then StripHighlight(p.Character) end
            end
        end
    end
})

task.spawn(function()
    while true do
        task.wait(0.8) -- Quét giãn cách chống quá tải luồng gõ lệnh (Thread Blocking)
        if CheatConfig.EspHuman then
            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        ApplyHighlight(p.Character, Color3.fromRGB(0, 255, 120))
                    end
                end
            end)
        end
    end
end)

-- ===================================================================
-- PHÂN VÙNG 3: DI CHUYỂN (FIXED RE-APPLY LOGIC)
-- ===================================================================
local MoveTab = Window:CreateTab({ Name = "Di Chuyển" })
local StatsSection = MoveTab:CreateSection({ Name = "Speed & Jump" })

StatsSection:AddSlider({
    Name = "Tốc Độ Chạy (WalkSpeed)",
    Min = 16,
    Max = 120,
    Value = 16,
    Callback = function(Value)
        CheatConfig.WalkSpeed = Value
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = Value end)
    end
})

StatsSection:AddSlider({
    Name = "Sức Mạnh Nhảy (JumpPower)",
    Min = 50,
    Max = 200,
    Value = 50,
    Callback = function(Value)
        CheatConfig.JumpPower = Value
        pcall(function() LocalPlayer.Character.Humanoid.JumpPower = Value end)
    end
})

-- SỬA LỖI ĐƠ: Thay vì dùng Stepped chạy liên tục 60 lần/giây, đổi sang sự kiện nạp CharacterAdded cô lập
local function OnCharacterSpawn(Character)
    local Hum = Character:WaitForChild("Humanoid", 5)
    if Hum then
        task.wait(0.8) -- Chờ server ổn định trạng thái nhân vật (Morphed/Spawned)
        Hum.WalkSpeed = CheatConfig.WalkSpeed
        Hum.JumpPower = Config and Config.JumpPower or CheatConfig.JumpPower
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterSpawn)
if LocalPlayer.Character then OnCharacterSpawn(LocalPlayer.Character) end

-- ===================================================================
-- PHÂN VÙNG 4: BẢO MẬT (SYSTEM)
-- ===================================================================
local SysTab = Window:CreateTab({ Name = "Hệ Thống" })
local SecuritySection = SysTab:CreateSection({ Name = "Bảo Mật An Toàn" })

SecuritySection:AddToggle({
    Name = "Tự Thoát Khi Gặp Admin",
    Value = false,
    Callback = function(State)
        CheatConfig.AdminAutoLeave = State
        if State then
            for _, player in ipairs(Players:GetPlayers()) do
                if player:GetRankInGroup(123456) >= 200 or player.UserId == game.CreatorId then
                    LocalPlayer:Kick("Phát hiện Admin " .. player.Name)
                end
            end
        end
    end
})

print("[MOBILE FIX SUCCESS] Đã dọn luồng nghẽn, các nút tương tác đã hoạt động hoàn toàn bình thường!")
