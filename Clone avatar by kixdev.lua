local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- ====================================================================
-- UTILITY & HELPER FUNCTIONS
-- ====================================================================

local function SanitizeAvatarName(rawName)
    local str = tostring(rawName or "")
    local trimmed = str:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then
        trimmed = "Avatar_" .. tostring(os.time())
    end
    return trimmed:gsub('[\\/:*?"<>|]', "_")
end

local function ListFilesSafe(path)
    if type(listfiles) ~= "function" then
        return {}
    end
    local success, result = pcall(listfiles, path)
    if success and type(result) == "table" then
        return result
    end
    return {}
end

local function DeleteFileSafe(filePath)
    if type(delfile) ~= "function" then
        return false
    end
    return pcall(delfile, filePath)
end

local function IsFileSafe(filePath)
    if type(isfile) ~= "function" then
        return false
    end
    local success, result = pcall(isfile, filePath)
    return success and result == true
end

local function ReadFileSafe(filePath)
    if not IsFileSafe(filePath) then
        return nil
    end
    local success, content = pcall(readfile, filePath)
    if success and type(content) == "string" then
        return content
    end
    return nil
end

local function WriteFileSafe(filePath, content)
    return pcall(writefile, filePath, content)
end

local function GetAvatarFilePath(avatarName)
    return "KIXDEV_AvatarChanger/Avatars/" .. SanitizeAvatarName(avatarName) .. ".json"
end

local function TableToVector3(tbl)
    if type(tbl) ~= "table" then
        return Vector3.zero
    end
    return Vector3.new(tonumber(tbl[1]) or 0, tonumber(tbl[2]) or 0, tonumber(tbl[3]) or 0)
end

local function Vector3ToTable(vec)
    return { vec.X, vec.Y, vec.Z }
end

local function ProtectGuiSafe(gui)
    pcall(function()
        if type(protect_gui) == "function" then
            protect_gui(gui)
        end
    end)
end

local function ParentGuiSafe(gui)
    local targets = {}
    if typeof(gethui) == "function" then
        local success, hui = pcall(gethui)
        if success and hui then
            table.insert(targets, hui)
        end
    end
    table.insert(targets, CoreGui)
    
    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if playerGui then
            table.insert(targets, playerGui)
        end
    end
    
    for _, targetParent in ipairs(targets) do
        if pcall(function() gui.Parent = targetParent end) and gui.Parent == targetParent then
            return true
        end
    end
    return false
end

-- ====================================================================
-- SERIALIZATION & DESERIALIZATION (GUI / HUMANOID DESCRIPTION)
-- ====================================================================

local GUI_PROPERTIES = {
    "Size", "Position", "AnchorPoint", "BackgroundColor3", "BackgroundTransparency",
    "BorderSizePixel", "BorderColor3", "ZIndex", "Visible", "LayoutOrder", "Text",
    "TextColor3", "TextTransparency", "TextScaled", "TextSize", "TextWrapped",
    "TextXAlignment", "TextYAlignment", "Font", "FontFace", "RichText",
    "TextStrokeTransparency", "TextStrokeColor3", "LineHeight", "Image", "ImageColor3",
    "ImageTransparency", "ScaleType", "SliceCenter", "ImageRectOffset", "ImageRectSize",
    "TileSize", "ExtentsOffset", "ExtentsOffsetWorldSpace", "StudsOffset",
    "StudsOffsetWorldSpace", "AlwaysOnTop", "MaxDistance", "SizeOffset", "LightInfluence",
    "ResetOnSpawn", "Active", "ClipsDescendants", "Brightness", "CornerRadius",
    "Thickness", "Color", "Transparency", "Enabled", "LineJoinMode", "ApplyStrokeMode",
    "Rotation", "Offset"
}

