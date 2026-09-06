local CSGOHub = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Teams = game:GetService("Teams")
local VirtualInputManager = game:GetService("VirtualInputManager")

local AimbotSettings = {
    Enabled = false,
    SilentAim = false,
    FOV = 500,
    Target = "Head",
    Smoothing = 1,
    VisibleCheck = false
}

local VisualSettings = {
    TeamHighlights = true,
    ESP = false,
    Boxes = false,
    Names = false,
    Tracers = false
}

local MiscSettings = {
    AutoFire = false,
    TriggerBot = false,
    RapidFire = false,
    NoRecoil = false,
    NoSpread = false,
    AutoJump = false,
    SpeedHack = false,
    WalkSpeed = 16,
    NoClip = false,
    Fly = false
}

local Colors = {
    Background = Color3.fromRGB(0, 0, 0),
    SecondaryBackground = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(0, 255, 63),       -- verde brillante
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(30, 30, 30),
    Hover = Color3.fromRGB(20, 20, 20),
    ToggleOn = Color3.fromRGB(0, 255, 63),     -- verde brillante
    ToggleOff = Color3.fromRGB(40, 40, 40)
}

local GlobalTransparency = 0.2

local function getPlayerTeamColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Color3.new(1, 1, 1)
end

local function getPlayerTeamName(player)
    return player.Team and player.Team.Name or "No Team"
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
            
            if VisualSettings.TeamHighlights then
                if isEnemy(player) then
                    highlight.FillTransparency = 0.3
                else
                    highlight.FillTransparency = 0.7
                end
            else
                highlight.FillTransparency = 1
            end
        end
    end
end

local function createESP(player)
    if player.Character then
        local esp = player.Character:FindFirstChild("ESPBox")
        if not esp and VisualSettings.Boxes then
            esp = Instance.new("BoxHandleAdornment")
            esp.Name = "ESPBox"
            esp.Size = Vector3.new(4, 6, 2)
            esp.Adornee = player.Character
            esp.AlwaysOnTop = true
            esp.ZIndex = 5
            esp.Color3 = getPlayerTeamColor(player)
            esp.Transparency = 0.3
            esp.Parent = player.Character
        end
        if esp and not VisualSettings.Boxes then
            esp:Destroy()
        end
    end
end

local function createNameTag(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        local tag = head:FindFirstChild("NameTag")
        if not tag and VisualSettings.Names then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameTag"
            billboard.Size = UDim2.new(0, 200, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 1, 0)
            billboard.Adornee = head
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextColor3 = Colors.Text
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Text = player.Name
            nameLabel.Parent = billboard
        end
        if tag and not VisualSettings.Names then
            tag:Destroy()
        end
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createESP(player)
            createNameTag(player)
        end
    end
end

local function aimbotFunction()
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
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, AimbotSettings.Smoothing)
            end
        end
    end
end

local function autoFireFunction()
    if MiscSettings.AutoFire then
        local target = getClosestEnemyToMouse()
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            local humanoid = target.Parent.Humanoid
            if humanoid.Health > 0 then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end
end

local function triggerBotFunction()
    if MiscSettings.TriggerBot then
        local mouseLocation = UserInputService:GetMouseLocation()
        local camera = workspace.CurrentCamera
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and isEnemy(player) then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and rootPart then
                    local screenPos, onScreen = camera:WorldToScreenPoint(rootPart.Position)
                    if onScreen and (Vector2.new(screenPos.X, screenPos.Y) - mouseLocation).Magnitude < 20 then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        break
                    end
                end
            end
        end
    end
end

local function rapidFireFunction()
    if MiscSettings.RapidFire then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Ammo") then
            -- Adjust fire rate if possible
        end
    end
end

local function noRecoilFunction()
    if MiscSettings.NoRecoil then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local recoil = tool:FindFirstChild("Recoil") or tool:FindFirstChild("CameraRecoil")
            if recoil then
                recoil:Destroy()
            end
        end
    end
end

local function noSpreadFunction()
    if MiscSettings.NoSpread then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            local spread = tool:FindFirstChild("Spread") or tool:FindFirstChild("CurrentSpread")
            if spread then
                spread:Destroy()
            end
        end
    end
end

local function autoJumpFunction()
    if MiscSettings.AutoJump then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function speedHackFunction()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = MiscSettings.SpeedHack and MiscSettings.WalkSpeed or 16
    end
