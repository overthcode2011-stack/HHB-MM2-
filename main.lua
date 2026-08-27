--|| Happy Hub ~ v10 ~ By Odecode ||--
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local TextChannels = TextChatService:FindFirstChild("TextChannels")

local player = Players.LocalPlayer
--|| Themes ||--
local THEMES = {
	Dark = {
		accent    = Color3.fromRGB(0, 210, 100),
		bg        = Color3.fromRGB(10, 10, 10),
		text      = Color3.fromRGB(255, 255, 255),
		subtext   = Color3.fromRGB(160, 160, 160),
		danger    = Color3.fromRGB(220, 60, 60),
		knobOff   = Color3.fromRGB(50, 50, 50),
		icon      = "rbxassetid://104348663064077",
	},
	Purple = {
		accent    = Color3.fromRGB(160, 80, 255), 
		bg        = Color3.fromRGB(12, 8, 20),
		text      = Color3.fromRGB(240, 228, 255),
		subtext   = Color3.fromRGB(160, 140, 200),
		danger    = Color3.fromRGB(220, 60, 60),
		knobOff   = Color3.fromRGB(55, 35, 80),
		icon      = "rbxassetid://104348663064077",
	},
	Blue = {
		accent    = Color3.fromRGB(40, 160, 255),
		bg        = Color3.fromRGB(6, 12, 22),
		text      = Color3.fromRGB(215, 232, 255),
		subtext   = Color3.fromRGB(120, 160, 210),
		danger    = Color3.fromRGB(220, 60, 60),
		knobOff   = Color3.fromRGB(25, 45, 80),
		icon      = "rbxassetid://104348663064077",
	},
	Red = {
		accent    = Color3.fromRGB(230, 50, 50),
		bg        = Color3.fromRGB(15, 5, 5),
		text      = Color3.fromRGB(255, 228, 228),
		subtext   = Color3.fromRGB(190, 140, 140),
		danger    = Color3.fromRGB(230, 50, 50),
		knobOff   = Color3.fromRGB(70, 28, 28),
		icon      = "rbxassetid://104348663064077",
	},
	White = {
		accent    = Color3.fromRGB(0, 150, 80),
		bg        = Color3.fromRGB(236, 236, 236),
		text      = Color3.fromRGB(15, 15, 15),
		subtext   = Color3.fromRGB(90, 90, 90),
		danger    = Color3.fromRGB(200, 40, 40),
		knobOff   = Color3.fromRGB(170, 170, 170),
		icon      = "rbxassetid://104348663064077",
	},
	Valentine = {
		accent    = Color3.fromRGB(255, 105, 155),
		bg        = Color3.fromRGB(28, 8, 18),
		text      = Color3.fromRGB(255, 220, 235),
		subtext   = Color3.fromRGB(210, 150, 180),
		danger    = Color3.fromRGB(240, 50, 90),
		knobOff   = Color3.fromRGB(80, 25, 50),
		icon      = "rbxassetid://84155924426327",
	},
	Cat = {
		accent    = Color3.fromRGB(180, 180, 180),
		bg        = Color3.fromRGB(5, 5, 5),
		text      = Color3.fromRGB(230, 230, 230),
		subtext   = Color3.fromRGB(110, 110, 110),
		danger    = Color3.fromRGB(200, 60, 60),
		knobOff   = Color3.fromRGB(30, 30, 30),
		icon      = "rbxassetid://85240387254442",
	},
}

local currentThemeName = "Dark"
local function T() return THEMES[currentThemeName] end

-- ✅ FIX 4: don't laugh, its my code 
local reg = {
	panels        = {},
	texts         = {},
	subtexts      = {},
	accentBgs     = {},
	accentTexts   = {},
	dangerTexts   = {},
	dangerStrokes = {},
	accentStrokes = {},
	pills         = {},
	sliderFills   = {},
	sliderHandles = {},
	sidebarBtns   = {},
	scrollBars    = {},
	bgTexts       = {}, 
}

local activeTabName = "Home"
local iconRefs = {}
local customIconOverride = nil
local execTabBtnRefs = {}
local activeExecTabIdx = 1

-- ✅ FIX 2: I just inprove my script with IA sometimes, be grateful you have my code, or I'll consider you a piece of trash.
local HHBFuncs = {}

local function applyTheme()
	local th = T()
	for _, o in ipairs(reg.panels)        do if o and o.Parent then o.BackgroundColor3    = th.bg      end end
	for _, o in ipairs(reg.texts)         do if o and o.Parent then o.TextColor3           = th.text    end end
	for _, o in ipairs(reg.subtexts)      do if o and o.Parent then o.TextColor3           = th.subtext end end
	for _, o in ipairs(reg.accentBgs)     do if o and o.Parent then o.BackgroundColor3    = th.accent  end end
	for _, o in ipairs(reg.accentTexts)   do if o and o.Parent then o.TextColor3           = th.accent  end end
	for _, o in ipairs(reg.dangerTexts)   do if o and o.Parent then o.TextColor3           = th.danger  end end
	for _, o in ipairs(reg.dangerStrokes) do if o and o.Parent then o.Color                = th.danger  end end
	for _, o in ipairs(reg.accentStrokes) do if o and o.Parent then o.Color                = th.accent  end end
	for _, o in ipairs(reg.sliderFills)   do if o and o.Parent then o.BackgroundColor3    = th.accent  end end
	for _, o in ipairs(reg.sliderHandles) do if o and o.Parent then o.BackgroundColor3    = th.text    end end
	for _, o in ipairs(reg.scrollBars)    do if o and o.Parent then o.ScrollBarImageColor3 = th.accent  end end
	for _, o in ipairs(reg.bgTexts)       do if o and o.Parent then o.TextColor3           = th.bg      end end
	for _, d in ipairs(reg.pills) do
		local pill, knob, getState = d[1], d[2], d[3]
		if pill and pill.Parent then pill.BackgroundColor3 = getState() and th.accent or th.knobOff end
		if knob and knob.Parent then knob.BackgroundColor3 = th.text end
	end
	for _, d in ipairs(reg.sidebarBtns) do
		local btn, name = d[1], d[2]
		if btn and btn.Parent then
			if name == activeTabName then
				btn.BackgroundColor3       = th.accent
				btn.BackgroundTransparency = 0
				btn.TextColor3             = th.bg
			else
				btn.BackgroundColor3       = th.bg
				btn.BackgroundTransparency = 0.35
				btn.TextColor3             = th.text
			end
		end
	end
	for _, il in ipairs(iconRefs) do
		if il and il.Parent then
			if il:IsA("ImageLabel") or il:IsA("ImageButton") then
				il.ImageColor3 = th.accent
			end
		end
	end
	if toggleBtn and toggleBtn.Parent then
		toggleBtn.BackgroundColor3 = th.bg
		toggleBtn.ImageColor3      = th.accent
		toggleBtn.Image            = customIconOverride or th.icon
	end
	if headerIcon and headerIcon.Parent then
		headerIcon.Image = customIconOverride or th.icon
	end
	if minimizeBtn and minimizeBtn.Parent then
		minimizeBtn.ImageColor3 = th.text
	end
	for _, d in ipairs(execTabBtnRefs) do
		local btn, idx = d[1], d[2]
		if btn and btn.Parent then
			if idx == activeExecTabIdx then
				btn.BackgroundColor3       = th.accent
				btn.BackgroundTransparency = 0
				btn.TextColor3             = th.bg
			else
				btn.BackgroundColor3       = th.bg
				btn.BackgroundTransparency = 0.30
				btn.TextColor3             = th.subtext
			end
		end
	end
	if HHBFuncs.refreshWaypoints then HHBFuncs.refreshWaypoints() end
	if HHBFuncs.refreshPlayers   then HHBFuncs.refreshPlayers()   end
end

---------|| Global config ||----------
local PANEL_TRANSPARENCY = 0.75
local ICON_ID            = "rbxassetid://104348663064077"
local CLOSE_ICON_ID      = "rbxassetid://115558082558028"
local ADD_WP_ICON_ID     = "rbxassetid://117786081881229"
local TP_ICON            = "rbxassetid://2129457776"
local DEL_ICON           = "rbxassetid://120824454689592"
local CLEAR_ICON_ID      = "rbxassetid://80646119892661"
local EXEC_ICON_ID       = "rbxassetid://116651535114885"
local VERIFIED_ICON_ID   = "rbxassetid://13737813988"

local DEFAULT_WALKSPEED  = 16
local DEFAULT_JUMPPOWER  = 50
local DEFAULT_FLYSPEED   = 40

local waypoints = {}
local Maps_mm2 = {
    "ResearchFacility", "House2", "Mansion2", "Hotel",
    "MilBase", "Bank2", "BioLab", "Factory",
    "Workplace", "PoliceStation", "Office3","Hospital3"
}


-------------||  Helpers ||----------------

local function getHRP()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function nameExists(n)
	for _, wp in ipairs(waypoints) do if wp.name == n then return true end end
	return false
end
local function uniqueName(base)
	if not nameExists(base) then return base end
	local i = 2
	while nameExists(base.." ("..i..")") do i += 1 end
	return base.." ("..i..")"
end

-- ✅ FUNCIONES GLOBALES PARA MM2 (definidas UNA SOLA VEZ)
local function findGunDropCFrame()
    for _, map in ipairs(workspace:GetChildren()) do
        if map:IsA("Model") and map.Name:find("Map") then
            local gunDrop = map:FindFirstChild("GunDrop", true)
            if gunDrop and gunDrop:IsA("BasePart") then
                return gunDrop.CFrame
            end
        end
    end
    return workspace:FindFirstChild("GunDrop") and workspace.GunDrop.CFrame or nil
end

local function getPlayerWithItem(itemName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local bp = plr:FindFirstChild("Backpack")
            if (char and char:FindFirstChild(itemName)) or (bp and bp:FindFirstChild(itemName)) then
                return plr
            end
        end
    end
    return nil
end

local function teleportTo(targetPlr)
    if not targetPlr then return false end
    local targetChar = targetPlr.Character
    if not targetChar then return false end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myHRP = getHRP()
    if targetHRP and myHRP then
        myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

local function obtainSheriffGun()
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local gunCFrame = findGunDropCFrame()
    if not gunCFrame then return false end
    local originalCF = hrp.CFrame
    hrp.CFrame = gunCFrame + Vector3.new(0, 5, 0)
    task.wait(0.5)
    hrp.CFrame = originalCF
    local bp = player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Gun") then return true end
    return false
end


-------------||  reutilizable styles ||----------------
local function styleCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 10)
	c.Parent = obj
end
local function styleStroke(obj, t, color, thick)
	local s = Instance.new("UIStroke")
	s.Color        = color or T().text
	s.Thickness    = thick or 1
	s.Transparency = t or 0.78
	s.Parent = obj
	return s
end
local function stylePadding(obj, top, bot, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top   or 0)
	p.PaddingBottom = UDim.new(0, bot   or 0)
	p.PaddingLeft   = UDim.new(0, left  or 0)
	p.PaddingRight  = UDim.new(0, right or 0)
	p.Parent = obj
end
local twI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-------------||  toggle row ||----------------
local function makeToggleRow(parent, labelText, layoutOrder)
	local th = T()
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,50)
	row.BackgroundColor3 = th.bg
	row.BackgroundTransparency = 0.25
	row.BorderSizePixel = 0
	row.LayoutOrder = layoutOrder or 0
	row.Parent = parent
	styleCorner(row, UDim.new(0,10))
	styleStroke(row, 0.88)
	table.insert(reg.panels, row)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-80,1,0)
	lbl.Position = UDim2.new(0,14,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = th.text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextSize = 15
	lbl.Font = Enum.Font.GothamSemibold
	lbl.Parent = row
	table.insert(reg.texts, lbl)

	local pill = Instance.new("TextButton")
	pill.Size = UDim2.new(0,56,0,30)
	pill.Position = UDim2.new(1,-66,0.5,-15)
	pill.BackgroundColor3 = th.knobOff
	pill.Text = ""
	pill.BorderSizePixel = 0
	pill.AutoButtonColor = false
	pill.Parent = row
	styleCorner(pill, UDim.new(1,0))

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0,24,0,24)
	knob.Position = UDim2.new(0,3,0.5,-12)
	knob.BackgroundColor3 = th.text
	knob.BorderSizePixel = 0
	knob.Parent = pill
	styleCorner(knob, UDim.new(1,0))

	local state = false
	local function setState(val)
		state = val
		TweenService:Create(pill, twI, {BackgroundColor3 = val and T().accent or T().knobOff}):Play()
		TweenService:Create(knob, twI, {
			Position = val and UDim2.new(0,29,0.5,-12) or UDim2.new(0,3,0.5,-12)
		}):Play()
	end
	local function getState() return state end
	table.insert(reg.pills, {pill, knob, getState})
	return pill, setState, getState
end

-------------||  slider row ||----------------
local function makeSliderRow(parent, labelText, minVal, maxVal, defVal, onChange, layoutOrder)
	local th = T()
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,62)
	row.BackgroundColor3 = th.bg
	row.BackgroundTransparency = 0.22
	row.BorderSizePixel = 0
	row.LayoutOrder = layoutOrder or 0
	row.Parent = parent
	styleCorner(row, UDim.new(0,10))
	styleStroke(row, 0.88)
	table.insert(reg.panels, row)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-70,0,24)
	lbl.Position = UDim2.new(0,14,0,8)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = th.text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextSize = 14
	lbl.Font = Enum.Font.GothamSemibold
	lbl.Parent = row
	table.insert(reg.texts, lbl)

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0,58,0,24)
	valLbl.Position = UDim2.new(1,-66,0,8)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(defVal)
	valLbl.TextColor3 = th.accent
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.TextSize = 14
	valLbl.Font = Enum.Font.GothamBold
	valLbl.Parent = row
	table.insert(reg.accentTexts, valLbl)

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1,-28,0,8)
	track.Position = UDim2.new(0,14,0,42)
	track.BackgroundColor3 = th.knobOff
	track.BorderSizePixel = 0
	track.Parent = row
	styleCorner(track, UDim.new(1,0))

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((defVal-minVal)/(maxVal-minVal),0,1,0)
	fill.BackgroundColor3 = th.accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	styleCorner(fill, UDim.new(1,0))
	table.insert(reg.sliderFills, fill)

	local handle = Instance.new("TextButton")
	handle.Size = UDim2.new(0,22,0,22)
	handle.AnchorPoint = Vector2.new(0.5,0.5)
	handle.Position = UDim2.new((defVal-minVal)/(maxVal-minVal),0,0.5,0)
	handle.BackgroundColor3 = th.text
	handle.Text = ""
	handle.BorderSizePixel = 0
	handle.AutoButtonColor = false
	handle.Parent = track
	styleCorner(handle, UDim.new(1,0))
	table.insert(reg.sliderHandles, handle)

	local cur = defVal
	local sliding, activeInput = false, nil
	local function updateFromX(absX)
		local tp, ts = track.AbsolutePosition.X, track.AbsoluteSize.X
		if ts == 0 then return end
		local ratio = math.clamp((absX-tp)/ts,0,1)
		local nv = math.floor(minVal + ratio*(maxVal-minVal))
		if nv == cur then return end
		cur = nv
		fill.Size       = UDim2.new(ratio,0,1,0)
		handle.Position = UDim2.new(ratio,0,0.5,0)
		valLbl.Text     = tostring(cur)
		if onChange then onChange(cur) end
	end

	local conns = {}
	conns[#conns+1] = handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true; activeInput = inp
		end
	end)
	conns[#conns+1] = track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true; activeInput = inp
			updateFromX(inp.Position.X)
		end
	end)
	conns[#conns+1] = UserInputService.InputChanged:Connect(function(inp)
		if not sliding then return end
		if inp.UserInputType == Enum.UserInputType.Touch then
			if activeInput and inp.Touch == activeInput.Touch then updateFromX(inp.Position.X) end
		elseif inp.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromX(inp.Position.X)
		end
	end)
	conns[#conns+1] = UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false; activeInput = nil
		end
	end)
	row.AncestryChanged:Connect(function()
		if not row:IsDescendantOf(game) then
			for _, c in ipairs(conns) do c:Disconnect() end
		end
	end)
	return row, function() return cur end
end

-------------||  Principal Gui  ||----------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HappyHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999   
screenGui.Parent = game:GetService("CoreGui")

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0.4, 0, 0.55, 0)
panel.Position = UDim2.new(0.5, 0, 0.5, 0)
panel.BackgroundColor3 = T().bg
panel.BackgroundTransparency = 0.6
panel.BorderSizePixel = 0
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.ClipsDescendants = true
panel.Visible = true
panel.Parent = screenGui
styleCorner(panel, UDim.new(0, 18))
styleStroke(panel, 0.65)
table.insert(reg.panels, panel)

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 28, 1, 28)
shadow.Position = UDim2.new(0, -14, 0, 14)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.ZIndex = panel.ZIndex - 1
shadow.Parent = panel
styleCorner(shadow, UDim.new(0, 22))

