-- [[ DIRTANK ULTIMATE ENGINE v60.5 - NO TRIGGER & RECALL TOGGLE ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.Dirtank_Active = true
local AimEnabled, BHOP_Enabled, HitboxEnabled = false, false, false
local RecallEnabled = true -- Переключатель возврата
local SG_Power, FOV_Enabled, FOV_Radius = 35, true, 150

-- Переменные для Флинга
local FlingActive = false
local SelectedTargets = {}
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- 1. FOV КРУГ
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness, FOV_Circle.Color, FOV_Circle.Transparency = 2, Color3.new(1, 1, 1), 1

-- 2. СИСТЕМА ДВИЖЕНИЯ (SPEED)
RS.Heartbeat:Connect(function()
    if not _G.Dirtank_Active or not BHOP_Enabled or FlingActive then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        local vel = hum.MoveDirection * SG_Power
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
    end
end)

-- 3. ФУНКЦИЯ ФЛИНГА (С ПЕРЕКЛЮЧАТЕЛЕМ ВОЗВРАТА)
local function SkidFling(TargetPlayer)
    local Character = LP.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local TCharacter = TargetPlayer.Character
    local TRootPart = TCharacter and (TCharacter:FindFirstChild("HumanoidRootPart") or TCharacter:FindFirstChild("Head"))
    
    if RootPart and TRootPart and FlingActive then
        local OldCF = RootPart.CFrame -- Запоминаем позицию на случай Recall
        workspace.FallenPartsDestroyHeight = 0/0
        
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end

        local BV = Instance.new("BodyVelocity", RootPart)
        BV.Velocity, BV.MaxForce = Vector3.new(0,0,0), Vector3.new(9e9, 9e9, 9e9)
        
        local Time = tick()
        repeat
            if not FlingActive or not TargetPlayer.Parent or not TCharacter.Parent then break end
            RootPart.CFrame = TRootPart.CFrame * CFrame.new(0, 1.5, 0)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            task.wait()
        until tick() > Time + 1.1 
        
        BV:Destroy()
        RootPart.Velocity = Vector3.new(0,0,0)
        RootPart.RotVelocity = Vector3.new(0,0,0)
        
        -- ВОЗВРАТ ТОЛЬКО ЕСЛИ ВКЛЮЧЕНО
        if RecallEnabled then
            RootPart.CFrame = OldCF
        end
        
        task.wait(0.1)
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

-- 4. ОБРАБОТКА АИМА И ЦЕНТРА FOV
RS.RenderStepped:Connect(function()
    if not _G.Dirtank_Active then return end
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FOV_Circle.Position, FOV_Circle.Radius, FOV_Circle.Visible = center, FOV_Radius, FOV_Enabled
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            p.Character.Head.Size = HitboxEnabled and Vector3.new(3,3,3) or Vector3.new(1.2,1.2,1.2)
            
            if AimEnabled and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen and (Vector2.new(pos.X, pos.Y) - center).Magnitude < FOV_Radius then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Character.Head.Position)
                    local gun = LP.Character:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
                    if gun and gun.Parent == LP.Character then gun:Activate() end
                end
            end
        end
    end
end)

-- 5. ESP
RS.RenderStepped:Connect(function()
    if not _G.Dirtank_Active then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local color = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) and Color3.new(1,0,0) or (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) and Color3.new(0,0.6,1) or Color3.new(1,1,1)
            local high = p.Character:FindFirstChild("D_High") or Instance.new("Highlight", p.Character)
            high.Name = "D_High"; high.FillColor = color; high.FillTransparency = 0.5
        end
    end
end)

-- 6. ИНТЕРФЕЙС
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "DirtankV60"; sg.ResetOnSpawn = false
local frame = Instance.new("Frame", sg); frame.Size, frame.Position = UDim2.new(0, 450, 0, 320), UDim2.new(0.5, -225, 0.4, 0)
frame.BackgroundColor3, frame.Active, frame.Draggable = Color3.fromRGB(20, 20, 20), true, true
Instance.new("UICorner", frame)

local sidebar = Instance.new("Frame", frame); sidebar.Size, sidebar.BackgroundColor3 = UDim2.new(0, 100, 1, 0), Color3.fromRGB(60, 0, 0)
local content = Instance.new("Frame", frame); content.Position, content.Size = UDim2.new(0, 105, 0, 0), UDim2.new(1, -105, 1, 0); content.BackgroundTransparency = 1

local function CreateBtn(t, y, f, s, parent)
    local b = Instance.new("TextButton", parent or content); b.Size = s or UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text, b.BackgroundColor3, b.TextColor3 = t, Color3.fromRGB(40,40,40), Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold
    b.MouseButton1Click:Connect(function() f(b) end); return b