end

local function noClipFunction()
    if MiscSettings.NoClip then
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function flyFunction()
    local character = LocalPlayer.Character
    if character and MiscSettings.Fly then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = true
            local bodyGyro = character:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
            bodyGyro.Parent = character

            local bodyVelocity = character:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlyVelocity"
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = character

            RunService:BindToRenderStep("Fly", 200, function()
                if not MiscSettings.Fly then return end
                local moveDirection = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection -= Vector3.new(0, 1, 0) end
                bodyVelocity.Velocity = moveDirection * 50
            end)
        end
    else
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
            local bodyGyro = character:FindFirstChild("BodyGyro")
            if bodyGyro then bodyGyro:Destroy() end
            local bodyVelocity = character:FindFirstChild("FlyVelocity")
            if bodyVelocity then bodyVelocity:Destroy() end
            RunService:UnbindFromRenderStep("Fly")
        end
    end
end

function CSGOHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HappyHub"
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
    MainFrame.Visible = false
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
    TitleLabel.TextSize = 28
    TitleLabel.TextColor3 = Color3.new(0, 255, 63)
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
    F3Indicator.Text = "Press F3"
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
    MinimizeButton.Text = "·"
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
    CloseButton.Text = "·"
    CloseButton.ZIndex = 3
    CloseButton.Parent = TopBar

    -- TabContainer ajustado para dejar espacio abajo (150 px)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 250, 1, -213)
    TabContainer.Position = UDim2.new(0, 0, 0, 63)
    TabContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    TabContainer.BackgroundTransparency = GlobalTransparency + 0.1
    TabContainer.BorderSizePixel = 0
    TabContainer.ZIndex = 2
    TabContainer.Parent = MainFrame

    -- MyPlayerCard
    local MyPlayerCard = Instance.new("Frame")
    MyPlayerCard.Name = "MyPlayerCard"
    MyPlayerCard.Size = UDim2.new(0, 250, 0, 150)
    MyPlayerCard.Position = UDim2.new(0, 0, 1, -150)
    MyPlayerCard.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    MyPlayerCard.BackgroundTransparency = GlobalTransparency
    MyPlayerCard.BorderSizePixel = 0
    MyPlayerCard.ZIndex = 2
    MyPlayerCard.Parent = MainFrame

    local pfpBackground = Instance.new("Frame")
    pfpBackground.Size = UDim2.new(0, 60, 0, 60)
    pfpBackground.Position = UDim2.new(0, 15, 0, 15)
    pfpBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    pfpBackground.BackgroundTransparency = 0.5
    pfpBackground.BorderSizePixel = 0
    pfpBackground.Parent = MyPlayerCard

    local pfpCorner = Instance.new("UICorner")
    pfpCorner.CornerRadius = UDim.new(1, 0)
    pfpCorner.Parent = pfpBackground

    local pfp = Instance.new("ImageLabel")
    pfp.Size = UDim2.new(1, 0, 1, 0)
    pfp.BackgroundTransparency = 0
    pfp.BackgroundColor3 = Color3.new(1,1,1)
    pfp.BorderSizePixel = 0
    pfp.ScaleType = Enum.ScaleType.Crop
    pfp.Parent = pfpBackground

    local pfpImageCorner = Instance.new("UICorner")
    pfpImageCorner.CornerRadius = UDim.new(1, 0)
    pfpImageCorner.Parent = pfp

    local teamDot = Instance.new("Frame")
    teamDot.Size = UDim2.new(0, 14, 0, 14)
    teamDot.Position = UDim2.new(1, -7, 1, -7)
    teamDot.BackgroundColor3 = getPlayerTeamColor(LocalPlayer)
    teamDot.BorderSizePixel = 0
    teamDot.ZIndex = 5
    teamDot.Parent = pfpBackground

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = teamDot

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -90, 0, 30)
    nameLabel.Position = UDim2.new(0, 85, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextColor3 = Colors.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = LocalPlayer.Name
    nameLabel.Parent = MyPlayerCard

    local displayLabel = Instance.new("TextLabel")
    displayLabel.Size = UDim2.new(1, -90, 0, 20)
    displayLabel.Position = UDim2.new(0, 85, 0, 40)
    displayLabel.BackgroundTransparency = 1
    displayLabel.Font = Enum.Font.Gotham
    displayLabel.TextSize = 12
    displayLabel.TextColor3 = Colors.TextSecondary
    displayLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayLabel.Text = "@" .. LocalPlayer.DisplayName
    displayLabel.Parent = MyPlayerCard

    local teamLabel = Instance.new("TextLabel")
    teamLabel.Size = UDim2.new(1, -90, 0, 20)
    teamLabel.Position = UDim2.new(0, 85, 0, 65)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Font = Enum.Font.GothamSemibold
    teamLabel.TextSize = 12
    teamLabel.TextColor3 = Colors.Text
    teamLabel.TextXAlignment = Enum.TextXAlignment.Left
    teamLabel.Text = getPlayerTeamName(LocalPlayer)
    teamLabel.Parent = MyPlayerCard

    -- Función para actualizar la card
    local function updateMyPlayerCard()
        pfp.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        nameLabel.Text = LocalPlayer.Name
        displayLabel.Text = "@" .. LocalPlayer.DisplayName
        teamLabel.Text = getPlayerTeamName(LocalPlayer)
        teamDot.BackgroundColor3 = getPlayerTeamColor(LocalPlayer)
    end

    updateMyPlayerCard()

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
        UpdateMyPlayerCard = updateMyPlayerCard,
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
        MiscSettings.Fly = false
        flyFunction()
        ScreenGui:Destroy()
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        local isMinimized = ContentArea.Visible
        ContentArea.Visible = not isMinimized
        TabContainer.Visible = not isMinimized
        MyPlayerCard.Visible = not isMinimized
    end)

    local function animateText(element, text)
        if not element:IsA("TextLabel") and not element:IsA("TextButton") then return end
        local originalText = text
        element.Text = ""
        for i = 1, #originalText do
            element.Text = string.sub(originalText, 1, i)
            task.wait(0.03)
        end
    end

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
            Name = name,
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

        for _, element in ipairs(tab.Elements) do
            if element:IsA("TextLabel") or element:IsA("TextButton") then
                local originalText = element:GetAttribute("OriginalText")
                if originalText then
                    task.spawn(function()
                        animateText(element, originalText)
                    end)
                end
            end
        end
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
        label:SetAttribute("OriginalText", text)
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
        button:SetAttribute("OriginalText", text)

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
        label:SetAttribute("OriginalText", text)
        label.Parent = container

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 30, 0, 30) -- cuadrado 30x30
        toggleButton.Position = UDim2.new(1, -30, 0.5, -15)
        toggleButton.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
        toggleButton.BackgroundTransparency = GlobalTransparency
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false
        toggleButton.ZIndex = 2
        toggleButton.Parent = container

        local state = default or false
        if callback then callback(state) end

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
        label:SetAttribute("OriginalText", text)
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
        label:SetAttribute("OriginalText", text)
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
    window.UpdateMyPlayerCard = updateMyPlayerCard

    return window
