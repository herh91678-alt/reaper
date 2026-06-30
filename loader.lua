-- [[ hunberg ]] --

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.hunberg_Active = true

local AimEnabled, BHOP_Enabled, HitboxEnabled = false, false, false
local RecallEnabled = true
local SG_Power, FOV_Enabled, FOV_Radius = 35, true, 150

local SelectedTargets = {}
local FlingActive = false
local FlingDirection = "Forward"

getgenv().FPDH = workspace.FallenPartsDestroyHeight

local LastSheriffDeathPos = nil

-- Body Direction
local BodyDirectionEnabled = false
local BodyDirectionMode = "Normal"

-- Hitbox
local HitboxSize = 5

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Thickness, FOV_Circle.Color, FOV_Circle.Transparency = 2, Color3.new(1, 1, 1), 1

local currentHat = nil
local hatOffset = 2.0
local hatColor = Color3.new(1, 0.55, 0)

-- ESP Drawing + роли
local espDrawings = {}

local function UpdateESP()
    for _, d in pairs(espDrawings) do d:Remove() end
    espDrawings = {}

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2,0))
            if onScreen then
                local nameText = Drawing.new("Text")
                nameText.Text = p.Name
                nameText.Position = Vector2.new(pos.X, pos.Y - 25)
                nameText.Size = 17
                nameText.Color = Color3.new(1,1,1)
                nameText.Outline = true
                nameText.Center = true
                table.insert(espDrawings, nameText)

                local role = "Innocent"
                local roleColor = Color3.new(1,1,1)
                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                    role = "MURDERER"
                    roleColor = Color3.new(1,0,0)
                elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                    role = "SHERIFF"
                    roleColor = Color3.new(0,0.6,1)
                end

                local roleText = Drawing.new("Text")
                roleText.Text = role
                roleText.Position = Vector2.new(pos.X, pos.Y - 8)
                roleText.Size = 15
                roleText.Color = roleColor
                roleText.Outline = true
                roleText.Center = true
                table.insert(espDrawings, roleText)
            end
        end
    end
end

RS.Heartbeat:Connect(UpdateESP)

local function GrabGun()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if LastSheriffDeathPos then
        hrp.CFrame = LastSheriffDeathPos
        task.wait(0.15)
    end

    local gunHandle = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Handle" and (v.Parent.Name == "GunDrop" or v.Parent:FindFirstChild("SelectionBox")) then
            gunHandle = v
            break
        end
    end

    if gunHandle then
        local startTime = tick()
        repeat
            if not gunHandle.Parent then break end
            gunHandle.CFrame = hrp.CFrame * CFrame.new(0, 0, -1.5)
            gunHandle.Velocity = Vector3.new(0,0,0)
            task.wait()
        until tick() - startTime > 2.5 or LP.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
    end
end

local function TeleportTo(plr)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp and targetHrp then
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, -3)
    end
end

local function SkidFling(TargetPlayer)
    if TargetPlayer == LP then return end
    local Character = LP.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local TCharacter = TargetPlayer.Character
    local TRootPart = TCharacter and (TCharacter:FindFirstChild("HumanoidRootPart") or TCharacter:FindFirstChild("Head"))
   
    if RootPart and TRootPart and FlingActive then
        local OldCF = RootPart.CFrame
        workspace.FallenPartsDestroyHeight = 0/0
        for _, v in pairs(Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        local BV = Instance.new("BodyVelocity", RootPart)
        BV.Velocity, BV.MaxForce = Vector3.new(0,0,0), Vector3.new(9e9, 9e9, 9e9)
       
        local Time = tick()
        repeat
            if not FlingActive or not TargetPlayer.Parent or not TCharacter.Parent then break end
           
            local offset = CFrame.new(0, 1.5, 0)
            if FlingDirection == "Backward" then offset = CFrame.new(0, 1.5, 3)
            elseif FlingDirection == "Left" then offset = CFrame.new(3, 1.5, 0)
            elseif FlingDirection == "Right" then offset = CFrame.new(-3, 1.5, 0)
            end
            RootPart.CFrame = TRootPart.CFrame * offset
            RootPart.Velocity = Vector3.new(0, 100, 0)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            task.wait()
        until tick() > Time + 1.2
       
        BV:Destroy()
        RootPart.Velocity, RootPart.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0)
        if RecallEnabled then RootPart.CFrame = OldCF end
        task.wait(0.1)
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

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

