local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

_G.TitleSuffix = "Kaiju Paradise"

-- Load Neptune UI Library & Dependencies
pcall(function()
    loadstring(game:HttpGet("https://githubusercontent.com"))()
end)

local espFolderName = (_G.MakeString and _G.MakeString(16)) or "KP_ESP_Folder"

local Config = {
    Visuals = {
        Enabled = false,
        TeamCheck = false,
        ItemEnabled = false,
        ItemShowInteractible = false,
    },
    WeaponAssist = {
        Enabled = false,
        AssistBoxSize = 10,
        AssistTargetPart = "Closest"
    },
    Universal = {
        Fullbright = false
    },
    Movement = {
        WalkSpeed = 0,
        JumpPower = 0
    },
    Human = {
        AutoRespawn = false,
        AutoEscapeDelay = 1.5
    },
    Teleporting = {
        FoundItem = false,
        TeleportBackDelay = 1,
        TeleportRepeatDelay = 0,
        TeleportGrabDelay = 0
    },
    VendingMachine = {
        Enabled = false
    }
}

-- Trạng thái Lighting gốc
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd
local origGlobalShadows = Lighting.GlobalShadows
local origOutdoorAmbient = Lighting.OutdoorAmbient
local fullbrightActive = false

-- Template UI & Part
local waypointPart = Instance.new("Part")
waypointPart.Size = Vector3.new(0.3, 0.3, 0.3)
waypointPart.Anchored = true
waypointPart.CanCollide = false
waypointPart.Material = Enum.Material.Neon
waypointPart.Shape = Enum.PartType.Ball

local passthroughModifier = Instance.new("PathfindingModifier")
passthroughModifier.Name = "PassthroughModifier"
passthroughModifier.Label = "PassthroughModifier"
passthroughModifier.PassThrough = true

local baseTextLabel = Instance.new("TextLabel")
baseTextLabel.BackgroundTransparency = 1
baseTextLabel.Size = UDim2.new(0, 75, 0, 15)
baseTextLabel.Font = Enum.Font.Code
baseTextLabel.TextSize = 15
baseTextLabel.TextStrokeTransparency = 0.5
baseTextLabel.TextColor3 = Color3.new(1, 1, 1)
baseTextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
baseTextLabel.TextTransparency = 0.1

local espFolder = Instance.new("Folder")
espFolder.Name = espFolderName

local espHighlight = Instance.new("Highlight")
espHighlight.FillTransparency = 1
espHighlight.OutlineTransparency = 0.1
espHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
espHighlight.OutlineColor = Color3.fromRGB(255, 0, 0)

local bottomBillboard = Instance.new("BillboardGui")
bottomBillboard.Name = "BottomBillboard"
bottomBillboard.AlwaysOnTop = true
bottomBillboard.Size = UDim2.new(1, 100, 1, 150)
bottomBillboard.StudsOffsetWorldSpace = Vector3.new(0, -5, 0)

local bottomListLayout = Instance.new("UIListLayout")
bottomListLayout.Name = "BottomListLayout"
bottomListLayout.FillDirection = Enum.FillDirection.Vertical
bottomListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bottomListLayout.SortOrder = Enum.SortOrder.LayoutOrder
bottomListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
bottomListLayout.Parent = bottomBillboard

local infoLabel = baseTextLabel:Clone()
infoLabel.Name = "InfoLabel"
infoLabel.LayoutOrder = 1
infoLabel.Text = "UnknownInfo"
infoLabel.Size = UDim2.new(0, 100, 0, 90)
infoLabel.TextYAlignment = Enum.TextYAlignment.Bottom
infoLabel.Parent = bottomBillboard

local distanceLabel = baseTextLabel:Clone()
distanceLabel.Name = "DistanceLabel"
distanceLabel.LayoutOrder = 2
distanceLabel.Text = "UnknownStuds"
distanceLabel.Size = UDim2.new(0, 100, 0, 90)
distanceLabel.TextYAlignment = Enum.TextYAlignment.Top
distanceLabel.Parent = bottomBillboard

local topBillboard = Instance.new("BillboardGui")
topBillboard.Name = "TopBillboard"
topBillboard.AlwaysOnTop = true
topBillboard.Size = UDim2.new(1, 100, 1, 150)
topBillboard.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)

local topListLayout = Instance.new("UIListLayout")
topListLayout.Name = "TopListLayout"
topListLayout.FillDirection = Enum.FillDirection.Vertical
topListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topListLayout.SortOrder = Enum.SortOrder.LayoutOrder
topListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
topListLayout.Parent = topBillboard

