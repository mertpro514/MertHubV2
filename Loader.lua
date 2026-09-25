local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Configuration
local TOGGLE_KEY = Enum.KeyCode.RightShift
local BALL_NAME = "Ball"
local DEFAULT_SIZE = 1
local MAX_SIZE = 25
local MIN_SIZE = 0.5
local enabled = false
local currentSize = DEFAULT_SIZE
local guiVisible = true
local trackedBalls = {}

-- BALL CUSTOMIZATION
local ballTransparency = 0.6
local ballColor = Color3.fromRGB(0, 240, 255)

-- TRAJECTORY CONFIG
local trajectoryEnabled = false
local trajColor = Color3.fromRGB(255, 220, 60)
local trajTransparency = 0.2
local trajWidth = 0.18
local trajLength = 40
local trajDt = 0.05

-- BALL ESP
local espEnabled = true
local espColor = Color3.fromRGB(0, 240, 255)

-- BALL PARTICLE
local particleEnabled = false
local particleTexture = "rbxasset://textures/particles/sparkles_main.dds"
local particleColor = Color3.fromRGB(255, 220, 60)
local particleRate = 30
local particleSize = 0.6
local particleSpeed = 3

-- Walkspeed
local DEFAULT_SPEED = 16
local MIN_SPEED = 22
local MAX_SPEED = 32
local currentSpeed = MIN_SPEED
local speedEnabled = false

-- Colors
local THEME_BG = Color3.fromRGB(15, 15, 22)
local THEME_SURFACE = Color3.fromRGB(24, 24, 35)
local ACCENT_CYAN = Color3.fromRGB(0, 240, 255)
local ACCENT_RED = Color3.fromRGB(255, 60, 90)
local ACCENT_GREEN = Color3.fromRGB(0, 230, 120)
local ACCENT_DISCORD = Color3.fromRGB(88, 101, 242)
local ACCENT_ORANGE = Color3.fromRGB(255, 160, 40)
local ACCENT_YELLOW = Color3.fromRGB(255, 220, 60)
local ACCENT_PURPLE = Color3.fromRGB(180, 90, 255)
local TEXT_PRIMARY = Color3.fromRGB(240, 240, 255)
local TEXT_SECONDARY = Color3.fromRGB(140, 140, 170)

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxExpanderPro"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 650)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -325)
mainFrame.BackgroundColor3 = THEME_BG
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = ACCENT_CYAN
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = THEME_SURFACE
title.Text = "⚡ HITBOX EXPANDER"
title.TextColor3 = TEXT_PRIMARY
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Hitbox Toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 42)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 35)
toggleBtn.Text = "HITBOX: DISABLED"
toggleBtn.TextColor3 = ACCENT_RED
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = ACCENT_RED
toggleStroke.Thickness = 1.5
toggleStroke.Parent = toggleBtn

-- =============================================
-- SCROLLING FRAME
-- =============================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -110)
Scroll.Position = UDim2.new(0, 5, 0, 100)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.ScrollBarImageColor3 = ACCENT_CYAN
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1400)
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent = mainFrame

-- =============================================
-- HELPER: SLIDER
-- =============================================
local function createSlider(parent, labelText, yPos, minVal, maxVal, default, callback, isFloat, color)
    color = color or ACCENT_CYAN
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 15)
    Label.Position = UDim2.new(0, 10, 0, yPos)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. default
    Label.TextColor3 = TEXT_SECONDARY
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3
    Label.Parent = parent

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 12)
    Bar.Position = UDim2.new(0, 10, 0, yPos + 16)
    Bar.BackgroundColor3 = THEME_SURFACE
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 3
    Bar.Parent = parent
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(math.clamp((default - minVal) / (maxVal - minVal), 0, 1), 0, 1, 0)
    Fill.BackgroundColor3 = color
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 4
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(math.clamp((default - minVal) / (maxVal - minVal), 0, 1), -8, 0.5, -8)
    Knob.BackgroundColor3 = TEXT_PRIMARY
    Knob.ZIndex = 5
    Knob.Parent = Bar
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    local kStroke = Instance.new("UIStroke")
    kStroke.Color = color
    kStroke.Thickness = 2
    kStroke.Parent = Knob

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 6
    Btn.Parent = Bar

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = minVal + rel * (maxVal - minVal)
        if not isFloat then val = math.floor(val) else val = math.floor(val * 100) / 100 end
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -8, 0.5, -8)
        Label.Text = labelText .. ": " .. val
        callback(val)
    end
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { Bar = Bar, Fill = Fill, Knob = Knob, Label = Label }
end

