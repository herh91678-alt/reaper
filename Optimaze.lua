-- [[ BYSTIT V44 - NO STROKE UPDATE ]] --
local ScreenGui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TabContainer = Instance.new("Frame")
local ContentContainer = Instance.new("Frame")
local FOVCircle = Instance.new("Frame")
local ExpandBtn = Instance.new("TextButton")

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

if CoreGui:FindFirstChild("BystitV44") then CoreGui.BystitV44:Destroy() end

ScreenGui.Parent = CoreGui
ScreenGui.Name = "BystitV44"
ScreenGui.ResetOnSpawn = false

local Colors = {
    Bg = Color3.fromRGB(15, 15, 15),
    Accent = Color3.fromRGB(180, 0, 255),
    Text = Color3.fromRGB(255, 255, 255),
    BtnBg = Color3.fromRGB(30, 30, 30)
}

local Settings = { 
    Aim = false, AimPart = "Head", AimSmooth = 0.5, FOVSize = 150,
    WalkSpeed = 16, WallCheck = false, ESP = false
}

-- [ СИСТЕМА ШРИФТОВ ] --
local AvailableFonts = {Enum.Font.Roboto, Enum.Font.RobotoMono, Enum.Font.SciFi, Enum.Font.Arial}
local CurrentFontIdx = 1

local function ApplyFontToAll()
    local targetFont = AvailableFonts[CurrentFontIdx]
    for _, v in pairs(ScreenGui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            v.Font = targetFont
        end
    end
end

-- [ TOP BAR ] --
ExpandBtn.Name = "ExpandBtn"
ExpandBtn.Parent = ScreenGui; ExpandBtn.BackgroundColor3 = Colors.Bg; ExpandBtn.BackgroundTransparency = 0.4
ExpandBtn.Position = UDim2.new(0.5, -90, 0, 15); ExpandBtn.Size = UDim2.new(0, 180, 0, 32); ExpandBtn.Visible = false
ExpandBtn.TextColor3 = Colors.Accent; ExpandBtn.TextSize = 13
ExpandBtn.AutoButtonColor = false -- Убирает стандартное мигание
Instance.new("UICorner", ExpandBtn).CornerRadius = UDim.new(0, 10)
-- ОБВОДКА УДАЛЕНА ЗДЕСЬ (ExpStroke)

-- [ MAIN UI ] --
local OriginalMainSize = UDim2.new(0, 360, 0, 340)
local OriginalMainPos = UDim2.new(0.5, -180, 0.5, -170)

Main.Parent = ScreenGui; Main.BackgroundColor3 = Colors.Bg; Main.BackgroundTransparency = 0.1
Main.Position = OriginalMainPos; Main.Size = OriginalMainSize; Main.Active, Main.Draggable = true, true
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)
-- ОБВОДКА УДАЛЕНА ЗДЕСЬ (MainStroke)

-- [ HEADER ] --
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 60); Header.BackgroundTransparency = 1
local AvatarImg = Instance.new("ImageLabel", Header)
AvatarImg.Size = UDim2.new(0, 45, 0, 45); AvatarImg.Position = UDim2.new(0, 15, 0, 8)
pcall(function() AvatarImg.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
local Title = Instance.new("TextLabel", Header)
Title.Text = "BYSTIT V44 PRO"; Title.TextSize = 16; Title.TextColor3 = Colors.Accent; Title.Position = UDim2.new(0, 70, 0, 20); Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

-- [ УПРАВЛЕНИЕ ] --
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 10); CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.new(1,0,0); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextSize = 25
local HideBtn = Instance.new("TextButton", Main)
HideBtn.Size = UDim2.new(0, 30, 0, 30); HideBtn.Position = UDim2.new(1, -65, 0, 10); HideBtn.Text = "—"; HideBtn.TextColor3 = Colors.Text; HideBtn.BackgroundTransparency = 1; HideBtn.TextSize = 25

HideBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 180, 0, 32), Position = UDim2.new(0.5, -90, 0, 15), BackgroundTransparency = 0.5}):Play()
    task.wait(0.45); Main.Visible = false; ExpandBtn.Visible = true
