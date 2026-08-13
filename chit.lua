-- Защита от повторного запуска
if _G.MM2Loaded then
    return
end
_G.MM2Loaded = true

-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Создание простого и удобного GUI для Delta
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Delta_Hub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.Size = UDim2.new(0, 350, 0, 260)
MainFrame.Active = true
MainFrame.Draggable = true -- Можно перетаскивать пальцем

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "MM2 Hub | Delta Edition"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.Size = UDim2.new(0, 330, 0, 200)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Функция создания кнопок-переключателей (Toggle)
local function CreateToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Parent = ScrollingFrame
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.Font = Enum.Font.SourceSans
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 16
    Button.Text = name .. ": [OFF]"
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    local toggled = false
    Button.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            Button.Text = name .. ": [ON]"
            Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            Button.Text = name .. ": [OFF]"
            Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        callback(toggled)
    end)
end

-- Переменные для функций
local speedEnabled = false
local jumpEnabled = false
local hitboxesEnabled = false
local aimbotEnabled = false
local noclipEnabled = false
local flyEnabled = false
local antiAimEnabled = false

-- 1. Ускорение (Speed)
CreateToggle("Ускорение (WalkSpeed = 25)", function(state)
    speedEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 25
    elseif not speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- 2. Изменение прыжка (JumpPower)
CreateToggle("Супер-прыжок", function(state)
    jumpEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if jumpEnabled then
            LocalPlayer.Character.Humanoid.JumpPower = 80
        else
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
end)

-- 3. Хитбоксы (Hitboxes) - Увеличение голов/тел игроков
CreateToggle("Увеличение хитбоксов", function(state)
    hitboxesEnabled = state
end)

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if hitboxesEnabled then
                hrp.Size = Vector3.new(4, 4, 4)
                hrp.Transparency = 0.6
                hrp.CanCollide = false
            else
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = true
            end
        end
    end
end)

-- 4. Ноуклип (NoClip) - Проход сквозь стены
CreateToggle("Ноуклип (NoClip)", function(state)
    noclipEnabled = state
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 5. Флай (Fly) - Полет
local flyConnection
CreateToggle("Флай (Fly)", function(state)
    flyEnabled = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if flyEnabled then
        flyConnection = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                hrp.Velocity = Vector3.new(0, 1, 0) -- Базовая поддержка высоты
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
                end
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
        end
    end
end)

-- 6. Антиаим (Anti-Aim) - Вращение персонажа для уклонения
CreateToggle("Антиаим (Anti-Aim)", function(state)
    antiAimEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if antiAimEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(35), 0)
    end
end)

-- 7. Наводка (Aimbot) - Автоматический взгляд на ближайшего игрока
CreateToggle("Наводка (Aimbot)", function(state)
    aimbotEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local distance = (head.Position - Camera.CFrame.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
        
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
        end
    end
end)
