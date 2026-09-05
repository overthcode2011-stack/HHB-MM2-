--|| Happy  Hub ~ By Odecode ||--
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

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
local HHBFuncs = {}
local toggleBtn
local headerIcon
local minimizeBtn

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
end

---------|| Global config ||----------
local PANEL_TRANSPARENCY = 0.45
local ICON_ID            = "rbxassetid://104348663064077"
local CLOSE_ICON_ID      = "rbxassetid://115558082558028"
local VERIFIED_ICON_ID   = "rbxassetid://13737813988"

local function getHRP()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

-------------||  Styles ||----------------
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

-------------||  Toggle Row ||----------------
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

-------------||  Slider Row ||----------------
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

-------------||  Principal Gui ||----------------
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
panel.BackgroundTransparency = 0.45
panel.BorderSizePixel = 0
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.ClipsDescendants = true
panel.Visible = true
panel.Parent = screenGui
styleCorner(panel, UDim.new(0, 18))
styleStroke(panel, 0.65)
table.insert(reg.panels, panel)

-------------||  Header ||----------------
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

headerIcon = Instance.new("ImageLabel")
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
authorLabel.Text = "By @replicatedman - Keyless - Prison Life"
authorLabel.TextColor3 = T().subtext
authorLabel.TextXAlignment = Enum.TextXAlignment.Left
authorLabel.TextSize = 10
authorLabel.Font = Enum.Font.Gotham
authorLabel.Parent = header
table.insert(reg.subtexts, authorLabel)

minimizeBtn = Instance.new("ImageButton")
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
local originalTransparency = panel.BackgroundTransparency

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetTransparency = isMinimized and 1 or originalTransparency
    local targetSize = isMinimized and CLOSED_SIZE or OPEN_SIZE
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(panel, tweenInfo, {Size = targetSize}):Play()
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

-------------||  Sidebar ||----------------
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

local tabDefs = {"Home", "ESP", "Settings"}
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

-------------|| HOME PAGE ||----------------
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
	hubNameLbl.Text = "Prison Life Hub"
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
	hubSubLbl.Text = "Best free hub - Prison Life - Keyless"
	hubSubLbl.TextColor3 = T().subtext
	hubSubLbl.Font = Enum.Font.Gotham
	hubSubLbl.TextSize = 11
	hubSubLbl.TextXAlignment = Enum.TextXAlignment.Left
	hubSubLbl.Parent = headerCard
	table.insert(reg.subtexts, hubSubLbl)

	makeSectionLabel(homePage, "Creators", 2)

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

	makeOwnerCard(homePage, "replicatedman", "Developer - Hub Creator", 3)
	makeOwnerCard(homePage, "OverthaneRBX", "Co-Owner - Test & Scripts", 4)

	makeSectionLabel(homePage, "Features", 5)

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

	makeFeatureRow(homePage, "ESP", "Player Highlights - NameTags - Item ESP", 6)
	makeFeatureRow(homePage, "Weapons", "Get AK-47 & Shotgun instantly", 7)
	makeFeatureRow(homePage, "Movement", "WalkSpeed - JumpPower - Anti-Jump Bypass", 8)
	makeFeatureRow(homePage, "Settings", "Themes - Fullbright", 9)
end