-------------||  header ||----------------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = T().bg
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = panel
styleCorner(header, UDim.new(0, 16))
table.insert(reg.panels, header)

local headerPatch = Instance.new("Frame")
headerPatch.Size = UDim2.new(1, 0, 0, 16)
headerPatch.Position = UDim2.new(0, 0, 1, -16)
headerPatch.BackgroundColor3 = T().bg
headerPatch.BackgroundTransparency = 0.08
headerPatch.BorderSizePixel = 0
headerPatch.Parent = header
table.insert(reg.panels, headerPatch)

local headerIcon = Instance.new("ImageLabel")
headerIcon.Size = UDim2.new(0, 30, 0, 30)
headerIcon.Position = UDim2.new(0, 14, 0.5, -15)
headerIcon.BackgroundTransparency = 1
headerIcon.Image = ICON_ID
headerIcon.ImageColor3 = T().accent
headerIcon.ScaleType = Enum.ScaleType.Fit
headerIcon.Parent = header
table.insert(iconRefs, headerIcon)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -110, 0, 26)
titleLabel.Position = UDim2.new(0, 52, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Happy Hub"
titleLabel.TextColor3 = T().text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextSize = 19
titleLabel.Font = Enum.Font.BuilderSansBold
titleLabel.Parent = header
table.insert(reg.texts, titleLabel)

local authorLabel = Instance.new("TextLabel")
authorLabel.Size = UDim2.new(1, -110, 0, 14)
authorLabel.Position = UDim2.new(0, 52, 0, 36)
authorLabel.BackgroundTransparency = 1
authorLabel.Text = "By @replicatedman · Keyless · MM2 Proyect"
authorLabel.TextColor3 = T().subtext
authorLabel.TextXAlignment = Enum.TextXAlignment.Left
authorLabel.TextSize = 10
authorLabel.Font = Enum.Font.Gotham
authorLabel.Parent = header
table.insert(reg.subtexts, authorLabel)

local minimizeBtn = Instance.new("ImageButton")
minimizeBtn.Size = UDim2.new(0, 38, 0, 38)
minimizeBtn.Position = UDim2.new(1, -46, 0.5, -19)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Image = CLOSE_ICON_ID
minimizeBtn.ImageColor3 = T().text
minimizeBtn.ScaleType = Enum.ScaleType.Fit
minimizeBtn.BorderSizePixel = 0
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = header

local isMinimized = false
local OPEN_SIZE = UDim2.new(0.4, 0, 0.55, 0)
local CLOSED_SIZE = UDim2.new(0.4, 0, 0, 58)
local originalTransparency = panel.BackgroundTransparency  -- guardamos 0.6

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetTransparency = isMinimized and 1 or originalTransparency
    local targetSize = isMinimized and CLOSED_SIZE or OPEN_SIZE
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    -- Animación de tamaño
    TweenService:Create(panel, tweenInfo, {Size = targetSize}):Play()
    -- Animación de transparencia (desvanecimiento)
    TweenService:Create(panel, tweenInfo, {BackgroundTransparency = targetTransparency}):Play()
end)

-- DRAG
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		dragInput = input
	end
end)
header.InputEnded:Connect(function(input)
	if input == dragInput then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-------------||  side bar and pages ||----------------
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0, 138, 1, -130)
sidebar.Position = UDim2.new(0, 8, 0, 62)
sidebar.BackgroundColor3 = T().bg
sidebar.BackgroundTransparency = 0.45
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 2
sidebar.ScrollBarImageColor3 = T().accent
sidebar.CanvasSize = UDim2.new(0,0,0,0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
sidebar.Parent = panel
styleCorner(sidebar, UDim.new(0,10))
styleStroke(sidebar, 0.80)
stylePadding(sidebar, 8,8,6,6)
table.insert(reg.panels, sidebar)
table.insert(reg.scrollBars, sidebar)

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0,6)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local tabDefs = {"Home","Waypoints","Players","ESP","Movement","Aimbot","Avatar","Scripts","Misc","Settings",}
local tabBtns = {}
for i, name in ipairs(tabDefs) do
	local btn = Instance.new("TextButton")
	btn.Name = name.."TabBtn"
	btn.Size = UDim2.new(1,0,0,46)
	btn.BackgroundColor3 = T().bg
	btn.BackgroundTransparency = 0.35
	btn.Text = name
	btn.TextColor3 = T().text
	btn.TextSize = 12  
	btn.Font = Enum.Font.GothamSemibold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.LayoutOrder = i
	btn.Parent = sidebar
	styleCorner(btn, UDim.new(0,10))
	local btnStroke = styleStroke(btn, 0.88)
	tabBtns[name] = btn
	table.insert(reg.accentStrokes, btnStroke)
	table.insert(reg.sidebarBtns, {btn, name})

	btn.MouseEnter:Connect(function()
		if activeTabName ~= name then
			TweenService:Create(btn, twI, {BackgroundTransparency=0.20}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if activeTabName ~= name then
			TweenService:Create(btn, twI, {BackgroundTransparency=0.35}):Play()
		end
	end)
end

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -162, 1, -68)
contentArea.Position = UDim2.new(0, 154, 0, 62)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.Parent = panel


local playerInfoPanel = Instance.new("Frame")
playerInfoPanel.Size = UDim2.new(0, 138, 0, 58)
playerInfoPanel.Position = UDim2.new(0, 8, 1, -68)
playerInfoPanel.BackgroundColor3 = T().bg
playerInfoPanel.BackgroundTransparency = 0.35
playerInfoPanel.BorderSizePixel = 0
playerInfoPanel.ClipsDescendants = true
playerInfoPanel.Parent = panel
styleCorner(playerInfoPanel, UDim.new(0, 10))
styleStroke(playerInfoPanel, 0.80)
table.insert(reg.panels, playerInfoPanel)

local pfpFrame = Instance.new("Frame")
pfpFrame.Size = UDim2.new(0, 36, 0, 36)
pfpFrame.Position = UDim2.new(0, 8, 0.5, -18)
pfpFrame.BackgroundColor3 = T().accent
pfpFrame.BackgroundTransparency = 0.6
pfpFrame.BorderSizePixel = 0
pfpFrame.Parent = playerInfoPanel
styleCorner(pfpFrame, UDim.new(1, 0))

local pfpImage = Instance.new("ImageLabel")
pfpImage.Size = UDim2.new(1, -4, 1, -4)
pfpImage.Position = UDim2.new(0, 2, 0, 2)
pfpImage.BackgroundTransparency = 1
pfpImage.Image = "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=150&h=150"
pfpImage.ScaleType = Enum.ScaleType.Fit
pfpImage.Parent = pfpFrame
styleCorner(pfpImage, UDim.new(1, 0))

local displayNameLbl = Instance.new("TextLabel")
displayNameLbl.Size = UDim2.new(1, -54, 0, 18)
displayNameLbl.Position = UDim2.new(0, 50, 0, 8)
displayNameLbl.BackgroundTransparency = 1
displayNameLbl.Text = player.DisplayName
displayNameLbl.TextColor3 = T().text
displayNameLbl.Font = Enum.Font.GothamBold
displayNameLbl.TextSize = 13
displayNameLbl.TextXAlignment = Enum.TextXAlignment.Left
displayNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
displayNameLbl.Parent = playerInfoPanel
table.insert(reg.texts, displayNameLbl)

local usernameLbl = Instance.new("TextLabel")
usernameLbl.Size = UDim2.new(1, -54, 0, 14)
usernameLbl.Position = UDim2.new(0, 50, 0, 28)
usernameLbl.BackgroundTransparency = 1
usernameLbl.Text = "@"..player.Name
usernameLbl.TextColor3 = T().subtext
usernameLbl.Font = Enum.Font.Gotham
usernameLbl.TextSize = 10
usernameLbl.TextXAlignment = Enum.TextXAlignment.Left
usernameLbl.TextTruncate = Enum.TextTruncate.AtEnd
usernameLbl.Parent = playerInfoPanel
table.insert(reg.subtexts, usernameLbl)

local pages = {}
local function newPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name.."Page"
	page.Size = UDim2.new(1,0,1,0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = T().accent
	page.CanvasSize = UDim2.new(0,0,0,0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.Visible = false
	page.Parent = contentArea
	pages[name] = page
	table.insert(reg.scrollBars, page)
	return page
end

local function switchTab(name)
	activeTabName = name
	for n, page in pairs(pages) do page.Visible = (n == name) end
	local th = T()
	for n, btn in pairs(tabBtns) do
		if n == name then
			TweenService:Create(btn, twI, {BackgroundTransparency=0, BackgroundColor3=th.accent}):Play()
			btn.TextColor3 = th.bg
		else
			TweenService:Create(btn, twI, {BackgroundTransparency=0.35, BackgroundColor3=th.bg}):Play()
			btn.TextColor3 = th.text
		end
	end
end

for _, name in ipairs(tabDefs) do
	tabBtns[name].MouseButton1Click:Connect(function() switchTab(name) end)
end

-------------||  Aux functions ||----------------
local function makeSectionLabel(parent, text, lo)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,0,24)
	lbl.BackgroundTransparency = 1
	lbl.Text = "  "..text
	lbl.TextColor3 = T().subtext
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = lo or 0
	lbl.Parent = parent
	table.insert(reg.subtexts, lbl)
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0.3,0,0,1)
	line.Position = UDim2.new(0,0,1,-1)
	line.BackgroundColor3 = T().accent
	line.BackgroundTransparency = 0.6
	line.BorderSizePixel = 0
	line.Parent = lbl
	table.insert(reg.accentBgs, line)
	return lbl
end

local function makeDangerBtn(parent, text, lo)
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = lo or 0
	btn.Size = UDim2.new(1,0,0,50)
	btn.BackgroundColor3 = T().bg
	btn.BackgroundTransparency = 0.18
	btn.Text = text
	btn.TextColor3 = T().danger
	btn.TextSize = 15
	btn.Font = Enum.Font.GothamSemibold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Parent = parent
	styleCorner(btn, UDim.new(0,10))
	local stroke = styleStroke(btn, 0.82, T().danger)
	table.insert(reg.panels,        btn)
	table.insert(reg.dangerTexts,   btn)
	table.insert(reg.dangerStrokes, stroke)
	return btn
end

local function makeInfoCard(parent, text, lo)
	local f = Instance.new("Frame")
	f.LayoutOrder = lo or 0
	f.Size = UDim2.new(1,0,0,52)
	f.BackgroundColor3 = T().bg
	f.BackgroundTransparency = 0.22
	f.BorderSizePixel = 0
	f.Parent = parent
	styleCorner(f, UDim.new(0,10))
	styleStroke(f, 0.90)
	table.insert(reg.panels, f)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-20,1,0)
	lbl.Position = UDim2.new(0,10,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = T().subtext
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.TextWrapped = true
	lbl.Parent = f
	table.insert(reg.subtexts, lbl)
	return f
end

-------------||  Data storage ||----------------
espStates = {
	getPL = nil, setPL = nil,
	getMM2 = nil, setMM2 = nil,
	getOG = nil, setOG = nil,
	getNameTag = nil, setNameTag = nil,
	getTeamOnly = nil, setTeamOnly = nil,
}
movementStates = {
	getNoclip = nil, setNoclip = nil,
	getGod = nil, setGod = nil,
	getInfiniteJump = nil, setInfiniteJump = nil,
	getAntiAFK = nil, setAntiAFK = nil,
	getAntiFling = nil, setAntiFling = nil,
}
flyState = { get = nil, set = nil, speed = DEFAULT_FLYSPEED }
aimbotMM2 = { get = nil, set = nil, smooth = 8, range = 500, statusDot = nil, statusLbl = nil }
aimbotGeneral = { get = nil, set = nil, fov = 500, smooth = 4 }

-- Variables de conexiones (scope global para poder apagarlas desde Settings)
local noclipConn, godConn, antiAFKConn, antiFlingConn = nil, nil, nil, nil
local flyConn, flyBV, flyBG = nil, nil, nil
-- ✅ FIX 3: mm2Conn y generalConn solo en scope externo, NO re-declarar dentro del bloque Aimbot
local mm2Conn, generalConn = nil, nil
local antiFlingLastPos = nil
local ANTI_FLING_MAX_VEL = 350
local ANTI_FLING_MAX_DELTA = 80

-------------|| Home page [1] ||----------------
local homePage = newPage("Home")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = homePage
	stylePadding(homePage, 4,8,0,4)

	
	local headerCard = Instance.new("Frame")
	headerCard.LayoutOrder = 1
	headerCard.Size = UDim2.new(1,0,0,80)
	headerCard.BackgroundColor3 = T().bg
	headerCard.BackgroundTransparency = 0.15
	headerCard.BorderSizePixel = 0
	headerCard.Parent = homePage
	styleCorner(headerCard, UDim.new(0,12))
	styleStroke(headerCard, 0.78)
	table.insert(reg.panels, headerCard)

	local accentStripe = Instance.new("Frame")
	accentStripe.Size = UDim2.new(0,4,0.7,0)
	accentStripe.Position = UDim2.new(0,0,0.15,0)
	accentStripe.BackgroundColor3 = T().accent
	accentStripe.BorderSizePixel = 0
	accentStripe.Parent = headerCard
	styleCorner(accentStripe, UDim.new(1,0))
	table.insert(reg.accentBgs, accentStripe)

	local hubNameLbl = Instance.new("TextLabel")
	hubNameLbl.Size = UDim2.new(1,-24,0,28)
	hubNameLbl.Position = UDim2.new(0,16,0,14)
	hubNameLbl.BackgroundTransparency = 1
	hubNameLbl.Text = "Happy Hub"
	hubNameLbl.TextColor3 = T().text
	hubNameLbl.Font = Enum.Font.GothamBold
	hubNameLbl.TextSize = 18
	hubNameLbl.TextXAlignment = Enum.TextXAlignment.Left
	hubNameLbl.Parent = headerCard
	table.insert(reg.texts, hubNameLbl)

	local hubSubLbl = Instance.new("TextLabel")
	hubSubLbl.Size = UDim2.new(1,-24,0,16)
	hubSubLbl.Position = UDim2.new(0,16,0,44)
	hubSubLbl.BackgroundTransparency = 1
	hubSubLbl.Text = "Best free hub · Since 2026 · v10 Update"
	hubSubLbl.TextColor3 = T().subtext
	hubSubLbl.Font = Enum.Font.Gotham
	hubSubLbl.TextSize = 11
	hubSubLbl.TextXAlignment = Enum.TextXAlignment.Left
	hubSubLbl.Parent = headerCard
	table.insert(reg.subtexts, hubSubLbl)

	
	makeSectionLabel(homePage, "Music", 2)

	local pillMusic, setMusic, getMusic = makeToggleRow(homePage, "HR - WASSA", 3)

	local musicSound = nil
	local musicActive = false

	local function playMusic()
		if musicSound then
			musicSound:Destroy()
			musicSound = nil
		end
		musicSound = Instance.new("Sound")
		musicSound.SoundId = "rbxassetid://17422156627"
		musicSound.Volume = 10
		musicSound.Looped = true
		musicSound.Parent = playerGui
		musicSound:Play()
		musicActive = true
	end

	local function stopMusic()
		if musicSound then
			musicSound:Stop()
			musicSound:Destroy()
			musicSound = nil
		end
		musicActive = false
	end

	pillMusic.MouseButton1Click:Connect(function()
		local v = not getMusic()
		setMusic(v)
		if v then
			playMusic()
			showNotification("Playing: EYUHH! - HR")
		else
			stopMusic()
			showNotification("Music stopped")
		end
	end)

	screenGui.AncestryChanged:Connect(function()
		if not screenGui:IsDescendantOf(game) then
			stopMusic()
		end
	end)

	player.CharacterAdded:Connect(function()
		if getMusic() and musicSound then
			if not musicSound.Parent then
				musicSound.Parent = playerGui
				musicSound:Play()
			end
		end
	end)

	
	makeSectionLabel(homePage, "Creators", 4)

	local function makeOwnerCard(parent, username, role, lo)
		local th = T()
		local card = Instance.new("Frame")
		card.LayoutOrder = lo or 1
		card.Size = UDim2.new(1,0,0,64)
		card.BackgroundColor3 = th.bg
		card.BackgroundTransparency = 0.18
		card.BorderSizePixel = 0
		card.Parent = parent
		styleCorner(card, UDim.new(0,12))
		styleStroke(card, 0.82)
		table.insert(reg.panels, card)

		local avatar = Instance.new("Frame")
		avatar.Size = UDim2.new(0,40,0,40)
		avatar.Position = UDim2.new(0,12,0.5,-20)
		avatar.BackgroundColor3 = th.accent
		avatar.BackgroundTransparency = 0.72
		avatar.BorderSizePixel = 0
		avatar.Parent = card
		styleCorner(avatar, UDim.new(1,0))
		local avatarLetter = Instance.new("TextLabel")
		avatarLetter.Size = UDim2.new(1,0,1,0)
		avatarLetter.BackgroundTransparency = 1
		avatarLetter.Text = username:sub(1,1):upper()
		avatarLetter.TextColor3 = th.accent
		avatarLetter.Font = Enum.Font.GothamBold
		avatarLetter.TextSize = 18
		avatarLetter.Parent = avatar
		table.insert(reg.accentTexts, avatarLetter)

		local nameRow = Instance.new("Frame")
		nameRow.Size = UDim2.new(1,-130,0,22)
		nameRow.Position = UDim2.new(0,60,0,12)
		nameRow.BackgroundTransparency = 1
		nameRow.BorderSizePixel = 0
		nameRow.Parent = card

		local usernameLbl = Instance.new("TextLabel")
		usernameLbl.Size = UDim2.new(1,-28,1,0)
		usernameLbl.Position = UDim2.new(0,0,0,0)
		usernameLbl.BackgroundTransparency = 1
		usernameLbl.Text = "@"..username
		usernameLbl.TextColor3 = th.text
		usernameLbl.Font = Enum.Font.GothamBold
		usernameLbl.TextSize = 15
		usernameLbl.TextXAlignment = Enum.TextXAlignment.Left
		usernameLbl.Parent = nameRow
		table.insert(reg.texts, usernameLbl)

		local verifiedIcon = Instance.new("ImageLabel")
		verifiedIcon.Size = UDim2.new(0,18,0,18)
		verifiedIcon.Position = UDim2.new(1,-22,0.5,-9)
		verifiedIcon.BackgroundTransparency = 1
		verifiedIcon.Image = VERIFIED_ICON_ID
		verifiedIcon.ImageColor3 = Color3.fromRGB(80,160,255)
		verifiedIcon.ScaleType = Enum.ScaleType.Fit
		verifiedIcon.Parent = nameRow

		local roleLbl = Instance.new("TextLabel")
		roleLbl.Size = UDim2.new(1,-130,0,16)
		roleLbl.Position = UDim2.new(0,60,0,36)
		roleLbl.BackgroundTransparency = 1
		roleLbl.Text = role
		roleLbl.TextColor3 = th.subtext
		roleLbl.Font = Enum.Font.Gotham
		roleLbl.TextSize = 11
		roleLbl.TextXAlignment = Enum.TextXAlignment.Left
		roleLbl.Parent = card
		table.insert(reg.subtexts, roleLbl)

		local badge = Instance.new("TextLabel")
		badge.Size = UDim2.new(0,0,0,22)
		badge.AutomaticSize = Enum.AutomaticSize.X
		badge.Position = UDim2.new(1,-8,0.5,-11)
		badge.AnchorPoint = Vector2.new(1,0)
		badge.BackgroundColor3 = th.accent
		badge.BackgroundTransparency = 0.78
		badge.Text = "  Creator "
		badge.TextColor3 = th.accent
		badge.Font = Enum.Font.GothamBold
		badge.TextSize = 9
		badge.BorderSizePixel = 0
		badge.Parent = card
		styleCorner(badge, UDim.new(1,0))
		table.insert(reg.accentTexts, badge)
		return card
	end

	makeOwnerCard(homePage, "OverthaneRBX ", "Developer · Hub Creator", 5)
	makeOwnerCard(homePage, "ReplicatedBacon_0", "Co-Owner · Test & Scripts", 6)

	
	makeSectionLabel(homePage, "Features", 7)

	local function makeFeatureRow(parent, title, desc, lo)
		local th = T()
		local row = Instance.new("Frame")
		row.LayoutOrder = lo or 1
		row.Size = UDim2.new(1,0,0,52)
		row.BackgroundColor3 = th.bg
		row.BackgroundTransparency = 0.25
		row.BorderSizePixel = 0
		row.Parent = parent
		styleCorner(row, UDim.new(0,10))
		styleStroke(row, 0.90)
		table.insert(reg.panels, row)

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1,-20,0,20)
		titleLbl.Position = UDim2.new(0,10,0,8)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = title
		titleLbl.TextColor3 = th.text
		titleLbl.Font = Enum.Font.GothamSemibold
		titleLbl.TextSize = 13
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Parent = row
		table.insert(reg.texts, titleLbl)

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1,-20,0,14)
		descLbl.Position = UDim2.new(0,10,0,28)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = desc
		descLbl.TextColor3 = th.subtext
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 10
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextTruncate = Enum.TextTruncate.AtEnd
		descLbl.Parent = row
		table.insert(reg.subtexts, descLbl)
		return row
	end

	makeFeatureRow(homePage, "Players", "Teleport to any player · Server Hop · Rejoin", 8)
	makeFeatureRow(homePage, "Waypoints", "Save positions and teleport", 9)
	makeFeatureRow(homePage, "ESP", "Highlights · NameTags · Roles MM2 / PL", 10)
	makeFeatureRow(homePage, "Movimiento", "Speed · Jump · Noclip · God Mode · Anti-AFK", 11)
	makeFeatureRow(homePage, "Fly", "WASD Flight · Mobile joystick support", 12)
	makeFeatureRow(homePage, "Aimbot", "Lock-On MM2 + General · Smoothness", 13)
	makeFeatureRow(homePage, "Avatar", "Korblox · Shoulder · Rainbow Body · Invisible", 14)
	makeFeatureRow(homePage, "Executor", "Script tabs · Execute loadstring · Error detection", 15)
	makeFeatureRow(homePage, "Scripts", "Scripts from other users", 16)
	makeFeatureRow(homePage, "Settings", "7 themes (2 exclusive) · Fullbright · Hide GUI", 17)
