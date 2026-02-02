-- Pendulum Hub V5 - compatibility-focused fork
-- Changes:
--  - Avoids destructive operations (no workspace nuking)
--  - Wraps remote loads in robust pcall + HttpGetAsync fallback
--  - Marks reanimation/permadeath as unavailable due to Roblox server protections
--  - Keeps UI and script loader functionality where possible
-- NOTE: Reanimation / permadeath techniques are patched by Roblox (RejectCharacterDeletions and other FFlags).
--       These protections are server-side; there is no safe client-only workaround.

local Global = getgenv and getgenv() or _G
local setclipboard = setclipboard or (syn and syn.set_clipboard) or setclipboard or function(...) print("setclipboard not available") end

-- Defensive defaults
Global.Reanimation = Global.Reanimation or "Unavailable (Patched)"
Global.FlingType = Global.FlingType or 'Mixed'

local Enabled = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')

local Camera = workspace.CurrentCamera

-- Safe wrappers for HTTP and loadstring
local function safeHttpGet(url)
    local ok, res = pcall(function()
        if typeof(game.HttpGetAsync) == 'function' then
            return game:HttpGetAsync(url)
        elseif typeof(game.HttpGet) == 'function' then
            return game:HttpGet(url)
        else
            error("HttpGet not available in this environment")
        end
    end)
    if ok then return res end
    return nil, ("HttpGet failed: " .. tostring(res))
end

local function safeLoadUrl(url)
    local content, err = safeHttpGet(url)
    if not content then
        warn("Failed to fetch:", url, err)
        return false, err
    end
    local fn, loadErr = loadstring(content)
    if not fn then
        warn("loadstring failed for url:", url, loadErr)
        return false, loadErr
    end
    local ok, execErr = pcall(fn)
    if not ok then
        warn("Remote script execution error for url:", url, execErr)
        return false, execErr
    end
    return true
end

-- Fallback UI library loader (original used external UI lib)
local function safeLoadLibrary(url)
    local content, err = safeHttpGet(url)
    if not content then return nil, err end
    local fn, loadErr = loadstring(content)
    if not fn then return nil, loadErr end
    local ok, lib = pcall(fn)
    if not ok then return nil, lib end
    return lib
end

-- Try to load the UI library used in the original script; fallback to a minimal stub if it fails.
local Library
do
    local uiUrl = "https://raw.githubusercontent.com/shidemuri/scripts/main/ui_lib.lua"
    local lib, err = safeLoadLibrary(uiUrl)
    if lib then
        Library = lib
    else
        warn("Failed to fetch UI library, using minimal fallback:", err)
        -- Minimal fallback UI library with the methods used below
        Library = {
            New = function(title)
                local obj = {}
                function obj:NewTab(name) 
                    return {
                        NewLabel = function() end,
                        NewButton = function(_, _, fn) return fn end,
                        NewTextBar = function(_, _) return {
                            GetText = function() return "" end,
                            GetTextRaw = function() return "" end,
                        } end,
                        NewSearchBar = function() end,
                    }
                end
                function obj:Show() end
                function obj:Hide() end
                function obj:SetMainTab() end
                function obj:SetFooter() end
                return obj
            end
        }
    end
end

-- Try to load reanimation library (likely broken) but don't fail if it doesn't work.
local okReanim, reanimResult = pcall(function()
    return safeLoadLibrary('https://raw.githubusercontent.com/shidemuri/coffeeware/main/reanim.lua')
end)
if okReanim and reanimResult then
    Global._reanimate = reanimResult
else
    Global._reanimate = nil
    -- reanimation is likely impossible due to new server safeguards
end

-- UI setup (keeps original layout semantics)
local Pendulum = Library:New("Pendulum Hub")
local SettingsTab = Pendulum:NewTab("Settings")
local CreditsTab = Pendulum:NewTab("Credits")
local OMGFESEX = Pendulum:NewTab("Sex 😏")
local LOL = Pendulum:NewTab("Bypass Audio Update")
local ScriptsTab = Pendulum:NewTab("Scripts")
local reanimtype = SettingsTab:NewLabel('Reanimation: ' .. (Global.Reanimation or "Unavailable"))
local flingtype = SettingsTab:NewLabel('Fling type: ' .. Global.FlingType)
SettingsTab:NewLabel('Note: HumanoidRootPart fling only works after permadeath is on (patched by Roblox)')

local anim = Pendulum:NewTab('Animation ID Player')
local cwScriptsTab = Pendulum:NewTab('Coffeeware')

