local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("REAPER V10.3 | PREDICTION", "BloodTheme")

-- Глобальные настройки
_G.Aimbot = false
_G.AimPart = "Head"
_G.Smoothness = 0.05
_G.FOV = 150
_G.AimBind = Enum.KeyCode.E
_G.Prediction = false -- Включение предугадывания
_G.PredIntensity = 0.15 -- Интенсивность (насколько далеко "закидывать" прицел)

_G.ESP_Enabled = false
_G.Arrows_Enabled = false
_G.WalkSpeed = 16

local lp = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- UI
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")

local AimSec = Combat:NewSection("Aimbot & Prediction")
AimSec:NewToggle("Enable Aimbot", "Работает при зажатии бинда", function(s) _G.Aimbot = s end)
AimSec:NewToggle("Movement Prediction", "Предугадывание движения", function(s) _G.Prediction = s end)
AimSec:NewSlider("Pred Intensity", "Сила упреждения", 50, 10, function(s) _G.PredIntensity = s/100 end)
AimSec:NewKeybind("Aim Bind", "Зажми для наводки", Enum.KeyCode.E, function(k) _G.AimBind = k end)
AimSec:NewSlider("Aim FOV", "Радиус", 800, 10, function(s) _G.FOV = s end)

local VisSec = Visuals:NewSection("Visual Settings")
VisSec:NewToggle("Box ESP", "Квадраты", function(s) _G.ESP_Enabled = s end)
VisSec:NewToggle("Arrows", "Стрелочки", function(s) _G.Arrows_Enabled = s end)

-- Хранилище визуалов (ScreenGui)
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
    n.Size, n.Position, n.BackgroundTransparency, n.TextColor3, n.TextSize = UDim2.new(1,0,0,20), UDim2.new(0,0,-.25,0), 1, Color3.new(1,1,1), 14
    local a = Instance.new("ImageLabel", MainGui)
    a.Size, a.AnchorPoint, a.BackgroundTransparency, a.Image, a.ImageColor3, a.Visible = UDim2.new(0,35,0,35), Vector2.new(.5,.5), 1, "rbxassetid://6031097229", Color3.new(1,0,0), false
    espObjects[p] = {box = b, txt = n, arrow = a}
end

-- ЛОГИКА АИМА С PREDICTION
local function getTarget()
    local t, close = nil, _G.FOV
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild(_G.AimPart) and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                local p, vis = cam:WorldToViewportPoint(v.Character[_G.AimPart].Position)
                if vis then
                    local mag = (Vector2.new(p.X, p.Y) - uis:GetMouseLocation()).Magnitude
                    if mag < close then close = mag t = v.Character end
                end
            end
        end
    end
    return t
end

rs.RenderStepped:Connect(function()
    Circle.Visible, Circle.Radius, Circle.Position = _G.Aimbot, _G.FOV, uis:GetMouseLocation()
    
    -- ESP & Arrows
    for p, d in pairs(espObjects) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
            local r = p.Character.HumanoidRootPart
            local sPos, on = cam:WorldToViewportPoint(r.Position)
            if _G.Arrows_Enabled and not on then
                local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                local diff = (Vector2.new(sPos.X, sPos.Y) - center)
                if sPos.Z < 0 then diff = -diff end
                local dir = diff.Unit
                d.arrow.Visible, d.arrow.Position, d.arrow.Rotation = true, UDim2.new(0, center.X + dir.X*180, 0, center.Y + dir.Y*180), math.deg(math.atan2(dir.Y, dir.X)) + 90
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
        local targetChar = getTarget()
        if targetChar then
            local part = targetChar[_G.AimPart]
            local targetPos = part.Position
            
            -- Добавляем Prediction
            if _G.Prediction and targetChar:FindFirstChild("HumanoidRootPart") then
                -- Формула: Позиция + (Скорость * Интенсивность)
                targetPos = targetPos + (targetChar.HumanoidRootPart.Velocity * _G.PredIntensity)
            end
            
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), _G.Smoothness)
        end
    end
end)

for _, p in pairs(game.Players:GetPlayers()) do createVisuals(p) end
game.Players.PlayerAdded:Connect(createVisuals)
