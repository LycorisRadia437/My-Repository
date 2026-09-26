local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse() or nil

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Theme = {
    topGradient = Color3.fromRGB(35, 35, 35),
    bottomGradient = Color3.fromRGB(29, 29, 29),
    background = Color3.fromRGB(40, 40, 40),
    sectionBackground = Color3.fromRGB(35, 34, 34),
    outerBorder = Color3.fromRGB(15, 15, 15),
    innerBorder = Color3.fromRGB(0, 64, 115),
    elementBorder = Color3.fromRGB(20, 20, 20),
    main = Color3.fromRGB(2, 94, 163),
    section = Color3.fromRGB(176, 175, 176),
    tabText = Color3.fromRGB(185, 185, 185),
    elementText = Color3.fromRGB(147, 145, 147),
    otherElementText = Color3.fromRGB(129, 127, 129),
    selectedOption = Color3.fromRGB(55, 55, 55),
    unselectedOption = Color3.fromRGB(40, 40, 40),
    hoveredOptionTop = Color3.fromRGB(65, 65, 65),
    hoveredOptionBottom = Color3.fromRGB(45, 45, 45),
    unhoveredOptionTop = Color3.fromRGB(50, 50, 50),
    unhoveredOptionBottom = Color3.fromRGB(35, 35, 35),
    ImageAssetID = "rbxassetid://17487536571",
    ImageColor = Color3.fromRGB(255, 255, 255),
    ImageTransparency = 0.8,
    UseBackgroundImage = true,
    ShowHideKey = Enum.KeyCode.KeypadMinus
}

local TargetParent = nil
local success, result = pcall(function()
    return CoreGui
end)

if success and result then
    TargetParent = result
elseif LocalPlayer then
    TargetParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local Flags = {}
local Library = {}
Library.Flags = Flags

-- [ TẠO GIAO DIỆN CHÍNH ] --
local NeptuneGui = Instance.new("ScreenGui")
NeptuneGui.Name = "Neptune"
NeptuneGui.ResetOnSpawn = false
pcall(function()
    NeptuneGui.Parent = TargetParent
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 380)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
MainFrame.BackgroundColor3 = Theme.background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = NeptuneGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.innerBorder
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Theme.topGradient
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Neptune"
TitleLabel.TextColor3 = Theme.tabText
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- [ CHỨC NĂNG KÉO THẢ (DRAG) ] --
do
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
        end
    end)
end

-- [ KHUNG BỐ CỤC CHÍNH ] --
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 130, 1, -32)
SideBar.Position = UDim2.new(0, 0, 0, 32)
SideBar.BackgroundColor3 = Theme.bottomGradient
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideBarLayout = Instance.new("UIListLayout")
SideBarLayout.FillDirection = Enum.FillDirection.Vertical
SideBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideBarLayout.Padding = UDim.new(0, 4)
SideBarLayout.Parent = SideBar

local SideBarPadding = Instance.new("UIPadding")
SideBarPadding.PaddingTop = UDim.new(0, 8)
SideBarPadding.PaddingLeft = UDim.new(0, 8)
SideBarPadding.PaddingRight = UDim.new(0, 8)
SideBarPadding.Parent = SideBar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -130, 1, -32)
ContentArea.Position = UDim2.new(0, 130, 0, 32)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local TabsList = {}
local CurrentTab = nil

