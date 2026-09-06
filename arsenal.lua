local CSGOHub = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Teams = game:GetService("Teams")

local AimbotSettings = {
    Enabled = false,
    SilentAim = false,
    FOV = 500,
    Target = "Head",
    Smoothing = 1,
    VisibleCheck = false
}

local Colors = {
    Background = Color3.fromRGB(0, 0, 0),
    SecondaryBackground = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(0, 200, 100),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(30, 30, 30),
    Hover = Color3.fromRGB(20, 20, 20),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(40, 40, 40)
}

local GlobalTransparency = 0.4

local function getPlayerTeamColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Color3.new(1, 1, 1)
end

local function isEnemy(player)
    local localTeamColor = getPlayerTeamColor(LocalPlayer)
    local targetTeamColor = getPlayerTeamColor(player)
    return localTeamColor ~= targetTeamColor
end

local function getClosestEnemyToMouse()
    local mouseLocation = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    local closestPlayer = nil
    local closestDistance = AimbotSettings.FOV
    local closestPart = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local targetPart = nil
                
                if AimbotSettings.Target == "Head" and player.Character:FindFirstChild("Head") then
                    targetPart = player.Character.Head
                elseif AimbotSettings.Target == "Torso" then
                    targetPart = rootPart
                elseif AimbotSettings.Target == "Random" then
                    if math.random(1, 2) == 1 and player.Character:FindFirstChild("Head") then
                        targetPart = player.Character.Head
                    else
                        targetPart = rootPart
                    end
                end
                
                if targetPart then
                    local screenPosition, onScreen = camera:WorldToScreenPoint(targetPart.Position)
                    
                    if onScreen then
                        local screenVector = Vector2.new(screenPosition.X, screenPosition.Y)
                        local distanceFromMouse = (screenVector - mouseLocation).Magnitude
                        
                        if distanceFromMouse < closestDistance then
                            closestDistance = distanceFromMouse
                            closestPlayer = player
                            closestPart = targetPart
                        end
                    end
                end
            end
        end
    end
    
    return closestPart
end

local function ApplyTeamHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local teamColor = getPlayerTeamColor(player)
            
            local highlight = player.Character:FindFirstChild("TeamHighlight")
            
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "TeamHighlight"
                highlight.Parent = player.Character
            end
            
            highlight.FillColor = teamColor
            highlight.OutlineColor = teamColor
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 1
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            
            if isEnemy(player) then
                highlight.FillTransparency = 0.3
            else
                highlight.FillTransparency = 0.7
            end
        end
    end
end

local aimbotConnection
aimbotConnection = RunService.RenderStepped:Connect(function()
    if AimbotSettings.Enabled then
        local target = getClosestEnemyToMouse()
        if target then
            local camera = workspace.CurrentCamera
            local targetPosition = target.Position
            
            if AimbotSettings.SilentAim then
                local direction = (targetPosition - camera.CFrame.Position).Unit
                camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
            else
                local targetCFrame = CFrame.new(camera.CFrame.Position, targetPosition)
                camera.CFrame = targetCFrame
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    ApplyTeamHighlights()
end)

function CSGOHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HappyHub_" .. title
    ScreenGui.Parent = (gethui and gethui()) or CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.Position = UDim2.new(0, 0, 0, 0)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BackgroundTransparency = GlobalTransparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui

    local TopBorder = Instance.new("Frame")
    TopBorder.Name = "TopBorder"
    TopBorder.Size = UDim2.new(1, 0, 0, 3)
    TopBorder.Position = UDim2.new(0, 0, 0, 0)
    TopBorder.BackgroundColor3 = Colors.Accent
    TopBorder.BackgroundTransparency = 0.3
    TopBorder.BorderSizePixel = 0
    TopBorder.ZIndex = 2
    TopBorder.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.Position = UDim2.new(0, 0, 0, 3)
    TopBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    TopBar.BackgroundTransparency = GlobalTransparency + 0.1
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 2
    TopBar.Parent = MainFrame

    local HubIcon = Instance.new("ImageLabel")
    HubIcon.Name = "HubIcon"
    HubIcon.Size = UDim2.new(0, 40, 0, 40)
    HubIcon.Position = UDim2.new(0, 15, 0.5, -20)
    HubIcon.BackgroundTransparency = 1
    HubIcon.Image = "rbxassetid://104348663064077"
    HubIcon.ZIndex = 3
    HubIcon.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -300, 1, 0)
    TitleLabel.Position = UDim2.new(0, 65, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 24
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = title or "Happy Hub"
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TopBar

    local F3Indicator = Instance.new("TextLabel")
    F3Indicator.Name = "F3Indicator"
    F3Indicator.Size = UDim2.new(0, 80, 0, 25)
    F3Indicator.Position = UDim2.new(1, -190, 0.5, -12)
    F3Indicator.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    F3Indicator.BackgroundTransparency = 0.3
    F3Indicator.BorderSizePixel = 0
    F3Indicator.Font = Enum.Font.GothamSemibold
    F3Indicator.TextSize = 12
    F3Indicator.TextColor3 = Colors.TextSecondary
    F3Indicator.Text = "F3: Toggle"
    F3Indicator.ZIndex = 3
    F3Indicator.Parent = TopBar

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Size = UDim2.new(0, 50, 0, 50)
    MinimizeButton.Position = UDim2.new(1, -100, 0, 5)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 24
    MinimizeButton.TextColor3 = Colors.Text
    MinimizeButton.Text = "-"
    MinimizeButton.ZIndex = 3
    MinimizeButton.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 50, 0, 50)
    CloseButton.Position = UDim2.new(1, -50, 0, 5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 24
    CloseButton.TextColor3 = Colors.Text
    CloseButton.Text = "X"
    CloseButton.ZIndex = 3
    CloseButton.Parent = TopBar

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 250, 1, -63)
    TabContainer.Position = UDim2.new(0, 0, 0, 63)
    TabContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    TabContainer.BackgroundTransparency = GlobalTransparency + 0.1
    TabContainer.BorderSizePixel = 0
    TabContainer.ZIndex = 2
    TabContainer.Parent = MainFrame

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -250, 1, -63)
    ContentArea.Position = UDim2.new(0, 250, 0, 63)
    ContentArea.BackgroundColor3 = Colors.Background
    ContentArea.BackgroundTransparency = GlobalTransparency
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = false
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainFrame

    local window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TopBar = TopBar,
        TitleLabel = TitleLabel,
        MinimizeButton = MinimizeButton,
        CloseButton = CloseButton,
        TabContainer = TabContainer,
        ContentArea = ContentArea,
        Tabs = {},
        ActiveTab = nil,
        IsVisible = true,
    }

    local function toggleVisibility()
        window.IsVisible = not window.IsVisible
        MainFrame.Visible = window.IsVisible
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F3 and not gameProcessed then
            toggleVisibility()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        AimbotSettings.Enabled = false
        ScreenGui:Destroy()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        local isMinimized = ContentArea.Visible
        ContentArea.Visible = not isMinimized
        TabContainer.Visible = not isMinimized
    end)

    function window:CreateTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "_Tab"
        TabButton.Size = UDim2.new(1, -20, 0, 40)
        TabButton.Position = UDim2.new(0, 10, 0, 10 + (#self.Tabs * 50))
        TabButton.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        TabButton.BackgroundTransparency = GlobalTransparency + 0.05
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 15
        TabButton.TextColor3 = Colors.TextSecondary
        TabButton.Text = name
        TabButton.AutoButtonColor = false
        TabButton.ZIndex = 3
        TabButton.Parent = self.TabContainer

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "_Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Colors.Accent
        TabContent.ScrollBarImageTransparency = 0.5
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Parent = self.ContentArea
        TabContent.Visible = false
        TabContent.ZIndex = 2

        local tab = {
            Button = TabButton,
            Content = TabContent,
            Elements = {},
            YOffset = 20,
        }

        TabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= tab then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
                TweenService:Create(TabButton, TweenInfo.new(0.15), {TextColor3 = Colors.Text}):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= tab then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(5, 5, 5)}):Play()
                TweenService:Create(TabButton, TweenInfo.new(0.15), {TextColor3 = Colors.TextSecondary}):Play()
            end
        end)
        TabButton.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)

        table.insert(self.Tabs, tab)

        if #self.Tabs == 1 then
            self:SelectTab(tab)
        end

        return tab
    end

    function window:SelectTab(tab)
        if self.ActiveTab then
            self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            self.ActiveTab.Button.TextColor3 = Colors.TextSecondary
            self.ActiveTab.Content.Visible = false
        end
        self.ActiveTab = tab
        tab.Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tab.Button.TextColor3 = Colors.Text
        tab.Content.Visible = true
    end

    local function addElement(tab, element)
        element.Position = UDim2.new(0, 20, 0, tab.YOffset)
        element.Parent = tab.Content
        tab.YOffset += element.Size.Y.Offset + 10
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.YOffset + 30)
        table.insert(tab.Elements, element)
        return element
    end

    function window:CreateLabel(tab, text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 0, 25)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.TextColor3 = Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.ZIndex = 2
        return addElement(tab, label)
    end

    function window:CreateButton(tab, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -40, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        button.BackgroundTransparency = GlobalTransparency
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamSemibold
        button.TextSize = 14
        button.TextColor3 = Colors.Text
        button.Text = text
        button.AutoButtonColor = false
        button.ZIndex = 2

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Hover}):Play()
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(5, 5, 5)}):Play()
        end)
        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return addElement(tab, button)
    end

    function window:CreateToggle(tab, text, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -40, 0, 35)
        container.BackgroundTransparency = 1
        container.ZIndex = 2

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextColor3 = Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.ZIndex = 2
        label.Parent = container

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 45, 0, 25)
        toggleButton.Position = UDim2.new(1, -45, 0.5, -12)
        toggleButton.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
        toggleButton.BackgroundTransparency = GlobalTransparency
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false
        toggleButton.ZIndex = 2
        toggleButton.Parent = container

        local state = default or false

        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            toggleButton.BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
            if callback then callback(state) end
        end)

        addElement(tab, container)
        return {
            SetState = function(newState)
                state = newState
                toggleButton.BackgroundColor3 = state and Colors.ToggleOn or Colors.ToggleOff
                if callback then callback(state) end
            end,
            GetState = function()
                return state
            end
        }
    end

    function window:CreateSlider(tab, text, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -40, 0, 50)
        container.BackgroundTransparency = 1
        container.ZIndex = 2

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextColor3 = Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text .. ": " .. tostring(default)
        label.ZIndex = 2
        label.Parent = container

        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 6)
        sliderFrame.Position = UDim2.new(0, 0, 1, -15)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        sliderFrame.BackgroundTransparency = GlobalTransparency
        sliderFrame.BorderSizePixel = 0
        sliderFrame.ZIndex = 2
        sliderFrame.Parent = container

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Colors.Accent
        fill.BackgroundTransparency = 0.2
        fill.BorderSizePixel = 0
        fill.ZIndex = 2
        fill.Parent = sliderFrame

        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        knob.BackgroundColor3 = Colors.Accent
        knob.BackgroundTransparency = 0.2
        knob.BorderSizePixel = 0
        knob.Text = ""
        knob.AutoButtonColor = false
        knob.ZIndex = 2
        knob.Parent = sliderFrame

        local value = default
        local dragging = false

        local function updateFromMouse(input)
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = mousePos.X - sliderFrame.AbsolutePosition.X
            local percent = math.clamp(relativeX / sliderFrame.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * percent
            value = math.floor(value * 100) / 100
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -7, 0.5, -7)
            label.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end

        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateFromMouse(input)
            end
        end)

        addElement(tab, container)
        return {
            SetValue = function(newValue)
                value = math.clamp(newValue, min, max)
                local percent = (value - min) / (max - min)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -7, 0.5, -7)
                label.Text = text .. ": " .. tostring(value)
                if callback then callback(value) end
            end,
            GetValue = function()
                return value
            end
        }
    end

    function window:CreateDropdown(tab, text, options, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -40, 0, 35)
        container.BackgroundTransparency = 1
        container.ZIndex = 10
        container.ClipsDescendants = false

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextColor3 = Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.ZIndex = 10
        label.Parent = container

        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0.5, -10, 0, 30)
        dropdownButton.Position = UDim2.new(0.5, 10, 0.5, -15)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        dropdownButton.BackgroundTransparency = GlobalTransparency
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Font = Enum.Font.GothamSemibold
        dropdownButton.TextSize = 14
        dropdownButton.TextColor3 = Colors.Text
        dropdownButton.Text = default or options[1] or ""
        dropdownButton.AutoButtonColor = false
        dropdownButton.ZIndex = 10
        dropdownButton.Parent = container

        local dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0.5, -10, 0, #options * 30)
        dropdownList.Position = UDim2.new(0.5, 10, 1, 5)
        dropdownList.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        dropdownList.BackgroundTransparency = 0.1
        dropdownList.BorderSizePixel = 1
        dropdownList.BorderColor3 = Colors.Accent
        dropdownList.Visible = false
        dropdownList.ZIndex = 10
        dropdownList.ClipsDescendants = false
        dropdownList.Parent = container

        local selected = default or options[1] or ""

        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            optionButton.BackgroundColor3 = (option == selected) and Colors.Accent or Color3.fromRGB(5, 5, 5)
            optionButton.BackgroundTransparency = (option == selected) and 0.2 or GlobalTransparency
            optionButton.BorderSizePixel = 0
            optionButton.Font = Enum.Font.GothamSemibold
            optionButton.TextSize = 14
            optionButton.TextColor3 = Colors.Text
            optionButton.Text = option
            optionButton.AutoButtonColor = false
            optionButton.ZIndex = 10
            optionButton.Parent = dropdownList

            optionButton.MouseEnter:Connect(function()
                if option ~= selected then
                    TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Hover}):Play()
                end
            end)
            
            optionButton.MouseLeave:Connect(function()
                if option ~= selected then
                    TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(5, 5, 5)}):Play()
                end
            end)

            optionButton.MouseButton1Click:Connect(function()
                selected = option
                dropdownButton.Text = option
                dropdownList.Visible = false
                for _, btn in ipairs(dropdownList:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = (btn.Text == selected) and Colors.Accent or Color3.fromRGB(5, 5, 5)
                        btn.BackgroundTransparency = (btn.Text == selected) and 0.2 or GlobalTransparency
                    end
                end
                if callback then callback(selected) end
            end)
        end

        dropdownButton.MouseButton1Click:Connect(function()
            dropdownList.Visible = not dropdownList.Visible
            dropdownList.ZIndex = 10
            container.ZIndex = 10
        end)

        addElement(tab, container)
        return {
            SetValue = function(newValue)
                if table.find(options, newValue) then
                    selected = newValue
                    dropdownButton.Text = newValue
                    for _, btn in ipairs(dropdownList:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = (btn.Text == selected) and Colors.Accent or Color3.fromRGB(5, 5, 5)
                            btn.BackgroundTransparency = (btn.Text == selected) and 0.2 or GlobalTransparency
                        end
                    end
                    if callback then callback(selected) end
                end
            end,
            GetValue = function()
                return selected
            end
        }
    end

    window.ToggleVisibility = toggleVisibility
    window.IsVisible = function()
        return window.IsVisible
    end

    return window
end

local win = CSGOHub:CreateWindow("Happy Hub")

local aimbotTab = win:CreateTab("Aimbot")
local visualsTab = win:CreateTab("Visuals")
local miscTab = win:CreateTab("Misc")

win:CreateLabel(aimbotTab, "Aimbot")
win:CreateToggle(aimbotTab, "Enabled", false, function(state)
    AimbotSettings.Enabled = state
end)
win:CreateToggle(aimbotTab, "Silent Aim", false, function(state)
    AimbotSettings.SilentAim = state
end)
win:CreateSlider(aimbotTab, "FOV", 100, 2000, 500, function(value)
    AimbotSettings.FOV = value
end)
win:CreateSlider(aimbotTab, "Smoothing", 0.1, 1, 1, function(value)
    AimbotSettings.Smoothing = value
end)
win:CreateDropdown(aimbotTab, "Target", {"Head", "Torso", "Random"}, "Head", function(selected)
    AimbotSettings.Target = selected
end)
win:CreateButton(aimbotTab, "Reset", function()
    AimbotSettings.Enabled = false
    AimbotSettings.SilentAim = false
    AimbotSettings.FOV = 500
    AimbotSettings.Target = "Head"
    AimbotSettings.Smoothing = 1
end)

win:CreateLabel(visualsTab, "Visuals")
win:CreateToggle(visualsTab, "Team Highlights", true, function(state)
end)
win:CreateToggle(visualsTab, "ESP", false, function(state)
end)
win:CreateToggle(visualsTab, "Boxes", false, function(state)
end)
win:CreateToggle(visualsTab, "Names", false, function(state)
end)
win:CreateToggle(visualsTab, "Tracers", false, function(state)
end)

win:CreateLabel(miscTab, "Combat")
win:CreateToggle(miscTab, "Auto Fire", false, function(state)
end)
win:CreateToggle(miscTab, "Trigger Bot", false, function(state)
end)
win:CreateToggle(miscTab, "Rapid Fire", false, function(state)
end)
win:CreateToggle(miscTab, "No Recoil", false, function(state)
end)
win:CreateToggle(miscTab, "No Spread", false, function(state)
end)

win:CreateLabel(miscTab, "Movement")
win:CreateToggle(miscTab, "Auto Jump", false, function(state)
end)
win:CreateToggle(miscTab, "Speed Hack", false, function(state)
end)
win:CreateSlider(miscTab, "Walk Speed", 16, 200, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)
win:CreateToggle(miscTab, "No Clip", false, function(state)
end)
win:CreateToggle(miscTab, "Fly", false, function(state)
end)

win:CreateLabel(miscTab, "Utility")
win:CreateButton(miscTab, "Teleport to Spawn", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end)
win:CreateButton(miscTab, "Reset Character", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end)