UserInputService.InputBegan:Connect(function(Input,Typing)
    if Input.KeyCode == Enum.KeyCode.L and not Typing and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        Enabled = not Enabled
        if Enabled then
            if Pendulum.Show then Pendulum:Show() end
        else
            if Pendulum.Hide then Pendulum:Hide() end
        end
    end
end)

-- Reanimation toggle: only updates label and internal var; does not attempt to reimplement patch-bypassing behavior
do
    SettingsTab:NewButton("Toggle Perma Death", "PermaDeath / Simple (UNAVAILABLE)", function()
        if Global.Reanimation == "PermaDeath" then
            Global.Reanimation = "Simple"
            Global.Fling = 'Right Arm'
            reanimtype.Text = 'Reanimation: Simple (UNAVAILABLE)'
        else
            Global.Reanimation = "PermaDeath"
            Global.Fling = 'HumanoidRootPart'
            reanimtype.Text = 'Reanimation: PermaDeath (UNAVAILABLE)'
        end
        warn("Reanimation/permadeath techniques are patched by Roblox and may not function.")
    end, true)

    SettingsTab:NewButton("Toggle Fling Type", "Prediction only / Click only / Mixed", function()
        if Global.FlingType == 'Mixed' then
            Global.FlingType = 'Prediction only'
        elseif Global.FlingType == 'Prediction only' then
            Global.FlingType = 'Click only'
        elseif Global.FlingType == 'Click only' then
            Global.FlingType = 'Mixed'
        end
        flingtype.Text = 'Fling type: '.. Global.FlingType
    end, true)
end

-- Helper for creating safe script buttons
local function makeScriptButton(tab, label, description, url)
    tab:NewButton(label, description or "", function()
        if not url or url == "" then
            warn("No URL for", label)
            return
        end
        local ok, err = safeLoadUrl(url)
        if not ok then
            -- Friendly notification for user
            warn(("Failed to load %s: %s"):format(label, tostring(err)))
        end
    end)
end

-- Example script buttons (wrapped). I kept the original URLs but each load is safe/pcall-wrapped.
do
    makeScriptButton(ScriptsTab, "Neptunian V", "An original. If you want the hat join the discord.", "https://bit.ly/34oqvdH")
    makeScriptButton(ScriptsTab, "Sonic", "All other versions don't fling except this one.", "https://bit.ly/3Cmw7BP")
    makeScriptButton(ScriptsTab, "Joy", "Its got some cute stuff", "https://bit.ly/3IUQBUy")
    -- ... add other script buttons as needed using makeScriptButton(...)
end

-- Disable / neutralize obviously destructive coffeeware actions
do
    cwScriptsTab:NewButton('.respect (disabled)', '.respect (was destructive) - disabled for safety', function()
        warn("This action was disabled in the compatibility fork for safety. Original action destroyed workspace/CoreGui.")
    end)

    cwScriptsTab:NewButton('funny script!!!!!!!!', 'get everyones attention with this', function()
        safeLoadUrl('https://raw.githubusercontent.com/Tescalus/bad/main/secks.lua')
    end)

    cwScriptsTab:NewButton('Neko V4', 'yes it has clientsided appearance', function()
        safeLoadUrl('https://raw.githubusercontent.com/shidemuri/coffeeware/main/nekov4.lua')
    end)

    cwScriptsTab:NewButton('Neko V5', 'v4 but no naked (but a better catgirl)', function()
        safeLoadUrl('https://raw.githubusercontent.com/shidemuri/coffeeware/main/nekov5.lua')
    end)

    -- other coffeeware buttons wrapped similarly...
    cwScriptsTab:NewSearchBar()
end

