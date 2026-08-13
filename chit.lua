-- MM2 Ultimate Rage Script with Fly & Full Customization for Delta hamam
if _G.MM2UltimateRageLoaded then return end
_G.MM2UltimateRageLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Config = {
    RageBot = false,
    RageHitbox = "Head",
    SilentAim = false,
    AutoShoot = false,
    FovCircle = true,
    FovSize = 150,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    ESPRole = false,
    Chams = false,
    BunnyHop = false,
    SpeedHack = false,
    SpeedVal = 24,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    FullBright = false,
    AutoCoin = false,
    CoinDelay = 0.15,
    FOVChanger = false,
    FOVVal = 90
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = Config.FovSize
fovCircle.Color = Color3.fromRGB(0, 255, 200)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 0.8

local ESPStorage = {}

local function RemoveESP(player)
    if ESPStorage[player] then
        for _, obj in pairs(ESPStorage[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPStorage[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    p.CharacterRemoving:Connect(function() RemoveESP(p) end)
end
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

-- Переменные для полета (Fly)
local flyBodyVel, flyBodyGyro
local function enableFly()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVel.Velocity = Vector3.zero
        flyBodyVel.Parent = hrp

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp
    end
end

local function disableFly()
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2AdvancedRage"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
MainFrame.Position = UDim2.new(0.05, 0, 0.08, 0)
MainFrame.Size = UDim2.new(0, 480, 0, 400)
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
Title.Text = "MM2 ADVANCED RAGE // WITH FLY"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.BorderColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.02, 0)
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
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 0, 0, 35)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -35)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 1250)

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollingFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 6)

local function AddToggle(name, configKey)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingFrame
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Size = UDim2.new(0, 450, 0, 32)
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
            if configKey == "Fly" then disableFly() end
            if configKey:sub(1,3) == "ESP" or configKey == "Chams" then
                for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end
            end
        end
    end)
end