local topLabel = baseTextLabel:Clone()
topLabel.Name = "TopLabel"
topLabel.LayoutOrder = 1
topLabel.Text = ""
topLabel.Size = UDim2.new(0, 100, 0, 90)
topLabel.Position = UDim2.new(0, 0, 0, 0)
topLabel.TextYAlignment = Enum.TextYAlignment.Center
topLabel.Parent = topBillboard

local playerEspCache = {}
local itemEspCache = {}

-- Thiết lập Attribute giả lập Studio (Anti-cheat bypass phụ)
pcall(function()
    workspace:SetAttribute("Age", 9000000000000000000)
    workspace:SetAttribute("Studio", true)
    workspace:SetAttribute("PrivateServer", true)
    workspace:SetAttribute("PublicServer", false)
end)

-- Các hàm tính toán phụ trợ
local function getHealthColor(health)
    local clamped = math.clamp(health, 0, 100)
    if clamped > 50 then
        return Color3.new(1 - (clamped - 50) / 50, 1, 0)
    else
        return Color3.new(1, clamped / 50, 0)
    end
end

local function formatCamelCase(str)
    local result = str:sub(1, 1)
    for i = 2, #str do
        local char = str:sub(i, i)
        if char:match("%u") then
            result = result .. " " .. char
        else
            result = result .. char
        end
    end
    return result
end

local function getItemType(item)
    local scripted = workspace:FindFirstChild("Scripted")
    if scripted and scripted:FindFirstChild("Interactable") and item.Parent == scripted.Interactable then
        return Config.Visuals.ItemShowInteractible and "Interactible" or nil
    elseif item.Name == "HazmatSuit" then
        return "HazmatSuit"
    else
        return "Tool"
    end
end

local function getItemColor(itemType)
    if itemType == "Interactible" then
        return Color3.fromRGB(255, 255, 0)
    elseif itemType == "Tool" then
        return Color3.fromRGB(255, 0, 255)
    elseif itemType == "HazmatSuit" then
        return Color3.fromRGB(255, 150, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

-- Vòng lặp dọn dẹp Client Script chống phá
local antiLoop = task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local chat = game:GetService("Chat")
            for _, child in ipairs(chat:GetChildren()) do
                child:Destroy()
            end
            if LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Default") then
                if LocalPlayer.PlayerScripts.Default:FindFirstChild("AntiWeirdPeople") then
                    LocalPlayer.PlayerScripts.Default.AntiWeirdPeople.Disabled = true
                end
                if LocalPlayer.PlayerScripts.Default:FindFirstChild("FriendCheck") then
                    LocalPlayer.PlayerScripts.Default.FriendCheck.Disabled = true
                end
            end
        end)
    end
end)

