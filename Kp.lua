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

loadstring(game:HttpGet("https://raw.githubusercontent.com/JinxTheCatto/Neptune/main/Games/Dependencies/UniversInit.lua"))()

local espFolderName = _G.MakeString(16)

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

-- Thiết lập Attribute cho Workspace
workspace:SetAttribute("Age", 9000000000000000000)
workspace:SetAttribute("Studio", true)
workspace:SetAttribute("PrivateServer", true)
workspace:SetAttribute("PublicServer", false)

-- Hàm hỗ trợ
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
    if item.Parent == workspace.Scripted.Interactable then
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

-- Vòng lặp dọn dẹp hệ thống chống người chơi
local antiLoop = task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local chat = game:GetService("Chat")
            for _, child in ipairs(chat:GetChildren()) do
                child:Destroy()
            end
            LocalPlayer.PlayerScripts.Default.AntiWeirdPeople.Disabled = true
            LocalPlayer.PlayerScripts.Default.FriendCheck.Disabled = true
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

    if closestPlayer then
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
    local originCFrame = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame
    local scripted = workspace.Scripted
    local prompt, targetModel

    if itemName == "HazmatSuit" then
        local suit = scripted.Other:FindFirstChild("HazmatSuit")
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
        local item = scripted.ItemSpawner:FindFirstChild(itemName, true)
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
        end
        task.wait(0.2)
        fireproximityprompt(prompt, 1, true)
        task.wait(Config.Teleporting.TeleportBackDelay)

        if Config.Teleporting.FoundItem and originCFrame and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = originCFrame
        end
    else
        _G.Notify("Couldn't find a " .. itemName .. "...", 2)
    end
end

-- Tối ưu vị trí Hitbox đánh gần
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

