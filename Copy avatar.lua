-- ==========================================
-- AVATAR COPIER (DELTA FIX + DYNAMIC HEAD SUPPORT)
-- ==========================================
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. TẠO GIAO DIỆN (TỰ ĐỘNG XÓA BẢN CŨ)
local coreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
for _, ui in ipairs(coreGui:GetChildren()) do
    if ui.Name == "MobileAvatarCopier" then ui:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAvatarCopier"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = coreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -130, 0.35, -80)
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -30, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "AVATAR COPIER (DYNAMIC HEAD)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15

local CloseButton = Instance.new("TextButton", MainFrame)
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextSize = 18

local UsernameInput = Instance.new("TextBox", MainFrame)
UsernameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
UsernameInput.Position = UDim2.new(0.08, 0, 0.32, 0)
UsernameInput.Size = UDim2.new(0.84, 0, 0, 38)
UsernameInput.Font = Enum.Font.SourceSans
UsernameInput.PlaceholderText = "Nhập tên hoặc ID..."
UsernameInput.Text = ""
UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameInput.TextSize = 16
UsernameInput.ClearTextOnFocus = false
Instance.new("UICorner", UsernameInput).CornerRadius = UDim.new(0, 8)

local CopyButton = Instance.new("TextButton", MainFrame)
CopyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
CopyButton.Position = UDim2.new(0.08, 0, 0.65, 0)
CopyButton.Size = UDim2.new(0.84, 0, 0, 42)
CopyButton.Font = Enum.Font.SourceSansBold
CopyButton.Text = "SAO CHÉP TOÀN BỘ"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 16
Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 8)

-- DI CHUYỂN UI MƯỢT MÀ
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ==========================================
-- HỆ THỐNG HÀN PHỤ KIỆN TỰ ĐỘNG CHO DELTA
-- ==========================================
local function ForceWeldAccessory(char, accessory)
    local handle = accessory:FindFirstChild("Handle")
    if not handle then return end

    local att = handle:FindFirstChildOfClass("Attachment")
    if not att then return end

    local targetPart, charAtt
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local foundAtt = part:FindFirstChild(att.Name)
            if foundAtt then
                targetPart = part
                charAtt = foundAtt
                break
            end
        end
    end

    if targetPart and charAtt then
        handle.Anchored = true
        accessory.Parent = char
        handle.CFrame = targetPart.CFrame * charAtt.CFrame * att.CFrame:Inverse()
        
        local weld = Instance.new("Weld")
        weld.Name = "DeltaFixWeld"
        weld.Part0 = targetPart
        weld.Part1 = handle
        weld.C0 = charAtt.CFrame
        weld.C1 = att.CFrame
        weld.Parent = handle
        
        handle.Anchored = false
    else
        char.Humanoid:AddAccessory(accessory)
    end
end