local function SerializeGuiInstance(guiObject)
    local data = {
        ClassName = guiObject.ClassName,
        Name = guiObject.Name,
        Properties = {},
        Children = {}
    }

    for _, propName in ipairs(GUI_PROPERTIES) do
        local success, val = pcall(function() return guiObject[propName] end)
        if success and val ~= nil then
            local valType = typeof(val)
            if valType == "Color3" then
                data.Properties[propName] = { Type = "Color3", Value = { val.R, val.G, val.B } }
            elseif valType == "UDim2" then
                data.Properties[propName] = { Type = "UDim2", Value = { val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset } }
            elseif valType == "UDim" then
                data.Properties[propName] = { Type = "UDim", Value = { val.Scale, val.Offset } }
            elseif valType == "Vector3" then
                data.Properties[propName] = { Type = "Vector3", Value = { val.X, val.Y, val.Z } }
            elseif valType == "Vector2" then
                data.Properties[propName] = { Type = "Vector2", Value = { val.X, val.Y } }
            elseif valType == "Rect" then
                data.Properties[propName] = { Type = "Rect", Value = { val.Min.X, val.Min.Y, val.Max.X, val.Max.Y } }
            elseif valType == "EnumItem" then
                data.Properties[propName] = { Type = "EnumItem", EnumType = tostring(val.EnumType), Value = val.Value }
            elseif valType == "ColorSequence" then
                local keypoints = {}
                for _, kp in ipairs(val.Keypoints) do
                    table.insert(keypoints, { Time = kp.Time, Value = { kp.Value.R, kp.Value.G, kp.Value.B } })
                end
                data.Properties[propName] = { Type = "ColorSequence", Value = keypoints }
            elseif valType == "NumberSequence" then
                local keypoints = {}
                for _, kp in ipairs(val.Keypoints) do
                    table.insert(keypoints, { Time = kp.Time, Value = kp.Value, Envelope = kp.Envelope })
                end
                data.Properties[propName] = { Type = "NumberSequence", Value = keypoints }
            elseif valType == "Font" then
                data.Properties[propName] = { Type = "Font", Family = val.Family, Weight = val.Weight.Name, Style = val.Style.Name }
            elseif type(val) == "number" then
                if val == math.huge then
                    data.Properties[propName] = { Type = "Primitive_Huge", Value = "Infinity" }
                elseif val == -math.huge then
                    data.Properties[propName] = { Type = "Primitive_Huge", Value = "-Infinity" }
                elseif val == val then
                    data.Properties[propName] = { Type = "Primitive", Value = val }
                end
            elseif type(val) == "string" or type(val) == "boolean" then
                data.Properties[propName] = { Type = "Primitive", Value = val }
            end
        end
    end

    local successAdornee, adornee = pcall(function() return guiObject.Adornee end)
    if successAdornee and adornee and adornee:IsA("BasePart") then
        data.AdorneeName = adornee.Name
    end

    for _, child in ipairs(guiObject:GetChildren()) do
        table.insert(data.Children, SerializeGuiInstance(child))
    end

    return data
end

