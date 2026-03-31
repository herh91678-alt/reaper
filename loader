-- [[ DIRTANK ULTIMATE ENGINE v60 - HOTKEYS + INSTANT ESP ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

_G.Dirtank_Active = true
local AimEnabled = false 
local BHOP_Enabled = false
local HitboxEnabled = false
local SG_Power = 25
local FOV_Enabled = true
local FOV_Radius = 150
local MenuVisible = true

-- 1. FOV КРУГ
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness = 2
FOV_Circle.Color = Color3.new(1, 1, 1)

-- 2. ГАРАНТИРОВАННЫЙ ФИЗИЧЕСКИЙ СПИД
RS.Heartbeat:Connect(function()
    if not _G.Dirtank_Active or not BHOP_Enabled then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.FloorMaterial == Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
        local force = hum.MoveDirection * SG_Power
        hrp.AssemblyLinearVelocity = Vector3.new(force.X, hrp.AssemblyLinearVelocity.Y, force.Z)
    end
end)

-- 3. МГНОВЕННОЕ ESP (ОБНОВЛЕНИЕ КАЖДЫЙ КАДР)
local function UpdateESP()
    if not _G.Dirtank_Active then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            -- NameTags
            local bbg = char:FindFirstChild("D_Tag") or Instance.new("BillboardGui", char)
            if bbg.Name ~= "D_Tag" then
                bbg.Name = "D_Tag"; bbg.AlwaysOnTop = true; bbg.Size = UDim2.new(0, 200, 0, 50); bbg.ExtentsOffset = Vector3.new(0, 3, 0)
                local lbl = Instance.new("TextLabel", bbg)
                lbl.Name = "L"; lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.TextSize = 24; lbl.Font = Enum.Font.SourceSansBold; lbl.TextStrokeTransparency = 0
            end
            
            local role, color = "Innocent", Color3.new(1, 1, 1)
            if p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife") then role, color = "MURDERER 💀", Color3.new(1, 0, 0)
            elseif p.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun") then role, color = "SHERIFF ⚖️", Color3.new(0, 0.6, 1) end
            
            local lbl = bbg:FindFirstChild("L")
            if lbl then lbl.Text = p.Name .. "\n[" .. role .. "]"; lbl.TextColor3 = color end
            
            -- Highlight
            local high = char:FindFirstChild("D_High") or Instance.new("Highlight", char)
            high.Name = "D_High"; high.FillColor = color; high.FillTransparency = 0.5; high.OutlineTransparency = 0
        end
    end
end
RS.RenderStepped:Connect(UpdateESP) -- ОБНОВЛЕНИЕ 0.000001 сек (каждый кадр)

-- 4. АИМ, ХИТБОКСЫ И ГРАББЕР
RS.RenderStepped:Connect(function()
    if not _G.Dirtank_Active then return end
    FOV_Circle.Position = workspace.CurrentCamera.ViewportSize / 2
    FOV_Circle.Radius = FOV_Radius; FOV_Circle.Visible = FOV_Enabled
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            p.Character.Head.Size = HitboxEnabled and Vector3.new(3,3,3) or Vector3.new(1.2,1.2,1.2)
            if AimEnabled and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
                local mag = (Vector2.new(pos.X, pos.Y) - FOV_Circle.Position).Magnitude
                if onScreen and mag < FOV_Radius then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, p.Character.Head.Position)
                    local gun = LP.Character:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
                    if gun and gun.Parent == LP.Character then gun:Activate() end
                end
            end
        end
    end
end)

-- 5. БИНДЫ (Q - АИМ, Z - СПИДЫ)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Q then
        AimEnabled = not AimEnabled
    elseif input.KeyCode == Enum.KeyCode.Z then
        BHOP_Enabled = not BHOP_Enabled
    end
end)

-- 6. ИНТЕРФЕЙС
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "DirtankV60"; sg.ResetOnSpawn = false
local frame = Instance.new("Frame", sg); frame.Size, frame.Position = UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.4, 0)
frame.BackgroundColor3, frame.Active, frame.Draggable = Color3.fromRGB(20, 20, 20), true, true

