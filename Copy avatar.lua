-- ==========================================
-- AVATAR COPIER + MANUAL COLOR TINTING FIX
-- ==========================================
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 1. TẠO GIAO DIỆN & XÓA BẢN CŨ
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
MainFrame.Position = UDim2.new(0.5, -130, 0.35, -95)
MainFrame.Size = UDim2.new(0, 260, 0, 210)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -30, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "AVATAR COPIER + FIX MÀU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

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
UsernameInput.Position = UDim2.new(0.08, 0, 0.22, 0)
UsernameInput.Size = UDim2.new(0.84, 0, 0, 35)
UsernameInput.Font = Enum.Font.SourceSans
UsernameInput.PlaceholderText = "Nhập tên hoặc ID..."
UsernameInput.Text = ""
UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
UsernameInput.TextSize = 15
UsernameInput.ClearTextOnFocus = false
Instance.new("UICorner", UsernameInput).CornerRadius = UDim.new(0, 8)

-- Ô NHẬP MÃ MÀU THỦ CÔNG (HEX HOẶC CHỌN NHANH)
local ColorInput = Instance.new("TextBox", MainFrame)
ColorInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ColorInput.Position = UDim2.new(0.08, 0, 0.42, 0)
ColorInput.Size = UDim2.new(0.84, 0, 0, 32)
ColorInput.Font = Enum.Font.SourceSans
ColorInput.PlaceholderText = "Mã màu RGB (VD: 255,220,195)"
ColorInput.Text = ""
ColorInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorInput.TextSize = 13
ColorInput.ClearTextOnFocus = false
Instance.new("UICorner", ColorInput).CornerRadius = UDim.new(0, 8)

local CopyButton = Instance.new("TextButton", MainFrame)
CopyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
CopyButton.Position = UDim2.new(0.08, 0, 0.65, 0)
CopyButton.Size = UDim2.new(0.84, 0, 0, 40)
CopyButton.Font = Enum.Font.SourceSansBold
CopyButton.Text = "SAO CHÉP TOÀN BỘ"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 15
Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 8)

-- NÚT NHUỘM MÀU NHANH NẾU ĐẦU BỊ TRẮNG
local TintButton = Instance.new("TextButton", MainFrame)
TintButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
TintButton.Position = UDim2.new(0.08, 0, 0.84, 0)
TintButton.Size = UDim2.new(0.84, 0, 0, 26)
TintButton.Font = Enum.Font.SourceSansBold
TintButton.Text = "ÁP DỤNG MÀU THỦ CÔNG"
TintButton.TextColor3 = Color3.fromRGB(200, 200, 200)
TintButton.TextSize = 12
Instance.new("UICorner", TintButton).CornerRadius = UDim.new(0, 6)

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

-- HÀM HÃN PHỤ KIỆN
local function ForceWeldAccessory(char, accessory)
    local handle = accessory:FindFirstChild("Handle")
    if not handle then return end
    local att = handle:FindFirstChildOfClass("Attachment")
    if not att then return end

    local targetPart, charAtt
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local foundAtt = part:FindFirstChild(att.Name)
            if foundAtt then targetPart = part; charAtt = foundAtt; break end
        end
    end

    if targetPart and charAtt then
        handle.Anchored = true
        accessory.Parent = char
        handle.CFrame = targetPart.CFrame * charAtt.CFrame * att.CFrame:Inverse()
        local weld = Instance.new("Weld", handle)
        weld.Name = "DeltaFixWeld"
        weld.Part0 = targetPart
        weld.Part1 = handle
        weld.C0 = charAtt.CFrame
        weld.C1 = att.CFrame
        handle.Anchored = false
    else
        char.Humanoid:AddAccessory(accessory)
    end
end