local function ApplyDescriptionData(humDesc, descData)
    if not humDesc or type(descData) ~= "table" then return end

    for propName, propValue in pairs(descData) do
        if propName ~= "_LayeredAccessories" then
            pcall(function()
                if type(propValue) == "table" and #propValue == 3 then
                    humDesc[propName] = Color3.new(propValue[1], propValue[2], propValue[3])
                else
                    humDesc[propName] = propValue
                end
            end)
        end
    end

    if type(descData._LayeredAccessories) == "table" and #descData._LayeredAccessories > 0 then
        pcall(function()
            local accList = {}
            for _, acc in ipairs(descData._LayeredAccessories) do
                local item = {}
                if acc.AssetId ~= nil then item.AssetId = acc.AssetId end
                if acc.IsLayered ~= nil then item.IsLayered = acc.IsLayered end
                if acc.Order ~= nil then item.Order = acc.Order end
                if acc.Puffiness ~= nil then item.Puffiness = acc.Puffiness end
                
                if acc.AccessoryType ~= nil then
                    pcall(function()
                        for _, enumItem in ipairs(Enum.AccessoryType:GetEnumItems()) do
                            if enumItem.Value == acc.AccessoryType then
                                item.AccessoryType = enumItem
                                break
                            end
                        end
                    end)
                end
                
                if type(acc.Position) == "table" then item.Position = Vector3.new(acc.Position[1] or 0, acc.Position[2] or 0, acc.Position[3] or 0) end
                if type(acc.Rotation) == "table" then item.Rotation = Vector3.new(acc.Rotation[1] or 0, acc.Rotation[2] or 0, acc.Rotation[3] or 0) end
                if type(acc.Scale) == "table" then item.Scale = Vector3.new(acc.Scale[1] or 0, acc.Scale[2] or 0, acc.Scale[3] or 0) end
                
                table.insert(accList, item)
            end

            if #accList > 0 then
                if not pcall(function() humDesc:SetAccessories(accList, true) end) then
                    local fallbackList = {}
                    for _, acc in ipairs(accList) do
                        table.insert(fallbackList, {
                            AssetId = acc.AssetId,
                            IsLayered = acc.IsLayered,
                            Order = acc.Order,
                            Puffiness = acc.Puffiness,
                            AccessoryType = acc.AccessoryType
                        })
                    end
                    pcall(function() humDesc:SetAccessories(fallbackList, true) end)
                end
            end
        end)
    end
end

-- ====================================================================
-- ANIMATION PACK PRESETS DATA
-- ====================================================================

local ANIMATION_PACKS = {
    ["Adidas Sports"] = { WalkAnim = 18537392113, RunAnim = 18537384940, JumpAnim = 18537380791, FallAnim = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Animation1 = 18537376492, Animation2 = 18537371272, ClimbAnim = 18537363391 },
    ["Adidas Community"] = { WalkAnim = 122150855457006, RunAnim = 82598234841035, JumpAnim = 75290611992385, FallAnim = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266210, Animation1 = 122257458498460, Animation2 = 102357151005770, ClimbAnim = 88763136693023 },
    ["Adidas Aura"] = { WalkAnim = 83842218823011, RunAnim = 118320322718870, JumpAnim = 109996626521200, FallAnim = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383900, Animation1 = 110211186840350, Animation2 = 114191137265060, ClimbAnim = 97824616490448 },
    ["Wicked Popular"] = { WalkAnim = 92072849924640, RunAnim = 72301599441680, JumpAnim = 104325245285200, FallAnim = 121152442762480, Animation1 = 118832222982049, ClimbAnim = 131326830509780, SwimIdle = 113199415118200, Swim = 99384245425157, Animation2 = 76049494037641 },
    Elder = { WalkAnim = 10921111375, RunAnim = 10921104374, JumpAnim = 10921107367, FallAnim = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, ClimbAnim = 10921100400, Animation1 = 10921101664, Animation2 = 10921102574 },
    Zombie = { WalkAnim = 10921355261, RunAnim = 616163682, JumpAnim = 10921351278, FallAnim = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Animation1 = 10921344533, Animation2 = 10921345304, ClimbAnim = 10921343576 },
    Mage = { WalkAnim = 10921152678, RunAnim = 10921148209, JumpAnim = 10921149743, FallAnim = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, ClimbAnim = 10921143404, Animation1 = 10921144709, Animation2 = 10921145797 },
    ["Catwalk Glam"] = { WalkAnim = 109168724482750, RunAnim = 81024476153754, JumpAnim = 116936326516980, FallAnim = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181630, ClimbAnim = 119377220967550, Animation1 = 133806214992291, Animation2 = 94970088341563 },
    Astronaut = { WalkAnim = 10921046031, RunAnim = 10921039308, JumpAnim = 10921042494, FallAnim = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, ClimbAnim = 10921032124, Animation1 = 10921034824, Animation2 = 10921036806 },
    Ninja = { Run = 656118852, Walk = 656121766, Jump = 656117878, Fall = 656115606, Swim = 656119721, SwimIdle = 656121397, Climb = 656114359, Idle = {656117400, 656118341, 886742569} },
    Robot = { Run = 616091570, Walk = 616095330, Jump = 616090535, Fall = 616087089, Swim = 616092998, SwimIdle = 616094091, Climb = 616086039, Idle = {616088211, 616089559, 885531463} },
    Levitation = { Run = 616010382, Walk = 616013216, Jump = 616008936, Fall = 616005863, Swim = 616011509, SwimIdle = 616012453, Climb = 616003713, Idle = {616006778, 616008087, 886862142} },
    Stylish = { Run = 616140816, Walk = 616146177, Jump = 616139451, Fall = 616134815, Swim = 616143378, SwimIdle = 616144772, Climb = 616133594, Idle = {616136790, 616138447, 886888594} },
    Bubbly = { Run = 910025107, Walk = 910034870, Jump = 910016857, Fall = 910001910, Swim = 910028158, SwimIdle = 910030921, Climb = 909997997, Idle = {910004836, 910009958, 1018536639} },
    Cartoon = { Run = 742638842, Walk = 742640026, Jump = 742637942, Fall = 742637151, Swim = 742639220, SwimIdle = 742639812, Climb = 742636889, Idle = {742637544, 742638445, 885477856} },
}

