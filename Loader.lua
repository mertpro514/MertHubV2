-- MertHubV2 PRO UI
-- Single File | Executor Only

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

local function getChar()
	local c = lp.Character or lp.CharacterAdded:Wait()
	return c, c:WaitForChild("Humanoid"), c:WaitForChild("HumanoidRootPart")
end

-- ================= UI =================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MertHubV2_PRO"

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(460, 360)
main.Position = UDim2.fromScale(0.05, 0.25)
main.BackgroundColor3 = Color3.fromRGB(16,16,16)
main.BorderSizePixel = 0
main.Active, main.Draggable = true, true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

-- Shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1,40,1,40)
shadow.Position = UDim2.fromOffset(-20,-20)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,118,118)
shadow.BackgroundTransparency = 1
shadow.ZIndex = 0

-- Top bar
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,48)
top.BackgroundColor3 = Color3.fromRGB(22,22,22)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-16,1,0)
title.Position = UDim2.fromOffset(16,0)
title.BackgroundTransparency = 1
title.Text = "MertHub V2  |  PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(240,240,240)
title.TextXAlignment = Left

-- Content
local content = Instance.new("Frame", main)
content.Position = UDim2.fromOffset(16,64)
content.Size = UDim2.new(1,-32,1,-80)
content.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0,12)

-- ================= UI ELEMENTS =================
local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function button(text, cb)
	local b = Instance.new("TextButton", content)
	b.Size = UDim2.new(1,0,0,40)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.fromRGB(235,235,235)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)

	b.MouseEnter:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(40,40,40)})
	end)
	b.MouseLeave:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(30,30,30)})
	end)

	b.MouseButton1Click:Connect(cb)
	return b
end

local function toggle(text, cb)
	local on = false
	local b = button(text .. " : OFF", function()
		on = not on
		b.Text = text .. (on and " : ON" or " : OFF")
		cb(on)
	end)
end

local function slider(text, min, max, default, cb)
	local holder = Instance.new("Frame", content)
	holder.Size = UDim2.new(1,0,0,52)
	holder.BackgroundTransparency = 1

	local lbl = Instance.new("TextLabel", holder)
	lbl.Size = UDim2.new(1,0,0,18)
	lbl.BackgroundTransparency = 1
	lbl.Text = text .. ": " .. default
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.TextXAlignment = Left

	local bar = Instance.new("Frame", holder)
	bar.Position = UDim2.fromOffset(0,26)
	bar.Size = UDim2.new(1,0,0,14)
	bar.BackgroundColor3 = Color3.fromRGB(35,35,35)
	bar.BorderSizePixel = 0
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(90,120,255)
	fill.BorderSizePixel = 0
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)

	local dragging = false
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(pct,0,1,0)
			local val = math.floor(min + (max-min)*pct)
			lbl.Text = text .. ": " .. val
			cb(val)
		end
	end)
end

-- ================= FEATURES =================

-- WalkSpeed / JumpPower (CUSTOM)
slider("WalkSpeed", 16, 150, 16, function(v)
	local _, hum = getChar()
	hum.WalkSpeed = v
end)

slider("JumpPower", 50, 250, 50, function(v)
	local _, hum = getChar()
	hum.JumpPower = v
end)

-- TP
button("TP to Mouse (T)", function() end)
UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.T and mouse.Hit then
		local _,_,hrp = getChar()
		hrp.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0,3,0))
	end
end)

-- Fly
local flying = false
local bv, bg
toggle("Fly (F)", function(v)
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

RunService.RenderStepped:Connect(function()
	if flying and bv and bg then
		local cam = workspace.CurrentCamera
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		bv.Velocity = dir * 90
		bg.CFrame = cam.CFrame
	end
end)

-- ESP
toggle("ESP", function(on)
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			if on then
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "ESP"
				box.Adornee = p.Character.HumanoidRootPart
				box.Size = Vector3.new(4,6,2)
				box.AlwaysOnTop = true
				box.Color3 = Color3.fromRGB(255,80,80)
				box.Parent = p.Character
			else
				local b = p.Character:FindFirstChild("ESP")
				if b then b:Destroy() end
			end
		end
	end
end)

-- MENU TOGGLE
UIS.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)

print("MertHubV2 PRO Loaded")