-------------|| ESP PAGE ||----------------
local espPage = newPage("ESP")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = espPage
	stylePadding(espPage, 0,8,0,4)

	makeSectionLabel(espPage, "Player ESP", 1)
	
	local pillESP, setESP, getESP = makeToggleRow(espPage, "ESP Highlights", 2)
	local pillNameTag, setNameTag, getNameTag = makeToggleRow(espPage, "NameTags", 3)
	
	makeInfoCard(espPage, "Criminals: Red  |  Guards: Blue  |  Inmates: Yellow", 4)

	local espActive = false
	local nameTagActive = false
	local espHighlights = {}
	local espNameTags = {}
	local espConnections = {}

	local TEAM_COLORS = {
		Criminals = Color3.fromRGB(255, 60, 60),
		Guards = Color3.fromRGB(60, 160, 255),
		Inmates = Color3.fromRGB(255, 180, 40),
	}

	local function getTeamColor(plr)
		if not plr.Team then return TEAM_COLORS.Inmates end
		return TEAM_COLORS[plr.Team.Name] or TEAM_COLORS.Inmates
	end

	local function clearESP()
		for plr, highlight in pairs(espHighlights) do
			if highlight and highlight.Parent then highlight:Destroy() end
		end
		espHighlights = {}
		for plr, data in pairs(espNameTags) do
			if data and data.bb and data.bb.Parent then data.bb:Destroy() end
		end
		espNameTags = {}
	end

	local function applyESPToPlayer(plr)
		if plr == player then return end
		local char = plr.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end
		
		if espActive then
			if not espHighlights[plr] then
				local h = Instance.new("Highlight")
				h.Name = "PL_ESP"
				h.FillColor = getTeamColor(plr)
				h.FillTransparency = 0.3
				h.OutlineTransparency = 1
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = char
				espHighlights[plr] = h
			else
				espHighlights[plr].FillColor = getTeamColor(plr)
			end
		elseif espHighlights[plr] then
			espHighlights[plr]:Destroy()
			espHighlights[plr] = nil
		end
		
		if nameTagActive then
			if not espNameTags[plr] then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local bb = Instance.new("BillboardGui")
					bb.Name = "PL_NameTag"
					bb.Size = UDim2.new(0, 120, 0, 34)
					bb.StudsOffset = Vector3.new(0, 3.5, 0)
					bb.AlwaysOnTop = true
					bb.Adornee = hrp
					bb.Parent = hrp
					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(1, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.TextColor3 = Color3.new(1, 1, 1)
					lbl.Font = Enum.Font.GothamBold
					lbl.TextSize = 14
					lbl.TextStrokeTransparency = 0.3
					lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
					lbl.Parent = bb
					espNameTags[plr] = {bb = bb, lbl = lbl}
				end
			end
		elseif espNameTags[plr] then
			espNameTags[plr].bb:Destroy()
			espNameTags[plr] = nil
		end
	end

	local function refreshAllESP()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then applyESPToPlayer(plr) end
		end
	end

	local function setupPlayerEvents(plr)
		if plr == player then return end
		local charConn = plr.CharacterAdded:Connect(function()
			task.wait(0.3)
			applyESPToPlayer(plr)
		end)
		table.insert(espConnections, charConn)
		local charRemovingConn = plr.CharacterRemoving:Connect(function()
			if espHighlights[plr] then
				espHighlights[plr]:Destroy()
				espHighlights[plr] = nil
			end
			if espNameTags[plr] then
				espNameTags[plr].bb:Destroy()
				espNameTags[plr] = nil
			end
		end)
		table.insert(espConnections, charRemovingConn)
		if plr:FindFirstChild("Team") then
			local teamConn = plr:GetPropertyChangedSignal("Team"):Connect(function()
				if espActive then applyESPToPlayer(plr) end
			end)
			table.insert(espConnections, teamConn)
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do setupPlayerEvents(plr) end
	Players.PlayerAdded:Connect(setupPlayerEvents)

	local nameTagUpdater
	local function startNameTagUpdater()
		if nameTagUpdater then return end
		nameTagUpdater = RunService.Heartbeat:Connect(function()
			if not nameTagActive then return end
			local myHRP = getHRP()
			if not myHRP then return end
			for plr, data in pairs(espNameTags) do
				if plr.Character and data.lbl then
					local theirHRP = plr.Character:FindFirstChild("HumanoidRootPart")
					if theirHRP then
						local dist = math.floor((myHRP.Position - theirHRP.Position).Magnitude)
						local teamName = plr.Team and plr.Team.Name or "Inmate"
						data.lbl.Text = plr.DisplayName .. " [" .. teamName .. "]\n" .. dist .. "m"
					else
						data.lbl.Text = plr.DisplayName
					end
				end
			end
		end)
	end

	pillESP.MouseButton1Click:Connect(function()
		local v = not getESP()
		setESP(v)
		espActive = v
		refreshAllESP()
	end)

	pillNameTag.MouseButton1Click:Connect(function()
		local v = not getNameTag()
		setNameTag(v)
		nameTagActive = v
		if v then
			startNameTagUpdater()
		else
			if nameTagUpdater then
				nameTagUpdater:Disconnect()
				nameTagUpdater = nil
			end
			for plr, data in pairs(espNameTags) do
				if data and data.bb then data.bb:Destroy() end
			end
			espNameTags = {}
		end
		refreshAllESP()
	end)

	-- Item ESP
	makeSectionLabel(espPage, "Item ESP", 5)

	local pillItemESP, setItemESP, getItemESP = makeToggleRow(espPage, "Show All Items", 6)

	local itemESPActive = false
	local itemHighlights = {}
	local itemNameTags = {}
	local itemConnections = {}

	local function clearItemESP()
		for _, hl in pairs(itemHighlights) do if hl and hl.Parent then hl:Destroy() end end
		itemHighlights = {}
		for _, bb in pairs(itemNameTags) do if bb and bb.Parent then bb:Destroy() end end
		itemNameTags = {}
	end

	local function applyItemESP()
		clearItemESP()
		if not itemESPActive then return end
		for _, giver in pairs(CollectionService:GetTagged("Giver")) do
			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.fromRGB(0, 255, 200)
			hl.FillTransparency = 0.2
			hl.OutlineTransparency = 0.8
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = giver
			itemHighlights[giver] = hl
			for _, part in pairs(giver:GetChildren()) do
				if part:IsA("BasePart") then
					if not part:GetAttribute("OriginalTransparency") then
						part:SetAttribute("OriginalTransparency", part.Transparency)
					end
					part.Transparency = 0
				end
			end
			local hrp = giver:FindFirstChild("HumanoidRootPart")
			if not hrp then
				for _, part in pairs(giver:GetChildren()) do
					if part:IsA("BasePart") then hrp = part; break end
				end
			end
			if hrp then
				local bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 120, 0, 30)
				bb.StudsOffset = Vector3.new(0, 3, 0)
				bb.AlwaysOnTop = true
				bb.Adornee = hrp
				bb.Parent = hrp
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.TextColor3 = Color3.fromRGB(0, 255, 200)
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 12
				lbl.TextStrokeTransparency = 0.3
				lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
				local itemName = giver.Name
				if itemName:find("Gun") or itemName:find("Weapon") or itemName:find("Pistol") then
					lbl.Text = itemName
					lbl.TextColor3 = Color3.fromRGB(255, 50, 50)
				elseif itemName:find("Card") or itemName:find("Key") then
					lbl.Text = itemName
					lbl.TextColor3 = Color3.fromRGB(50, 150, 255)
				elseif itemName:find("Drop") then
					lbl.Text = itemName
					lbl.TextColor3 = Color3.fromRGB(255, 200, 50)
				else
					lbl.Text = itemName
				end
				lbl.Parent = bb
				itemNameTags[giver] = bb
			end
		end
	end

	local function setupItemConnections()
		local addedConn = CollectionService:GetInstanceAddedSignal("Giver"):Connect(function()
			task.wait(0.1)
			if itemESPActive then applyItemESP() end
		end)
		table.insert(itemConnections, addedConn)
		local removedConn = CollectionService:GetInstanceRemovedSignal("Giver"):Connect(function(instance)
			if itemESPActive then
				if itemHighlights[instance] then
					itemHighlights[instance]:Destroy()
					itemHighlights[instance] = nil
				end
				if itemNameTags[instance] then
					itemNameTags[instance]:Destroy()
					itemNameTags[instance] = nil
				end
			end
		end)
		table.insert(itemConnections, removedConn)
	end

	local function cleanupItemESP()
		itemESPActive = false
		clearItemESP()
		for _, conn in ipairs(itemConnections) do conn:Disconnect() end
		itemConnections = {}
	end

	pillItemESP.MouseButton1Click:Connect(function()
		local v = not getItemESP()
		setItemESP(v)
		itemESPActive = v
		if v then
			applyItemESP()
			setupItemConnections()
			showNotification("Item ESP enabled")
		else
			cleanupItemESP()
			showNotification("Item ESP disabled")
		end
	end)

	-- Weapon Markers
	makeSectionLabel(espPage, "Weapon Markers", 7)

	local pillWeaponMarkers, setWeaponMarkers, getWeaponMarkers = makeToggleRow(espPage, "Show AK-47 & Shotgun", 8)

	local weaponMarkersActive = false
	local weaponMarkers = {}

	local WEAPON_DATA = {
		{pos = Vector3.new(-931.792847, 91.2783127, 2039.25549), name = "AK-47", color = Color3.fromRGB(255, 50, 50)},
		{pos = Vector3.new(-938.992737, 91.2782822, 2039.25537), name = "Shotgun", color = Color3.fromRGB(255, 150, 50)}
	}

	local function clearWeaponMarkers()
		for _, obj in ipairs(weaponMarkers) do if obj and obj.Parent then obj:Destroy() end end
		weaponMarkers = {}
	end

	local function createWeaponMarkers()
		clearWeaponMarkers()
		if not weaponMarkersActive then return end
		for _, wpn in ipairs(WEAPON_DATA) do
			local sphere = Instance.new("Part")
			sphere.Size = Vector3.new(3, 3, 3)
			sphere.Position = wpn.pos + Vector3.new(0, 1.5, 0)
			sphere.Anchored = true
			sphere.CanCollide = false
			sphere.Transparency = 0.4
			sphere.Material = Enum.Material.Neon
			sphere.Color = wpn.color
			sphere.Shape = Enum.PartType.Ball
			sphere.Parent = workspace
			table.insert(weaponMarkers, sphere)
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0, 200, 0, 50)
			bb.AlwaysOnTop = true
			bb.Adornee = sphere
			bb.Parent = sphere
			table.insert(weaponMarkers, bb)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = wpn.name .. "\nHERE"
			lbl.TextColor3 = wpn.color
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 16
			lbl.TextStrokeTransparency = 0.2
			lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
			lbl.Parent = bb
			table.insert(weaponMarkers, lbl)
		end
	end

	pillWeaponMarkers.MouseButton1Click:Connect(function()
		local v = not getWeaponMarkers()
		setWeaponMarkers(v)
		weaponMarkersActive = v
		if v then
			createWeaponMarkers()
			showNotification("Weapon markers created")
		else
			clearWeaponMarkers()
			showNotification("Weapon markers removed")
		end
	end)

	HHBFuncs.cleanupWeaponMarkers = function()
		weaponMarkersActive = false
		clearWeaponMarkers()
	end
