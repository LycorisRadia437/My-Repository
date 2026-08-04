--// Thư dịch vụ hệ thống Roblox \\--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// Biến cấu hình & Trạng thái hoạt động \\--
local Player = Players.LocalPlayer
local AttackEnabled = false 
local AttackRange = 8.0     -- Tầm đánh tối ưu mặc định ban đầu
local MinRange = 4.0        -- Tầm đánh tối thiểu (Cận chiến thực tế)
local MaxRange = 25.0       -- Tầm đánh tối đa khuyến nghị để tránh bị dòm ngó

--// Hàm ẩn giao diện (GUI) an toàn chống bị xóa trên Mobile \\--
local function ProtectGUI(gui)
    if gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
end

--// Hàm kiểm tra và lấy Vũ khí / Kỹ năng đang cầm trên tay \\--
local function GetCurrentWeapon()
    local Char = Player.Character
    if not Char or not Char:FindFirstChild("Humanoid") or Char.Humanoid.Health <= 0 then
        return nil
    end
    -- Lấy công cụ (Tool) đang được chọn hoặc kích hoạt trên tay nhân vật
    local Tool = Char:FindFirstChildOfClass("Tool")
    if Tool then
        return Tool
    end
    return nil
end

--// Hàm quét tìm mục tiêu khác phe (Check Team Người / Gnar - Kaiju) \\--
local function GetClosestEnemy()
    local Enemy = nil
    local ClosestDistance = AttackRange
    local MyChar = Player.Character
    if not MyChar or not MyChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, targetPlayer in next, Players:GetPlayers() do
        local TargetChar = targetPlayer.Character
        -- ĐIỀU KIỆN: Không phải bản thân + Khác phe + Nhân vật hợp lệ + Còn sống + Không có khiên bảo vệ
        if targetPlayer ~= Player and targetPlayer.Team ~= Player.Team and TargetChar then
            local TargetHRP = TargetChar:FindFirstChild("HumanoidRootPart")
            local TargetHumanoid = TargetChar:FindFirstChildOfClass("Humanoid")
            
            if TargetHRP and TargetHumanoid and TargetHumanoid.Health > 0 and TargetChar:FindFirstChild("ForceField") == nil then
                local Distance = (MyChar.HumanoidRootPart.Position - TargetHRP.Position).Magnitude
                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    Enemy = TargetHRP
                end
            end
        end
    end
    return Enemy
end

--// ⚔️ VÒNG LẶP TỰ ĐỘNG KHÓA VÀ TẤN CÔNG ⚔️ \\--
task.spawn(function()
    while true do
        task.wait(0.05) -- Tần suất quét nhanh nhằm đảm bảo tốc độ phản xạ cao trên Mobile
        
        if AttackEnabled then
            local Tool = GetCurrentWeapon()
            local EnemyHRP = GetClosestEnemy()
            local MyChar = Player.Character
            
            -- Thực hiện tấn công khi có đủ điều kiện: Cầm vũ khí + Địch trong tầm ngắm
            if Tool and EnemyHRP and MyChar and MyChar:FindFirstChild("HumanoidRootPart") then
                -- Quay mặt nhân vật thẳng về phía đối thủ để đòn đánh chuẩn hướng hoạt ảnh
                local TargetPosition = Vector3.new(EnemyHRP.Position.X, MyChar.HumanoidRootPart.Position.Y, EnemyHRP.Position.Z)
                MyChar.HumanoidRootPart.CFrame = CFrame.lookAt(MyChar.HumanoidRootPart.Position, TargetPosition)
                
                -- Kích hoạt đòn đánh vật lý của vũ khí/kỹ năng cận chiến
                Tool:Activate()
                
                -- Khớp thời gian hồi nhỏ để không bị gián đoạn hoạt ảnh (Animation) đòn đánh
                task.wait(0.12) 
            end
        end
    end
end)

--// 📱 KHỞI TẠO BẢNG ĐIỀU KHIỂN MINI (MINI PANEL GUI) \\--
local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "KaijuParadiseV2"
ProtectGUI(MobileGui)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MobileGui
MainFrame.Position = UDim2.new(0.15, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 170, 0, 145)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Tiêu đề Menu
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KAIJU PARADISE ATK"
TitleLabel.TextColor3 = Color3.fromRGB(255, 64, 129) -- Màu hồng neon đặc trưng
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.SourceSansBold

-- Nút Bật / Tắt Auto Attack
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.Position = UDim2.new(0.05, 0, 0.24, 0)
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 20, 40) -- Đỏ (Tắt)
ToggleButton.Text = "AUTO ATTACK: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.SourceSansBold

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    AttackEnabled = not AttackEnabled
    if AttackEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 160, 80) -- Xanh (Bật)
        ToggleButton.Text = "AUTO ATTACK: ON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 20, 40)
        ToggleButton.Text = "AUTO ATTACK: OFF"
    end
end)

-- Nhãn hiển thị Tầm Đánh (Range)
local RangeLabel = Instance.new("TextLabel")
RangeLabel.Name = "RangeLabel"
RangeLabel.Parent = MainFrame
RangeLabel.Position = UDim2.new(0.05, 0, 0.56, 0)
RangeLabel.Size = UDim2.new(0.9, 0, 0, 20)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "RANGE: " .. string.format("%.1f", AttackRange) .. " studs"
RangeLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
RangeLabel.TextSize = 12
RangeLabel.Font = Enum.Font.SourceSansBold
RangeLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Thanh trượt chỉnh tầm đánh (Slider Bar)
local SliderBackground = Instance.new("Frame")
SliderBackground.Name = "SliderBackground"
SliderBackground.Parent = MainFrame
SliderBackground.Position = UDim2.new(0.05, 0, 0.74, 0)
SliderBackground.Size = UDim2.new(0.9, 0, 0, 10)
SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 65)

local SliderBgCorner = Instance.new("UICorner")
SliderBgCorner.CornerRadius = UDim.new(1, 0)
SliderBgCorner.Parent = SliderBackground

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Parent = SliderBackground
SliderFill.Size = UDim2.new((AttackRange - MinRange) / (MaxRange - MinRange), 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)

local SliderFillCorner = Instance.new("UICorner")
SliderFillCorner.CornerRadius = UDim.new(1, 0)
SliderFillCorner.Parent = SliderFill

local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.Parent = SliderBackground
SliderButton.Position = UDim2.new((AttackRange - MinRange) / (MaxRange - MinRange), -6, 0.5, -6)
SliderButton.Size = UDim2.new(0, 12, 0, 12)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.Text = ""

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderButton

--// XỬ LÝ VUỐT TRƯỢT SLIDER TRÊN ĐIỆN THOẠI \\--
local isSliding = false

local function UpdateSlider(input)
    local absolutePosition = SliderBackground.AbsolutePosition
    local absoluteSize = SliderBackground.AbsoluteSize
    local percentage = math.clamp((input.Position.X - absolutePosition.X) / absoluteSize.X, 0, 1)
    
    AttackRange = MinRange + (percentage * (MaxRange - MinRange))
    
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderButton.Position = UDim2.new(percentage, -6, 0.5, -6)
    RangeLabel.Text = "RANGE: " .. string.format("%.1f", AttackRange) .. " studs"
end

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UpdateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isSliding = false
    end
end)

SliderBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        UpdateSlider(input)
        isSliding = true
    end
end)

--// KÉO RÊ DI CHUYỂN BẢNG MENU TRÊN MÀN HÌNH DI ĐỘNG \\--
local dragging, dragInput, dragStart, startPos
local function updateMainFrame(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.08), {Position = targetPos}):Play()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