end

local function ShowTab(name)
    for _, v in pairs(content:GetChildren()) do v:Destroy() end
    if name == "Combat" then
        CreateBtn("AIM (Q)", 10, function() AimEnabled = not AimEnabled end)
        CreateBtn("HITBOX", 50, function() HitboxEnabled = not HitboxEnabled end)
    elseif name == "Fling" then
        local scroll = Instance.new("ScrollingFrame", content); scroll.Size, scroll.Position = UDim2.new(0.95, 0, 0, 10), UDim2.new(0.025, 0, 0, 10)
        scroll.CanvasSize, scroll.BackgroundColor3, scroll.Size = UDim2.new(0,0,0,0), Color3.fromRGB(30,30,30), UDim2.new(0.95, 0, 0, 130)
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)
        local function Refresh()
            for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP then
                    local b = Instance.new("TextButton", scroll); b.Size, b.Text = UDim2.new(1, -10, 0, 25), (SelectedTargets[p.Name] and "[X] " or "[ ] ") .. p.Name
                    b.BackgroundColor3 = SelectedTargets[p.Name] and Color3.fromRGB(100,0,0) or Color3.fromRGB(50,50,50); b.TextColor3 = Color3.new(1,1,1)
                    b.MouseButton1Click:Connect(function() if SelectedTargets[p.Name] then SelectedTargets[p.Name] = nil else SelectedTargets[p.Name] = p end Refresh() end)
                end
            end
            scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 27)
        end
        Refresh()
        CreateBtn("START FLING", 150, function() FlingActive = true task.spawn(function() while FlingActive do for _, p in pairs(SelectedTargets) do if FlingActive then SkidFling(p) end end task.wait(0.5) end end) end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("STOP", 150, function() FlingActive = false end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 150)
        
        CreateBtn("RECALL AFTER FLING", 195, function() RecallEnabled = not RecallEnabled end)
        
        CreateBtn("SELECT ALL", 240, function() for _, p in pairs(Players:GetPlayers()) do if p ~= LP then SelectedTargets[p.Name] = p end end Refresh() end, UDim2.new(0.45, 0, 0, 30))
        CreateBtn("CLEAR", 240, function() SelectedTargets = {} Refresh() end, UDim2.new(0.45, 0, 0, 30)).Position = UDim2.new(0.5, 5, 0, 240)
    elseif name == "Movement" then
        CreateBtn("SPEED (Z)", 10, function() BHOP_Enabled = not BHOP_Enabled end)
        CreateBtn("POWER +", 50, function() SG_Power += 5 end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("POWER -", 50, function() SG_Power -= 5 end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 50)
    elseif name == "Visuals" then
        CreateBtn("SHOW FOV", 10, function() FOV_Enabled = not FOV_Enabled end)
        CreateBtn("FOV +", 50, function() FOV_Radius += 20 end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("FOV -", 50, function() FOV_Radius -= 20 end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 50)
    elseif name == "System" then
        CreateBtn("UNINJECT", 10, function() _G.Dirtank_Active = false FOV_Circle:Remove(); sg:Destroy() end)
    end
end

local function Nav(t, y, n)
    local b = Instance.new("TextButton", sidebar); b.Size, b.Position, b.Text = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, y), t
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,30), Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() ShowTab(n) end)
end
Nav("Combat", 0, "Combat"); Nav("Fling", 40, "Fling"); Nav("Movement", 80, "Movement"); Nav("Visuals", 120, "Visuals"); Nav("System", 160, "System")
ShowTab("Combat")

UIS.InputBegan:Connect(function(i, p) if not p then if i.KeyCode == Enum.KeyCode.Q then AimEnabled = not AimEnabled elseif i.KeyCode == Enum.KeyCode.Z then BHOP_Enabled = not BHOP_Enabled end end end)

task.spawn(function()
    while task.wait(0.1) do
        if content:FindFirstChild("TextButton") then
            for _, b in pairs(content:GetChildren()) do
                if b.Text:find("AIM") then b.Text = "AIM (Q): "..(AimEnabled and "ON" or "OFF") end
                if b.Text:find("RECALL") then b.Text = "RECALL: "..(RecallEnabled and "ON" or "OFF") end
                if b.Text:find("SPEED") then b.Text = "SPEED (Z): "..(BHOP_Enabled and "ON" or "OFF") end
                if b.Text:find("SHOW FOV") then b.Text = "SHOW FOV: "..(FOV_Enabled and "ON" or "OFF") end
                if b.Text:find("HITBOX") then b.Text = "HITBOX: "..(HitboxEnabled and "ON" or "OFF") end
            end
        end
    end
end)
