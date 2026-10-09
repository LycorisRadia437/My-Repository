local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

----------------------------------------------------------------
-- NOTIFICATION
----------------------------------------------------------------

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "TWR Client ESP",
            Text = msg,
            Duration = 3
        })
    end)
end

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------

local ignoreFolder = workspace:FindFirstChild("Ignore")
local itemsFolder = ignoreFolder and ignoreFolder:FindFirstChild("Items")

local legitLootEnabled = true
local trackedItems = {}

----------------------------------------------------------------
-- CLIENT ESP CONTAINER
----------------------------------------------------------------

local function getClientContainer()
    local playerGui = Player:FindFirstChild("PlayerGui")
    if not playerGui then return nil end

    local container = playerGui:FindFirstChild("TWR_ClientESP_Storage")
    if not container then
        container = Instance.new("Folder")
        container.Name = "TWR_ClientESP_Storage"
        container.Parent = playerGui
    end

    return container
end

----------------------------------------------------------------
-- CLEAR ESP
----------------------------------------------------------------

local function clearAllESP()
    local container = getClientContainer()
    if container then
        container:ClearAllChildren()
    end
    table.clear(trackedItems)
end

----------------------------------------------------------------
-- APPLY ESP
----------------------------------------------------------------

local function applyESP(model)
    if not legitLootEnabled then return end
    if not model or not model:IsA("Model") then return end

    ------------------------------------------------------------
    -- TÌM MODEL CHA CAO NHẤT
    ------------------------------------------------------------
    local topModel = model
    while topModel.Parent
        and topModel.Parent ~= itemsFolder
        and topModel.Parent ~= workspace do
        if topModel.Parent:IsA("Model") then
            topModel = topModel.Parent
        else
            break
        end
    end

    if trackedItems[topModel] then return end

    ------------------------------------------------------------
    -- TÌM PART ĐẠI DIỆN
    ------------------------------------------------------------
    local mainPart = topModel:FindFirstChild("Handle", true)
                  or topModel:FindFirstChildWhichIsA("BasePart", true)

    if not mainPart then return end

    local container = getClientContainer()
    if not container then return end

    trackedItems[topModel] = true
    local itemID = tostring(topModel:GetDebugId())

    ------------------------------------------------------------
    -- CLAP BOMB (BOX NỀN MỜ + KHUNG VIỀN 3D DÀY)
    ------------------------------------------------------------

    if topModel.Name == "Clap Bomb" or topModel:FindFirstChild("ClapBomb", true) then

        local BOX_X = 0.555
        local BOX_Y = 1.945
        local BOX_Z = 0.74
        local targetSize = mainPart.Size + Vector3.new(BOX_X, BOX_Y, BOX_Z)
        local targetOffset = CFrame.new(0, BOX_Y / 4, 0)

        -- 1. Nền mờ bên trong (Cyan, Độ mờ 0.6 để giống Highlight)
        local boxName = "Box_" .. itemID
        local clientBox = container:FindFirstChild(boxName)

        if not clientBox then
            clientBox = Instance.new("BoxHandleAdornment")
            clientBox.Name = boxName
            clientBox.Adornee = mainPart
            clientBox.AlwaysOnTop = true
            clientBox.Size = targetSize
            clientBox.CFrame = targetOffset
            clientBox.Transparency = 0.6
            clientBox.Color3 = Color3.fromRGB(0, 255, 255)
            clientBox.ZIndex = 9
            clientBox.Parent = container
        end

        -- 2. Khung viền 3D dày (Màu trắng y hệt Highlight ESP)
        local outlineName = "Outline_" .. itemID
        local outlineFolder = container:FindFirstChild(outlineName)

        if not outlineFolder then
            outlineFolder = Instance.new("Folder")
            outlineFolder.Name = outlineName
            outlineFolder.Parent = container

            local THICKNESS = 0.06 -- Độ dày của viền (Tăng lên nếu muốn viền dày hơn nữa)
            local sx, sy, sz = targetSize.X / 2, targetSize.Y / 2, targetSize.Z / 2
            
            -- Tọa độ 8 góc của khối vuông
            local corners = {
                Vector3.new(-sx, -sy, -sz), Vector3.new(sx, -sy, -sz), 
                Vector3.new(sx, -sy, sz), Vector3.new(-sx, -sy, sz),
                Vector3.new(-sx, sy, -sz), Vector3.new(sx, sy, -sz), 
                Vector3.new(sx, sy, sz), Vector3.new(-sx, sy, sz)
            }
            
            -- Trục kết nối: {Điểm 1, Điểm 2, Hướng Trục (1=X, 2=Y, 3=Z)}
            local edges = {
                {1,2,1}, {2,3,3}, {3,4,1}, {4,1,3}, -- Viền đáy
                {5,6,1}, {6,7,3}, {7,8,1}, {8,5,3}, -- Viền nắp
                {1,5,2}, {2,6,2}, {3,7,2}, {4,8,2}  -- Viền cột dọc
            }

            for i, edge in ipairs(edges) do
                local p1, p2 = corners[edge[1]], corners[edge[2]]
                local axis = edge[3]
                local length = (p2 - p1).Magnitude
                local midPoint = (p1 + p2) / 2
                
                local line = Instance.new("BoxHandleAdornment")
                line.Name = "L" .. i
                
                -- Tạo thanh vuông vức hoàn hảo cho các cạnh nối
                local sizeX, sizeY, sizeZ = THICKNESS, THICKNESS, THICKNESS
                if axis == 1 then sizeX = length + THICKNESS
                elseif axis == 2 then sizeY = length + THICKNESS
                elseif axis == 3 then sizeZ = length + THICKNESS end
                
                line.Size = Vector3.new(sizeX, sizeY, sizeZ)
                line.CFrame = targetOffset * CFrame.new(midPoint)
                
                -- MÀU TRẮNG VÀ ĐẬM GIỐNG CÁC ESP KHÁC
                line.Color3 = Color3.fromRGB(255, 255, 255) 
                line.Transparency = 0 
                line.AlwaysOnTop = true
                line.ZIndex = 10
                line.Adornee = mainPart
                line.Parent = outlineFolder
            end
        end

    ------------------------------------------------------------
    -- ITEM THƯỜNG
    ------------------------------------------------------------
    else
        local highlightName = "Hl_" .. itemID
        local clientHighlight = container:FindFirstChild(highlightName)

        if not clientHighlight then
            clientHighlight = Instance.new("Highlight")
            clientHighlight.Name = highlightName
            
            clientHighlight.FillColor = Color3.fromRGB(0, 255, 255)
            clientHighlight.FillTransparency = 0.6
            
            -- Outline gốc là Trắng, nên phần Clap Bomb đã được sửa thành Trắng
            clientHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            clientHighlight.OutlineTransparency = 0
            
            clientHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            clientHighlight.Adornee = topModel
            clientHighlight.Parent = container
        end
    end

    ------------------------------------------------------------
    -- NAME TAG
    ------------------------------------------------------------
    local tagName = "Tag_" .. itemID
    local clientTag = container:FindFirstChild(tagName)

    if not clientTag then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = tagName
        billboard.Adornee = mainPart
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 120, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.Parent = container

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Name"
        textLabel.Parent = billboard
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Text = topModel.Name
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        textLabel.TextSize = 12
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    end
end

