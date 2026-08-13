-- MM2 Rage Cheat (CS2 Style) for Delta
if _G.MM2RageLoaded then return end
_G.MM2RageLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Состояние функций (Config)
local Config = {
    RageBot = false,
    SilentAim = false,
    AutoShoot = false,
    FovCircle = true,
    FovSize = 120,
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

-- Создание UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2RageCheat"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
MainFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 480, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.Text = "CS2 STYLE RAGE // MM2 [DELTA]"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка сворачивания
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.05, 0)
ToggleBtn.Size = UDim2.new(0, 90, 0, 35)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.Text = "MENU [ON]"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.TextSize = 12

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleBtn.Text = MainFrame.Visible and "MENU [ON]" or "MENU [OFF]"
end)

-- Контейнер функций
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 650)

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollingFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

-- Функция создания чекбокса
local function CreateButton(name, configKey, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Size = UDim2.new(0, 450, 0, 32)
    btn.Font = Enum.Font.Code
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.TextSize = 13

    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        if Config[configKey] then
            btn.Text = name .. ": ON"
            btn.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            btn.Text = name .. ": OFF"
            btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        if callback then callback(Config[configKey]) end
    end)
end

-- Добавление 15+ функций (Rage, Visuals, Misc)
CreateButton("1. RageBot (Auto-Aim Murderer)", "RageBot")
CreateButton("2. Silent Aim (Instant Lock)", "SilentAim")
CreateButton("3. Auto-Shoot Gun", "AutoShoot")
CreateButton("4. FOV Circle (Draw FOV)", "FovCircle")
CreateButton("5. ESP Box (CS2 Style)", "ESPBox")
CreateButton("6. ESP Name", "ESPName")
CreateButton("7. ESP Health / Status", "ESPHealth")
CreateButton("8. ESP Role (Murder/Sheriff)", "ESPRole")
CreateButton("9. Chams (Fullbright Models)", "Chams")
CreateButton("10. BunnyHop (Auto-Jump)", "BunnyHop")
CreateButton("11. SpeedHack", "SpeedHack")
CreateButton("12. NoClip (Walk through walls)", "NoClip")
CreateButton("13. Fullbright (Remove shadows)", "FullBright")
CreateButton("14. Auto-Farm Coins", "AutoCoin")
CreateButton("15. Custom FOV Changer", "FOVChanger")

-- Логика функционала (Rage/Visuals/Misc)

-- Поиск ближайшей цели (Убийцы или врагов)
local function GetTarget()
    local target = nil
    local shortestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local bp = player.Backpack
            -- Приоритет ragebot на убийцу
            local isMurderer = char:FindFirstChild("Knife") or bp:FindFirstChild("Knife")
            
            if Config.RageBot or isMurderer then
                local pos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < Config.FovSize and dist < shortestDist then
                    shortestDist = dist
                    target = char:FindFirstChild(Config.Hitbox) or char.HumanoidRootPart
                end
            end
        end
    end
    return target
end

-- RageBot & SilentAim Логика
RunService.RenderStepped:Connect(function()
    -- RageBot (наведение камеры)
    if Config.RageBot then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- SilentAim (телепортация луча/пули, если есть ствол)
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

    -- AutoShoot (автоматический выстрел из пистолета шерифа)
    if Config.AutoShoot and LocalPlayer.Character then
        local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun then
            pcall(function()
                gun.Shoot:FireServer(Camera.CFrame)
            end)
        end
    end

    -- BunnyHop
    if Config.BunnyHop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid:Jump()
        end
    end

    -- SpeedHack
    if Config.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.SpeedVal
    end

    -- NoClip
    if Config.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- FullBright
    if Config.FullBright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
    end

    -- FOV Changer
    if Config.FOVChanger then
        Camera.FieldOfView = Config.FOVVal
    end
end)

-- Авто-фарм монет в фоновом режиме
task.spawn(function()
    while true do
        task.wait(0.3)
        if Config.AutoCoin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            pcall(function()
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name == "CoinContainer" or obj.Name == "Coin_Server" then
                        for _, coin in pairs(obj:GetChildren()) do
                            if coin:IsA("BasePart") and coin.Transparency == 0 and Config.AutoCoin then
                                hrp.CFrame = coin.CFrame
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ESP & Chams Визуализация
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("CS2_Highlight")
            
            -- Chams / ESP Role подсветка
            if Config.ESPRole or Config.Chams then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "CS2_Highlight"
                    highlight.Parent = char
                end
                
                local isMurderer = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
                local isSheriff = char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
                
                if isMurderer then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный (Убийца)
                elseif isSheriff then
                    highlight.FillColor = Color3.fromRGB(0, 100, 255) -- Синий (Шериф)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Зеленый (Мэверик)
                end
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)
