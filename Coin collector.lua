-- ============================================================
-- COIN COLLECTOR - HAPPY HUB DESIGN v2
-- Diseño premium con sistema de temas Happy Hub
-- ============================================================
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ============================================================
-- INTEGRACIÓN CON HAPPY HUB (temas, estilos)
-- ============================================================
local HHB = PlayerGui:FindFirstChild("HappyHub")
local useHappyHubTheme = false
local HHB_CONNECTED = false

if HHB then
	local success, result = pcall(function()
		return HHB:FindFirstChild("MainPanel")
	end)
	if success and result then
		useHappyHubTheme = true
		HHB_CONNECTED = true
	end
end

-- Sistema de temas propio (fallback si no hay Happy Hub)
local THEMES = {
	Dark = {
		accent  = Color3.fromRGB(0, 180, 255),
		bg      = Color3.fromRGB(10, 10, 10),
		text    = Color3.fromRGB(255, 255, 255),
		subtext = Color3.fromRGB(150, 150, 150),
		danger  = Color3.fromRGB(220, 60, 60),
		knobOff = Color3.fromRGB(50, 50, 50),
	},
	Purple = {
		accent  = Color3.fromRGB(160, 80, 255),
		bg      = Color3.fromRGB(12, 8, 20),
		text    = Color3.fromRGB(240, 228, 255),
		subtext = Color3.fromRGB(160, 140, 200),
		danger  = Color3.fromRGB(220, 60, 60),
		knobOff = Color3.fromRGB(55, 35, 80),
	},
	Blue = {
		accent  = Color3.fromRGB(40, 160, 255),
		bg      = Color3.fromRGB(6, 12, 22),
		text    = Color3.fromRGB(215, 232, 255),
		subtext = Color3.fromRGB(120, 160, 210),
		danger  = Color3.fromRGB(220, 60, 60),
		knobOff = Color3.fromRGB(25, 45, 80),
	},
}

local currentTheme = "Dark"
local function T() return THEMES[currentTheme] end
local twI = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ============================================================
-- ESTILOS (mismos que Happy Hub)
-- ============================================================
local function styleCorner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 10)
	c.Parent = obj
end

local function styleStroke(obj, t, color, thick)
	local s = Instance.new("UIStroke")
	s.Color = color or T().text
	s.Thickness = thick or 1
	s.Transparency = t or 0.78
	s.Parent = obj
	return s
end

local function stylePadding(obj, top, bot, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bot or 0)
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.Parent = obj
end

-- ============================================================
-- CONFIGURACIÓN
-- ============================================================
local DEFAULT_SPEED = 50
local MIN_SPEED = 10
local MAX_SPEED = 200
local DEFAULT_PICKUP_DELAY = 0.8
local MIN_PICKUP_DELAY = 0.1
local MAX_PICKUP_DELAY = 3
local DEFAULT_PICKUP_RADIUS = 3
local MIN_PICKUP_RADIUS = 1
local MAX_PICKUP_RADIUS = 10
local EVADE_DISTANCE = 25
local EVADE_SAFE_DISTANCE = 35

-- MAPAS DE MM2
local Maps_mm2 = {
	"ResearchFacility", "House2", "Mansion2", "Hotel",
	"MilBase", "Bank2", "BioLab", "Factory",
	"Workplace", "PoliceStation", "Office3", "Hospital3",
	"Town", "Town2", "Mansion", "House",
}

-- ============================================================
-- VARIABLES DE ESTADO
-- ============================================================
local isCollecting = false
local collectSpeed = DEFAULT_SPEED
local pickupDelay = DEFAULT_PICKUP_DELAY
local pickupRadius = DEFAULT_PICKUP_RADIUS
local coinConnection = nil
local flyBodyVelocity = nil
local flyBodyGyro = nil
local currentState = "Apagado"
local isMinimized = false
local coinsCollected = 0

-- Remote event de MM2 para recolectar monedas
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoinCollectedEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("CoinCollected")

-- ============================================================
-- CREACIÓN DE GUI - ESTILO HAPPY HUB V10
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoinCollectorHH"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 998
screenGui.Parent = PlayerGui

-- Panel principal (rediseñado)
local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 350, 0, 280)
panel.Position = UDim2.new(1, -370, 0.76, 0)
panel.BackgroundColor3 = T().bg
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = screenGui
styleCorner(panel, UDim.new(0, 14))
styleStroke(panel, 0.72)
local PANEL_OPEN_HEIGHT = UDim2.new(0, 350, 0, 280)
local PANEL_CLOSED_HEIGHT = UDim2.new(0, 230, 0, 46)