end

-------------|| MOVEMENT PAGE ||----------------
local movPage = newPage("Movement")
do
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = movPage
	stylePadding(movPage, 0,8,0,4)

	makeSectionLabel(movPage, "Speed", 1)
	
	local currentWalkSpeed = 16
	local currentJumpPower = 50
	
	makeSliderRow(movPage, "Walk Speed", 4, 150, 16, function(v)
		currentWalkSpeed = v
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = v end
	end, 2)
	
	makeSliderRow(movPage, "Jump Power", 10, 200, 50, function(v)
		currentJumpPower = v
		local hum = getHumanoid()
		if hum then hum.JumpPower = v end
	end, 3)
	
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = currentWalkSpeed
			hum.JumpPower = currentJumpPower
		end
	end)

	makeSectionLabel(movPage, "Anti-Jump Bypass", 4)
	
	local pillBypassJump, setBypassJump, getBypassJump = makeToggleRow(movPage, "Bypass Anti-Jump", 5)
	
	local bypassJumpActive = false
	
	local function toggleBypassJump()
		bypassJumpActive = not bypassJumpActive
		local char = player.Character
		if bypassJumpActive then
			if char then
				local antiJump = char:FindFirstChild("AntiJump")
				if antiJump then
					antiJump.Disabled = true
					showNotification("Anti-Jump bypassed")
				else
					showNotification("Anti-Jump not found", "warning")
					bypassJumpActive = false
					setBypassJump(false)
				end
			end
		else
			if char then
				local antiJump = char:FindFirstChild("AntiJump")
				if antiJump then
					antiJump.Disabled = false
					showNotification("Anti-Jump restored")
				end
			end
		end
	end
	
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if bypassJumpActive then
			local antiJump = char:FindFirstChild("AntiJump")
			if antiJump then antiJump.Disabled = true end
		end
	end)
	
	pillBypassJump.MouseButton1Click:Connect(function()
		local v = not getBypassJump()
		setBypassJump(v)
		toggleBypassJump()
	end)
	
	makeInfoCard(movPage, "Bypasses the anti-jump system, allowing unlimited jumping", 6)