-- =============================================
-- HELPER: TOGGLE BUTTON
-- =============================================
local function createToggle(parent, text, yPos, activeColor, callback)
    activeColor = activeColor or ACCENT_GREEN
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = activeColor
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = activeColor
    stroke.Thickness = 1.5
    stroke.Transparency = 0.4
    stroke.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 45, 30)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
            btn.Text = text .. ": ON"
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 30, 35)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            btn.Text = text .. ": OFF"
        end
        callback(state)
    end)
    return btn
end

-- =============================================
-- HELPER: SECTION HEADER
-- =============================================
local function createSection(parent, text, yPos, color)
    color = color or ACCENT_CYAN
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundColor3 = THEME_SURFACE
    lbl.BorderSizePixel = 0
    lbl.Text = "  " .. text
    lbl.TextColor3 = color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = parent
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 5)
end

-- =============================================
-- HELPER: COLOR SWATCHES
-- =============================================
local function createColorSwatches(parent, yPos, defaultColor, callback, size)
    size = size or 24
    local presets = {
        Color3.fromRGB(0, 240, 255),
        Color3.fromRGB(255, 60, 90),
        Color3.fromRGB(0, 230, 120),
        Color3.fromRGB(255, 160, 40),
        Color3.fromRGB(180, 90, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 240, 0),
        Color3.fromRGB(255, 100, 200),
    }
    local strokes = {}
    local spacing = size + 4
    for i, c in ipairs(presets) do
        local sw = Instance.new("TextButton")
        sw.Size = UDim2.new(0, size, 0, size)
        sw.Position = UDim2.new(0, 10 + (i-1) * spacing, 0, yPos)
        sw.BackgroundColor3 = c
        sw.Text = ""
        sw.AutoButtonColor = false
        sw.BorderSizePixel = 0
        sw.ZIndex = 3
        sw.Parent = parent
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(255, 255, 255)
        s.Thickness = 2
        s.Transparency = (c == defaultColor) and 0 or 0.85
        s.Parent = sw
        strokes[i] = s
        sw.MouseButton1Click:Connect(function()
            for _, st in pairs(strokes) do st.Transparency = 0.85 end
            s.Transparency = 0
            callback(c)
        end)
    end
end

-- =============================================
-- MENU İÇERİĞİ
-- =============================================
local y = 5

-- === HITBOX ===
createSection(Scroll, "HITBOX", y, ACCENT_CYAN)
y = y + 26

createSlider(Scroll, "Multiplier", y, MIN_SIZE, MAX_SIZE, currentSize, function(v) currentSize = v end)
y = y + 45
createSlider(Scroll, "Transparency", y, 0, 1, ballTransparency, function(v) ballTransparency = v end, true)
y = y + 45
local ballColorLbl = Instance.new("TextLabel")
ballColorLbl.Size = UDim2.new(1, -20, 0, 15)
ballColorLbl.Position = UDim2.new(0, 10, 0, y)
ballColorLbl.BackgroundTransparency = 1
ballColorLbl.Text = "Color"
ballColorLbl.TextColor3 = TEXT_SECONDARY
ballColorLbl.TextSize = 11
ballColorLbl.Font = Enum.Font.GothamBold
ballColorLbl.TextXAlignment = Enum.TextXAlignment.Left
ballColorLbl.ZIndex = 3
ballColorLbl.Parent = Scroll
y = y + 18
createColorSwatches(Scroll, y, ballColor, function(c) ballColor = c end)
y = y + 32

-- === TRAJECTORY ===
createSection(Scroll, "TRAJECTORY", y, ACCENT_YELLOW)
y = y + 26

local trajBtn = createToggle(Scroll, "Trajectory", y, ACCENT_YELLOW, function(state)
    trajectoryEnabled = state
    if not state then hideAllTrajectories() end
end)
y = y + 40