-- Sombra
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, 10)
shadow.BackgroundColor3 = Color3.new(0, 0, 0)
shadow.BackgroundTransparency = 0.55
shadow.BorderSizePixel = 0
shadow.ZIndex = panel.ZIndex - 1
shadow.Parent = panel
styleCorner(shadow, UDim.new(0, 18))

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = T().bg
header.BackgroundTransparency = 0.05
header.BorderSizePixel = 0
header.Parent = panel
styleCorner(header, UDim.new(0, 14))
styleStroke(header, 0.78)

local headerPatch = Instance.new("Frame")
headerPatch.Size = UDim2.new(1, 0, 0, 12)
headerPatch.Position = UDim2.new(0, 0, 1, -12)
headerPatch.BackgroundColor3 = T().bg
headerPatch.BackgroundTransparency = 0.02
headerPatch.BorderSizePixel = 0
headerPatch.Parent = header

-- Línea separadora
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -20, 0, 1)
headerLine.Position = UDim2.new(0, 10, 1, 0)
headerLine.BackgroundColor3 = T().accent
headerLine.BackgroundTransparency = 0.65
headerLine.BorderSizePixel = 0
headerLine.Parent = header

-- Icono moneda (ImageLabel con assetID para mejor calidad)
local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 28, 0, 28)
icon.Position = UDim2.new(0, 12, 0.5, -14)
icon.BackgroundTransparency = 1
icon.Text = "🪙"
icon.TextColor3 = Color3.fromRGB(255, 215, 0)
icon.Font = Enum.Font.GothamBold
icon.TextSize = 20
icon.Parent = header

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 140, 0, 22)
titleLabel.Position = UDim2.new(0, 46, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Coin Collector"
titleLabel.TextColor3 = T().text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Subtítulo / estado
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 140, 0, 16)
statusLabel.Position = UDim2.new(0, 46, 0, 26)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 Estado: Apagado"
statusLabel.TextColor3 = T().subtext
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = header

-- Botón minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(1, -62, 0.5, -13)
minimizeBtn.BackgroundTransparency = 0.12
minimizeBtn.BackgroundColor3 = T().bg
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = T().text
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.BorderSizePixel = 0
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = header
styleCorner(minimizeBtn, UDim.new(0, 8))

-- INTERRUPTOR (Toggle Switch estilo Happy Hub)
local toggleFrame = Instance.new("Frame")
toggleFrame.Size = UDim2.new(0, 48, 0, 26)
toggleFrame.Position = UDim2.new(1, -38, 0.5, -13)
toggleFrame.BackgroundColor3 = T().knobOff
toggleFrame.BorderSizePixel = 0
toggleFrame.Parent = header
styleCorner(toggleFrame, UDim.new(1, 0))

local toggleKnob = Instance.new("Frame")
toggleKnob.Size = UDim2.new(0, 22, 0, 22)
toggleKnob.Position = UDim2.new(0, 2, 0.5, -11)
toggleKnob.BackgroundColor3 = T().text
toggleKnob.BorderSizePixel = 0
toggleKnob.Parent = toggleFrame
styleCorner(toggleKnob, UDim.new(1, 0))

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = ""
toggleBtn.Parent = toggleFrame

-- ============================================================
-- CUERPO DEL PANEL (CONTROLES)
-- ============================================================
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -46)
body.Position = UDim2.new(0, 0, 0, 46)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.Parent = panel

local bodyPadding = Instance.new("UIPadding")
bodyPadding.PaddingTop = UDim.new(0, 8)
bodyPadding.PaddingLeft = UDim.new(0, 12)
bodyPadding.PaddingRight = UDim.new(0, 12)
bodyPadding.Parent = body

-- Layout vertical para los controles
local bodyLayout = Instance.new("UIListLayout")
bodyLayout.Padding = UDim.new(0, 6)
bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
bodyLayout.Parent = body

-- ============================================================
-- FILA: CONTADOR DE MONEDAS
-- ============================================================
local counterRow = Instance.new("Frame")
counterRow.LayoutOrder = 1
counterRow.Size = UDim2.new(1, 0, 0, 36)
counterRow.BackgroundColor3 = T().bg
counterRow.BackgroundTransparency = 0.18
counterRow.BorderSizePixel = 0
counterRow.Parent = body
styleCorner(counterRow, UDim.new(0, 10))
styleStroke(counterRow, 0.88)

local coinIcon = Instance.new("TextLabel")
coinIcon.Size = UDim2.new(0, 32, 0, 32)
coinIcon.Position = UDim2.new(0, 6, 0.5, -16)
coinIcon.BackgroundTransparency = 1
coinIcon.Text = "🪙"
coinIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
coinIcon.Font = Enum.Font.GothamBold
coinIcon.TextSize = 20
coinIcon.Parent = counterRow

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -90, 0, 20)
counterLabel.Position = UDim2.new(0, 42, 0, 2)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "Monedas recolectadas"
counterLabel.TextColor3 = T().subtext
counterLabel.Font = Enum.Font.Gotham
counterLabel.TextSize = 11
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.Parent = counterRow

