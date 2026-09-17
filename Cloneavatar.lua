--[========================================================================[
    AVATAR CHANGER BY KIXDEV (OPTIMIZED FOR DELTA EXECUTOR)
--========================================================================]

local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local core_gui = game:GetService("CoreGui")
local workspace = game:GetService("Workspace")
local user_input_service = game:GetService("UserInputService")
local http_service = game:GetService("HttpService")
local starter_gui = game:GetService("StarterGui")
local local_player = players.LocalPlayer

while not local_player do
    task.wait(0.1)
    local_player = players.LocalPlayer
end

-- Bộ nhớ đệm và quản lý trạng thái
local original_transparencies = {}
local morph_connections = {}
local cached_animations = {}
local visual_tools_map = {}
local current_morph_model = nil
local is_applying_pack = false
local last_applied_pack = ""
local current_custom_emote = nil

-- Cấu hình màu sắc UI
local ui_theme = {
    BG = Color3.fromRGB(18, 18, 22),
    Panel = Color3.fromRGB(28, 28, 34),
    Accent = Color3.fromRGB(80, 140, 255),
    Green = Color3.fromRGB(45, 140, 80),
    Red = Color3.fromRGB(180, 60, 60),
    Text = Color3.fromRGB(230, 230, 230),
    Divider = Color3.fromRGB(50, 50, 60)
}

-- Danh sách các thuộc tính Gui phục vụ serialize
local gui_properties_list = {
    'Size', 'Position', 'AnchorPoint', 'BackgroundColor3', 'BackgroundTransparency',
    'BorderSizePixel', 'BorderColor3', 'ZIndex', 'Visible', 'LayoutOrder', 'Text',
    'TextColor3', 'TextTransparency', 'TextScaled', 'TextSize', 'TextWrapped',
    'TextXAlignment', 'TextYAlignment', 'Font', 'FontFace', 'RichText',
    'TextStrokeTransparency', 'TextStrokeColor3', 'LineHeight', 'Image',
    'ImageColor3', 'ImageTransparency', 'ScaleType', 'SliceCenter',
    'ImageRectOffset', 'ImageRectSize', 'TileSize', 'ExtentsOffset',
    'ExtentsOffsetWorldSpace', 'StudsOffset', 'StudsOffsetWorldSpace',
    'AlwaysOnTop', 'MaxDistance', 'SizeOffset', 'LightInfluence', 'ResetOnSpawn',
    'Active', 'ClipsDescendants', 'Brightness', 'CornerRadius', 'Thickness',
    'Color', 'Transparency', 'Enabled', 'LineJoinMode', 'ApplyStrokeMode',
    'Rotation', 'Offset'
}

-- Cơ sở dữ liệu Animation Packs
local animation_packs = {
    ['Adidas Sports'] = { WalkAnim = 18537392113, RunAnim = 18537384940, JumpAnim = 18537380791, FallAnim = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Animation1 = 18537376492, Animation2 = 18537371272, ClimbAnim = 18537363391 },
    ['Adidas Community'] = { WalkAnim = 122150855457006, RunAnim = 82598234841035, JumpAnim = 75290611992385, FallAnim = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266210, Animation1 = 122257458498460, Animation2 = 102357151005770, ClimbAnim = 88763136693023 },
    ['Adidas Aura'] = { WalkAnim = 83842218823011, RunAnim = 118320322718870, JumpAnim = 109996626521200, FallAnim = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383900, Animation1 = 110211186840350, Animation2 = 114191137265060, ClimbAnim = 97824616490448 },
    ['Wicked Popular'] = { WalkAnim = 92072849924640, RunAnim = 72301599441680, JumpAnim = 104325245285200, FallAnim = 121152442762480, Animation1 = 118832222982049, ClimbAnim = 131326830509780, SwimIdle = 113199415118200, Swim = 99384245425157, Animation2 = 76049494037641 },
    Elder = { WalkAnim = 10921111375, RunAnim = 10921104374, JumpAnim = 10921107367, FallAnim = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, ClimbAnim = 10921100400, Animation1 = 10921101664, Animation2 = 10921102574 },
    Zombie = { WalkAnim = 10921355261, RunAnim = 616163682, JumpAnim = 10921351278, FallAnim = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Animation1 = 10921344533, Animation2 = 10921345304, ClimbAnim = 10921343576 },
    Mage = { WalkAnim = 10921152678, RunAnim = 10921148209, JumpAnim = 10921149743, FallAnim = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, ClimbAnim = 10921143404, Animation1 = 10921144709, Animation2 = 10921145797 },
    ['Catwalk Glam'] = { WalkAnim = 109168724482750, RunAnim = 81024476153754, JumpAnim = 116936326516980, FallAnim = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181630, ClimbAnim = 119377220967550, Animation1 = 133806214992291, Animation2 = 94970088341563 },
    Astronaut = { WalkAnim = 10921046031, RunAnim = 10921039308, JumpAnim = 10921042494, FallAnim = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, ClimbAnim = 10921032124, Animation1 = 10921034824, Animation2 = 10921036806 },
    ['Wicked "Dancing Through Life"'] = { WalkAnim = 73718308412641, RunAnim = 135515454877967, JumpAnim = 78508480717326, FallAnim = 78147885297412, SwimIdle = 129183123083281, Swim = 110657013921770, ClimbAnim = 129447497744820, Animation1 = 92849173543269, Animation2 = 132238900951110 },
    Werewolf = { WalkAnim = 10921342074, RunAnim = 10921336997, JumpAnim = nil, FallAnim = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, ClimbAnim = 10921329322, Animation1 = 10921330408, Animation2 = 10921333667 },
    Superhero = { WalkAnim = 10921298616, RunAnim = 10921291831, JumpAnim = 10921294559, FallAnim = 10921293373, SwimIdle = 10921297391, Swim = 10921295495, ClimbAnim = 10921286911, Animation1 = 10921288909, Animation2 = 10921290167 },
    Toy = { WalkAnim = 10921312010, RunAnim = 10921306285, JumpAnim = 10921308158, FallAnim = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, ClimbAnim = 10921300839, Animation1 = 10921301576, Animation2 = nil },
    ['No Boundaries'] = { WalkAnim = 18747074203, RunAnim = 18747070484, JumpAnim = 18747069148, FallAnim = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, ClimbAnim = 18747060903, Animation1 = 18747067405, Animation2 = 18747063918 },
    NFL = { WalkAnim = 110358958299415, RunAnim = 117333533048080, JumpAnim = 119846112151350, FallAnim = 129773241321030, SwimIdle = 79090109939093, Swim = 132697394189920, ClimbAnim = 134630013742020, Animation1 = 92080889861410, Animation2 = 74451233229259 },
    ['Amazon Unboxed'] = { WalkAnim = 90478085024465, RunAnim = 134824450619860, JumpAnim = 121454505477200, FallAnim = 94788218468396, SwimIdle = 129126268464850, Swim = 105962919001090, ClimbAnim = 121145883950230, Animation1 = 98281136301627, Animation2 = nil },
    Vampire = { WalkAnim = 10921326949, RunAnim = 10921320299, JumpAnim = 10921322186, FallAnim = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, ClimbAnim = 10921314188, Animation1 = 10921315373, Animation2 = nil },
    Ninja = { Run = 656118852, Walk = 656121766, Jump = 656117878, Fall = 656115606, Swim = 656119721, SwimIdle = 656121397, Climb = 656114359, Idle = {656117400, 656118341, 886742569} },
    Robot = { Run = 616091570, Walk = 616095330, Jump = 616090535, Fall = 616087089, Swim = 616092998, SwimIdle = 616094091, Climb = 616086039, Idle = {616088211, 616089559, 885531463} },
    Levitation = { Run = 616010382, Walk = 616013216, Jump = 616008936, Fall = 616005863, Swim = 616011509, SwimIdle = 616012453, Climb = 616003713, Idle = {616006778, 616008087, 886862142} },
    Stylish = { Run = 616140816, Walk = 616146177, Jump = 616139451, Fall = 616134815, Swim = 616143378, SwimIdle = 616144772, Climb = 616133594, Idle = {616136790, 616138447, 886888594} },
    Bubbly = { Run = 910025107, Walk = 910034870, Jump = 910016857, Fall = 910001910, Swim = 910028158, SwimIdle = 910030921, Climb = 909997997, Idle = {910004836, 910009958, 1018536639} },
    Cartoon = { Run = 742638842, Walk = 742640026, Jump = 742637942, Fall = 742637151, Swim = 742639220, SwimIdle = 742639812, Climb = 742636889, Idle = {742637544, 742638445, 885477856} }
}

-- Các hàm tiện ích xử lý Hệ Thống File bảo mật
local function filesystem_available()
    return type(writefile) == "function" and type(readfile) == "function" and (type(isfile) == "function" or type(listfiles) == "function")
end

local function is_file_safe(path)
    if type(isfile) ~= "function" then return false end
    local success, exists = pcall(isfile, path)
    return success and exists == true
end

local function read_file_safe(path)
    if not is_file_safe(path) then return nil end
    local success, content = pcall(readfile, path)
    if success and type(content) == "string" then return content end
    return nil
end

local function write_file_safe(path, data)
    return pcall(writefile, path, data)
end

local function delete_file_safe(path)
    if type(delfile) ~= "function" then return false end
    return pcall(delfile, path)
end

local function list_files_safe(path)
    if type(listfiles) ~= "function" then return {} end
    local success, files = pcall(listfiles, path)
    return (success and type(files) == "table") and files or {}
end

local function sanitize_avatar_name(name)
    local cleaned = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if cleaned == "" then
        cleaned = "Avatar_" .. tostring(os.time())
    end
    return cleaned:gsub('[\\/:*?"<>|]', "_")
end

local function get_avatar_file_path(name)
    return "KIXDEV_AvatarChanger/Avatars/" .. sanitize_avatar_name(name) .. ".json"
end

local function table_to_vector3(t)
    if type(t) ~= "table" then return Vector3.zero end
    return Vector3.new(tonumber(t[1]) or 0, tonumber(t[2]) or 0, tonumber(t[3]) or 0)
end

local function vector3_to_table(v)
    return {v.X, v.Y, v.Z}
end

-- Tối ưu hóa bảo vệ UI cho Delta Executor
local function protect_gui_safe(gui)
    pcall(function()
        if type(protect_gui) == "function" then
            protect_gui(gui)
        elseif type(syn) == "table" and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
end

local function parent_gui_safe(gui)
    local targets = {}
    if typeof(gethui) == "function" then
        local success, hui = pcall(gethui)
        if success and hui then table.insert(targets, hui) end
    end
    table.insert(targets, core_gui)
    