-- [ HÀM TẠO TAB ] --
function Library:CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName or "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 28)
    TabButton.BackgroundColor3 = Theme.unselectedOption
    TabButton.BorderSizePixel = 0
    TabButton.Text = tabName or "Tab"
    TabButton.TextColor3 = Theme.otherElementText
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.Parent = SideBar

    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 4)
    TabButtonCorner.Parent = TabButton

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = (tabName or "Tab") .. "_Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.BorderSizePixel = 0
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = Theme.main
    TabPage.Visible = false
    TabPage.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.FillDirection = Enum.FillDirection.Vertical
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = TabPage

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 10)
    PagePadding.PaddingRight = UDim.new(0, 10)
    PagePadding.PaddingBottom = UDim.new(0, 10)
    PagePadding.Parent = TabPage

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
    end)

    local function SwitchTab()
        for _, tabInfo in ipairs(TabsList) do
            tabInfo.Button.BackgroundColor3 = Theme.unselectedOption
            tabInfo.Button.TextColor3 = Theme.otherElementText
            tabInfo.Page.Visible = false
        end
        TabButton.BackgroundColor3 = Theme.main
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabPage.Visible = true
        CurrentTab = TabPage
    end

    TabButton.MouseButton1Click:Connect(SwitchTab)

    local tabData = {
        Button = TabButton,
        Page = TabPage
    }
    table.insert(TabsList, tabData)

    if #TabsList == 1 then
        SwitchTab()
    end

    local TabObject = {}

    -- [ HÀM TẠO SECTION ] --
    function TabObject:CreateSection(sectionName)
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = (sectionName or "Section") .. "_Section"
        SectionFrame.Size = UDim2.new(1, 0, 0, 32)
        SectionFrame.BackgroundColor3 = Theme.sectionBackground
        SectionFrame.BorderSizePixel = 0
        SectionFrame.Parent = TabPage

        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 4)
        SectionCorner.Parent = SectionFrame

        local SectionStroke = Instance.new("UIStroke")
        SectionStroke.Color = Theme.elementBorder
        SectionStroke.Thickness = 1
        SectionStroke.Parent = SectionFrame

        local SectionHeader = Instance.new("TextLabel")
        SectionHeader.Name = "Header"
        SectionHeader.Size = UDim2.new(1, -16, 0, 24)
        SectionHeader.Position = UDim2.new(0, 8, 0, 4)
        SectionHeader.BackgroundTransparency = 1
        SectionHeader.Text = sectionName or "Section"
        SectionHeader.TextColor3 = Theme.section
        SectionHeader.TextSize = 13
        SectionHeader.Font = Enum.Font.GothamBold
        SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        SectionHeader.Parent = SectionFrame

        local SectionContainer = Instance.new("Frame")
        SectionContainer.Name = "Container"
        SectionContainer.Size = UDim2.new(1, -16, 0, 0)
        SectionContainer.Position = UDim2.new(0, 8, 0, 28)
        SectionContainer.BackgroundTransparency = 1
        SectionContainer.Parent = SectionFrame

        local ContainerLayout = Instance.new("UIListLayout")
        ContainerLayout.FillDirection = Enum.FillDirection.Vertical
        ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerLayout.Padding = UDim.new(0, 6)
        ContainerLayout.Parent = SectionContainer

        ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionContainer.Size = UDim2.new(1, -16, 0, ContainerLayout.AbsoluteContentSize.Y)
            SectionFrame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 36)
        end)

        local SectionElements = {}

        -- [ THÊM TOGGLE ] --
        function SectionElements:AddToggle(options)
            local opts = options or {}
            local toggleName = opts.Name or "Toggle"
            local flagName = opts.Flag or nil
            local defaultState = opts.Default or false
            local callbackFunc = opts.Callback or function() end
            local currentState = defaultState

            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = toggleName .. "_Toggle"
            ToggleButton.Size = UDim2.new(1, 0, 0, 28)
            ToggleButton.BackgroundColor3 = Theme.unselectedOption
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = SectionContainer

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleButton

            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.Name = "Title"
            ToggleTitle.Size = UDim2.new(1, -50, 1, 0)
            ToggleTitle.Position = UDim2.new(0, 8, 0, 0)
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Text = toggleName
            ToggleTitle.TextColor3 = Theme.elementText
            ToggleTitle.TextSize = 12
            ToggleTitle.Font = Enum.Font.GothamMedium
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.Parent = ToggleButton

            local Indicator = Instance.new("Frame")
            Indicator.Name = "Indicator"
            Indicator.Size = UDim2.new(0, 34, 0, 18)
            Indicator.Position = UDim2.new(1, -42, 0.5, -9)
            Indicator.BackgroundColor3 = currentState and Theme.main or Theme.outerBorder
            Indicator.BorderSizePixel = 0
            Indicator.Parent = ToggleButton

            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = Indicator

            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = currentState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.Parent = Indicator

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob

            local function SetState(newState)
                currentState = newState
                if flagName then
                    Flags[flagName] = currentState
                end
                local targetPos = currentState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetColor = currentState and Theme.main or Theme.outerBorder
                TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = targetPos }):Play()
                TweenService:Create(Indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = targetColor }):Play()
                task.spawn(callbackFunc, currentState)
            end

            ToggleButton.MouseButton1Click:Connect(function()
                SetState(not currentState)
            end)

            if flagName then
                Flags[flagName] = currentState
            end

            return {
                Set = function(self, value)
                    SetState(value)
                end
            }
        end

        -- [ THÊM SLIDER ] --
        function SectionElements:AddSlider(options)
            local opts = options or {}
            local sliderName = opts.Name or "Slider"
            local minVal = opts.Min or 0
            local maxVal = opts.Max or 100
            local defaultVal = opts.Default or minVal
            local flagName = opts.Flag or nil
            local callbackFunc = opts.Callback or function() end
            local currentValue = math.clamp(defaultVal, minVal, maxVal)

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderName .. "_Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, 42)
            SliderFrame.BackgroundColor3 = Theme.unselectedOption
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = SectionContainer

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame

            local SliderTitle = Instance.new("TextLabel")
            SliderTitle.Name = "Title"
            SliderTitle.Size = UDim2.new(1, -60, 0, 20)
            SliderTitle.Position = UDim2.new(0, 8, 0, 2)
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Text = sliderName
            SliderTitle.TextColor3 = Theme.elementText
            SliderTitle.TextSize = 12
            SliderTitle.Font = Enum.Font.GothamMedium
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
            SliderTitle.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "Value"
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -58, 0, 2)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(currentValue)
            ValueLabel.TextColor3 = Theme.otherElementText
            ValueLabel.TextSize = 12
            ValueLabel.Font = Enum.Font.GothamMedium
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "Bar"
            SliderBar.Size = UDim2.new(1, -16, 0, 8)
            SliderBar.Position = UDim2.new(0, 8, 0, 26)
            SliderBar.BackgroundColor3 = Theme.outerBorder
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame

            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = SliderBar

            local fillPercent = (currentValue - minVal) / (maxVal - minVal)
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.main
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = SliderFill

            local function UpdateSlider(newValue)
                local clampedVal = math.clamp(newValue, minVal, maxVal)
                currentValue = clampedVal
                if flagName then
                    Flags[flagName] = currentValue
                end
                ValueLabel.Text = tostring(math.floor(currentValue * 100) / 100)
                local percent = (currentValue - minVal) / (maxVal - minVal)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                task.spawn(callbackFunc, currentValue)
            end

            local DraggingSlider = false
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingSlider = true
                    local percent = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    UpdateSlider(minVal + (maxVal - minVal) * percent)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingSlider = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if DraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local percent = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    UpdateSlider(minVal + (maxVal - minVal) * percent)
                end
            end)

            if flagName then
                Flags[flagName] = currentValue
            end

            return {
                Set = function(self, value)
                    UpdateSlider(value)
                end
            }
        end

        -- [ THÊM NÚT BẤM (BUTTON) ] --
        function SectionElements:AddButton(options)
            local opts = options or {}
            local buttonName = opts.Name or "Button"
            local callbackFunc = opts.Callback or function() end

            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = buttonName .. "_Button"
            ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
            ButtonFrame.BackgroundColor3 = Theme.unselectedOption
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Text = buttonName
            ButtonFrame.TextColor3 = Theme.elementText
            ButtonFrame.TextSize = 12
            ButtonFrame.Font = Enum.Font.GothamMedium
            ButtonFrame.Parent = SectionContainer

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = ButtonFrame

            ButtonFrame.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.15), { BackgroundColor3 = Theme.hoveredOptionTop }):Play()
            end)

            ButtonFrame.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.15), { BackgroundColor3 = Theme.unselectedOption }):Play()
            end)

            ButtonFrame.MouseButton1Click:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), { BackgroundColor3 = Theme.main }):Play()
                task.delay(0.1, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), { BackgroundColor3 = Theme.unselectedOption }):Play()
                end)
                task.spawn(callbackFunc)
            end)
        end

        -- [ THÊM DROPDOWN ] --
        function SectionElements:AddDropdown(options)
            local opts = options or {}
            local dropdownName = opts.Name or "Dropdown"
            local listOptions = opts.Options or {}
            local defaultVal = opts.Default or listOptions[1] or ""
            local flagName = opts.Flag or nil
            local callbackFunc = opts.Callback or function() end
            local currentSelection = defaultVal
            local isOpen = false

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = dropdownName .. "_Dropdown"
            DropdownFrame.Size = UDim2.new(1, 0, 0, 28)
            DropdownFrame.BackgroundColor3 = Theme.unselectedOption
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = SectionContainer

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 4)
            DropdownCorner.Parent = DropdownFrame

            local TriggerButton = Instance.new("TextButton")
            TriggerButton.Name = "Trigger"
            TriggerButton.Size = UDim2.new(1, 0, 0, 28)
            TriggerButton.BackgroundTransparency = 1
            TriggerButton.Text = ""
            TriggerButton.Parent = DropdownFrame

            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Name = "Title"
            DropdownTitle.Size = UDim2.new(0.5, 0, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 8, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = dropdownName
            DropdownTitle.TextColor3 = Theme.elementText
            DropdownTitle.TextSize = 12
            DropdownTitle.Font = Enum.Font.GothamMedium
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = TriggerButton

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Name = "Selected"
            SelectedLabel.Size = UDim2.new(0.5, -20, 1, 0)
            SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = tostring(currentSelection)
            SelectedLabel.TextColor3 = Theme.otherElementText
            SelectedLabel.TextSize = 12
            SelectedLabel.Font = Enum.Font.GothamMedium
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.Parent = TriggerButton

            local DropdownList = Instance.new("Frame")
            DropdownList.Name = "List"
            DropdownList.Size = UDim2.new(1, -16, 0, 0)
            DropdownList.Position = UDim2.new(0, 8, 0, 32)
            DropdownList.BackgroundTransparency = 1
            DropdownList.Parent = DropdownFrame

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.FillDirection = Enum.FillDirection.Vertical
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 4)
            ListLayout.Parent = DropdownList

            local function SelectOption(option)
                currentSelection = option
                if flagName then
                    Flags[flagName] = currentSelection
                end
                SelectedLabel.Text = tostring(currentSelection)
                task.spawn(callbackFunc, currentSelection)
            end

            local function RefreshOptions()
                for _, child in ipairs(DropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                for _, option in ipairs(listOptions) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = tostring(option)
                    OptionButton.Size = UDim2.new(1, 0, 0, 24)
                    OptionButton.BackgroundColor3 = (option == currentSelection) and Theme.main or Theme.sectionBackground
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = tostring(option)
                    OptionButton.TextColor3 = Theme.elementText
                    OptionButton.TextSize = 12
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.Parent = DropdownList

                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 3)
                    OptionCorner.Parent = OptionButton

                    OptionButton.MouseButton1Click:Connect(function()
                        SelectOption(option)
                        isOpen = false
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 28) }):Play()
                    end)
                end
            end

            RefreshOptions()

            TriggerButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetSize = isOpen and (36 + #listOptions * 28) or 28
                TweenService:Create(DropdownFrame, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, targetSize) }):Play()
            end)

            if flagName then
                Flags[flagName] = currentSelection
            end

            return {
                Set = function(self, value)
                    SelectOption(value)
                end,
                Refresh = function(self, newList)
                    listOptions = newList or {}
                    RefreshOptions()
                end
            }
        end

        -- [ THÊM CHỌN MÀU (COLOR PICKER) ] --
        function SectionElements:AddColorPicker(options)
            local opts = options or {}
            local pickerName = opts.Name or "ColorPicker"
            local defaultColor = opts.Default or Color3.fromRGB(255, 255, 255)
            local flagName = opts.Flag or nil
            local callbackFunc = opts.Callback or function() end
            local currentColor = defaultColor

            local PickerFrame = Instance.new("Frame")
            PickerFrame.Name = pickerName .. "_ColorPicker"
            PickerFrame.Size = UDim2.new(1, 0, 0, 28)
            PickerFrame.BackgroundColor3 = Theme.unselectedOption
            PickerFrame.BorderSizePixel = 0
            PickerFrame.Parent = SectionContainer

            local PickerCorner = Instance.new("UICorner")
            PickerCorner.CornerRadius = UDim.new(0, 4)
            PickerCorner.Parent = PickerFrame

            local PickerTitle = Instance.new("TextLabel")
            PickerTitle.Name = "Title"
            PickerTitle.Size = UDim2.new(1, -40, 1, 0)
            PickerTitle.Position = UDim2.new(0, 8, 0, 0)
            PickerTitle.BackgroundTransparency = 1
            PickerTitle.Text = pickerName
            PickerTitle.TextColor3 = Theme.elementText
            PickerTitle.TextSize = 12
            PickerTitle.Font = Enum.Font.GothamMedium
            PickerTitle.TextXAlignment = Enum.TextXAlignment.Left
            PickerTitle.Parent = PickerFrame

            local ColorPreview = Instance.new("TextButton")
            ColorPreview.Name = "ColorPreview"
            ColorPreview.Size = UDim2.new(0, 24, 0, 16)
            ColorPreview.Position = UDim2.new(1, -32, 0.5, -8)
            ColorPreview.BackgroundColor3 = currentColor
            ColorPreview.BorderSizePixel = 0
            ColorPreview.Text = ""
            ColorPreview.Parent = PickerFrame

            local PreviewCorner = Instance.new("UICorner")
            PreviewCorner.CornerRadius = UDim.new(0, 3)
            PreviewCorner.Parent = ColorPreview

            local function SetColor(newColor)
                currentColor = newColor
                if flagName then
                    Flags[flagName] = currentColor
                end
                ColorPreview.BackgroundColor3 = currentColor
                task.spawn(callbackFunc, currentColor)
            end

            if flagName then
                Flags[flagName] = currentColor
            end

            return {
                Set = function(self, value)
                    SetColor(value)
                end
            }
        end

        return SectionElements
    end

    return TabObject
