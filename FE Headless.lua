local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--============================================================
-- GUI
--============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local btn = Instance.new("TextButton")
btn.Size            = UDim2.fromScale(0.08, 0.055)
btn.Position        = UDim2.fromScale(0.02, 0.03)
btn.Text            = "🎭  Anim: OFF"
btn.TextScaled      = true
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.TextColor3      = Color3.fromRGB(255, 255, 255)
btn.BorderSizePixel = 0
btn.AutoButtonColor = true
btn.Parent          = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = btn

--============================================================
-- STATE
--============================================================
local state = false
local track  = nil

--============================================================
-- HEADLESS HELPER
--============================================================
local HEADLESS_ID = "rbxassetid://134082579"   -- Headless Horseman head mesh

local function applyHeadless(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    -- Hide the visible head mesh/texture
    head.Transparency = 1
    local face = head:FindFirstChild("face")
    if face then face.Transparency = 1 end
    -- Also hide Hair / Hat accessories that sit on the head
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                -- Only hide accessories that are attached to the head attachment
                local att = handle:FindFirstChildOfClass("Attachment")
                if att and att.Name:find("Hat") then
                    handle.Transparency = 1
                end
            end
        end
    end
end

--============================================================
-- ANIMATION LOADER  (re-runs on every respawn)
--============================================================
local ANIM_ID = "rbxassetid://102316572910864"

local function setupCharacter(char)
    -- Reset track ref on respawn
    track = nil

    local hum = char:WaitForChild("Humanoid")
    local animator = hum:WaitForChild("Animator")

    local anim = Instance.new("Animation")
    anim.AnimationId = ANIM_ID

    local newTrack = animator:LoadAnimation(anim)
    newTrack.Priority = Enum.AnimationPriority.Action
    newTrack.Looped   = true   -- FIX: keep playing until toggled off
    track = newTrack

    -- Apply headless
    applyHeadless(char)

    -- Re-sync toggle visual state
    if state then
        track:Play()
        btn.Text             = "🎭  Anim: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        btn.Text             = "🎭  Anim: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end

--============================================================
-- INIT + RESPAWN HANDLING
--============================================================
if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

--============================================================
-- TOGGLE
--============================================================
btn.MouseButton1Click:Connect(function()
    state = not state

    if state then
        btn.Text             = "🎭  Anim: ON"
        btn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
        if track then track:Play() end
    else
        btn.Text             = "🎭  Anim: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        if track then track:Stop() end
    end
end)