-- HÀM COPY CHÍNH
local function ForceCopyAvatar(targetUserId)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false, "Lỗi Nhân Vật" end

    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end

    local success, targetModel = pcall(function()
        return Players:CreateHumanoidModelFromUserId(targetUserId)
    end)
    if not success or not targetModel then return false, "Không tải được Dữ liệu" end

    local targetColors = targetModel:FindFirstChildOfClass("BodyColors")
    if targetColors then
        targetColors:Clone().Parent = char
    else
        local myBodyColors = Instance.new("BodyColors", char)
        myBodyColors.HeadColor3 = Color3.fromRGB(255, 220, 177)
    end

    local myHead = char:FindFirstChild("Head")
    local targetHead = targetModel:FindFirstChild("Head")
    
    if myHead and targetHead then
        myHead.Transparency = 1
        for _, v in ipairs(myHead:GetChildren()) do
            if v:IsA("Decal") or v:IsA("SurfaceAppearance") or v:IsA("FaceControls") or v:IsA("SpecialMesh") then
                v:Destroy()
            end
        end
        
        local oldFakeHead = char:FindFirstChild("FakeHeadAvatarCopier")
        if oldFakeHead then oldFakeHead:Destroy() end
        
        local fakeHead = targetHead:Clone()
        fakeHead.Name = "FakeHeadAvatarCopier"
        fakeHead.CanCollide = false
        fakeHead.Massless = true
        
        for _, v in ipairs(fakeHead:GetChildren()) do
            if v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            end
        end

        if targetHead:IsA("MeshPart") then
            fakeHead.MeshId = targetHead.MeshId
            fakeHead.TextureID = targetHead.TextureID
            fakeHead.Size = targetHead.Size
        end

        -- Xóa SurfaceAppearance lỗi để tránh bị ám màu xám trắng
        local targetSA = targetHead:FindFirstChildOfClass("SurfaceAppearance")
        if targetSA then targetSA:Destroy() end

        fakeHead.Parent = char
        fakeHead.CFrame = myHead.CFrame

        local headWeld = Instance.new("Weld", fakeHead)
        headWeld.Name = "FakeHeadWeld"
        headWeld.Part0 = myHead
        headWeld.Part1 = fakeHead
        headWeld.C0 = CFrame.new(0, 0, 0)
        headWeld.C1 = CFrame.new(0, 0, 0)
        
        for _, att in ipairs(targetHead:GetChildren()) do
            if att:IsA("Attachment") then
                local myAtt = myHead:FindFirstChild(att.Name)
                if myAtt then myAtt.CFrame = att.CFrame
                else att:Clone().Parent = myHead end
            end
        end
    end

    for _, item in ipairs(targetModel:GetChildren()) do
        if item:IsA("Accessory") then
            ForceWeldAccessory(char, item:Clone())
        elseif item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("CharacterMesh") then
            item:Clone().Parent = char
        end
    end

    targetModel:Destroy()
    return true, "Thành công!"
end

-- XỬ LÝ NÚT COPY
CopyButton.Activated:Connect(function()
    local targetName = UsernameInput.Text
    if targetName == "" or targetName:match("^%s*$") then return end
    CopyButton.Text = "Đang tải dữ liệu..."
    
    local targetUserId = tonumber(targetName)
    if not targetUserId then
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer then targetUserId = targetPlayer.UserId
        else
            local succ, res = pcall(function() return Players:GetUserIdFromNameAsync(targetName) end)
            if succ then targetUserId = res end
        end
    end
    
    if targetUserId then
        local success, msg = ForceCopyAvatar(targetUserId)
        if success then
            CopyButton.Text = "THÀNH CÔNG!"
        else
            CopyButton.Text = msg
        end
    else
        CopyButton.Text = "Sai Tên / ID!"
    end
    
    task.wait(2)
    CopyButton.Text = "SAO CHÉP TOÀN BỘ"
end)

-- XỬ LÝ NÚT NHUỘM MÀU THỦ CÔNG
-- Thay thế đoạn code trong hàm TintButton.Activated bằng đoạn này:
TintButton.Activated:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local fakeHead = char:FindFirstChild("FakeHeadAvatarCopier")
    if not fakeHead then return end

    -- Xóa triệt để các lớp texture/PBR gây cản trở đổi màu
    for _, v in ipairs(fakeHead:GetChildren()) do
        if v:IsA("SurfaceAppearance") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    fakeHead.TextureID = "" -- Xóa texture gốc bị lỗi màu

    local rgbText = ColorInput.Text
    local r, g, b = rgbText:match("^(%d+),%s*(%d+),%s*(%d+)$")
    if r and g and b then
        fakeHead.Color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
        TintButton.Text = "ĐÃ ĐỔI MÀU THÀNH CÔNG!"
    else
        fakeHead.Color = Color3.fromRGB(255, 219, 172)
        TintButton.Text = "ĐÃ DÙNG MÀU MẶC ĐỊNH!"
    end
    task.wait(2)
    TintButton.Text = "ÁP DỤNG MÀU THỦ CÔNG"
end)


CloseButton.Activated:Connect(function() ScreenGui:Destroy() end)