end)
ExpandBtn.MouseButton1Click:Connect(function()
    ExpandBtn.Visible = false; Main.Visible = true
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = OriginalMainSize, Position = OriginalMainPos, BackgroundTransparency = 0.1}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- [ ТАБЫ ] --
TabContainer.Parent = Main; TabContainer.Position = UDim2.new(0, 10, 0, 65); TabContainer.Size = UDim2.new(0, 85, 0, 260); TabContainer.BackgroundTransparency = 0.6; TabContainer.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UICorner", TabContainer)
Instance.new("UIListLayout", TabContainer).HorizontalAlignment = "Center"
ContentContainer.Parent = Main; ContentContainer.Position = UDim2.new(0, 105, 0, 65); ContentContainer.Size = UDim2.new(0, 245, 0, 260); ContentContainer.BackgroundTransparency = 1; ContentContainer.ClipsDescendants = true

local function CreateBtn(p, t, c)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = Colors.BtnBg; b.Text = t; b.TextColor3 = Colors.Text; b.TextSize = 11; Instance.new("UICorner", b); b.Font = AvailableFonts[CurrentFontIdx]
    b.AutoButtonColor = false
    b.MouseButton1Click:Connect(function() c(b) end)
end

local function AddTab(n, c)
    local b = Instance.new("TextButton", TabContainer); b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundTransparency = 1; b.Text = n; b.TextColor3 = Color3.fromRGB(140, 140, 140); b.TextSize = 9; b.Font = AvailableFonts[CurrentFontIdx]
    b.MouseButton1Click:Connect(function()
        for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(140, 140, 140) end end
        b.TextColor3 = Colors.Accent
        local old = ContentContainer:FindFirstChild("ActiveTab")
        if old then 
            TweenService:Create(old, TweenInfo.new(0.3), {Position = UDim2.new(0,-250,0,0), GroupTransparency = 1}):Play()
            task.delay(0.3, function() old:Destroy() end)
        end
        local Scroll = Instance.new("CanvasGroup", ContentContainer)
        Scroll.Name = "ActiveTab"; Scroll.Size = UDim2.new(1, 0, 1, 0); Scroll.Position = UDim2.new(0, 50, 0, 0); Scroll.BackgroundTransparency = 1; Scroll.GroupTransparency = 1
        local RealScroll = Instance.new("ScrollingFrame", Scroll)
        RealScroll.Size = UDim2.new(1, 0, 1, 0); RealScroll.BackgroundTransparency = 1; RealScroll.ScrollBarThickness = 1; RealScroll.ScrollBarImageColor3 = Colors.Accent; RealScroll.CanvasSize = UDim2.new(0,0,0,0); RealScroll.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", RealScroll).Padding = UDim.new(0, 6)
        c(RealScroll)
        ApplyFontToAll()
        TweenService:Create(Scroll, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}):Play()
    end)
end

-- [ FOV ] --
FOVCircle.Parent = ScreenGui; FOVCircle.Size = UDim2.new(0, Settings.FOVSize*2, 0, Settings.FOVSize*2); FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0); FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5); FOVCircle.BackgroundTransparency = 1; FOVCircle.Visible = false
local FOVStroke = Instance.new("UIStroke", FOVCircle); FOVStroke.Color = Colors.Accent; Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

-- [ ESP ] --
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            if Settings.ESP and p.Character and p.Character:FindFirstChild("Head") then
                local h = p.Character.Head
                local tag = h:FindFirstChild("BTag") or Instance.new("BillboardGui", h)
                tag.Name = "BTag"; tag.Size = UDim2.new(0, 100, 0, 50); tag.AlwaysOnTop = true; tag.ExtentsOffset = Vector3.new(0, 3, 0)
                local l = tag:FindFirstChild("L") or Instance.new("TextLabel", tag)
                l.Name = "L"; l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = p.Name; l.TextColor3 = Colors.Accent; l.Font = AvailableFonts[CurrentFontIdx]; l.TextSize = 13
            elseif p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("BTag") then
                p.Character.Head.BTag:Destroy()
            end
        end
    end
end