end

-- Intro GUI
local introGui = Instance.new("ScreenGui")
introGui.Name = "HappyHubIntro"
introGui.Parent = (gethui and gethui()) or CoreGui
introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
introGui.DisplayOrder = 999
introGui.IgnoreGuiInset = true

local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Color3.new(0, 0, 0)
introFrame.BorderSizePixel = 0
introFrame.BackgroundTransparency = 0.1
introFrame.ZIndex = 10
introFrame.Parent = introGui

local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, 0, 0, 80)
introText.Position = UDim2.new(0.5, 0, 0.5, -40)
introText.AnchorPoint = Vector2.new(0.5, 0.5)
introText.BackgroundTransparency = 1
introText.Font = Enum.Font.GothamBlack
introText.TextSize = 60
introText.TextColor3 = Color3.new(0, 255, 63)
introText.Text = ""
introText.ZIndex = 11
introText.Parent = introFrame

local introSubText = Instance.new("TextLabel")
introSubText.Size = UDim2.new(1, 0, 0, 30)
introSubText.Position = UDim2.new(0.5, 0, 0.5, 40)
introSubText.AnchorPoint = Vector2.new(0.5, 0.5)
introSubText.BackgroundTransparency = 1
introSubText.Font = Enum.Font.GothamSemibold
introSubText.TextSize = 16
introSubText.TextColor3 = Color3.new(255, 255, 255)
introSubText.Text = ""
introSubText.ZIndex = 11
introSubText.Parent = introFrame