local function AddSlider(name, configKey, min, max, decimals)
    decimals = decimals or 0
    local container = Instance.new("Frame")
    container.Parent = ScrollingFrame
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.Size = UDim2.new(0, 450, 0, 50)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0.02, 0, 0.05, 0)
    label.Size = UDim2.new(0.96, 0, 0, 20)
    label.Font = Enum.Font.Code
    label.Text = name .. ": " .. tostring(Config[configKey])
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBar = Instance.new("TextButton")
    sliderBar.Parent = container
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.Position = UDim2.new(0.02, 0, 0.55, 0)
    sliderBar.Size = UDim2.new(0.96, 0, 0, 14)
    sliderBar.Text = ""

    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBar
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    sliderFill.Size = UDim2.new((Config[configKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BorderSizePixel = 0

    local dragging = false
    
    local function updateValue(input)
        local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local val = min + ((max - min) * pos)
        if decimals == 0 then
            val = math.floor(val + 0.5)
        else
            val = tonumber(string.format("%." .. decimals .. "f", val))
        end
        Config[configKey] = val
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = name .. ": " .. tostring(val)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
end

local function AddDropdown(name, configKey, options)
    local container = Instance.new("Frame")
    container.Parent = ScrollingFrame
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.Size = UDim2.new(0, 450, 0, 40)

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Position = UDim2.new(0.02, 0, 0.1, 0)
    btn.Size = UDim2.new(0.96, 0, 0, 32)
    btn.Font = Enum.Font.Code
    btn.Text = name .. ": " .. tostring(Config[configKey])
    btn.TextColor3 = Color3.fromRGB(0, 255, 200)
    btn.TextSize = 12

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == Config[configKey] then currentIndex = i end
    end

    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        Config[configKey] = options[currentIndex]
        btn.Text = name .. ": " .. tostring(Config[configKey])
    end)
end

-- Меню элементов
AddToggle("1. RageBot (Auto-Lock Murderer)", "RageBot")
AddDropdown("   > Rage Hitbox", "RageHitbox", {"Head", "HumanoidRootPart", "UpperTorso"})
AddToggle("2. Silent Aim (Redirect Gun)", "SilentAim")
AddToggle("3. Auto-Shoot Gun", "AutoShoot")
AddToggle("4. FOV Circle Display", "FovCircle")
AddSlider("   > FOV Circle Size", "FovSize", 30, 400, 0)
AddToggle("5. ESP Box (Drawing)", "ESPBox")
AddToggle("6. ESP Name Tags", "ESPName")
AddToggle("7. ESP Health Tracker", "ESPHealth")
AddToggle("8. ESP Role Highlights", "ESPRole")
AddToggle("9. Chams (Fullbright Models)", "Chams")
AddToggle("10. BunnyHop (Auto Jump)", "BunnyHop")
AddToggle("11. SpeedHack", "SpeedHack")
AddSlider("   > Speed Multiplier", "SpeedVal", 16, 100, 0)
AddToggle("12. Flight Mode (Fly)", "Fly")
AddSlider("   > Fly Speed", "FlySpeed", 20, 200, 0)
AddToggle("13. NoClip (Walk Through Walls)", "NoClip")
AddToggle("14. FullBright (No Shadows)", "FullBright")
AddToggle("15. Auto-Farm Coins", "AutoCoin")
AddSlider("   > Coin Pickup Delay", "CoinDelay", 0.05, 0.5, 2)
AddToggle("16. Custom FOV Changer", "FOVChanger")
AddSlider("   > Camera FOV Value", "FOVVal", 70, 120, 0)

-- Цель для аимбота
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
                            target = char:FindFirstChild(Config.RageHitbox) or char.HumanoidRootPart
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Основной цикл рендеринга
RunService.RenderStepped:Connect(function()
    if Config.FovCircle then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fovCircle.Radius = Config.FovSize
    else
        fovCircle.Visible = false
    end

    if Config.RageBot then
        local target = GetTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    if Config.SilentAim and LocalPlayer.Character then
        local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun and gun:FindFirstChild("Handle") then
            pcall(function()
                local target = GetTarget()
                if target then gun.Handle.CFrame = target.CFrame end
            end)
        end
    end

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

    if Config.BunnyHop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end

    if Config.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.SpeedVal
    end

    -- Логика полета (Fly)
    if Config.Fly then
        if not flyBodyVel or not flyBodyVel.Parent then
            enableFly()
        end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            flyBodyGyro.CFrame = Camera.CFrame
            local speed = Config.FlySpeed
            local dir = Vector3.zero
            
            if hum.MoveDirection.Magnitude > 0 then
                dir = Camera.CFrame.LookVector * (hum.MoveDirection:Dot(Camera.CFrame.LookVector)) + Camera.CFrame.RightVector * (hum.MoveDirection:Dot(Camera.CFrame.RightVector))
                dir = dir.Unit * speed
            end
            
            if hum.Jump then
                dir = dir + Vector3.new(0, speed, 0)
            end
            
            flyBodyVel.Velocity = dir
        end
    else
        disableFly()
    end

    if Config.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if Config.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    end

    if Config.FOVChanger then
        Camera.FieldOfView = Config.FOVVal
    end

    -- ESP & Chams
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if not ESPStorage[player] then
                    ESPStorage[player] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Health = Drawing.new("Text"),
                        Highlight = Instance.new("Highlight")
                    }
                    ESPStorage[player].Box.Thickness = 1
                    ESPStorage[player].Box.Filled = false
                    ESPStorage[player].Name.Size = 14
                    ESPStorage[player].Name.Center = true
                    ESPStorage[player].Name.Outline = true
                    ESPStorage[player].Health.Size = 12
                    ESPStorage[player].Health.Center = true
                    ESPStorage[player].Health.Outline = true
                end
                
                local esp = ESPStorage[player]
                local isMurderer = char:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")
                local isSheriff = char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
                
                local roleColor = Color3.fromRGB(0, 255, 100)
                if isMurderer then roleColor = Color3.fromRGB(255, 0, 0)
                elseif isSheriff then roleColor = Color3.fromRGB(0, 120, 255) end

                if onScreen and Config.ESPBox then
                    local size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                    esp.Box.Size = size
                    esp.Box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                    esp.Box.Color = roleColor
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                if onScreen and Config.ESPName then
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - (3000 / pos.Z) / 2 - 18)
                    esp.Name.Color = roleColor
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                if onScreen and Config.ESPHealth then
                    esp.Health.Text = "HP: " .. math.floor(humanoid.Health)
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + (3000 / pos.Z) / 2 + 2)
                    esp.Health.Color = Color3.fromRGB(255, 255, 255)
                    esp.Health.Visible = true
                else
                    esp.Health.Visible = false
                end

                if Config.ESPRole or Config.Chams then
                    if esp.Highlight.Parent ~= char then
                        esp.Highlight.Parent = char
                    end
                    esp.Highlight.FillColor = roleColor
                    esp.Highlight.FillTransparency = 0.45
                    esp.Highlight.OutlineTransparency = 0
                    esp.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    if esp.Highlight.Parent then esp.Highlight.Parent = nil end
                end
            else
                RemoveESP(player)
            end
        else
            RemoveESP(player)
        end
    end
end)

-- Авто-фарм монет
task.spawn(function()
    while true do
        task.wait(Config.CoinDelay)
        if Config.AutoCoin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "Coin" or obj.Name == "Coin_Server" or (obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "CoinContainer") then
                        if obj:IsA("BasePart") and obj.Transparency == 0 and Config.AutoCoin then
                            hrp.CFrame = obj.CFrame
                            task.wait(Config.CoinDelay)
                        end
                    end
                end
            end)
        end
    end
end)

```
