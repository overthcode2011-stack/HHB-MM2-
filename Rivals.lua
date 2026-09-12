if _G.__rivals_aimbot_loaded then return end
_G.__rivals_aimbot_loaded = true

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local mousemoverel = mousemoverel or MouseMoveRel or (syn and syn.mousemoverel) or (fluxus and fluxus.mousemoverel)

local MAIN_ICON  = "rbxassetid://104348663064077"
local CLOSE_ICON = "rbxassetid://130629964514885"
local MIN_ICON   = "rbxassetid://115558082558028"
local AIM_ICON   = "rbxassetid://93310349660228"
local VIS_ICON   = "rbxassetid://13321848320"
local MISC_ICON  = "rbxassetid://109962716823639"
local NOTIF_ICON = "rbxassetid://111849828445660"

local AimbotSettings = {
    Enabled     = false,
    FOV         = 150,
    Smoothing   = 0.35,
    WallCheck   = false,
    MaxDistance = 150,
    Target      = "Head",
    ShowFOV     = false,
    TeamCheck   = false,
    RotateRig   = true,
}

local VisualSettings = {
    RivalsESP     = false,
    TeamHighlight = false,
    NameTags      = false,
}

local MiscSettings     = { InfJump = false, AntiAFK = false }
local MovementSettings = { Noclip = false, God = false }

local Colors = {
    Background    = Color3.fromRGB(0, 0, 0),
    Accent        = Color3.fromRGB(0, 255, 63),
    Text          = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Hover         = Color3.fromRGB(20, 20, 20),
    ToggleOn      = Color3.fromRGB(0, 255, 63),
    ToggleOff     = Color3.fromRGB(40, 40, 40),
}

local openDropdowns = {}

local function closeAllDropdowns()
    for _, fn in ipairs(openDropdowns) do
        pcall(fn)
    end
    openDropdowns = {}
end

local teamCache, teamCacheTime = {}, {}

local function normalizeTeam(v)
    if v == nil then return nil end
    local t = typeof(v)
    if t == "Instance"   then return v end
    if t == "Color3"     then return string.format("c:%.3f:%.3f:%.3f", v.R, v.G, v.B) end
    if t == "BrickColor" then return "b:" .. v.Name end
    if t == "string"     then return v == "" and nil or "s:" .. v end
    if t == "number"     then return "n:" .. tostring(v) end
    return nil
end

local function isTeamName(n)
    if typeof(n) ~= "string" then return false end
    local l = string.gsub(string.lower(n), "[%s_%-]", "")
    return l == "team" or l == "teamid" or l == "teamindex"
        or l == "teamcolor" or l == "teamcolour"
end

local function getTeamAttr(c)
    if not c then return nil end
    for n, v in pairs(c:GetAttributes()) do
        if isTeamName(n) then
            local r = normalizeTeam(v)
            if r then return r end
        end
    end
end

local function getTeamVal(c)
    if not c then return nil end
    for _, o in ipairs(c:GetChildren()) do
        if isTeamName(o.Name) then
            local r = normalizeTeam(o.Value)
            if r then return r end
        end
    end
end

local function getTeamSig(p)
    if not p then return nil end
    local now = os.clock()
    if teamCache[p] ~= nil and teamCacheTime[p] and now - teamCacheTime[p] < 0.25 then
        return teamCache[p]
    end
    local s = p.Team or getTeamAttr(p) or getTeamVal(p)
        or (p.Character and getTeamAttr(p.Character))
        or (p.Character and getTeamVal(p.Character))
    if not s and p.TeamColor then
        local n = p.TeamColor.Name
        if n and n ~= "Medium stone grey" then s = "b:" .. n end
    end
    teamCache[p] = s
    teamCacheTime[p] = now
    return s
end

local function isTeammate(p)
    if not p or p == LocalPlayer then return true end
    if p.Team and LocalPlayer.Team then return p.Team == LocalPlayer.Team end
    local ls, ts = getTeamSig(LocalPlayer), getTeamSig(p)
    if ls ~= nil and ts ~= nil then
        if typeof(ls) == "Instance" and typeof(ts) == "Instance" then return ls == ts end
        return tostring(ls) == tostring(ts)
    end
    return false
end

local function isEnemy(p)
    if not p or p == LocalPlayer then return false end
    if not AimbotSettings.TeamCheck then return true end
    return not isTeammate(p)
end

local enemyCache, lastEnemyUpdate = {}, 0

