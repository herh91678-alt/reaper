local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("REAPER V10 | ULTIMATE", "BloodTheme")

-- Вкладки
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")

-- Настройки (Исходные не менял, только добавил управление)
_G.Aimbot = false
_G.AimPart = "Head"
_G.Smoothness = 0.1
_G.FOV = 150 -- Теперь меняется слайдером
_G.AimBind = Enum.KeyCode.E

_G.ESP_Enabled = false
_G.Arrows_Enabled = false
_G.TriggerBot = false
_G.WalkSpeed = 16

local lp = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Создаем ScreenGui
local MainGui = Instance.new("ScreenGui", lp.PlayerGui)
MainGui.Name = "ReaperVisuals"
MainGui.IgnoreGuiInset = true

-- Круг FOV (Рисуем через Drawing для точности)
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 1
Circle.NumSides = 64
Circle.Radius = _G.FOV
Circle.Visible = false

local espObjects = {}

-- ФУНКЦИЯ СОЗДАНИЯ ВИЗУАЛОВ
local function createVisuals(player)
    if player == lp then return end
    
    -- Твой ESP Box
    local box = Instance.new("Frame", MainGui)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255, 0, 0)
    box.Visible = false

    local name = Instance.new("TextLabel", box)
    name.Size = UDim2.new(1, 0, 0, 20)
    name.Position = UDim2.new(0, 0, -0.25, 0)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextStrokeTransparency = 0
    name.TextSize = 14
    name.Font = Enum.Font.SourceSansBold

    local hpBar = Instance.new("Frame", box)
    hpBar.Size = UDim2.new(0, 4, 1, 0)
    hpBar.Position = UDim2.new(-0.1, 0, 0, 0)
    hpBar.BackgroundColor3 = Color3.new(0, 1, 0)

    -- НОВЫЕ СТРЕЛОЧКИ (Используем Frame под углом для более четкого вида)
    local arrowContainer = Instance.new("Frame", MainGui)
    arrowContainer.Size = UDim2.new(0, 40, 0, 40)
    arrowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    arrowContainer.BackgroundTransparency = 1
    arrowContainer.Visible = false

    local arrowImg = Instance.new("ImageLabel", arrowContainer)
    arrowImg.Size = UDim2.new(1, 0, 1, 0)
    arrowImg.BackgroundTransparency = 1
    arrowImg.Image = "rbxassetid://6031097229" -- Более агрессивная стрелка-треугольник
    arrowImg.ImageColor3 = Color3.fromRGB(255, 0, 0)

    espObjects[player] = {box = box, hp = hpBar, txt = name, arrow = arrowContainer}
end

-- МЕНЮ (Добавлена настройка FOV)
local AimSec = Combat:NewSection("Aimbot & Trigger")
AimSec:NewToggle("Enable Aimbot", "Auto-lock", function(s) _G.Aimbot = s Circle.Visible = s end)
AimSec:NewSlider("Aim FOV", "Радиус захвата", 800, 10, function(s) 
    _G.FOV = s 
    Circle.Radius = s -- Обновляем круг моментально
end)
AimSec:NewSlider("Smoothness", "Плавность", 100, 1, function(s) _G.Smoothness = s/100 end)
AimSec:NewKeybind("Aim Key", "Key", Enum.KeyCode.E, function(k) _G.AimBind = k end)
AimSec:NewToggle("Trigger Bot", "Auto-click", function(s) _G.TriggerBot = s end)

local VisSec = Visuals:NewSection("Visual Settings")
VisSec:NewToggle("Enable ESP Box", "Show Squares", function(s) _G.ESP_Enabled = s end)
VisSec:NewToggle("Enable Arrows", "Offscreen Arrows", function(s) _G.Arrows_Enabled = s end)

local MoveSec = Movement:NewSection("Player")
MoveSec:NewSlider("Speed", "WalkSpeed", 500, 16, function(s) _G.WalkSpeed = s end)

-- ОБНОВЛЕННЫЙ ЦИКЛ
rs.RenderStepped:Connect(function()
    Circle.Position = uis:GetMouseLocation()
    
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = _G.WalkSpeed
    end

    for player, data in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Parent then
            local root = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
            
            -- ЛОГИКА СТРЕЛОЧЕК (Фикс инверсии + Центровка)
            if _G.Arrows_Enabled and not onScreen then
                local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                local diff = (Vector2.new(screenPos.X, screenPos.Y) - center)
                
                if screenPos.Z < 0 then diff = -diff end 
                
                local direction = diff.Unit
                local arrowPos = center + direction * 180 -- Дистанция стрелок от центра
                
                data.arrow.Visible = true
                data.arrow.Position = UDim2.new(0, arrowPos.X, 0, arrowPos.Y)
                data.arrow.Rotation = math.deg(math.atan2(direction.Y, direction.X)) + 90
            else
                data.arrow.Visible = false
            end

            -- ЛОГИКА ESP BOX
            if onScreen and _G.ESP_Enabled then
                local size = (camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.6, 0)).Y)
                data.box.Size = UDim2.new(0, size/1.5, 0, size)
                data.box.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
                data.box.Visible = true
                
                data.txt.Text = player.Name .. " [" .. math.floor((root.Position - camera.CFrame.Position).Magnitude) .. "m]"
                if hum then
                    data.hp.Size = UDim2.new(0, 4, hum.Health/hum.MaxHealth, 0)
                    data.hp.BackgroundColor3 = Color3.fromHSV(hum.Health/100 * 0.3, 1, 1)
                end
            else
                data.box.Visible = false
            end
        else
            data.box.Visible = false
            data.arrow.Visible = false
        end
    end

    -- AIMBOT (Использует _G.FOV из слайдера)
    if _G.Aimbot and uis:IsKeyDown(_G.AimBind) then
        local target = nil
        local closestDist = _G.FOV
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild(_G.AimPart) then
                local pPos, vis = camera:WorldToViewportPoint(p.Character[_G.AimPart].Position)
                if vis then
                    local mag = (Vector2.new(pPos.X, pPos.Y) - uis:GetMouseLocation()).Magnitude
                    if mag < closestDist then 
                        closestDist = mag 
                        target = p.Character[_G.AimPart] 
                    end
                end
            end
        end
        if target then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), _G.Smoothness)
        end
    end
end)

-- Инициализация
for _, p in pairs(game.Players:GetPlayers()) do createVisuals(p) end
game.Players.PlayerAdded:Connect(createVisuals)
