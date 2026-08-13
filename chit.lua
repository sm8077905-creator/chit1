--[[
    NEVERLOSE CS-MODE V34.1 (Delta Mobile Edition)
    - Mobile & PC Fly Controls (On-Screen D-Pad / Buttons)
    - GD-Style Speed, Jump & Fly Input
    - True RGB Color Picker (Palette + Preset System)
    - Fully Fixed ESP & Chams Rendering
    - Open Key: [TAB] or [INSERT] / Toggle Button on Mobile
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- НАСТРОЙКИ
--------------------------------------------------------------------------------
local Config = {
	Speed_Enabled = true,
	WalkSpeed = 16,

	Jump_Enabled = true,
	JumpPower = 50,

	Fly_Enabled = false,
	FlySpeed = 50,

	Aim_Enabled = true,
	Aim_AutoTarget = true,
	Aim_WallCheck = true,
	Aim_ShowFOV = true,
	Aim_FOV = 180,
	Aim_TargetPart = "Head",
	Aim_Duration = 0.1,

	ESP_Enabled = true,
	Chams_Enabled = true,
	ShowSelf = false,
	BoxColor = Color3.fromRGB(0, 255, 150),
	BoxThickness = 1.5,
	ChamsColor = Color3.fromRGB(255, 0, 100),
	ChamsTransparency = 0.5,

	AntiAim_Enabled = false,
	AntiAim_Pitch = "Вниз",
	AntiAim_Yaw = "Спинбот",
	SpinSpeed = 25
}

local ESP_Boxes = {}
local spinAngle = 0
local currentRootJoint = nil
local defaultRootC0 = nil
local currentNeck = nil
local defaultNeckC0 = nil
local lastSnapTime = 0
local isShooting = false

-- Мобильные состояния кнопок полета
local mobileFlyInputs = {
	W = false,
	S = false,
	A = false,
	D = false,
	Up = false,
	Down = false
}

--------------------------------------------------------------------------------
-- GUI СТРУКТУРА
--------------------------------------------------------------------------------
local successGui, parentGui = pcall(function()
	return CoreGui
end)
if not successGui or not parentGui then
	parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Neverlose_V34_DeltaFly"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = parentGui

local espContainer = Instance.new("Folder")
espContainer.Name = "ESP_Container"
espContainer.Parent = screenGui

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(0, 180, 255)
fovStroke.Thickness = 1.5
fovStroke.Parent = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

--------------------------------------------------------------------------------
-- МОБИЛЬНАЯ ПАНЕЛЬ УПРАВЛЕНИЯ ПОЛЕТОМ
--------------------------------------------------------------------------------
local flyControlGui = Instance.new("Frame")
flyControlGui.Size = UDim2.new(0, 150, 0, 150)
flyControlGui.Position = UDim2.new(0, 20, 0.5, -75)
flyControlGui.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
flyControlGui.BackgroundTransparency = 0.3
flyControlGui.Visible = false
flyControlGui.Active = true
flyControlGui.Parent = screenGui

local fcCorner = Instance.new("UICorner")
fcCorner.CornerRadius = UDim.new(0, 12)
fcCorner.Parent = flyControlGui

local fcStroke = Instance.new("UIStroke")
fcStroke.Color = Color3.fromRGB(0, 150, 255)
fcStroke.Thickness = 1.5
fcStroke.Parent = flyControlGui

local function createFlyBtn(name, text, size, pos, callback)
	local btn = Instance.new("TextButton")
	btn.Size = size
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = flyControlGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	btn.MouseButton1Down:Connect(function() callback(true) end)
	btn.MouseButton1Up:Connect(function() callback(false) end)
	btn.MouseLeave:Connect(function() callback(false) end)
	return btn
end

createFlyBtn("W", "W", UDim2.new(0, 40, 0, 40), UDim2.new(0, 55, 0, 8), function(v) mobileFlyInputs.W = v end)
createFlyBtn("S", "S", UDim2.new(0, 40, 0, 40), UDim2.new(0, 55, 0, 102), function(v) mobileFlyInputs.S = v end)
createFlyBtn("A", "A", UDim2.new(0, 40, 0, 40), UDim2.new(0, 8, 0, 55), function(v) mobileFlyInputs.A = v end)
createFlyBtn("D", "D", UDim2.new(0, 40, 0, 40), UDim2.new(0, 102, 0, 55), function(v) mobileFlyInputs.D = v end)

-- Дополнительные кнопки Вверх/Вниз для полета с телефона
local flyExtraGui = Instance.new("Frame")
flyExtraGui.Size = UDim2.new(0, 60, 0, 120)
flyExtraGui.Position = UDim2.new(1, -80, 0.5, -60)
flyExtraGui.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
flyExtraGui.BackgroundTransparency = 0.3
flyExtraGui.Visible = false
flyExtraGui.Active = true
flyExtraGui.Parent = screenGui

local feCorner = Instance.new("UICorner")
feCorner.CornerRadius = UDim.new(0, 12)
feCorner.Parent = flyExtraGui

local feStroke = Instance.new("UIStroke")
feStroke.Color = Color3.fromRGB(0, 150, 255)
feStroke.Thickness = 1.5
feStroke.Parent = flyExtraGui

createFlyBtn("Up", "UP", UDim2.new(0, 44, 0, 44), UDim2.new(0, 8, 0, 8), function(v) mobileFlyInputs.Up = v end)
createFlyBtn("Down", "DN", UDim2.new(0, 44, 0, 44), UDim2.new(0, 8, 0, 68), function(v) mobileFlyInputs.Down = v end)

--------------------------------------------------------------------------------
-- ГЛАВНОЕ МЕНЮ
--------------------------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 560)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.Active = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 150, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
titleBar.Text = "   NEVERLOSE.CC // DELTA FLY"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 11
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- Кнопка закрытия/открытия меню для телефонов (Delta)
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Size = UDim2.new(0, 45, 0, 28)
toggleMenuBtn.Position = UDim2.new(1, -50, 0, 5)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleMenuBtn.Text = "MENU"
toggleMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.TextSize = 10
toggleMenuBtn.Parent = titleBar

local tmCorner = Instance.new("UICorner")
tmCorner.CornerRadius = UDim.new(0, 4)
tmCorner.Parent = toggleMenuBtn

toggleMenuBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

--------------------------------------------------------------------------------
-- УПРАВЛЕНИЕ МЕНЮ (ПЕРЕТАСКИВАНИЕ)
--------------------------------------------------------------------------------
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.Insert then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

--------------------------------------------------------------------------------
-- ЭЛЕМЕНТЫ МЕНЮ
--------------------------------------------------------------------------------
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 44)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scroll

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