end

local function findGunDropCFrame()
    local gWorkspace = game:GetService("Workspace")
    for _, map in ipairs(gWorkspace:GetChildren()) do
        if map:IsA("Model") and map.Name:find("Map") then
            local gunDrop = map:FindFirstChild("GunDrop", true)
            if gunDrop and gunDrop:IsA("BasePart") then
                return gunDrop.CFrame
            end
        end
    end
    local gunDrop = gWorkspace:FindFirstChild("GunDrop", true)
    if gunDrop and gunDrop:IsA("BasePart") then
        return gunDrop.CFrame
    end
    return nil
end

local function getPlayerWithItem(itemName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local bp = plr:FindFirstChild("Backpack")
            if (char and char:FindFirstChild(itemName)) or
               (bp and bp:FindFirstChild(itemName)) then
                return plr
            end
        end
    end
    return nil
end

local function teleportTo(targetPlr)
    if not targetPlr then return false end
    local targetChar = targetPlr.Character
    if not targetChar then return false end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myHRP = getHRP()
    if targetHRP and myHRP then
        myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

local function obtainSheriffGun()
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local gunCFrame = findGunDropCFrame()
    if not gunCFrame then return false end
    local originalCF = hrp.CFrame
    hrp.CFrame = gunCFrame + Vector3.new(0, 5, 0)
    task.wait(0.5)
    hrp.CFrame = originalCF
    local bp = player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Gun") then return true end
    return false
end

-------------||  Page waypoints [2] ||----------------
local wpPage = newPage("Waypoints")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = wpPage
	stylePadding(wpPage, 0,8,0,4)

	local saveSection = Instance.new("Frame")
	saveSection.LayoutOrder = 1
	saveSection.Size = UDim2.new(1,0,0,94)
	saveSection.BackgroundColor3 = T().bg
	saveSection.BackgroundTransparency = PANEL_TRANSPARENCY
	saveSection.BorderSizePixel = 0
	saveSection.Parent = wpPage
	styleCorner(saveSection, UDim.new(0,12))
	styleStroke(saveSection, 0.78)
	stylePadding(saveSection, 10,10,10,10)
	table.insert(reg.panels, saveSection)

	local nameBox = Instance.new("TextBox")
	nameBox.Size = UDim2.new(1,-52,0,38)
	nameBox.BackgroundColor3 = T().bg
	nameBox.BackgroundTransparency = 0.15
	nameBox.TextColor3 = T().text
	nameBox.PlaceholderText = "waypoint name"
   nameBox.Text = "   "
	nameBox.PlaceholderColor3 = T().subtext
	nameBox.TextSize = 14
	nameBox.Font = Enum.Font.Gotham
	nameBox.ClearTextOnFocus = false
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.BorderSizePixel = 0
	nameBox.Parent = saveSection
	styleCorner(nameBox, UDim.new(0,8))
	styleStroke(nameBox, 0.88)
	stylePadding(nameBox, 0,0,12,12)
	table.insert(reg.panels, nameBox)
	table.insert(reg.texts, nameBox)

	local saveBtn = Instance.new("ImageButton")
	saveBtn.Size = UDim2.new(0,38,0,38)
	saveBtn.Position = UDim2.new(1,-42,0,0)
	saveBtn.BackgroundColor3 = T().accent
	saveBtn.Image = ADD_WP_ICON_ID
	saveBtn.ImageColor3 = T().bg
	saveBtn.ScaleType = Enum.ScaleType.Fit
	saveBtn.BorderSizePixel = 0
	saveBtn.AutoButtonColor = true
	saveBtn.Parent = saveSection
	styleCorner(saveBtn, UDim.new(0,10))
	table.insert(reg.accentBgs, saveBtn)

	local wpListLbl = Instance.new("TextLabel")
	wpListLbl.LayoutOrder = 2
	wpListLbl.Size = UDim2.new(1,0,0,20)
	wpListLbl.BackgroundTransparency = 1
	wpListLbl.Text = "Saved waypoints"
	wpListLbl.TextColor3 = T().subtext
	wpListLbl.Font = Enum.Font.GothamBold
	wpListLbl.TextSize = 10
	wpListLbl.TextXAlignment = Enum.TextXAlignment.Left
	wpListLbl.Parent = wpPage
	table.insert(reg.subtexts, wpListLbl)

	local listContainer = Instance.new("Frame")
	listContainer.Name = "ListContainer"
	listContainer.LayoutOrder = 3
	listContainer.Size = UDim2.new(1,0,0,0)
	listContainer.AutomaticSize = Enum.AutomaticSize.Y
	listContainer.BackgroundTransparency = 1
	listContainer.BorderSizePixel = 0
	listContainer.Parent = wpPage
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0,6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = listContainer

	local emptyLbl = Instance.new("TextLabel")
	emptyLbl.Name = "EmptyLabel"
	emptyLbl.Size = UDim2.new(1,0,0,44)
	emptyLbl.BackgroundTransparency = 1
	emptyLbl.Text = "There are no saved waypoints yet."
	emptyLbl.TextColor3 = T().subtext
	emptyLbl.Font = Enum.Font.Gotham
	emptyLbl.TextSize = 13
	emptyLbl.Parent = listContainer
	table.insert(reg.subtexts, emptyLbl)

	local function refreshList()
		for _, ch in ipairs(listContainer:GetChildren()) do
			if ch:IsA("Frame") and ch.Name == "WaypointRow" then ch:Destroy() end
		end
		emptyLbl.Visible = #waypoints == 0
		for idx, wp in ipairs(waypoints) do
			local th = T()
			local row = Instance.new("Frame")
			row.Name = "WaypointRow"
			row.LayoutOrder = idx
			row.Size = UDim2.new(1,0,0,50)
			row.BackgroundColor3 = th.bg
			row.BackgroundTransparency = 0.2
			row.BorderSizePixel = 0
			row.Parent = listContainer
			styleCorner(row, UDim.new(0,10))
			styleStroke(row, 0.88)
			table.insert(reg.panels, row)

			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0,8,0,8)
			dot.Position = UDim2.new(0,12,0.5,-4)
			dot.BackgroundColor3 = th.accent
			dot.BorderSizePixel = 0
			dot.Parent = row
			styleCorner(dot, UDim.new(1,0))
			table.insert(reg.accentBgs, dot)

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1,-160,1,0)
			nameLbl.Position = UDim2.new(0,28,0,0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = wp.name
			nameLbl.TextColor3 = th.text
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextSize = 14
			nameLbl.Font = Enum.Font.GothamSemibold
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.Parent = row
			table.insert(reg.texts, nameLbl)

			local tp = Instance.new("TextButton")
			tp.Size = UDim2.new(0,62,0,34)
			tp.Position = UDim2.new(1,-138,0.5,-17)
			tp.BackgroundColor3 = th.bg
			tp.BackgroundTransparency = 0.05
			tp.Text = "·"
			tp.TextColor3 = th.accent
			tp.TextSize = 13
			tp.Font = Enum.Font.GothamBold
			tp.BorderSizePixel = 0
			tp.AutoButtonColor = true
			tp.Parent = row
			styleCorner(tp, UDim.new(0,8))
			local tpStroke = styleStroke(tp, 0.85, th.accent)
			table.insert(reg.panels, tp)
			table.insert(reg.accentTexts, tp)
			table.insert(reg.accentStrokes, tpStroke)

			local del = Instance.new("TextButton")
			del.Size = UDim2.new(0,62,0,34)
			del.Position = UDim2.new(1,-68,0.5,-17)
			del.BackgroundColor3 = th.bg
			del.BackgroundTransparency = 0.05
			del.Text = "x"
			del.TextColor3 = th.danger
			del.TextSize = 13
			del.Font = Enum.Font.GothamBold
			del.BorderSizePixel = 0
			del.AutoButtonColor = true
			del.Parent = row
			styleCorner(del, UDim.new(0,8))
			local delStroke = styleStroke(del, 0.85, th.danger)
			table.insert(reg.panels, del)
			table.insert(reg.dangerTexts, del)
			table.insert(reg.dangerStrokes, delStroke)

			tp.MouseButton1Click:Connect(function()
				local hrp = getHRP()
				if hrp then hrp.CFrame = CFrame.new(wp.position + Vector3.new(0,3,0)) end
			end)
			del.MouseButton1Click:Connect(function()
				for i, d in ipairs(waypoints) do
					if d == wp then table.remove(waypoints,i); break end
				end
				refreshList()
			end)
		end
	end

	saveBtn.MouseButton1Click:Connect(function()
		local hrp = getHRP()
		if not hrp then return end
		local raw = nameBox.Text
		if raw == "" then raw = "Waypoint "..tostring(#waypoints+1) end
		table.insert(waypoints, {name=uniqueName(raw), position=hrp.Position})
		nameBox.Text = ""
		refreshList()
	end)

	-- ✅ FIX 5: exponer refreshList para que applyTheme pueda llamarla
	HHBFuncs.refreshWaypoints = refreshList
	_G.__HHB_refreshList = refreshList
	refreshList()
end
----|| Page players idk number ||---
local jugadoresPage = newPage("Players")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = jugadoresPage
	stylePadding(jugadoresPage, 0,8,0,4)

	makeSectionLabel(jugadoresPage, "Teleport to any player", 1)

	--|| With this you can make Kill everyone ||--
	local tpAllPill, setTpAll, getTpAll = makeToggleRow(jugadoresPage, "TP All (Loop)", 2)
	local tpAllRunning = false
	local tpAllTask = nil

	local function startTpAllLoop()
		tpAllRunning = true
		tpAllTask = task.spawn(function()
			while tpAllRunning do
				for _, plr in ipairs(Players:GetPlayers()) do
					if not tpAllRunning then break end
					if plr ~= player then
						local hrp = getHRP()
						local theirHRP = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
						if hrp and theirHRP then
							hrp.CFrame = theirHRP.CFrame
							task.wait(0.1)
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end

	local function stopTpAllLoop()
		tpAllRunning = false
		if tpAllTask then
			task.cancel(tpAllTask)
			tpAllTask = nil
		end
	end

	tpAllPill.MouseButton1Click:Connect(function()
		local v = not getTpAll()
		setTpAll(v)
		if v then
			startTpAllLoop()
			showNotification("TP All activado")
		else
			stopTpAllLoop()
			showNotification("TP All desactivado")
		end
	end)

	----|| Player list ||---
	local playerListContainer = Instance.new("Frame")
	playerListContainer.Name = "PlayerListContainer"
	playerListContainer.LayoutOrder = 3
	playerListContainer.Size = UDim2.new(1,0,0,0)
	playerListContainer.AutomaticSize = Enum.AutomaticSize.Y
	playerListContainer.BackgroundTransparency = 1
	playerListContainer.BorderSizePixel = 0
	playerListContainer.Parent = jugadoresPage
	local plListLayout = Instance.new("UIListLayout")
	plListLayout.Padding = UDim.new(0,6)
	plListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	plListLayout.Parent = playerListContainer

	----|| Refresh list ||---
	local function refreshPlayerList()
		for _, ch in ipairs(playerListContainer:GetChildren()) do
			if ch:IsA("Frame") then ch:Destroy() end
		end
		local allPlayers = Players:GetPlayers()
		for idx, plr in ipairs(allPlayers) do
			if plr == player then continue end
			local th = T()
			local row = Instance.new("Frame")
			row.Name = "PlayerRow"
			row.LayoutOrder = idx
			row.Size = UDim2.new(1,0,0,60)
			row.BackgroundColor3 = th.bg
			row.BackgroundTransparency = 0.20
			row.BorderSizePixel = 0
			row.Parent = playerListContainer
			styleCorner(row, UDim.new(0,10))
			styleStroke(row, 0.88)
			table.insert(reg.panels, row)

			-- Avatar
			local avatarCircle = Instance.new("Frame")
			avatarCircle.Size = UDim2.new(0,36,0,36)
			avatarCircle.Position = UDim2.new(0,10,0.5,-18)
			avatarCircle.BackgroundColor3 = th.accent
			avatarCircle.BackgroundTransparency = 0.70
			avatarCircle.BorderSizePixel = 0
			avatarCircle.Parent = row
			styleCorner(avatarCircle, UDim.new(1,0))
			local avatarLetter = Instance.new("TextLabel")
			avatarLetter.Size = UDim2.new(1,0,1,0)
			avatarLetter.BackgroundTransparency = 1
			avatarLetter.Text = plr.Name:sub(1,1):upper()
			avatarLetter.TextColor3 = th.accent
			avatarLetter.Font = Enum.Font.GothamBold
			avatarLetter.TextSize = 16
			avatarLetter.Parent = avatarCircle
			table.insert(reg.accentTexts, avatarLetter)

			-- name
			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size = UDim2.new(1,-120,0,20)
			nameLbl.Position = UDim2.new(0,54,0,8)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text = plr.DisplayName
			nameLbl.TextColor3 = th.text
			nameLbl.Font = Enum.Font.GothamSemibold
			nameLbl.TextSize = 14
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
			nameLbl.Parent = row
			table.insert(reg.texts, nameLbl)

			-- user
			local userLbl = Instance.new("TextLabel")
			userLbl.Size = UDim2.new(1,-120,0,14)
			userLbl.Position = UDim2.new(0,54,0,30)
			userLbl.BackgroundTransparency = 1
			userLbl.Text = "@"..plr.Name
			userLbl.TextColor3 = th.subtext
			userLbl.Font = Enum.Font.Gotham
			userLbl.TextSize = 11
			userLbl.TextXAlignment = Enum.TextXAlignment.Left
			userLbl.Parent = row
			table.insert(reg.subtexts, userLbl)

			local capturedPlr = plr

			----|| Teleport button [modify if you want ] ||---
			local tpBtn = Instance.new("ImageButton")
			tpBtn.Size = UDim2.new(0, 38, 0, 38)
			tpBtn.Position = UDim2.new(1, -48, 0.5, -19)
			tpBtn.BackgroundColor3 = th.bg
			tpBtn.BackgroundTransparency = 0.1
			tpBtn.Image = TP_ICON
			tpBtn.ImageColor3 = th.accent
			tpBtn.ScaleType = Enum.ScaleType.Fit
			tpBtn.BorderSizePixel = 0
			tpBtn.AutoButtonColor = false
			tpBtn.Parent = row
			styleCorner(tpBtn, UDim.new(0,8))
			local tpStroke = styleStroke(tpBtn, 0.7, th.accent)
			table.insert(reg.panels, tpBtn)
			table.insert(reg.accentStrokes, tpStroke)

			local tpTip = Instance.new("TextLabel")
			tpTip.Size = UDim2.new(0,0,0,18)
			tpTip.AutomaticSize = Enum.AutomaticSize.X
			tpTip.Position = UDim2.new(0.5,0,1,4)
			tpTip.AnchorPoint = Vector2.new(0.5,0)
			tpTip.BackgroundColor3 = Color3.fromRGB(0,0,0)
			tpTip.BackgroundTransparency = 0.8
			tpTip.Text = "Invadir (1.5s)"
			tpTip.TextColor3 = Color3.new(1,1,1)
			tpTip.Font = Enum.Font.Gotham
			tpTip.TextSize = 9
			tpTip.TextXAlignment = Enum.TextXAlignment.Center
			tpTip.BorderSizePixel = 0
			tpTip.Visible = false
			tpTip.Parent = tpBtn
			styleCorner(tpTip, UDim.new(1,0))
			stylePadding(tpTip, 2,2,6,6)
			tpBtn.MouseEnter:Connect(function() tpTip.Visible = true end)
			tpBtn.MouseLeave:Connect(function() tpTip.Visible = false end)

			
			local invasionActive = false
			local invasionConnection = nil
			local invasionStartTime = 0
			local INVASION_DURATION = 1.5

			local function startInvasion(targetPlr)
				if invasionActive then 
					invasionActive = false
					if invasionConnection then
						invasionConnection:Disconnect()
						invasionConnection = nil
					end
					local hrp = getHRP()
					if hrp then
						hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
					end
					showNotification("Invasión cancelada")
					return
				end
				
				if not targetPlr then
					showNotification("Jugador no disponible", "warning")
					return
				end
				
				local myChar = player.Character
				local targetChar = targetPlr.Character
				
				if not myChar or not targetChar then
					showNotification("Personaje no disponible", "warning")
					return
				end
				
				local myHRP = myChar:FindFirstChild("HumanoidRootPart")
				local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
				
				if not myHRP or not targetHRP then
					showNotification("Error: partes del cuerpo no encontradas", "warning")
					return
				end
				
				invasionActive = true
				invasionStartTime = tick()
				
				
				local originalCF = myHRP.CFrame
				
				
				myHRP.CFrame = targetHRP.CFrame
				showNotification("Invadiendo a " .. targetPlr.DisplayName)
				
				
				for _, part in ipairs(myChar:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
				
				
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Velocity = Vector3.zero
				bv.Parent = myHRP
				
				
				local bg = Instance.new("BodyGyro")
				bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
				bg.P = 1e4
				bg.CFrame = targetHRP.CFrame
				bg.Parent = myHRP
				
		
				invasionConnection = RunService.Heartbeat:Connect(function()
					if not invasionActive then
						if bv then bv:Destroy() end
						if bg then bg:Destroy() end
						if invasionConnection then invasionConnection:Disconnect() end
						invasionConnection = nil
						return
					end
					
					
					local elapsed = tick() - invasionStartTime
					if elapsed >= INVASION_DURATION then
						invasionActive = false
						if bv then bv:Destroy() end
						if bg then bg:Destroy() end
						if invasionConnection then invasionConnection:Disconnect() end
						invasionConnection = nil
						
						
						if myHRP and myHRP.Parent then
							myHRP.CFrame = originalCF
						end
						showNotification("Invasión terminada")
						return
					end
					
					
					local currentTargetChar = targetPlr.Character
					if not currentTargetChar then
						invasionActive = false
						showNotification("Jugador desconectado", "warning")
						return
					end
					
					local currentTargetHRP = currentTargetChar:FindFirstChild("HumanoidRootPart")
					local currentMyHRP = getHRP()
					
					if currentTargetHRP and currentMyHRP then
						-- FORZAR la posición DENTRO del objetivo
						currentMyHRP.CFrame = currentTargetHRP.CFrame
						
						-- Actualizar BodyGyro
						if bg then
							bg.CFrame = currentTargetHRP.CFrame
						end
						
						-- Mantener noclip
						local char = player.Character
						if char then
							for _, part in ipairs(char:GetDescendants()) do
								if part:IsA("BasePart") then
									part.CanCollide = false
								end
							end
						end
						
						-- También desactivar colisiones del objetivo para evitar empujones
						local targetChar2 = targetPlr.Character
						if targetChar2 then
							for _, part in ipairs(targetChar2:GetDescendants()) do
								if part:IsA("BasePart") then
									part.CanCollide = false
								end
							end
						end
						
					else
						invasionActive = false
						showNotification("Error en la invasión", "danger")
					end
				end)
			end

			tpBtn.MouseButton1Click:Connect(function()
				startInvasion(capturedPlr)
			end)

		end

		if #allPlayers <= 1 then
			local noPlayers = Instance.new("TextLabel")
			noPlayers.Size = UDim2.new(1,0,0,44)
			noPlayers.BackgroundTransparency = 1
			noPlayers.Text = "There's not Other players in this server"
			noPlayers.TextColor3 = T().subtext
			noPlayers.Font = Enum.Font.Gotham
			noPlayers.TextSize = 13
			noPlayers.Parent = playerListContainer
			table.insert(reg.subtexts, noPlayers)
		end
	end


	local refreshBtn = Instance.new("TextButton")
	refreshBtn.LayoutOrder = 4
	refreshBtn.Size = UDim2.new(1,0,0,42)
	refreshBtn.BackgroundColor3 = T().bg
	refreshBtn.BackgroundTransparency = 0.28
	refreshBtn.Text = "Update list"
	refreshBtn.TextColor3 = T().subtext
	refreshBtn.TextSize = 13
	refreshBtn.Font = Enum.Font.GothamSemibold
	refreshBtn.BorderSizePixel = 0
	refreshBtn.AutoButtonColor = true
	refreshBtn.Parent = jugadoresPage
	styleCorner(refreshBtn, UDim.new(0,10))
	styleStroke(refreshBtn, 0.82)
	table.insert(reg.panels, refreshBtn)
	table.insert(reg.subtexts, refreshBtn)

	refreshBtn.MouseButton1Click:Connect(refreshPlayerList)

	Players.PlayerAdded:Connect(function() task.wait(1); refreshPlayerList() end)
	Players.PlayerRemoving:Connect(function() task.wait(0.1); refreshPlayerList() end)

	
	makeSectionLabel(jugadoresPage, "Server", 5)

	local rejoinBtn = Instance.new("TextButton")
	rejoinBtn.LayoutOrder = 6
	rejoinBtn.Size = UDim2.new(1,0,0,50)
	rejoinBtn.BackgroundColor3 = T().bg
	rejoinBtn.BackgroundTransparency = 0.22
	rejoinBtn.Text = " Rejoin"
	rejoinBtn.TextColor3 = T().text
	rejoinBtn.TextSize = 14
	rejoinBtn.Font = Enum.Font.GothamSemibold
	rejoinBtn.BorderSizePixel = 0
	rejoinBtn.AutoButtonColor = true
	rejoinBtn.Parent = jugadoresPage
	styleCorner(rejoinBtn, UDim.new(0,10))
	styleStroke(rejoinBtn, 0.88)
	table.insert(reg.panels, rejoinBtn)
	table.insert(reg.texts, rejoinBtn)

	rejoinBtn.MouseButton1Click:Connect(function()
		local TeleportService = game:GetService("TeleportService")
		pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
		end)
	end)

	local serverHopBtn = Instance.new("TextButton")
	serverHopBtn.LayoutOrder = 7
	serverHopBtn.Size = UDim2.new(1,0,0,50)
	serverHopBtn.BackgroundColor3 = T().bg
	serverHopBtn.BackgroundTransparency = 0.22
	serverHopBtn.Text = " Server Hop"
	serverHopBtn.TextColor3 = T().text
	serverHopBtn.TextSize = 14
	serverHopBtn.Font = Enum.Font.GothamSemibold
	serverHopBtn.BorderSizePixel = 0
	serverHopBtn.AutoButtonColor = true
	serverHopBtn.Parent = jugadoresPage
	styleCorner(serverHopBtn, UDim.new(0,10))
	styleStroke(serverHopBtn, 0.88)
	table.insert(reg.panels, serverHopBtn)
	table.insert(reg.texts, serverHopBtn)

	serverHopBtn.MouseButton1Click:Connect(function()
		local TeleportService = game:GetService("TeleportService")
		local HttpService = game:GetService("HttpService")
		pcall(function()
			local data = HttpService:JSONDecode(
				game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
			)
			if data and data.data then
				for _, s in ipairs(data.data) do
					if s.id ~= game.JobId and s.playing < s.maxPlayers then
						TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
						return
					end
				end
			end
		end)
	end)

	-- Exponer refresh
	HHBFuncs.refreshPlayers = refreshPlayerList
	refreshPlayerList()
end
----|| Esp page ||---
local espPage = newPage("ESP")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = espPage
	stylePadding(espPage, 0,8,0,4)

	makeSectionLabel(espPage, "ESP or Xray", 1)
	local pillPL, setPL, getPL = makeToggleRow(espPage, "Prison Life", 2)
	local pillMM2, setMM2, getMM2 = makeToggleRow(espPage, "Murder Mystery 2", 3)
	local pillOG, setOG, getOG = makeToggleRow(espPage, "Other games", 4)
	makeSectionLabel(espPage, "Options", 5)
	local pillNameTag, setNameTag, getNameTag = makeToggleRow(espPage, "Nametag", 6)
	local pillTeamOnly, setTeamOnly, getTeamOnly = makeToggleRow(espPage, "Just enemies", 7)

	espStates.getPL = getPL; espStates.setPL = setPL
	espStates.getMM2 = getMM2; espStates.setMM2 = setMM2
	espStates.getOG = getOG; espStates.setOG = setOG
	espStates.getNameTag = getNameTag; espStates.setNameTag = setNameTag
	espStates.getTeamOnly = getTeamOnly; espStates.setTeamOnly = setTeamOnly

	pillPL.MouseButton1Click:Connect(function()
		local v = not getPL(); setPL(v)
		if v then pcall(enableESP_PL) else pcall(disableESP_PL) end
	end)
	pillMM2.MouseButton1Click:Connect(function()
		local v = not getMM2(); setMM2(v)
		if v then pcall(enableESP_MM2) else pcall(disableESP_MM2) end
	end)
	pillOG.MouseButton1Click:Connect(function()
		local v = not getOG(); setOG(v)
		if v then pcall(enableESP_OG) else pcall(disableESP_OG) end
	end)
	pillNameTag.MouseButton1Click:Connect(function()
		local v = not getNameTag(); setNameTag(v)
		if v then pcall(enableNameTags) else pcall(disableNameTags) end
	end)
	pillTeamOnly.MouseButton1Click:Connect(function()
		local v = not getTeamOnly(); setTeamOnly(v)
		if getPL() then pcall(disableESP_PL); pcall(enableESP_PL) end
	end)
end
----|| Movement ||---
local movPage = newPage("Movement")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = movPage
	stylePadding(movPage, 0,8,0,4)

	
	makeSectionLabel(movPage, "Fly", 1)
	local pillFly, setFly, getFly = makeToggleRow(movPage, "Active Fly", 2)
	local currentFlySpeed = DEFAULT_FLYSPEED
	makeSliderRow(movPage, "Fly Speed", 5, 200, DEFAULT_FLYSPEED, function(v) currentFlySpeed = v end, 3)
	
	local flyInfo = Instance.new("TextLabel")
	flyInfo.Size = UDim2.new(1,0,0,32)
	flyInfo.LayoutOrder = 4
	flyInfo.BackgroundColor3 = T().bg
	flyInfo.BackgroundTransparency = 0.15
	flyInfo.Text = "  WASD + Space / Ctrl"
	flyInfo.TextColor3 = T().subtext
	flyInfo.Font = Enum.Font.Gotham
	flyInfo.TextSize = 11
	flyInfo.TextXAlignment = Enum.TextXAlignment.Left
	flyInfo.TextWrapped = true
	flyInfo.BorderSizePixel = 0
	flyInfo.Parent = movPage
	styleCorner(flyInfo, UDim.new(0,8))
	styleStroke(flyInfo, 0.85)
	table.insert(reg.panels, flyInfo)
	table.insert(reg.subtexts, flyInfo)

	-- Variables de Fly
	flyState.get = getFly; flyState.set = setFly; flyState.speed = currentFlySpeed

	local function startFly()
		local hrp = getHRP(); local hum = getHumanoid()
		if not hrp or not hum then return end
		hum.PlatformStand = true
		flyBV = Instance.new("BodyVelocity")
		flyBV.Velocity = Vector3.zero
		flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
		flyBV.Parent = hrp
		flyBG = Instance.new("BodyGyro")
		flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
		flyBG.P = 1e4
		flyBG.CFrame = hrp.CFrame
		flyBG.Parent = hrp
		flyConn = RunService.Heartbeat:Connect(function()
			local h = getHRP(); if not h then return end
			local cf = workspace.CurrentCamera.CFrame
			local mv = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv += cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv -= cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then mv += Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then mv -= Vector3.yAxis end
			if mv.Magnitude < 0.01 then
				local hum2 = getHumanoid()
				if hum2 then local md = hum2.MoveDirection
					if md.Magnitude > 0.1 then mv = md * Vector3.new(1,0,1) end
				end
			end
			flyBV.Velocity = mv.Magnitude > 0 and mv.Unit * currentFlySpeed or Vector3.zero
			flyBG.CFrame = cf
		end)
	end

	local function stopFly()
		if flyConn then flyConn:Disconnect(); flyConn = nil end
		if flyBV then flyBV:Destroy(); flyBV = nil end
		if flyBG then flyBG:Destroy(); flyBG = nil end
		local hum = getHumanoid(); if hum then hum.PlatformStand = false end
	end

	HHBFuncs.startFly = startFly
	HHBFuncs.stopFly = stopFly

	pillFly.MouseButton1Click:Connect(function()
		local v = not getFly(); setFly(v)
		if v then startFly() else stopFly() end
	end)
	player.CharacterAdded:Connect(function()
		if getFly() then setFly(false); stopFly() end
	end)

	
	makeSectionLabel(movPage, "Speed", 5)
	local currentWalkSpeed = DEFAULT_WALKSPEED
	local currentJumpPower = DEFAULT_JUMPPOWER
	makeSliderRow(movPage, "Walk Speed", 4, 150, DEFAULT_WALKSPEED, function(v)
		currentWalkSpeed = v
		local hum = getHumanoid(); if hum then hum.WalkSpeed = v end
	end, 6)
	makeSliderRow(movPage, "Jump Power", 10, 200, DEFAULT_JUMPPOWER, function(v)
		currentJumpPower = v
		local hum = getHumanoid(); if hum then hum.JumpPower = v end
	end, 7)
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = currentWalkSpeed; hum.JumpPower = currentJumpPower end
	end)

	
	makeSectionLabel(movPage, "Modifications or mods", 8)

	local pillNoclip, setNoclip, getNoclip = makeToggleRow(movPage, "Noclip", 9)
	local pillGod, setGod, getGod = makeToggleRow(movPage, "God Mode", 10)
	local pillIJ, setIJ, getIJ = makeToggleRow(movPage, "Infinite Jump", 11)
	local pillAntiAFK, setAntiAFK, getAntiAFK = makeToggleRow(movPage, "Anti-AFK", 12)
	local pillAntiFling, setAntiFling, getAntiFling = makeToggleRow(movPage, "Anti-Fling", 13)

	movementStates.getNoclip = getNoclip; movementStates.setNoclip = setNoclip
	movementStates.getGod = getGod; movementStates.setGod = setGod
	movementStates.getInfiniteJump = getIJ; movementStates.setInfiniteJump = setIJ
	movementStates.getAntiAFK = getAntiAFK; movementStates.setAntiAFK = setAntiAFK
	movementStates.getAntiFling = getAntiFling; movementStates.setAntiFling = setAntiFling

	pillNoclip.MouseButton1Click:Connect(function()
		local v = not getNoclip(); setNoclip(v)
		if v then
			noclipConn = RunService.Stepped:Connect(function()
				local c = player.Character
				if c then
					for _, p in ipairs(c:GetDescendants()) do
						if p:IsA("BasePart") then p.CanCollide = false end
					end
				end
			end)
		else
			if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
			local c = player.Character
			if c then
				for _, p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = (p.Name ~= "HumanoidRootPart") end
				end
			end
		end
	end)

	pillGod.MouseButton1Click:Connect(function()
		local v = not getGod(); setGod(v)
		if v then
			godConn = RunService.Heartbeat:Connect(function()
				local hum = getHumanoid(); if hum then hum.Health = hum.MaxHealth end
			end)
		else
			if godConn then godConn:Disconnect(); godConn = nil end
		end
	end)

	pillIJ.MouseButton1Click:Connect(function() setIJ(not getIJ()) end)
	UserInputService.JumpRequest:Connect(function()
		if getIJ() then
			local hum = getHumanoid()
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)

	pillAntiAFK.MouseButton1Click:Connect(function()
		local v = not getAntiAFK(); setAntiAFK(v)
		if v then
			local vu = game:GetService("VirtualUser")
			antiAFKConn = player.Idled:Connect(function()
				vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			end)
		else
			if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
		end
	end)

	pillAntiFling.MouseButton1Click:Connect(function()
		local v = not getAntiFling(); setAntiFling(v)
		if v then
			antiFlingLastPos = nil
			antiFlingConn = RunService.Heartbeat:Connect(function()
				local hrp = getHRP(); if not hrp then return end
				local vel = hrp.AssemblyLinearVelocity
				local speed = vel.Magnitude
				local curPos = hrp.Position
				if speed > ANTI_FLING_MAX_VEL then
					hrp.AssemblyLinearVelocity = Vector3.zero
					if antiFlingLastPos then
						hrp.CFrame = CFrame.new(antiFlingLastPos) * (hrp.CFrame - hrp.CFrame.Position)
					end
				elseif antiFlingLastPos and (curPos - antiFlingLastPos).Magnitude > ANTI_FLING_MAX_DELTA then
					hrp.CFrame = CFrame.new(antiFlingLastPos) * (hrp.CFrame - hrp.CFrame.Position)
					hrp.AssemblyLinearVelocity = Vector3.zero
				else
					antiFlingLastPos = curPos
				end
			end)
		else
			if antiFlingConn then antiFlingConn:Disconnect(); antiFlingConn = nil end
			antiFlingLastPos = nil
		end
	end)

	
	-- ── Animaciones ───────────────────────────────────────────
makeSectionLabel(movPage, "Animations", 9)

local laughBtn = Instance.new("TextButton")
laughBtn.LayoutOrder = 10
laughBtn.Size = UDim2.new(1,0,0,50)
laughBtn.BackgroundColor3 = T().bg
laughBtn.BackgroundTransparency = CARD_TRANSPARENCY
laughBtn.Text = " /e laugh"
laughBtn.TextColor3 = T().accent
laughBtn.TextSize = 15
laughBtn.Font = Enum.Font.GothamSemibold
laughBtn.BorderSizePixel = 0
laughBtn.AutoButtonColor = true
laughBtn.Parent = movPage
styleCorner(laughBtn, UDim.new(0,10))
local laughStroke = styleStroke(laughBtn, 0.82, T().accent)
table.insert(reg.panels, laughBtn)
table.insert(reg.accentTexts, laughBtn)
table.insert(reg.accentStrokes, laughStroke)

laughBtn.MouseButton1Click:Connect(function()
    local tcs = game:GetService("TextChatService")
    if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = tcs.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync("/e laugh")
        end
    else
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if event then
            local sayReq = event:FindFirstChild("SayMessageRequest")
            if sayReq then
                sayReq:FireServer("/e laugh", "All")
            end
        end
    end
end)


	makeSectionLabel(movPage, "Reset Character", 18)
	local resetBtn = makeDangerBtn(movPage, "Autokill", 19)
	resetBtn.MouseButton1Click:Connect(function()
		local hum = getHumanoid()
		if hum then hum.Health = 0 end
	end)

	
	makeSectionLabel(movPage, "Fling", 20)

	local flingInfo = Instance.new("TextLabel")
	flingInfo.Size = UDim2.new(1,0,0,32)
	flingInfo.LayoutOrder = 21
	flingInfo.BackgroundColor3 = T().bg
	flingInfo.BackgroundTransparency = 0.15
	flingInfo.Text = "  · Teleports all players\n  with a mass-launch effect."
	flingInfo.TextColor3 = T().subtext
	flingInfo.Font = Enum.Font.Gotham
	flingInfo.TextSize = 11
	flingInfo.TextXAlignment = Enum.TextXAlignment.Left
	flingInfo.TextWrapped = true
	flingInfo.BorderSizePixel = 0
	flingInfo.Parent = movPage
	styleCorner(flingInfo, UDim.new(0,8))
	styleStroke(flingInfo, 0.85)
	table.insert(reg.panels, flingInfo)
	table.insert(reg.subtexts, flingInfo)

	local pillFling, setFling, getFling = makeToggleRow(movPage, "Fling All", 22)

	local flingRunning = false
	local flingTask = nil
	local flingConnections = {}

	local function startFling()
		if flingRunning then return end
		flingRunning = true
		
		flingTask = task.spawn(function()
			while flingRunning do
				task.wait()
				local character = player.Character
				local hrp = character and character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local velo = hrp.Velocity
					hrp.Velocity = velo * 10000 + Vector3.new(0, 10000, 0)
					RunService.RenderStepped:Wait()
					hrp.Velocity = velo
					RunService.Stepped:Wait()
				end
			end
		end)
	end

	local function stopFling()
		flingRunning = false
		if flingTask then
			task.cancel(flingTask)
			flingTask = nil
		end
		for _, conn in ipairs(flingConnections) do
			if conn then conn:Disconnect() end
		end
		flingConnections = {}
		local hrp = getHRP()
		if hrp then hrp.Velocity = Vector3.zero end
	end

	pillFling.MouseButton1Click:Connect(function()
		local v = not getFling()
		setFling(v)
		if v then
			startFling()
			showNotification(" Fling activado")
		else
			stopFling()
			showNotification("Fling desactivado")
		end
	end)

	player.CharacterAdded:Connect(function()
		if getFling() then
			task.wait(0.5)
			if getFling() then
				stopFling()
				setFling(false)
				showNotification("Fling detenido por respawn")
			end
		end
	end)

	screenGui.AncestryChanged:Connect(function()
		if not screenGui:IsDescendantOf(game) then
			stopFling()
		end
	end)

end 
----|| Page aimbot... ||---
local aimbotPage = newPage("Aimbot")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = aimbotPage
	stylePadding(aimbotPage, 0,10,0,4)

	makeSectionLabel(aimbotPage, "Murder Mistery", 1)
	local pillAimbotMM2, setStateAimbotMM2, getStateAimbotMM2 = makeToggleRow(aimbotPage, "Lock-On Asesino", 2)
	local aimbotSmooth = 8
	makeSliderRow(aimbotPage, "Smoothness", 1, 30, aimbotSmooth, function(v) aimbotSmooth = v end, 3)
	local aimbotRange = 500
	makeSliderRow(aimbotPage, "Distance", 50, 1000, aimbotRange, function(v) aimbotRange = v end, 4)

	makeSectionLabel(aimbotPage, "Normal Aimbot", 5)
	local pillAimbotGeneral, setStateAimbotGeneral, getStateAimbotGeneral = makeToggleRow(aimbotPage, "Aimbot General (Mouse Lock)", 6)
	local generalFOV = 500
	makeSliderRow(aimbotPage, "FOV (píxeles)", 50, 1200, generalFOV, function(v) generalFOV = v end, 7)
	local generalSmooth = 4
	makeSliderRow(aimbotPage, "Smoothness", 1, 15, generalSmooth, function(v) generalSmooth = v end, 8)

	local aimbotStatusBox = Instance.new("Frame")
	aimbotStatusBox.LayoutOrder = 9
	aimbotStatusBox.Size = UDim2.new(1,0,0,50)
	aimbotStatusBox.BackgroundColor3 = T().bg
	aimbotStatusBox.BackgroundTransparency = 0.22
	aimbotStatusBox.BorderSizePixel = 0
	aimbotStatusBox.Parent = aimbotPage
	styleCorner(aimbotStatusBox, UDim.new(0,10))
	styleStroke(aimbotStatusBox, 0.88)
	table.insert(reg.panels, aimbotStatusBox)

	local aimbotStatusDot = Instance.new("Frame")
	aimbotStatusDot.Size = UDim2.new(0,10,0,10)
	aimbotStatusDot.Position = UDim2.new(0,14,0.5,-5)
	aimbotStatusDot.BackgroundColor3 = T().knobOff
	aimbotStatusDot.BorderSizePixel = 0
	aimbotStatusDot.Parent = aimbotStatusBox
	styleCorner(aimbotStatusDot, UDim.new(1,0))

	local aimbotStatusLbl = Instance.new("TextLabel")
	aimbotStatusLbl.Size = UDim2.new(1,-34,1,0)
	aimbotStatusLbl.Position = UDim2.new(0,32,0,0)
	aimbotStatusLbl.BackgroundTransparency = 1
	aimbotStatusLbl.Text = "Not murderer detected"
	aimbotStatusLbl.TextColor3 = T().subtext
	aimbotStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
	aimbotStatusLbl.Font = Enum.Font.GothamSemibold
	aimbotStatusLbl.TextSize = 13
	aimbotStatusLbl.Parent = aimbotStatusBox
	table.insert(reg.subtexts, aimbotStatusLbl)

	makeInfoCard(aimbotPage,
		"• Lock-On Asesino: You just can use in MM2.\n• Aimbot general is for any player",
		10)


	local function getMurderer()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player then continue end
			local char = plr.Character
			local bp   = plr:FindFirstChild("Backpack")
			if (char and char:FindFirstChild("Knife")) or (bp and bp:FindFirstChild("Knife")) then
				return plr
			end
		end
		return nil
	end

	local function startMM2Aimbot()
		mm2Conn = RunService.RenderStepped:Connect(function()
			if not getStateAimbotMM2() then return end
			local murderer = getMurderer()
			if not murderer or not murderer.Character then
				aimbotStatusDot.BackgroundColor3 = T().knobOff
				aimbotStatusLbl.Text = "Sin asesino detectado"
				aimbotStatusLbl.TextColor3 = T().subtext
				return
			end
			local murderHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
			local myHRP     = getHRP()
			if not murderHRP or not myHRP then return end
			local dist = (myHRP.Position - murderHRP.Position).Magnitude
			if dist > aimbotRange then
				aimbotStatusDot.BackgroundColor3 = Color3.fromRGB(255,180,0)
				aimbotStatusLbl.Text = murderer.DisplayName.." Out of range"
				aimbotStatusLbl.TextColor3 = Color3.fromRGB(255,180,0)
				return
			end
			local murderHum = murderer.Character:FindFirstChildOfClass("Humanoid")
			if not murderHum or murderHum.Health <= 0 then return end
			local camera = workspace.CurrentCamera
			local targetPos
			local lowerTorso = murderer.Character:FindFirstChild("LowerTorso")
			local torso      = murderer.Character:FindFirstChild("Torso")
			if lowerTorso then
				targetPos = lowerTorso.Position
			elseif torso then
				targetPos = torso.Position
			else
				targetPos = murderHRP.Position + Vector3.new(0, 0.6, 0)
			end
			local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
			local alpha    = math.clamp(1/aimbotSmooth, 0.02, 1)
			camera.CFrame  = camera.CFrame:Lerp(targetCF, alpha)
			aimbotStatusDot.BackgroundColor3 = T().accent
			aimbotStatusLbl.Text = "Locked: "..murderer.DisplayName
			aimbotStatusLbl.TextColor3 = T().accent
		end)
	end

	local function stopMM2Aimbot()
		if mm2Conn then mm2Conn:Disconnect(); mm2Conn = nil end
		if aimbotStatusDot and aimbotStatusDot.Parent then
			aimbotStatusDot.BackgroundColor3 = T().knobOff
		end
		if aimbotStatusLbl and aimbotStatusLbl.Parent then
			aimbotStatusLbl.Text       = "Not murderer detected"
			aimbotStatusLbl.TextColor3 = T().subtext
		end
	end

	local fovCircle = Drawing.new("Circle")
	fovCircle.Visible = false
	fovCircle.Thickness = 1.5
	fovCircle.NumSides = 64
	fovCircle.Radius = generalFOV
	fovCircle.Transparency = 0.7

	local function startGeneralAimbot()
		fovCircle.Visible = true
		fovCircle.Color = T().accent
		generalConn = RunService.RenderStepped:Connect(function()
			if not getStateAimbotGeneral() then return end
			local camera  = workspace.CurrentCamera
			local myHRP   = getHRP()
			if not myHRP then return end
			local mousePos = UserInputService:GetMouseLocation()
			fovCircle.Position = mousePos
			fovCircle.Radius = generalFOV
			local closest, closestDist = nil, generalFOV
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr == player then continue end
				local char = plr.Character
				if not char then continue end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hrp or not hum or hum.Health <= 0 then continue end
				local screenPos, onScreen = camera:WorldToScreenPoint(hrp.Position)
				if not onScreen then continue end
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = hrp
				end
			end
			if closest then
				local targetCF = CFrame.new(camera.CFrame.Position, closest.Position)
				local alpha    = math.clamp(1/generalSmooth, 0.05, 1)
				camera.CFrame  = camera.CFrame:Lerp(targetCF, alpha)
				fovCircle.Color = T().accent
			else
				fovCircle.Color = T().subtext
			end
		end)
	end

	local function stopGeneralAimbot()
		fovCircle.Visible = false
		if generalConn then generalConn:Disconnect(); generalConn = nil end
	end

	
	HHBFuncs.startMM2Aimbot     = startMM2Aimbot
	HHBFuncs.stopMM2Aimbot      = stopMM2Aimbot
	HHBFuncs.startGeneralAimbot = startGeneralAimbot
	HHBFuncs.stopGeneralAimbot  = stopGeneralAimbot

	pillAimbotMM2.MouseButton1Click:Connect(function()
		local v = not getStateAimbotMM2(); setStateAimbotMM2(v)
		if v then startMM2Aimbot() else stopMM2Aimbot() end
	end)
	pillAimbotGeneral.MouseButton1Click:Connect(function()
		local v = not getStateAimbotGeneral(); setStateAimbotGeneral(v)
		if v then startGeneralAimbot() else stopGeneralAimbot() end
	end)
end

----|| Page Avatar  ||---
local avatarPage = newPage("Avatar")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = avatarPage
	stylePadding(avatarPage, 0,8,0,4)

	local AVATAR_ITEMS = {}

	local function applyKorblox()
		local char = player.Character; if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		if hum.RigType == Enum.HumanoidRigType.R15 then
			local rf = char:FindFirstChild("RightFoot")
			local rl = char:FindFirstChild("RightLowerLeg")
			local ru = char:FindFirstChild("RightUpperLeg")
			if ru and rl and rf then
				rf.Transparency = 1; rl.Transparency = 1
			ru.MeshId    = "rbxassetid://902942096"
			ru.TextureID = "rbxassetid://902843398"
				ru.Color = Color3.new(1,1,1); ru.Transparency = 0
			end
		else
			local rightLeg = char:FindFirstChild("Right Leg"); if not rightLeg then return end
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("CharacterMesh") and v.BodyPart == Enum.BodyPart.RightLeg then v:Destroy() end
			end
			local mesh = rightLeg:FindFirstChildOfClass("SpecialMesh")
			if not mesh then mesh = Instance.new("SpecialMesh"); mesh.Parent = rightLeg end
			rightLeg.Color = Color3.fromRGB(64,64,64); rightLeg.Transparency = 0
			mesh.MeshType = Enum.MeshType.FileMesh
			mesh.MeshId   = "rbxassetid://101851696"
			mesh.TextureId = "rbxassetid://101851254"
			mesh.Scale    = Vector3.new(1,1,1)
		end
	end
	local function removeKorblox()
		local char = player.Character; if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		if hum.RigType == Enum.HumanoidRigType.R15 then
			local rf = char:FindFirstChild("RightFoot")
			local rl = char:FindFirstChild("RightLowerLeg")
			local ru = char:FindFirstChild("RightUpperLeg")
			if rf then rf.Transparency = 0 end
			if rl then rl.Transparency = 0 end
			if ru then ru.MeshId = ""; ru.TextureID = "" end
		else
			local rightLeg = char:FindFirstChild("Right Leg"); if not rightLeg then return end
			local mesh = rightLeg:FindFirstChildOfClass("SpecialMesh")
			if mesh then mesh:Destroy() end
			rightLeg.Color = Color3.fromRGB(163,162,165)
		end
	end

	local function applyShoulderAcc()
		local char = player.Character; if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
		for _, v in ipairs(char:GetChildren()) do
			if v:IsA("Accessory") and v.Name == "HHB_ShoulderAcc" then v:Destroy() end
		end
		local acc = Instance.new("Accessory"); acc.Name = "HHB_ShoulderAcc"
		local handle = Instance.new("Part")
		handle.Name = "Handle"; handle.Size = Vector3.new(1,1,1)
		handle.CanCollide = false; handle.Anchored = false
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId   = "rbxassetid://110121730336323"
		mesh.Parent   = handle
		local att = Instance.new("Attachment"); att.Name = "BodyFrontAttachment"; att.Parent = handle
		handle.Parent = acc; acc.Parent = char
		hum:AddAccessory(acc)
	end
	local function removeShoulderAcc()
		local char = player.Character; if not char then return end
		for _, v in ipairs(char:GetChildren()) do
			if v:IsA("Accessory") and v.Name == "HHB_ShoulderAcc" then v:Destroy() end
		end
	end

	local _origTransparencies = {}
	local function applyInvisible()
		local char = player.Character; if not char then return end
		_origTransparencies = {}
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
				_origTransparencies[p] = p.Transparency; p.Transparency = 1
			end
		end
	end
	local function removeInvisible()
		local char = player.Character; if not char then return end
		for p, t in pairs(_origTransparencies) do
			if p and p.Parent then p.Transparency = t end
		end
		_origTransparencies = {}
	end

	local function applyNoobFace()
		local char = player.Character; if not char then return end
		local head = char:FindFirstChild("Head"); if not head then return end
		local face = head:FindFirstChildOfClass("Decal")
		if not face then face = Instance.new("Decal"); face.Name="face"; face.Parent=head end
		face.Texture = "rbxassetid://1079"
	end
	local function removeNoobFace()
		local char = player.Character; if not char then return end
		local head = char:FindFirstChild("Head"); if not head then return end
		local face = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
		if face then face.Texture = "rbxassetid://1369239677" end
	end

	local _origBodyColors = {}
	local function applyRainbowBody()
		local char = player.Character; if not char then return end
		_origBodyColors = {}
		local parts = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg",
			"UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand",
			"RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg",
			"LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
		for _, n in ipairs(parts) do
			local p = char:FindFirstChild(n)
			if p and p:IsA("BasePart") then
				_origBodyColors[n] = p.Color
				p.Color = Color3.fromHSV(math.random(), 0.9, 1)
			end
		end
	end
	local function removeRainbowBody()
		local char = player.Character; if not char then return end
		for n, col in pairs(_origBodyColors) do
			local p = char:FindFirstChild(n)
			if p and p:IsA("BasePart") then p.Color = col end
		end
		_origBodyColors = {}
	end

	local avatarCatalog = {
		{ id="korblox",   label="Korblox Deathspeaker",  desc="Pierna derecha de hueso.\nR15 y R6.",            apply=applyKorblox,    remove=removeKorblox    },
		{ id="shoulder",  label="Shoulder Accessory",    desc="Accesorio en el hombro\nfrontal del personaje.", apply=applyShoulderAcc, remove=removeShoulderAcc },
		{ id="invisible", label="Invisible",             desc="Vuelve invisible todo\nel personaje (local).",   apply=applyInvisible,  remove=removeInvisible   },
		{ id="noobface",  label="Classic Noob face",     desc="Reemplaza la cara con\nel noob original.",       apply=applyNoobFace,   remove=removeNoobFace    },
		{ id="rainbow",   label="Rainbow Body",          desc="Colorea aleatoriamente\ncada parte del cuerpo.", apply=applyRainbowBody, remove=removeRainbowBody },
	}
	for _, item in ipairs(avatarCatalog) do item.state = false end

	makeInfoCard(avatarPage, "Efectos solo visibles localmente. Se reactivan al respawnear.", 1)
	makeSectionLabel(avatarPage, "Avatar features", 2)

	for idx, item in ipairs(avatarCatalog) do
		local card = Instance.new("Frame")
		card.LayoutOrder = idx + 2
		card.Size = UDim2.new(1,0,0,76)
		card.BackgroundColor3 = T().bg
		card.BackgroundTransparency = 0.18
		card.BorderSizePixel = 0
		card.Parent = avatarPage
		styleCorner(card, UDim.new(0,10))
		styleStroke(card, 0.82)
		table.insert(reg.panels, card)

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0,10,0,10)
		dot.Position = UDim2.new(0,14,0.5,-5)
		dot.BackgroundColor3 = T().knobOff
		dot.BorderSizePixel = 0
		dot.Parent = card
		styleCorner(dot, UDim.new(1,0))

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1,-82,0,26)
		nameLbl.Position = UDim2.new(0,32,0,10)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = item.label
		nameLbl.TextColor3 = T().text
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextSize = 14
		nameLbl.Font = Enum.Font.GothamSemibold
		nameLbl.Parent = card
		table.insert(reg.texts, nameLbl)

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1,-82,0,30)
		descLbl.Position = UDim2.new(0,32,0,36)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = item.desc
		descLbl.TextColor3 = T().subtext
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextYAlignment = Enum.TextYAlignment.Top
		descLbl.TextSize = 11
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextWrapped = true
		descLbl.Parent = card
		table.insert(reg.subtexts, descLbl)

		local equipBtn = Instance.new("TextButton")
		equipBtn.Size = UDim2.new(0,64,0,34)
		equipBtn.Position = UDim2.new(1,-74,0.5,-17)
		equipBtn.BackgroundColor3 = T().bg
		equipBtn.BackgroundTransparency = 0.05
		equipBtn.Text = "Equip"
		equipBtn.TextColor3 = T().accent
		equipBtn.TextSize = 12
		equipBtn.Font = Enum.Font.GothamBold
		equipBtn.BorderSizePixel = 0
		equipBtn.AutoButtonColor = true
		equipBtn.Parent = card
		styleCorner(equipBtn, UDim.new(0,8))
		local equipStroke = styleStroke(equipBtn, 0.82, T().accent)
		table.insert(reg.panels, equipBtn)
		table.insert(reg.accentTexts, equipBtn)
		table.insert(reg.accentStrokes, equipStroke)

		local function updateCardVisual()
			if item.state then
				dot.BackgroundColor3  = T().accent
				equipBtn.Text         = "UnEquip"
				equipBtn.TextColor3   = T().danger
				equipStroke.Color     = T().danger
			else
				dot.BackgroundColor3  = T().knobOff
				equipBtn.Text         = "Equip"
				equipBtn.TextColor3   = T().accent
				equipStroke.Color     = T().accent
			end
		end

		equipBtn.MouseButton1Click:Connect(function()
			item.state = not item.state
			if item.state then pcall(item.apply) else pcall(item.remove) end
			updateCardVisual()
		end)

		AVATAR_ITEMS[#AVATAR_ITEMS+1] = { item = item, updateVisual = updateCardVisual }
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.6)
		for _, entry in ipairs(AVATAR_ITEMS) do
			if entry.item.state then pcall(entry.item.apply) end
		end
	end)

	do
		local clearBtn = makeDangerBtn(avatarPage, "Quitar todos los mods", #avatarCatalog + 4)
		clearBtn.MouseButton1Click:Connect(function()
			for _, entry in ipairs(AVATAR_ITEMS) do
				if entry.item.state then
					entry.item.state = false
					pcall(entry.item.remove)
					entry.updateVisual()
				end
			end
		end)
	end
end


----|| Script catalog||---
local gameScriptsPage = newPage("Scripts")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = gameScriptsPage
	stylePadding(gameScriptsPage, 0,8,0,4)

	makeSectionLabel(gameScriptsPage, "Script Library", 0)

	local scriptsData = {
		{
			name = "Infinite Yield",
			desc = "Admin commands for any game",
			badge = "FE Admin",
			color = Color3.fromRGB(255, 105, 180),
			icon = "rbxassetid://7484057032",
			func = function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
			end,
		},
		{
			name = "Coin collector",
			desc = "MM2 Tool & Farmer",
			badge = "Verified ",
			color = Color3.fromRGB(60, 160, 255),
			icon = "rbxassetid://6031065931",
			func = function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/overthcode2011-stack/HHB-MM2-/refs/heads/main/Coin%20collector.lua"))()
			end,
		},
		{
			name = "MM2 Headless FE",
			desc = "Headless server-side",
			badge = "Verified ",
			color = Color3.fromRGB(255, 180, 40),
			icon = "rbxassetid://6031065931",
			func = function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/overthcode2011-stack/HHB-MM2-/refs/heads/main/FE%20Headless.lua"))()
			end,
		},
	}

	for idx, data in ipairs(scriptsData) do
		local th = T()
		local card = Instance.new("Frame")
		card.LayoutOrder = idx
		card.Size = UDim2.new(1, 0, 0, 84)
		card.BackgroundColor3 = th.bg
		card.BackgroundTransparency = 0.12
		card.BorderSizePixel = 0
		card.Parent = gameScriptsPage
		styleCorner(card, UDim.new(0, 12))
		styleStroke(card, 0.78)
		table.insert(reg.panels, card)

		local glow = Instance.new("Frame")
		glow.Size = UDim2.new(0, 4, 1, 0)
		glow.BackgroundColor3 = data.color
		glow.BackgroundTransparency = 0.3
		glow.BorderSizePixel = 0
		glow.Parent = card
		styleCorner(glow, UDim.new(1, 0))

		local iconFrame = Instance.new("Frame")
		iconFrame.Size = UDim2.new(0, 34, 0, 34)
		iconFrame.Position = UDim2.new(0, 14, 0.5, -17)
		iconFrame.BackgroundColor3 = data.color
		iconFrame.BackgroundTransparency = 0.7
		iconFrame.BorderSizePixel = 0
		iconFrame.Parent = card
		styleCorner(iconFrame, UDim.new(1, 0))

		local iconLbl = Instance.new("TextLabel")
		iconLbl.Size = UDim2.new(1, 0, 1, 0)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = data.name:sub(1, 1):upper()
		iconLbl.TextColor3 = data.color
		iconLbl.Font = Enum.Font.GothamBold
		iconLbl.TextSize = 16
		iconLbl.Parent = iconFrame
		table.insert(reg.accentTexts, iconLbl)

		local badgeLbl = Instance.new("TextLabel")
		badgeLbl.Size = UDim2.new(0, 0, 0, 18)
		badgeLbl.AutomaticSize = Enum.AutomaticSize.X
		badgeLbl.Position = UDim2.new(0, 56, 0, 10)
		badgeLbl.BackgroundColor3 = data.color
		badgeLbl.BackgroundTransparency = 0.72
		badgeLbl.Text = "  "..data.badge.."  "
		badgeLbl.TextColor3 = data.color
		badgeLbl.Font = Enum.Font.GothamBold
		badgeLbl.TextSize = 9
		badgeLbl.BorderSizePixel = 0
		badgeLbl.Parent = card
		styleCorner(badgeLbl, UDim.new(1, 0))

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, -170, 0, 20)
		nameLbl.Position = UDim2.new(0, 56, 0, 32)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = data.name
		nameLbl.TextColor3 = th.text
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 15
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Parent = card
		table.insert(reg.texts, nameLbl)

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1, -170, 0, 16)
		descLbl.Position = UDim2.new(0, 56, 0, 54)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = data.desc
		descLbl.TextColor3 = th.subtext
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 11
		descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.TextTruncate = Enum.TextTruncate.AtEnd
		descLbl.Parent = card
		table.insert(reg.subtexts, descLbl)

		local runBtn = Instance.new("TextButton")
		runBtn.Size = UDim2.new(0, 82, 0, 34)
		runBtn.Position = UDim2.new(1, -92, 0.5, -17)
		runBtn.BackgroundColor3 = data.color
		runBtn.BackgroundTransparency = 0
		runBtn.Text = "Run"
		runBtn.TextColor3 = Color3.new(1, 1, 1)
		runBtn.TextSize = 12
		runBtn.Font = Enum.Font.GothamBold
		runBtn.BorderSizePixel = 0
		runBtn.AutoButtonColor = false
		runBtn.Parent = card
		styleCorner(runBtn, UDim.new(0, 8))

		runBtn.MouseEnter:Connect(function() TweenService:Create(runBtn, twI, {BackgroundTransparency=0.2}):Play() end)
		runBtn.MouseLeave:Connect(function() TweenService:Create(runBtn, twI, {BackgroundTransparency=0}):Play() end)
		runBtn.MouseButton1Click:Connect(function()
			TweenService:Create(runBtn, TweenInfo.new(0.08), {Size=UDim2.new(0, 78, 0, 30)}):Play()
			task.delay(0.12, function() TweenService:Create(runBtn, TweenInfo.new(0.12), {Size=UDim2.new(0, 82, 0, 34)}):Play() end)
			local ok, err = pcall(data.func)
			if not ok then showNotification("Script error: "..tostring(err):sub(1, 30), "danger") end
		end)
	end