-- Traj color label + swatches
local trajColorLbl = Instance.new("TextLabel")
trajColorLbl.Size = UDim2.new(1, -20, 0, 15)
trajColorLbl.Position = UDim2.new(0, 10, 0, y)
trajColorLbl.BackgroundTransparency = 1
trajColorLbl.Text = "Traj Color"
trajColorLbl.TextColor3 = TEXT_SECONDARY
trajColorLbl.TextSize = 11
trajColorLbl.Font = Enum.Font.GothamBold
trajColorLbl.TextXAlignment = Enum.TextXAlignment.Left
trajColorLbl.ZIndex = 3
trajColorLbl.Parent = Scroll
y = y + 18
createColorSwatches(Scroll, y, trajColor, function(c)
    trajColor = c
    for _, data in pairs(ballBeams) do applyBeamAppearance(data.beam) end
end, 22)
y = y + 28

createSlider(Scroll, "Traj Transparency", y, 0, 1, trajTransparency, function(v)
    trajTransparency = v
    for _, data in pairs(ballBeams) do applyBeamAppearance(data.beam) end
end, true, ACCENT_YELLOW)
y = y + 45
createSlider(Scroll, "Traj Width", y, 0.05, 0.6, trajWidth, function(v)
    trajWidth = v
    for _, data in pairs(ballBeams) do applyBeamAppearance(data.beam) end
end, true, ACCENT_YELLOW)
y = y + 45
createSlider(Scroll, "Traj Length", y, 5, 100, trajLength, function(v) trajLength = v end, false, ACCENT_YELLOW)
y = y + 45

-- === BALL ESP ===
createSection(Scroll, "BALL ESP (mesafe)", y, ACCENT_CYAN)
y = y + 26

createToggle(Scroll, "Distance ESP", y, ACCENT_CYAN, function(state)
    espEnabled = state
    -- Görünürlüğü hemen güncelle
    for ball, esp in pairs(ballESP) do
        if esp.billboard then
            esp.billboard.Enabled = state
        end
    end
end)
y = y + 40

-- === BALL PARTICLE ===
createSection(Scroll, "BALL PARTICLE", y, ACCENT_PURPLE)
y = y + 26

createToggle(Scroll, "Particles", y, ACCENT_PURPLE, function(state)
    particleEnabled = state
    for ball, em in pairs(ballParticles) do
        if em then em.Enabled = state end
    end
end)
y = y + 40

-- Particle texture label
local texLbl = Instance.new("TextLabel")
texLbl.Size = UDim2.new(1, -20, 0, 15)
texLbl.Position = UDim2.new(0, 10, 0, y)
texLbl.BackgroundTransparency = 1
texLbl.Text = "Texture"
texLbl.TextColor3 = TEXT_SECONDARY
texLbl.TextSize = 11
texLbl.Font = Enum.Font.GothamBold
texLbl.TextXAlignment = Enum.TextXAlignment.Left
texLbl.ZIndex = 3
texLbl.Parent = Scroll
y = y + 18

-- Particle textures (2 satır x 3 kolon)
local particleTextures = {
    {name = "Sparkle", tex = "rbxasset://textures/particles/sparkles_main.dds"},
    {name = "Fire",    tex = "rbxasset://textures/particles/fire_main.dds"},
    {name = "Smoke",   tex = "rbxasset://textures/particles/smoke_main.dds"},
    {name = "Ring",    tex = "rbxasset://textures/particles/rings_main.dds"},
    {name = "Spark2",  tex = "rbxasset://textures/particles/sparkles_main.dds"},
    {name = "Explode", tex = "rbxasset://textures/particles/explosion01_implosion_main.dds"},
}

local texButtons = {}
for i, t in ipairs(particleTextures) do
    local col = (i - 1) % 3
    local row = math.floor((i - 1) / 3)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 82, 0, 24)
    btn.Position = UDim2.new(0, 10 + col * 86, 0, y + row * 28)
    btn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
    btn.Text = t.name
    btn.TextColor3 = TEXT_PRIMARY
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local str = Instance.new("UIStroke")
    str.Color = ACCENT_PURPLE
    str.Thickness = 1.5
    str.Transparency = 0.7
    str.Parent = btn
    texButtons[i] = { btn = btn, stroke = str }

    btn.MouseButton1Click:Connect(function()
        particleTexture = t.tex
        for _, data in pairs(texButtons) do
            data.stroke.Transparency = 0.7
            data.btn.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
        end
        str.Transparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(60, 40, 90)
        for _, em in pairs(ballParticles) do
            if em then em.Texture = particleTexture end
        end
    end)