----------------------------------------------------------------
-- XỬ LÝ NAME TAG CHỒNG NHAU
----------------------------------------------------------------

local function adjustStackedText()
    if not legitLootEnabled then return end
    local container = getClientContainer()
    if not container then return end

    local activeLoot = {}

    for topModel, _ in pairs(trackedItems) do
        if topModel and topModel.Parent then
            local itemID = tostring(topModel:GetDebugId())
            local tag = container:FindFirstChild("Tag_" .. itemID)
            local mainPart = topModel:FindFirstChildWhichIsA("BasePart", true)

            if tag and mainPart then
                table.insert(activeLoot, { Part = mainPart, Tag = tag })
            end
        end
    end

    for i = 1, #activeLoot do
        local current = activeLoot[i]
        local stackCount = 0

        for j = 1, i - 1 do
            local other = activeLoot[j]
            if (current.Part.Position - other.Part.Position).Magnitude < 3 then
                stackCount = stackCount + 1
            end
        end
        current.Tag.StudsOffset = Vector3.new(0, 1.8 + stackCount * 1.2, 0)
    end
end

----------------------------------------------------------------
-- QUÉT TOÀN BỘ MAP
----------------------------------------------------------------

local function scanAndApplyAll()
    table.clear(trackedItems)
    if itemsFolder then
        for _, desc in pairs(itemsFolder:GetDescendants()) do
            if desc:IsA("Model") then
                applyESP(desc)
            end
        end
    end
    adjustStackedText()