local coinCountLabel = Instance.new("TextLabel")
coinCountLabel.Size = UDim2.new(0, 50, 0, 20)
coinCountLabel.Position = UDim2.new(1, -54, 0, 2)
coinCountLabel.BackgroundTransparency = 1
coinCountLabel.Text = "0"
coinCountLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinCountLabel.Font = Enum.Font.GothamBold
coinCountLabel.TextSize = 16
coinCountLabel.TextXAlignment = Enum.TextXAlignment.Right
coinCountLabel.Parent = counterRow

local coinRateLabel = Instance.new("TextLabel")
coinRateLabel.Size = UDim2.new(1, -90, 0, 14)
coinRateLabel.Position = UDim2.new(0, 42, 0, 20)
coinRateLabel.BackgroundTransparency = 1
coinRateLabel.Text = "Esperando..."
coinRateLabel.TextColor3 = T().subtext
coinRateLabel.Font = Enum.Font.Gotham
coinRateLabel.TextSize = 10
coinRateLabel.TextXAlignment = Enum.TextXAlignment.Left
coinRateLabel.Parent = counterRow

-- ============================================================
-- FILA: VELOCIDAD (Slider estilo Happy Hub)
-- ============================================================
local speedRow = Instance.new("Frame")
speedRow.LayoutOrder = 2
speedRow.Size = UDim2.new(1, 0, 0, 42)
speedRow.BackgroundColor3 = T().bg
speedRow.BackgroundTransparency = 0.18
speedRow.BorderSizePixel = 0
speedRow.Parent = body
styleCorner(speedRow, UDim.new(0, 10))
styleStroke(speedRow, 0.88)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -60, 0, 18)
speedLabel.Position = UDim2.new(0, 10, 0, 4)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Velocidad"
speedLabel.TextColor3 = T().text
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.GothamSemibold
speedLabel.Parent = speedRow

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Size = UDim2.new(0, 50, 0, 18)
speedValueLabel.Position = UDim2.new(1, -60, 0, 4)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.Text = tostring(DEFAULT_SPEED)
speedValueLabel.TextColor3 = T().accent
speedValueLabel.TextXAlignment = Enum.TextXAlignment.Right
speedValueLabel.TextSize = 12
speedValueLabel.Font = Enum.Font.GothamBold
speedValueLabel.Parent = speedRow

