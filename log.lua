-- [[ PREMIUM HUB V13.0: AUTO-SKIP, SMART DETECT & COOLDOWN NOTIF ]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local ScriptActive = true

-- Настройки по умолчанию
local WALK_SPEED = 50
local SpeedEnabled = true
local EspEnabled = true
local AutoRollEnabled = false

-- Флаги паузы, радара и защиты
local AutoRollPaused = false 
local LastNotifiedText = ""
local DetectedEggModel = nil 

-- Защита от спама и авто-скип
local NotifActive = false -- Флаг: висит ли сейчас уведомление на экране
local SameEggCounter = 0 -- Счетчик повторов для одного и того же текста

local SelectedRarities = {} 
local SelectedMutations = {}
local TargetedPart = nil 
local BindingMode = 0 

local RarityColors = {
    common = Color3.fromRGB(200, 200, 200),
    rare = Color3.fromRGB(0, 150, 255),
    epic = Color3.fromRGB(150, 0, 255),
    legendary = Color3.fromRGB(255, 150, 0),
    mythic = Color3.fromRGB(255, 0, 50),
    secret = Color3.fromRGB(255, 0, 255)
}

local AvailableRarities = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
local AvailableMutations = {"Shiny", "Golden", "Rainbow", "Diamond", "Galactic", "Cosmic", "Corrupt"}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateAutomationHubV13"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Контейнер для уведомлений
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 300, 1, -40)
NotifContainer.Position = UDim2.new(1, -310, 0, 20)
NotifContainer.BackgroundTransparency = 1
local NotifList = Instance.new("UIListLayout", NotifContainer)
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Padding = UDim.new(0, 10)

-- Уведомление с жестким КД на 3 секунды
local function SendNotification(title, message)
    if NotifActive then return end -- Если старая плашка еще не ушла, новую не спавним
    NotifActive = true

    local Box = Instance.new("Frame", NotifContainer)
    Box.Size = UDim2.new(1, 0, 0, 75)
    Box.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Box.BorderSizePixel = 0
    Box.Position = UDim2.new(1.5, 0, 0, 0)
    Box.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner", Box)
    Corner.CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Color = Color3.fromRGB(255, 0, 128)
    Stroke.Thickness = 1
    
    local NeonBar = Instance.new("Frame", Box)
    NeonBar.Size = UDim2.new(0, 5, 1, 0)
    NeonBar.BackgroundColor3 = Color3.fromRGB(255, 0, 128)
    Instance.new("UICorner", NeonBar).CornerRadius = UDim.new(0, 10)
    
    local TxtTitle = Instance.new("TextLabel", Box)
    TxtTitle.Size = UDim2.new(1, -20, 0, 25)
    TxtTitle.Position = UDim2.new(0, 15, 0, 6)
    TxtTitle.BackgroundTransparency = 1
    TxtTitle.Text = title:upper()
    TxtTitle.TextColor3 = Color3.fromRGB(255, 0, 128)
    TxtTitle.Font = Enum.Font.GothamBold
    TxtTitle.TextSize = 13
    TxtTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local TxtMsg = Instance.new("TextLabel", Box)
    TxtMsg.Size = UDim2.new(1, -20, 0, 32)
    TxtMsg.Position = UDim2.new(0, 15, 0, 28)
    TxtMsg.BackgroundTransparency = 1
    TxtMsg.Text = message
    TxtMsg.TextColor3 = Color3.fromRGB(240, 240, 240)
    TxtMsg.Font = Enum.Font.GothamMedium
    TxtMsg.TextSize = 12
    TxtMsg.TextWrapped = true
    TxtMsg.TextXAlignment = Enum.TextXAlignment.Left

    local ProgressBarBackground = Instance.new("Frame", Box)
    ProgressBarBackground.Size = UDim2.new(1, -20, 0, 4)
    ProgressBarBackground.Position = UDim2.new(0, 15, 1, -8)
    ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    ProgressBarBackground.BorderSizePixel = 0
    Instance.new("UICorner", ProgressBarBackground).CornerRadius = UDim.new(0, 2)

    local ProgressBar = Instance.new("Frame", ProgressBarBackground)
    ProgressBar.Size = UDim2.new(1, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 0, 128)
    ProgressBar.BorderSizePixel = 0
    Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(0, 2)

    Box:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.4, true)
    
    local TimeToLive = 3
    TweenService:Create(ProgressBar, TweenInfo.new(TimeToLive, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    
    task.delay(TimeToLive, function()
        if Box then
            pcall(function()
                Box:TweenPosition(UDim2.new(1.5, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
                    Box:Destroy()
                    NotifActive = false -- Сбрасываем КД, теперь можно слать следующее нотифи
                end)
            end)
        else
            NotifActive = false
        end
    end)
end

-- Главное меню
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.4, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Size = UDim2.new(0, 520, 0, 380)

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 0, 128)
UIStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = "  EGG HUB v13.0 [AUTO-SKIP & SMART DETECT]  "
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 14)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 120, 0, 40)
OpenBtn.Position = UDim2.new(0, 20, 0, 20)
OpenBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
OpenBtn.Text = "OPEN MENU"
OpenBtn.TextColor3 = Color3.fromRGB(255, 0, 128)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 13
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(255, 0, 128)