end
-- İlk butonu seçili yap
texButtons[1].stroke.Transparency = 0
texButtons[1].btn.BackgroundColor3 = Color3.fromRGB(60, 40, 90)

y = y + 60

-- Particle color
local partColorLbl = Instance.new("TextLabel")
partColorLbl.Size = UDim2.new(1, -20, 0, 15)
partColorLbl.Position = UDim2.new(0, 10, 0, y)
partColorLbl.BackgroundTransparency = 1
partColorLbl.Text = "Particle Color"
partColorLbl.TextColor3 = TEXT_SECONDARY
partColorLbl.TextSize = 11
partColorLbl.Font = Enum.Font.GothamBold
partColorLbl.TextXAlignment = Enum.TextXAlignment.Left
partColorLbl.ZIndex = 3
partColorLbl.Parent = Scroll
y = y + 18
createColorSwatches(Scroll, y, particleColor, function(c)
    particleColor = c
    for _, em in pairs(ballParticles) do
        if em then em.Color = ColorSequence.new(c) end
    end
end, 22)
y = y + 28

createSlider(Scroll, "Rate", y, 5, 200, particleRate, function(v)
    particleRate = v
    for _, em in pairs(ballParticles) do
        if em then em.Rate = v end
    end
end, false, ACCENT_PURPLE)
y = y + 45
createSlider(Scroll, "Size", y, 0.1, 3, particleSize, function(v)
    particleSize = v
    for _, em in pairs(ballParticles) do
        if em then em.Size = NumberSequence.new(v) end
    end
end, true, ACCENT_PURPLE)
y = y + 45
createSlider(Scroll, "Speed", y, 0.5, 15, particleSpeed, function(v)
    particleSpeed = v
    for _, em in pairs(ballParticles) do
        if em then em.Speed = NumberRange.new(v * 0.5, v) end
    end
end, true, ACCENT_PURPLE)
y = y + 45

-- === SPEED ===
createSection(Scroll, "SPEED MODIFIER", y, ACCENT_ORANGE)
y = y + 26

createToggle(Scroll, "WalkSpeed", y, ACCENT_ORANGE, function(state)
    speedEnabled = state
    applySpeed()
end)
y = y + 40

createSlider(Scroll, "Speed Value", y, MIN_SPEED, MAX_SPEED, currentSpeed, function(v)
    currentSpeed = v
    applySpeed()
end, false, ACCENT_ORANGE)
y = y + 45

-- === DISCORD ===
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(1, -20, 0, 34)
discordBtn.Position = UDim2.new(0, 10, 0, y)
discordBtn.BackgroundColor3 = Color3.fromRGB(30, 33, 70)
discordBtn.Text = "🎮  JOIN OUR DISCORD"
discordBtn.TextColor3 = ACCENT_DISCORD
discordBtn.TextSize = 12
discordBtn.Font = Enum.Font.GothamBold
discordBtn.AutoButtonColor = false
discordBtn.ZIndex = 3
discordBtn.Parent = Scroll
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 8)
local dStroke = Instance.new("UIStroke")
dStroke.Color = ACCENT_DISCORD
dStroke.Thickness = 1.5
dStroke.Transparency = 0.3
dStroke.Parent = discordBtn
discordBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.com/invite/CWYQqnEMh") end)
    local orig = discordBtn.Text
    discordBtn.Text = "✅  LINK COPIED!"
    discordBtn.TextColor3 = ACCENT_GREEN
    task.delay(2, function()
        discordBtn.Text = orig
        discordBtn.TextColor3 = ACCENT_DISCORD
    end)
end)
y = y + 50

Scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)

-- =============================================
-- TRAJECTORY BEAM SYSTEM
-- =============================================
local trajectoryFolder = Instance.new("Folder")
trajectoryFolder.Name = "TrajectoryPreview"
trajectoryFolder.Parent = workspace

local ballBeams = {}

local function applyBeamAppearance(beam)
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, trajColor),
        ColorSequenceKeypoint.new(1, trajColor:Lerp(Color3.new(0, 0, 0), 0.45)),
    })
    beam.Width0 = trajWidth
    beam.Width1 = trajWidth * 0.25
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, trajTransparency),
        NumberSequenceKeypoint.new(0.4, math.min(1, trajTransparency + 0.25)),
        NumberSequenceKeypoint.new(1, 0.95),
    })
