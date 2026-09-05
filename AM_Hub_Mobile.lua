--// AM Hub Mobile
--// Luau / LocalScript
--// Mobile UI
--// 无 DP / 无 UIScale
--// 直接使用 Roblox Offset 尺寸

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- 基础设置
--==================================================

local MENU_WIDTH = 280
local MENU_HEIGHT = 330

local FLOAT_SIZE = 58

-- 在这里填写你的 QQ 群号
local QQ_GROUP = "179051448"

--==================================================
-- ScreenGui
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- 彩虹颜色
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
-- 工具函数
--==================================================

local function AddCorner(object, radius)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object

	return corner

end

local function AddStroke(object, color, thickness)

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Parent = object

	return stroke

end

--==================================================
-- 悬浮球
--==================================================

local AMButton = Instance.new("TextButton")

AMButton.Name = "AMButton"

AMButton.Size = UDim2.fromOffset(
	FLOAT_SIZE,
	FLOAT_SIZE
)

AMButton.Position = UDim2.new(
	0,
	18,
	0.5,
	-29
)

AMButton.BackgroundColor3 =
	Color3.fromRGB(255, 255, 255)

AMButton.BackgroundTransparency = 0.03

AMButton.BorderSizePixel = 0

AMButton.Text = "AM"

AMButton.TextColor3 =
	Color3.fromRGB(20, 20, 20)

AMButton.TextSize = 19

AMButton.Font =
	Enum.Font.GothamBold

AMButton.AutoButtonColor = false

AMButton.Active = true

AMButton.ZIndex = 100

AMButton.Parent = ScreenGui

AddCorner(AMButton, 100)

--==================================================
-- 悬浮球流光
--==================================================

local AMStroke = Instance.new("UIStroke")

AMStroke.Name = "RainbowStroke"

AMStroke.Thickness = 3

AMStroke.ApplyStrokeMode =
	Enum.ApplyStrokeMode.Border

AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")

AMGradient.Color = rainbow

AMGradient.Parent = AMStroke

--==================================================
-- 菜单
--==================================================

local Menu = Instance.new("Frame")

Menu.Name = "Menu"

Menu.Size = UDim2.fromOffset(
	MENU_WIDTH,
	MENU_HEIGHT
)

Menu.Position = UDim2.new(
	0,
	88,
	0.5,
	-MENU_HEIGHT / 2
)

Menu.BackgroundColor3 =
	Color3.fromRGB(255, 255, 255)

Menu.BackgroundTransparency = 0.02

Menu.BorderSizePixel = 0

Menu.Visible = false

Menu.Active = true

Menu.ZIndex = 10

Menu.Parent = ScreenGui

AddCorner(Menu, 16)

--==================================================
-- 菜单流光边框
--==================================================

local MenuStroke = Instance.new("UIStroke")

MenuStroke.Name = "RainbowStroke"

MenuStroke.Thickness = 3

MenuStroke.ApplyStrokeMode =
	Enum.ApplyStrokeMode.Border

MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")

MenuGradient.Color = rainbow

MenuGradient.Parent = MenuStroke

--==================================================
-- 顶部标题栏
--==================================================

local Header = Instance.new("Frame")

Header.Name = "Header"

Header.Size = UDim2.new(
	1,
	0,
	0,
	48
)

Header.Position =
	UDim2.fromOffset(0, 0)

Header.BackgroundTransparency = 1

Header.ZIndex = 20

Header.Parent = Menu

--==================================================
-- 标题
--==================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(
	1,
	-55,
	1,
	0
)

Title.Position =
	UDim2.fromOffset(15, 0)

Title.BackgroundTransparency = 1

Title.Text = "AM Hub"

Title.TextColor3 =
	Color3.fromRGB(20, 20, 20)

Title.TextSize = 21

Title.Font =
	Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.ZIndex = 21

Title.Parent = Header

--==================================================
-- 关闭按钮
--==================================================

local CloseButton = Instance.new("TextButton")

CloseButton.Name = "CloseButton"

CloseButton.Size =
	UDim2.fromOffset(38, 38)

CloseButton.Position =
	UDim2.new(
		1,
		-43,
		0,
		5
	)

CloseButton.BackgroundTransparency = 1

CloseButton.Text = "×"

CloseButton.TextColor3 =
	Color3.fromRGB(30, 30, 30)

CloseButton.TextSize = 27

CloseButton.Font =
	Enum.Font.GothamBold

CloseButton.AutoButtonColor = false

CloseButton.ZIndex = 30

CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()

	Menu.Visible = false

end)

--==================================================
-- 左侧分类
--==================================================

