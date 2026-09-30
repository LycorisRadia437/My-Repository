local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Kiểm tra và xác định các đường dẫn chính xác từ Dex của bạn
local ScriptedFolder = Workspace:FindFirstChild("Scripted")
local InteractableFolder = ScriptedFolder and ScriptedFolder:FindFirstChild("Interactable")
local OtherFolder = ScriptedFolder and ScriptedFolder:FindFirstChild("Other")

if not ScriptedFolder then
    warn("Không tìm thấy thư mục gốc: workspace.Scripted")
    return
end

-- Trạng thái Bật/Tắt ESP (Mặc định là BẬT khi chạy script)
local ESP_Enabled = true

-- Cấu hình mục tiêu quét và màu sắc riêng biệt
local Targets = {
    ["Long Pipe"] = { Color = Color3.fromRGB(255, 50, 50), Tag = "LongPipeESP" },  -- Màu đỏ rực
    ["HazmatSuit"] = { Color = Color3.fromRGB(255, 255, 0), Tag = "HazmatSuitESP" } -- Màu vàng chanh
}

-- Hàm tạo ESP nhãn tên cho vật phẩm hợp lệ
local function CreateItemESP(item, config)
    if item:FindFirstChild(config.Tag) then return end
    
    local primaryPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
    if not primaryPart then return end

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = config.Tag
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 120, 0, 20)
    Billboard.Adornee = primaryPart
    Billboard.Enabled = ESP_Enabled -- Tuân theo trạng thái nút bật/tắt
    Billboard.Parent = item

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = config.Color
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.Text = item.Name
    TextLabel.Parent = Billboard
end

-- Hàm kiểm tra và xử lý đối tượng cụ thể
local function CheckAndApply(object)
    local config = Targets[object.Name]
    if config then
        task.spawn(function()
            CreateItemESP(object, config)
        end)
    end
end

-- Hàm quét cực sâu đệ quy
local function DeepScan(object)
    CheckAndApply(object)
    for _, child in ipairs(object:GetChildren()) do
        DeepScan(child)
    end
end

-- Khởi chạy quét ban đầu cho cả 2 thư mục nếu chúng tồn tại
if InteractableFolder then DeepScan(InteractableFolder) end
if OtherFolder then DeepScan(OtherFolder) end

-- Tự động nạp thời gian thực khi server sinh ra (Respawn) vật phẩm mới
if InteractableFolder then
    InteractableFolder.DescendantAdded:Connect(function(descendant)
        task.wait(0.1)
        CheckAndApply(descendant)
    end)
end

if OtherFolder then
    OtherFolder.DescendantAdded:Connect(function(descendant)
        task.wait(0.1)
        CheckAndApply(descendant)
    end)
end

-- ========================================================
-- TẠO GIAO DIỆN NÚT BẬT / TẮT (TOGGLE GUI) TRÊN MÀN HÌNH
-- ========================================================

-- Xóa giao diện cũ nếu bạn chạy lại script tránh bị đè nút
local TargetGui = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
if TargetGui:FindFirstChild("KP_ToggleItemESP") then
    TargetGui.KP_ToggleItemESP:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KP_ToggleItemESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 110, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0) -- Nằm ở góc trên bên trái màn hình
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderSizePixel = 2
ToggleButton.BorderColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 100) -- Chữ xanh lá lúc đang bật
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "ESP ITEMS: ON"
ToggleButton.Parent = ScreenGui

-- Giúp nút có thể kéo thả di chuyển vị trí trên màn hình điện thoại/PC
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Xử lý sự kiện khi bấm nút Bật/Tắt
ToggleButton.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    
    if ESP_Enabled then
        ToggleButton.Text = "ESP ITEMS: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        ToggleButton.Text = "ESP ITEMS: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
    
    -- Duyệt qua toàn bộ map để ẩn/hiện các nhãn ESP ngay lập tức
    for _, config in pairs(Targets) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == config.Tag and obj:IsA("BillboardGui") then
                obj.Enabled = ESP_Enabled
            end
        end
    end
end)

print("[Kaiju Paradise] Đã gộp và khởi tạo thành công nút bấm điều khiển ESP!")