-- ==========================================
-- HÀM COPY AVATAR VÀ DYNAMIC HEAD CHÍNH
-- ==========================================
local function ForceCopyAvatar(targetUserId)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false, "Lỗi Nhân Vật" end

    -- 1. XÓA ĐỒ CŨ
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end

    -- 2. TẢI BẢN SAO 
    local success, targetModel = pcall(function()
        return Players:CreateHumanoidModelFromUserId(targetUserId)
    end)
    if not success or not targetModel then return false, "Không tải được Dữ liệu" end

    -- 3. CHÉP PHỤ KIỆN VÀ QUẦN ÁO
    for _, item in ipairs(targetModel:GetChildren()) do
        if item:IsA("Accessory") then
            ForceWeldAccessory(char, item:Clone())
        elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("BodyColors") or item:IsA("CharacterMesh") then
            for _, old in ipairs(char:GetChildren()) do
                if old.ClassName == item.ClassName then old:Destroy() end
            end
            item:Clone().Parent = char
        end
    end

    -- 4. XỬ LÝ KHUÔN MẶT (DYNAMIC HEAD & CLASSIC HEAD)
    local myHead = char:FindFirstChild("Head")
    local targetHead = targetModel:FindFirstChild("Head")
    
    if myHead and targetHead then
        -- Dọn dẹp Decal, SurfaceAppearance, FaceControls, SpecialMesh cũ của mình
        for _, v in ipairs(myHead:GetChildren()) do
            if v:IsA("Decal") or v:IsA("SurfaceAppearance") or v:IsA("FaceControls") or v:IsA("SpecialMesh") then
                v:Destroy()
            end
        end
        
        -- Nếu cả 2 đều là MeshPart (R15 Dynamic) -> Copy thẳng chỉ số khung lưới
        if myHead:IsA("MeshPart") and targetHead:IsA("MeshPart") then
            myHead.MeshId = targetHead.MeshId
            myHead.TextureID = targetHead.TextureID
            myHead.Color = targetHead.Color
            myHead.Size = targetHead.Size
        end
        
        -- Xử lý Classic Head (R6 hoặc đầu hộp)
        local targetSpecialMesh = targetHead:FindFirstChildOfClass("SpecialMesh")
        if targetSpecialMesh then
            targetSpecialMesh:Clone().Parent = myHead
        elseif targetHead:IsA("MeshPart") and not myHead:IsA("MeshPart") then
            -- Nếu Target dùng Dynamic Head nhưng mình dùng Classic Head (Giả lập)
            local fakeMesh = Instance.new("SpecialMesh")
            fakeMesh.MeshId = targetHead.MeshId
            fakeMesh.TextureId = targetHead.TextureID
            fakeMesh.Scale = Vector3.new(1, 1, 1)
            fakeMesh.Parent = myHead
        end

        -- Chép PBR Texture (SurfaceAppearance) cho Dynamic Head
        local targetSA = targetHead:FindFirstChildOfClass("SurfaceAppearance")
        if targetSA then targetSA:Clone().Parent = myHead end

        -- Chép Chuyển động mặt (FaceControls) cho Dynamic Head
        local targetFC = targetHead:FindFirstChildOfClass("FaceControls")
        if targetFC then targetFC:Clone().Parent = myHead end

        -- Chép Khuôn mặt 2D (Decal) nếu có
        local faceFound = false
        for _, v in ipairs(targetHead:GetChildren()) do
            if v:IsA("Decal") then
                v:Clone().Parent = myHead
                faceFound = true
            end
        end
        
        -- Cấp mặt cười cơ bản nếu người kia không có cả 2D lẫn Dynamic
        if not faceFound and not targetSA and not targetFC then
            local df = Instance.new("Decal")
            df.Name = "face"
            df.Texture = "rbxasset://textures/face.png"
            df.Parent = myHead
        end
    end

    targetModel:Destroy()
    return true, "Thành công!"
end

-- ==========================================
-- XỬ LÝ NÚT BẤM
-- ==========================================
CopyButton.Activated:Connect(function()
    local targetName = UsernameInput.Text
    if targetName == "" or targetName:match("^%s*$") then return end
    
    CopyButton.Text = "Đang tải dữ liệu..."
    CopyButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    
    local targetUserId = nil
    if tonumber(targetName) then
        targetUserId = tonumber(targetName)
    else
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer then
            targetUserId = targetPlayer.UserId
        else
            local succ, res = pcall(function() return Players:GetUserIdFromNameAsync(targetName) end)
            if succ then targetUserId = res end
        end
    end
    
    if targetUserId then
        local success, msg = ForceCopyAvatar(targetUserId)
        if success then
            CopyButton.Text = "THÀNH CÔNG!"
            CopyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            CopyButton.Text = msg
            CopyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        end
    else
        CopyButton.Text = "Sai Tên / ID!"
        CopyButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    end
    
    task.wait(2)
    CopyButton.Text = "SAO CHÉP TOÀN BỘ"
    CopyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
end)

CloseButton.Activated:Connect(function() ScreenGui:Destroy() end)