local speedTrack = Instance.new("Frame")
speedTrack.Size = UDim2.new(1, -20, 0, 6)
speedTrack.Position = UDim2.new(0, 10, 0, 28)
speedTrack.BackgroundColor3 = T().knobOff
speedTrack.BorderSizePixel = 0
speedTrack.Parent = speedRow
styleCorner(speedTrack, UDim.new(1, 0))

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new((DEFAULT_SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1, 0)
speedFill.BackgroundColor3 = T().accent
speedFill.BorderSizePixel = 0
speedFill.Parent = speedTrack
styleCorner(speedFill, UDim.new(1, 0))

local speedHandle = Instance.new("TextButton")
speedHandle.Size = UDim2.new(0, 18, 0, 18)
speedHandle.AnchorPoint = Vector2.new(0.5, 0.5)
speedHandle.Position = UDim2.new((DEFAULT_SPEED - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 0.5, 0)
speedHandle.BackgroundColor3 = T().text
speedHandle.Text = ""
speedHandle.BorderSizePixel = 0
speedHandle.AutoButtonColor = false
speedHandle.Parent = speedTrack
styleCorner(speedHandle, UDim.new(1, 0))

-- ============================================================
-- FILA: RADIO DE RECOLECCIÓN (Slider)
-- ============================================================
local radiusRow = Instance.new("Frame")
radiusRow.LayoutOrder = 3
radiusRow.Size = UDim2.new(1, 0, 0, 42)
radiusRow.BackgroundColor3 = T().bg
radiusRow.BackgroundTransparency = 0.18
radiusRow.BorderSizePixel = 0
radiusRow.Parent = body
styleCorner(radiusRow, UDim.new(0, 10))
styleStroke(radiusRow, 0.88)

local radiusLabel = Instance.new("TextLabel")
radiusLabel.Size = UDim2.new(1, -60, 0, 18)
radiusLabel.Position = UDim2.new(0, 10, 0, 4)
radiusLabel.BackgroundTransparency = 1
radiusLabel.Text = "Radio de agarre"
radiusLabel.TextColor3 = T().text
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left
radiusLabel.TextSize = 12
radiusLabel.Font = Enum.Font.GothamSemibold
radiusLabel.Parent = radiusRow

local radiusValueLabel = Instance.new("TextLabel")
radiusValueLabel.Size = UDim2.new(0, 50, 0, 18)
radiusValueLabel.Position = UDim2.new(1, -60, 0, 4)
radiusValueLabel.BackgroundTransparency = 1
radiusValueLabel.Text = tostring(DEFAULT_PICKUP_RADIUS)
radiusValueLabel.TextColor3 = T().accent
radiusValueLabel.TextXAlignment = Enum.TextXAlignment.Right
radiusValueLabel.TextSize = 12
radiusValueLabel.Font = Enum.Font.GothamBold
radiusValueLabel.Parent = radiusRow

local radiusTrack = Instance.new("Frame")
radiusTrack.Size = UDim2.new(1, -20, 0, 6)
radiusTrack.Position = UDim2.new(0, 10, 0, 28)
radiusTrack.BackgroundColor3 = T().knobOff
radiusTrack.BorderSizePixel = 0
radiusTrack.Parent = radiusRow
styleCorner(radiusTrack, UDim.new(1, 0))

local radiusFill = Instance.new("Frame")
radiusFill.Size = UDim2.new((DEFAULT_PICKUP_RADIUS - MIN_PICKUP_RADIUS) / (MAX_PICKUP_RADIUS - MIN_PICKUP_RADIUS), 0, 1, 0)
radiusFill.BackgroundColor3 = T().accent
radiusFill.BorderSizePixel = 0
radiusFill.Parent = radiusTrack
styleCorner(radiusFill, UDim.new(1, 0))

local radiusHandle = Instance.new("TextButton")
radiusHandle.Size = UDim2.new(0, 18, 0, 18)
radiusHandle.AnchorPoint = Vector2.new(0.5, 0.5)
radiusHandle.Position = UDim2.new((DEFAULT_PICKUP_RADIUS - MIN_PICKUP_RADIUS) / (MAX_PICKUP_RADIUS - MIN_PICKUP_RADIUS), 0, 0.5, 0)
radiusHandle.BackgroundColor3 = T().text
radiusHandle.Text = ""
radiusHandle.BorderSizePixel = 0
radiusHandle.AutoButtonColor = false
radiusHandle.Parent = radiusTrack
styleCorner(radiusHandle, UDim.new(1, 0))

-- ============================================================
-- FILA: DEMORA (Slider)
-- ============================================================
local delayRow = Instance.new("Frame")
delayRow.LayoutOrder = 4
delayRow.Size = UDim2.new(1, 0, 0, 42)
delayRow.BackgroundColor3 = T().bg
delayRow.BackgroundTransparency = 0.18
delayRow.BorderSizePixel = 0
delayRow.Parent = body
styleCorner(delayRow, UDim.new(0, 10))
styleStroke(delayRow, 0.88)

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, -60, 0, 18)
delayLabel.Position = UDim2.new(0, 10, 0, 4)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Demora al agarrar"
delayLabel.TextColor3 = T().text
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.TextSize = 12
delayLabel.Font = Enum.Font.GothamSemibold
delayLabel.Parent = delayRow

local delayValueLabel = Instance.new("TextLabel")
delayValueLabel.Size = UDim2.new(0, 50, 0, 18)
delayValueLabel.Position = UDim2.new(1, -60, 0, 4)
delayValueLabel.BackgroundTransparency = 1
delayValueLabel.Text = string.format("%.1f", DEFAULT_PICKUP_DELAY) .. "s"
delayValueLabel.TextColor3 = T().accent
delayValueLabel.TextXAlignment = Enum.TextXAlignment.Right
delayValueLabel.TextSize = 12
delayValueLabel.Font = Enum.Font.GothamBold
delayValueLabel.Parent = delayRow

local delayTrack = Instance.new("Frame")
delayTrack.Size = UDim2.new(1, -20, 0, 6)
delayTrack.Position = UDim2.new(0, 10, 0, 28)
delayTrack.BackgroundColor3 = T().knobOff
delayTrack.BorderSizePixel = 0
delayTrack.Parent = delayRow
styleCorner(delayTrack, UDim.new(1, 0))

local delayFill = Instance.new("Frame")
delayFill.Size = UDim2.new((DEFAULT_PICKUP_DELAY - MIN_PICKUP_DELAY) / (MAX_PICKUP_DELAY - MIN_PICKUP_DELAY), 0, 1, 0)
delayFill.BackgroundColor3 = T().accent
delayFill.BorderSizePixel = 0
delayFill.Parent = delayTrack
styleCorner(delayFill, UDim.new(1, 0))

local delayHandle = Instance.new("TextButton")
delayHandle.Size = UDim2.new(0, 18, 0, 18)
delayHandle.AnchorPoint = Vector2.new(0.5, 0.5)
delayHandle.Position = UDim2.new((DEFAULT_PICKUP_DELAY - MIN_PICKUP_DELAY) / (MAX_PICKUP_DELAY - MIN_PICKUP_DELAY), 0, 0.5, 0)
delayHandle.BackgroundColor3 = T().text
delayHandle.Text = ""
delayHandle.BorderSizePixel = 0
delayHandle.AutoButtonColor = false
delayHandle.Parent = delayTrack
styleCorner(delayHandle, UDim.new(1, 0))

-- ============================================================
-- FILA: AUTO GET GUN (con interceptación GiveWeapon)
-- ============================================================
local gunRow = Instance.new("Frame")
gunRow.LayoutOrder = 5
gunRow.Size = UDim2.new(1, 0, 0, 36)
gunRow.BackgroundColor3 = T().bg
gunRow.BackgroundTransparency = 0.18
gunRow.BorderSizePixel = 0
gunRow.Parent = body
styleCorner(gunRow, UDim.new(0, 10))
styleStroke(gunRow, 0.88)

local gunIcon = Instance.new("TextLabel")
gunIcon.Size = UDim2.new(0, 32, 0, 32)
gunIcon.Position = UDim2.new(0, 6, 0.5, -16)
gunIcon.BackgroundTransparency = 1
gunIcon.Text = "🔫"
gunIcon.TextColor3 = T().accent
gunIcon.Font = Enum.Font.GothamBold
gunIcon.TextSize = 18
gunIcon.Parent = gunRow

local gunLabel = Instance.new("TextLabel")
gunLabel.Size = UDim2.new(1, -80, 0, 20)
gunLabel.Position = UDim2.new(0, 42, 0, 2)
gunLabel.BackgroundTransparency = 1
gunLabel.Text = "Auto Get Gun"
gunLabel.TextColor3 = T().text
gunLabel.Font = Enum.Font.GothamSemibold
gunLabel.TextSize = 12
gunLabel.TextXAlignment = Enum.TextXAlignment.Left
gunLabel.Parent = gunRow

local gunStatus = Instance.new("TextLabel")
gunStatus.Size = UDim2.new(1, -80, 0, 14)
gunStatus.Position = UDim2.new(0, 42, 0, 20)
gunStatus.BackgroundTransparency = 1
gunStatus.Text = "Listo"
gunStatus.TextColor3 = T().subtext
gunStatus.Font = Enum.Font.Gotham
gunStatus.TextSize = 10
gunStatus.TextXAlignment = Enum.TextXAlignment.Left
gunStatus.Parent = gunRow

local gunBtn = Instance.new("TextButton")
gunBtn.Size = UDim2.new(0, 62, 0, 28)
gunBtn.Position = UDim2.new(1, -68, 0.5, -14)
gunBtn.BackgroundColor3 = T().accent
gunBtn.BackgroundTransparency = 0.1
gunBtn.Text = "Obtener"
gunBtn.TextColor3 = T().text
gunBtn.Font = Enum.Font.GothamBold
gunBtn.TextSize = 11
gunBtn.BorderSizePixel = 0
gunBtn.AutoButtonColor = false
gunBtn.Parent = gunRow
styleCorner(gunBtn, UDim.new(0, 8))

-- Interceptación GiveWeapon
local function setupGiveWeaponHook()
	local Event = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	if Event then Event = Event:FindFirstChild("Gameplay") end
	if Event then Event = Event:FindFirstChild("GiveWeapon") end
	if not Event then
		gunStatus.Text = "No GiveWeapon remote"
		return false
	end
	local hooked = false
	for _, Connection in getconnections(Event.OnClientEvent) do
		local old = hookfunction(Connection.Function, function(...)
			local args = {...}
			local weaponName = tostring(args[1] or "?")
			gunStatus.Text = "Armado: " .. weaponName
			task.delay(3, function()
				if gunStatus and gunStatus.Parent then gunStatus.Text = "Listo" end
			end)
			if old then return old(...) end
		end)
		hooked = true
	end
	return hooked
end

local function findGunDrop()
	for _, map in ipairs(workspace:GetChildren()) do
		if map:IsA("Model") and (map.Name:find("Map") or map.Name:find("map")) then
			local gunDrop = map:FindFirstChild("GunDrop", true)
			if gunDrop and gunDrop:IsA("BasePart") then return gunDrop.CFrame end
		end
	end
	local gunDrop = workspace:FindFirstChild("GunDrop", true)
	if gunDrop and gunDrop:IsA("BasePart") then return gunDrop.CFrame end
	return nil
end

local gunHooked = false
gunBtn.MouseButton1Click:Connect(function()
	if gunHooked then
		gunStatus.Text = "Ya interceptado"
		return
	end

	local gunCF = findGunDrop()
	if not gunCF then
		gunStatus.Text = "No GunDrop en el mapa"
		return
	end

	local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		gunStatus.Text = "Sin personaje"
		return
	end

	-- TP al GunDrop y volver
	gunStatus.Text = "Yendo al arma..."
	local origCF = hrp.CFrame
	hrp.CFrame = gunCF + Vector3.new(0, 5, 0)
	task.wait(0.6)
	hrp.CFrame = origCF

	-- Interceptar GiveWeapon
	if setupGiveWeaponHook() then
		gunHooked = true
		gunStatus.Text = "Hook activo"
		gunBtn.Text = "Hecho"
		gunBtn.BackgroundColor3 = T().knobOff
	else
		gunStatus.Text = "No se pudo interceptar"
	end
end)

-- ============================================================
-- FUNCIONALIDAD: SLIDERS
-- ============================================================
local function makeSlider(trackObj, handleObj, fillObj, minV, maxV, defV, displayFn, onChange)
	local cur = defV
	local sliding = false
	local activeInput = nil

	local function updateFromX(absX)
		local tp, ts = trackObj.AbsolutePosition.X, trackObj.AbsoluteSize.X
		if ts == 0 then return end
		local ratio = math.clamp((absX - tp) / ts, 0, 1)
		local nv = minV + ratio * (maxV - minV)
		nv = math.floor(nv * 10 + 0.5) / 10
		nv = math.clamp(nv, minV, maxV)
		if nv == cur then return end
		cur = nv
		fillObj.Size = UDim2.new(ratio, 0, 1, 0)
		handleObj.Position = UDim2.new(ratio, 0, 0.5, 0)
		if displayFn then displayFn(cur) end
		if onChange then onChange(cur) end
	end

	handleObj.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			activeInput = inp
		end
	end)

	trackObj.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			activeInput = inp
			updateFromX(inp.Position.X)
		end
	end)

	local changeConn = UserInputService.InputChanged:Connect(function(inp)
		if not sliding then return end
		if inp.UserInputType == Enum.UserInputType.Touch then
			if activeInput and inp.Touch == activeInput.Touch then updateFromX(inp.Position.X) end
		elseif inp.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromX(inp.Position.X)
		end
	end)

	local endConn = UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
			activeInput = nil
		end
	end)

	return {
		getValue = function() return cur end,
		setValue = function(v)
			v = math.clamp(v, minV, maxV)
			cur = v
			local ratio = (v - minV) / (maxV - minV)
			fillObj.Size = UDim2.new(ratio, 0, 1, 0)
			handleObj.Position = UDim2.new(ratio, 0, 0.5, 0)
			if displayFn then displayFn(v) end
		end,
		disconnect = function()
			changeConn:Disconnect()
			endConn:Disconnect()
		end
	}