-- Tìm đường (Pathfinding)
local function pathfindTo(targetPos, repathCount)
    repathCount = repathCount or 0
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if repathCount >= 6 then
        warn("PathFind: Repath limit reached. Aborting path.")
        _G.Notify("Pathfinding failed: stuck too many times.", 2)
        return false
    end

    if not humanoid or not rootPart or humanoid.Health <= 0 then
        warn("PathFind: Humanoid not available for pathfinding (or dead).")
        _G.Notify("Pathfinding aborted: character not ready.", 2)
        return false
    end

    local function createWaypoints(waypoints)
        local parts = {}
        for i, wp in ipairs(waypoints) do
            local p = waypointPart:Clone()
            p.Position = wp.Position
            p.Color = (i == #waypoints) and Color3.fromRGB(0, 255, 0) 
                      or (wp.Action == Enum.PathWaypointAction.Jump and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 139, 0))
            p.Name = "PathWaypoint"
            p.Parent = workspace
            table.insert(parts, p)
        end
        return parts
    end

    local function cleanupWaypoints(parts)
        if parts then
            for _, p in ipairs(parts) do p:Destroy() end
        end
    end

    local pathParams = {
        AgentRadius = 5,
        AgentCanJump = true,
        WaypointSpacing = 0.2,
        Costs = { HazardArea = math.huge },
    }

    pcall(function()
        for _, barrier in ipairs(workspace.RaycastBarriers:GetChildren()) do
            if not barrier:FindFirstChildOfClass("PathfindingModifier") then
                passthroughModifier:Clone().Parent = barrier
            end
        end
        if workspace.Scripted.Other:FindFirstChild("SpawnHitBox") and not workspace.Scripted.Other.SpawnHitBox:FindFirstChildOfClass("PathfindingModifier") then
            passthroughModifier:Clone().Parent = workspace.Scripted.Other.SpawnHitBox
        end
        for _, light in ipairs(workspace.Lights:GetChildren()) do
            if light.Name == "Forcefield" and not light:FindFirstChildOfClass("PathfindingModifier") then
                passthroughModifier:Clone().Parent = light
            end
        end
        for _, door in ipairs(workspace.Door:GetChildren()) do
            if door.Name == "DoubleAutoDoor" and not door:FindFirstChildOfClass("PathfindingModifier") then
                passthroughModifier:Clone().Parent = door
            end
        end
    end)

    pcall(function()
        for _, child in ipairs(workspace.Workplace.Map.Cafe:GetChildren()) do
            if child:IsA("UnionOperation") and math.abs(child.Size.X - 0.3) < 0.1 and math.abs(child.Size.Y - 14.05) < 0.1 and math.abs(child.Size.Z - 48) < 0.5 then
                child:Destroy()
            end
        end
    end)

    local success, result = pcall(function()
        local path = PathfindingService:CreatePath(pathParams)
        path:ComputeAsync(rootPart.Position, targetPos)

        if path.Status ~= Enum.PathStatus.Success then
            warn("PathFind: Path computation failed. Reason: " .. tostring(path.Status))
            return pathfindTo(targetPos, repathCount + 1)
        end

        local waypoints = path:GetWaypoints()
        if #waypoints < 2 then return true end

        local waypointParts = createWaypoints(waypoints)
        local reachedTarget = true

        for i, wp in ipairs(waypoints) do
            if not Config.VendingMachine.Enabled then
                reachedTarget = false
                break
            end

            if i > 1 then
                humanoid:MoveTo(wp.Position)
                if wp.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end

                local startTime = tick()
                local reached = false

                local conn = humanoid.MoveToFinished:Connect(function(reachedWp)
                    if reachedWp then
                        reached = true
                    else
                        warn("PathFind: MoveToFinished reported not reached for waypoint " .. i)
                    end
                end)

                while not reached do
                    if not Config.VendingMachine.Enabled then
                        reachedTarget = false
                        break
                    end

                    local currentPos = rootPart.Position
                    if (Vector3.new(currentPos.X, wp.Position.Y, currentPos.Z) - wp.Position).Magnitude < 4 then
                        reached = true
                        break
                    end

                    if tick() - startTime > 4 then
                        warn("PathFind: Player stuck at waypoint " .. i .. ", attempting to repath...")
                        reachedTarget = false
                        break
                    end

                    local state = humanoid:GetState()
                    if rootPart.AssemblyLinearVelocity.Magnitude < 8 and state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Landed then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait()
                    end

                    task.wait()
                end

                if conn.Connected then conn:Disconnect() end
                if not reachedTarget then break end
            end
        end

        cleanupWaypoints(waypointParts)
        return reachedTarget
    end)

    if not success then
        warn("PATHFINDING CRITICAL ERROR: " .. tostring(result))
        _G.Notify("Pathfinding failed due to an unexpected error.", 2)
        return false
    end

    return result
end

-- Tạo giao diện (UI Setup)
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
        for _, doorGroup in pairs(workspace.Door:GetChildren()) do
            if doorGroup:FindFirstChild("DoorPart") then
                for _, part in pairs(doorGroup.DoorPart:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = not v
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
    Callback = function(v) workspace.Events.MuteRadio.Value = v end
})

basicSection:AddToggle({
    Name = "Bypass Respawn Block",
    Flag = "SpawnBypass",
    Callback = function(v)
        LocalPlayer.PlayerGui.ClientVariable.CanReset.Value = v
        if v then
            task.spawn(function()
                while v do
                    LocalPlayer.PlayerGui.ClientVariable.CanReset.Value = true
                    task.wait()
                end
            end)
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
                while task.wait(0.1) do
                    local sam = workspace:WaitForChild("Scripted"):WaitForChild("NPCs"):WaitForChild("Sam")
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
    Name = "Get Quest",
    Callback = function()
        local sam = workspace:WaitForChild("Scripted"):WaitForChild("NPCs"):WaitForChild("Sam")
        if sam and sam:FindFirstChild("Data") and sam.Data:FindFirstChild("Communication") then
            sam.Data.Communication:FireServer("AddQuest")
        end
    end
})

