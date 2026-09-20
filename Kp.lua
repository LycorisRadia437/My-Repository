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
    AssistRangeVisualizer = false,
    VisualizerTransparency = 8,
    VisualizerColor = Color3.new(0.843137, 0.843137, 0.843137),
    UseWalkSpeed = false,
    WalkSpeed = 16,
    NoJumpCooldown = false,
    TeleportDelay = 1,
    TeleportRepeatDelay = 0,
    TeleportGrabDelay = 0,
    AutoRespawn = false,
    BarrierBypass = false,
    AutoEscape = false,
    DelaySlider = 1.5,
    AutoNC = false,
    AutoBandana = false
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

-- Teleport tránh bị kẹt hoặc rơi xuống void
local function TeleportToInstance(targetInstance)
    local isAlive, rootPart = GetAliveCharacter(LocalPlayer)

    if isAlive and rootPart and targetInstance then
        local part

        if targetInstance:IsA("BasePart") then
            part = targetInstance
        else
            part = targetInstance:FindFirstChildWhichIsA("BasePart", true)
        end

        if part then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.CFrame = part.CFrame * CFrame.new(0, 3, 0)
        end
    end
end

local function TeleportToNamedItem(itemName)
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == itemName
            or (item:IsA("Tool") and item.Name:lower():find(itemName:lower())) then

            TeleportToInstance(item)
            break
        end
    end
end

-- Initialize Neptune Library
local Neptune = loadstring(
    game:HttpGet(
        "https://raw.githubusercontent.com/JinxTheCatto/Neptune/main/Games/Dependencies/UniversInit.lua"
    )
)()

local UniversalTab = Neptune:CreateTab("Universal")
local HumanTab = Neptune:CreateTab("Human")
local FurryTab = Neptune:CreateTab("Furry/Raytraxian")

-- =========================================================
-- Universal -> Visuals
-- =========================================================

local VisualsSection = UniversalTab:CreateSection("Visuals")

VisualsSection:AddToggle({
    Name = "Player ESP",
    Flag = "PlayerESP",

    Callback = function(enabled)
        Settings.PlayerESP = enabled
    end
})

VisualsSection:AddToggle({
    Name = "Player ESP Team Check",
    Flag = "PlayerESPTeamCheck",

    Callback = function(enabled)
        Settings.PlayerESPTeamCheck = enabled
    end
})

VisualsSection:AddToggle({
    Name = "Item ESP",
    Flag = "ItemESP",

    Callback = function(enabled)
        Settings.ItemESP = enabled
    end
})

VisualsSection:AddToggle({
    Name = "Item ESP Show Interactible",
    Flag = "ItemESPInteractible",

    Callback = function(enabled)
        Settings.ItemESPInteractible = enabled
    end
})

-- =========================================================
-- Universal -> Basic Options
-- =========================================================

local BasicOptionsSection =
    UniversalTab:CreateSection("Universal Basic Options")

BasicOptionsSection:AddToggle({
    Name = "Auto Rejoin",
    Flag = "AutoRejoin",

    Callback = function(enabled)
        Settings.AutoRejoin = enabled
    end
})

BasicOptionsSection:AddToggle({
    Name = "Door Noclip",
    Flag = "DoorNoclip",

    Callback = function(enabled)
        Settings.DoorNoclip = enabled
    end
})

BasicOptionsSection:AddToggle({
    Name = "Fast Respawn",
    Flag = "FastRespawn",

    Callback = function(enabled)
        Settings.FastRespawn = enabled
    end
})

BasicOptionsSection:AddToggle({
    Name = "Mute Radios",
    Flag = "RadioMute",

    Callback = function(enabled)
        Settings.RadioMute = enabled
    end
})

BasicOptionsSection:AddToggle({
    Name = "Bypass Respawn Block",
    Flag = "SpawnBypass",

    Callback = function(enabled)
        Settings.SpawnBypass = enabled
    end
})

BasicOptionsSection:AddToggle({
    Name = "Fullbright",
    Flag = "Fullbright",

    Callback = function(enabled)
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
    Name = "Auto Get Quest",
    Flag = "AutoQuest",

    Callback = function(enabled)
        Settings.AutoQuest = enabled
    end
})

BasicOptionsSection:AddButton({
    Name = "Get Quest",

    Callback = function()
        local questGiver =
            Workspace:FindFirstChild("QuestGiver", true)
            or Workspace:FindFirstChild("Giver", true)

        if questGiver and fireproximityprompt then
            local prompt =
                questGiver:FindFirstChildWhichIsA("ProximityPrompt", true)

            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end
})

BasicOptionsSection:AddButton({
    Name = "Force Reset",

    Callback = function()
        local isAlive, _, hum = GetAliveCharacter(LocalPlayer)

        if isAlive and hum then
            hum.Health = 0
        end
    end
})

BasicOptionsSection:AddButton({
    Name = "Fire Proximity Prompts",

    Callback = function()
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
    Name = "Unlock Framerate",

    Callback = function()
        if setfpscap then
            setfpscap(999)
        end
    end
})