end

----|| misc ||---
local miscPage = newPage("Misc")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = miscPage
	stylePadding(miscPage, 0,8,0,4)

	
makeSectionLabel(miscPage, "Auto pick up gun", 1)
	local pillGunDrop, setGunDrop, getGunDrop = makeToggleRow(miscPage, "Auto Get GunDrop", 2)
	local gunDropConn = nil
	local function startGunDrop()
		gunDropConn = task.spawn(function()
			while getGunDrop() do
				local success = obtainSheriffGun()
				if success then
					showNotification("GunDrop obtained!")
				end
				task.wait(3)
			end
		end)
	end
	local function stopGunDrop()
		if gunDropConn then
			coroutine.close(gunDropConn)
			gunDropConn = nil
		end
	end
	pillGunDrop.MouseButton1Click:Connect(function()
		local v = not getGunDrop(); setGunDrop(v)
		if v then startGunDrop() else stopGunDrop() end
	end)

	
	makeSectionLabel(miscPage, "Quick access", 3)
	local quickRow = Instance.new("Frame")
	quickRow.LayoutOrder = 4
	quickRow.Size = UDim2.new(1,0,0,42)
	quickRow.BackgroundTransparency = 1
	quickRow.BorderSizePixel = 0
	quickRow.Parent = miscPage
	local quickLayout = Instance.new("UIListLayout")
	quickLayout.FillDirection = Enum.FillDirection.Horizontal
	quickLayout.Padding = UDim.new(0,6)
	quickLayout.SortOrder = Enum.SortOrder.LayoutOrder
	quickLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	quickLayout.Parent = quickRow

	local function makeQuickButton(label, action, lo)
		local btn = Instance.new("TextButton")
		btn.LayoutOrder = lo
		btn.Size = UDim2.new(0,0,0,36)
		btn.AutomaticSize = Enum.AutomaticSize.X
		btn.BackgroundColor3 = T().accent
		btn.Text = label
		btn.TextColor3 = T().bg
		btn.TextSize = 13
		btn.Font = Enum.Font.BuilderSansBold
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = true
		btn.Parent = quickRow
		styleCorner(btn, UDim.new(0,6))
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = UDim.new(0,12)
		padding.PaddingRight = UDim.new(0,12)
		padding.Parent = btn
		btn.MouseButton1Click:Connect(action)
		return btn
	end

	makeQuickButton("Murder TP", function()
		local assassin = getPlayerWithItem("Knife")
		if teleportTo(assassin) then
			showNotification("Teleported to Murder")
		else
			showNotification("No murder found", "warning")
		end
	end, 1)

	makeQuickButton("Sheriff TP", function()
		local sheriff = getPlayerWithItem("Gun")
		if teleportTo(sheriff) then
			showNotification("Teleported to Sheriff")
		else
			showNotification("No sheriff found", "warning")
		end
	end, 2)

	makeQuickButton("Get Gun", function()
		if obtainSheriffGun() then
			showNotification("Gun obtained!")
		else
			showNotification("Gun not found", "warning")
		end
	end, 3)


	makeSectionLabel(miscPage, "Silent Aim", 5)
	local pillSilentAim, setSilentAim, getSilentAim = makeToggleRow(miscPage, "Silent Aim", 6)
	local silentAimConn = nil
	local mouse = player:GetMouse()
	local function startSilentAim()
		silentAimConn = RunService.RenderStepped:Connect(function()
			if not getSilentAim() then return end
			local target = getPlayerWithItem("Knife")
			if not target or not target.Character then return end
			local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
			if not targetHRP then return end
			local camera = workspace.CurrentCamera
			local hitCF = CFrame.new(camera.CFrame.Position, targetHRP.Position)
			pcall(function()
				mouse.Hit = hitCF
				mouse.Target = targetHRP
			end)
		end)
	end
	local function stopSilentAim()
		if silentAimConn then silentAimConn:Disconnect(); silentAimConn = nil end
	end
	pillSilentAim.MouseButton1Click:Connect(function()
		local v = not getSilentAim(); setSilentAim(v)
		if v then startSilentAim() else stopSilentAim() end
	end)

	makeSectionLabel(miscPage, "Auto Shoot", 7)
	local pillAutoShoot, setAutoShoot, getAutoShoot = makeToggleRow(miscPage, "Auto Shoot", 8)
	local autoShootConn = nil
	local lastShotTime = 0

	local function getTargetFromAimbot()
		local camera = workspace.CurrentCamera
		local mousePos = UserInputService:GetMouseLocation()
		local closest, closestDist = nil, 500
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player then continue end
			local char = plr.Character
			if not char then continue end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then continue end
			local screenPos, onScreen = camera:WorldToScreenPoint(hrp.Position)
			if not onScreen then continue end
			local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = plr
			end
		end
		return closest
	end

	local function startAutoShoot()
		autoShootConn = RunService.RenderStepped:Connect(function()
			if not getAutoShoot() then return end
			local target = getPlayerWithItem("Knife") or getTargetFromAimbot()
			if not target or not target.Character then return end
			local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
			if not targetHRP then return end
			local camera = workspace.CurrentCamera

			-- Wall detection
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			local ignore = {player.Character, camera}
			rayParams.FilterDescendantsInstances = ignore

			local origin = camera.CFrame.Position
			local direction = (targetHRP.Position - origin).Unit * 1000
			local result = workspace:Raycast(origin, direction, rayParams)

			-- Only shoot if no wall blocks the view
			if not result then
				local now = tick()
				if now - lastShotTime > 0.3 then
					lastShotTime = now
					pcall(function()
						local vim = game:GetService("VirtualInputManager")
						vim:SendMouseButtonEvent(0, 0, 0, true, game, 1)
						task.wait(0.03)
						vim:SendMouseButtonEvent(0, 0, 0, false, game, 1)
					end)
				end
			end
		end)
	end
	local function stopAutoShoot()
		if autoShootConn then autoShootConn:Disconnect(); autoShootConn = nil end
	end
	pillAutoShoot.MouseButton1Click:Connect(function()
		local v = not getAutoShoot(); setAutoShoot(v)
		if v then startAutoShoot() else stopAutoShoot() end
	end)