-- ESP + Hitbox + Sheriff
RS.Heartbeat:Connect(function()
    if not _G.hunberg_Active then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            if (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) and hum.Health <= 0 then
                if p.Character:FindFirstChild("HumanoidRootPart") then
                    LastSheriffDeathPos = p.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            local color = (char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) and Color3.new(1, 0, 0)
                       or (char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) and Color3.new(0, 0.6, 1)
                       or Color3.new(1, 1, 1)
            local high = char:FindFirstChild("D_High") or Instance.new("Highlight", char)
            high.FillColor = color; high.FillTransparency = 0.5
            if head then
                local tag = head:FindFirstChild("D_Tag") or Instance.new("BillboardGui", head)
                tag.Name = "D_Tag"; tag.Adornee = head; tag.Size = UDim2.new(0, 100, 0, 50)
                tag.AlwaysOnTop = true; tag.ExtentsOffset = Vector3.new(0, 3, 0)
                local tl = tag:FindFirstChild("TextLabel") or Instance.new("TextLabel", tag)
                tl.Size = UDim2.new(1, 0, 1, 0); tl.BackgroundTransparency = 1
                tl.Text = p.Name; tl.TextColor3 = color; tl.Font = Enum.Font.SourceSansBold; tl.TextSize = 16
                if HitboxEnabled then
                    head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    head.Transparency = 0.7
                    head.CanCollide = true
                else
                    head.Size = Vector3.new(1.2,1.2,1.2)
                    head.Transparency = 0
                    head.CanCollide = true
                end
            end
        end
    end
    local lpChar = LP.Character
    local hum = lpChar and lpChar:FindFirstChildOfClass("Humanoid")
    local hrp = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    if BHOP_Enabled and hrp and hum and hum.MoveDirection.Magnitude > 0 then
        if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
            hrp.Velocity = Vector3.new(hum.MoveDirection.X * SG_Power, hrp.Velocity.Y, hum.MoveDirection.Z * SG_Power)
        end
    end
end)

-- AIM & FOV
RS.RenderStepped:Connect(function()
    if not _G.hunberg_Active then return end
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

-- BODY DIRECTION
RS.RenderStepped:Connect(function()
    if not BodyDirectionEnabled then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local rot = 0
    if BodyDirectionMode == "Backward" then rot = 180
    elseif BodyDirectionMode == "Left" then rot = 90
    elseif BodyDirectionMode == "Right" then rot = -90
    end
    if rot ~= 0 then
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(rot), 0)
    end
end)

-- Китайская шляпа (с сохранением после смерти)
local hatConnection
local function CreateChineseHat()
    local char = LP.Character
    if not char or not char:FindFirstChild("Head") then return end

    if char:FindFirstChild("ChineseHat") then
        char.ChineseHat:Destroy()
    end

    local hat = Instance.new("Part")
    hat.Name = "ChineseHat"
    hat.Size = Vector3.new(3.6, 0.65, 3.6)
    hat.Shape = Enum.PartType.Block
    hat.Color = hatColor
    hat.Material = Enum.Material.Neon
    hat.Transparency = 0.25
    hat.CanCollide = false
    hat.Anchored = true
    hat.Parent = char

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(2.3, 0.9, 2.3)
    mesh.Parent = hat

    if hatConnection then hatConnection:Disconnect() end
    hatConnection = RS.RenderStepped:Connect(function()
        if not hat.Parent or not char:FindFirstChild("Head") then
            hatConnection:Disconnect()
            return
        end
        hat.CFrame = char.Head.CFrame * CFrame.new(0, hatOffset, 0) * CFrame.Angles(0, 0, 0)
    end)

    currentHat = hat
    print("✅ Приплюснутая шляпа надета!")
end

-- Автоматическое создание шляпы после респавна
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if currentHat then CreateChineseHat() end
end)