end

local speedSlider = makeSlider(speedTrack, speedHandle, speedFill, MIN_SPEED, MAX_SPEED, DEFAULT_SPEED,
	function(v) speedValueLabel.Text = tostring(v); collectSpeed = v end,
	function(v) collectSpeed = v end
)

local radiusSlider = makeSlider(radiusTrack, radiusHandle, radiusFill, MIN_PICKUP_RADIUS, MAX_PICKUP_RADIUS, DEFAULT_PICKUP_RADIUS,
	function(v)
		radiusValueLabel.Text = tostring(v)
		if v >= 5 then radiusValueLabel.TextColor3 = T().accent else radiusValueLabel.TextColor3 = T().accent end
		pickupRadius = v
	end,
	function(v) pickupRadius = v end
)

local delaySlider = makeSlider(delayTrack, delayHandle, delayFill, MIN_PICKUP_DELAY, MAX_PICKUP_DELAY, DEFAULT_PICKUP_DELAY,
	function(v) delayValueLabel.Text = string.format("%.1f", v) .. "s"; pickupDelay = v end,
	function(v) pickupDelay = v end
)

-- ============================================================
-- FUNCIONALIDAD: MINIMIZAR
-- ============================================================
local function toggleMinimize()
	isMinimized = not isMinimized
	if isMinimized then
		TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = PANEL_CLOSED_HEIGHT}):Play()
		body.Visible = false
		minimizeBtn.Text = "+"
	else
		TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = PANEL_OPEN_HEIGHT}):Play()
		body.Visible = true
		minimizeBtn.Text = "−"
	end
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