end

local notifIndex = 0

local function showNotification(msg, notifType)
	local th = T()
	notifIndex += 1
	local myIdx = notifIndex

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 0, 0, 46)
	notif.Position = UDim2.new(1, 0, 0, 12 + (myIdx - 1) * 54)
	notif.BackgroundColor3 = th.bg
	notif.BackgroundTransparency = 0.08
	notif.BorderSizePixel = 0
	notif.ZIndex = 100
	notif.ClipsDescendants = true
	notif.Parent = screenGui
	styleCorner(notif, UDim.new(0, 10))

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 4, 1, 0)
	accentBar.BorderSizePixel = 0
	accentBar.Parent = notif
	local barColor = (notifType == "danger" and th.danger) or (notifType == "warning" and Color3.fromRGB(255, 180, 40)) or th.accent
	accentBar.BackgroundColor3 = barColor
	styleCorner(accentBar, UDim.new(1, 0))

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 28, 1, 0)
	icon.Position = UDim2.new(0, 12, 0, 0)
	icon.BackgroundTransparency = 1
	local iconText = ""
	if notifType == "danger" then iconText = "!"
	elseif notifType == "warning" then iconText = "?"
	end
	icon.Text = iconText
	icon.TextColor3 = barColor
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 18
	icon.TextXAlignment = Enum.TextXAlignment.Center
	icon.Parent = notif

	local msgLbl = Instance.new("TextLabel")
	msgLbl.Size = UDim2.new(1, -56, 1, 0)
	msgLbl.Position = UDim2.new(0, 44, 0, 0)
	msgLbl.BackgroundTransparency = 1
	msgLbl.Text = msg
	msgLbl.TextColor3 = th.text
	msgLbl.Font = Enum.Font.GothamSemibold
	msgLbl.TextSize = 13
	msgLbl.TextXAlignment = Enum.TextXAlignment.Left
	msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
	msgLbl.Parent = notif

	local notifWidth = math.clamp(#msg * 8 + 80, 200, 400)

	local slideIn = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, notifWidth, 0, 46)
	})
	slideIn:Play()

	task.delay(2.5, function()
		local slideOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 46),
			BackgroundTransparency = 1,
		})
		slideOut:Play()
		slideOut.Completed:Once(function()
			if notif and notif.Parent then notif:Destroy() end
		end)
	end)