local CategoryBar = Instance.new("Frame")

CategoryBar.Name = "CategoryBar"

CategoryBar.Size = UDim2.new(
	0,
	82,
	1,
	-58
)

CategoryBar.Position =
	UDim2.fromOffset(6, 52)

CategoryBar.BackgroundColor3 =
	Color3.fromRGB(245, 245, 245)

CategoryBar.BorderSizePixel = 0

CategoryBar.ZIndex = 15

CategoryBar.Parent = Menu

AddCorner(CategoryBar, 11)

--==================================================
-- 右侧内容
--==================================================

local Content = Instance.new("ScrollingFrame")

Content.Name = "Content"

Content.Size = UDim2.new(
	1,
	-97,
	1,
	-58
)

Content.Position =
	UDim2.fromOffset(91, 52)

Content.BackgroundTransparency = 1

Content.BorderSizePixel = 0

Content.ScrollBarThickness = 4

Content.ScrollBarImageColor3 =
	Color3.fromRGB(160, 160, 160)

Content.ScrollingDirection =
	Enum.ScrollingDirection.Y

Content.ZIndex = 15

Content.Parent = Menu

local ContentLayout = Instance.new("UIListLayout")

ContentLayout.Padding =
	UDim.new(0, 7)

ContentLayout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(function()

	Content.CanvasSize = UDim2.fromOffset(
		0,
		ContentLayout.AbsoluteContentSize.Y + 12
	)

end)

--==================================================
-- 清理内容
--==================================================

local function ClearContent()

	for _, object in ipairs(Content:GetChildren()) do

		if not object:IsA("UIListLayout") then

			object:Destroy()

		end

	end

	Content.CanvasPosition = Vector2.new(0, 0)

end

--==================================================
-- 标题
--==================================================

local function CreateSectionTitle(text)

	local label = Instance.new("TextLabel")

	label.Size =
		UDim2.new(1, -10, 0, 30)

	label.BackgroundTransparency = 1

	label.Text = text

	label.TextColor3 =
		Color3.fromRGB(20, 20, 20)

	label.TextSize = 17

	label.Font =
		Enum.Font.GothamBold

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.ZIndex = 20

	label.Parent = Content

	return label

end

--==================================================
-- 普通按钮
--==================================================

local function CreateButton(text, callback)

	local button = Instance.new("TextButton")

	button.Size =
		UDim2.new(1, -10, 0, 42)

	button.BackgroundColor3 =
		Color3.fromRGB(245, 245, 245)

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.fromRGB(25, 25, 25)

	button.TextSize = 14

	button.Font =
		Enum.Font.Gotham

	button.AutoButtonColor = true

	button.ZIndex = 20

	button.Parent = Content

	AddCorner(button, 9)

	AddStroke(
		button,
		Color3.fromRGB(220, 220, 220),
		1
	)

	if callback then

		button.MouseButton1Click:Connect(
			callback
		)

	end

	return button

end

--==================================================
-- 开关
--==================================================

local function CreateToggle(text, default, callback)

	local button = Instance.new("TextButton")

	button.Size =
		UDim2.new(1, -10, 0, 42)

	button.BackgroundColor3 =
		Color3.fromRGB(245, 245, 245)

	button.BorderSizePixel = 0

	button.TextSize = 14

	button.Font =
		Enum.Font.GothamBold

	button.AutoButtonColor = false

	button.ZIndex = 20

	button.Parent = Content

	AddCorner(button, 9)

	local enabled = default or false

	local function Refresh()

		if enabled then

			button.Text =
				text .. "    ● 开启"

			button.TextColor3 =
				Color3.fromRGB(0, 150, 80)

			button.BackgroundColor3 =
				Color3.fromRGB(235, 250, 240)

		else

			button.Text =
				text .. "    ○ 关闭"

			button.TextColor3 =
				Color3.fromRGB(50, 50, 50)

			button.BackgroundColor3 =
				Color3.fromRGB(245, 245, 245)

		end

	end

	Refresh()

	button.MouseButton1Click:Connect(function()

		enabled = not enabled

		Refresh()

		if callback then

			callback(enabled)

		end

	end)

	return button

end

--==================================================
-- 滑块
--==================================================