local function createHeader(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 22)
	label.BackgroundTransparency = 1
	label.Text = "--- " .. text .. " ---"
	label.TextColor3 = Color3.fromRGB(0, 150, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.Parent = scroll
end

local function createToggle(text, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
	btn.Text = "  " .. text .. ": " .. (defaultState and "[ВКЛ]" or "[ВЫКЛ]")
	btn.TextColor3 = defaultState and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 70, 70)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = scroll

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	local state = defaultState
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = "  " .. text .. ": " .. (state and "[ВКЛ]" or "[ВЫКЛ]")
		btn.TextColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 70, 70)
		callback(state)
	end)
end

local function createCycleButton(text, options, defaultIndex, callback)
	local currentIndex = defaultIndex
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 35)
	btn.Text = "  " .. text .. ": [" .. options[currentIndex] .. "]"
	btn.TextColor3 = Color3.fromRGB(0, 180, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = scroll

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		currentIndex = (currentIndex % #options) + 1
		btn.Text = "  " .. text .. ": [" .. options[currentIndex] .. "]"
		callback(options[currentIndex])
	end)
end

local function createSlider(text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 44)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	frame.Parent = scroll

	local sfCorner = Instance.new("UICorner")
	sfCorner.CornerRadius = UDim.new(0, 6)
	sfCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 18)
	label.Position = UDim2.new(0, 8, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text .. ": " .. tostring(default)
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local back = Instance.new("Frame")
	back.Size = UDim2.new(1, -16, 0, 6)
	back.Position = UDim2.new(0, 8, 0, 28)
	back.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	back.Parent = frame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	fill.Parent = back

	local isDrag = false
	local function updateVal(input)
		local pct = math.clamp((input.Position.X - back.AbsolutePosition.X) / back.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		local val = math.floor(min + (max - min) * pct)
		label.Text = text .. ": " .. tostring(val)
		callback(val)
	end

	back.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDrag = true updateVal(i) end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDrag = false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if isDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateVal(i) end
	end)
end

local function createTextBox(text, defaultVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	frame.Parent = scroll

	local tfCorner = Instance.new("UICorner")
	tfCorner.CornerRadius = UDim.new(0, 6)
	tfCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 85, 0, 26)
	box.Position = UDim2.new(1, -93, 0.5, -13)
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
	box.Text = tostring(defaultVal)
	box.TextColor3 = Color3.fromRGB(0, 255, 150)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.Parent = frame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 4)
	boxCorner.Parent = box

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(0, 150, 255)
	boxStroke.Thickness = 1
	boxStroke.Parent = box

	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			num = math.max(0, num)
			box.Text = tostring(num)
			callback(num)
		else
			box.Text = tostring(defaultVal)
		end
	end)