BasicOptionsSection:AddButton({
    Name = "Serverhop",

    Callback = function()
        pcall(function()
            local servers = HttpService:JSONDecode(
                game:HttpGet(
                    "https://roblox.com" ..
                    game.PlaceId ..
                    "/servers/Public?sortOrder=Asc&limit=100"
                )
            )

            if servers and servers.data then
                for _, server in ipairs(servers.data) do
                    if server.playing < server.maxPlayers
                        and server.id ~= game.JobId then

                        TeleportService:TeleportToPlaceInstance(
                            game.PlaceId,
                            server.id,
                            LocalPlayer
                        )

                        break
                    end
                end
            end
        end)
    end
})

BasicOptionsSection:AddButton({
    Name = "Rejoin",

    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

BasicOptionsSection:AddButton({
    Name = "Ultra Performance Mode",

    Callback = function()
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

BasicOptionsSection:AddButton({
    Name = "Copy Discord Invite",

    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg")
        end
    end
})

-- =========================================================
-- Universal -> Weapon Assist
-- =========================================================

local WeaponAssistSection =
    UniversalTab:CreateSection("Weapon Assist")

WeaponAssistSection:AddToggle({
    Name = "Melee Hit Assist (Aimbot)",
    Flag = "HitAssist",

    Callback = function(enabled)
        Settings.HitAssist = enabled
    end
})

WeaponAssistSection:AddSlider({
    Name = "Assist Box Size (Advanced)",
    Flag = "AssistOffset",
    Min = 0,
    Max = 20,
    Value = 10,
    Precise = 1,

    Callback = function(value)
        Settings.AssistOffset = value
    end
})

WeaponAssistSection:AddDropdown({
    Name = "Assist Target Part",
    Flag = "AssistTargetPart",

    List = {
        "Closest",
        "Torso",
        "Head",
        "HumanoidRootPart"
    },

    Callback = function(option)
        Settings.AssistTargetPart = option
    end
})

-- =========================================================
-- Universal -> Movement
-- =========================================================

local MovementSection =
    UniversalTab:CreateSection("Movement Options")

MovementSection:AddToggle({
    Name = "Use Walk Speed",
    Flag = "UseWalkSpeed",

    Callback = function(enabled)
        Settings.UseWalkSpeed = enabled

        local isAlive, _, hum = GetAliveCharacter(LocalPlayer)

        if isAlive and hum then
            hum.WalkSpeed = enabled and Settings.WalkSpeed or 16
        end
    end
})

MovementSection:AddSlider({
    Name = "Walk Speed",
    Flag = "WalkSpeed",
    Min = 16,
    Max = 100,
    Value = 16,
    Precise = 1,

    Callback = function(value)
        Settings.WalkSpeed = value

        if Settings.UseWalkSpeed then
            local isAlive, _, hum =
                GetAliveCharacter(LocalPlayer)

            if isAlive and hum then
                hum.WalkSpeed = value
            end
        end
    end
})

-- Loop giữ WalkSpeed ổn định
RunService.PostSimulation:Connect(function()
    if Settings.UseWalkSpeed then
        local isAlive, _, hum =
            GetAliveCharacter(LocalPlayer)

        if isAlive
            and hum
            and hum.WalkSpeed ~= Settings.WalkSpeed then

            hum.WalkSpeed = Settings.WalkSpeed
        end
    end
end)

MovementSection:AddToggle({
    Name = "No Jump Cooldown",
    Flag = "NoJumpCooldown",

    Callback = function(enabled)
        Settings.NoJumpCooldown = enabled
    end
})

-- =========================================================
-- Human -> Basic
-- =========================================================

local HumanBasicSection =
    HumanTab:CreateSection("Human Basic Options")

HumanBasicSection:AddToggle({
    Name = "Bypass Barrier",
    Flag = "BarrierBypass",

    Callback = function(enabled)
        Settings.BarrierBypass = enabled

        for _, barrier in ipairs(Workspace:GetDescendants()) do
            if barrier:IsA("BasePart")
                and (
                    barrier.Name:lower():find("barrier")
                    or barrier.Name:lower():find("gate")
                ) then

                barrier.CanCollide = not enabled
            end
        end
    end
})

-- =========================================================
-- Human -> Item Teleports
-- =========================================================

local HumanItemSection =
    HumanTab:CreateSection("Human Item Teleports")

local HumanItems = {
    "Hazmat Suit",
    "Medkit",
    "Katana",
    "Machete",
    "Knife",
    "Brick",
    "Nunchucks",
    "Sledge Hammer",
    "Crowbar",
    "Long Pipe",
    "Bat"
}

for _, itemName in ipairs(HumanItems) do
    HumanItemSection:AddButton({
        Name = itemName,

        Callback = function()
            TeleportToNamedItem(itemName)
        end
    })
end

-- =========================================================
-- Furry -> Basic Options
-- =========================================================

local FurryBasicSection =
    FurryTab:CreateSection("Furry/Goo Basic Options")

FurryBasicSection:AddButton({
    Name = "Kill Yourself NOW!",

    Callback = function()
        local isAlive, _, hum =
            GetAliveCharacter(LocalPlayer)

        if isAlive and hum then
            hum.Health = 0
        end
    end
})

-- =========================================================
-- Door Noclip
-- =========================================================

RunService.Heartbeat:Connect(function()
    if Settings.DoorNoclip then
        for _, door in ipairs(Workspace:GetDescendants()) do
            if door:IsA("BasePart")
                and (
                    door.Name:lower():find("door")
                    or door.Name:lower():find("gate")
                ) then

                door.CanCollide = false
            end
        end
    end
end)
