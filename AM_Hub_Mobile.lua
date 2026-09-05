--// AM Hub Mobile
--// Luau / LocalScript
--// 360dp Design
--// 左侧：分类
--// 右侧：功能

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local DESIGN_WIDTH = 360

local MENU_WIDTH = 250
local MENU_HEIGHT = 300

local FLOAT_SIZE = 58

-- 把这里换成你的 QQ 群
local QQ_GROUP = "你的QQ群号"

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

--==================================================
-- 自适应
--==================================================

local UIScale = Instance.new("UIScale")
UIScale.Parent = ScreenGui

local function UpdateScale()

	local camera = workspace.CurrentCamera

	if not camera then
		return
	end

	local width = camera.ViewportSize.X

	local scale = width / DESIGN_WIDTH

	scale = math.clamp(scale, 0.75, 2)

	UIScale.Scale = scale
end

UpdateScale()

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal(
		"ViewportSize"
	):Connect(UpdateScale)
end

--==================================================
-- 彩虹颜色
--==================================================

local rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 120))
})

--==================================================
-- 工具
--==================================================

local function Corner(object, radius)

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = object

	return c
end

local function Stroke(object, color, thickness)

	local s = Instance.new("UIStroke")

	s.Color = color
	s.Thickness = thickness

	s.Parent = object

	return s
end

--==================================================
-- 悬浮球
--==================================================

local AMButton = Instance.new("TextButton")

AMButton.Name = "AMButton"
AMButton.Size = UDim2.fromOffset(FLOAT_SIZE, FLOAT_SIZE)

AMButton.Position = UDim2.new(
	0,
	20,
	0.5,
	-29
)

AMButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
AMButton.BackgroundTransparency = .03

AMButton.BorderSizePixel = 0

AMButton.Text = "AM"
AMButton.TextColor3 = Color3.fromRGB(20,20,20)

AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold

AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.ZIndex = 50

AMButton.Parent = ScreenGui

Corner(AMButton, 100)

local AMStroke = Stroke(
	AMButton,
	Color3.fromRGB(255,0,100),
	3
)

local AMGradient = Instance.new("UIGradient")

AMGradient.Color = rainbow
AMGradient.Parent = AMStroke

--==================================================
-- 主菜单
--==================================================

local Menu = Instance.new("Frame")

Menu.Name = "Menu"

Menu.Size = UDim2.fromOffset(
	MENU_WIDTH,
	MENU_HEIGHT
)

Menu.Position = UDim2.new(
	0,
	90,
	0.5,
	-MENU_HEIGHT / 2
)

Menu.BackgroundColor3 = Color3.fromRGB(
	255,
	255,
	255
)

Menu.BackgroundTransparency = .02

Menu.BorderSizePixel = 0

Menu.Visible = false
Menu.Active = true

Menu.ZIndex = 10

Menu.Parent = ScreenGui

Corner(Menu,15)

local MenuStroke = Stroke(
	Menu,
	Color3.fromRGB(255,0,100),
	3
)

local MenuGradient = Instance.new("UIGradient")

MenuGradient.Color = rainbow
MenuGradient.Parent = MenuStroke

--==================================================
-- 标题
--==================================================

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(
	1,
	-50,
	0,
	42
)

Title.Position = UDim2.fromOffset(
	15,
	5
)

Title.BackgroundTransparency = 1

Title.Text = "AM Hub"

Title.TextColor3 = Color3.fromRGB(
	20,
	20,
	20
)

Title.TextSize = 21
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.ZIndex = 20

Title.Parent = Menu

--==================================================
-- 关闭
--==================================================

local Close = Instance.new("TextButton")

Close.Size = UDim2.fromOffset(35,35)

Close.Position = UDim2.new(
	1,
	-42,
	0,
	6
)

Close.BackgroundTransparency = 1

Close.Text = "×"

Close.TextColor3 =
	Color3.fromRGB(30,30,30)

Close.TextSize = 25

Close.Font = Enum.Font.GothamBold

Close.ZIndex = 30

Close.Parent = Menu

Close.MouseButton1Click:Connect(function()

	Menu.Visible = false

end)

--==================================================
-- 左侧分类栏
--==================================================

local CategoryBar = Instance.new("Frame")

CategoryBar.Size = UDim2.new(
	0,
	72,
	1,
	-52
)

CategoryBar.Position = UDim2.fromOffset(
	5,
	47
)

CategoryBar.BackgroundColor3 =
	Color3.fromRGB(245,245,245)

