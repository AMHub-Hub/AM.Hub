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
-- AM 悬浮球
--==================================================

local AMButton = Instance.new("TextButton")
AMButton.Name = "AMButton"
AMButton.Size = UDim2.fromOffset(58, 58)
AMButton.Position = UDim2.new(0, 25, 0.5, -29)
AMButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AMButton.BackgroundTransparency = 0.18
AMButton.BorderSizePixel = 0
AMButton.Text = "AM"
AMButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold
AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.Parent = ScreenGui

local AMCorner = Instance.new("UICorner")
AMCorner.CornerRadius = UDim.new(1, 0)
AMCorner.Parent = AMButton

local AMStroke = Instance.new("UIStroke")
AMStroke.Thickness = 3
AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")
AMGradient.Color = rainbow
AMGradient.Parent = AMStroke

--==================================================
-- 功能菜单
--==================================================

local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromOffset(230, 250)
Menu.Position = UDim2.new(0, 95, 0.5, -125)
Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Menu.BackgroundTransparency = 0.12
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 15)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 3
MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")
MenuGradient.Color = rainbow
MenuGradient.Parent = MenuStroke

--==================================================
-- 菜单标题
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "AM Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu

--==================================================
-- 临时功能按钮
--==================================================

local TestButton = Instance.new("TextButton")
TestButton.Size = UDim2.new(1, -30, 0, 45)
TestButton.Position = UDim2.fromOffset(15, 60)
TestButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TestButton.BackgroundTransparency = 0.15
TestButton.BorderSizePixel = 0
TestButton.Text = "功能 1"
TestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TestButton.TextSize = 16
TestButton.Font = Enum.Font.Gotham
TestButton.Parent = Menu

local TestCorner = Instance.new("UICorner")
TestCorner.CornerRadius = UDim.new(0, 9)
TestCorner.Parent = TestButton

TestButton.MouseButton1Click:Connect(function()
	print("功能 1")
end)

--==================================================
-- 关闭菜单按钮
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(35, 35)
CloseButton.Position = UDim2.new(1, -42, 0, 7)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Menu

CloseButton.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

--==================================================
-- 点击 / 拖动判断
--==================================================

local dragging = false
local dragStart
local startPosition
local moved = false

AMButton.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		moved = false

		dragStart = input.Position
		startPosition = AMButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		-- 移动超过一定距离才算拖动
		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
			moved = true
		end

		AMButton.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		if dragging and not moved then
			Menu.Visible = not Menu.Visible
		end

		dragging = false
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
