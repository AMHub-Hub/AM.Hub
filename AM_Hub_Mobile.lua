--// AM Hub Mobile
--// Luau / LocalScript
--// 设计基准：360dp
--// 菜单宽度：250dp
--// 悬浮球：58dp

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- 设计参数
--==================================================

local DESIGN_WIDTH = 360

local MENU_WIDTH_DP = 250
local MENU_HEIGHT_DP = 270

local FLOATING_SIZE_DP = 58

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- UI 缩放
--==================================================

local UIScale = Instance.new("UIScale")
UIScale.Name = "DesignScale"
UIScale.Parent = ScreenGui

local function UpdateScale()
	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	-- 按屏幕宽度计算缩放
	local scale = viewport.X / DESIGN_WIDTH

	-- 防止在极端设备上缩得太小
	scale = math.clamp(scale, 0.75, 2.0)

	UIScale.Scale = scale
end

UpdateScale()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()

	if workspace.CurrentCamera then
		UpdateScale()

		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
	end
end)

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
end

--==================================================
-- 彩色流光
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

-- 58dp
AMButton.Size = UDim2.fromOffset(
	FLOATING_SIZE_DP,
	FLOATING_SIZE_DP
)

AMButton.Position = UDim2.new(
	0,
	20,
	0.5,
	-29
)

AMButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AMButton.BackgroundTransparency = 0.05

AMButton.BorderSizePixel = 0

AMButton.Text = "AM"
AMButton.TextColor3 = Color3.fromRGB(20, 20, 20)
AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold

AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.ZIndex = 10
AMButton.Parent = ScreenGui

local AMCorner = Instance.new("UICorner")
AMCorner.CornerRadius = UDim.new(1, 0)
AMCorner.Parent = AMButton

--==================================================
-- 悬浮球流光边框
--==================================================

local AMStroke = Instance.new("UIStroke")
AMStroke.Name = "RainbowStroke"
AMStroke.Thickness = 3
AMStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")
AMGradient.Name = "RainbowGradient"
AMGradient.Color = rainbow
AMGradient.Parent = AMStroke

--==================================================
-- 菜单
--==================================================

local Menu = Instance.new("Frame")
Menu.Name = "Menu"

-- 250dp × 270dp
Menu.Size = UDim2.fromOffset(
	MENU_WIDTH_DP,
	MENU_HEIGHT_DP
)

-- 初始位置
Menu.Position = UDim2.new(
	0,
	90,
	0.5,
	-MENU_HEIGHT_DP / 2
)

Menu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Menu.BackgroundTransparency = 0.04

Menu.BorderSizePixel = 0

Menu.Visible = false
Menu.Active = true
Menu.ZIndex = 5

Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 15)
MenuCorner.Parent = Menu

--==================================================
-- 菜单流光边框
--==================================================

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Name = "RainbowStroke"
MenuStroke.Thickness = 3
MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")
MenuGradient.Name = "RainbowGradient"
MenuGradient.Color = rainbow
MenuGradient.Parent = MenuStroke

--==================================================
-- 标题
--==================================================

local Title = Instance.new("TextLabel")
Title.Name = "Title"

Title.Size = UDim2.new(
	1,
	-60,
	0,
	45
)

Title.Position = UDim2.fromOffset(15, 7)

Title.BackgroundTransparency = 1

Title.Text = "AM Hub"
Title.TextColor3 = Color3.fromRGB(20, 20, 20)

Title.TextSize = 21
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 7

Title.Parent = Menu

--==================================================
-- 菜单拖动区域
--==================================================

local DragArea = Instance.new("TextButton")
DragArea.Name = "DragArea"

DragArea.Size = UDim2.new(
	1,
	-50,
	0,
	50
)

DragArea.Position = UDim2.fromOffset(0, 0)

DragArea.BackgroundTransparency = 1
DragArea.Text = ""

DragArea.AutoButtonColor = false
DragArea.Active = true
DragArea.ZIndex = 8

DragArea.Parent = Menu

--==================================================
-- 关闭按钮
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"

CloseButton.Size = UDim2.fromOffset(35, 35)

CloseButton.Position = UDim2.new(
	1,
	-42,
	0,
	7
)

CloseButton.BackgroundTransparency = 1

CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(25, 25, 25)

CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.GothamBold

CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 10

CloseButton.Parent = Menu

CloseButton.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

--==================================================
-- 创建功能按钮
--==================================================

local function CreateButton(name, text, y)

	local Button = Instance.new("TextButton")

	Button.Name = name

	Button.Size = UDim2.new(
		1,
		-30,
		0,
		45
	)

	Button.Position = UDim2.fromOffset(
		15,
		y
	)

	Button.BackgroundColor3 = Color3.fromRGB(
		245,
		245,
		245
	)

	Button.BackgroundTransparency = 0

	Button.BorderSizePixel = 0

	Button.Text = text

	Button.TextColor3 = Color3.fromRGB(
		25,
		25,
		25
	)

	Button.TextSize = 16
	Button.Font = Enum.Font.Gotham

	Button.AutoButtonColor = false

	Button.ZIndex = 7

	Button.Parent = Menu

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 9)
	Corner.Parent = Button

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(220, 220, 220)
	Stroke.Thickness = 1
	Stroke.Parent = Button

	return Button
end

--==================================================
-- 功能按钮
--==================================================

local Function1 = CreateButton(
	"Function1",
	"功能 1",
	65
)

Function1.MouseButton1Click:Connect(function()
	print("功能 1")
end)

local Function2 = CreateButton(
	"Function2",
	"功能 2",
	120
)

Function2.MouseButton1Click:Connect(function()
	print("功能 2")
end)

local Function3 = CreateButton(
	"Function3",
	"功能 3",
	175
)

Function3.MouseButton1Click:Connect(function()
	print("功能 3")
end)

--==================================================
-- 悬浮球拖动
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

		if math.abs(delta.X) > 6
			or math.abs(delta.Y) > 6 then

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