local TabPanel = Instance.new("Frame", MainFrame)
TabPanel.Size = UDim2.new(0, 140, 1, -50)
TabPanel.Position = UDim2.new(0, 10, 0, 45)
TabPanel.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabPanel)
TabList.Padding = UDim.new(0, 6)

local MainContent = Instance.new("Frame", MainFrame)
MainContent.Size = UDim2.new(1, -170, 1, -50)
MainContent.Position = UDim2.new(0, 160, 0, 45)
MainContent.BackgroundTransparency = 1

local Pages = {}
local function createPage()
    local Page = Instance.new("ScrollingFrame", MainContent)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 1.8, 0)
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 128)
    Page.Visible = false
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)
    return Page
end

Pages.Main = createPage()
Pages.Roll = createPage()
Pages.Mutations = createPage()
Pages.Main.Visible = true

local function createTabButton(name, targetPage)
    local TabBtn = Instance.new("TextButton", TabPanel)
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    TabBtn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        for _, p in pairs(Pages) do p.Visible = false end
        targetPage.Visible = true
    end)
end

createTabButton("⚡ Main Cheats", Pages.Main)
createTabButton("🥚 Auto-Roll Stop", Pages.Roll)
createTabButton("🧬 Mutations Stop", Pages.Mutations)

local function createToggle(name, default, parentPage, callback)
    local Row = Instance.new("Frame", parentPage)
    Row.Size = UDim2.new(1, -10, 0, 38)
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleBtn = Instance.new("TextButton", Row)
    ToggleBtn.Size = UDim2.new(0, 45, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -55, 0.5, -11)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 0, 128) or Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 9
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        state = not state
        local targetColor = state and Color3.fromRGB(255, 0, 128) or Color3.fromRGB(50, 50, 60)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        ToggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

createToggle("Visual ESP (Eggs)", true, Pages.Main, function(val) EspEnabled = val end)
createToggle("⚡ ВКЛЮЧИТЬ АВТО-РОЛЛ", false, Pages.Main, function(val) AutoRollEnabled = val end)

