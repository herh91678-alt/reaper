local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("REAPER V10.5 | UNLOCKED", "BloodTheme")

-- Настройки
_G.Aimbot = false
_G.AimPart = "Head"
_G.Smoothness = 0.08
_G.FOV = 150
_G.Prediction = false
_G.PredIntensity = 0.15
_G.AimBind = Enum.KeyCode.E

_G.ESP_Enabled = false
_G.Arrows_Enabled = false

-- Movement Settings
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.InfJump = false
_G.FlyEnabled = false
_G.FlySpeed = 50

local lp = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- ВКЛАДКИ
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")

-- COMBAT
local AimSec = Combat:NewSection("Aimbot & Prediction")
AimSec:NewToggle("Enable Aimbot", "Lock on players", function(s) _G.Aimbot = s end)
AimSec:NewToggle("Movement Prediction", "For fast targets", function(s) _G.Prediction = s end)
AimSec:NewSlider("FOV", "Radius", 800, 10, function(s) _G.FOV = s end)
AimSec:NewKeybind("Aim Key", "Bind", _G.AimBind, function(k) _G.AimBind = k end)

-- VISUALS
local VisSec = Visuals:NewSection("ESP Settings")
VisSec:NewToggle("Box ESP", "Squares", function(s) _G.ESP_Enabled = s end)
VisSec:NewToggle("Arrows", "Offscreen indicators", function(s) _G.Arrows_Enabled = s end)

-- MOVEMENT (ТЕПЕРЬ ВСЁ ТУТ)
local MoveSec = Movement:NewSection("Player Cheats")
MoveSec:NewSlider("WalkSpeed", "Speed", 500, 16, function(s) _G.WalkSpeed = s end)
MoveSec:NewSlider("JumpPower", "Jump", 500, 50, function(s) _G.JumpPower = s end)
MoveSec:NewToggle("Infinite Jump", "Jump in air", function(s) _G.InfJump = s end)

local FlySec = Movement:NewSection("Flight")
FlySec:NewToggle("Enable Fly", "Fly like a bird", function(s) _G.FlyEnabled = s end)
FlySec:NewSlider("Fly Speed", "Flight speed", 500, 10, function(s) _G.FlySpeed = s end)

-- ЛОГИКА INFINITE JUMP
uis.JumpRequest:Connect(function()
    if _G.InfJump and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ЛОГИКА FLY (Работает везде)
local bodyVel, bodyGyro
rs.Heartbeat:Connect(function()
    if _G.FlyEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        if not hrp:FindFirstChild("ReaperFlyVel") then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.Name = "ReaperFlyVel"
            bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.Name = "ReaperFlyGyro"
            bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            bodyGyro.P = 10000
        end
        bodyVel.Velocity = cam.CFrame.LookVector * _G.FlySpeed
        bodyGyro.CFrame = cam.CFrame
        lp.Character.Humanoid.PlatformStand = true
    else
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            if lp.Character.HumanoidRootPart:FindFirstChild("ReaperFlyVel") then lp.Character.HumanoidRootPart.ReaperFlyVel:Destroy() end
            if lp.Character.HumanoidRootPart:FindFirstChild("ReaperFlyGyro") then lp.Character.HumanoidRootPart.ReaperFlyGyro:Destroy() end
            if lp.Character:FindFirstChildOfClass("Humanoid") then lp.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false end
        end
    end
end)

-- ВИЗУАЛЫ (ScreenGui)
local MainGui = Instance.new("ScreenGui", lp.PlayerGui)
MainGui.Name = "ReaperVisuals"
MainGui.IgnoreGuiInset = true
local espObjects = {}

-- Круг FOV
local Circle = Drawing.new("Circle")
Circle.Color, Circle.Thickness, Circle.NumSides = Color3.new(1,0,0), 1, 64
Circle.Visible = false

local function createVisuals(p)
    if p == lp then return end
    local b = Instance.new("Frame", MainGui)
    b.AnchorPoint, b.BackgroundTransparency, b.BorderSizePixel, b.BorderColor3, b.Visible = Vector2.new(.5,.5), 1, 2, Color3.new(1,0,0), false
    local n = Instance.new("TextLabel", b)
    n.Size, n.Position, n.BackgroundTransparency, n.TextColor3, n.TextSize = UDim2.new(1,0,0,20), UDim2.new(0,0,-.25,0), 1, Color3.new(1,1,1), 12
    local a = Instance.new("ImageLabel", MainGui)
    a.Size, a.AnchorPoint, a.BackgroundTransparency, a.Image, a.ImageColor3, a.Visible = UDim2.new(0,35,0,35), Vector2.new(.5,.5), 1, "rbxassetid://6031097229", Color3.new(1,0,0), false
    espObjects[p] = {box = b, txt = n, arrow = a}
end

-- ЦИКЛ
rs.RenderStepped:Connect(function()
    Circle.Visible, Circle.Radius, Circle.Position = _G.Aimbot, _G.FOV, uis:GetMouseLocation()
    
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = _G.WalkSpeed
        lp.Character.Humanoid.JumpPower = _G.JumpPower
    end

    for p, d in pairs(espObjects) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
            local r = p.Character.HumanoidRootPart
            local sPos, on = cam:WorldToViewportPoint(r.Position)
            if _G.Arrows_Enabled and not on then
                local c = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                local diff = (Vector2.new(sPos.X, sPos.Y) - c)
                if sPos.Z < 0 then diff = -diff end
                local dir = diff.Unit
                d.arrow.Visible, d.arrow.Position, d.arrow.Rotation = true, UDim2.new(0, c.X + dir.X*180, 0, c.Y + dir.Y*180), math.deg(math.atan2(dir.Y, dir.X)) + 90
            else d.arrow.Visible = false end
            if on and _G.ESP_Enabled then
                local sz = (cam:WorldToViewportPoint(r.Position - Vector3.new(0,3,0)).Y - cam:WorldToViewportPoint(r.Position + Vector3.new(0,2.6,0)).Y)
                d.box.Visible, d.box.Size, d.box.Position = true, UDim2.new(0, sz/1.5, 0, sz), UDim2.new(0, sPos.X, 0, sPos.Y)
                d.txt.Text = p.Name .. " [" .. math.floor((r.Position - cam.CFrame.Position).Magnitude) .. "m]"
            else d.box.Visible = false end
        else d.box.Visible, d.arrow.Visible = false, false end
    end

    if _G.Aimbot and uis:IsKeyDown(_G.AimBind) then
        local t, close = nil, _G.FOV
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild(_G.AimPart) then
                local pP, vis = cam:WorldToViewportPoint(v.Character[_G.AimPart].Position)
                if vis then
                    local mag = (Vector2.new(pP.X, pP.Y) - uis:GetMouseLocation()).Magnitude
                    if mag < close then close = mag t = v.Character end
                end
            end
        end
        if t then
            local tPos = t[_G.AimPart].Position
            if _G.Prediction then tPos = tPos + (t.HumanoidRootPart.Velocity * _G.PredIntensity) end
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, tPos), _G.Smoothness)
        end
    end
end)

for _, p in pairs(game.Players:GetPlayers()) do createVisuals(p) end
game.Players.PlayerAdded:Connect(createVisuals)