end

----------------------------------------------------------------
-- THEO DÕI ITEM MỚI
----------------------------------------------------------------

if itemsFolder then
    itemsFolder.DescendantAdded:Connect(function(descendant)
        task.wait(0.2)
        if descendant:IsA("Model") then
            applyESP(descendant)
        elseif descendant:IsA("BasePart")
            and descendant.Parent
            and descendant.Parent:IsA("Model") then
            applyESP(descendant.Parent)
        end
        adjustStackedText()
    end)

    ------------------------------------------------------------
    -- ITEM BỊ XÓA / NHẶT
    ------------------------------------------------------------

    itemsFolder.ChildRemoved:Connect(function(child)
        task.wait(0.1)
        local container = getClientContainer()
        local itemID = tostring(child:GetDebugId())

        if container then
            local box = container:FindFirstChild("Box_" .. itemID)
            if box then box:Destroy() end

            local outline = container:FindFirstChild("Outline_" .. itemID)
            if outline then outline:Destroy() end

            local highlight = container:FindFirstChild("Hl_" .. itemID)
            if highlight then highlight:Destroy() end

            local tag = container:FindFirstChild("Tag_" .. itemID)
            if tag then tag:Destroy() end
        end

        trackedItems[child] = nil
        adjustStackedText()
    end)
end

----------------------------------------------------------------
-- REFRESH
----------------------------------------------------------------

local function refreshESP()
    if legitLootEnabled then
        scanAndApplyAll()
    else
        clearAllESP()
    end
end

----------------------------------------------------------------
-- UI
----------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TWRLootUI"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 90, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ToggleButton.BorderSizePixel = 0
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "ESP: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Active = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

----------------------------------------------------------------
-- DRAG MOBILE + PC
----------------------------------------------------------------

local dragToggle, dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = ToggleButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        updateInput(input)
    end
end)

----------------------------------------------------------------
-- BẬT / TẮT
----------------------------------------------------------------

local function updateLootState(state)
    legitLootEnabled = state
    if legitLootEnabled then
        ToggleButton.Text = "ESP: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        refreshESP()
        notify("Đã bật Client-Side Item ESP!")
    else
        ToggleButton.Text = "ESP: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        clearAllESP()
        notify("Đã tắt toàn bộ ESP!")
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    updateLootState(not legitLootEnabled)
end)

----------------------------------------------------------------
-- PHÍM T TRÊN PC
----------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, chat)
    if chat then return end
    if input.KeyCode == Enum.KeyCode.T then
        updateLootState(not legitLootEnabled)
    end
end)

----------------------------------------------------------------
-- KHỞI CHẠY
----------------------------------------------------------------

refreshESP()

----------------------------------------------------------------
-- MAINTENANCE
----------------------------------------------------------------

task.spawn(function()
    while task.wait(1) do
        if legitLootEnabled then
            adjustStackedText()
        end
    end
end)

notify("Client-side ESP đã kích hoạt!")
