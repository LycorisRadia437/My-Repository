local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    PlayerESP = false,
    PlayerESPTeamCheck = false,
    ItemESP = false,
    ItemESPInteractible = false,
    AutoRejoin = false,
    DoorNoclip = false,
    FastRespawn = false,
    RadioMute = false,
    SpawnBypass = false,
    Fullbright = false,
    AutoQuest = false,
    HitAssist = false,
    AssistOffset = 10,
    AssistTargetPart = "Closest",
    UseWalkSpeed = false,
    WalkSpeed = 16,
    NoJumpCooldown = false,
    BarrierBypass = false,
}

local DefaultLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

local function GetAliveCharacter(player)
    local char = player and player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            return true, root, hum
        end
    end
    return false, nil, nil
end

local function TeleportToInstance(targetInstance)
    local isAlive, rootPart = GetAliveCharacter(LocalPlayer)
    if isAlive and rootPart and targetInstance then
        local part = targetInstance:IsA("BasePart") and targetInstance or targetInstance:FindFirstChildWhichIsA("BasePart", true)
        if part then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
        end
    end
end

local function TeleportToNamedItem(itemName)
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == itemName or (item:IsA("Tool") and item.Name:lower():find(itemName:lower())) then
            TeleportToInstance(item)
            break
        end
    end
end

-- Tải Thư viện UI Neptune gốc
local Neptune = loadstring(game:HttpGet("https://raw.githubusercontent.com/LycorisRadia437/My-Repository/refs/heads/main/Neptuneui.lua"))()

-- Khởi tạo các Tab (Sử dụng 'text' thay vì 'Name' để map đúng với cấu trúc Neptune)
local UniversalTab = Neptune:CreateTab({text = "Universal"})
local HumanTab = Neptune:CreateTab({text = "Human"})
local FurryTab = Neptune:CreateTab({text = "Furry/Raytraxian"})

-- Universal -> Visuals
local VisualsSection = UniversalTab:CreateSection({text = "Visuals"})

VisualsSection:AddToggle({
    text = "Player ESP",
    flag = "PlayerESP",
    callback = function(enabled) Settings.PlayerESP = enabled end
})

VisualsSection:AddToggle({
    text = "Player ESP Team Check",
    flag = "PlayerESPTeamCheck",
    callback = function(enabled) Settings.PlayerESPTeamCheck = enabled end
})

VisualsSection:AddToggle({
    text = "Item ESP",
    flag = "ItemESP",
    callback = function(enabled) Settings.ItemESP = enabled end
})

VisualsSection:AddToggle({
    text = "Item ESP Show Interactible",
    flag = "ItemESPInteractible",
    callback = function(enabled) Settings.ItemESPInteractible = enabled end
})

-- Universal -> Basic Options
local BasicOptionsSection = UniversalTab:CreateSection({text = "Universal Basic Options"})

BasicOptionsSection:AddToggle({
    text = "Auto Rejoin",
    flag = "AutoRejoin",
    callback = function(enabled) Settings.AutoRejoin = enabled end
})

BasicOptionsSection:AddToggle({
    text = "Door Noclip",
    flag = "DoorNoclip",
    callback = function(enabled) Settings.DoorNoclip = enabled end
})

BasicOptionsSection:AddToggle({
    text = "Fast Respawn",
    flag = "FastRespawn",
    callback = function(enabled) Settings.FastRespawn = enabled end
})

BasicOptionsSection:AddToggle({
    text = "Mute Radios",
    flag = "RadioMute",
    callback = function(enabled) Settings.RadioMute = enabled end
})

BasicOptionsSection:AddToggle({
    text = "Bypass Respawn Block",
    flag = "SpawnBypass",
    callback = function(enabled) Settings.SpawnBypass = enabled end
})

BasicOptionsSection:AddToggle({
    text = "Fullbright",
    flag = "Fullbright",
    callback = function(enabled)
        Settings.Fullbright = enabled
        if enabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.ClockTime = DefaultLighting.ClockTime
            Lighting.FogEnd = DefaultLighting.FogEnd
            Lighting.GlobalShadows = DefaultLighting.GlobalShadows
            Lighting.Ambient = DefaultLighting.Ambient
        end
    end
})

BasicOptionsSection:AddToggle({
    text = "Auto Get Quest",
    flag = "AutoQuest",
    callback = function(enabled) Settings.AutoQuest = enabled end
})

BasicOptionsSection:AddButton({
    text = "Get Quest",
    callback = function()
        local questGiver = Workspace:FindFirstChild("QuestGiver", true) or Workspace:FindFirstChild("Giver", true)
        if questGiver and fireproximityprompt then
            local prompt = questGiver:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then fireproximityprompt(prompt) end
        end
    end
})