-- ====================================================================
-- ANIMATION SYSTEM HANDLERS
-- ====================================================================

local CachedDefaultAnims = nil
local IsApplyingAnimPack = false

local function FindAnimateScript(character)
    for i = 1, 40 do
        local animScript = character:FindFirstChild("Animate")
        if animScript and animScript:FindFirstChild("idle") and animScript:FindFirstChild("run") and animScript:FindFirstChild("walk") then
            return animScript
        end
        task.wait(0.1)
    end
    return nil
end

local function CacheDefaultAnimations(character)
    local animScript = FindAnimateScript(character)
    if animScript and not CachedDefaultAnims then
        CachedDefaultAnims = {}
        for _, animName in ipairs({"run", "walk", "jump", "fall", "climb", "swim", "swimidle", "idle"}) do
            local folder = animScript:FindFirstChild(animName)
            if folder then
                CachedDefaultAnims[animName] = {}
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Animation") then
                        CachedDefaultAnims[animName][child.Name] = child.AnimationId
                    end
                end
            end
        end
    end
end

if LocalPlayer.Character then
    task.spawn(function() CacheDefaultAnimations(LocalPlayer.Character) end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function() CacheDefaultAnimations(char) end)
    task.wait(0.6)
    local lastPack = LocalPlayer:GetAttribute("AnimPack_Last")
    if type(lastPack) == "string" and lastPack ~= "" and ANIMATION_PACKS[lastPack] then
        -- Tự động khôi phục AnimPack đã chọn sau khi respawn
    end
end)

-- ====================================================================
-- MORPH & SYSTEM CORE
-- ====================================================================

local ActiveMorphModel = nil
local ActiveConnections = {}
local CachedAnimTracks = {}
local FakeToolMap = {}
local OriginalCharacterProperties = {}
local ActiveCustomAnimTrack = nil

local function StopCustomAnimation()
    if ActiveCustomAnimTrack then
        ActiveCustomAnimTrack:Stop()
        ActiveCustomAnimTrack:Destroy()
        ActiveCustomAnimTrack = nil
    end
end