local function refreshEnemies()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isEnemy(p) then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health > 0 then l[#l+1] = p end
        end
    end
    enemyCache = l
end

local function getEnemiesCached()
    local now = os.clock()
    if now - lastEnemyUpdate > 0.05 then
        refreshEnemies()
        lastEnemyUpdate = now
    end
    return enemyCache
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {}

local function rebuildRayFilter()
    local l = {}
    if LocalPlayer.Character then l[#l+1] = LocalPlayer.Character end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then l[#l+1] = p.Character end
    end
    rayParams.FilterDescendantsInstances = l
end

local function hasLineOfSight(part)
    if not part or not Camera then return false end
    local cp = Camera.CFrame.Position
    local off = part.Position - cp
    local d = off.Magnitude
    if d <= 0 then return false end
    local hit = workspace:Raycast(cp, off.Unit * d, rayParams)
    if not hit then return true end
    return hit.Instance and (hit.Instance:IsDescendantOf(part.Parent) or hit.Instance == part)
end

local lockedTarget = nil

local function getCrosshairPosition()
    if not Camera then return Vector2.new(0, 0) end
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function getTargetPart(character)
    if not character then return nil end
    if AimbotSettings.Target == "Head" then
        return character:FindFirstChild("Head")
    elseif AimbotSettings.Target == "Torso" then
        return character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
    elseif AimbotSettings.Target == "Random" then
        if math.random(1, 2) == 1 then
            return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        else
            return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
        end
    end
    return character:FindFirstChild("Head")
end

local function getAimTarget(crosshair)
    local lc = LocalPlayer.Character
    if not lc then return nil end
    local lr = lc:FindFirstChild("HumanoidRootPart")
    if not lr then return nil end

    if lockedTarget then
        local c = lockedTarget.Character
        local part = c and getTargetPart(c)
        local hu = c and c:FindFirstChildOfClass("Humanoid")
        if part and hu and hu.Health > 0 then
            local d = (lr.Position - part.Position).Magnitude
            if d <= AimbotSettings.MaxDistance then
                if not AimbotSettings.WallCheck or hasLineOfSight(part) then
                    return part
                end
            end
        end
        lockedTarget = nil
    end

    local best, bestD = nil, AimbotSettings.FOV
    for _, p in ipairs(getEnemiesCached()) do
        local c = p.Character
        if c then
            local part = getTargetPart(c)
            if part then
                local d3 = (lr.Position - part.Position).Magnitude
                if d3 <= AimbotSettings.MaxDistance then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d2 = (Vector2.new(sp.X, sp.Y) - crosshair).Magnitude
                        if d2 <= bestD then
                            if not AimbotSettings.WallCheck or hasLineOfSight(part) then
                                bestD = d2
                                best = p
                            end
                        end
                    end
                end
            end
        end
    end

    if best then
        lockedTarget = best
        return getTargetPart(best.Character)
    end
    return nil
end

local function rotateRigTowards(part)
    if not AimbotSettings.RotateRig then return end
    if not part or not part.Parent then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local myPos = hrp.Position
    local targetPos = part.Position

    local deltaX = targetPos.X - myPos.X
    local deltaZ = targetPos.Z - myPos.Z

    local desiredYaw = math.atan2(-deltaX, -deltaZ)
    local currentYaw = math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z)

    local diff = math.atan2(
        math.sin(desiredYaw - currentYaw),
        math.cos(desiredYaw - currentYaw)
    )

    local newYaw = currentYaw + diff * math.clamp(AimbotSettings.Smoothing * 1.5, 0, 1)

    local look  = Vector3.new(-math.sin(newYaw), 0, -math.cos(newYaw))
    local right = Vector3.new(math.cos(newYaw), 0, -math.sin(newYaw))

    hrp.CFrame = CFrame.fromMatrix(
        hrp.CFrame.Position,
        right,
        Vector3.new(0, 1, 0),
        -look
    )
end

local function aimViaMouse(part)
    if not part or not part.Parent then return end
    if not mousemoverel then return end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local screenPos = camera:WorldToViewportPoint(part.Position)
    if not screenPos then return end

    local vp = camera.ViewportSize
    local centerX = vp.X / 2
    local centerY = vp.Y / 2

    local deltaX = screenPos.X - centerX
    local deltaY = screenPos.Y - centerY

    local dist = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    if dist < 1 then return end

    local smooth = AimbotSettings.Smoothing
    if smooth <= 0 then smooth = 1 end

    local moveX = deltaX * smooth
    local moveY = deltaY * smooth

    if dist > 200 then
        moveX = moveX * 0.7
        moveY = moveY * 0.7
    end

    rotateRigTowards(part)
    pcall(mousemoverel, moveX, moveY)
end

local fovCircle = nil
pcall(function()
    if Drawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.Color = Color3.fromRGB(0, 255, 63)
        fovCircle.Filled = false
        fovCircle.Visible = false
        fovCircle.NumSides = 60
    end
end)

local function makeCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local function makeStroke(p, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local noclipConn, godConn, antiAFKConn = nil, nil, nil

UserInputService.JumpRequest:Connect(function()
    if MiscSettings.InfJump then
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

local RivalsESP = {
    active = false,
    highlights = {},
    nameTags = {},
    updateThread = nil,
    nameTagUpdater = nil,
}

local ESP_COLORS = {
    Enemy   = Color3.fromRGB(255, 60, 60),
    Ally    = Color3.fromRGB(60, 160, 255),
    Self    = Color3.fromRGB(0, 255, 63),
    Neutral = Color3.fromRGB(255, 255, 255),
}

local function getRivalsESPColor(plr)
    if plr == LocalPlayer then return ESP_COLORS.Self end
    if isTeammate(plr) then return ESP_COLORS.Ally end
    return ESP_COLORS.Enemy
end

local function clearRivalsHighlight(plr)
    if RivalsESP.highlights[plr] then
        RivalsESP.highlights[plr]:Destroy()
        RivalsESP.highlights[plr] = nil
    end
    if RivalsESP.nameTags[plr] then
        if RivalsESP.nameTags[plr].bb and RivalsESP.nameTags[plr].bb.Parent then
            RivalsESP.nameTags[plr].bb:Destroy()
        end
        RivalsESP.nameTags[plr] = nil
    end
end

local function applyRivalsESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local color = getRivalsESPColor(plr)

    if not RivalsESP.highlights[plr] then
        local h = Instance.new("Highlight")
        h.Name = "HHB_ESP_Rivals"
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.35
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        RivalsESP.highlights[plr] = h
    else
        RivalsESP.highlights[plr].FillColor = color
        RivalsESP.highlights[plr].OutlineColor = color
    end

    if VisualSettings.NameTags then
        if not RivalsESP.nameTags[plr] then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bb = Instance.new("BillboardGui")
                bb.Name = "HHB_NameTag"
                bb.Size = UDim2.new(0, 120, 0, 34)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Adornee = hrp
                bb.Parent = hrp

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = color
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.TextStrokeTransparency = 0.4
                lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                lbl.Parent = bb

                RivalsESP.nameTags[plr] = { bb = bb, lbl = lbl }
            end
        end
    elseif RivalsESP.nameTags[plr] then
        RivalsESP.nameTags[plr].bb:Destroy()
        RivalsESP.nameTags[plr] = nil
    end
end

local function refreshAllRivalsESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not plr.Character then
                clearRivalsHighlight(plr)
            else
                applyRivalsESP(plr)
            end
        end
    end
end

local function startRivalsESP()
    RivalsESP.active = true
    if not RivalsESP.updateThread then
        RivalsESP.updateThread = task.spawn(function()
            while RivalsESP.active do
                task.wait(0.5)
                if RivalsESP.active then
                    refreshAllRivalsESP()
                end
            end
            RivalsESP.updateThread = nil
        end)
    end
    refreshAllRivalsESP()
end

local function stopRivalsESP()
    RivalsESP.active = false
    if RivalsESP.updateThread then
        task.cancel(RivalsESP.updateThread)
        RivalsESP.updateThread = nil
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        clearRivalsHighlight(plr)
    end
end

local function startNameTagUpdater()
    if not RivalsESP.nameTagUpdater then
        RivalsESP.nameTagUpdater = RunService.Heartbeat:Connect(function()
            if not VisualSettings.NameTags then return end
            local myHRP = getHRP()
            if not myHRP then return end
            for plr, data in pairs(RivalsESP.nameTags) do
                if plr.Character and data.lbl then
                    local theirHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    if theirHRP then
                        local dist = math.floor((myHRP.Position - theirHRP.Position).Magnitude)
                        data.lbl.Text = plr.DisplayName .. "\n" .. dist .. "m"
                    else
                        data.lbl.Text = plr.DisplayName
                    end
                end
            end
        end)
    end
end

local function stopNameTagUpdater()
    if RivalsESP.nameTagUpdater then
        RivalsESP.nameTagUpdater:Disconnect()
        RivalsESP.nameTagUpdater = nil
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if RivalsESP.active then applyRivalsESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    clearRivalsHighlight(plr)
end)

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "HappyHubNotifications"
NotifGui.Parent = game:GetService("CoreGui")
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.DisplayOrder = 500
NotifGui.IgnoreGuiInset = true
NotifGui.ResetOnSpawn = false

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "Container"
NotifContainer.Size = UDim2.new(0, 280, 1, -20)
NotifContainer.Position = UDim2.new(1, -300, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Parent = NotifContainer

local notifOrder = 0

local function Notify(text, duration)
    duration = duration or 3
    notifOrder = notifOrder + 1

    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(1, 0, 0, 56)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.LayoutOrder = notifOrder
    frame.Parent = NotifContainer
    makeCorner(frame, 8)
    makeStroke(frame, Colors.Accent, 1, 0.7)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -16)
    accent.Position = UDim2.new(0, 0, 0, 8)
    accent.BackgroundColor3 = Colors.Accent
    accent.BorderSizePixel = 0
    accent.Parent = frame
    makeCorner(accent, 2)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(30, 30)
    icon.Position = UDim2.new(0, 14, 0.5, -15)
    icon.BackgroundTransparency = 1
    icon.Image = NOTIF_ICON
    icon.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.new(0, 54, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Colors.Accent
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Happy Hub"
    title.Parent = frame

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -70, 0, 18)
    msg.Position = UDim2.new(0, 54, 0, 28)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.GothamMedium
    msg.TextSize = 12
    msg.TextColor3 = Colors.TextSecondary
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextTruncate = Enum.TextTruncate.AtEnd
    msg.Text = text
    msg.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 3)
    barBg.Position = UDim2.new(0, 10, 1, -6)
    barBg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    makeCorner(barBg, 2)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Colors.Accent
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    makeCorner(bar, 2)

    frame.Position = UDim2.new(1, 300, 0, 0)
    frame.BackgroundTransparency = 1
    icon.ImageTransparency = 1
    title.TextTransparency = 1
    msg.TextTransparency = 1
    accent.BackgroundTransparency = 1
    barBg.BackgroundTransparency = 1
    bar.BackgroundTransparency = 1

    TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.1
    }):Play()
    TweenService:Create(icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
    TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(msg, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(accent, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(barBg, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(bar, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 300, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(icon, TweenInfo.new(0.25), {ImageTransparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        TweenService:Create(msg, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        TweenService:Create(accent, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        TweenService:Create(barBg, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        TweenService:Create(bar, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        task.wait(0.4)
        frame:Destroy()
    end)
end

_G.HappyHubNotify = Notify

local typingTokens = {}

local function registerTyping(label, fullText, speed)
    if not label or not fullText then return end
    table.insert(typingTokens, {
        Label    = label,
        FullText = fullText,
        Speed    = speed or 0.02,
        Token    = {},
    })
end

local function playTyping(tab)
    if not tab then return end
    for _, entry in ipairs(typingTokens) do
        local lbl = entry.Label
        if lbl and lbl.Parent and lbl:IsDescendantOf(tab.Content) then
            local token = {}
            entry.Token = token
            local full = entry.FullText
            lbl.Text = ""
            task.spawn(function()
                for i = 1, #full do
                    if entry.Token ~= token then return end
                    if not lbl or not lbl.Parent then return end
                    lbl.Text = string.sub(full, 1, i)
                    task.wait(entry.Speed)
                end
                if entry.Token == token and lbl and lbl.Parent then
                    lbl.Text = full
                end
            end)
        end
    end
end

local function stopAllTyping()
    for _, entry in ipairs(typingTokens) do
        entry.Token = {}
    end
end

local CSGOHub = {}

function CSGOHub:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HappyHub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Enabled = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 1
    MainFrame.Parent = ScreenGui
    makeCorner(MainFrame, 12)
    makeStroke(MainFrame, Colors.Accent, 1, 0.7)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5028857084"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    Shadow.ZIndex = 0
    Shadow.Parent = MainFrame
    makeCorner(Shadow, 12)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 56)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    TopBar.BackgroundTransparency = 0.1
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.ZIndex = 2
    TopBar.Parent = MainFrame
    makeCorner(TopBar, 12)

    local TopBarGradient = Instance.new("UIGradient")
    TopBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    TopBarGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.55),
        NumberSequenceKeypoint.new(1, 1),
    })
    TopBarGradient.Rotation = 0
    TopBarGradient.Parent = TopBar

    local TopBarMask = Instance.new("Frame")
    TopBarMask.Size = UDim2.new(1, 0, 0, 12)
    TopBarMask.Position = UDim2.new(0, 0, 1, -12)
    TopBarMask.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    TopBarMask.BackgroundTransparency = 0.1
    TopBarMask.BorderSizePixel = 0
    TopBarMask.ZIndex = 3
    TopBarMask.Parent = TopBar

    local TopIcon = Instance.new("ImageLabel")
    TopIcon.Name = "TopIcon"
    TopIcon.Size = UDim2.fromOffset(32, 32)
    TopIcon.Position = UDim2.new(0, 16, 0.5, -16)
    TopIcon.BackgroundTransparency = 1
    TopIcon.Image = MAIN_ICON
    TopIcon.ZIndex = 4
    TopIcon.Parent = TopBar
    makeCorner(TopIcon, 8)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -140, 1, 0)
    TitleLabel.Position = UDim2.new(0, 58, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = title or "Happy Hub"
    TitleLabel.ZIndex = 4
    TitleLabel.Parent = TopBar

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
    MinimizeButton.Position = UDim2.new(1, -82, 0.5, -16)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = ""
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.ZIndex = 4
    MinimizeButton.Parent = TopBar
    makeCorner(MinimizeButton, 8)

    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Size = UDim2.fromOffset(16, 16)
    MinimizeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Image = MIN_ICON
    MinimizeIcon.ImageColor3 = Colors.TextSecondary
    MinimizeIcon.ZIndex = 5
    MinimizeIcon.Parent = MinimizeButton

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -44, 0.5, -16)
    CloseButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    CloseButton.ZIndex = 4
    CloseButton.Parent = TopBar
    makeCorner(CloseButton, 8)

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.fromOffset(16, 16)
    CloseIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = CLOSE_ICON
    CloseIcon.ImageColor3 = Colors.TextSecondary
    CloseIcon.ZIndex = 5
    CloseIcon.Parent = CloseButton

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 200, 1, -73)
    TabContainer.Position = UDim2.new(0, 8, 0, 61)
    TabContainer.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    TabContainer.BackgroundTransparency = 0.2
    TabContainer.BorderSizePixel = 0
    TabContainer.ClipsDescendants = true
    TabContainer.ZIndex = 2
    TabContainer.Parent = MainFrame
    makeCorner(TabContainer, 10)

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -224, 1, -73)
    ContentArea.Position = UDim2.new(0, 216, 0, 61)
    ContentArea.BackgroundColor3 = Colors.Background
    ContentArea.BackgroundTransparency = 0.4
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.ZIndex = 2
    ContentArea.Parent = MainFrame
    makeCorner(ContentArea, 10)

    local KeybindsPanel = Instance.new("Frame")
    KeybindsPanel.Name = "KeybindsPanel"
    KeybindsPanel.Size = UDim2.new(0, 140, 0, 128)
    KeybindsPanel.Position = UDim2.new(1, 10, 0, 70)
    KeybindsPanel.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    KeybindsPanel.BackgroundTransparency = 0.15
    KeybindsPanel.BorderSizePixel = 0
    KeybindsPanel.ZIndex = 5
    KeybindsPanel.Parent = MainFrame
    makeCorner(KeybindsPanel, 10)
    makeStroke(KeybindsPanel, Colors.Accent, 1, 0.7)

    local KeybindsTitle = Instance.new("TextLabel")
    KeybindsTitle.Size = UDim2.new(1, -16, 0, 20)
    KeybindsTitle.Position = UDim2.new(0, 8, 0, 6)
    KeybindsTitle.BackgroundTransparency = 1
    KeybindsTitle.Font = Enum.Font.GothamBold
    KeybindsTitle.TextSize = 11
    KeybindsTitle.TextColor3 = Colors.Accent
    KeybindsTitle.TextXAlignment = Enum.TextXAlignment.Left
    KeybindsTitle.Text = "LEFT KEYBINDS"
    KeybindsTitle.ZIndex = 6
    KeybindsTitle.Parent = KeybindsPanel

    local function makeKeybindRow(parent, key, label, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -16, 0, 22)
        row.Position = UDim2.new(0, 8, 0, 28 + ((order - 1) * 24))
        row.BackgroundTransparency = 1
        row.ZIndex = 6
        row.Parent = parent

        local keyBadge = Instance.new("TextLabel")
        keyBadge.Size = UDim2.new(0, 22, 0, 18)
        keyBadge.Position = UDim2.new(0, 0, 0.5, -9)
        keyBadge.BackgroundColor3 = Colors.Accent
        keyBadge.Text = key
        keyBadge.TextColor3 = Colors.Background
        keyBadge.Font = Enum.Font.GothamBold
        keyBadge.TextSize = 11
        keyBadge.BorderSizePixel = 0
        keyBadge.ZIndex = 6
        keyBadge.Parent = row
        makeCorner(keyBadge, 4)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -28, 1, 0)
        lbl.Position = UDim2.new(0, 28, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 11
        lbl.TextColor3 = Colors.TextSecondary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = label
        lbl.ZIndex = 6
        lbl.Parent = row
    end

    makeKeybindRow(KeybindsPanel, "T", "Toggle Aimbot", 1)
    makeKeybindRow(KeybindsPanel, "O", "Toggle ESP", 2)
    makeKeybindRow(KeybindsPanel, "F3", "Toggle UI", 3)

    local DragBar = Instance.new("Frame")
    DragBar.Name = "DragBar"
    DragBar.Size = UDim2.new(0.12, 0, 0, 4)
    DragBar.AnchorPoint = Vector2.new(0.5, 1)
    DragBar.Position = UDim2.new(0.5, 0, 1, -6)
    DragBar.BackgroundColor3 = Colors.Text
    DragBar.BackgroundTransparency = 0.3
    DragBar.BorderSizePixel = 0
    DragBar.Active = true
    DragBar.ZIndex = 4
    DragBar.Parent = MainFrame
    makeCorner(DragBar, 2)

    local window = {
        ScreenGui    = ScreenGui,
        MainFrame    = MainFrame,
        TabContainer = TabContainer,
        ContentArea  = ContentArea,
        Tabs         = {},
        ActiveTab    = nil,
        IsVisible    = true,
        Minimized    = false,
    }

    local dragging, dragStart, startPos = false, nil, nil

    local function beginDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end

    local function updateDrag(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    local function endDrag()
        dragging = false
    end

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    DragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    DragBar.MouseEnter:Connect(function()
        TweenService:Create(DragBar, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    DragBar.MouseLeave:Connect(function()
        TweenService:Create(DragBar, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)

    local function hideUI()
        closeAllDropdowns()
        window.IsVisible = false
        MainFrame.Visible = false
    end

    local function showUI()
        window.IsVisible = true
        MainFrame.Visible = true
    end

    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 0, 0)}):Play()
        TweenService:Create(CloseIcon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
        TweenService:Create(CloseIcon, TweenInfo.new(0.15), {ImageColor3 = Colors.TextSecondary}):Play()
    end)
    CloseButton.MouseButton1Click:Connect(hideUI)

    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Hover}):Play()
    end)
    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
    end)
    MinimizeButton.MouseButton1Click:Connect(function()
        closeAllDropdowns()
        window.Minimized = not window.Minimized
        local target = window.Minimized and UDim2.new(0, 700, 0, 56) or UDim2.new(0, 700, 0, 450)
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = target}):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F3 then
            closeAllDropdowns()
            if window.IsVisible then hideUI() else showUI() end
        end
    end)

    function window:CreateTab(name, iconId)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -20, 0, 40)
        TabButton.Position = UDim2.new(0, 10, 0, 10 + (#self.Tabs * 50))
        TabButton.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        TabButton.BackgroundTransparency = 0.3
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 15
        TabButton.TextColor3 = Colors.TextSecondary
        TabButton.Text = ""
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.ZIndex = 3
        TabButton.Parent = self.TabContainer
        makeCorner(TabButton, 8)

        local icon = Instance.new("ImageLabel")
        icon.Name = "TabIcon"
        icon.Size = UDim2.fromOffset(22, 22)
        icon.Position = UDim2.new(0, 14, 0.5, -11)
        icon.BackgroundTransparency = 1
        icon.Image = iconId and ("rbxassetid://" .. tostring(iconId)) or ""
        icon.ImageColor3 = Colors.TextSecondary
        icon.ScaleType = Enum.ScaleType.Fit
        icon.ZIndex = 4
        icon.Parent = TabButton

        local txt = Instance.new("TextLabel")
        txt.Name = "TabText"
        txt.Size = UDim2.new(1, -55, 1, 0)
        txt.Position = UDim2.new(0, 55, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamSemibold
        txt.TextSize = 15
        txt.TextColor3 = Colors.TextSecondary
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Text = name
        txt.ZIndex = 4
        txt.Parent = TabButton

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, -8, 1, -8)
        TabContent.Position = UDim2.new(0, 4, 0, 4)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Colors.Accent
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ClipsDescendants = true
        TabContent.ZIndex = 3
        TabContent.Parent = self.ContentArea
        TabContent.Visible = false
        makeCorner(TabContent, 8)

        local tab = {
            Button   = TabButton,
            Content  = TabContent,
            Elements = {},
            YOffset  = 20,
            Name     = name,
            TextRef  = txt,
            IconRef  = icon,
        }

        TabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= tab then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= tab then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(5, 5, 5)}):Play()
            end
        end)
        TabButton.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then self:SelectTab(tab) end
        return tab
    end

    function window:SelectTab(tab)
        closeAllDropdowns()
        if self.ActiveTab then
            self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            self.ActiveTab.Button.BackgroundTransparency = 0.3
            if self.ActiveTab.TextRef then
                self.ActiveTab.TextRef.TextColor3 = Colors.TextSecondary
            end
            if self.ActiveTab.IconRef then
                TweenService:Create(self.ActiveTab.IconRef, TweenInfo.new(0.15), {ImageColor3 = Colors.TextSecondary}):Play()
            end
            self.ActiveTab.Content.Visible = false
        end
        self.ActiveTab = tab
        tab.Button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tab.Button.BackgroundTransparency = 0
        if tab.TextRef then
            tab.TextRef.TextColor3 = Colors.Accent
        end
        if tab.IconRef then
            TweenService:Create(tab.IconRef, TweenInfo.new(0.15), {ImageColor3 = Colors.Accent}):Play()
        end
        tab.Content.Visible = true

        stopAllTyping()
        task.wait(0.03)
        playTyping(tab)
    end

    local function addElement(tab, el)
        el.Position = UDim2.new(0, 20, 0, tab.YOffset)
        el.Parent = tab.Content
        tab.YOffset += el.Size.Y.Offset + 10
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.YOffset + 30)
        table.insert(tab.Elements, el)
        return el
    end

    function window:CreateLabel(tab, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -40, 0, 25)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = 16
        l.TextColor3 = Colors.Accent
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text
        l.ZIndex = 3
        registerTyping(l, text)
        return addElement(tab, l)
    end

    function window:CreateButton(tab, text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -40, 0, 35)
        b.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        b.BackgroundTransparency = 0.3
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        b.TextColor3 = Colors.Text
        b.Text = text
        b.AutoButtonColor = false
        b.ZIndex = 3
        makeCorner(b, 8)
        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Hover}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(5,5,5)}):Play()
        end)
        b.MouseButton1Click:Connect(function() if cb then cb() end end)
        registerTyping(b, text)
        return addElement(tab, b)
    end

    function window:CreateToggle(tab, text, default, cb)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(1, -40, 0, 35)
        c.BackgroundTransparency = 1
        c.ZIndex = 3

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.7, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 14
        l.TextColor3 = Colors.Text
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text
        l.ZIndex = 3
        l.Parent = c
        registerTyping(l, text)

        local t = Instance.new("TextButton")
        t.Size = UDim2.fromOffset(30, 30)
        t.Position = UDim2.new(1, -30, 0.5, -15)
        t.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
        t.BorderSizePixel = 0
        t.Text = ""
        t.AutoButtonColor = false
        t.ZIndex = 3
        t.Parent = c
        makeCorner(t, 8)

        local state = default or false

        local function setVisual(v)
            state = v
            t.BackgroundColor3 = v and Colors.ToggleOn or Colors.ToggleOff
        end

        t.MouseButton1Click:Connect(function()
            setVisual(not state)
            if cb then cb(state) end
        end)
        addElement(tab, c)
        return {
            SetState = function(v, silent)
                setVisual(v)
                if not silent and cb then cb(v) end
            end,
            GetState = function() return state end,
        }
    end

    function window:CreateSlider(tab, text, min, max, default, cb)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(1, -40, 0, 50)
        c.BackgroundTransparency = 1
        c.ZIndex = 3

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 25)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 14
        l.TextColor3 = Colors.Text
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text .. ": " .. tostring(default)
        l.ZIndex = 3
        l.Parent = c
        registerTyping(l, text .. ": " .. tostring(default))

        local sf = Instance.new("Frame")
        sf.Size = UDim2.new(1, 0, 0, 6)
        sf.Position = UDim2.new(0, 0, 1, -15)
        sf.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        sf.BorderSizePixel = 0
        sf.ZIndex = 3
        sf.Parent = c
        makeCorner(sf, 3)

        local f = Instance.new("Frame")
        f.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        f.BackgroundColor3 = Colors.Accent
        f.BorderSizePixel = 0
        f.ZIndex = 3
        f.Parent = sf
        makeCorner(f, 3)

        local k = Instance.new("TextButton")
        k.Size = UDim2.fromOffset(14, 14)
        k.Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7)
        k.BackgroundColor3 = Colors.Accent
        k.BorderSizePixel = 0
        k.Text = ""
        k.AutoButtonColor = false
        k.ZIndex = 4
        k.Parent = sf
        makeCorner(k, 7)

        local val = default
        local drag = false

        local function updateFromMouse()
            local mp = UserInputService:GetMouseLocation()
            local rx = mp.X - sf.AbsolutePosition.X
            local p = math.clamp(rx / sf.AbsoluteSize.X, 0, 1)
            val = math.floor((min + (max-min)*p) * 100) / 100
            f.Size = UDim2.new(p, 0, 1, 0)
            k.Position = UDim2.new(p, -7, 0.5, -7)
            l.Text = text .. ": " .. tostring(val)
            if cb then cb(val) end
        end

        k.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                updateFromMouse()
            end
        end)

        addElement(tab, c)
    end

    function window:CreateDropdown(tab, text, options, default, cb)
        local c = Instance.new("Frame")
        c.Size = UDim2.new(1, -40, 0, 60)
        c.BackgroundTransparency = 1
        c.ClipsDescendants = false
        c.ZIndex = 10

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.5, 0, 0, 30)
        l.Position = UDim2.new(0, 0, 0, 15)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamSemibold
        l.TextSize = 14
        l.TextColor3 = Colors.Text
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text
        l.ZIndex = 10
        l.Parent = c
        registerTyping(l, text)

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.5, -10, 0, 40)
        b.Position = UDim2.new(0.5, 10, 0, 10)
        b.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        b.BackgroundTransparency = 0.3
        b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 14
        b.TextColor3 = Colors.Text
        b.Text = default or options[1] or ""
        b.AutoButtonColor = false
        b.ZIndex = 10
        b.Parent = c
        makeCorner(b, 8)

        local list = Instance.new("Frame")
        list.Size = UDim2.new(0.5, -10, 0, (#options * 36) + 10)
        list.Position = UDim2.new(0.5, 10, 1, 5)
        list.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
        list.BackgroundTransparency = 0.1
        list.BorderSizePixel = 0
        list.Visible = false
        list.ZIndex = 50
        list.ClipsDescendants = false
        list.Parent = c
        makeCorner(list, 8)
        makeStroke(list, Colors.Accent, 1, 0.6)

        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop = UDim.new(0, 5)
        listPad.PaddingBottom = UDim.new(0, 5)
        listPad.Parent = list

        local sel = default or options[1] or ""

        local function closeDropdown()
            list.Visible = false
        end

        table.insert(openDropdowns, closeDropdown)

        for i, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, -10, 0, 30)
            ob.Position = UDim2.new(0, 5, 0, 5 + ((i-1) * 36))
            ob.BackgroundColor3 = (opt == sel) and Colors.Accent or Color3.fromRGB(8, 8, 8)
            ob.BackgroundTransparency = (opt == sel) and 0 or 0.2
            ob.BorderSizePixel = 0
            ob.Font = Enum.Font.GothamSemibold
            ob.TextSize = 14
            ob.TextColor3 = (opt == sel) and Color3.fromRGB(0, 0, 0) or Colors.Text
            ob.Text = opt
            ob.AutoButtonColor = false
            ob.ZIndex = 51
            ob.Parent = list
            makeCorner(ob, 6)

            ob.MouseEnter:Connect(function()
                if ob.Text ~= sel then
                    TweenService:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                end
            end)
            ob.MouseLeave:Connect(function()
                if ob.Text ~= sel then
                    TweenService:Create(ob, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(8, 8, 8)}):Play()
                end
            end)

            ob.MouseButton1Click:Connect(function()
                sel = opt
                b.Text = opt
                list.Visible = false
                for _, ch in ipairs(list:GetChildren()) do
                    if ch:IsA("TextButton") then
                        if ch.Text == sel then
                            ch.BackgroundColor3 = Colors.Accent
                            ch.BackgroundTransparency = 0
                            ch.TextColor3 = Color3.fromRGB(0, 0, 0)
                        else
                            ch.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
                            ch.BackgroundTransparency = 0.2
                            ch.TextColor3 = Colors.Text
                        end
                    end
                end
                if cb then cb(sel) end
            end)
        end

        b.MouseEnter:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Colors.Hover}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(5, 5, 5)}):Play()
        end)

        b.MouseButton1Click:Connect(function()
            local wasVisible = list.Visible
            closeAllDropdowns()
            if wasVisible then return end

            local listHeight = list.Size.Y.Offset + 8
            local tabContent = tab.Content
            local cAbsY = c.AbsolutePosition.Y
            local cAbsH = c.AbsoluteSize.Y
            local tabAbsY = tabContent.AbsolutePosition.Y
            local tabAbsH = tabContent.AbsoluteSize.Y

            local bottomSpace = (tabAbsY + tabAbsH) - (cAbsY + cAbsH)

            if bottomSpace < listHeight then
                list.Position = UDim2.new(0.5, 10, 0, -listHeight + 5)
            else
                list.Position = UDim2.new(0.5, 10, 1, 5)
            end

            list.Visible = true
        end)

        addElement(tab, c)
    end

    return window