BasicOptionsSection:AddButton({
    text = "Force Reset",
    callback = function()
        local isAlive, _, hum = GetAliveCharacter(LocalPlayer)
        if isAlive and hum then hum.Health = 0 end
    end
})

BasicOptionsSection:AddButton({
    text = "Fire Proximity Prompts",
    callback = function()
        if fireproximityprompt then
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
})

BasicOptionsSection:AddButton({
    text = "Unlock Framerate",
    callback = function()
        if setfpscap then setfpscap(999) end
    end
})

BasicOptionsSection:AddButton({
    text = "Serverhop",
    callback = function()
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://roblox.com" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            if servers and servers.data then
                for _, server in ipairs(servers.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        break
                    end
                end
            end
        end)
    end
})

BasicOptionsSection:AddButton({
    text = "Rejoin",
    callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end
})

BasicOptionsSection:AddButton({
    text = "Ultra Performance Mode",
    callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end
})

-- Universal -> Weapon Assist
local WeaponAssistSection = UniversalTab:CreateSection({text = "Weapon Assist"})

WeaponAssistSection:AddToggle({
    text = "Melee Hit Assist (Aimbot)",
    flag = "HitAssist",
    callback = function(enabled) Settings.HitAssist = enabled end
})

WeaponAssistSection:AddSlider({
    text = "Assist Box Size",
    flag = "AssistOffset",
    min = 0, max = 20, value = 10, precise = 1,
    callback = function(value) Settings.AssistOffset = value end
})

-- Universal -> Movement
local MovementSection = UniversalTab:CreateSection({text = "Movement Options"})

MovementSection:AddToggle({
    text = "Use Walk Speed",
    flag = "UseWalkSpeed",
    callback = function(enabled)
        Settings.UseWalkSpeed = enabled
        local isAlive, _, hum = GetAliveCharacter(LocalPlayer)
        if isAlive and hum then
            hum.WalkSpeed = enabled and Settings.WalkSpeed or 16
        end
    end
})

MovementSection:AddSlider({
    text = "Walk Speed",
    flag = "WalkSpeed",
    min = 16, max = 100, value = 16, precise = 1,
    callback = function(value)
        Settings.WalkSpeed = value
    end
})

RunService.PostSimulation:Connect(function()
    if Settings.UseWalkSpeed then
        local isAlive, _, hum = GetAliveCharacter(LocalPlayer)
        if isAlive and hum and hum.WalkSpeed ~= Settings.WalkSpeed then
            hum.WalkSpeed = Settings.WalkSpeed
        end
    end
end)

-- Human -> Basic
local HumanBasicSection = HumanTab:CreateSection({text = "Human Basic Options"})

HumanBasicSection:AddToggle({
    text = "Bypass Barrier",
    flag = "BarrierBypass",
    callback = function(enabled)
        Settings.BarrierBypass = enabled
        for _, barrier in ipairs(Workspace:GetDescendants()) do
            if barrier:IsA("BasePart") and (barrier.Name:lower():find("barrier") or barrier.Name:lower():find("gate")) then
                barrier.CanCollide = not enabled
            end
        end
    end
})

-- Human -> Item Teleports
local HumanItemSection = HumanTab:CreateSection({text = "Human Item Teleports"})
local HumanItems = {
    "Hazmat Suit", "Medkit", "Katana", "Machete", "Knife",
    "Brick", "Nunchucks", "Sledge Hammer", "Crowbar", "Long Pipe", "Bat"
}
for _, itemName in ipairs(HumanItems) do
    HumanItemSection:AddButton({
        text = itemName,
        callback = function() TeleportToNamedItem(itemName) end
    })
end

-- Furry -> Basic Options
local FurryBasicSection = FurryTab:CreateSection({text = "Furry/Goo Basic Options"})

FurryBasicSection:AddButton({
    text = "Kill Yourself NOW!",
    callback = function()
        local isAlive, _, hum = GetAliveCharacter(LocalPlayer)
        if isAlive and hum then 
            hum.Health = 0 
        end
    end
})

-- Vòng lặp Noclip ẩn
RunService.Heartbeat:Connect(function()
    if Settings.DoorNoclip then
        for _, door in ipairs(Workspace:GetDescendants()) do
            if door:IsA("BasePart") and (door.Name:lower():find("door") or door.Name:lower():find("gate")) then
                door.CanCollide = false
            end
        end
    end
end)