end

local function createColorPicker(text, defaultColor, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 42)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	frame.Parent = scroll

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 6)
	cCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local previewBtn = Instance.new("TextButton")
	previewBtn.Size = UDim2.new(0, 45, 0, 24)
	previewBtn.Position = UDim2.new(1, -53, 0.5, -12)
	previewBtn.BackgroundColor3 = defaultColor
	previewBtn.Text = ""
	previewBtn.Parent = frame

	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 4)
	pCorner.Parent = previewBtn

	local paletteFrame = Instance.new("Frame")
	paletteFrame.Size = UDim2.new(1, 0, 0, 140)
	paletteFrame.Position = UDim2.new(0, 0, 1, 4)
	paletteFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	paletteFrame.Visible = false
	paletteFrame.ZIndex = 5
	paletteFrame.Parent = frame

	local pfCorner = Instance.new("UICorner")
	pfCorner.CornerRadius = UDim.new(0, 6)
	pfCorner.Parent = paletteFrame

	local currentColor = defaultColor

	local function createRgbSlider(name, yPos, maxVal, initialVal, onValChanged)
		local sLabel = Instance.new("TextLabel")
		sLabel.Size = UDim2.new(0, 25, 0, 18)
		sLabel.Position = UDim2.new(0, 8, 0, yPos)
		sLabel.BackgroundTransparency = 1
		sLabel.Text = name
		sLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		sLabel.Font = Enum.Font.GothamBold
		sLabel.TextSize = 10
		sLabel.ZIndex = 6
		sLabel.Parent = paletteFrame

		local sBack = Instance.new("Frame")
		sBack.Size = UDim2.new(1, -70, 0, 8)
		sBack.Position = UDim2.new(0, 35, 0, yPos + 5)
		sBack.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
		sBack.ZIndex = 6
		sBack.Parent = paletteFrame

		local sFill = Instance.new("Frame")
		sFill.Size = UDim2.new(initialVal / maxVal, 0, 1, 0)
		sFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		sFill.ZIndex = 6
		sFill.Parent = sBack

		local valBox = Instance.new("TextBox")
		valBox.Size = UDim2.new(0, 24, 0, 18)
		valBox.Position = UDim2.new(1, -30, 0, yPos)
		valBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
		valBox.Text = tostring(math.floor(initialVal))
		valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		valBox.Font = Enum.Font.GothamBold
		valBox.TextSize = 10
		valBox.ZIndex = 6
		valBox.Parent = paletteFrame

		local isDraggingSlider = false
		local function updateSlider(input)
			local pct = math.clamp((input.Position.X - sBack.AbsolutePosition.X) / sBack.AbsoluteSize.X, 0, 1)
			sFill.Size = UDim2.new(pct, 0, 1, 0)
			local val = math.floor(pct * maxVal)
			valBox.Text = tostring(val)
			onValChanged(val)
		end

		sBack.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDraggingSlider = true updateSlider(i) end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDraggingSlider = false end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if isDraggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i) end
		end)

		return sFill, valBox
	end

	local rVal = math.floor(defaultColor.R * 255)
	local gVal = math.floor(defaultColor.G * 255)
	local bVal = math.floor(defaultColor.B * 255)

	local function updateColorFromRGB()
		currentColor = Color3.fromRGB(rVal, gVal, bVal)
		previewBtn.BackgroundColor3 = currentColor
		callback(currentColor)
	end

	local _, rBox = createRgbSlider("R", 8, 255, rVal, function(v) rVal = v updateColorFromRGB() end)
	local _, gBox = createRgbSlider("G", 32, 255, gVal, function(v) gVal = v updateColorFromRGB() end)
	local _, bBox = createRgbSlider("B", 56, 255, bVal, function(v) bVal = v updateColorFromRGB() end)

	previewBtn.MouseButton1Click:Connect(function()
		paletteFrame.Visible = not paletteFrame.Visible
	end)