-- Crear ventana principal (oculta)
local win = CSGOHub:CreateWindow("Happy Hub")

-- Animación de intro y mostrar ventana
task.spawn(function()
    local title = "Happy Hub"
    local subtitle = "Loading..."
    for i = 1, #title do
        introText.Text = string.sub(title, 1, i)
        task.wait(0.08)
    end
    task.wait(0.5)
    for i = 1, #subtitle do
        introSubText.Text = string.sub(subtitle, 1, i)
        task.wait(0.02)
    end
    task.wait(2)
    introGui:Destroy()

    win.MainFrame.Visible = true
    if win.ActiveTab then
        win:SelectTab(win.ActiveTab)
    end
end)

-- Crear pestañas
local aimbotTab = win:CreateTab("Aimbot")
local visualsTab = win:CreateTab("Visuals")
local miscTab = win:CreateTab("Misc")
local playersTab = win:CreateTab("Players")

-- Aimbot
win:CreateLabel(aimbotTab, "Aimbot Settings")
win:CreateToggle(aimbotTab, "Enabled", false, function(state)
    AimbotSettings.Enabled = state
end)
win:CreateToggle(aimbotTab, "Silent Aim", false, function(state)
    AimbotSettings.SilentAim = state
end)
win:CreateSlider(aimbotTab, "FOV", 70, 2000, 500, function(value)
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

-- Visuals
win:CreateLabel(visualsTab, "Visual Settings")
win:CreateToggle(visualsTab, "Team Highlights", true, function(state)
    VisualSettings.TeamHighlights = state
end)
win:CreateToggle(visualsTab, "ESP (Boxes)", false, function(state)
    VisualSettings.Boxes = state
    updateESP()
end)
win:CreateToggle(visualsTab, "Names", false, function(state)
    VisualSettings.Names = state
    updateESP()
end)
win:CreateToggle(visualsTab, "Tracers", false, function(state)
    VisualSettings.Tracers = state
end)

-- Misc
win:CreateLabel(miscTab, "Combat")
win:CreateToggle(miscTab, "Auto Fire", false, function(state)
    MiscSettings.AutoFire = state
end)
win:CreateToggle(miscTab, "Trigger Bot", false, function(state)
    MiscSettings.TriggerBot = state
end)
win:CreateToggle(miscTab, "Rapid Fire", false, function(state)
    MiscSettings.RapidFire = state
end)
win:CreateToggle(miscTab, "No Recoil", false, function(state)
    MiscSettings.NoRecoil = state
end)
win:CreateToggle(miscTab, "No Spread", false, function(state)
    MiscSettings.NoSpread = state
end)

win:CreateLabel(miscTab, "Movement")
win:CreateToggle(miscTab, "Auto Jump", false, function(state)
    MiscSettings.AutoJump = state
end)
win:CreateToggle(miscTab, "Speed Hack", false, function(state)
    MiscSettings.SpeedHack = state
    speedHackFunction()
end)
win:CreateSlider(miscTab, "Walk Speed", 16, 200, 16, function(value)
    MiscSettings.WalkSpeed = value
    if MiscSettings.SpeedHack then
        speedHackFunction()
    end
end)
win:CreateToggle(miscTab, "No Clip", false, function(state)
    MiscSettings.NoClip = state
    noClipFunction()
end)
win:CreateToggle(miscTab, "Fly", false, function(state)
    MiscSettings.Fly = state
    flyFunction()
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

-- Players List
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, -40, 1, -10)
playerListFrame.Position = UDim2.new(0, 20, 0, 10)
playerListFrame.BackgroundTransparency = 1
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.ScrollBarImageColor3 = Colors.Accent
playerListFrame.ScrollBarImageTransparency = 0.5
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = playersTab.Content

local function updatePlayerList()
    for _, child in ipairs(playerListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local yOffset = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, 0, 0, 50)
            playerFrame.Position = UDim2.new(0, 0, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            playerFrame.BackgroundTransparency = GlobalTransparency
            playerFrame.BorderSizePixel = 0
            playerFrame.Parent = playerListFrame

            local pfpBackground = Instance.new("Frame")
            pfpBackground.Size = UDim2.new(0, 35, 0, 35)
            pfpBackground.Position = UDim2.new(0, 30, 0.5, -17)
            pfpBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            pfpBackground.BackgroundTransparency = 0.5
            pfpBackground.BorderSizePixel = 0
            pfpBackground.Parent = playerFrame

            local pfpCorner = Instance.new("UICorner")
            pfpCorner.CornerRadius = UDim.new(1, 0)
            pfpCorner.Parent = pfpBackground

            local pfp = Instance.new("ImageLabel")
            pfp.Size = UDim2.new(1, 0, 1, 0)
            pfp.BackgroundTransparency = 0
            pfp.BackgroundColor3 = Color3.new(1,1,1)
            pfp.BorderSizePixel = 0
            pfp.ScaleType = Enum.ScaleType.Crop
            pfp.Parent = pfpBackground

            local pfpImageCorner = Instance.new("UICorner")
            pfpImageCorner.CornerRadius = UDim.new(1, 0)
            pfpImageCorner.Parent = pfp

            local teamDot = Instance.new("Frame")
            teamDot.Size = UDim2.new(0, 12, 0, 12)
            teamDot.Position = UDim2.new(1, -6, 1, -6)
            teamDot.BackgroundColor3 = getPlayerTeamColor(player)
            teamDot.BorderSizePixel = 0
            teamDot.ZIndex = 5
            teamDot.Parent = pfpBackground

            local dotCorner = Instance.new("UICorner")
            dotCorner.CornerRadius = UDim.new(1, 0)
            dotCorner.Parent = teamDot

            task.spawn(function()
                local userId = player.UserId
                local success, thumbnail = pcall(function()
                    return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                if success then
                    pfp.Image = thumbnail
                end
            end)

            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(0.5, -80, 1, 0)
            infoLabel.Position = UDim2.new(0, 75, 0, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 14
            infoLabel.TextColor3 = Colors.Text
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Text = player.Name .. " (" .. player.DisplayName .. ")\n" .. getPlayerTeamName(player)
            infoLabel.Parent = playerFrame

            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(0, 80, 1, 0)
            distLabel.Position = UDim2.new(0.5, 10, 0, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextSize = 12
            distLabel.TextColor3 = Colors.TextSecondary
            distLabel.Text = "Distance: N/A"
            distLabel.Parent = playerFrame

            local teleportBtn = Instance.new("TextButton")
            teleportBtn.Size = UDim2.new(0, 80, 0, 30)
            teleportBtn.Position = UDim2.new(1, -90, 0.5, -15)
            teleportBtn.BackgroundColor3 = Colors.Accent
            teleportBtn.BackgroundTransparency = 0.2
            teleportBtn.BorderSizePixel = 0
            teleportBtn.Font = Enum.Font.GothamBold
            teleportBtn.TextSize = 12
            teleportBtn.TextColor3 = Colors.Text
            teleportBtn.Text = "Teleport"
            teleportBtn.AutoButtonColor = false
            teleportBtn.Parent = playerFrame

            teleportBtn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                    end
                end
            end)

            yOffset += 60
        end
    end

    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)

    task.spawn(function()
        while true do
            task.wait(1)
            for _, frame in ipairs(playerListFrame:GetChildren()) do
                if frame:IsA("Frame") then
                    local distLabel = frame:FindFirstChildOfClass("TextLabel")
                    if distLabel and distLabel.Text:sub(1, 8) == "Distance" then
                        local playerName = frame:FindFirstChildOfClass("TextLabel").Text:split(" ")[1]
                        local player = Players:FindFirstChild(playerName)
                        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            distLabel.Text = "Distance: " .. string.format("%.1f", dist)
                        end
                    end
                end
            end
        end
    end)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Conexiones de RenderStepped
RunService.RenderStepped:Connect(function()
    aimbotFunction()
    autoFireFunction()
    triggerBotFunction()
    autoJumpFunction()
end)

RunService.Heartbeat:Connect(function()
    ApplyTeamHighlights()
    if MiscSettings.NoClip then noClipFunction() end
    if MiscSettings.Fly then flyFunction() end
end)

-- Limpiar al salir
game:GetService("Players").LocalPlayer.OnCharacterAdded:Connect(function()
    task.wait(1)
    speedHackFunction()
    noClipFunction()
    if MiscSettings.Fly then flyFunction() end
    win.UpdateMyPlayerCard()
end)