CategoryBar.BorderSizePixel = 0

CategoryBar.Parent = Menu

Corner(CategoryBar,10)

--==================================================
-- 右侧功能区
--==================================================

local Content = Instance.new("ScrollingFrame")

Content.Size = UDim2.new(
	1,
	-87,
	1,
	-52
)

Content.Position = UDim2.fromOffset(
	82,
	47
)

Content.BackgroundTransparency = 1

Content.BorderSizePixel = 0

Content.ScrollBarThickness = 3

Content.ScrollBarImageColor3 =
	Color3.fromRGB(170,170,170)

Content.CanvasSize =
	UDim2.new(0,0,0,0)

Content.Parent = Menu

local ContentLayout = Instance.new("UIListLayout")

ContentLayout.Padding =
	UDim.new(0,7)

ContentLayout.HorizontalAlignment =
	Enum.HorizontalAlignment.Center

ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal(
	"AbsoluteContentSize"
):Connect(function()

	Content.CanvasSize =
	UDim2.fromOffset(
		0,
		ContentLayout.AbsoluteContentSize.Y + 10
	)

end)

--==================================================
-- 分类数据
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

--==================================================
-- 清空右侧
--==================================================

local function ClearContent()

	for _, object in ipairs(Content:GetChildren()) do

		if not object:IsA("UIListLayout") then
			object:Destroy()
		end

	end

end

--==================================================
-- 标题
--==================================================

local function CreateSectionTitle(text)

	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(
		1,
		-10,
		0,
		30
	)

	label.BackgroundTransparency = 1

	label.Text = text

	label.TextColor3 =
		Color3.fromRGB(25,25,25)

	label.TextSize = 17

	label.Font =
		Enum.Font.GothamBold

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent = Content

	return label
end

--==================================================
-- 普通按钮
--==================================================