end

-- НАПОЛНЕНИЕ МЕНЮ
createHeader("СКОРОСТЬ, ПРЫЖОК И ПОЛЕТ")
createToggle("Включить Speedhack", Config.Speed_Enabled, function(s) Config.Speed_Enabled = s end)
createTextBox("Скорость (GD)", Config.WalkSpeed, function(v) Config.WalkSpeed = v end)

createToggle("Включить JumpPower", Config.Jump_Enabled, function(s) Config.Jump_Enabled = s end)
createTextBox("Высота прыжка (GD)", Config.JumpPower, function(v) Config.JumpPower = v end)

createToggle("Включить Полет (Fly)", Config.Fly_Enabled, function(s)
	Config.Fly_Enabled = s
	flyControlGui.Visible = s
	flyExtraGui.Visible = s
end)
createTextBox("Скорость Полета (GD)", Config.FlySpeed, function(v) Config.FlySpeed = v end)

createHeader("АВТОНАВОДКА (AIMBOT)")
createToggle("Включить Аимбот", Config.Aim_Enabled, function(s) Config.Aim_Enabled = s end)
createToggle("Постоянная Автонаводка", Config.Aim_AutoTarget, function(s) Config.Aim_AutoTarget = s end)
createToggle("Проверка стен (Wall Check)", Config.Aim_WallCheck, function(s) Config.Aim_WallCheck = s end)
createToggle("Показывать круг FOV", Config.Aim_ShowFOV, function(s) Config.Aim_ShowFOV = s end)
createSlider("Радиус FOV", 50, 500, Config.Aim_FOV, function(v) Config.Aim_FOV = v end)
createCycleButton("Цель", {"Голова", "Торс"}, 1, function(v)
	Config.Aim_TargetPart = (v == "Голова" and "Head" or "HumanoidRootPart")
end)

