-- [[ DIRTANK ULTIMATE ENGINE v61.0 - AIR-SPEED & FOV UPDATE ]] --
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.Dirtank_Active = true
local AimEnabled, BHOP_Enabled, HitboxEnabled = false, false, false
local RecallEnabled = true
local SG_Power, FOV_Enabled, FOV_Radius = 35, true, 150

local SelectedTargets = {}
local FlingActive = false
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- 1. FOV КРУГ
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness, FOV_Circle.Color, FOV_Circle.Transparency = 2, Color3.new(1, 1, 1), 1

-- 2. MAGNET KILL (CLICK)
local function DoMagnetKill()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local knife = char:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
    if not hrp or not knife then return end
    if knife.Parent == LP.Backpack then knife.Parent = char end
    for i = 1, 15 do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -1.2)
                p.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                 knife:Activate()
            end
        end
        hrp.Velocity = Vector3.new(0,0,0)
        task.wait(0.05)
    end
end

-- 3. ESP & TAGS SYSTEM (MAX SPEED UPDATE)
RS.Heartbeat:Connect(function()
    if not _G.Dirtank_Active then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local color = (char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) and Color3.new(1, 0, 0) or (char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) and Color3.new(0, 0.6, 1) or Color3.new(1, 1, 1)
            
            local high = char:FindFirstChild("D_High") or Instance.new("Highlight", char)
            high.Name = "D_High"; high.FillColor = color; high.FillTransparency = 0.5
            
            if head then
                local tag = head:FindFirstChild("D_Tag") or Instance.new("BillboardGui", head)
                tag.Name = "D_Tag"; tag.Adornee = head; tag.Size = UDim2.new(0, 100, 0, 50); tag.AlwaysOnTop = true; tag.ExtentsOffset = Vector3.new(0, 3, 0)
                local tl = tag:FindFirstChild("TextLabel") or Instance.new("TextLabel", tag)
                tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1; tl.Text = p.Name; tl.TextColor3 = color; tl.Font = Enum.Font.SourceSansBold; tl.TextSize = 16
                head.Size = HitboxEnabled and Vector3.new(3,3,3) or Vector3.new(1.2,1.2,1.2)
            end
        end
    end
end)

-- 4. SPEED LOGIC (JUMP ONLY)
RS.Heartbeat:Connect(function()
    if not _G.Dirtank_Active or not BHOP_Enabled or FlingActive then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        -- ПРОВЕРКА: Если игрок в воздухе (FloorMaterial == Air)
        if hum.FloorMaterial == Enum.Material.Air then
            local vel = hum.MoveDirection * SG_Power
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
        end
    end
end)

-- 5. AIM & FOV DRAWING
RS.RenderStepped:Connect(function()
    if not _G.Dirtank_Active then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOV_Circle.Position, FOV_Circle.Radius, FOV_Circle.Visible = center, FOV_Radius, FOV_Enabled
    
    if AimEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
                local head = p.Character:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen and (Vector2.new(pos.X, pos.Y) - center).Magnitude < FOV_Radius then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    end
                end
            end
        end
    end
end)

-- 6. FLING
local function SkidFling(TargetPlayer)
    local Character = LP.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local TCharacter = TargetPlayer.Character
    local TRootPart = TCharacter and (TCharacter:FindFirstChild("HumanoidRootPart") or TCharacter:FindFirstChild("Head"))
    if RootPart and TRootPart and FlingActive then
        local OldCF = RootPart.CFrame
        workspace.FallenPartsDestroyHeight = 0/0
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
        RootPart.Velocity, RootPart.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0)
        if RecallEnabled then RootPart.CFrame = OldCF end
        task.wait(0.1)
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

-- 7. GUI (DIRTANK ULTIMATE)
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "DirtankV60"; sg.ResetOnSpawn = false
local frame = Instance.new("Frame", sg); frame.Size, frame.Position = UDim2.new(0, 450, 0, 320), UDim2.new(0.5, -225, 0.4, 0)
frame.BackgroundColor3, frame.Active, frame.Draggable = Color3.fromRGB(20, 20, 20), true, true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 30); title.Text = "DIRTANK ULTIMATE v61.0"
title.TextColor3, title.BackgroundTransparency = Color3.new(1,1,1), 1; title.Font = Enum.Font.SourceSansBold; title.TextSize = 18