end
----|| Page settings ||---
local settingsPage = newPage("Settings")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = settingsPage
	stylePadding(settingsPage, 0,12,0,4)

	makeSectionLabel(settingsPage, "Theme", 1)

	local themeBox = Instance.new("Frame")
	themeBox.LayoutOrder = 2
	themeBox.Size = UDim2.new(1,0,0,0)
	themeBox.AutomaticSize = Enum.AutomaticSize.Y
	themeBox.BackgroundColor3 = T().bg
	themeBox.BackgroundTransparency = 0.22
	themeBox.BorderSizePixel = 0
	themeBox.Parent = settingsPage
	styleCorner(themeBox, UDim.new(0,10))
	styleStroke(themeBox, 0.88)
	stylePadding(themeBox, 10,14,10,10)
	table.insert(reg.panels, themeBox)

	local themeBoxLayout = Instance.new("UIListLayout")
	themeBoxLayout.Padding = UDim.new(0,12)
	themeBoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
	themeBoxLayout.Parent = themeBox

	local themeCurLbl = Instance.new("TextLabel")
	themeCurLbl.Size = UDim2.new(1,0,0,20)
	themeCurLbl.BackgroundTransparency = 1
	themeCurLbl.Text = "Tema actual:  "..currentThemeName
	themeCurLbl.TextColor3 = T().subtext
	themeCurLbl.Font = Enum.Font.GothamSemibold
	themeCurLbl.TextSize = 13
	themeCurLbl.TextXAlignment = Enum.TextXAlignment.Left
	themeCurLbl.LayoutOrder = 1
	themeCurLbl.Parent = themeBox
	table.insert(reg.subtexts, themeCurLbl)

	local swatchRow1 = Instance.new("Frame")
	swatchRow1.LayoutOrder = 2
	swatchRow1.Size = UDim2.new(1,0,0,46)
	swatchRow1.BackgroundTransparency = 1
	swatchRow1.BorderSizePixel = 0
	swatchRow1.Parent = themeBox
	local swatchL1 = Instance.new("UIListLayout")
	swatchL1.FillDirection = Enum.FillDirection.Horizontal
	swatchL1.Padding = UDim.new(0,8)
	swatchL1.SortOrder = Enum.SortOrder.LayoutOrder
	swatchL1.VerticalAlignment = Enum.VerticalAlignment.Center
	swatchL1.Parent = swatchRow1

	local exclusiveLbl = Instance.new("TextLabel")
	exclusiveLbl.LayoutOrder = 3
	exclusiveLbl.Size = UDim2.new(1,0,0,18)
	exclusiveLbl.BackgroundTransparency = 1
	exclusiveLbl.Text = "Temas exclusivos"
	exclusiveLbl.TextColor3 = T().subtext
	exclusiveLbl.Font = Enum.Font.GothamBold
	exclusiveLbl.TextSize = 11
	exclusiveLbl.TextXAlignment = Enum.TextXAlignment.Left
	exclusiveLbl.Parent = themeBox
	table.insert(reg.subtexts, exclusiveLbl)

	local swatchRow2 = Instance.new("Frame")
	swatchRow2.LayoutOrder = 4
	swatchRow2.Size = UDim2.new(1,0,0,46)
	swatchRow2.BackgroundTransparency = 1
	swatchRow2.BorderSizePixel = 0
	swatchRow2.Parent = themeBox
	local swatchL2 = Instance.new("UIListLayout")
	swatchL2.FillDirection = Enum.FillDirection.Horizontal
	swatchL2.Padding = UDim.new(0,8)
	swatchL2.SortOrder = Enum.SortOrder.LayoutOrder
	swatchL2.VerticalAlignment = Enum.VerticalAlignment.Center
	swatchL2.Parent = swatchRow2

	local SWATCH_DEFS = {
		{ name="Dark",      col=Color3.fromRGB(30,30,30),       row=swatchRow1 },
		{ name="Purple",    col=Color3.fromRGB(160,80,255),     row=swatchRow1 },
		{ name="Blue",      col=Color3.fromRGB(40,160,255),     row=swatchRow1 },
		{ name="Red",       col=Color3.fromRGB(230,50,50),      row=swatchRow1 },
		{ name="White",     col=Color3.fromRGB(210,210,210),    row=swatchRow1 },
		{ name="Valentine", col=Color3.fromRGB(255,105,155),    row=swatchRow2 },
		{ name="Cat",   col=Color3.fromRGB(30,30,30),       row=swatchRow2 },
	}

	local swatchData = {}

	for i, def in ipairs(SWATCH_DEFS) do
		local sw = Instance.new("ImageButton")
		sw.Size = UDim2.new(0,42,0,42)
		sw.BackgroundColor3 = def.col
		sw.Image = THEMES[def.name].icon
		sw.ImageColor3 = Color3.new(1,1,1)
		sw.ImageTransparency = 0.55
		sw.ScaleType = Enum.ScaleType.Fit
		sw.BorderSizePixel = 0
		sw.AutoButtonColor = false
		sw.LayoutOrder = i
		sw.Parent = def.row
		styleCorner(sw, UDim.new(0,10))
		local stroke = styleStroke(sw, 0.92, Color3.new(1,1,1), 1)

		local nameLbl2 = Instance.new("TextLabel")
		nameLbl2.Size = UDim2.new(1,0,0,14)
		nameLbl2.Position = UDim2.new(0,0,1,2)
		nameLbl2.BackgroundTransparency = 1
		nameLbl2.Text = def.name
		nameLbl2.TextColor3 = T().subtext
		nameLbl2.Font = Enum.Font.Gotham
		nameLbl2.TextSize = 9
		nameLbl2.TextXAlignment = Enum.TextXAlignment.Center
		nameLbl2.Parent = sw
		table.insert(reg.subtexts, nameLbl2)

		swatchData[def.name] = {btn=sw, stroke=stroke}

		sw.MouseButton1Click:Connect(function()
			for _, d in pairs(swatchData) do
				d.stroke.Transparency = 0.92
				d.stroke.Thickness    = 1
				d.stroke.Color        = Color3.new(1,1,1)
			end
			stroke.Color        = THEMES[def.name].accent
			stroke.Transparency = 0
			stroke.Thickness    = 2.5

			currentThemeName = def.name
			themeCurLbl.Text = "Actual theme:  "..def.name
			applyTheme()
			switchTab(activeTabName)
			showNotification("Theme: " .. def.name)
		end)
	end

	task.defer(function()
		local d = swatchData[currentThemeName]
		if d then
			d.stroke.Color        = THEMES[currentThemeName].accent
			d.stroke.Transparency = 0
			d.stroke.Thickness    = 2.5
		end
	end)

	makeSectionLabel(settingsPage, "Visual", 3)

	local pillFullbright, setFullbright, getFullbright = makeToggleRow(settingsPage, "Fullbright", 4)
	pillFullbright.MouseButton1Click:Connect(function()
		local v = not getFullbright(); setFullbright(v)
		local Lighting = game:GetService("Lighting")
		if v then
			Lighting.Brightness    = 10
			Lighting.ClockTime     = 14
			Lighting.FogEnd        = 1e6
			Lighting.GlobalShadows = false
		else
			Lighting.Brightness    = 1
			Lighting.ClockTime     = 14
			Lighting.FogEnd        = 100000
			Lighting.GlobalShadows = true
		end
	end)

	local pillHideGui, setHideGui, getHideGui = makeToggleRow(settingsPage, "Hide GUIs", 5)
	pillHideGui.MouseButton1Click:Connect(function()
		local v = not getHideGui(); setHideGui(v)
		for _, g in ipairs(player.PlayerGui:GetChildren()) do
			if g ~= screenGui and g:IsA("ScreenGui") then
				g.Enabled = not v
			end
		end
	end)

	makeSectionLabel(settingsPage, "Set Custom decal", 6)

	local iconBox = Instance.new("Frame")
	iconBox.LayoutOrder = 7
	iconBox.Size = UDim2.new(1,0,0,84)
	iconBox.BackgroundColor3 = T().bg
	iconBox.BackgroundTransparency = 0.22
	iconBox.BorderSizePixel = 0
	iconBox.Parent = settingsPage
	styleCorner(iconBox, UDim.new(0,10))
	styleStroke(iconBox, 0.88)
	stylePadding(iconBox, 10,10,10,10)
	table.insert(reg.panels, iconBox)

	local iconPreview = Instance.new("ImageLabel")
	iconPreview.Size = UDim2.new(0,52,0,52)
	iconPreview.Position = UDim2.new(0,0,0.5,-26)
	iconPreview.BackgroundTransparency = 1
	iconPreview.Image = ICON_ID
	iconPreview.ImageColor3 = T().accent
	iconPreview.ScaleType = Enum.ScaleType.Fit
	iconPreview.Parent = iconBox
	table.insert(iconRefs, iconPreview)

	local iconIdHint = Instance.new("TextLabel")
	iconIdHint.Size = UDim2.new(1,-68,0,20)
	iconIdHint.Position = UDim2.new(0,62,0,2)
	iconIdHint.BackgroundTransparency = 1
	iconIdHint.Text = "Asset ID  (numero o rbxassetid://...)"
	iconIdHint.TextColor3 = T().subtext
	iconIdHint.Font = Enum.Font.Gotham
	iconIdHint.TextSize = 11
	iconIdHint.TextXAlignment = Enum.TextXAlignment.Left
	iconIdHint.TextWrapped = true
	iconIdHint.Parent = iconBox
	table.insert(reg.subtexts, iconIdHint)

	local iconIdBox = Instance.new("TextBox")
	iconIdBox.Size = UDim2.new(1,-68,0,34)
	iconIdBox.Position = UDim2.new(0,62,0,28)
	iconIdBox.BackgroundColor3 = T().bg
	iconIdBox.BackgroundTransparency = 0.1
	iconIdBox.TextColor3 = T().text
	iconIdBox.PlaceholderText = "rbxassetid://104348663064077"
	iconIdBox.Text = ICON_ID
	iconIdBox.TextSize = 12
	iconIdBox.Font = Enum.Font.Gotham
	iconIdBox.ClearTextOnFocus = false
	iconIdBox.TextXAlignment = Enum.TextXAlignment.Left
	iconIdBox.BorderSizePixel = 0
	iconIdBox.Parent = iconBox
	styleCorner(iconIdBox, UDim.new(0,7))
	styleStroke(iconIdBox, 0.88)
	stylePadding(iconIdBox, 0,0,8,8)
	table.insert(reg.panels, iconIdBox)
	table.insert(reg.texts, iconIdBox)

	iconIdBox.FocusLost:Connect(function()
		local raw = iconIdBox.Text
		local id  = raw:match("rbxassetid://(%d+)") or raw:match("^(%d+)$")
		if id then
			local full = "rbxassetid://"..id
			iconIdBox.Text    = full
			iconPreview.Image = full
			headerIcon.Image  = full
			customIconOverride = full
			if toggleBtn then toggleBtn.Image = full end
		end
	end)

	makeSectionLabel(settingsPage, "Warn zone", 8)
	local deleteGuiBtn = makeDangerBtn(settingsPage, "Delete UI", 9)
	deleteGuiBtn.MouseButton1Click:Connect(function()
		
		pcall(HHBFuncs.stopFly)
		pcall(HHBFuncs.stopMM2Aimbot)
		pcall(HHBFuncs.stopGeneralAimbot)
		if noclipConn   then pcall(function() noclipConn:Disconnect()   end); noclipConn   = nil end
		if godConn      then pcall(function() godConn:Disconnect()      end); godConn      = nil end
		if antiAFKConn  then pcall(function() antiAFKConn:Disconnect()  end); antiAFKConn  = nil end
		if antiFlingConn then pcall(function() antiFlingConn:Disconnect() end); antiFlingConn = nil end
		if screenGui and screenGui.Parent then screenGui:Destroy() end
	end)
