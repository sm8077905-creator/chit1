-- Защита от повторного запуска
if _G.MM2CustomLoaded then
    return
end
_G.MM2CustomLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Создание UI (Простая библиотека на Drawing / CoreGui)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local EspToggle = Instance.new("TextButton")
local CoinToggle = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "MM2CustomGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать меню по экрану на телефоне

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "MM2 Rage Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Кнопка ESP
EspToggle.Name = "EspToggle"
EspToggle.Parent = MainFrame
EspToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
EspToggle.Size = UDim2.new(0, 160, 0, 35)
EspToggle.Font = Enum.Font.SourceSansBold
EspToggle.Text = "ESP Ролей: ВЫКЛ"
EspToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
EspToggle.TextSize = 14

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 6)
EspCorner.Parent = EspToggle

-- Кнопка Авто-Фарм Монет
CoinToggle.Name = "CoinToggle"
CoinToggle.Parent = MainFrame
CoinToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CoinToggle.Size = UDim2.new(0, 160, 0, 35)
CoinToggle.Font = Enum.Font.SourceSansBold
CoinToggle.Text = "Авто-Монеты: ВЫКЛ"
CoinToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
CoinToggle.TextSize = 14

local CoinCorner = Instance.new("UICorner")
CoinCorner.CornerRadius = UDim.new(0, 6)
CoinCorner.Parent = CoinToggle

-- Логика ESP (Подсветка Убийцы и Шерифа)
local espEnabled = false
EspToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        EspToggle.Text = "ESP Ролей: ВКЛ"
        EspToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        EspToggle.Text = "ESP Ролей: ВЫКЛ"
        EspToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
        -- Удаляем подсветку
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local backpack = player.Backpack
            local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                local highlight = char:FindFirstChild("Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Parent = char
                end
                
                -- Проверка инвентаря на наличие оружия
                local hasKnife = char:FindFirstChild("Knife") or backpack:FindFirstChild("Knife")
                local hasGun = char:FindFirstChild("Gun") or backpack:FindFirstChild("Gun")
                
                if hasKnife then
                    -- Убийца — Красный
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif hasGun then
                    -- Шериф — Синий
                    highlight.FillColor = Color3.fromRGB(0, 150, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    -- Обычный игрок — Зеленый
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end)

-- Логика Авто-Фарма Монет
local coinFarmEnabled = false
CoinToggle.MouseButton1Click:Connect(function()
    coinFarmEnabled = not coinFarmEnabled
    if coinFarmEnabled then
        CoinToggle.Text = "Авто-Монеты: ВКЛ"
        CoinToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        CoinToggle.Text = "Авто-Монеты: ВЫКЛ"
        CoinToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if coinFarmEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            pcall(function()
                -- Ищем контейнеры с монетами на карте
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name == "CoinContainer" or obj.Name == "Coin_Server" then
                        for _, coin in pairs(obj:GetChildren()) do
                            if coin:IsA("BasePart") and coin.Transparency == 0 and coinFarmEnabled then
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