-- GUI
local sg = Instance.new("ScreenGui", LP.PlayerGui); sg.Name = "hunberg"; sg.ResetOnSpawn = false
local frame = Instance.new("Frame", sg); frame.Size, frame.Position = UDim2.new(0, 470, 0, 520), UDim2.new(0.5, -235, 0.35, 0)
frame.BackgroundColor3, frame.Active, frame.Draggable = Color3.fromRGB(20, 20, 20), true, true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 30); title.Text = "hunberg"
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
        CreateBtn("HITBOX EXPANDER", 50, function() HitboxEnabled = not HitboxEnabled end)
        CreateBtn("MAGNET KILL", 90, function() DoMagnetKill() end)
        CreateBtn("MAGNET GRAB GUN", 130, function() GrabGun() end)
    elseif name == "Trolling" then
        local scroll = Instance.new("ScrollingFrame", content); scroll.Size, scroll.Position = UDim2.new(0.95, 0, 0, 130), UDim2.new(0.025, 0, 0, 10)
        scroll.CanvasSize, scroll.BackgroundColor3 = UDim2.new(0,0,0,0), Color3.fromRGB(30,30,30)
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)
        local function Refresh()
            for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            for _, p in pairs(Players:GetPlayers()) do if p ~= LP then
                local selected = SelectedTargets[p.Name] ~= nil
                local b = Instance.new("TextButton", scroll)
                b.Size = UDim2.new(1, -10, 0, 25)
                b.Text = (selected and "[X] " or "[ ] ") .. p.Name
                b.BackgroundColor3 = selected and Color3.fromRGB(120,0,0) or Color3.fromRGB(50,50,50)
                b.TextColor3 = Color3.new(1,1,1)
                b.MouseButton1Click:Connect(function()
                    if selected then
                        SelectedTargets[p.Name] = nil
                    else
                        SelectedTargets[p.Name] = p
                    end
                    Refresh()
                end)
            end end
            scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 27)
        end
        Refresh()
        CreateBtn("TELEPORT TO", 150, function()
            for _, p in pairs(SelectedTargets) do TeleportTo(p) end
        end, UDim2.new(0.9, 0, 0, 35))
        CreateBtn("START FLING", 190, function()
            FlingActive = true
            task.spawn(function()
                while FlingActive do
                    for _, p in pairs(SelectedTargets) do
                        if FlingActive then SkidFling(p) end
                    end
                    task.wait(0.4)
                end
            end)
        end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("STOP FLING", 190, function() FlingActive = false end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 190)
        CreateBtn("FLING DIR: " .. FlingDirection, 235, function(b)
            local modes = {"Forward", "Backward", "Left", "Right"}
            local idx = table.find(modes, FlingDirection) or 1
            idx = idx % #modes + 1
            FlingDirection = modes[idx]
            b.Text = "FLING DIR: " .. FlingDirection
        end)
        CreateBtn("RECALL: ON", 275, function(b) RecallEnabled = not RecallEnabled b.Text = "RECALL: "..(RecallEnabled and "ON" or "OFF") end)
    elseif name == "Movement" then
        CreateBtn("AIR-SPEED (Z)", 10, function() BHOP_Enabled = not BHOP_Enabled end)
        local slbl = Instance.new("TextLabel", content); slbl.Size, slbl.Position = UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0,50)
        slbl.Text = "SPEED: "..SG_Power; slbl.TextColor3, slbl.BackgroundTransparency = Color3.new(1,1,1), 1
        CreateBtn("SPEED +5", 85, function() SG_Power = SG_Power + 5 slbl.Text = "SPEED: "..SG_Power end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("SPEED -5", 85, function() SG_Power = math.max(0, SG_Power - 5) slbl.Text = "SPEED: "..SG_Power end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 85)
    elseif name == "Visuals" then
        CreateBtn("SHOW FOV", 10, function() FOV_Enabled = not FOV_Enabled end)
        local flbl = Instance.new("TextLabel", content); flbl.Size, flbl.Position = UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0,50)
        flbl.Text = "FOV: " .. FOV_Radius; flbl.TextColor3, flbl.BackgroundTransparency = Color3.new(1,1,1), 1
        CreateBtn("FOV +20", 85, function() FOV_Radius = FOV_Radius + 20 flbl.Text = "FOV: "..FOV_Radius end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("FOV -20", 85, function() FOV_Radius = math.max(10, FOV_Radius - 20) flbl.Text = "FOV: "..FOV_Radius end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 85)
        CreateBtn("BODY DIR: " .. BodyDirectionMode, 130, function(b)
            local modes = {"Normal", "Backward", "Left", "Right"}
            local idx = table.find(modes, BodyDirectionMode) or 1
            idx = idx % #modes + 1
            BodyDirectionMode = modes[idx]
            b.Text = "BODY DIR: " .. BodyDirectionMode
        end)
        CreateBtn("ENABLE BODY DIR", 170, function(b)
            BodyDirectionEnabled = not BodyDirectionEnabled
            b.Text = "BODY DIR: " .. (BodyDirectionEnabled and "ON" or "OFF")
            b.BackgroundColor3 = BodyDirectionEnabled and Color3.fromRGB(0,100,0) or Color3.fromRGB(40,40,40)
        end)

        -- Китайская шляпа
        CreateBtn("CHINESE HAT", 210, function()
            CreateChineseHat()
        end)

        CreateBtn("↑ ВЫШЕ", 255, function()
            hatOffset = hatOffset + 0.2
            print("Высота: " .. hatOffset)
        end, UDim2.new(0.45, 0, 0, 35))

        CreateBtn("↓ НИЖЕ", 255, function()
            hatOffset = hatOffset - 0.2
            print("Высота: " .. hatOffset)
        end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 255)

        -- Смена цвета шляпы
        CreateBtn("КРАСНЫЙ", 295, function()
            hatColor = Color3.new(1, 0, 0)
            if currentHat then currentHat.Color = hatColor end
        end, UDim2.new(0.45, 0, 0, 35))

        CreateBtn("СИНИЙ", 295, function()
            hatColor = Color3.new(0, 0.6, 1)
            if currentHat then currentHat.Color = hatColor end
        end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 295)

        CreateBtn("ЖЁЛТЫЙ", 335, function()
            hatColor = Color3.new(1, 0.9, 0)
            if currentHat then currentHat.Color = hatColor end
        end, UDim2.new(0.45, 0, 0, 35))

        CreateBtn("РАДУЖНЫЙ", 335, function()
            local connection
            connection = RS.RenderStepped:Connect(function()
                if not currentHat then connection:Disconnect() return end
                hatColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                currentHat.Color = hatColor
            end)
        end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 335)

        local hlbl = Instance.new("TextLabel", content); hlbl.Size, hlbl.Position = UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0,375)
        hlbl.Text = "HITBOX SIZE: " .. HitboxSize; hlbl.TextColor3, hlbl.BackgroundTransparency = Color3.new(1,1,1), 1
        CreateBtn("HITBOX +1", 410, function() HitboxSize = HitboxSize + 1; hlbl.Text = "HITBOX SIZE: " .. HitboxSize end, UDim2.new(0.45, 0, 0, 35))
        CreateBtn("HITBOX -1", 410, function() HitboxSize = math.max(2, HitboxSize - 1); hlbl.Text = "HITBOX SIZE: " .. HitboxSize end, UDim2.new(0.45, 0, 0, 35)).Position = UDim2.new(0.5, 5, 0, 410)
    elseif name == "System" then
        CreateBtn("UNINJECT", 10, function() _G.hunberg_Active = false FOV_Circle:Remove(); sg:Destroy() end)
    end
end

local function Nav(t, y, n)
    local b = Instance.new("TextButton", sidebar); b.Size, b.Position, b.Text = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, y), t
    b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(30,30,30), Color3.new(1,1,1); b.MouseButton1Click:Connect(function() ShowTab(n) end)
end

Nav("Combat", 0, "Combat"); Nav("Trolling", 40, "Trolling"); Nav("Movement", 80, "Movement"); Nav("Visuals", 120, "Visuals"); Nav("System", 160, "System")

ShowTab("Visuals")

print("hunberg loaded")