end

--|| ESP LOGIC ||--

local ESP = {
    active = {
        PL = false,
        MM2 = false,
        OG = false,
        NameTag = false,
        TeamOnly = false
    },
    highlights = {
        PL = {},
        MM2 = {},
        OG = {}
    },
    nameTags = {},
    connections = {}
}

-- === CONFIGURACIÓN ===
local ESP_COLORS = {
    PL = {
        Criminals = Color3.fromRGB(255, 60, 60),
        Guards = Color3.fromRGB(60, 160, 255),
        Inmates = Color3.fromRGB(255, 180, 40),
        Neutral = Color3.fromRGB(255, 255, 255)
    },
    MM2 = {
        Murderer = Color3.fromRGB(255, 0, 0),
        Sheriff = Color3.fromRGB(0, 132, 255),
        Innocent = Color3.fromRGB(56, 255, 112)
    },
    OG = Color3.fromRGB(255, 255, 255)
}

-- === FUNCIONES DE UTILIDAD ===
local function getTeamColor(plr)
    if not plr.Team then return ESP_COLORS.PL.Neutral end
    return ESP_COLORS.PL[plr.Team.Name] or ESP_COLORS.PL.Neutral
end

-- Detección mejorada de rol en MM2
local function hasTool(parent, toolName)
    if not parent then return false end
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name == toolName:lower() or name:find(toolName:lower(), 1, true) then
                return true
            end
        end
    end
    return false