end

local win = CSGOHub:CreateWindow("Happy Hub")

local aimbotTab  = win:CreateTab("Aimbot", AIM_ICON)
local visualsTab = win:CreateTab("Visuals", VIS_ICON)
local miscTab    = win:CreateTab("Misc", MISC_ICON)

local aimbotToggleRef, espToggleRef, nametagToggleRef
local infJumpToggleRef, noclipToggleRef, godToggleRef, antiAFKToggleRef

win:CreateLabel(aimbotTab, "Aimbot Settings")

aimbotToggleRef = win:CreateToggle(aimbotTab, "Enabled (T)", AimbotSettings.Enabled, function(v)
    AimbotSettings.Enabled = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not v then
        lockedTarget = nil
        if hum then hum.AutoRotate = true end
    else
        if hum then hum.AutoRotate = false end
    end
    Notify(v and "Aimbot enabled" or "Aimbot disabled")
end)

win:CreateSlider(aimbotTab, "FOV", 20, 800, AimbotSettings.FOV, function(v)
    AimbotSettings.FOV = v
end)
win:CreateSlider(aimbotTab, "Smoothing", 0.05, 1, AimbotSettings.Smoothing, function(v)
    AimbotSettings.Smoothing = v
end)
win:CreateSlider(aimbotTab, "Max Distance", 100, 2000, AimbotSettings.MaxDistance, function(v)
    AimbotSettings.MaxDistance = v
end)
win:CreateToggle(aimbotTab, "Wall Check", AimbotSettings.WallCheck, function(v)
    AimbotSettings.WallCheck = v
end)
win:CreateToggle(aimbotTab, "Team Check", AimbotSettings.TeamCheck, function(v)
    AimbotSettings.TeamCheck = v
end)
win:CreateToggle(aimbotTab, "Show FOV Circle", AimbotSettings.ShowFOV, function(v)
    AimbotSettings.ShowFOV = v
end)
win:CreateToggle(aimbotTab, "Rotate Rig", AimbotSettings.RotateRig, function(v)
    AimbotSettings.RotateRig = v
end)
win:CreateDropdown(aimbotTab, "Target", {"Head", "Torso", "Random"}, "Head", function(sel)
    AimbotSettings.Target = sel
    Notify("Target: " .. sel)
end)