-- ============================================================
-- FUNCIONALIDAD: DRAG (ARRATRE)
-- ============================================================
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
	if dragging and (input == dragInput or (input.UserInputType == Enum.UserInputType.MouseMovement and dragInput)) then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ============================================================
-- FUNCIONALIDAD: INTERRUPTOR (TOGGLE)
-- ============================================================
local function updateToggleUI(state)
	TweenService:Create(toggleFrame, twI, {BackgroundColor3 = state and T().accent or T().knobOff}):Play()
	TweenService:Create(toggleKnob, twI, {Position = state and UDim2.new(0, 24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)}):Play()
end

-- ============================================================
-- FUNCIONES DE DETECCIÓN
-- ============================================================
local function getCoinContainer()
	-- Buscar en mapas conocidos de MM2 y también en el workspace raíz
	for _, mapName in ipairs(Maps_mm2) do
		local map = workspace:FindFirstChild(mapName)
		if map then
			local container = map:FindFirstChild("CoinContainer", true)
			if container then return container end
		end
	end
	-- Búsqueda global en workspace
	local coinContainer = workspace:FindFirstChild("CoinContainer", true)
	if coinContainer then return coinContainer end

	-- Búsqueda en cualquier modelo con nombre que contenga "Map"
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Model") and (child.Name:find("Map") or child.Name:find("map")) then
			local container = child:FindFirstChild("CoinContainer", true)
			if container then return container end
		end
	end
	return nil