local function CreateSlider(
	text,
	minimum,
	maximum,
	default,
	callback
)

	local holder = Instance.new("Frame")

	holder.Size =
		UDim2.new(1, -10, 0, 60)

	holder.BackgroundColor3 =
		Color3.fromRGB(245, 245, 245)

	holder.BorderSizePixel = 0

	holder.ZIndex = 20

	holder.Parent = Content

	AddCorner(holder, 9)

	local label = Instance.new("TextLabel")

	label.Size =
		UDim2.new(1, -16, 0, 24)

	label.Position =
		UDim2.fromOffset(8, 3)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		Color3.fromRGB(30, 30, 30)

	label.TextSize = 13

	label.Font =
		Enum.Font.Gotham

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.ZIndex = 21

	label.Parent = holder

	local bar = Instance.new("Frame")

	bar.Size =
		UDim2.new(1, -20, 0, 7)

	bar.Position =
		UDim2.fromOffset(10, 38)

	bar.BackgroundColor3 =
		Color3.fromRGB(215, 215, 215)

	bar.BorderSizePixel = 0

	bar.ZIndex = 21

	bar.Parent = holder

	AddCorner(bar, 10)

	local fill = Instance.new("Frame")

	fill.Size =
		UDim2.new(0, 0, 1, 0)

	fill.BackgroundColor3 =
		Color3.fromRGB(80, 80, 80)

	fill.BorderSizePixel = 0

	fill.ZIndex = 22

	fill.Parent = bar

	AddCorner(fill, 10)

	local knob = Instance.new("Frame")

	knob.Size =
		UDim2.fromOffset(15, 15)

	knob.AnchorPoint =
		Vector2.new(.5, .5)

	knob.Position =
		UDim2.new(0, 0, .5, 0)

	knob.BackgroundColor3 =
		Color3.fromRGB(50, 50, 50)

	knob.BorderSizePixel = 0

	knob.ZIndex = 23

	knob.Parent = bar

	AddCorner(knob, 20)

	local dragging = false

	local value = default

	local function SetValue(newValue)

		value = math.clamp(
			newValue,
			minimum,
			maximum
		)

		local percent =
			(value - minimum) /
			(maximum - minimum)

		fill.Size =
			UDim2.new(
				percent,
				0,
				1,
				0
			)

		knob.Position =
			UDim2.new(
				percent,
				0,
				0.5,
				0
			)

		label.Text =
			text .. " : " ..
			math.floor(value)

		if callback then

			callback(value)

		end

	end

	local function UpdateFromInput(input)

		local x =
			input.Position.X -
			bar.AbsolutePosition.X

		local percent =
			math.clamp(
				x / bar.AbsoluteSize.X,
				0,
				1
			)

		SetValue(
			minimum +
			(maximum - minimum) *
			percent
		)

	end

	bar.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch
			or input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging = true

			UpdateFromInput(input)

		end

	end)

	UserInputService.InputChanged:Connect(function(input)

		if not dragging then
			return
		end

		if input.UserInputType ==
			Enum.UserInputType.Touch
			or input.UserInputType ==
			Enum.UserInputType.MouseMovement then

			UpdateFromInput(input)

		end

	end)

	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch
			or input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging = false

		end

	end)

	SetValue(default)

	return holder

end

--==================================================
-- 信息
--==================================================

local function ShowInfo()

	ClearContent()

	CreateSectionTitle(
		"信息"
	)

	CreateButton(
		"欢迎使用 AM Hub"
	)

	local accountAge =
		player.AccountAge

	local years =
		math.floor(accountAge / 365)

	local days =
		accountAge % 365

	CreateButton(
		"Roblox 账户年龄：" ..
		years ..
		" 年 " ..
		days ..
		" 天"
	)

	CreateButton(
		"用户名：" ..
		player.Name
	)

	CreateButton(
		"QQ 群：" ..
		QQ_GROUP
	)

	CreateButton(
		"AM Mobile"
	)

end

--==================================================
-- 通用
--==================================================

