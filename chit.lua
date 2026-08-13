-- Natural Disaster Survival GUI (Delta Optimized + Fly & Knife)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 390) -- Увеличили размер под новые кнопки
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

-- Функция создания кнопок с авто-отступом
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
    yOffset = yOffset + 43
end

-- 1. Телепорт к яблокам
createButton("Телепорт к Яблокам", function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Apple" and obj:IsA("BasePart") then
            char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end)

-- 2. Выдача ножа
createButton("Выдать Нож", function()
    -- Ищем нож в игре (в ReplicatedStorage или ServerStorage / Workspace) и клонируем в рюкзак
    local toolName = "Knife" -- Стандартное имя ножа в NDS
    local foundTool = nil
    
    -- Проверяем ReplicatedStorage
    local repStorage = game:GetService("ReplicatedStorage")
    if repStorage:FindFirstChild(toolName, true) then
        foundTool = repStorage:FindFirstChild(toolName, true):Clone()
    end
    
    -- Если не нашли там, ищем в Workspace или других местах
    if not foundTool then
        for _, item in pairs(Workspace:GetDescendants()) do
            if item.Name == toolName and item:IsA("Tool") then
                foundTool = item:Clone()
                break
            end
        end
    end
    
    if foundTool and LocalPlayer:FindFirstChild("Backpack") then
        foundTool.Parent = LocalPlayer.Backpack
    else
        -- Запасной вариант: если точное имя отличается, попробуем поискать инструменты в игре
        for _, item in pairs(repStorage:GetDescendants()) do
            if item:IsA("Tool") and (item.Name:lower():find("knife") or item.Name:lower():find("нож")) then
                item:Clone().Parent = LocalPlayer.Backpack
                break
            end
        end
    end
end)

-- 3. Функция Полета (Fly)
local flying = false
local flySpeed = 50
createButton("Полет (Вкл/Выкл)", function()
    flying = not flying
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    local rootPart = char.HumanoidRootPart
    local humanoid = char.Humanoid
    
    if flying then
        humanoid.PlatformStand = true
        local bg = Instance.new("BodyGyro", rootPart)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e4, 9e4, 9e4)
        bg.cframe = rootPart.CFrame
        
        local bv = Instance.new("BodyVelocity", rootPart)
        bv.velocity = Vector3.new(0, 0, 0)
        bv.maxForce = Vector3.new(9e4, 9e4, 9e4)
        
        task.spawn(function()
            while flying and char and char.Parent do
                local cam = Workspace.CurrentCamera
                local moveDir = Vector3.new()
                
                -- Управление для мобильных и ПК через камеру
                moveDir = cam.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) 
                        - cam.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                
                -- Для дельта-экзекьютора делаем простой подъем/полет по взгляду камеры
                bv.velocity = cam.CFrame.LookVector * flySpeed
                bg.cframe = cam.CFrame
                RunService.RenderStepped:Wait()
            end
            
            humanoid.PlatformStand = false
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end)
    else
        humanoid.PlatformStand = false
        flying = false
    end
end)

-- 4. Защита от сильного падения
createButton("Анти-урон от падения", function()
    RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local vel = char.HumanoidRootPart.Velocity
            if vel.Y < -60 then
                char.HumanoidRootPart.Velocity = Vector3.new(vel.X, -20, vel.Z)
            end
        end
    end)
end)

-- 5. Быстрый бег
local speedEnabled = false
createButton("Быстрый бег (Вкл/Выкл)", function()
    speedEnabled = not speedEnabled
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedEnabled and 24 or 16
    end
end)

-- 6. Телепорт на крышу лобби
createButton("На крышу (Лобби)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(-255, 195, 350)
    end
end)

-- 7. Закрыть меню
createButton("Закрыть Меню", function()
    ScreenGui:Destroy()
end)

print("NDS Menu (Fly & Knife) успешно загружено!")
