-- Owner : brotha2
-- Version : V1.5 (Rayfield Gen2 - Numeric Icons & ShowNames Fixed)
-- Game : Those Who Remain

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local Config = {
    ESP_Players  = false,
    ESP_Zombies  = false,
    ShowNames    = true, -- Đã bật sẵn

    Chams_PlayerColor         = Color3.fromRGB(0, 120, 255),
    Chams_ZombieColor         = Color3.fromRGB(255, 40, 40),
    Chams_FillTransparency    = 0.5,
    Chams_OutlineTransparency = 0.1,

    Hitbox_Enabled      = false,
    Hitbox_Size         = 15,
    Hitbox_Transparency = 0.7,
    Hitbox_Color        = Color3.fromRGB(255, 0, 80),

    InfAmmo       = false,

    Fly           = false,
    FlySpeed      = 50,
    Speed         = false,
    SpeedValue    = 40,
    InfiniteJump  = false,

    FullBright    = false,
    AntiAFK       = true,

    AC_Bypass     = false,
}

local FBBackup = {}

-- ── Load Rayfield Gen2 ─────────────────────────────────────────
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Window = Rayfield:CreateWindow({
    Name            = "TWR  |  brotha2  ·  v1.5",
    LoadingTitle    = "Those Who Remain",
    LoadingSubtitle = "v1.5 - Gen2 Edition",
    Theme           = "Default",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "TWR_Config",
        FileName   = "twr_v5", -- Đổi tên file để reset cấu hình, ép ShowNames bật
    },
    KeySystem = false,
})

-- ── Credit bar ─────────────────────────────────────────────────
do
    local pg = LocalPlayer:WaitForChild("PlayerGui")

    local holder = Instance.new("Frame")
    holder.Name = "TWR_Credit"
    holder.Size = UDim2.new(0, 240, 0, 40)
    holder.Position = UDim2.new(1, -256, 1, -52)
    holder.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    holder.BackgroundTransparency = 0.15
    holder.BorderSizePixel = 0
    holder.Parent = pg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = holder

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(95, 155, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = holder
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(Color3.fromRGB(60, 120, 220), Color3.fromRGB(150, 200, 255))
    grad.Rotation = 45
    grad.Parent = stroke

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = holder

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0.55, 0)
    label.Text = "brotha2  ·  TWR v1.5"
    label.TextColor3 = Color3.fromRGB(235, 235, 245)
    label.TextStrokeTransparency = 0.8
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder
    local labelGrad = Instance.new("UIGradient")
    labelGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 200, 255))
    labelGrad.Rotation = 0
    labelGrad.Parent = label

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(1, 0, 0.4, 0)
    sub.Position = UDim2.new(0, 0, 0.55, 0)
    sub.Text = "v1.5  ·  those who remain"
    sub.TextColor3 = Color3.fromRGB(140, 145, 165)
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = holder

    task.spawn(function()
        while holder.Parent do
            TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.15
            }):Play()
            task.wait(2)
            TweenService:Create(stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.55
            }):Play()
            task.wait(2)
        end
    end)
end

-- ── PC keybind ─────────────────────────────────────────────────
do
    local pg = LocalPlayer:WaitForChild("PlayerGui")

    local function toggleUI()
        pcall(function()
            for _, g in ipairs(pg:GetChildren()) do
                local n = g.Name:lower()
                if (n:find("rayfield") or n:find("sirius") or n:find("twr")) and g:IsA("ScreenGui") then
                    g.Enabled = not g.Enabled
                end
            end
        end)
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleUI()
        end
    end)
end

local ESP_UI = Instance.new("ScreenGui")
ESP_UI.Name           = "ESP_UI"
ESP_UI.ResetOnSpawn   = false
ESP_UI.IgnoreGuiInset = true
ESP_UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ESP_UI.Parent         = LocalPlayer:WaitForChild("PlayerGui")

local ZombieList     = {}
local espObjects     = {}
local chamsObjects   = {}
local originalData   = {}
local hitboxOutlines = {}
local networkOwners  = {}
local acActive       = false
local flyBV          = nil
local flyBG          = nil

local chamsPulse = 0
task.spawn(function()
    while true do
        chamsPulse = (math.sin(tick() * 1.5) + 1) / 2
        RunService.Heartbeat:Wait()
    end
end)

local function isPlayer(model)
    if model == LocalPlayer.Character then return true end
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function updateZombieList()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and not isPlayer(obj) then
                list[obj] = true
            end
        end
    end
    ZombieList = list
