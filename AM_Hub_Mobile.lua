--// AM Hub Mobile
--// Luau / LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- 彩色流光颜色
--==================================================

local rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120))
})

--==================================================
-- 悬浮球
--==================================================

local AMButton = Instance.new("TextButton")
AMButton.Name = "AMButton"
AMButton.Size = UDim2.fromOffset(58, 58)
AMButton.Position = UDim2.new(0, 20, 0.5, -29)

-- 白色
AMButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AMButton.BackgroundTransparency = 0.05

AMButton.BorderSizePixel = 0
AMButton.Text = "AM"
AMButton.TextColor3 = Color3.fromRGB(20, 20, 20)
AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold
AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.Parent = ScreenGui

local AMCorner = Instance.new("UICorner")
AMCorner.CornerRadius = UDim.new(1, 0)
AMCorner.Parent = AMButton

--==================================================
-- 悬浮球彩色流光边框
--==================================================

local AMStroke = Instance.new("UIStroke")
AMStroke.Name = "RainbowStroke"
AMStroke.Thickness = 3
AMStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")
AMGradient.Name = "RainbowGradient"
AMGradient.Color = rainbow
AMGradient.Rotation = 0
AMGradient.Parent = AMStroke

--==================================================
-- 菜单
-- 360dp 参考宽度
-- 菜单宽度 = 250dp
--==================================================

local Menu = Instance.new("Frame")
Menu.Name = "Menu"

-- 250dp
Menu.Size = UDim2.fromOffset(250, 270)

Menu.Position = UDim2.new(0, 90, 0.5, -135)

-- 白色菜单
Menu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Menu.BackgroundTransparency = 0.05

Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 15)
MenuCorner.Parent = Menu

--==================================================
-- 菜单彩色流光边框
--==================================================

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Name = "RainbowStroke"
MenuStroke.Thickness = 3
MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")
MenuGradient.Name = "RainbowGradient"
MenuGradient.Color = rainbow
MenuGradient.Rotation = 0
MenuGradient.Parent = MenuStroke

--==================================================
-- 菜单标题
--==================================================

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -60, 0, 45)
Title.Position = UDim2.fromOffset(15, 7)
Title.BackgroundTransparency = 1
Title.Text = "AM Hub"
Title.TextColor3 = Color3.fromRGB(20, 20, 20)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Menu

--==================================================
-- 菜单拖动区域
--==================================================

local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"

-- 覆盖标题区域
DragArea.Size = UDim2.new(1, -50, 0, 50)
DragArea.Position = UDim2.fromOffset(0, 0)

DragArea.BackgroundTransparency = 1
DragArea.Text = ""
DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.Parent = Menu

--==================================================
-- 关闭按钮
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.fromOffset(35, 35)
CloseButton.Position = UDim2.new(1, -42, 0, 7)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Menu

CloseButton.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

--==================================================
-- 功能按钮
--==================================================

local TestButton = Instance.new("TextButton")
TestButton.Name = "TestButton"
TestButton.Size = UDim2.new(1, -30, 0, 45)
TestButton.Position = UDim2.fromOffset(15, 65)

TestButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
TestButton.BackgroundTransparency = 0

TestButton.BorderSizePixel = 0
TestButton.Text = "功能 1"
TestButton.TextColor3 = Color3.fromRGB(25, 25, 25)
TestButton.TextSize = 16
TestButton.Font = Enum.Font.Gotham
TestButton.AutoButtonColor = false
TestButton.Parent = Menu

local TestCorner = Instance.new("UICorner")
TestCorner.CornerRadius = UDim.new(0, 9)
TestCorner.Parent = TestButton

local TestStroke = Instance.new("UIStroke")
TestStroke.Color = Color3.fromRGB(220, 220, 220)
TestStroke.Thickness = 1
TestStroke.Parent = TestButton

TestButton.MouseButton1Click:Connect(function()
	print("功能 1")
end)

--==================================================
-- 第二个示例按钮
--==================================================

local TestButton2 = Instance.new("TextButton")
TestButton2.Name = "TestButton2"
TestButton2.Size = UDim2.new(1, -30, 0, 45)
TestButton2.Position = UDim2.fromOffset(15, 120)

TestButton2.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
TestButton2.BackgroundTransparency = 0

TestButton2.BorderSizePixel = 0
TestButton2.Text = "功能 2"
TestButton2.TextColor3 = Color3.fromRGB(25, 25, 25)
TestButton2.TextSize = 16
TestButton2.Font = Enum.Font.Gotham
TestButton2.AutoButtonColor = false
TestButton2.Parent = Menu

local TestCorner2 = Instance.new("UICorner")
TestCorner2.CornerRadius = UDim.new(0, 9)
TestCorner2.Parent = TestButton2

local TestStroke2 = Instance.new("UIStroke")
TestStroke2.Color = Color3.fromRGB(220, 220, 220)
TestStroke2.Thickness = 1
TestStroke2.Parent = TestButton2

TestButton2.MouseButton1Click:Connect(function()
	print("功能 2")
end)

--==================================================
-- 悬浮球拖动 / 点击
--==================================================

local buttonDragging = false
local buttonDragStart
local buttonStartPosition
local buttonMoved = false

AMButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		buttonDragging = true
		buttonMoved = false

		buttonDragStart = input.Position
		buttonStartPosition = AMButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not buttonDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - buttonDragStart

		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
			buttonMoved = true
		end

		AMButton.Position = UDim2.new(
			buttonStartPosition.X.Scale,
			buttonStartPosition.X.Offset + delta.X,
			buttonStartPosition.Y.Scale,
			buttonStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		if buttonDragging and not buttonMoved then
			Menu.Visible = not Menu.Visible
		end

		buttonDragging = false
	end
end)

--==================================================
-- 菜单拖动
--==================================================

local menuDragging = false
local menuDragStart
local menuStartPosition

DragArea.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		menuDragging = true

		menuDragStart = input.Position
		menuStartPosition = Menu.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not menuDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - menuDragStart

		Menu.Position = UDim2.new(
			menuStartPosition.X.Scale,
			menuStartPosition.X.Offset + delta.X,
			menuStartPosition.Y.Scale,
			menuStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		menuDragging = false
	end
end)

--==================================================
-- 彩色流光动画
--==================================================

local rotation = 0

RunService.RenderStepped:Connect(function(dt)

	rotation = (rotation + dt * 100) % 360

	AMGradient.Rotation = rotation
	MenuGradient.Rotation = rotation
end)
