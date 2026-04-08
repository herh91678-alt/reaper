-- [[ BLOXSTRAP V10: GOD OPTIMIZER & HARD LOCK ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TabContainer = Instance.new("ScrollingFrame")
local UIList = Instance.new("UIListLayout")
local CloseBtn = Instance.new("TextButton")
local FOVCircle = Instance.new("Frame")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "BstrapV10"

-- [[ КРУГ АИМА (FOV) ]] --
FOVCircle.Name = "FOVCircle"
FOVCircle.Parent = ScreenGui
FOVCircle.BackgroundColor3 = Color3.new(1, 1, 1)
FOVCircle.BackgroundTransparency = 0.95
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, 150, 0, 150)
FOVCircle.Visible = false
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

-- [[ ГЛАВНОЕ МЕНЮ ]] --
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BackgroundTransparency = 0.5
Main.Position = UDim2.new(0.3, 0, 0.2, 0)
Main.Size = UDim2.new(0, 220, 0, 350)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

CloseBtn.Parent = Main
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

TabContainer.Parent = Main
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 10, 0, 40)
TabContainer.Size = UDim2.new(1, -20, 1, -50)
TabContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
TabContainer.ScrollBarThickness = 0
UIList.Parent = TabContainer
UIList.Padding = UDim.new(0, 5)

local Settings = { Aim = false, ESP = false, FOV = 150, Part = "Head" }

local function CreateBtn(txt, cb)
    local b = Instance.new("TextButton", TabContainer)
    b.Text = txt
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = Color3.new(1,1,1)
    b.BackgroundTransparency = 0.85
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

--- [[ ЯДЕРНЫЙ БУСТЕР + ВЕЧНЫЙ ДЕНЬ ]] ---
local function NuclearClean()
    -- 1. Время и Свет
    local L = game:GetService("Lighting")
    L.ClockTime = 14
    L.GlobalShadows = false
    L.OutdoorAmbient = Color3.new(1, 1, 1)
    for _, v in pairs(L:GetChildren()) do v:Destroy() end
    
    -- 2. Удаление анимаций воды и террейна
    local terr = workspace:FindFirstChildOfClass("Terrain")
    if terr then
        terr.WaterWaveSize = 0
        terr.WaterWaveSpeed = 0
        terr.WaterReflectance = 0
        terr.WaterTransparency = 0
        terr.Decoration = false -- Трава
    end

    -- 3. Удаление частиц, дыма, текстур
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.CastShadow = false
            v.Reflectance = 0
        end
    end
end

CreateBtn("☢️ FULL OPTIMIZE (Day/No VFX)", function()
    NuclearClean()
    -- Цикл фиксации настроек
    task.spawn(function()
        while task.wait(2) do
            game:GetService("Lighting").ClockTime = 14 -- Вечный день
            NuclearClean()
        end
    end)
end)

--- [[ ESP И HARD LOCK ]] ---

CreateBtn("TOGGLE ADVANCED ESP", function() Settings.ESP = not Settings.ESP end)

local aimBtn = CreateBtn("HARD LOCK: OFF", function()
    Settings.Aim = not Settings.Aim
    FOVCircle.Visible = Settings.Aim
end)

CreateBtn("TARGET: HEAD/TORSO", function()
    Settings.Part = (Settings.Part == "Head" and "HumanoidRootPart" or "Head")
end)

-- ГЛАВНЫЙ ЦИКЛ
local lp = game.Players.LocalPlayer
local cam = workspace.CurrentCamera

game:GetService("RunService").RenderStepped:Connect(function()
    -- ESP
    if Settings.ESP then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
                p.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                if not p.Character:FindFirstChild("ESPHighlight") then
                    Instance.new("Highlight", p.Character).Name = "ESPHighlight"
                end
                local head = p.Character.Head
                if not head:FindFirstChild("CustomESP") then
                    local bg = Instance.new("BillboardGui", head)
                    bg.AlwaysOnTop, bg.Name, bg.Size, bg.StudsOffset = true, "CustomESP", UDim2.new(0, 100, 0, 50), Vector3.new(0, 3, 0)
                    local tl = Instance.new("TextLabel", bg)
                    tl.BackgroundTransparency, tl.Size, tl.Font, tl.TextSize, tl.TextColor3 = 1, UDim2.new(1, 0, 1, 0), Enum.Font.GothamBold, 12, Color3.new(1, 1, 1)
                else
                    local hp, dist = math.floor(p.Character.Humanoid.Health), math.floor((lp.Character.HumanoidRootPart.Position - head.Position).Magnitude)
                    head.CustomESP.TextLabel.Text = string.format("%s\n%d HP | %d m", p.Name, hp, dist)
                end
            end
        end
    end

    -- AIM HARD LOCK
    if Settings.Aim then
        aimBtn.Text = "HARD LOCK: ON"
        local target, minDist = nil, Settings.FOV
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild(Settings.Part) and p.Character.Humanoid.Health > 0 then
                local pos, onScreen = cam:WorldToViewportPoint(p.Character[Settings.Part].Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).magnitude
                    if mag < minDist then target = p.Character[Settings.Part] minDist = mag end
                end
            end
        end
        if target then cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position) end
    else
        aimBtn.Text = "HARD LOCK: OFF"
    end
end)
