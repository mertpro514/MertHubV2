-- MertHubV2 | Single File Loader
-- Executor only

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

local function getChar()
    local c = lp.Character or lp.CharacterAdded:Wait()
    return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

-- ================= UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MertHubV2"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(420, 320)
main.Position = UDim2.fromScale(0.05, 0.25)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BorderSizePixel = 0
main.Active, main.Draggable = true, true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,44)
title.BackgroundTransparency = 1
title.Text = "MertHub V2"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

local content = Instance.new("Frame", main)
content.Position = UDim2.fromOffset(12,56)
content.Size = UDim2.new(1,-24,1,-68)
content.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0,10)

local function button(text, cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,0,0,38)
    b.BackgroundColor3 = Color3.fromRGB(32,32,32)
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Text = text
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function toggle(text, state, cb)
    local b
    b = button(text .. ": OFF", function()
        state = not state
        b.Text = text .. (state and ": ON" or ": OFF")
        cb(state)
    end)
end

-- ================= FEATURES =================

-- SPEED / JUMP
button("Speed 50", function()
    local _, hum = getChar()
    hum.WalkSpeed = 50
end)

button("Jump 120", function()
    local _, hum = getChar()
    hum.JumpPower = 120
end)

button("Reset Speed / Jump", function()
    local _, hum = getChar()
    hum.WalkSpeed = 16
    hum.JumpPower = 50
end)

-- TP TO MOUSE
button("TP to Mouse (T)", function() end)

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.T and mouse.Hit then
        local _,_,hrp = getChar()
        hrp.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0,3,0))
    end
end)

-- FLY
local flying = false
local bv, bg

toggle("Fly (F)", false, function(v)
    flying = v
    local _,_,hrp = getChar()
    if v then
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.F then
        flying = not flying
    end
end)

RunService.RenderStepped:Connect(function()
    if flying and bv and bg then
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        bv.Velocity = dir * 80
        bg.CFrame = cam.CFrame
    end
end)

-- ESP
local espOn = false
local espBoxes = {}

local function clearESP()
    for _,b in pairs(espBoxes) do b:Destroy() end
    espBoxes = {}
end

toggle("ESP", false, function(v)
    espOn = v
    clearESP()
    if not v then return end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Adornee = p.Character.HumanoidRootPart
            box.Size = Vector3.new(4,6,2)
            box.AlwaysOnTop = true
            box.Transparency = 0.5
            box.Color3 = Color3.fromRGB(255,80,80)
            box.Parent = p.Character
            table.insert(espBoxes, box)
        end
    end
end)

-- MENU TOGGLE
UIS.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

print("MertHubV2 Loaded")