basicSection:AddButton({
    Name = "Force Reset",
    Callback = function()
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("DiedRemote"):FireServer()
    end
})

basicSection:AddButton({
    Name = "Fire Proximity Prompts",
    Callback = function()
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt, 1, true)
            end
        end
    end
})

basicSection:AddButton({
    Name = "Unlock Framerate",
    Callback = function()
        if setfpscap then
            setfpscap(1000)
        else
            _G.Notify("Your exploit does not support this feature", 2)
        end
    end
})

basicSection:AddButton({
    Name = "Serverhop",
    Callback = function()
        _G.Notify("Serverhopping...", 2)
        if _G.ServerHop then _G.ServerHop() end
    end
})

basicSection:AddButton({
    Name = "Rejoin",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

basicSection:AddButton({
    Name = "Ultra Performance Mode",
    Callback = function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9000000000

        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Lifetime = NumberRange.new(0)
            elseif obj:IsA("Explosion") then
                obj.BlastPressure = 1
                obj.BlastRadius = 1
            end
        end

        for _, effect in pairs(Lighting:GetDescendants()) do
            if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
                effect.Enabled = false
            end
        end

        workspace.DescendantAdded:Connect(function(descendant)
            task.spawn(function()
                if descendant:IsA("ForceField") or descendant:IsA("Sparkles") or descendant:IsA("Smoke") or descendant:IsA("Fire") then
                    task.wait()
                    descendant:Destroy()
                end
            end)
        end)
    end
})

basicSection:AddButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if _G.DiscordToClipboard then _G.DiscordToClipboard() end
        _G.Notify("Copied!", 1)
    end
})

-- Weapon Assist
local weaponAssistSection = universalTab:CreateSection({ Name = "Weapon Assist", Side = "Right" })

weaponAssistSection:AddToggle({ Name = "Melee Hit Assist (Aimbot)", Flag = "HitAssist", Callback = function(v) Config.WeaponAssist.Enabled = v end })
weaponAssistSection:AddSlider({ Name = "Assist Box Size (Advanced)", Flag = "AssistOffset", Value = Config.WeaponAssist.AssistBoxSize, Precise = 1, Min = 0, Max = 20, Callback = function(v) Config.WeaponAssist.AssistBoxSize = v end })
weaponAssistSection:AddDropdown({ Name = "Assist Target Part", Flag = "AssistTargetPart", List = { "Closest", "Torso", "Head", "HumanoidRootPart" }, Callback = function(v) Config.WeaponAssist.AssistTargetPart = v end })

local visualizerConn
weaponAssistSection:AddToggle({
    Name = "Assist Range Visualizer",
    Flag = "AssistRangeVisualizer",
    Callback = function(v)
        if v then
            setupVisualizer(LocalPlayer.Character)
            visualizerConn = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                setupVisualizer(char)
            end)
        else
            if visualizerConn then visualizerConn:Disconnect() end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("SphereHandleAdornment") then
                LocalPlayer.Character:FindFirstChildWhichIsA("SphereHandleAdornment"):Destroy()
            end
        end
    end
})

weaponAssistSection:AddSlider({
    Name = "Visualizer Transparency",
    Flag = "VisualizerTransparency",
    Value = 8,
    Precise = 1,
    Min = 0,
    Max = 10,
    Callback = function(v)
        visualizerTransparency = v / 10
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("SphereHandleAdornment") then
            LocalPlayer.Character:FindFirstChildWhichIsA("SphereHandleAdornment"):Destroy()
            setupVisualizer(LocalPlayer.Character)
        end
    end
})

weaponAssistSection:AddColorPicker({
    Name = "Visualizer Color",
    Flag = "VisualizerColor",
    Value = Color3.fromRGB(215, 215, 215),
    Callback = function(v)
        visualizerColor = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("SphereHandleAdornment") then
            LocalPlayer.Character:FindFirstChildWhichIsA("SphereHandleAdornment"):Destroy()
            setupVisualizer(LocalPlayer.Character)
        end
    end
})