local function ShowGeneral()

	ClearContent()

	CreateSectionTitle(
		"通用"
	)

	CreateToggle(
		"飞行",
		false,
		function(enabled)

			print(
				"飞行：",
				enabled
			)

		end
	)

	CreateToggle(
		"夜视",
		false,
		function(enabled)

			if enabled then

				Lighting.Brightness = 2
				Lighting.ClockTime = 14

			else

				Lighting.Brightness = 1

			end

		end
	)

	CreateSlider(
		"移速",
		0,
		300,
		16,
		function(value)

			local character =
				player.Character

			local humanoid =
				character and
				character:FindFirstChildOfClass(
					"Humanoid"
				)

			if humanoid then

				humanoid.WalkSpeed =
					value

			end

		end
	)

	CreateButton(
		"移动方式",
		function()

			print(
				"移动方式选择"
			)

		end
	)

	CreateSlider(
		"跳高",
		0,
		300,
		50,
		function(value)

			local character =
				player.Character

			local humanoid =
				character and
				character:FindFirstChildOfClass(
					"Humanoid"
				)

			if humanoid then

				humanoid.JumpPower =
					value

			end

		end
	)

	CreateSlider(
		"重力",
		0,
		300,
		196,
		function(value)

			workspace.Gravity =
				value

		end
	)

	CreateToggle(
		"点击屏幕瞬移",
		false,
		function(enabled)

			print(
				"点击瞬移：",
				enabled
			)

		end
	)

	CreateToggle(
		"踏空飞行",
		false,
		function(enabled)

			print(
				"踏空飞行：",
				enabled
			)

		end
	)

	CreateToggle(
		"锁定视角",
		false,
		function(enabled)

			if enabled then

				UserInputService.MouseBehavior =
					Enum.MouseBehavior.LockCenter

			else

				UserInputService.MouseBehavior =
					Enum.MouseBehavior.Default

			end

		end
	)

	CreateButton(
		"退出服务器",
		function()

			player:Kick(
				"已退出服务器"
			)

		end
	)

	CreateButton(
		"重新选择服务器",
		function()

			print(
				"重新选择服务器"
			)

		end
	)

end

--==================================================
-- 战斗
--==================================================

local function ShowCombat()

	ClearContent()

	CreateSectionTitle(
		"战斗"
	)

	CreateToggle(
		"透视",
		false,
		function(enabled)

			print(
				"透视状态：",
				enabled
			)

		end
	)

	CreateSlider(
		"范围",
		0,
		1500,
		150,
		function(value)

			print(
				"范围：",
				value
			)

		end
	)

	CreateSlider(
		"自瞄 FOV",
		1,
		180,
		90,
		function(value)

			print(
				"FOV：",
				value
			)

		end
	)

	CreateToggle(
		"子弹追踪",
		false,
		function(enabled)

			print(
				"子弹追踪：",
				enabled
			)

		end
	)

	CreateToggle(
		"无限子弹",
		false,
		function(enabled)

			print(
				"无限子弹：",
				enabled
			)

		end
	)

	CreateButton(
		"敌对颜色：红色",
		function()

			print(
				"敌对颜色"
			)

		end
	)

	CreateButton(
		"我方颜色：蓝色",
		function()

			print(
				"我方颜色"
			)

		end
	)

	CreateButton(
		"自定义颜色",
		function()

			print(
				"颜色选择器"
			)

		end
	)

end

--==================================================
-- 娱乐
--==================================================

local function ShowEntertainment()

	ClearContent()

	CreateSectionTitle(
		"娱乐"
	)

	CreateSlider(
		"FPS",
		1,
		100,
		60,
		function(value)

			print(
				"FPS：",
				value
			)

		end
	)

end

--==================================================
-- FE
--==================================================

local function ShowFE()

	ClearContent()

	CreateSectionTitle(
		"FE"
	)

	CreateButton(
		"选择玩家",
		function()

			print(
				"玩家选择器"
			)

		end
	)

	CreateButton(
		"甩飞",
		function()

			print(
				"甩飞"
			)

		end
	)

	CreateButton(
		"传送",
		function()

			print(
				"传送"
			)

		end
	)

	CreateToggle(
		"环绕",
		false,
		function(enabled)

			print(
				"环绕：",
				enabled
			)

		end
	)

	CreateSlider(
		"环绕速度",
		1,
		100,
		10,
		function(value)

			print(
				"环绕速度：",
				value
			)

		end
	)

	CreateButton(
		"客户端传送",
		function()

			print(
				"客户端传送"
			)

		end
	)

end

--==================================================
-- 特效
--==================================================

local function ShowEffects()

	ClearContent()

	CreateSectionTitle(
		"特效"
	)

	CreateToggle(
		"AM 使用者",
		false,
		function(enabled)

			print(
				"AM 使用者：",
				enabled
			)

		end
	)

	CreateToggle(
		"金身",
		false,
		function(enabled)

			local character =
				player.Character

			if not character then
				return
			end

			for _, object in ipairs(
				character:GetChildren()
			) do

				if object:IsA(
					"BasePart"
				) then

					if enabled then

						object.Color =
							Color3.fromRGB(
								255,
								200,
								40
							)

					else

						object.Color =
							Color3.fromRGB(
								255,
								255,
								255
							)

					end

				end

			end

		end
	)

	CreateToggle(
		"头顶火焰",
		false,
		function(enabled)

			local character =
				player.Character

			if not character then
				return
			end

			local head =
				character:FindFirstChild(
					"Head"
				)

			if not head then
				return
			end

			local old =
				head:FindFirstChild(
					"AM_Fire"
				)

			if old then

				old:Destroy()

			end

			if enabled then

				local fire =
					Instance.new("Fire")

				fire.Name =
					"AM_Fire"

				fire.Heat = 8
				fire.Size = 6

				fire.Parent =
					head

			end

		end
	)

	CreateToggle(
		"冰霜移动拖尾",
		false,
		function(enabled)

			print(
				"冰霜拖尾：",
				enabled
			)

		end
	)