end

updateZombieList()
task.spawn(function()
    while true do
        task.wait(6)
        updateZombieList()
    end
end)

local function applyChams(model, color, fillTrans, outlineTrans)
    local existing = chamsObjects[model]
    if not (existing and existing.Parent) then
        local highlight = Instance.new("Highlight")
        highlight.Name                = "Chams"
        highlight.Adornee             = model
        highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor           = color
        highlight.OutlineColor        = color
        highlight.FillTransparency    = fillTrans
        highlight.OutlineTransparency = outlineTrans
        highlight.Parent              = model
        chamsObjects[model]           = highlight
        existing = highlight
    end

    local pulseFill    = math.clamp(fillTrans    + chamsPulse * 0.12,       0, 1)
    local pulseOutline = math.clamp(outlineTrans + (1 - chamsPulse) * 0.08, 0, 1)

    existing.FillColor           = color
    existing.OutlineColor        = color
    existing.FillTransparency    = pulseFill
    existing.OutlineTransparency = pulseOutline
end

local function removeChams(model)
    local existing = chamsObjects[model]
    if existing then
        existing:Destroy()
        chamsObjects[model] = nil
    end
end

local function createESP(model, isPlayerTarget)
    if espObjects[model] then return end

    local hrp      = model:FindFirstChild("HumanoidRootPart")
    local head     = model:FindFirstChild("Head")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not hrp or not head or not humanoid then return end

    local accentA = isPlayerTarget and Color3.fromRGB(80, 160, 255)
                                    or Color3.fromRGB(255, 70, 70)
    local accentB = isPlayerTarget and Color3.fromRGB(150, 205, 255)
                                    or Color3.fromRGB(255, 150, 130)

    local objs = {}

    local plate = Instance.new("Frame")
    plate.BackgroundColor3       = Color3.fromRGB(8, 8, 12)
    plate.BackgroundTransparency = 0.1
    plate.BorderSizePixel        = 0
    plate.Visible                = false
    plate.ZIndex                 = 3
    plate.Parent                 = ESP_UI
    local plateCorner = Instance.new("UICorner")
    plateCorner.CornerRadius = UDim.new(0, 4)
    plateCorner.Parent = plate

    local plateStroke = Instance.new("UIStroke")
    plateStroke.Color        = accentA
    plateStroke.Thickness    = 1
    plateStroke.Transparency = 0.35
    plateStroke.Parent       = plate
    local plateGrad = Instance.new("UIGradient")
    plateGrad.Color    = ColorSequence.new(accentA, accentB)
    plateGrad.Rotation = 0
    plateGrad.Parent   = plateStroke

    local platePad = Instance.new("UIPadding")
    platePad.PaddingLeft  = UDim.new(0, 5)
    platePad.PaddingRight = UDim.new(0, 5)
    platePad.Parent       = plate

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                   = model.Name
    nameLabel.TextColor3             = Color3.fromRGB(240, 245, 255)
    nameLabel.TextStrokeTransparency = 0.75
    nameLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    nameLabel.TextScaled             = false
    nameLabel.TextSize               = 11
    nameLabel.Font                   = Enum.Font.GothamBold
    nameLabel.TextXAlignment         = Enum.TextXAlignment.Center
    nameLabel.TextYAlignment         = Enum.TextYAlignment.Center
    nameLabel.Size                   = UDim2.new(1, 0, 1, 0)
    nameLabel.Visible                = false
    nameLabel.Parent                 = plate
    local nameGrad = Instance.new("UIGradient")
    nameGrad.Color    = ColorSequence.new(Color3.fromRGB(255, 255, 255), accentB)
    nameGrad.Rotation = 90
    nameGrad.Parent   = nameLabel

    objs.Plate = plate
    objs.Name  = nameLabel

    espObjects[model] = objs

    model.AncestryChanged:Connect(function(_, parent)
        if not parent then
            for _, o in pairs(objs) do
                if o then o:Destroy() end
            end
            espObjects[model] = nil
        end
    end)
end

local function removeESP(model)
    local objs = espObjects[model]
    if objs then
        for _, o in pairs(objs) do
            if o then o:Destroy() end
        end
        espObjects[model] = nil
    end
end