-- Tùy chọn di chuyển (Movement Options)
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
    Value = Config.Movement.WalkSpeed,
    Precise = 1,
    Min = 0,
    Max = 27,
    Callback = function(v)
        Config.Movement.WalkSpeed = v
        if wsConn1 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

local noJumpCdConn
movementSection:AddToggle({
    Name = "No Jump Cooldown",
    Flag = "NoJumpCooldown",
    Callback = function(v)
        if v then
            noJumpCdConn = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local state = hum:GetState()
                    if state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Landed then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait()
                    end
                end
            end)
        elseif noJumpCdConn then
            noJumpCdConn:Disconnect()
        end
    end
})

-- Tùy chọn Dịch chuyển (Teleportation)
local tpSection = universalTab:CreateSection({ Name = "Teleportation Options", Side = "Right" })
tpSection:AddSlider({ Name = "Teleport Back Delay", Flag = "TeleportDelay", Value = Config.Teleporting.TeleportBackDelay, Precise = 1, Min = 0, Max = 10, Callback = function(v) Config.Teleporting.TeleportBackDelay = v end })
tpSection:AddSlider({ Name = "Teleport Repeat Delay", Flag = "TeleportRepeatDelay", Value = Config.Teleporting.TeleportRepeatDelay, Precise = 1, Min = 0, Max = 2, Callback = function(v) Config.Teleporting.TeleportRepeatDelay = v end })
tpSection:AddSlider({ Name = "Teleport Grab Delay", Flag = "TeleportGrabDelay", Value = Config.Teleporting.TeleportGrabDelay, Precise = 1, Min = 0, Max = 2, Callback = function(v) Config.Teleporting.TeleportGrabDelay = v end })

-- Tab Con người (Human Tab)
local humanTab = _G.Neptune:CreateTab({ Name = "Human" })
local humanBasicSection = humanTab:CreateSection({ Name = "Human Basic Options", Side = "Right" })

humanBasicSection:AddToggle({ Name = "Auto Respawn If Infected", Flag = "AutoRespawn", Callback = function(v) Config.Human.AutoRespawn = v end })
humanBasicSection:AddToggle({ Name = "Bypass Barrier", Flag = "BarrierBypass", Callback = function(v) workspace.Events.BarrierEnabled.Value = not v end })

local autoEscapeConn1, autoEscapeConn2, autoEscapeConn3
humanBasicSection:AddToggle({
    Name = "Auto Escape",
    Flag = "AutoEscape",
    Callback = function(v)
        if v then
            if LocalPlayer.Character then
                autoEscapeConn1 = LocalPlayer.Character.ChildAdded:Connect(function(child)
                    if child.Name == "GrabWeld" then
                        task.wait(Config.Human.AutoEscapeDelay)
                        ReplicatedStorage.Remote.Grab.Escape:FireServer()
                    end
                end)
            end

            autoEscapeConn2 = LocalPlayer.CharacterAdded:Connect(function(char)
                if autoEscapeConn3 then autoEscapeConn3:Disconnect() end
                autoEscapeConn3 = char.ChildAdded:Connect(function(child)
                    if child.Name == "GrabWeld" then
                        task.wait(Config.Human.AutoEscapeDelay)
                        ReplicatedStorage.Remote.Grab.Escape:FireServer()
                    end
                end)
            end)
        else
            if autoEscapeConn1 then autoEscapeConn1:Disconnect() end
            if autoEscapeConn2 then autoEscapeConn2:Disconnect() end
            if autoEscapeConn3 then autoEscapeConn3:Disconnect() end
        end
    end
})

humanBasicSection:AddSlider({ Name = "Escape Delay", Flag = "DelaySlider", Value = Config.Human.AutoEscapeDelay, Precise = 1, Min = 0, Max = 5, Callback = function(v) Config.Human.AutoEscapeDelay = v end })