end

local function createBeamForBall(ball)
    if ballBeams[ball] then return ballBeams[ball] end
    local att0 = Instance.new("Attachment")
    att0.Parent = trajectoryFolder
    local att1 = Instance.new("Attachment")
    att1.Parent = trajectoryFolder
    local beam = Instance.new("Beam")
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Segments = 12
    beam.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    beam.TextureMode = Enum.TextureMode.Wrap
    beam.TextureLength = 2
    beam.TextureSpeed = 3
    beam.Enabled = false
    beam.Parent = trajectoryFolder
    applyBeamAppearance(beam)
    ballBeams[ball] = { beam = beam, att0 = att0, att1 = att1 }
    return ballBeams[ball]
end

local function hideAllTrajectories()
    for _, data in pairs(ballBeams) do
        data.beam.Enabled = false
    end
end

-- =============================================
-- BALL ESP + PARTICLE STORAGE
-- =============================================
local ballESP = {}
local ballParticles = {}

local function createESP(ball)
    if ballESP[ball] then return ballESP[ball] end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BallESP"
    billboard.Size = UDim2.new(0, 80, 0, 24)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = espEnabled
    billboard.Parent = ball

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "0 m"
    label.TextColor3 = espColor
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = billboard

    ballESP[ball] = { billboard = billboard, label = label }
    return ballESP[ball]
end

local function createParticle(ball)
    if ballParticles[ball] then return ballParticles[ball] end
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "BallParticles"
    emitter.Texture = particleTexture
    emitter.Rate = particleRate
    emitter.Lifetime = NumberRange.new(0.5, 1.2)
    emitter.Speed = NumberRange.new(particleSpeed * 0.5, particleSpeed)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Size = NumberSequence.new(particleSize)
    emitter.Color = ColorSequence.new(particleColor)
    emitter.LightEmission = 1
    emitter.LightInfluence = 0
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Enabled = particleEnabled
    emitter.Parent = ball
    ballParticles[ball] = emitter
    return emitter
end

-- =============================================
-- VELOCITY ESTIMATION
-- =============================================
local ballHistory = {}

local function getBallVelocity(ball)
    local hist = ballHistory[ball]
    if hist and hist.vel.Magnitude > 1 then return hist.vel end
    local ok, v = pcall(function() return ball.AssemblyLinearVelocity end)
    if ok and v and v.Magnitude > 1 then return v end
    return Vector3.zero
end

local function predictTrajectory(ball)
    local vel = getBallVelocity(ball)
    if vel.Magnitude < 2 then return nil end
    local gravity = Vector3.new(0, -workspace.Gravity, 0)
    local dt = trajDt
    local pos = ball.Position
    local points = {}
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local exclude = {ball, trajectoryFolder}
    if player.Character then table.insert(exclude, player.Character) end
    rayParams.FilterDescendantsInstances = exclude
    rayParams.IgnoreWater = true
    local maxPoints = math.floor(trajLength)
    for i = 1, maxPoints do
        local nextPos = pos + vel * dt + 0.5 * gravity * dt * dt
        local dir = nextPos - pos
        local result = workspace:Raycast(pos, dir, rayParams)
        if result then
            local hitPos = result.Position
            local normal = result.Normal
            table.insert(points, hitPos)
            local dot = vel:Dot(normal)
            vel = (vel - 2 * dot * normal) * 0.65
            pos = hitPos + normal * 0.3
        else
            pos = nextPos
            vel = vel + gravity * dt
            table.insert(points, pos)
        end
        if #points >= maxPoints then break end
    end
    return points
end

-- =============================================
-- WALKSPEED
-- =============================================
local function applySpeed()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedEnabled and currentSpeed or DEFAULT_SPEED
        end
    end
end

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if speedEnabled then humanoid.WalkSpeed = currentSpeed end
end)