end

local function getClosestCoin()
	local coinContainer = getCoinContainer()
	if not coinContainer then return nil end

	local myHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end

	local closest = nil
	local closestDist = math.huge

	for _, child in ipairs(coinContainer:GetChildren()) do
		local part = child:IsA("BasePart") and child or (child:IsA("Model") and child.PrimaryPart)
		if part then
			local dist = (myHRP.Position - part.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closest = part
			end
		end
	end
	return closest
end

local function getMurderer()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= Player then
			local char = plr.Character
			local bp = plr:FindFirstChild("Backpack")
			if char and char:FindFirstChild("Knife") then return plr end
			if bp and bp:FindFirstChild("Knife") then return plr end
		end
	end
	return nil
end

-- ============================================================
-- EVENTO DE RECOLECCIÓN (REMOTE)
-- ============================================================
local coinCollectionConnection = nil
local coinCounterFlash = nil

local function startCoinEventListener()
	if not CoinCollectedEvent then return end
	coinCollectionConnection = CoinCollectedEvent.OnClientEvent:Connect(function()
		if not isCollecting then return end
		coinsCollected = coinsCollected + 1
		coinCountLabel.Text = tostring(coinsCollected)
		coinRateLabel.Text = "🪙 +1 moneda!"

		-- Efecto flash en el contador
		if coinCounterFlash then coinCounterFlash:Cancel() end
		coinCounterFlash = TweenService:Create(coinCountLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 100)}):Play()
		TweenService:Create(coinCountLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 215, 0)}):Play()
	end)
end

-- ============================================================
-- LÓGICA DE RECOLECCIÓN MEJORADA
-- ============================================================
local function startCollecting()
	if isCollecting then return end

	if not getCoinContainer() then
		statusLabel.Text = "Estado: Sin mapa"
		task.delay(2, function()
			if statusLabel and statusLabel.Parent then
				statusLabel.Text = "Estado: Apagado"
			end
		end)
		return
	end

	isCollecting = true
	coinsCollected = 0
	coinCountLabel.Text = "0"
	coinRateLabel.Text = "Buscando monedas..."
	updateToggleUI(true)

	startCoinEventListener()

	local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		stopCollecting()
		return
	end

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	flyBodyVelocity.Parent = hrp

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	flyBodyGyro.P = 1e4
	flyBodyGyro.CFrame = hrp.CFrame
	flyBodyGyro.Parent = hrp

	local waitUntil = 0
	local isWaiting = false

	coinConnection = RunService.Heartbeat:Connect(function()
		local currentHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not currentHRP then
			stopCollecting()
			return
		end

		-- Verificar asesino y evadir
		local murderer = getMurderer()
		local evadeDirection = nil
		if murderer and murderer.Character then
			local murderHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
			if murderHRP then
				local distToMurderer = (currentHRP.Position - murderHRP.Position).Magnitude
				if distToMurderer < EVADE_DISTANCE then
					evadeDirection = (currentHRP.Position - murderHRP.Position).Unit
					statusLabel.Text = "Estado: Evadiendo"
					coinRateLabel.Text = "⚠️ Esquivando asesino!"
				end
			end
		end

		if evadeDirection then
			local evadeSpeed = math.min(collectSpeed * 1.5, MAX_SPEED)
			flyBodyVelocity.Velocity = evadeDirection * evadeSpeed
			flyBodyGyro.CFrame = CFrame.lookAt(currentHRP.Position, currentHRP.Position + evadeDirection)
			isWaiting = false
			return
		end

		-- Buscar moneda más cercana
		local target = getClosestCoin()
		if not target then
			flyBodyVelocity.Velocity = Vector3.zero
			statusLabel.Text = "Estado: Sin monedas"
			coinRateLabel.Text = "✅ Todas recolectadas!"
			stopCollecting()
			return
		end

		local distToTarget = (currentHRP.Position - target.Position).Magnitude

		-- Pausa al llegar a la moneda para asegurar recolección
		if isWaiting then
			if tick() >= waitUntil then
				isWaiting = false
				local newTarget = getClosestCoin()
				if newTarget then
					local dir = (newTarget.Position - currentHRP.Position).Unit
					flyBodyVelocity.Velocity = dir * collectSpeed
					flyBodyGyro.CFrame = CFrame.lookAt(currentHRP.Position, newTarget.Position)
				else
					flyBodyVelocity.Velocity = Vector3.zero
					stopCollecting()
				end
				statusLabel.Text = "Estado: Buscando"
				coinRateLabel.Text = "Volando a la moneda..."
			else
				flyBodyVelocity.Velocity = Vector3.zero
				statusLabel.Text = "Esperando..."
				coinRateLabel.Text = "⏳ " .. string.format("%.1f", waitUntil - tick()) .. "s"
			end
			return
		end

		if distToTarget <= pickupRadius then
			isWaiting = true
			waitUntil = tick() + pickupDelay
			flyBodyVelocity.Velocity = Vector3.zero
			statusLabel.Text = "Estado: Agarrar"
			coinRateLabel.Text = "🪙 Agarrando moneda..."
			return
		end

		-- Volar hacia la moneda
		local direction = (target.Position - currentHRP.Position).Unit
		flyBodyVelocity.Velocity = direction * collectSpeed
		flyBodyGyro.CFrame = CFrame.lookAt(currentHRP.Position, target.Position)
		statusLabel.Text = "Estado: Buscando"
		coinRateLabel.Text = "Volando a la moneda..."
	end)