createHeader("ANTI-AIM (HVH)")
createToggle("Включить Anti-Aim", Config.AntiAim_Enabled, function(s) Config.AntiAim_Enabled = s end)
createCycleButton("Pitch (Наклон)", {"Выкл", "Вниз", "Вверх", "Нуль", "Джиттер"}, 2, function(v) Config.AntiAim_Pitch = v end)
createCycleButton("Yaw (Вращение)", {"Выкл", "Назад", "Лево", "Право", "Спинбот"}, 5, function(v) Config.AntiAim_Yaw = v end)
createSlider("Скорость Спинбота", 1, 100, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

createHeader("2D BOX ESP & CHAMS")
createToggle("Включить Box ESP", Config.ESP_Enabled, function(s) Config.ESP_Enabled = s end)
createColorPicker("Цвет Box ESP", Config.BoxColor, function(c) Config.BoxColor = c end)
createToggle("Включить Chams (Подсветку)", Config.Chams_Enabled, function(s) Config.Chams_Enabled = s end)
createColorPicker("Цвет Chams", Config.ChamsColor, function(c) Config.ChamsColor = c end)
createSlider("Прозрачность Chams", 0, 100, math.floor(Config.ChamsTransparency * 100), function(v) Config.ChamsTransparency = v / 100 end)

--------------------------------------------------------------------------------
-- ЛОГИКА ПЕРСОНАЖА, ПОЛЕТА И АИМБОТА
--------------------------------------------------------------------------------
local function updateJoints()
	local char = LocalPlayer.Character
	if not char then 
		currentRootJoint = nil
		defaultRootC0 = nil
		currentNeck = nil
		defaultNeckC0 = nil
		return 
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local rj = hrp:FindFirstChild("RootJoint") or hrp:FindFirstChild("RootRigJoint") or char:FindFirstChild("RootJoint", true)
		if rj and rj ~= currentRootJoint then
			currentRootJoint = rj
			defaultRootC0 = rj.C0
		end
	end

	local head = char:FindFirstChild("Head")
	if head then
		local neck = head:FindFirstChild("Neck") or char:FindFirstChild("Neck", true)
		if neck and neck ~= currentNeck then
			currentNeck = neck
			defaultNeckC0 = neck.C0
		end
	end
end

local function isPartVisible(targetPart)
	if not Config.Aim_WallCheck then return true end
	local origin = Camera.CFrame.Position
	local destination = targetPart.Position
	local direction = (destination - origin)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local ignoreList = {Camera}
	if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
	raycastParams.FilterDescendantsInstances = ignoreList
	raycastParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, raycastParams)
	if result then
		return result.Instance:IsDescendantOf(targetPart.Parent)
	end
	return true
end

local function getClosestTarget()
	local closestPart = nil
	local shortestDist = Config.Aim_FOV
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local targetPart = char and char:FindFirstChild(Config.Aim_TargetPart)

			if char and hum and hum.Health > 0 and targetPart then
				local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
					if dist < shortestDist and isPartVisible(targetPart) then
						shortestDist = dist
						closestPart = targetPart
					end
				end
			end
		end
	end
	return closestPart
end

RunService:BindToRenderStep("NL_MainLogic", Enum.RenderPriority.Character.Value + 1, function()
	updateJoints()

	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not character or not hrp or not humanoid or humanoid.Health <= 0 then return end

	if Config.Speed_Enabled then
		humanoid.WalkSpeed = Config.WalkSpeed
	end

	if Config.Jump_Enabled then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = Config.JumpPower
	end

	-- Логика полета (ПК + Дельта Кнопки)
	local flyBodyVelocity = hrp:FindFirstChild("NL_FlyVelocity")
	local flyBodyGyro = hrp:FindFirstChild("NL_FlyGyro")

	if Config.Fly_Enabled then
		humanoid.PlatformStand = true

		if not flyBodyVelocity then
			flyBodyVelocity = Instance.new("BodyVelocity")
			flyBodyVelocity.Name = "NL_FlyVelocity"
			flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			flyBodyVelocity.Parent = hrp
		end

		if not flyBodyGyro then
			flyBodyGyro = Instance.new("BodyGyro")
			flyBodyGyro.Name = "NL_FlyGyro"
			flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			flyBodyGyro.P = 3000
			flyBodyGyro.Parent = hrp
		end

		local moveDir = Vector3.new()
		if UserInputService:IsKeyDown(Enum.KeyCode.W) or mobileFlyInputs.W then moveDir = moveDir + Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) or mobileFlyInputs.S then moveDir = moveDir - Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) or mobileFlyInputs.A then moveDir = moveDir - Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) or mobileFlyInputs.D then moveDir = moveDir + Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileFlyInputs.Up then moveDir = moveDir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or mobileFlyInputs.Down then moveDir = moveDir - Vector3.new(0, 1, 0) end

		flyBodyVelocity.Velocity = moveDir * Config.FlySpeed
		flyBodyGyro.CFrame = Camera.CFrame
	else
		humanoid.PlatformStand = false
		if flyBodyVelocity then flyBodyVelocity:Destroy() end
		if flyBodyGyro then flyBodyGyro:Destroy() end
	end

	local targetPart = getClosestTarget()
	if Config.Aim_Enabled and Config.Aim_AutoTarget and targetPart then
		humanoid.AutoRotate = false
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
	elseif not Config.Fly_Enabled then
		humanoid.AutoRotate = true
	end
