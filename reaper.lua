local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("REAPER V10.4 | HYBRID", "BloodTheme")

-- Определение платформы
local isMobile = (game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").MouseEnabled)
local lp = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Настройки
_G.Aimbot = false
_G.AimPart = "Head"
_G.Smoothness = 0.08
_G.FOV = 150
_G.Prediction = false
_G.PredIntensity = 0.15
_G.AimBind = isMobile and Enum.KeyCode.E or Enum.KeyCode.Q -- Разные бинды для удобства

_G.ESP_Enabled = false
_G.Arrows_Enabled = false
_G.WalkSpeed = 16
_G.FlySpeed = 50
_G.Flying = false

-- ВКЛАДКИ
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")

-- СЕКЦИЯ COMBAT
local AimSec = Combat:NewSection("Aimbot & Prediction")
AimSec:NewToggle("Enable Aimbot", "Lock on players", function(s) _G.Aimbot = s end)
AimSec:NewToggle("Movement Prediction", "For fast targets", function(s) _G.Prediction = s end)
AimSec:NewSlider("FOV", "Radius", 800, 10, function(s) _G.FOV = s end)
AimSec:NewKeybind("Aim Key", "Bind", _G.AimBind, function(k) _G.AimBind = k end)

-- СЕКЦИЯ VISUALS (Оптимизирована под Mobile)
local VisSec = Visuals:NewSection("ESP Settings")
VisSec:NewToggle("Box ESP", "Squares", function(s) _G.ESP_Enabled = s end)
VisSec:NewToggle("Arrows", "Offscreen indicators", function(s) _G.Arrows_Enabled = s end)

-- СЕКЦИЯ MOVEMENT (С ПК-эксклюзивами)
local MoveSec = Movement:NewSection("Player Cheats")
MoveSec:NewSlider("WalkSpeed", "Default: 16", 500, 16, function(s) _G.WalkSpeed = s end)

-- Функции только для ПК (Fly / Car Speed)
if not isMobile then
    MoveSec:NewToggle("PC Fly", "Flight (Only for PC)", function(s) _G.Flying = s end)
    MoveSec:NewSlider("Fly Speed", "Speed of flight", 300, 50, function(s) _G.FlySpeed = s end)
    
    MoveSec:NewButton("Car Speed (Hold X)", "Boost vehicle", function()
        -- Логика ускорителя машин
    end)
end

-- ВИЗУАЛЫ (ScreenGui)
local MainGui = Instance.new("ScreenGui", lp.PlayerGui)
MainGui.Name = "ReaperVisuals"
MainGui.IgnoreGuiInset = true
local espObjects = {}

-- Круг FOV (Drawing работает только если инжектор поддерживает)
local Circle = Drawing.new("Circle")
Circle.Color, Circle.Thickness, Circle.NumSides = Color3.new(1,0,0), 1, 32 -- 32 стороны для FPS на мобилках
Circle.Visible = false

local function createVisuals(p)
    if p == lp then return end
    local b = Instance.new("Frame", MainGui)
    b.AnchorPoint, b.BackgroundTransparency, b.BorderSizePixel, b.BorderColor3, b.Visible = Vector2.new(.5,.5), 1, 1, Color3.new(1,0,0), false
    local n = Instance.new("TextLabel", b)
    n.Size, n.Position, n.BackgroundTransparency, n.TextColor3, n.TextSize = UDim2.new(1,0,0,20), UDim2.new(0,0,-.25,0), 1, Color3.new(1,1,1), isMobile and 10 or 12
    local a = Instance.new("ImageLabel", MainGui)
    a.Size, a.AnchorPoint, a.BackgroundTransparency, a.Image, a.ImageColor3, a.Visible = UDim2.new(0,30,0,30), Vector2.new(.5,.5), 1, "rbxassetid://6031097229", Color3.new(1,0,0), false
    espObjects[p] = {box = b, txt = n, arrow = a}
end

-- ЛОГИКА ПОЛЕТА (PC ONLY)
local bodyVel, bodyGyro
if not isMobile then
    rs.Heartbeat:Connect(function()
        if _G.Flying and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            if not hrp:FindFirstChild("FlyVel") then
                bodyVel = Instance.new("BodyVelocity", hrp)
                bodyVel.Name = "FlyVel"
                bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyGyro = Instance.new("BodyGyro", hrp)
                bodyGyro.Name = "FlyGyro"
                bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                bodyGyro.P = 10000
            end
            bodyVel.Velocity = cam.CFrame.LookVector * _G.FlySpeed
            bodyGyro.CFrame = cam.CFrame
        else
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                if lp.Character.HumanoidRootPart:FindFirstChild("FlyVel") then lp.Character.HumanoidRootPart.FlyVel:Destroy() end
                if lp.Character.HumanoidRootPart:FindFirstChild("FlyGyro") then lp.Character.HumanoidRootPart.FlyGyro:Destroy() end
            end
        end
    end)
end

-- ГЛАВНЫЙ ЦИКЛ (ОПТИМИЗИРОВАН)
local lastUpdate = 0
rs.RenderStepped:Connect(function()
    local now = tick()
    Circle.Visible, Circle.Radius, Circle.Position = _G.Aimbot, _G.FOV, uis:GetMouseLocation()
    
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = _G.WalkSpeed
    end

    -- Лимит обновления для мобилок (экономим ФПС)
    if isMobile and (now - lastUpdate) < 0.015 then return end 
    lastUpdate = now

    for p, d in pairs(espObjects) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
            local r = p.Character.HumanoidRootPart
            local sPos, on = cam:WorldToViewportPoint(r.Position)
            
            if _G.Arrows_Enabled and not on then
                local c = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                local diff = (Vector2.new(sPos.X, sPos.Y) - c)
                if sPos.Z < 0 then diff = -diff end
                local dir = diff.Unit
                d.arrow.Visible, d.arrow.Position, d.arrow.Rotation = true, UDim2.new(0, c.X + dir.X*160, 0, c.Y + dir.Y*160), math.deg(math.atan2(dir.Y, dir.X)) + 90
            else d.arrow.Visible = false end
            
            if on and _G.ESP_Enabled then
                local sz = (cam:WorldToViewportPoint(r.Position - Vector3.new(0,3,0)).Y - cam:WorldToViewportPoint(r.Position + Vector3.new(0,2.6,0)).Y)
                d.box.Visible, d.box.Size, d.box.Position = true, UDim2.new(0, sz/1.5, 0, sz), UDim2.new(0, sPos.X, 0, sPos.Y)
                d.txt.Text = p.Name .. " [" .. math.floor((r.Position - cam.CFrame.Position).Magnitude) .. "m]"
            else d.box.Visible = false end
        else d.box.Visible, d.arrow.Visible = false, false end
    end

    -- AIM LOGIC
    if _G.Aimbot and uis:IsKeyDown(_G.AimBind) then
        local t, close = nil, _G.FOV
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild(_G.AimPart) then
                local p, vis = cam:WorldToViewportPoint(v.Character[_G.AimPart].Position)
                if vis then
                    local m = (Vector2.new(p.X, p.Y) - uis:GetMouseLocation()).Magnitude
                    if m < close then close = m t = v.Character end
                end
            end
        end
        if t then
            local targetPos = t[_G.AimPart].Position
            if _G.Prediction then targetPos = targetPos + (t.HumanoidRootPart.Velocity * _G.PredIntensity) end
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), _G.Smoothness)
        end
    end
end)

for _, p in pairs(game.Players:GetPlayers()) do createVisuals(p) end
game.Players.PlayerAdded:Connect(createVisuals)