end

local function stopCollecting()
	if not isCollecting then return end
	isCollecting = false
	statusLabel.Text = "Estado: Apagado"
	coinRateLabel.Text = "Detenido"
	updateToggleUI(false)

	if coinConnection then
		coinConnection:Disconnect()
		coinConnection = nil
	end
	if coinCollectionConnection then
		coinCollectionConnection:Disconnect()
		coinCollectionConnection = nil
	end
	if flyBodyVelocity then
		flyBodyVelocity:Destroy()
		flyBodyVelocity = nil
	end
	if flyBodyGyro then
		flyBodyGyro:Destroy()
		flyBodyGyro = nil
	end
end

-- ============================================================
-- AUTO-START ON ROUND START (y CoinsStarted)
-- ============================================================
local function setupAutoStart()
    local gameplay = ReplicatedStorage:FindFirstChild("Remotes")
    if gameplay then gameplay = gameplay:FindFirstChild("Gameplay") end
    if not gameplay then
        warn("Gameplay folder not found – auto-start disabled")
        return
    end

    local roundStart = gameplay:FindFirstChild("RoundStart")
    local coinsStarted = gameplay:FindFirstChild("CoinsStarted")

    local function tryStart()
        -- Wait a bit for coins to appear and for any pending state to settle
        task.wait(1.5)
        if not isCollecting then
            -- Ensure we have a character and the map is loaded
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                startCollecting()
            else
                -- If character is not ready, wait for it
                local charAdded = Player.CharacterAdded:Connect(function()
                    charAdded:Disconnect()
                    task.wait(0.5)
                    if not isCollecting then
                        startCollecting()
                    end
                end)
                -- timeout after 5 seconds to avoid hanging
                task.delay(5, function()
                    charAdded:Disconnect()
                end)
            end
        end
    end

    if roundStart then
        roundStart.OnClientEvent:Connect(tryStart)
        print("🔄 Auto-start hooked to RoundStart")
    else
        warn("RoundStart remote not found – auto-start will not work")
    end

    if coinsStarted then
        coinsStarted.OnClientEvent:Connect(tryStart)
        print("🔄 Auto-start also hooked to CoinsStarted")
    else
        warn("CoinsStarted remote not found – not used")
    end
end

-- Enable auto-start (you can comment this line out to disable it)
setupAutoStart()

toggleBtn.MouseButton1Click:Connect(function()
	if isCollecting then
		stopCollecting()
	else
		startCollecting()
	end
end)

-- ============================================================
-- LIMPIEZA Y EVENTOS
-- ============================================================
Player.CharacterAdded:Connect(function()
	if isCollecting then stopCollecting() end
end)

screenGui.Destroying:Connect(function()
	stopCollecting()
	if speedSlider then speedSlider.disconnect() end
	if radiusSlider then radiusSlider.disconnect() end
	if delaySlider then delaySlider.disconnect() end
end)

-- ============================================================
-- INICIALIZACIÓN
-- ============================================================
-- Cargar tema desde Happy Hub si está disponible
if HHB_CONNECTED then
	local themeSuccess = pcall(function()
		-- Intentar usar el tema de Happy Hub
		local hTheme = _G and _G.__HHB_currentTheme
		if hTheme and THEMES[hTheme] then
			currentTheme = hTheme
		end
	end)
end

print("🪙 Coin Collector (Happy Hub Design v2) cargado correctamente.")
