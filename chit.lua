-- Natural Disaster Survival GUI (Fixed for Delta)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Удаляем старое меню, если оно было
if PlayerGui:FindFirstChild("NDS_Delta_GUI") then
    PlayerGui.NDS_Delta_GUI:Destroy()
end

-- Создаем главный контейнер
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NDS_Delta_GUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "NDS Menu | Delta"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Функция создания кнопок с фиксированным отступом
local yOffset = 50
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    yOffset = yOffset + 43 -- Смещаем следующую кнопку ниже
end

-- 1. Телепорт к яблокам
createButton("Телепорт к Яблокам", function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Apple" and obj:IsA("BasePart") then
            char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end)

-- 2. Защита от сильного падения
createButton("Анти-урон от падения", function()
    game:GetService("RunService").Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local vel = char.HumanoidRootPart.Velocity
            if vel.Y < -60 then
                char.HumanoidRootPart.Velocity = Vector3.new(vel.X, -20, vel.Z)
            end
        end
    end)
end)

-- 3. Быстрый бег
local speedEnabled = false
createButton("Быстрый бег (Вкл/Выкл)", function()
    speedEnabled = not speedEnabled
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedEnabled and 24 or 16
    end
end)

-- 4. Телепорт на крышу лобби
createButton("На крышу (Лобби)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-255, 195, 350)
    end
end)

-- 5. Закрыть меню
createButton("Закрыть Меню", function()
    ScreenGui:Destroy()
end)

print("NDS Menu успешно загружено!")