local function updateESP(model, objs, hrp, head, humanoid)
    if not objs then return end

    if not hrp or not head or not humanoid or humanoid.Health <= 0 then
        if objs.Plate then objs.Plate.Visible = false end
        if objs.Name  then objs.Name.Visible  = false end
        return
    end

    if not Config.ShowNames then
        if objs.Plate then objs.Plate.Visible = false end
        if objs.Name  then objs.Name.Visible  = false end
        return
    end

    local hrpPos = hrp.Position
    local rootVec, rootOn = Camera:WorldToViewportPoint(hrpPos)
    local headVec         = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
    local feetVec         = Camera:WorldToViewportPoint(hrpPos - Vector3.new(0, 3, 0))

    local visible  = rootOn and rootVec.Z > 0 and headVec.Z > 0 and feetVec.Z > 0
    local viewport = Camera.ViewportSize

    if visible then
        local margin = 500
        if headVec.X < -margin or headVec.X > viewport.X + margin
        or headVec.Y < -margin or headVec.Y > viewport.Y + margin then
            visible = false
        end
    end

    if not visible then
        if objs.Plate then objs.Plate.Visible = false end
        if objs.Name  then objs.Name.Visible  = false end
        return
    end

    local topLeft     = Vector2.new(math.min(headVec.X, feetVec.X), math.min(headVec.Y, feetVec.Y))
    local bottomRight = Vector2.new(math.max(headVec.X, feetVec.X), math.max(headVec.Y, feetVec.Y))
    local width       = math.max(bottomRight.X - topLeft.X, 20)
    local centerX     = (topLeft.X + bottomRight.X) / 2

    if objs.Plate and objs.Name then
        objs.Name.Visible = true
        objs.Name.Text    = model.Name

        local textWidth   = objs.Name.TextBounds.X
        local plateWidth  = math.max(width + 8, textWidth + 14, 56)
        local plateHeight = 18

        objs.Plate.Visible  = true
        objs.Plate.Size     = UDim2.fromOffset(plateWidth, plateHeight)
        objs.Plate.Position = UDim2.fromOffset(centerX - plateWidth / 2, topLeft.Y - plateHeight - 5)
    end
end

-- ── Hitbox — head-modifying ────────────────────────────────────
local function applyHitbox(model, size, transparency)
    if not ZombieList[model] then return end
    if isPlayer(model) then return end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local head = model:FindFirstChild("Head")
    if not head then return end

    if not originalData[model] then
        originalData[model] = {
            Size         = head.Size,
            Color        = head.Color,
            Transparency = head.Transparency,
            CanCollide   = head.CanCollide,
            Massless     = head.Massless,
            Material     = head.Material,
        }
    end

    local color = Config.Hitbox_Color
    local alpha = math.clamp(transparency, 0, 1)

    head.Size         = Vector3.new(size, size, size)
    head.Transparency = alpha
    head.Color        = color
    head.Material     = Enum.Material.Neon
    head.CanCollide   = false
    head.Massless     = true

    if not networkOwners[model] then
        pcall(function() head:SetNetworkOwner(LocalPlayer) end)
        networkOwners[model] = true
    end

    local outlineAlpha = math.clamp(alpha + 0.15, 0, 1)

    local box = hitboxOutlines[model]
    if not (box and box.Parent) then
        box = Instance.new("SelectionBox")
        box.Name                = "HitboxOutline"
        box.Adornee             = head
        box.LineThickness       = 0.03
        box.Color3              = color
        box.Transparency        = outlineAlpha
        box.SurfaceColor3       = color
        box.SurfaceTransparency = 1
        box.Parent              = head
        hitboxOutlines[model]   = box
    else
        box.Adornee        = head
        box.Color3         = color
        box.SurfaceColor3  = color
        box.Transparency   = outlineAlpha
    end
end

local function restoreHitbox(model)
    if originalData[model] then
        local head = model:FindFirstChild("Head")
        if head then
            head.Size         = originalData[model].Size
            head.Color        = originalData[model].Color
            head.Transparency = originalData[model].Transparency
            head.CanCollide   = originalData[model].CanCollide
            head.Massless     = originalData[model].Massless
            head.Material     = originalData[model].Material
        end
        originalData[model] = nil
    end
    if hitboxOutlines[model] then
        pcall(function() hitboxOutlines[model]:Destroy() end)
        hitboxOutlines[model] = nil
    end
    networkOwners[model] = nil
end

local function restoreAllHitboxes()
    for model in pairs(originalData) do
        restoreHitbox(model)
    end
    for model, box in pairs(hitboxOutlines) do
        pcall(function() box:Destroy() end)
    end
    hitboxOutlines = {}
    networkOwners  = {}
end