end

-------------|| SETTINGS PAGE ||----------------
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
	themeCurLbl.Text = "Current theme:  "..currentThemeName
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
	exclusiveLbl.Text = "Exclusive themes"
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
		{ name="Cat",       col=Color3.fromRGB(30,30,30),       row=swatchRow2 },
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
			themeCurLbl.Text = "Current theme:  "..def.name
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
end

-------------|| TOGGLE BUTTON ||----------------
local function openGui()
    panel.Visible = true
    panel.BackgroundTransparency = PANEL_TRANSPARENCY
end

local function closeGui()
    panel.Visible = false
end

toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "HHBToggle"
toggleBtn.Size = UDim2.new(0,62,0,62)
toggleBtn.Position = UDim2.new(1,-80,1,-90)
toggleBtn.BackgroundColor3 = T().bg
toggleBtn.BackgroundTransparency = 0.5
toggleBtn.AutoButtonColor = true
toggleBtn.Image = ICON_ID
toggleBtn.ImageColor3 = T().accent
toggleBtn.ScaleType = Enum.ScaleType.Fit
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui
styleCorner(toggleBtn, UDim.new(0,14))
styleStroke(toggleBtn, 0.85)
table.insert(reg.panels, toggleBtn)

local draggingT, wasDragged, dragInputT, dragStartT, startPosT = false, false, nil, nil, nil
local DRAG_THRESHOLD = 12
toggleBtn.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingT = true; wasDragged = false
		dragStartT = inp.Position; startPosT = toggleBtn.AbsolutePosition; dragInputT = inp
	end
end)
UserInputService.InputChanged:Connect(function(inp)
	if not draggingT then return end
	if inp ~= dragInputT and inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
	if dragStartT then
		local delta = inp.Position - dragStartT
		if delta.Magnitude >= DRAG_THRESHOLD then wasDragged = true end
		local vp = workspace.CurrentCamera.ViewportSize
		local bw, bh = toggleBtn.AbsoluteSize.X, toggleBtn.AbsoluteSize.Y
		toggleBtn.Position = UDim2.new(0,
			math.clamp(startPosT.X + delta.X, 0, vp.X - bw), 0,
			math.clamp(startPosT.Y + delta.Y, 0, vp.Y - bh))
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp == dragInputT then draggingT = false; dragInputT = nil end
end)
toggleBtn.MouseButton1Click:Connect(function()
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