local humanTpSection = humanTab:CreateSection({ Name = "Human Item Teleports", Side = "Left" })
local humanItems = { "HazmatSuit", "Medkit", "Katana", "Machete", "Knife", "Brick", "Nunchucks", "Sledge Hammer", "Crowbar", "Long Pipe" }
for _, item in ipairs(humanItems) do
    humanTpSection:AddButton({ Name = item, Callback = function() teleportToItem(item) end })
end

-- Tab Furry / Raytraxian
local furryTab = _G.Neptune:CreateTab({ Name = "Furry/Raytraxian" })
local hazzyTpSection = furryTab:CreateSection({ Name = "Hazzy Item Teleports", Side = "Left" })
local hazzyItems = { "HazmatSuit", "Katana", "Knife", "Brick", "Nunchucks", "Crowbar", "Long Pipe" }
for _, item in ipairs(hazzyItems) do
    hazzyTpSection:AddButton({ Name = item, Callback = function() teleportToItem(item) end })
end

local furryBasicSection = furryTab:CreateSection({ Name = "Furry/Goo Basic Options", Side = "Right" })
local autoNcConn
furryBasicSection:AddToggle({
    Name = "Auto Grab Nightcrawler",
    Flag = "AutoNC",
    Callback = function(v)
        if v then
            autoNcConn = workspace.Terrain.ChildAdded:Connect(function(child)
                if child.Name == "Nightvision" and child:IsA("Model") then
                    _G.Notify("NC Has Spawned!", 1)
                    teleportToItem("Nightvision")
                end
            end)
        elseif autoNcConn then
            autoNcConn:Disconnect()
        end
    end
})

local autoBandanaConn
furryBasicSection:AddToggle({
    Name = "Auto Grab Bandana",
    Flag = "AutoBandana",
    Callback = function(v)
        if v then
            autoBandanaConn = workspace.Terrain.ChildAdded:Connect(function(child)
                if child.Name == "Bandana" and child:IsA("Model") then
                    _G.Notify("Bandana Has Spawned!", 1)
                    teleportToItem("Bandana")
                end
            end)
        elseif autoBandanaConn then
            autoBandanaConn:Disconnect()
        end
    end
})

furryBasicSection:AddButton({
    Name = "Kill Yourself NOW!",
    Callback = function()
        for i = 1, 10 do
            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Safezone"):FireServer("Zap")
        end
    end
})

furryBasicSection:AddButton({
    Name = "Fake Unlock Bestiary",
    Callback = function()
        local list = LocalPlayer.PlayerGui.Bestiary.Menu.Page.List
        for _, scroll in ipairs(list:GetChildren()) do
            if scroll:IsA("ScrollingFrame") then
                for _, frame in ipairs(scroll.Frame:GetChildren()) do
                    if frame:IsA("Frame") then
                        frame.Frame.Image.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        frame.Frame.TextLabel.Text = formatCamelCase(frame.Name)
                    end
                end
            end
        end
    end
})