local RollBindBtn = Instance.new("TextButton", Pages.Main)
RollBindBtn.Size = UDim2.new(1, -10, 0, 38)
RollBindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
RollBindBtn.Text = "🎯 Привязать КНОПКУ ЛЕНТЫ кликом"
RollBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RollBindBtn.Font = Enum.Font.GothamBold
RollBindBtn.TextSize = 12
Instance.new("UICorner", RollBindBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", RollBindBtn).Color = Color3.fromRGB(0, 255, 150)

RollBindBtn.MouseButton1Click:Connect(function()
    if not ScriptActive then return end
    BindingMode = 1
    RollBindBtn.Text = "КЛИКНИ ПО ПАРТУ КНОПКИ/ЛЕНТЫ..."
    RollBindBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
end)

Mouse.Button1Down:Connect(function()
    if not ScriptActive or BindingMode == 0 then return end
    local target = Mouse.Target
    if target and target:IsA("BasePart") then
        if BindingMode == 1 then
            TargetedPart = target
            RollBindBtn.Text = "✓ БАЗА ПРИВЯЗАНА: " .. string.upper(target.Name)
            RollBindBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        end
        BindingMode = 0
    end
end)

local function createSpeedControl(parentPage)
    local Row = Instance.new("Frame", parentPage)
    Row.Size = UDim2.new(1, -10, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Speed Power"
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local ValueLabel = Instance.new("TextLabel", Row)
    ValueLabel.Size = UDim2.new(0, 45, 0, 24)
    ValueLabel.Position = UDim2.new(0.45, 0, 0.5, -12)
    ValueLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    ValueLabel.Text = tostring(WALK_SPEED)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 0, 128)
    ValueLabel.Font = Enum.Font.GothamBold
    Instance.new("UICorner", ValueLabel).CornerRadius = UDim.new(0, 5)
    local M = Instance.new("TextButton", Row)
    M.Size = UDim2.new(0, 24, 0, 24)
    M.Position = UDim2.new(1, -75, 0.5, -12)
    M.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    M.Text = "-"
    M.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", M).CornerRadius = UDim.new(0, 5)
    local P = Instance.new("TextButton", Row)
    P.Size = UDim2.new(0, 24, 0, 24)
    P.Position = UDim2.new(1, -35, 0.5, -12)
    P.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    P.Text = "+"
    P.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", P).CornerRadius = UDim.new(0, 5)
    M.MouseButton1Click:Connect(function() if WALK_SPEED > 16 then WALK_SPEED = WALK_SPEED - 5 ValueLabel.Text = tostring(WALK_SPEED) end end)
    P.MouseButton1Click:Connect(function() if WALK_SPEED < 250 then WALK_SPEED = WALK_SPEED + 5 ValueLabel.Text = tostring(WALK_SPEED) end end)
end
createSpeedControl(Pages.Main)

local function createSelector(name, tbl, parentPage)
    local Row = Instance.new("Frame", parentPage)
    Row.Size = UDim2.new(1, -10, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "🛑 Пауза на: " .. name
    Label.TextColor3 = RarityColors[name:lower()] or Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Check = Instance.new("TextButton", Row)
    Check.Size = UDim2.new(0, 20, 0, 20)
    Check.Position = UDim2.new(1, -35, 0.5, -10)
    Check.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Check.Text = ""
    Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 4)

    local isSelected = false
    Check.MouseButton1Click:Connect(function()
        if not ScriptActive then return end
        isSelected = not isSelected
        if isSelected then
            Check.BackgroundColor3 = Color3.fromRGB(255, 0, 128)
            Check.Text = "✓"
            tbl[name:lower()] = true
        else
            Check.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Check.Text = ""
            tbl[name:lower()] = nil
        end
    end)
end

for _, rarity in ipairs(AvailableRarities) do createSelector(rarity, SelectedRarities, Pages.Roll) end
for _, mut in ipairs(AvailableMutations) do createSelector(mut, SelectedMutations, Pages.Mutations) end


-- [[ УМНЫЙ МОНИТОРИНГ: АВТО-СКИП, ФИКСЫ И ЧЕТКИЕ СТОПЫ ]]
task.spawn(function()
    while task.wait(0.05) do
        if not ScriptActive then break end
        
        if AutoRollEnabled then
            local matchFound = false
            local detectedName = ""
            
            -- Четкое сканирование UI на совпадение с выбранными галочками в меню
            pcall(function()
                for _, guiObj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if guiObj:IsA("TextLabel") and guiObj.Visible and guiObj.Text ~= "" and not guiObj:IsDescendantOf(ScreenGui) then
                        local tLower = guiObj.Text:lower()
                        
                        -- Проверяем редкости
                        for r, _ in pairs(SelectedRarities) do
                            if string.find(tLower, r) then matchFound = true; detectedName = guiObj.Text; break end
                        end
                        -- Проверяем мутации
                        if not matchFound then
                            for m, _ in pairs(SelectedMutations) do
                                if string.find(tLower, m) then matchFound = true; detectedName = guiObj.Text; break end
                            end
                        end
                    end
                    if matchFound then break end
                end
            end)
            
            -- Если нашли нужное яйцо и мы еще не на паузе
            if matchFound and not AutoRollPaused and TargetedPart then
                -- Если это то же самое яйцо, увеличиваем счетчик детекта
                if LastNotifiedText == detectedName then
                    SameEggCounter = SameEggCounter + 1
                else
                    SameEggCounter = 1
                    LastNotifiedText = detectedName
                end
                
                -- АВТО-СКИП: Если скрипт видит одно и то же яйцо уже второй раз (зависло/баг), пропускаем его
                if SameEggCounter >= 2 then
                    print("[AUTO-SKIP]: Зафиксирован повтор текста! Принудительный скип яйца.")
                    AutoRollPaused = false
                    SameEggCounter = 0
                    LastNotifiedText = ""
                    task.wait(0.3)
                else
                    -- Обычная остановка
                    AutoRollPaused = true
                    DetectedEggModel = nil
                    
                    -- Ищем физическую модельку яйца в радиусе кнопки
                    pcall(function()
                        for _, obj in pairs(game.Workspace:GetChildren()) do
                            if obj:IsA("Model") or obj:IsA("BasePart") then
                                if obj.Name ~= LocalPlayer.Name and not obj:IsAncestorOf(LocalPlayer.Character) then
                                    local ppos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                    if (ppos - TargetedPart.Position).Magnitude <= 20 then
                                        DetectedEggModel = obj
                                        break
                                    end
                                end
                            end
                        end
                    end)
                    
                    -- Отправляем плашку (Защищено от спама через NotifActive КД)
                    SendNotification("⭐ СТОП-ФИЛЬТР!", "Выпало: " .. detectedName .. "\nЖдем пропажи с конвейера...")
                end
            end
            
            -- Физическая проверка исчезновения яйца из зоны
            if AutoRollPaused then
                local isEggStillInZone = false
                
                if TargetedPart then
                    if DetectedEggModel and DetectedEggModel:IsDescendantOf(game.Workspace) then
                        local epos = DetectedEggModel:IsA("Model") and DetectedEggModel:GetPivot().Position or DetectedEggModel.Position
                        if (epos - TargetedPart.Position).Magnitude <= 20 then
                            isEggStillInZone = true
                        end
                    else
                        -- Перепроверка зоны радаром
                        pcall(function()
                            for _, obj in pairs(game.Workspace:GetChildren()) do
                                if obj:IsA("Model") or obj:IsA("BasePart") then
                                    if obj.Name ~= LocalPlayer.Name and not obj:IsAncestorOf(LocalPlayer.Character) then
                                        local ppos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                                        if (ppos - TargetedPart.Position).Magnitude <= 20 then
                                            isEggStillInZone = true
                                            break
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                
                -- Разблокировка ролла, когда яйцо реально куплено или уехало
                if not isEggStillInZone then
                    task.wait(0.4)
                    AutoRollPaused = false
                    DetectedEggModel = nil
                    SameEggCounter = 0
                    LastNotifiedText = ""
                    print("[CONVEYOR v13]: Конвейер чист! Продолжаю авто-ролл.")
                end
            end
        else
            AutoRollPaused = false
            SameEggCounter = 0
            LastNotifiedText = ""
        end
    end
end)


-- [[ ЦИКЛ АВТО-КЛИКОВ ]]
task.spawn(function()
    while task.wait(0.15) do
        if not ScriptActive then break end
        if AutoRollEnabled and not AutoRollPaused and TargetedPart and TargetedPart:IsA("BasePart") then
            pcall(function()
                if TargetedPart:FindFirstChildOfClass("ClickDetector") then
                    fireclickdetector(TargetedPart:FindFirstChildOfClass("ClickDetector"))
                elseif TargetedPart:FindFirstChildOfClass("ProximityPrompt") then
                    fireproximityprompt(TargetedPart:FindFirstChildOfClass("ProximityPrompt"))
                elseif firetouchinterest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    firetouchinterest(TargetedPart, root, 0) task.wait(0.01) firetouchinterest(TargetedPart, root, 1)
                end
            end)
        end
    end
end)


-- [[ UNINJECT И УПРАВЛЕНИЕ ]]
local UninjectBtn = Instance.new("TextButton", TabPanel)
UninjectBtn.Size = UDim2.new(1, 0, 0, 32)
UninjectBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 30)
UninjectBtn.Text = "⚠️ UNINJECT"
UninjectBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
UninjectBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", UninjectBtn).CornerRadius = UDim.new(0, 6)

UninjectBtn.MouseButton1Click:Connect(function()
    ScriptActive = false 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end
    ScreenGui:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function() MainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Back, 0.4, true, function() OpenBtn.Visible = true end) end)
OpenBtn.MouseButton1Click:Connect(function() OpenBtn.Visible = false MainFrame:TweenSize(UDim2.new(0, 520, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.5, true) end)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging and ScriptActive then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

task.spawn(function() while task.wait(0.3) do if not ScriptActive then break end if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = WALK_SPEED end end end)

print("[Egg Farm Script]: Версия v13.0 успешно запущена!")