local function CreateButton(text, callback)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(
		1,
		-10,
		0,
		38
	)

	button.BackgroundColor3 =
		Color3.fromRGB(245,245,245)

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.fromRGB(30,30,30)

	button.TextSize = 14

	button.Font = Enum.Font.Gotham

	button.AutoButtonColor = true

	button.Parent = Content

	Corner(button,8)

	Stroke(
		button,
		Color3.fromRGB(220,220,220),
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

	button.Size = UDim2.new(
		1,
		-10,
		0,
		38
	)

	button.BackgroundColor3 =
		Color3.fromRGB(245,245,245)

	button.BorderSizePixel = 0

	button.TextSize = 14

	button.Font = Enum.Font.Gotham

	button.Parent = Content

	Corner(button,8)

	local enabled = default or false

	local function Refresh()

		if enabled then

			button.Text =
				text .. "    [开启]"

			button.TextColor3 =
				Color3.fromRGB(0,150,70)

		else

			button.Text =
				text .. "    [关闭]"

			button.TextColor3 =
				Color3.fromRGB(50,50,50)

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

local function CreateSlider(text, min, max, default, callback)

	local holder = Instance.new("Frame")

	holder.Size = UDim2.new(
		1,
		-10,
		0,
		55
	)

	holder.BackgroundColor3 =
		Color3.fromRGB(245,245,245)

	holder.BorderSizePixel = 0

	holder.Parent = Content

	Corner(holder,8)

	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(
		1,
		-15,
		0,
		22
	)

	label.Position =
		UDim2.fromOffset(8,2)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		Color3.fromRGB(30,30,30)

	label.TextSize = 13

	label.Font = Enum.Font.Gotham

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.Parent = holder

	local bar = Instance.new("Frame")

	bar.Size = UDim2.new(
		1,
		-16,
		0,
		6
	)

	bar.Position =
		UDim2.new(
			0,
			8,
			0,
			34
		)

	bar.BackgroundColor3 =
		Color3.fromRGB(215,215,215)

	bar.BorderSizePixel = 0

	bar.Parent = holder

	Corner(bar,10)

	local fill = Instance.new("Frame")

	fill.Size =
		UDim2.new(0,0,1,0)

	fill.BackgroundColor3 =
		Color3.fromRGB(100,100,100)

	fill.BorderSizePixel = 0

	fill.Parent = bar

	Corner(fill,10)

	local dragging = false

	local value = default

	local function SetValue(v)

		value = math.clamp(
			v,
			min,
			max
		)

		local percent =
			(value - min) /
			(max - min)

		fill.Size =
			UDim2.new(
				percent,
				0,
				1,
				0
			)

		label.Text =
			text .. " : " ..
			math.floor(value)

		if callback then
			callback(value)
		end

	end

	local function Update(input)

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
			min +
			(max-min)*percent
		)

	end

	bar.InputBegan:Connect(function(input)

		if input.UserInputType ==
			Enum.UserInputType.Touch
			or input.UserInputType ==
			Enum.UserInputType.MouseButton1 then

			dragging = true

			Update(input)

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

			Update(input)

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
		"欢迎使用 AM Hub",
		nil
	)

	local accountAge =
		player.AccountAge

	local years =
		math.floor(accountAge / 365)

	local days =
		accountAge % 365

	CreateButton(
		"Roblox 账户年龄：" ..
		years .. " 年 " ..
		days .. " 天",
		nil
	)

	CreateButton(
		"QQ 群：" ..
		QQ_GROUP,
		nil
	)

	CreateButton(
		"用户名：" ..
		player.Name,
		nil
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
			print("飞行：", enabled)
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
				humanoid.WalkSpeed = value
			end

		end
	)

	CreateSlider(
		"跳跃高度",
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
				humanoid.JumpPower = value
			end

		end
	)

	CreateSlider(
		"重力",
		0,
		300,
		196.2,
		function(value)

			workspace.Gravity = value

		end
	)

	CreateButton(
		"移动方式选择",
		function()
			print("移动方式选择")
		end
	)

	CreateToggle(
		"点击屏幕瞬移",
		false,
		function(enabled)
			print("点击瞬移：",enabled)
		end
	)

	CreateToggle(
		"踏空飞行",
		false,
		function(enabled)
			print("踏空飞行：",enabled)
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
				"重新选择服务器需要接入你的 Teleport 系统"
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
			print("透视：",enabled)
		end
	)

	CreateSlider(
		"透视范围",
		0,
		1500,
		150,
		function(value)
			print("透视范围：",value)
		end
	)

	CreateSlider(
		"自瞄 FOV",
		1,
		180,
		90,
		function(value)
			print("FOV：",value)
		end
	)

	CreateToggle(
		"子弹追踪",
		false,
		function(enabled)
			print("子弹追踪：",enabled)
		end
	)

	CreateToggle(
		"无限子弹",
		false,
		function(enabled)
			print("无限子弹：",enabled)
		end
	)

	CreateButton(
		"敌对颜色：红色",
		function()
			print("敌对颜色")
		end
	)

	CreateButton(
		"我方颜色：蓝色",
		function()
			print("我方颜色")
		end
	)

	CreateButton(
		"自定义透视颜色",
		function()
			print("打开颜色选择器")
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
				"FPS 设置：",
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
				"打开玩家选择器"
			)

		end
	)

	CreateButton(
		"甩飞",
		function()

			print(
				"甩飞功能需要接入你自己的游戏逻辑"
			)

		end
	)

	CreateButton(
		"传送",
		function()

			print(
				"传送功能需要接入你自己的游戏逻辑"
			)

		end
	)

	CreateButton(
		"环绕",
		function()

			print(
				"环绕功能需要接入你自己的游戏逻辑"
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

				if object:IsA("BasePart") then

					if enabled then

						object.Color =
							Color3.fromRGB(
								255,
								200,
								40
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

				fire.Parent = head

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
-- 分类切换
--==================================================

local Functions = {
	["信息"] = ShowInfo,
	["通用"] = ShowGeneral,
	["战斗"] = ShowCombat,
	["娱乐"] = ShowEntertainment,
	["FE"] = ShowFE,
	["特效"] = ShowEffects,
	["设置"] = ShowSettings
}

local currentCategory = nil

local function SelectCategory(name)

	currentCategory = name

	for category, button in pairs(
		CategoryButtons
	) do

		if category == name then

			button.BackgroundColor3 =
				Color3.fromRGB(
					225,
					225,
					225
				)

			button.TextColor3 =
				Color3.fromRGB(
					0,
					0,
					0
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

	local callback =
		Functions[name]

	if callback then
		callback()
	end

end

--==================================================
-- 创建分类按钮
--==================================================

for index, name in ipairs(Categories) do

	local button =
		Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-8,
			0,
			31
		)

	button.Position =
		UDim2.fromOffset(
			4,
			(index - 1) * 34
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

	button.Parent = CategoryBar

	Corner(button,7)

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
--==================================================

local menuDragging = false
local menuDragStart
local menuStartPosition

Title.InputBegan:Connect(function(input)

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
-- 流光
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
-- 默认打开信息
--==================================================

SelectCategory("信息")