-- =============================================
-- BALL TRACKING
-- =============================================
local function addBall(part)
    if part:IsA("BasePart") and not trackedBalls[part] then
        trackedBalls[part] = {
            Size = part.Size,
            Transparency = part.Transparency,
            CanCollide = part.CanCollide,
            Material = part.Material,
            Color = part.Color,
        }
        ballHistory[part] = { pos = part.Position, time = tick(), vel = Vector3.zero }

        createESP(part)
        createParticle(part)

        part.AncestryChanged:Connect(function()
            if part.Parent == nil then
                trackedBalls[part] = nil
                ballHistory[part] = nil
                if ballBeams[part] then
                    ballBeams[part].beam:Destroy()
                    ballBeams[part].att0:Destroy()
                    ballBeams[part].att1:Destroy()
                    ballBeams[part] = nil
                end
                if ballESP[part] then
                    ballESP[part].billboard:Destroy()
                    ballESP[part] = nil
                end
                if ballParticles[part] then
                    ballParticles[part]:Destroy()
                    ballParticles[part] = nil
                end
            end
        end)
    end
end

workspace.DescendantAdded:Connect(function(d)
    if d:IsA("BasePart") and d.Name == BALL_NAME then addBall(d) end
end)
for _, d in pairs(workspace:GetDescendants()) do
    if d:IsA("BasePart") and d.Name == BALL_NAME then addBall(d) end
end

-- =============================================
-- MAIN LOOP
-- =============================================
local espTimer = 0

RunService.RenderStepped:Connect(function(dt)
    -- Update velocity history
    for ball in pairs(trackedBalls) do
        if ball and ball.Parent then
            local now = tick()
            local hist = ballHistory[ball]
            if hist then
                local dtime = now - hist.time
                if dtime > 0.005 then
                    hist.vel = (ball.Position - hist.pos) / dtime
                    hist.pos = ball.Position
                    hist.time = now
                end
            end
        end
    end

    -- Hitbox expand
    if enabled then
        for part, orig in pairs(trackedBalls) do
            if part and part.Parent then
                local newSize = orig.Size * currentSize
                if part.Size ~= newSize then part.Size = newSize end
                if part.Transparency ~= ballTransparency then part.Transparency = ballTransparency end
                if part.CanCollide ~= false then part.CanCollide = false end
                if part.Material ~= Enum.Material.Neon then part.Material = Enum.Material.Neon end
                if part.Color ~= ballColor then part.Color = ballColor end
            end
        end
    end

    -- Trajectory
    if trajectoryEnabled then
        for ball in pairs(trackedBalls) do
            if ball and ball.Parent then
                local pts = predictTrajectory(ball)
                local data = ballBeams[ball] or createBeamForBall(ball)
                if pts and #pts >= 2 then
                    data.att0.WorldPosition = ball.Position
                    data.att1.WorldPosition = pts[#pts]
                    data.beam.Enabled = true
                else
                    data.beam.Enabled = false
                end
            end
        end
    else
        hideAllTrajectories()
    end

    -- ESP distance update
    espTimer = espTimer + dt
    if espTimer >= 0.1 then
        espTimer = 0
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for ball, esp in pairs(ballESP) do
                if ball and ball.Parent and esp.label then
                    local dist = (ball.Position - hrp.Position).Magnitude
                    esp.label.Text = string.format("%.0f m", dist)
                    esp.label.TextColor3 = espColor
                end
            end
        end
    end
end)

-- Hitbox Toggle
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    local t = TweenInfo.new(0.25)
    if enabled then
        TweenService:Create(toggleBtn, t, {BackgroundColor3 = Color3.fromRGB(15, 45, 30)}):Play()
        TweenService:Create(toggleStroke, t, {Color = ACCENT_GREEN}):Play()
        toggleBtn.Text = "HITBOX: ACTIVE"
        toggleBtn.TextColor3 = ACCENT_GREEN
    else
        TweenService:Create(toggleBtn, t, {BackgroundColor3 = Color3.fromRGB(35, 25, 35)}):Play()
        TweenService:Create(toggleStroke, t, {Color = ACCENT_RED}):Play()
        toggleBtn.Text = "HITBOX: DISABLED"
        toggleBtn.TextColor3 = ACCENT_RED
        for part, orig in pairs(trackedBalls) do
            if part and part.Parent then
                part.Size = orig.Size
                part.Transparency = orig.Transparency
                part.CanCollide = orig.CanCollide
                part.Material = orig.Material
                part.Color = orig.Color
            end
        end
    end
end)

-- UI Toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == TOGGLE_KEY then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end
end)