local function setupAmmoHook()
    local success, module = pcall(function()
        return require(LocalPlayer.PlayerScripts.Client.Interact)
    end)
    if not success or not module then return end

    local originalUpdate = module.Update

    module.Update = function(self, ...)
        local args = {...}
        if args[1] and args[1].Equipped then
            local weapon      = args[3][args[1].Equipped]
            local weaponStats = args[1].WeaponModule.Stats
            if weaponStats and weapon then
                if weaponStats.Mag  and Config.InfAmmo then weapon.Mag  = weaponStats.Mag  end
                if weaponStats.Pool and Config.InfAmmo then weapon.Pool = weaponStats.Pool end
            end
        end
        return originalUpdate(self, unpack(args))
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end

    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name     = "FlyBV"
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.P        = 1250
    flyBV.Parent   = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.Name      = "FlyBG"
    flyBG.P         = 9e4
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame    = hrp.CFrame
    flyBG.Parent    = hrp
end

local function stopFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
end

local function updateFly()
    if not Config.Fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    if not flyBV or not flyBV.Parent then
        startFly()
        return
    end

    local cam = workspace.CurrentCamera
    local lookVec  = cam.CFrame.LookVector
    local rightVec = cam.CFrame.RightVector

    local flatLookRaw = Vector3.new(lookVec.X, 0, lookVec.Z)
    local flatLook
    if flatLookRaw.Magnitude < 0.01 then
        flatLook = Vector3.new(0, 0, -1)
    else
        flatLook = flatLookRaw.Unit
    end

    local moveDir = hum.MoveDirection
    local forwardAmt = moveDir:Dot(flatLook)
    local rightAmt   = moveDir:Dot(rightVec)

    local dir = lookVec * forwardAmt + rightVec * rightAmt

    if dir.Magnitude > 0.01 then
        flyBV.Velocity = dir.Unit * Config.FlySpeed
    else
        flyBV.Velocity = Vector3.new(0, 0, 0)
    end

    flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
end

local function applySpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.Fly then return end

    if Config.Speed then
        if hum.WalkSpeed ~= Config.SpeedValue then
            hum.WalkSpeed = Config.SpeedValue
        end
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end
end

local function applyFullBright(state)
    if state then
        FBBackup.OutdoorAmbient = Lighting.OutdoorAmbient
        FBBackup.Ambient        = Lighting.Ambient
        FBBackup.Brightness     = Lighting.Brightness
        FBBackup.ClockTime      = Lighting.ClockTime
        FBBackup.FogEnd         = Lighting.FogEnd
        FBBackup.FogStart       = Lighting.FogStart

        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness     = 3
        Lighting.ClockTime      = 14
        Lighting.FogEnd         = 1e6
        Lighting.FogStart       = 0
    else
        if FBBackup.OutdoorAmbient then
            Lighting.OutdoorAmbient = FBBackup.OutdoorAmbient
            Lighting.Ambient        = FBBackup.Ambient
            Lighting.Brightness     = FBBackup.Brightness
            Lighting.ClockTime      = FBBackup.ClockTime
            Lighting.FogEnd         = FBBackup.FogEnd
            Lighting.FogStart       = FBBackup.FogStart
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if Config.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton1(Vector2.new(0, 0))
            end)
        end
    end
end)

local unloaded = false
local function unloadScript()
    unloaded = true

    pcall(function() restoreAllHitboxes() end)
    pcall(function() stopFly() end)
    pcall(function() applyFullBright(false) end)

    for model in pairs(espObjects) do
        pcall(function() removeESP(model) end)
    end
    for model in pairs(chamsObjects) do
        pcall(function() removeChams(model) end)
    end

    pcall(function() ESP_UI:Destroy() end)

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, g in ipairs(pg:GetChildren()) do
            local n = g.Name:lower()
            if n:find("rayfield") or n:find("twr") or n:find("esp_ui") then
                pcall(function() g:Destroy() end)
            end
        end
    end
end