local function getClosestTarget(targetPartName)
    local closestPlayer = nil
    local minPlayerDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = LocalPlayer:DistanceFromCharacter(player.Character.HumanoidRootPart.Position)
            if dist < minPlayerDist then
                minPlayerDist = dist
                closestPlayer = player
            end
        end
    end

    local targetPart = nil
    local minPartDist = math.huge

    if closestPlayer and closestPlayer.Character then
        if targetPartName == "Closest" then
            for _, part in ipairs(closestPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local dist = LocalPlayer:DistanceFromCharacter(part.Position)
                    if dist < minPartDist then
                        minPartDist = dist
                        targetPart = part
                    end
                end
            end
        else
            targetPart = closestPlayer.Character:FindFirstChild(targetPartName)
            if targetPart then
                minPartDist = LocalPlayer:DistanceFromCharacter(targetPart.Position)
            end
        end
    end

    return { closestPlayer, minPlayerDist, targetPart, minPartDist }
end

local function teleportToItem(itemName)
    Config.Teleporting.FoundItem = false
    local originCFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
    local scripted = workspace:FindFirstChild("Scripted")
    if not scripted then return end
    
    local prompt, targetModel

    if itemName == "HazmatSuit" then
        local other = scripted:FindFirstChild("Other")
        local suit = other and other:FindFirstChild("HazmatSuit")
        if suit and suit:FindFirstChild("Torso") and suit.Torso:FindFirstChild("Attachment") then
            prompt = suit.Torso.Attachment:FindFirstChildOfClass("ProximityPrompt")
            targetModel = suit
        end
    elseif itemName == "Nightvision" or itemName == "Bandana" then
        local item = workspace.Terrain:FindFirstChild(itemName)
        if item then
            prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            targetModel = item
        end
    else
        local itemSpawner = scripted:FindFirstChild("ItemSpawner")
        local item = itemSpawner and itemSpawner:FindFirstChild(itemName, true)
        if item then
            prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                targetModel = prompt:FindFirstAncestorWhichIsA("Model")
            end
        end
    end

    if prompt and targetModel then
        Config.Teleporting.FoundItem = true
        if _G.OffsetGoto then
            _G.OffsetGoto(targetModel, 0, -0.2, 0)
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetModel:GetPivot()
            end
        end
        
        task.wait(0.2)
        if fireproximityprompt then
            fireproximityprompt(prompt, 1, true)
        end
        
        task.wait(Config.Teleporting.TeleportBackDelay)
        if Config.Teleporting.FoundItem and originCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = originCFrame
        end
    else
        if _G.Notify then _G.Notify("Couldn't find a " .. itemName .. "...", 2) end
    end
end

-- Tối ưu vị trí Hitbox đánh gần (Melee Hit Assist)
local hitAssistStep = 1
local function randomizeHitbox(dmgPoint, targetPos, boxSize)
    local offsets = {
        Vector3.new(boxSize, boxSize, -boxSize),
        Vector3.new(-boxSize, -boxSize, -boxSize),
        Vector3.new(-boxSize, boxSize, -boxSize),
        Vector3.new(boxSize, -boxSize, -boxSize),
        Vector3.new(boxSize, boxSize, boxSize),
        Vector3.new(-boxSize, -boxSize, boxSize),
        Vector3.new(-boxSize, boxSize, boxSize),
        Vector3.new(boxSize, -boxSize, boxSize),
    }
    local offset = offsets[hitAssistStep] or Vector3.zero
    dmgPoint.WorldCFrame = CFrame.new(targetPos.X + offset.X, targetPos.Y + offset.Y, targetPos.Z + offset.Z)
    hitAssistStep = (hitAssistStep % 8) + 1
end

-- Hiển thị vùng ảnh hưởng (Visualizer)
local visualizerTransparency = 0.8
local visualizerColor = Color3.fromRGB(89, 89, 89)
local function setupVisualizer(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local adornment = character:FindFirstChildWhichIsA("SphereHandleAdornment") or Instance.new("SphereHandleAdornment", character)
    adornment.Adornee = character.HumanoidRootPart
    adornment.Radius = 10
    adornment.Transparency = visualizerTransparency
    adornment.Color3 = visualizerColor
    return adornment
end

-- Khởi tạo Menu Giao diện Neptune UI
if _G.Neptune then
    local universalTab = _G.Neptune:CreateTab({ Name = "Universal" })
    local visualsSection = universalTab:CreateSection({ Name = "Visuals", Side = "Left" })
    
    visualsSection:AddToggle({ Name = "Player ESP", Flag = "PlayerESP", Callback = function(v) Config.Visuals.Enabled = v end })
    visualsSection:AddToggle({ Name = "Player ESP Team Check", Flag = "PlayerESPTeamCheck", Callback = function(v) Config.Visuals.TeamCheck = v end })
    visualsSection:AddToggle({ Name = "Item ESP", Flag = "ItemESP", Callback = function(v) Config.Visuals.ItemEnabled = v end })
    visualsSection:AddToggle({ Name = "Item ESP Show Interactible", Flag = "ItemESPInteractible", Callback = function(v) Config.Visuals.ItemShowInteractible = v end })
    
    local basicSection = universalTab:CreateSection({ Name = "Universal Basic Options", Side = "Left" })
    local autoRejoinConn
    
    basicSection:AddToggle({
        Name = "Auto Rejoin",
        Flag = "AutoRejoin",
        Callback = function(v)
            if v then
                autoRejoinConn = GuiService.ErrorMessageChanged:Connect(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end)
            elseif autoRejoinConn then
                autoRejoinConn:Disconnect()
            end
        end
    })
    
    basicSection:AddToggle({
        Name = "Door Noclip",
        Flag = "DoorNoclip",
        Callback = function(v)
            local door = workspace:FindFirstChild("Door")
            if door then
                for _, doorGroup in pairs(door:GetChildren()) do
                    if doorGroup:FindFirstChild("DoorPart") then
                        for _, part in pairs(doorGroup.DoorPart:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = not v
                            end
                        end
                    end
                end
            end
        end
    })
    
    basicSection:AddToggle({
        Name = "Fast Respawn",
        Flag = "FastRespawn",
        Callback = function(v) Players.RespawnTime = v and 0 or 6 end
    })
    
    basicSection:AddToggle({
        Name = "Mute Radios",
        Flag = "RadioMute",
        Callback = function(v)
            local events = workspace:FindFirstChild("Events")
            if events and events:FindFirstChild("MuteRadio") then
                events.MuteRadio.Value = v
            end
        end
    })
    
    basicSection:AddToggle({
        Name = "Bypass Respawn Block",
        Flag = "SpawnBypass",
        Callback = function(v)
            if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ClientVariable") and LocalPlayer.PlayerGui.ClientVariable:FindFirstChild("CanReset") then
                LocalPlayer.PlayerGui.ClientVariable.CanReset.Value = v
                if v then
                    task.spawn(function()
                        while v do
                            if LocalPlayer.PlayerGui:FindFirstChild("ClientVariable") then
                                LocalPlayer.PlayerGui.ClientVariable.CanReset.Value = true
                            end
                            task.wait()
                        end
                    end)
                end
            end
        end
    })
    
    basicSection:AddToggle({
        Name = "Fullbright",
        Flag = "Fullbright",
        Callback = function(v) Config.Universal.Fullbright = v end
    })
    
    local autoQuestTask
    basicSection:AddToggle({
        Name = "Auto Get Quest",
        Flag = "AutoQuest",
        Callback = function(v)
            if v then
                autoQuestTask = task.spawn(function()
                    while task.wait(0.5) do
                        local scripted = workspace:FindFirstChild("Scripted")
                        local npcs = scripted and scripted:FindFirstChild("NPCs")
                        local sam = npcs and npcs:FindFirstChild("Sam")
                        if sam and sam:FindFirstChild("Data") and sam.Data:FindFirstChild("Communication") then
                            sam.Data.Communication:FireServer("AddQuest")
                        end
                    end
                end)
            elseif autoQuestTask then
                task.cancel(autoQuestTask)
            end
        end
    })
    
    basicSection:AddButton({
        Name = "Force Reset",
        Callback = function()
            local remote = ReplicatedStorage:FindFirstChild("Remote")
            local diedRemote = remote and remote:FindFirstChild("DiedRemote")
            if diedRemote then diedRemote:FireServer() end
        end
    })
    
    basicSection:AddButton({
        Name = "Unlock Framerate",
        Callback = function()
            if setfpscap then setfpscap(1000) else if _G.Notify then _G.Notify("Not supported", 2) end end
        end
    })
    
    -- Weapon Assist UI
    local weaponAssistSection = universalTab:CreateSection({ Name = "Weapon Assist", Side = "Right" })
    weaponAssistSection:AddToggle({ Name = "Melee Hit Assist (Aimbot)", Flag = "HitAssist", Callback = function(v) Config.WeaponAssist.Enabled = v end })
    weaponAssistSection:AddSlider({ Name = "Assist Box Size", Flag = "AssistOffset", Value = Config.WeaponAssist.AssistBoxSize, Precise = 1, Min = 0, Max = 20, Callback = function(v) Config.WeaponAssist.AssistBoxSize = v end })
    weaponAssistSection:AddDropdown({ Name = "Assist Target Part", Flag = "AssistTargetPart", List = { "Closest", "Torso", "Head", "HumanoidRootPart" }, Callback = function(v) Config.WeaponAssist.AssistTargetPart = v end })
    
    -- Movement Tab
    local movementSection = universalTab:CreateSection({ Name = "Movement Options", Side = "Right" })
    local wsConn1, wsConn2
    
    movementSection:AddToggle({
        Name = "Use Walk Speed",
        Flag = "UseWalkSpeed",
        Callback = function(v)
            if v then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = Config.Movement.WalkSpeed
                    wsConn1 = LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.WalkSpeed = Config.Movement.WalkSpeed
                        end
                    end)
                end
                wsConn2 = LocalPlayer.CharacterAdded:Connect(function(char)
                    local hum = char:WaitForChild("Humanoid")
                    hum.WalkSpeed = Config.Movement.WalkSpeed
                    wsConn1 = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                        hum.WalkSpeed = Config.Movement.WalkSpeed
                    end)
                end)
            else
                if wsConn1 then wsConn1:Disconnect() end
                if wsConn2 then wsConn2:Disconnect() end
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 14
                end
            end
        end
    })
    
    movementSection:AddSlider({
        Name = "Walk Speed",
        Flag = "WalkSpeed",
        Value = Config.Movement.WalkSpeed, Precise = 1, Min = 0, Max = 27,
        Callback = function(v)
            Config.Movement.WalkSpeed = v
            if wsConn1 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = v
            end
        end
    })
    
    -- Human Tab
    local humanTab = _G.Neptune:CreateTab({ Name = "Human" })
    local humanBasicSection = humanTab:CreateSection({ Name = "Human Basic Options", Side = "Right" })
    humanBasicSection:AddToggle({ Name = "Auto Respawn If Infected", Flag = "AutoRespawn", Callback = function(v) Config.Human.AutoRespawn = v end })
    humanBasicSection:AddToggle({
        Name = "Bypass Barrier",
        Flag = "BarrierBypass",
        Callback = function(v)
            local events = workspace:FindFirstChild("Events")
            if events and events:FindFirstChild("BarrierEnabled") then
                events.BarrierEnabled.Value = not v
            end
        end
    })
    
    local humanTpSection = humanTab:CreateSection({ Name = "Human Item Teleports", Side = "Left" })
    local humanItems = { "HazmatSuit", "Medkit", "Katana", "Machete", "Knife", "Brick", "Nunchucks", "Sledge Hammer", "Crowbar", "Long Pipe" }
    for _, item in ipairs(humanItems) do
        humanTpSection:AddButton({ Name = item, Callback = function() teleportToItem(item) end })
    end
end

-- Vòng lặp chính RenderStepped (Aimbot Hitbox + Fullbright)
RunService.RenderStepped:Connect(function()
    if Config.WeaponAssist.Enabled then
        local targetData = getClosestTarget(Config.WeaponAssist.AssistTargetPart)
        local targetPlayer = targetData[1]
        local targetDist = targetData[2]
        local targetPart = targetData[3]
        
        local char = LocalPlayer.Character
        local intVal = char and char:FindFirstChildWhichIsA("IntValue")
        
        if intVal and targetPlayer and targetPlayer.Team ~= LocalPlayer.Team and targetDist <= 12 then
            local targetCFrame = (Config.WeaponAssist.AssistTargetPart == "Closest" and targetPart) and targetPart.CFrame
                or (targetPlayer.Character and targetPlayer.Character:FindFirstChild(Config.WeaponAssist.AssistTargetPart) and targetPlayer.Character[Config.WeaponAssist.AssistTargetPart].CFrame)
                
            if targetCFrame then
                local name = intVal.Name
                if name == "Grab" or name == "Attack" or name == "Pummel" or name == "Fists" then
                    for _, p in pairs(char:GetDescendants()) do
                        if p.Name == "DmgPoint" then
                            randomizeHitbox(p, targetCFrame, math.random(0, Config.WeaponAssist.AssistBoxSize) / 10)
                        end
                    end
                else
                    local model = intVal:FindFirstChild("Model")
                    if model and model:FindFirstChild("DmgPoint", true) then
                        for _, p in pairs(model:FindFirstChild("DmgPoint", true).Parent:GetChildren()) do
                            if p.Name == "DmgPoint" then
                                randomizeHitbox(p, targetCFrame, math.random(0, Config.WeaponAssist.AssistBoxSize) / 10)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Đồng bộ Fullbright
    if Config.Universal.Fullbright then
        if not fullbrightActive then
            origBrightness = Lighting.Brightness
            origClockTime = Lighting.ClockTime
            origFogEnd = Lighting.FogEnd
            origGlobalShadows = Lighting.GlobalShadows
            origOutdoorAmbient = Lighting.OutdoorAmbient
        end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        fullbrightActive = true
    elseif fullbrightActive then
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClockTime
        Lighting.FogEnd = origFogEnd
        Lighting.GlobalShadows = origGlobalShadows
        Lighting.OutdoorAmbient = origOutdoorAmbient
        fullbrightActive = false
    end
end)

-- Vòng lặp quét Heartbeat để cập nhật ESP (Player & Items)
local heartbeatTimer = 0
RunService.Heartbeat:Connect(function(delta)
    heartbeatTimer = heartbeatTimer + delta
    if heartbeatTimer < 0.1 then return end
    heartbeatTimer = heartbeatTimer - 0.1

    -- Kiểm tra Player ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local char = player.Character
            local espFolderClone = playerEspCache[player]
            local isVisible = Config.Visuals.Enabled and (not Config.Visuals.TeamCheck or player.Team ~= LocalPlayer.Team)
            
            if isVisible then
                if not espFolderClone then
                    espFolderClone = espFolder:Clone()
                    espFolderClone.Parent = char
                    playerEspCache[player] = espFolderClone
                    
                    local hl = espHighlight:Clone()
                    hl.Adornee = char
                    hl.Parent = espFolderClone
                    
                    local bBb = bottomBillboard:Clone()
                    bBb.Adornee = char
                    bBb.Parent = espFolderClone
                    
                    local tBb = topBillboard:Clone()
                    tBb.Adornee = char
                    tBb.Parent = espFolderClone
                end
                
                local healthColor = (player.Team and player.Team.TeamColor.Color) or getHealthColor(char.Humanoid.Health)
                if espFolderClone:FindFirstChild("Highlight") then
                    espFolderClone.Highlight.OutlineColor = healthColor
                end
                
                local labelColor = Color3.fromRGB(255, 255, 255)
                if player.Team == Teams:FindFirstChild("Human") then
                    labelColor = healthColor
                end
                
                if espFolderClone:FindFirstChild("BottomBillboard") and espFolderClone.BottomBillboard:FindFirstChild("InfoLabel") then
                    espFolderClone.BottomBillboard.InfoLabel.TextColor3 = labelColor
                    espFolderClone.BottomBillboard.InfoLabel.Text = (player.Team and player.Team.Name) or "Goo/Infected"
                    local dist = math.floor(LocalPlayer:DistanceFromCharacter(char.HumanoidRootPart.Position))
                    if espFolderClone.BottomBillboard:FindFirstChild("DistanceLabel") then
                        espFolderClone.BottomBillboard.DistanceLabel.Text = dist .. " studs"
                    end
                end
                
                if espFolderClone:FindFirstChild("TopBillboard") and espFolderClone.TopBillboard:FindFirstChild("TopLabel") then
                    espFolderClone.TopBillboard.TopLabel.TextColor3 = healthColor
                    espFolderClone.TopBillboard.TopLabel.Text = string.format("%s | %d%%", char.Name, math.floor(char.Humanoid.Health))
                end
            else
                if espFolderClone then
                    espFolderClone:Destroy()
                    playerEspCache[player] = nil
                end
            end
        end
    end

    -- Cập nhật Item ESP an toàn
    local currentItems = {}
    local scripted = workspace:FindFirstChild("Scripted")
    if scripted then
        local other = scripted:FindFirstChild("Other")
        if other then
            for _, item in pairs(other:GetChildren()) do
                if item.Name == "HazmatSuit" and item:FindFirstChild("Torso") then
                    table.insert(currentItems, item)
                end
            end
        end
        local itemSpawner = scripted:FindFirstChild("ItemSpawner")
        if itemSpawner then
            for _, spawner in pairs(itemSpawner:GetChildren()) do
                local model = spawner:FindFirstChildWhichIsA("Model")
                if model then table.insert(currentItems, model) end
            end
        end
    end

    local activeItems = {}
    for _, item in pairs(currentItems) do
        local existingEsp = itemEspCache[item]
        local itemType = getItemType(item)
        if Config.Visuals.ItemEnabled and itemType ~= nil then
            activeItems[item] = true
            local itemColor = getItemColor(itemType)
            if not existingEsp then
                existingEsp = espFolder:Clone()
                existingEsp.Parent = item
                itemEspCache[item] = existingEsp
                
                local hl = espHighlight:Clone()
                hl.Adornee = item
                hl.OutlineColor = itemColor
                hl.Parent = existingEsp
                
                local bBb = bottomBillboard:Clone()
                bBb.StudsOffsetWorldSpace = Vector3.zero
                bBb.StudsOffset = Vector3.new(0, -3, 0)
                bBb.Adornee = item
                bBb.Parent = existingEsp
                
                local lbl = infoLabel:Clone()
                lbl.Text = item.Name
                lbl.TextColor3 = itemColor
                lbl.Parent = bBb
            end
        end
    end

    for item, folderObj in pairs(itemEspCache) do
        if not item.Parent or not activeItems[item] then
            if folderObj then folderObj:Destroy() end
            itemEspCache[item] = nil
        end
    end

    -- Auto Respawn khi bị nhiễm độc
    if Config.Human.AutoRespawn and LocalPlayer.Team ~= Teams:FindFirstChild("Human") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if playerEspCache[player] then
        playerEspCache[player]:Destroy()
        playerEspCache[player] = nil
    end
end)