end

--==================================================
-- 设置
--==================================================

local function ShowSettings()

	ClearContent()

	CreateSectionTitle(
		"设置"
	)

	CreateButton(
		"退出 AM",
		function()

			ScreenGui:Destroy()

		end
	)

end

--==================================================
-- 分类
--==================================================

local Categories = {
	"信息",
	"通用",
	"战斗",
	"娱乐",
	"FE",
	"特效",
	"设置"
}

local CategoryButtons = {}

local Pages = {

	["信息"] =
		ShowInfo,

	["通用"] =
		ShowGeneral,

	["战斗"] =
		ShowCombat,

	["娱乐"] =
		ShowEntertainment,

	["FE"] =
		ShowFE,

	["特效"] =
		ShowEffects,

	["设置"] =
		ShowSettings
}

local function SelectCategory(name)

	for category, button in pairs(
		CategoryButtons
	) do

		if category == name then

			button.BackgroundColor3 =
				Color3.fromRGB(
					220,
					220,
					220
				)

			button.TextColor3 =
				Color3.fromRGB(
					10,
					10,
					10
				)

		else

			button.BackgroundColor3 =
				Color3.fromRGB(
					245,
					245,
					245
				)

			button.TextColor3 =
				Color3.fromRGB(
					90,
					90,
					90
				)

		end

	end

	local page =
		Pages[name]

	if page then

		page()

	end

end

--==================================================
-- 创建分类按钮
--==================================================

for index, name in ipairs(
	Categories
) do

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-10,
			0,
			36
		)

	button.Position =
		UDim2.fromOffset(
			5,
			5 + (index - 1) * 41
		)

	button.BackgroundColor3 =
		Color3.fromRGB(
			245,
			245,
			245
		)

	button.BorderSizePixel = 0

	button.Text = name

	button.TextSize = 12

	button.Font =
		Enum.Font.GothamBold

	button.TextColor3 =
		Color3.fromRGB(
			90,
			90,
			90
		)

	button.AutoButtonColor = false

	button.ZIndex = 20

	button.Parent =
		CategoryBar

	AddCorner(button, 8)

	CategoryButtons[name] =
		button

	button.MouseButton1Click:Connect(
		function()

			SelectCategory(name)

		end
	)

end

--==================================================
-- 菜单拖动
-- 只允许拖顶部标题栏
-- 不会挡住下面的按钮
--==================================================

local menuDragging = false

local menuDragStart
local menuStartPosition

Header.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		menuDragging = true

		menuDragStart =
			input.Position

		menuStartPosition =
			Menu.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not menuDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta =
			input.Position -
			menuDragStart

		Menu.Position =
			UDim2.new(
				menuStartPosition.X.Scale,
				menuStartPosition.X.Offset +
					delta.X,

				menuStartPosition.Y.Scale,
				menuStartPosition.Y.Offset +
					delta.Y
			)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		menuDragging = false

	end

end)

--==================================================
-- 悬浮球拖动
--==================================================

local buttonDragging = false

local buttonDragStart
local buttonStartPosition

local buttonMoved = false

AMButton.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		buttonDragging = true

		buttonMoved = false

		buttonDragStart =
			input.Position

		buttonStartPosition =
			AMButton.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not buttonDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta =
			input.Position -
			buttonDragStart

		if math.abs(delta.X) > 6
			or math.abs(delta.Y) > 6 then

			buttonMoved = true

		end

		AMButton.Position =
			UDim2.new(
				buttonStartPosition.X.Scale,
				buttonStartPosition.X.Offset +
					delta.X,

				buttonStartPosition.Y.Scale,
				buttonStartPosition.Y.Offset +
					delta.Y
			)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		if buttonDragging
			and not buttonMoved then

			Menu.Visible =
				not Menu.Visible

		end

		buttonDragging = false

	end

end)

--==================================================
-- 彩色流光
--==================================================

local rotation = 0

RunService.RenderStepped:Connect(function(dt)

	rotation =
		(rotation + dt * 100) % 360

	AMGradient.Rotation =
		rotation

	MenuGradient.Rotation =
		rotation

end)

--==================================================
-- 默认显示信息
--==================================================

SelectCategory("信息")