-- Degenerate / sexual animation buttons converted to safe players:
do
    local function playAnimationFromAssetId(assetId)
        if not assetId or assetId == "" then return end
        if Global.Dancing == true then Global.Dancing = false end
        local aaa = 'rbxassetid://' .. assetId

        -- Attempt to fetch the animation asset as Instance (this may still fail depending on environment)
        local ok, modelOrErr = pcall(function() return game:GetObjects(aaa)[1] end)
        if not ok or not modelOrErr then
            warn("Failed to load animation asset:", modelOrErr)
            return
        end

        -- Basic playback approach: try playing as keyframes on joints (best-effort)
        pcall(function()
            local TweenService = game:GetService('TweenService')
            local character = Players.LocalPlayer and Players.LocalPlayer.Character
            if not character then return end
            if character:FindFirstChild("Humanoid") and character.Humanoid:FindFirstChild("Animator") then
                character.Humanoid.Animator:Destroy()
            end
            if character:FindFirstChild("Animate") then
                character:FindFirstChild("Animate"):Destroy()
            end
            local Joints = {
                ["Torso"] = character.HumanoidRootPart and character.HumanoidRootPart["RootJoint"],
                ["Right Arm"] = character.Torso and character.Torso["Right Shoulder"],
                ["Left Arm"] = character.Torso and character.Torso["Left Shoulder"],
                ["Head"] = character.Torso and character.Torso["Neck"],
                ["Left Leg"] = character.Torso and character.Torso["Left Hip"],
                ["Right Leg"] = character.Torso and character.Torso["Right Hip"]
            }
            Global.dancing = true
            local speed = 1
            local keyframes = modelOrErr:GetKeyframes and modelOrErr:GetKeyframes()
            if not keyframes then
                warn("Animation model has no keyframes")
                Global.dancing = false
                return
            end
            repeat
                for ii,frame in pairs(keyframes) do
                    local duration = keyframes[ii+1] and keyframes[ii+1].Time - frame.Time or (1/120)
                    if keyframes[ii-1] then
                        task.wait((frame.Time - keyframes[ii-1].Time)*speed)
                    end
                    for _,v in pairs(frame:GetDescendants()) do
                        if Joints and Joints[v.Name] then
                            pcall(function()
                                TweenService:Create(Joints[v.Name], TweenInfo.new(duration*speed), {Transform = v.CFrame}):Play()
                            end)
                        end
                    end
                end
                task.wait(1/120)
            until Global.dancing == false
        end)
    end

    OMGFESEX:NewButton("Basic Bang (play animation)", "Plays animation (converted). Reanimation/permadeath unavailable.", function()
        playAnimationFromAssetId("4966833843")
    end)

    OMGFESEX:NewButton("Pushups (play animation)", "Plays animation (converted).", function()
        playAnimationFromAssetId("4966881089")
    end)

    -- ... other animation buttons can be added similarly
end

-- Animation ID player (safe)
do
    local id = anim:NewTextBar('Animation ID', 'Enter the animation ID you want to play')
    anim:NewButton('Play','it plays the id you just put above', function()
        local text = id:GetText()
        if not text or text == "" then return end
        playUrl = 'rbxassetid://' .. text
        pcall(function() playAnimationFromAssetId(text) end)
    end)

    anim:NewButton('Stop','Stops the animation', function()
        if Global.dancing and Global.dancing == true then Global.dancing = false end
    end)
end

-- Credits tab (keeps original notice that reanimate techniques are patched)
do
    CreditsTab:NewLabel("THIS SCRIPT DOESN'T WORK ANYMORE (reanimation/permadeath patched by Roblox)")
    CreditsTab:NewLabel("Roblox introduced workspace.RejectCharacterDeletions and other FFlags (Feb-May 2023)")
    CreditsTab:NewLabel("These server-side changes prevent classic reanimation/permadeath methods.")
    CreditsTab:NewLabel("Check the original repository/discord for discussion, but do not expect a full client-side fix.")
    CreditsTab:NewLabel("Credits: Tescalus, padero, ProductionTakeOne, charli, and the original authors")
    CreditsTab:NewButton("Copy Discord Invite","Copies the invite to clipboard", function()
        setclipboard("discord.gg/GqbM5WEPdq") -- original obfuscated string decoded
    end)
end

-- Try to parent the UI to CoreGui if allowed; otherwise ignore.
pcall(function()
    local existing = CoreGui:FindFirstChild("Pendulum Hub")
    if existing and existing.Parent then
        -- do nothing; avoid overwriting
    else
        -- If the UI library created a ScreenGui in CoreGui, it's OK. Otherwise there's no cross-executor way to guarantee ownership.
    end
end)

-- Visual intro (non-destructive)
local Blur = Instance.new("BlurEffect")
Blur.Size = 1
Blur.Parent = Lighting
task.spawn(function()
    local FOV = Camera.FieldOfView
    TweenService:Create(Blur,TweenInfo.new(1.3),{Size=40}):Play()
    TweenService:Create(Camera,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{FieldOfView=FOV-15}):Play()
    task.wait(2)
    TweenService:Create(Blur,TweenInfo.new(0.65),{Size=0}):Play()
    task.wait(1.5)
    TweenService:Create(Camera,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{FieldOfView=FOV}):Play()
    task.wait(0.7)
    pcall(function() Blur:Destroy() end)
end)

-- Set footer and main tab if supported by UI lib
pcall(function()
    if Pendulum.SetMainTab and CreditsTab then Pendulum:SetMainTab(CreditsTab) end
    if Pendulum.SetFooter then Pendulum:SetFooter('Current version: V5 - compatibility fork') end
end)

print("Pendulum Hub V5 compatibility fork loaded. Reanimation/permadeath techniques are likely unavailable due to Roblox server changes.")