end

-- [ TẠO THÔNG BÁO (NOTIFICATION) ] --
function Library:CreateNotification(options)
    local opts = options or {}
    local title = opts.Title or "Notification"
    local content = opts.Content or ""
    local duration = opts.Duration or 3

    local NotificationArea = NeptuneGui:FindFirstChild("NotificationArea")
    if not NotificationArea then
        NotificationArea = Instance.new("Frame")
        NotificationArea.Name = "NotificationArea"
        NotificationArea.Size = UDim2.new(0, 260, 1, -20)
        NotificationArea.Position = UDim2.new(1, -270, 0, 10)
        NotificationArea.BackgroundTransparency = 1
        NotificationArea.Parent = NeptuneGui

        local NotifLayout = Instance.new("UIListLayout")
        NotifLayout.FillDirection = Enum.FillDirection.Vertical
        NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NotifLayout.Padding = UDim.new(0, 6)
        NotifLayout.Parent = NotificationArea
    end

    local ToastFrame = Instance.new("Frame")
    ToastFrame.Name = "Toast"
    ToastFrame.Size = UDim2.new(1, 0, 0, 56)
    ToastFrame.Position = UDim2.new(1, 280, 0, 0)
    ToastFrame.BackgroundColor3 = Theme.background
    ToastFrame.BorderSizePixel = 0
    ToastFrame.Parent = NotificationArea

    local ToastCorner = Instance.new("UICorner")
    ToastCorner.CornerRadius = UDim.new(0, 4)
    ToastCorner.Parent = ToastFrame

    local ToastStroke = Instance.new("UIStroke")
    ToastStroke.Color = Theme.main
    ToastStroke.Thickness = 1
    ToastStroke.Parent = ToastFrame

    local ToastTitle = Instance.new("TextLabel")
    ToastTitle.Name = "ToastTitle"
    ToastTitle.Size = UDim2.new(1, -16, 0, 20)
    ToastTitle.Position = UDim2.new(0, 8, 0, 4)
    ToastTitle.BackgroundTransparency = 1
    ToastTitle.Text = title
    ToastTitle.TextColor3 = Theme.tabText
    ToastTitle.TextSize = 13
    ToastTitle.Font = Enum.Font.GothamBold
    ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
    ToastTitle.Parent = ToastFrame

    local ToastContent = Instance.new("TextLabel")
    ToastContent.Name = "ToastContent"
    ToastContent.Size = UDim2.new(1, -16, 0, 26)
    ToastContent.Position = UDim2.new(0, 8, 0, 24)
    ToastContent.BackgroundTransparency = 1
    ToastContent.Text = content
    ToastContent.TextColor3 = Theme.elementText
    ToastContent.TextSize = 11
    ToastContent.Font = Enum.Font.Gotham
    ToastContent.TextWrapped = true
    ToastContent.TextXAlignment = Enum.TextXAlignment.Left
    ToastContent.Parent = ToastFrame

    TweenService:Create(ToastFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()

    task.delay(duration, function()
        local TweenOut = TweenService:Create(ToastFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 280, 0, 0) })
        TweenOut:Play()
        TweenOut.Completed:Connect(function()
            ToastFrame:Destroy()
        end)
    end)
end

Library.Notify = Library.CreateNotification

-- [ HÀM KHỞI TẠO WINDOW ] --
function Library:CreateWindow(options)
    if options and options.Name then
        TitleLabel.Text = options.Name
    end
    return Library
end

function Library:Init()
    return Library
end

_G.Neptune = Library
return Library