local sidebar = Instance.new("Frame", frame); sidebar.Size, sidebar.Position = UDim2.new(0, 100, 1, -30), UDim2.new(0, 0, 0, 30); sidebar.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
local content = Instance.new("Frame", frame); content.Position, content.Size = UDim2.new(0, 105, 0, 30), UDim2.new(1, -105, 1, -30); content.BackgroundTransparency = 1

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
        CreateBtn("MAGNET KILL (CLICK)", 90, function() DoMagnetKill() end)
    elseif name == "Fling" then
        local scroll = Instance.new("ScrollingFrame", content); scroll.Size, scroll.Position = UDim2.new(0.95, 0, 0, 10), UDim2.new(0.025, 0, 0, 10)
        scroll.CanvasSize, scroll.BackgroundColor3, scroll.Size = UDim2.new(0,0,0,0), Color3.fromRGB(30,30,30), UDim2.new(0.95, 0, 0, 130)
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)
        local function Refresh()
            for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, p in pairs(Players:GetPlayers()) do if p ~= LP then
                local b = Instance.new("TextButton", scroll); b.Size, b.Text = UDim2.new(1, -10, 0, 25), (SelectedTargets[p.Name] and "[X] " or "[ ] ") .. p.Name
                b.BackgroundColor3 = SelectedTargets[p.Name] and Color3.fromRGB(100,0,0) or Color3.fromRGB(50,50,50); b.TextColor3 = Color3.new(1,1,1)
                b.MouseButton1Click:Connect(function() if SelectedTargets[p.Name] then SelectedTargets[p.Name] = nil else SelectedTargets[p.Name] = p end Refresh() end)
            end end
            scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 27)
        end
        Refresh()
        CreateBtn("START FLING", 150, function() FlingActive = true task.spawn(function() while FlingActive do for _, p in pairs(SelectedTargets) do if FlingActive then SkidFling(p) end end task.wait(0.5) end end) end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("STOP", 150, function() FlingActive = false end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 150)
        CreateBtn("RECALL: ON", 195, function(b) RecallEnabled = not RecallEnabled b.Text = "RECALL: "..(RecallEnabled and "ON" or "OFF") end)
    elseif name == "Movement" then
        CreateBtn("AIR-SPEED (Z)", 10, function() BHOP_Enabled = not BHOP_Enabled end)
        local slbl = Instance.new("TextLabel", content); slbl.Size, slbl.Position = UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0,50)
        slbl.Text, slbl.TextColor3, slbl.BackgroundTransparency = "CURRENT SPEED: " .. SG_Power, Color3.new(1,1,1), 1
        CreateBtn("SPEED +5", 85, function() SG_Power = SG_Power + 5 slbl.Text = "CURRENT SPEED: "..SG_Power end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("SPEED -5", 85, function() SG_Power = math.max(0, SG_Power - 5) slbl.Text = "CURRENT SPEED: "..SG_Power end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 85)
    elseif name == "Visuals" then
        CreateBtn("SHOW FOV", 10, function() FOV_Enabled = not FOV_Enabled end)
        local flbl = Instance.new("TextLabel", content); flbl.Size, flbl.Position = UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0,50)
        flbl.Text, flbl.TextColor3, flbl.BackgroundTransparency = "FOV RADIUS: " .. FOV_Radius, Color3.new(1,1,1), 1
        CreateBtn("FOV +20", 85, function() FOV_Radius = FOV_Radius + 20 flbl.Text = "FOV RADIUS: "..FOV_Radius end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("FOV -20", 85, function() FOV_Radius = math.max(10, FOV_Radius - 20) flbl.Text = "FOV RADIUS: "..FOV_Radius end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 85)
    elseif name == "System" then
        CreateBtn("UNINJECT", 10, function() _G.Dirtank_Active = false FOV_Circle:Remove(); sg:Destroy() end)
    end
end

local function Nav(t, y, n)
    local b = Instance.new("TextButton", sidebar); b.Size, b.Position, b.Text = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, y), t
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,30), Color3.new(1,1,1); b.MouseButton1Click:Connect(function() ShowTab(n) end)
end
Nav("Combat", 0, "Combat"); Nav("Fling", 40, "Fling"); Nav("Movement", 80, "Movement"); Nav("Visuals", 120, "Visuals"); Nav("System", 160, "System")
ShowTab("Combat")

UIS.InputBegan:Connect(function(i, p) if not p then if i.KeyCode == Enum.KeyCode.Q then AimEnabled = not AimEnabled elseif i.KeyCode == Enum.KeyCode.Z then BHOP_Enabled = not BHOP_Enabled end end end)

task.spawn(function()
    while task.wait(0.1) do
        if content:FindFirstChild("TextButton") then
            for _, b in pairs(content:GetChildren()) do
                if b.Text:find("AIM") then b.Text = "AIM (Q): "..(AimEnabled and "ON" or "OFF") end
                if b.Text:find("AIR-SPEED") then b.Text = "AIR-SPEED (Z): "..(BHOP_Enabled and "ON" or "OFF") end
                if b.Text:find("HITBOX") then b.Text = "HITBOX: "..(HitboxEnabled and "ON" or "OFF") end
            end
        end
    end
end)