-- Vòng lặp chính RenderStepped (Aimbot + Fullbright)
RunService.RenderStepped:Connect(function()
    if Config.WeaponAssist.Enabled then
        local targetData = getClosestTarget(Config.WeaponAssist.AssistTargetPart)
        local targetPlayer = targetData[1]
        local targetDist = targetData[2]
        local targetPart = targetData[3]

        local char = LocalPlayer.Character
        local intVal = char and char:FindFirstChildWhichIsA("IntValue")

        if intVal and targetPlayer and targetPlayer.Team ~= LocalPlayer.Team and targetDist <= 10 then
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

Players.PlayerRemoving:Connect(function(player)
    if playerEspCache[player] then
        playerEspCache[player]:Destroy()
        playerEspCache[player] = nil
    end
end)

-- Vòng lặp chính Heartbeat (ESP Update)
local heartbeatTimer = 0
RunService.Heartbeat:Connect(function(delta)
    heartbeatTimer = heartbeatTimer + delta
    if heartbeatTimer < 0.1 then return end
    heartbeatTimer = heartbeatTimer - 0.1

    -- Vòng lặp Player ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

                local healthColor = Config.Visuals.TeamCheck and getHealthColor(char.Humanoid.Health) or player.Team.TeamColor.Color
                espFolderClone.Highlight.OutlineColor = healthColor

                local labelColor = Color3.fromRGB(255, 255, 255)
                if player.Team == Teams.Human then
                    labelColor = healthColor
                elseif player.Team == Teams.Raytraxian then
                    labelColor = char:GetAttribute("RaytraxColor") or Color3.fromRGB(255, 255, 255)
                end
                espFolderClone.BottomBillboard.InfoLabel.TextColor3 = labelColor

                local teamName = ""
                if player.Team == Teams.Human then
                    local setting = char:FindFirstChild("Setting", true)
                    teamName = setting and setting.Parent.Name or ""
                elseif player.Team == Teams.Raytraxian then
                    local raytype = char:GetAttribute("RaytraxType") or "Unknown"
                    local slime = char:GetAttribute("SlimeColor")
                    teamName = raytype .. (slime and (" (" .. slime .. ")") or "")
                end
                espFolderClone.BottomBillboard.InfoLabel.Text = teamName

                local dist = math.floor(LocalPlayer:DistanceFromCharacter(char.HumanoidRootPart.Position))
                espFolderClone.BottomBillboard.DistanceLabel.Text = dist .. " studs"

                espFolderClone.TopBillboard.TopLabel.TextColor3 = healthColor
                espFolderClone.TopBillboard.TopLabel.Text = string.format("%s | %d%%\nV", char.Name, math.floor(char.Humanoid.Health))
            else
                if espFolderClone then
                    espFolderClone:Destroy()
                    playerEspCache[player] = nil
                end
            end
        end
    end

    -- Vòng lặp Item ESP
    local currentItems = {}
    for _, item in pairs(workspace.Scripted.Other:GetChildren()) do
        if item.Name == "HazmatSuit" and item:FindFirstChild("Torso") then
            table.insert(currentItems, item)
        end
    end
    for _, spawner in pairs(workspace.Scripted.ItemSpawner:GetChildren()) do
        local model = spawner:FindFirstChildWhichIsA("Model")
        if model then table.insert(currentItems, model) end
    end
    for _, interactable in pairs(workspace.Scripted.Interactable:GetChildren()) do
        if interactable:IsA("Model") then table.insert(currentItems, interactable) end
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

    -- Tự tử khi bị lây nhiễm (Auto Respawn)
    if Config.Human.AutoRespawn and LocalPlayer.Team == Teams.Raytraxian and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- Sao chép Discord link và dọn dẹp biến khi hủy script
if _G.DiscordToClipboard then _G.DiscordToClipboard() end
_G.Notify("Copied Discord Server to clipboard!", 1)

if _G.Wait then
    repeat task.wait() until not _G.Wait()
end

if antiLoop then task.cancel(antiLoop) end
if autoRejoinConn then autoRejoinConn:Disconnect() end
if autoQuestTask then task.cancel(autoQuestTask) end
if wsConn1 then wsConn1:Disconnect() end
if wsConn2 then wsConn2:Disconnect() end
if noJumpCdConn then noJumpCdConn:Disconnect() end
if autoEscapeConn1 then autoEscapeConn1:Disconnect() end
if autoEscapeConn2 then autoEscapeConn2:Disconnect() end
if autoEscapeConn3 then autoEscapeConn3:Disconnect() end
if autoNcConn then autoNcConn:Disconnect() end
if autoBandanaConn then autoBandanaConn:Disconnect() end

playerEspCache = {}
itemEspCache = {}