-- Вкладки (Combat, Visuals и т.д. остаются без изменений)
AddTab("COMBAT", function(p)
    CreateBtn(p, "🎯 AIM: "..(Settings.Aim and "ON" or "OFF"), function(b)
        Settings.Aim = not Settings.Aim; b.Text = "🎯 AIM: "..(Settings.Aim and "ON" or "OFF"); b.TextColor3 = Settings.Aim and Colors.Accent or Colors.Text; FOVCircle.Visible = Settings.Aim
    end)
    CreateBtn(p, "🦴 PART: "..Settings.AimPart:upper(), function(b)
        Settings.AimPart = (Settings.AimPart == "Head") and "HumanoidRootPart" or "Head"
        b.Text = "🦴 PART: "..Settings.AimPart:upper()
    end)
    CreateBtn(p, "⚡ SMOOTH: "..Settings.AimSmooth, function(b)
        Settings.AimSmooth = (Settings.AimSmooth >= 1) and 0.1 or Settings.AimSmooth + 0.2; b.Text = "⚡ SMOOTH: "..Settings.AimSmooth
    end)
    CreateBtn(p, "⭕ FOV: "..Settings.FOVSize, function(b)
        Settings.FOVSize = (Settings.FOVSize >= 300) and 50 or Settings.FOVSize + 50
        FOVCircle.Size = UDim2.new(0, Settings.FOVSize*2, 0, Settings.FOVSize*2); b.Text = "⭕ FOV: "..Settings.FOVSize
    end)
    CreateBtn(p, "🧱 WALLS: "..(Settings.WallCheck and "CHECK" or "IGNORE"), function(b)
        Settings.WallCheck = not Settings.WallCheck; b.Text = "🧱 WALLS: "..(Settings.WallCheck and "CHECK" or "IGNORE")
    end)
end)

AddTab("VISUALS", function(p)
    CreateBtn(p, "👁️ ESP NAMES: "..(Settings.ESP and "ON" or "OFF"), function(b)
        Settings.ESP = not Settings.ESP; b.Text = "👁️ ESP NAMES: "..(Settings.ESP and "ON" or "OFF")
        if not Settings.ESP then UpdateESP() end
    end)
end)

AddTab("MOVEMENT", function(p)
    CreateBtn(p, "⚡ SPEED: "..Settings.WalkSpeed, function(b)
        Settings.WalkSpeed = (Settings.WalkSpeed >= 100) and 16 or Settings.WalkSpeed + 20
        if Players.LocalPlayer.Character then Players.LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed end; b.Text = "⚡ SPEED: "..Settings.WalkSpeed
    end)
end)

AddTab("SCRIPTS", function(p)
    CreateBtn(p, "♾️ INFINITY YIELD", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
    CreateBtn(p, "🌪️ ULTIMATE FLING", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua"))() end)
    CreateBtn(p, "🔪 REAPER (MM2)", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/herh91678-alt/reaper/main/loader.lua"))() end)
end)

AddTab("SETTINGS", function(p)
    CreateBtn(p, "🔤 CHANGE FONT", function(b)
        CurrentFontIdx = (CurrentFontIdx % #AvailableFonts) + 1
        ApplyFontToAll()
        b.Text = "🔤 FONT: "..tostring(AvailableFonts[CurrentFontIdx].Name):upper()
    end)
    CreateBtn(p, "🎨 CHANGE ACCENT", function()
        local c = {Color3.fromRGB(180,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(255,50,50), Color3.fromRGB(50,255,50)}
        local idx = 1; for i,v in ipairs(c) do if v == Colors.Accent then idx = i end end
        Colors.Accent = c[(idx % #c) + 1]
        ExpandBtn.TextColor3 = Colors.Accent; Title.TextColor3 = Colors.Accent; FOVStroke.Color = Colors.Accent
    end)
end)

-- [ LOOP ] --
RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    if ExpandBtn.Visible then ExpandBtn.Text = os.date("%H:%M") .. " | " .. fps .. " FPS" end
    if Settings.ESP then UpdateESP() end
    if Settings.Aim then
        local target = nil; local dist = Settings.FOVSize
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= Players.LocalPlayer and pl.Character and pl.Character:FindFirstChild(Settings.AimPart) then
                local part = pl.Character[Settings.AimPart]
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        local can = true
                        if Settings.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Players.LocalPlayer.Character, pl.Character})
                            if hit then can = false end
                        end
                        if can then target = part; dist = mag end
                    end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimSmooth) end
    end
end)

-- Исправленная активация первой вкладки без ошибок
task.wait(0.1)
local firstTab = TabContainer:GetChildren()
for _, v in pairs(firstTab) do
    if v:IsA("TextButton") then
        v:MouseButton1Click()
        break
    end
end
ApplyFontToAll()