-- ── Modern AC Bypass ──────────────────────────────────────────
local function enableACBypass()
    if acActive then return end
    acActive = true

    pcall(function() LocalPlayer.Kick = function() end end)

    if hookmetamethod then
        local oldNC
        oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local args = {...}
                if args[1] == "CheatKick" or args[1] == "Kick" or args[1] == "Ban" then
                    return
                end
                for _, arg in ipairs(args) do
                    if type(arg) == "string" then
                        local lower = arg:lower()
                        if lower:find("anticheat") or lower:find("detect")
                        or lower:find("ban")       or lower:find("kick")
                        or lower:find("exploit")   or lower:find("cheat")
                        or lower:find("hack")      or lower:find("report") then
                            return
                        end
                    end
                end
            end
            return oldNC(self, ...)
        end))

        local oldIdx
        oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if self:IsA("Humanoid") then
                if key == "WalkSpeed" and Config.Speed then return 16 end
                if key == "JumpPower" then return 50 end
                if key == "JumpHeight" then return 7.2 end
                if key == "HipHeight" then return 2 end
            end
            return oldIdx(self, key)
        end))
    else
        pcall(function()
            local mt = getrawmetatable(game)
            local oldNC = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local args = {...}
                    if args[1] == "CheatKick" or args[1] == "Kick" or args[1] == "Ban" then return end
                    for _, arg in ipairs(args) do
                        if type(arg) == "string" and arg:lower():find("anticheat") then return end
                    end
                end
                return oldNC(self, ...)
            end)
            setreadonly(mt, true)
        end)
    end

    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") then
            local n = obj.Name:lower()
            if n:find("anti") or n:find("detect") or n:find("guard")
            or n:find("security") or n:find("integrity") or n:find("verify") then
                pcall(function() obj.Disabled = true end)
            end
        end
    end
end

local function disableACBypass()
    acActive = false
end

task.spawn(function()
    task.wait(3)
    setupAmmoHook()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Fly then startFly() end
end)

local frameCounter = 0
RunService.RenderStepped:Connect(function()
    if unloaded then return end

    frameCounter = frameCounter + 1

    if Config.Fly then
        updateFly()
    elseif flyBV then
        stopFly()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    applySpeed()

    local anyHitbox = Config.Hitbox_Enabled

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local model = player.Character

            if Config.ESP_Players then
                local objs = espObjects[model]
                if not objs then createESP(model, true); objs = espObjects[model] end
                if objs then
                    updateESP(model, objs,
                        model:FindFirstChild("HumanoidRootPart"),
                        model:FindFirstChild("Head"),
                        model:FindFirstChildOfClass("Humanoid"))
                end
                applyChams(model, Config.Chams_PlayerColor, Config.Chams_FillTransparency, Config.Chams_OutlineTransparency)
            else
                if espObjects[model] then removeESP(model) end
                if chamsObjects[model] then removeChams(model) end
            end
        end
    end

    for model in pairs(ZombieList) do
        if Config.ESP_Zombies then
            local objs = espObjects[model]
            if not objs then createESP(model, false); objs = espObjects[model] end
            if objs then
                updateESP(model, objs,
                    model:FindFirstChild("HumanoidRootPart"),
                    model:FindFirstChild("Head"),
                    model:FindFirstChildOfClass("Humanoid"))
            end
            applyChams(model, Config.Chams_ZombieColor, Config.Chams_FillTransparency, Config.Chams_OutlineTransparency)
        else
            if espObjects[model] then removeESP(model) end
            if chamsObjects[model] then removeChams(model) end
        end

        if anyHitbox then
            if Config.Hitbox_Enabled then
                applyHitbox(model, Config.Hitbox_Size, Config.Hitbox_Transparency)
            elseif originalData[model] then
                restoreHitbox(model)
            end
        end
    end

    if frameCounter % 30 == 0 then
        for model in pairs(espObjects) do
            if not model.Parent or not model:FindFirstChildOfClass("Humanoid") then
                removeESP(model)
            end
        end
        for model in pairs(chamsObjects) do
            if not model.Parent then
                removeChams(model)
            end
        end
        for model in pairs(hitboxOutlines) do
            if not model.Parent or not model:FindFirstChild("Head") then
                pcall(function() hitboxOutlines[model]:Destroy() end)
                hitboxOutlines[model] = nil
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  TABS (Rayfield Gen2 Numeric Icons & ShowNames Active)
-- ══════════════════════════════════════════════════════════════

local ESPTab = Window:CreateTab({ Name = "ESP", Icon = nil })
ESPTab:CreateSection("Targets")
ESPTab:CreateToggle({Name = "ESP Players", CurrentValue = false, Flag = "ESP_Players", Callback = function(v) Config.ESP_Players = v end})
ESPTab:CreateToggle({Name = "ESP Zombies", CurrentValue = false, Flag = "ESP_Zombies", Callback = function(v) Config.ESP_Zombies = v end})
ESPTab:CreateToggle({Name = "Show Names",  CurrentValue = true,  Flag = "ShowNames",   Callback = function(v) Config.ShowNames = v end})
ESPTab:CreateSection("Style")
ESPTab:CreateColorPicker({Name = "Player Chams Color", Color = Color3.fromRGB(0, 120, 255), Flag = "Chams_PlayerColor", Callback = function(v) Config.Chams_PlayerColor = v end})
ESPTab:CreateColorPicker({Name = "Zombie Chams Color", Color = Color3.fromRGB(255, 40, 40), Flag = "Chams_ZombieColor", Callback = function(v) Config.Chams_ZombieColor = v end})
ESPTab:CreateSlider({Name = "Fill Transparency",    Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0.5, Flag = "Chams_FillTransparency",    Callback = function(v) Config.Chams_FillTransparency    = v end})
ESPTab:CreateSlider({Name = "Outline Transparency", Range = {0, 1}, Increment = 0.05, Suffix = "", CurrentValue = 0.1, Flag = "Chams_OutlineTransparency", Callback = function(v) Config.Chams_OutlineTransparency = v end})

local HitboxTab = Window:CreateTab({ Name = "Hitbox", Icon = nil })
HitboxTab:CreateSection("Zombie Hitbox")
HitboxTab:CreateToggle({Name = "Enable Hitbox", CurrentValue = false, Flag = "Hitbox_Enabled", Callback = function(v) Config.Hitbox_Enabled = v; if not v then restoreAllHitboxes() end end})
HitboxTab:CreateSlider({Name = "Size",         Range = {3, 60}, Increment = 1,    Suffix = " studs", CurrentValue = 15,  Flag = "Hitbox_Size",         Callback = function(v) Config.Hitbox_Size         = v end})
HitboxTab:CreateSlider({Name = "Transparency", Range = {0, 1},  Increment = 0.05, Suffix = "",       CurrentValue = 0.7, Flag = "Hitbox_Transparency", Callback = function(v) Config.Hitbox_Transparency = v end})
HitboxTab:CreateSection("Style")
HitboxTab:CreateColorPicker({Name = "Color", Color = Color3.fromRGB(255, 0, 80), Flag = "Hitbox_Color", Callback = function(v) Config.Hitbox_Color = v end})
HitboxTab:CreateButton({Name = "Restore", Callback = function() restoreAllHitboxes() end})

local WeaponTab = Window:CreateTab({ Name = "Weapon", Icon = nil })
WeaponTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Flag = "InfAmmo", Callback = function(v) Config.InfAmmo = v end})