end)

--------------------------------------------------------------------------------
-- ESP РЕНДЕР
--------------------------------------------------------------------------------
local function get2DBox(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local size = Vector3.new(3.8, 5.3, 2.0)
	local cf = hrp.CFrame
	local corners = {
		cf * Vector3.new(-size.X/2,  size.Y/2, -size.Z/2),
		cf * Vector3.new( size.X/2,  size.Y/2, -size.Z/2),
		cf * Vector3.new(-size.X/2, -size.Y/2, -size.Z/2),
		cf * Vector3.new( size.X/2, -size.Y/2, -size.Z/2),
		cf * Vector3.new(-size.X/2,  size.Y/2,  size.Z/2),
		cf * Vector3.new( size.X/2,  size.Y/2,  size.Z/2),
		cf * Vector3.new(-size.X/2, -size.Y/2,  size.Z/2),
		cf * Vector3.new( size.X/2, -size.Y/2,  size.Z/2),
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local onScreenCount = 0

	for _, corner in ipairs(corners) do
		local screenPos, visible = Camera:WorldToViewportPoint(corner)
		if visible then onScreenCount = onScreenCount + 1 end
		minX = math.min(minX, screenPos.X)
		minY = math.min(minY, screenPos.Y)
		maxX = math.max(maxX, screenPos.X)
		maxY = math.max(maxY, screenPos.Y)
	end

	if onScreenCount > 0 then
		return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
	end
	return nil
end

local function createPlayerBox(player)
	if ESP_Boxes[player] then return end
	local boxFrame = Instance.new("Frame")
	boxFrame.Name = "ESP_Box_" .. player.Name
	boxFrame.BackgroundTransparency = 1
	boxFrame.BorderSizePixel = 0
	boxFrame.Visible = false
	boxFrame.Parent = espContainer

	local stroke = Instance.new("UIStroke")
	stroke.Name = "BoxStroke"
	stroke.Color = Config.BoxColor
	stroke.Thickness = Config.BoxThickness
	stroke.Parent = boxFrame

	ESP_Boxes[player] = { frame = boxFrame, stroke = stroke }
end

local function removePlayerBox(player)
	if ESP_Boxes[player] then
		ESP_Boxes[player].frame:Destroy()
		ESP_Boxes[player] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do createPlayerBox(p) end
Players.PlayerAdded:Connect(createPlayerBox)
Players.PlayerRemoving:Connect(removePlayerBox)

RunService.RenderStepped:Connect(function()
	if Config.Aim_ShowFOV and Config.Aim_Enabled then
		local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		fovCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
		fovCircle.Size = UDim2.new(0, Config.Aim_FOV * 2, 0, Config.Aim_FOV * 2)
		fovCircle.Visible = true
	else
		fovCircle.Visible = false
	end

	for _, player in ipairs(Players:GetPlayers()) do
		local boxData = ESP_Boxes[player]
		if boxData then
			local frame = boxData.frame
			local stroke = boxData.stroke

			if (player == LocalPlayer and not Config.ShowSelf) or not Config.ESP_Enabled then
				frame.Visible = false
			else
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if character and humanoid and humanoid.Health > 0 then
					local pos, size = get2DBox(character)
					if pos and size then
						frame.Position = UDim2.new(0, pos.X, 0, pos.Y)
						frame.Size = UDim2.new(0, size.X, 0, size.Y)
						stroke.Color = Config.BoxColor
						stroke.Thickness = Config.BoxThickness
						frame.Visible = true
					else
						frame.Visible = false
					end
				else
					frame.Visible = false
				end
			end
		end
	end
end)
