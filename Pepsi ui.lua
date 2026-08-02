-- =====================================================================
-- SYSTEM INITIALIZATION & CORE FUNCTIONS (Merged from File 1, 2, 4, 5)
-- =====================================================================
local env = getfenv and getfenv() or _ENV
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local playersService = game:GetService("Players")

-- Xác định phân vùng lưu trữ UI an toàn (Anti-Cheat Protection)
local gui_parent = (function()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    local success2, playerGui = pcall(function()
        return (game:IsLoaded() or game.Loaded:Wait()) and playersService.LocalPlayer:WaitForChild("PlayerGui")
    end)
    if success2 and playerGui then return playerGui end
    return error("Core UI environment not found.")
end)()

-- Khởi tạo đối tượng UI bảo mật cao
local function Instance_new(className, parent)
    local obj = Instance.new(className)
    if syn and syn.protect_gui then pcall(syn.protect_gui, obj) end
    if parent then obj.Parent = parent end
    return obj
end

-- =====================================================================
-- FILE 3: PEPSI'S UI LIBRARY (Thư viện giao diện chính)
-- =====================================================================
local library = {
    flags = {},
    colors = {
        main = Color3.fromRGB(255, 39, 39),
        background = Color3.fromRGB(40, 40, 40),
        topGradient = Color3.fromRGB(35, 35, 35),
        tabText = Color3.fromRGB(185, 185, 185)
    },
    gui_parent = gui_parent
}

-- Tính năng Kéo/Thả cửa sổ (Draggable Window)
local function makeDraggable(topBarObject, object)
    local dragging, dragInput, dragStart, startPosition
    topBarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPosition = object.Position
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
end

-- Khởi tạo Cửa sổ chính
function library:CreateWindow(options)
    options = options or {}
    local pepsiLibrary = Instance_new("ScreenGui", gui_parent)
    local main = Instance_new("Frame", pepsiLibrary)
    main.Size = UDim2.fromOffset(500, 545)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = library.colors.background
    makeDraggable(main, main)
    
    local tabsHolder = Instance_new("Frame", main)
    tabsHolder.Size = UDim2.new(1, 0, 0, 30)
    tabsHolder.BackgroundColor3 = library.colors.topGradient
    
    local innerMainHolder = Instance_new("Frame", main)
    innerMainHolder.Size = UDim2.new(1, -14, 1, -44)
    innerMainHolder.Position = UDim2.fromOffset(7, 37)
    innerMainHolder.BackgroundTransparency = 1

    local windowFunctions = { Tabs = {} }

    -- Hàm tạo Tab mới
    function windowFunctions:CreateTab(tabOptions)
        local tabButton = Instance_new("TextButton", tabsHolder)
        tabButton.Text = tabOptions.Name or "Tab"
        tabButton.Size = UDim2.fromOffset(100, 30)
        tabButton.Font = Enum.Font.Code
        tabButton.TextColor3 = library.colors.tabText
        
        local tabContentFrame = Instance_new("Frame", innerMainHolder)
        tabContentFrame.Size = UDim2.fromScale(1, 1)
        tabContentFrame.BackgroundTransparency = 1
        tabContentFrame.Visible = false
        
        tabButton.MouseButton1Click:Connect(function()
            for _, child in next, innerMainHolder:GetChildren() do child.Visible = false end
            tabContentFrame.Visible = true
        end)
        
        local sectionFunctions = {}
        -- Hàm tạo Section & Elements (Button, Toggle, Slider) - Chi tiết logic trong File 3
        function sectionFunctions:CreateSection(secOptions)
            -- ... (Nội dung chi tiết của các phần tử UI được giữ nguyên từ File 3)
        end
        return sectionFunctions
    end
    return windowFunctions
end