local MovementTab = Window:CreateTab({ Name = "Movement", Icon = nil })
MovementTab:CreateSection("Fly")
MovementTab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) Config.Fly = v end})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {10, 200}, Increment = 5, Suffix = "", CurrentValue = 50, Flag = "FlySpeed", Callback = function(v) Config.FlySpeed = v end})
MovementTab:CreateSection("Speed")
MovementTab:CreateToggle({Name = "Speed", CurrentValue = false, Flag = "Speed", Callback = function(v) Config.Speed = v end})
MovementTab:CreateSlider({Name = "Speed Value", Range = {16, 100}, Increment = 1, Suffix = "", CurrentValue = 40, Flag = "SpeedValue", Callback = function(v) Config.SpeedValue = v end})
MovementTab:CreateSection("Jump")
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJump", Callback = function(v) Config.InfiniteJump = v end})

local MiscTab = Window:CreateTab({ Name = "Misc", Icon = nil })
MiscTab:CreateSection("Utility")
MiscTab:CreateToggle({Name = "Full Bright", CurrentValue = false, Flag = "FullBright", Callback = function(v)
    Config.FullBright = v
    applyFullBright(v)
end})
MiscTab:CreateToggle({Name = "Anti-AFK", CurrentValue = true, Flag = "AntiAFK", Callback = function(v) Config.AntiAFK = v end})
MiscTab:CreateButton({Name = "Unload Script", Callback = function() unloadScript() end})

MiscTab:CreateSection("Keybinds")
MiscTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Flag = "UI_Toggle",
    Callback = function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, g in ipairs(pg:GetChildren()) do
                local n = g.Name:lower()
                if (n:find("rayfield") or n:find("sirius") or n:find("twr")) and g:IsA("ScreenGui") then
                    g.Enabled = not g.Enabled
                end
            end
        end
    end
})

local ACTab = Window:CreateTab({ Name = "Anti Cheat Bypass", Icon = 4483362458 })
ACTab:CreateToggle({Name = "Enable", CurrentValue = false, Flag = "AC_Bypass", Callback = function(v) Config.AC_Bypass = v; if v then enableACBypass() else disableACBypass() end end})