local sidebar = Instance.new("Frame", frame); sidebar.Size, sidebar.BackgroundColor3 = UDim2.new(0, 100, 1, 0), Color3.fromRGB(60, 0, 0)
local content = Instance.new("Frame", frame); content.Position, content.Size = UDim2.new(0, 105, 0, 0), UDim2.new(1, -105, 1, 0); content.BackgroundTransparency = 1

local function CreateBtn(t, y, f, s)
    local b = Instance.new("TextButton", content); b.Size = s or UDim2.new(0.9, 0, 0, 30); b.Position = UDim2.new(0.05, 0, 0, y)
    b.Text, b.BackgroundColor3, b.TextColor3 = t, Color3.fromRGB(40,40,40), Color3.new(1,1,1); b.Font = Enum.Font.SourceSansBold
    b.MouseButton1Click:Connect(function() f(b) end); return b
end

local function ShowTab(name)
    for _, v in pairs(content:GetChildren()) do v:Destroy() end
    if name == "Combat" then
        CreateBtn("AIM (Q): "..(AimEnabled and "ON" or "OFF"), 10, function(b) AimEnabled = not AimEnabled end)
        CreateBtn("HITBOX: "..(HitboxEnabled and "ON" or "OFF"), 45, function(b) HitboxEnabled = not HitboxEnabled end)
        CreateBtn("INSTANT MAGNET", 80, function()
            local k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k then k.Parent = LP.Character; for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character then p.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.2) end end
            for i=1,10 do k:Activate() task.wait(0.05) end end
        end)
    elseif name == "Movement" then
        CreateBtn("BHOP (Z): "..(BHOP_Enabled and "ON" or "OFF"), 10, function(b) BHOP_Enabled = not BHOP_Enabled end)
        local l = Instance.new("TextLabel", content); l.Size, l.Position, l.Text = UDim2.new(0.9,0,0,20), UDim2.new(0.05,0,0,45), "SPEED: "..SG_Power; l.TextColor3, l.BackgroundTransparency = Color3.new(1,1,1), 1
        CreateBtn("+", 70, function() SG_Power += 5 l.Text = "SPEED: "..SG_Power end, UDim2.new(0.4, 0, 0, 30))
        CreateBtn("-", 70, function() SG_Power = math.max(16, SG_Power - 5) l.Text = "SPEED: "..SG_Power end, UDim2.new(0.4, 0, 0, 30)).Position = UDim2.new(0.55,0,0,70)
    elseif name == "Visuals" then
        CreateBtn("SHOW FOV: "..(FOV_Enabled and "ON" or "OFF"), 10, function(b) FOV_Enabled = not FOV_Enabled end)
        CreateBtn("FOV +", 45, function() FOV_Radius += 20 end, UDim2.new(0.4,0,0,30))
        CreateBtn("FOV -", 45, function() FOV_Radius = math.max(10, FOV_Radius - 20) end, UDim2.new(0.4,0,0,30)).Position = UDim2.new(0.55,0,0,45)
    elseif name == "System" then
        CreateBtn("UNINJECT", 10, function() _G.Dirtank_Active = false FOV_Circle:Remove() sg:Destroy() end)
        CreateBtn("REJOIN", 45, function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
    end
end

-- Навигация
local function Nav(t, y, n)
    local b = Instance.new("TextButton", sidebar); b.Size, b.Position, b.Text = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, y), t
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,30), Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() ShowTab(n) end)
end
Nav("Combat", 0, "Combat"); Nav("Movement", 40, "Movement"); Nav("Visuals", 80, "Visuals"); Nav("System", 120, "System")
ShowTab("Combat")

-- Авто-обновление текста кнопок в меню
task.spawn(function()
    while task.wait(0.1) do
        if content:FindFirstChild("TextButton") then
            for _, b in pairs(content:GetChildren()) do
                if b.Text:find("AIM") then b.Text = "AIM (Q): "..(AimEnabled and "ON" or "OFF") end
                if b.Text:find("BHOP") then b.Text = "BHOP (Z): "..(BHOP_Enabled and "ON" or "OFF") end
            end
        end
    end
end)
