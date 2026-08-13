-- MM2 Ultimate Rage Script (ESP Fixed for Delta)
if _G.MM2UltimateRageLoaded then return end
_G.MM2UltimateRageLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

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

-- FOV Круг через Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = Config.FovSize
fovCircle.Color = Color3.fromRGB(0, 255, 200)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 0.8

-- Хранилище для ESP объектов каждого игрока
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

-- Создание UI
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
Title.Text = "MM2 ULTIMATE RAGE // ESP FIXED"
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
            if configKey:sub(1,3) == "ESP" or configKey == "Chams" then
                for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end
            end
        end
    end)
end

CreateButton("1. RageBot (Auto-Lock Murderer)", "RageBot")
CreateButton("2. Silent Aim (Redirect Gun)", "SilentAim")
CreateButton("3. Auto-Shoot Gun", "AutoShoot")
CreateButton("4. FOV Circle Display", "FovCircle")
CreateButton("5. ESP Box (Drawing)", "ESPBox")
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

-- Обработка функционала и рендеринга
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

    -- Рендеринг ESP (Boxes, Names, Health, Roles, Chams)
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
                
                local roleColor = Color3.fromRGB(0, 255, 100) -- Мирный
                if isMurderer then roleColor = Color3.fromRGB(255, 0, 0) -- Убийца
                elseif isSheriff then roleColor = Color3.fromRGB(0, 120, 255) end -- Шериф

                -- ESP Box
                if onScreen and Config.ESPBox then
                    local size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                    esp.Box.Size = size
                    esp.Box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                    esp.Box.Color = roleColor
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                -- ESP Name
                if onScreen and Config.ESPName then
                    esp.Name.Text = player.Name
                    esp.Name.Position = Vector2.new(pos.X, pos.Y - (3000 / pos.Z) / 2 - 18)
                    esp.Name.Color = roleColor
                    esp.Name.Visible = true
                else
                    esp.Name.Visible = false
                end

                -- ESP Health
                if onScreen and Config.ESPHealth then
                    esp.Health.Text = "HP: " .. math.floor(humanoid.Health)
                    esp.Health.Position = Vector2.new(pos.X, pos.Y + (3000 / pos.Z) / 2 + 2)
                    esp.Health.Color = Color3.fromRGB(255, 255, 255)
                    esp.Health.Visible = true
                else
                    esp.Health.Visible = false
                end

                -- ESP Role / Chams (Highlight)
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