end

local function getMM2Role(plr)
    if plr == player then return "Innocent" end
    local char = plr.Character
    local bp = plr:FindFirstChildOfClass("Backpack")
    
    if hasTool(char, "Knife") or hasTool(bp, "Knife") then
        return "Murderer"
    end
    if hasTool(char, "Gun") or hasTool(bp, "Gun") then
        return "Sheriff"
    end
    return "Innocent"
end

local function isEnemy(plr)
    if not ESP.active.TeamOnly then return true end
    return plr.Team ~= player.Team
end

-- === LIMPIAR HIGHLIGHTS DE UN JUGADOR ===
local function clearHighlights(plr)
    if ESP.highlights.PL[plr] then
        ESP.highlights.PL[plr]:Destroy()
        ESP.highlights.PL[plr] = nil
    end
    if ESP.highlights.MM2[plr] then
        ESP.highlights.MM2[plr]:Destroy()
        ESP.highlights.MM2[plr] = nil
    end
    if ESP.highlights.OG[plr] then
        ESP.highlights.OG[plr]:Destroy()
        ESP.highlights.OG[plr] = nil
    end
    if ESP.nameTags[plr] then
        if ESP.nameTags[plr].bb and ESP.nameTags[plr].bb.Parent then
            ESP.nameTags[plr].bb:Destroy()
        end
        ESP.nameTags[plr] = nil
    end
end

-- === APLICAR ESP A UN JUGADOR ===
local function applyESP(plr)
    if plr == player then return end
    
    local char = plr.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    -- PL ESP
    if ESP.active.PL and isEnemy(plr) then
        if not ESP.highlights.PL[plr] then
            local h = Instance.new("Highlight")
            h.Name = "HHB_ESP_PL"
            h.FillColor = getTeamColor(plr)
            h.OutlineColor = Color3.new(1, 1, 1)
            h.FillTransparency = 0.2
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            ESP.highlights.PL[plr] = h
        end
    elseif ESP.highlights.PL[plr] then
        ESP.highlights.PL[plr]:Destroy()
        ESP.highlights.PL[plr] = nil
    end
    
    -- MM2 ESP
    if ESP.active.MM2 then
        local role = getMM2Role(plr)
        if not ESP.highlights.MM2[plr] then
            local h = Instance.new("Highlight")
            h.Name = "HHB_ESP_MM2"
            h.FillColor = ESP_COLORS.MM2[role]
            h.OutlineColor = ESP_COLORS.MM2[role]
            h.FillTransparency = 0.2
            h.OutlineTransparency = 1
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            ESP.highlights.MM2[plr] = h
        else
            ESP.highlights.MM2[plr].FillColor = ESP_COLORS.MM2[role]
            ESP.highlights.MM2[plr].OutlineColor = ESP_COLORS.MM2[role]
        end
    elseif ESP.highlights.MM2[plr] then
        ESP.highlights.MM2[plr]:Destroy()
        ESP.highlights.MM2[plr] = nil
    end
    
    -- OG ESP
    if ESP.active.OG then
        if not ESP.highlights.OG[plr] then
            local h = Instance.new("Highlight")
            h.Name = "HHB_ESP_OG"
            h.FillColor = ESP_COLORS.OG
            h.OutlineColor = ESP_COLORS.OG
            h.FillTransparency = 0.5
            h.OutlineTransparency = 1
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            ESP.highlights.OG[plr] = h
        end
    elseif ESP.highlights.OG[plr] then
        ESP.highlights.OG[plr]:Destroy()
        ESP.highlights.OG[plr] = nil
    end
    
    -- NameTag
    if ESP.active.NameTag then
        if not ESP.nameTags[plr] then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bb = Instance.new("BillboardGui")
                bb.Name = "HHB_NameTag"
                bb.Size = UDim2.new(0, 110, 0, 32)
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop = true
                bb.Adornee = hrp
                bb.Parent = hrp
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.new(1, 1, 1)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.TextStrokeTransparency = 0.4
                lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                lbl.Parent = bb
                
                ESP.nameTags[plr] = {bb = bb, lbl = lbl}
            end
        end
    elseif ESP.nameTags[plr] then
        ESP.nameTags[plr].bb:Destroy()
        ESP.nameTags[plr] = nil
    end
end

-- === ACTUALIZAR TODOS LOS JUGADORES ===
local function refreshAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            if not plr.Character then
                clearHighlights(plr)
            else
                applyESP(plr)
            end
        end
    end
end

-- === ACTIVAR/DESACTIVAR ESP ===
local function setESP(mode, active)
    ESP.active[mode] = active
    refreshAllESP()
end

-- === ACTUALIZADOR PERIÓDICO PARA MM2 ===
local mm2PeriodicUpdateThread = nil
local function startMM2PeriodicUpdate()
    if mm2PeriodicUpdateThread then return end
    mm2PeriodicUpdateThread = task.spawn(function()
        while ESP.active.MM2 do
            task.wait(1)
            if ESP.active.MM2 then
                refreshAllESP() -- Actualiza todos los ESP (incluido MM2)
            end
        end
        mm2PeriodicUpdateThread = nil
    end)
end

local function stopMM2PeriodicUpdate()
    if mm2PeriodicUpdateThread then
        task.cancel(mm2PeriodicUpdateThread)
        mm2PeriodicUpdateThread = nil
    end
end

-- === CONFIGURAR EVENTOS ===
local function setupCharacterToolListeners(plr)
    local char = plr.Character
    if not char then return end
    
    local addedConn = char.ChildAdded:Connect(function(child)
        if ESP.active.MM2 and child:IsA("Tool") then
            task.wait(0.1)
            applyESP(plr)
        end
    end)
    local removedConn = char.ChildRemoved:Connect(function(child)
        if ESP.active.MM2 and child:IsA("Tool") then
            task.wait(0.1)
            applyESP(plr)
        end
    end)
    table.insert(ESP.connections, addedConn)
    table.insert(ESP.connections, removedConn)
end

local function setupPlayerEvents(plr)
    if plr == player then return end
    
    local charConn = plr.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        clearHighlights(plr)
        applyESP(plr)
        setupCharacterToolListeners(plr)  -- Conectar listeners para el nuevo personaje
    end)
    table.insert(ESP.connections, charConn)
    
    local charRemovingConn = plr.CharacterRemoving:Connect(function()
        clearHighlights(plr)
    end)
    table.insert(ESP.connections, charRemovingConn)
    
    if plr:FindFirstChild("Team") then
        local teamConn = plr:GetPropertyChangedSignal("Team"):Connect(function()
            if ESP.active.PL then
                applyESP(plr)
            end
        end)
        table.insert(ESP.connections, teamConn)
    end
    
    local backpack = plr:FindFirstChildOfClass("Backpack")
    if backpack then
        local backpackAdded = backpack.ChildAdded:Connect(function(child)
            if ESP.active.MM2 and child:IsA("Tool") then
                task.wait(0.1)
                applyESP(plr)
            end
        end)
        local backpackRemoved = backpack.ChildRemoved:Connect(function(child)
            if ESP.active.MM2 and child:IsA("Tool") then
                task.wait(0.1)
                applyESP(plr)
            end
        end)
        table.insert(ESP.connections, backpackAdded)
        table.insert(ESP.connections, backpackRemoved)
    end
    
    if plr.Character then
        setupCharacterToolListeners(plr)
    end
    
    local removeConn = plr.AncestryChanged:Connect(function()
        if not plr.Parent then
            clearHighlights(plr)
        end
    end)
    table.insert(ESP.connections, removeConn)
end

-- === CONFIGURAR JUGADORES EXISTENTES ===
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then
        setupPlayerEvents(plr)
    end
end

-- === NUEVOS JUGADORES ===
Players.PlayerAdded:Connect(function(plr)
    setupPlayerEvents(plr)
end)

-- === ESCUCHAR RoundStarted ===
local replicatedStorage = game:GetService("ReplicatedStorage")
local roundStartRemote = replicatedStorage:FindFirstChild("Remotes") and replicatedStorage.Remotes:FindFirstChild("Gameplay") and replicatedStorage.Remotes.Gameplay:FindFirstChild("RoundStarted")
if roundStartRemote then
    local roundStartConn = roundStartRemote.OnClientEvent:Connect(function()
        refreshAllESP()
    end)
    table.insert(ESP.connections, roundStartConn)
end

-- === ACTUALIZAR DISTANCIAS EN NAMETAGS ===
local nameTagUpdater
local function startNameTagUpdater()
    if nameTagUpdater then return end
    nameTagUpdater = RunService.Heartbeat:Connect(function()
        if not ESP.active.NameTag then return end
        
        local myHRP = getHRP()
        if not myHRP then return end
        
        for plr, data in pairs(ESP.nameTags) do
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

-- === FUNCIONES PÚBLICAS PARA LOS TOGGLES ===
function enableESP_PL()
    setESP("PL", true)
end

function disableESP_PL()
    setESP("PL", false)
end

function enableESP_MM2()
    setESP("MM2", true)
    startMM2PeriodicUpdate()
end

function disableESP_MM2()
    setESP("MM2", false)
    stopMM2PeriodicUpdate()
end

function enableESP_OG()
    setESP("OG", true)
end

function disableESP_OG()
    setESP("OG", false)
end

function enableNameTags()
    setESP("NameTag", true)
    startNameTagUpdater()
end

function disableNameTags()
    setESP("NameTag", false)
    if nameTagUpdater then
        nameTagUpdater:Disconnect()
        nameTagUpdater = nil
    end
end

function setTeamOnly(active)
    ESP.active.TeamOnly = active
    if ESP.active.PL then
        refreshAllESP()
    end
end

-- === LIMPIEZA AL CERRAR GUI ===
local function cleanupESP()
    stopMM2PeriodicUpdate()
    
    for _, conn in ipairs(ESP.connections) do
        conn:Disconnect()
    end
    ESP.connections = {}
    
    if nameTagUpdater then
        nameTagUpdater:Disconnect()
        nameTagUpdater = nil
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        clearHighlights(plr)
    end
end

HHBFuncs.cleanupESP = cleanupESP
----|| toggle ||---
local function openGui()
    panel.Visible = true
    panel.BackgroundTransparency = PANEL_TRANSPARENCY
end

local function closeGui()
    panel.Visible = false
end

local toggle = Instance.new("ImageButton")
toggle.Name = "HHBToggle"
toggle.Size = UDim2.new(0,62,0,62)
toggle.Position = UDim2.new(1,-80,1,-90)
toggle.BackgroundColor3 = T().bg
toggle.BackgroundTransparency = 0.5
toggle.AutoButtonColor = true
toggle.Image = ICON_ID
toggle.ImageColor3 = T().accent
toggle.ScaleType = Enum.ScaleType.Fit
toggle.BorderSizePixel = 0
toggle.Parent = screenGui
styleCorner(toggle, UDim.new(0,14))
styleStroke(toggle, 0.85)
table.insert(reg.panels, toggle)
toggleBtn = toggle

local draggingT, wasDragged, dragInputT, dragStartT, startPosT = false, false, nil, nil, nil
local DRAG_THRESHOLD = 12
toggle.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingT = true; wasDragged = false
		dragStartT = inp.Position; startPosT = toggle.AbsolutePosition; dragInputT = inp
	end
end)
UserInputService.InputChanged:Connect(function(inp)
	if not draggingT then return end
	if inp ~= dragInputT and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	if dragStartT then
		local delta = inp.Position - dragStartT
		if delta.Magnitude >= DRAG_THRESHOLD then wasDragged = true end
		local vp = workspace.CurrentCamera.ViewportSize
		local bw, bh = toggle.AbsoluteSize.X, toggle.AbsoluteSize.Y
		toggle.Position = UDim2.new(0,
			math.clamp(startPosT.X + delta.X, 0, vp.X - bw), 0,
			math.clamp(startPosT.Y + delta.Y, 0, vp.Y - bh))
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp == dragInputT then draggingT = false; dragInputT = nil end
end)
toggle.MouseButton1Click:Connect(function()
	if wasDragged then wasDragged = false; return end
	if panel.Visible then closeGui() else openGui() end
end)

UserInputService.InputBegan:Connect(function(inp, processed)
	if processed then return end
	if inp.KeyCode == Enum.KeyCode.F3 then
		if panel.Visible then closeGui() else openGui() end
	end
end)

switchTab("Home")
applyTheme()
print("\27[38;2;0;255;0mHappy Hub Open source Licenced by Github > By Odecode .\n")---aplicar aqui