win:CreateLabel(visualsTab, "Visual Settings")

espToggleRef = win:CreateToggle(visualsTab, "Rivals ESP (O)", VisualSettings.RivalsESP, function(v)
    VisualSettings.RivalsESP = v
    if v then startRivalsESP() else stopRivalsESP() end
    Notify(v and "ESP enabled" or "ESP disabled")
end)

nametagToggleRef = win:CreateToggle(visualsTab, "Name Tags", VisualSettings.NameTags, function(v)
    VisualSettings.NameTags = v
    if v then
        startNameTagUpdater()
        refreshAllRivalsESP()
    else
        stopNameTagUpdater()
        refreshAllRivalsESP()
    end
end)

win:CreateLabel(miscTab, "Movement")

infJumpToggleRef = win:CreateToggle(miscTab, "Infinite Jump", MiscSettings.InfJump, function(v)
    MiscSettings.InfJump = v
    Notify(v and "Infinite Jump enabled" or "Infinite Jump disabled")
end)

noclipToggleRef = win:CreateToggle(miscTab, "Noclip", MovementSettings.Noclip, function(v)
    MovementSettings.Noclip = v
    if v then
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end)

godToggleRef = win:CreateToggle(miscTab, "God Mode", MovementSettings.God, function(v)
    MovementSettings.God = v
    if v then
        godConn = RunService.Heartbeat:Connect(function()
            local hum = getHumanoid()
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if godConn then godConn:Disconnect(); godConn = nil end
    end
end)

antiAFKToggleRef = win:CreateToggle(miscTab, "Anti-AFK", MiscSettings.AntiAFK, function(v)
    MiscSettings.AntiAFK = v
    if v then
        local vu = game:GetService("VirtualUser")
        antiAFKConn = LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        local newState = not AimbotSettings.Enabled
        if aimbotToggleRef then
            aimbotToggleRef.SetState(newState, true)
        end
        AimbotSettings.Enabled = newState
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not newState then
            lockedTarget = nil
            if hum then hum.AutoRotate = true end
        else
            if hum then hum.AutoRotate = false end
        end
        Notify(newState and "Aimbot enabled (T)" or "Aimbot disabled (T)")
    elseif input.KeyCode == Enum.KeyCode.O then
        local newState = not VisualSettings.RivalsESP
        if espToggleRef then
            espToggleRef.SetState(newState, true)
        end
        VisualSettings.RivalsESP = newState
        if newState then startRivalsESP() else stopRivalsESP() end
        Notify(newState and "ESP enabled (O)" or "ESP disabled (O)")
    end
end)

local frameCounter = 0

local function onRenderStep()
    if not LocalPlayer.Character then return end
    Camera = workspace.CurrentCamera
    if not Camera then return end

    frameCounter = frameCounter + 1

    if frameCounter % 5 == 0 then
        rebuildRayFilter()
    end

    local crosshair = getCrosshairPosition()

    if fovCircle then
        if AimbotSettings.Enabled and AimbotSettings.ShowFOV then
            fovCircle.Position = crosshair
            fovCircle.Radius = AimbotSettings.FOV
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end

    if AimbotSettings.Enabled then
        local targetPart = getAimTarget(crosshair)
        if targetPart then
            aimViaMouse(targetPart)
        elseif AimbotSettings.RotateRig then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local camLook = Camera.CFrame.LookVector
                local targetYaw = math.atan2(-camLook.X, -camLook.Z)
                local currentYaw = math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z)
                local diff = math.atan2(
                    math.sin(targetYaw - currentYaw),
                    math.cos(targetYaw - currentYaw)
                )
                local newYaw = currentYaw + diff * 0.4

                local look  = Vector3.new(-math.sin(newYaw), 0, -math.cos(newYaw))
                local right = Vector3.new(math.cos(newYaw), 0, -math.sin(newYaw))

                hrp.CFrame = CFrame.fromMatrix(
                    hrp.CFrame.Position,
                    right,
                    Vector3.new(0, 1, 0),
                    -look
                )
            end
        end
    else
        lockedTarget = nil
    end
end

RunService:BindToRenderStep("HappyHub", Enum.RenderPriority.Camera.Value + 1, onRenderStep)

Notify("Happy Hub loaded")
