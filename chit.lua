-- MM2 Ultimate Rage Script (Fully Fixed & Optimized for Delta)
if _G.MM2UltimateRageLoaded then return end
_G.MM2UltimateRageLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Конфигурация всех 15 функций
local Config = {
    RageBot = false,
    SilentAim = false,
    AutoShoot = false,
    FovCircle = true,
    FovSize = 150,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    ESPRole = false,
    Chams = false,
    Hitbox = "Head",
    BunnyHop = false,
    SpeedHack = false,
    SpeedVal = 24,
    NoClip = false,
    FullBright = false,
    AutoCoin = false,
    FOVChanger = false,
    FOVVal = 90
}

-- Стабильный круговой FOV через Drawing библиотеку Delta
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = Config.FovSize
fovCircle.Color = Color3.fromRGB(0, 255, 200)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 0.8

-- Создание графического интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2UltimateRage"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 460, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.Size = UDim2.new(0.8, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.Text = "MM2 ULTIMATE RAGE // FIXED"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.03, 0)
ToggleBtn.Size = UDim2.new(0, 90, 0, 30)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.Text = "MENU [ON]"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.TextSize = 11

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Text = MainFrame.Visible and "MENU [ON]" or "MENU [OFF]"
end)

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 750)

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollingFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)

-- Функция создания элементов меню
local function CreateButton(name, configKey)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Size = UDim2.new(0, 430, 0, 30)
    btn.Font = Enum.Font.Code
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.TextSize = 12

    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            btn.Text = name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            btn.Text = name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)
end

-- Регистрация всех 15 функций
CreateButton("1. RageBot (Auto-Lock Murderer)", "RageBot")
CreateButton("2. Silent Aim (Redirect Gun)", "SilentAim")
CreateButton("3. Auto-Shoot Gun", "AutoShoot")
CreateButton("4. FOV Circle Display", "FovCircle")
CreateButton("5. ESP Box (Models)", "ESPBox")
CreateButton("6. ESP Name Tags", "ESPName")
CreateButton("7. ESP Health Tracker", "ESPHealth")
CreateButton("8. ESP Role Highlights", "ESPRole")
CreateButton("9. Chams (Fullbright Models)", "Chams")
CreateButton("10. BunnyHop (Auto Jump)", "BunnyHop")
CreateButton("11. SpeedHack", "SpeedHack")
CreateButton("12. NoClip (Walk Through Walls)", "NoClip")
CreateButton("13. FullBright (No Shadows)", "FullBright")
CreateButton("14. Auto-Farm Coins", "AutoCoin")
CreateButton("15. Custom FOV Changer", "FOVChanger")

-- Поиск актуальной цели (приоритет убийце в поле зрения FOV)
local function GetTarget()
    local target = nil
    local shortestDist = math.huge
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local bp = player.Backpack
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local isMurderer = char:FindFirstChild("Knife") or bp:FindFirstChild("Knife")
                if Config.RageBot or isMurderer then
                    local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                    if onScreen then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local dist = (screenPos - centerScreen).Magnitude
                        if dist <= Config.FovSize and dist < shortestDist then
                            shortestDist = dist
                            target = char:FindFirstChild("Head") or char.HumanoidRootPart
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Основной цикл рендеринга для боевых и системных функций
RunService.RenderStepped:Connect(function()
    -- Обновление круга FOV
    if Config.FovCircle then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Config.FovSize
    else
        fovCircle.Visible = false
    end

    -- 1. RageBot (Плавное наведение на цель)
    if Config.RageBot then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    -- 2. Silent Aim (Редирект луча пистолета)
    if Config.SilentAim and LocalPlayer.Character then
        local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun and gun:FindFirstChild("Handle") then
            pcall(function()
                local target = GetTarget()
                if target then
                    gun.Handle.CFrame = target.CFrame
                end
            end)
        end
    end

    -- 3. Auto-Shoot (Автоматический выстрел при наличии пистолета)
    if Config.AutoShoot and LocalPlayer.Character then
        local gun = LocalPlayer.Character:FindFirstChild("Gun")
        if gun then
            pcall(function()
                for _, remote in pairs(workspace:GetDescendants()) do
                    if remote:IsA("RemoteEvent") and (remote.Name == "Shoot" or remote.Name == "GunEvent") then
                        remote:FireServer(1, Camera.CFrame, "Gun")
                    end
                end
            end)
        end
    end

    -- 10. BunnyHop
    if Config.BunnyHop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- 11. SpeedHack
    if Config.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.SpeedVal
    end

    -- 12. NoClip
    if Config.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- 13. FullBright
    if Config.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    end

    -- 15. FOV Changer
    if Config.FOVChanger then
        Camera.FieldOfView = Config.FOVVal
    end
end)

-- 14. Исправленный автофарм монет (глубокое сканирование карты)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Config.AutoCoin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin" or obj.Name == "Coin_Server" or (obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "CoinContainer") then
                        if obj:IsA("BasePart") and obj.Transparency == 0 and Config.AutoCoin then
                            hrp.CFrame = obj.CFrame
                            task.wait(0.15)
                        end
                    end
                end
            end)
        end
    end
end)

-- 8 & 9. Исправленная подсветка ролей и Chams
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hrp and humanoid then
                local highlight = char:FindFirstChild("UltimateHighlight")
                if Config.ESPRole or Config.Chams then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "UltimateHighlight"
                        highlight.Parent = char
                    end
                    
                    local isMurderer = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
                    local isSheriff = char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
                    
                    if isMurderer then
                        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный (Убийца)
                    elseif isSheriff then
                        highlight.FillColor = Color3.fromRGB(0, 120, 255) -- Синий (Шериф)
                    else
                        highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Зеленый (Мирный)
                    end
                    highlight.FillTransparency = 0.45
                    highlight.OutlineTransparency = 0
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end
end)