local function HideOriginalCharacter()
    local char = LocalPlayer.Character
    if not char then return end

    OriginalCharacterProperties = {}
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        OriginalCharacterProperties[humanoid] = {
            DisplayDistanceType = humanoid.DisplayDistanceType,
            NameDisplayDistance = humanoid.NameDisplayDistance,
            HealthDisplayDistance = humanoid.HealthDisplayDistance,
        }
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.NameDisplayDistance = 0
        humanoid.HealthDisplayDistance = 0
    end

    for _, obj in ipairs(char:GetDescendants()) do
        if not obj:FindFirstAncestorOfClass("Tool") then
            if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Name ~= "HumanoidRootPart" then
                    OriginalCharacterProperties[obj] = {
                        Transparency = obj.Transparency,
                        CastShadow = obj:IsA("BasePart") and obj.CastShadow or nil
                    }
                    obj.Transparency = 1
                    if obj:IsA("BasePart") then
                        obj.CastShadow = false
                    end
                end
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                OriginalCharacterProperties[obj] = { Enabled = obj.Enabled }
                obj.Enabled = false
            end
        end
    end
end

local function RestoreOriginalCharacter()
    for obj, props in pairs(OriginalCharacterProperties) do
        if obj and obj.Parent then
            for prop, val in pairs(props) do
                pcall(function() obj[prop] = val end)
            end
        end
    end
    OriginalCharacterProperties = {}
end

local function CleanupMorph()
    StopCustomAnimation()
    if ActiveMorphModel then
        ActiveMorphModel:Destroy()
        ActiveMorphModel = nil
    end

    for _, conn in ipairs(ActiveConnections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    
    for _, toolData in pairs(FakeToolMap) do
        if toolData.fakeModel then
            pcall(function() toolData.fakeModel:Destroy() end)
        end
    end

    ActiveConnections = {}
    CachedAnimTracks = {}
    FakeToolMap = {}

    local cam = Workspace.CurrentCamera
    if cam and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
    end

    RestoreOriginalCharacter()
end

local function MorphFromDescription(humDesc, avatarName)
    CleanupMorph()
    HideOriginalCharacter()

    local rigType = Enum.HumanoidRigType.R15
    local char = LocalPlayer.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        rigType = char:FindFirstChildOfClass("Humanoid").RigType
    end

    local success, morphModel = pcall(function()
        return Players:CreateHumanoidModelFromDescription(humDesc, rigType)
    end)

    if not success or not morphModel then
        return false, "Gagal mem-build model avatar!"
    end

    morphModel.Name = "PhantomMorph_" .. avatarName
    morphModel.Parent = Workspace
    ActiveMorphModel = morphModel

    -- Setup Morph Model Core
    local hum = morphModel:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        if not hum:FindFirstChildOfClass("Animator") then
            Instance.new("Animator", hum)
        end
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.CameraSubject = hum
        end
    end

    local hrp = morphModel:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end

    -- Render Loops Sync
    local stepConn = RunService.Stepped:Connect(function()
        if not ActiveMorphModel then return end
        for _, part in ipairs(ActiveMorphModel:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanTouch = false
                part.Massless = true
            end
        end
    end)
    table.insert(ActiveConnections, stepConn)

    return true, "Berhasil morph menjadi " .. avatarName
end

-- API Functions để thao tác
local AvatarChanger = {
    MorphByUser = function(usernameOrId)
        local userId = tonumber(usernameOrId)
        if not userId then
            local success, id = pcall(function() return Players:GetUserIdFromNameAsync(usernameOrId) end)
            if not success or not id then return false, "Username tidak ditemukan!" end
            userId = id
        end

        local successDesc, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
        if not successDesc or not desc then return false, "Gagal mengambil data Avatar." end

        return MorphFromDescription(desc, tostring(usernameOrId))
    end,

    MorphSavedAvatar = function(avatarData)
        local desc = Instance.new("HumanoidDescription")
        if avatarData.descData then ApplyDescriptionData(desc, avatarData.descData) end

        local success, msg = MorphFromDescription(desc, avatarData.name or "SavedAvatar")
        return success, msg
    end,

    Cleanup = CleanupMorph
}

return AvatarChanger
