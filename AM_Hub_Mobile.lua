--// AM Hub Mobile 3.0
--// Luau / LocalScript
--// Roblox Studio
--// UI + 自己游戏的功能接口版本

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local MENU_WIDTH = 280
local MENU_HEIGHT = 330

local FLOAT_SIZE = 58

local QQ_GROUP = "你的QQ群号"

--==================================================
-- 状态
--==================================================

local Flying = false
local InfiniteJump = false

local FlightSpeed = 50
local SelectedPlayer = nil

local FlightConnection = nil
local InfiniteJumpConnection = nil

--==================================================
-- 彩虹
--==================================================

local Rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120))
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

local function GetCharacter()

	return LocalPlayer.Character

end

local function GetHumanoid()

	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")

end

local function GetRoot()

	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")

end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

ScreenGui.Parent = PlayerGui

--==================================================
-- 悬浮球
--==================================================

local AMButton = Instance.new("TextButton")

AMButton.Name = "AMButton"

AMButton.Size =
	UDim2.fromOffset(
		FLOAT_SIZE,
		FLOAT_SIZE
	)

AMButton.Position =
	UDim2.new(
		0,
		18,
		0.5,
		-29
	)

AMButton.BackgroundColor3 =
	Color3.fromRGB(255, 255, 255)

AMButton.BorderSizePixel = 0

AMButton.Text = "AM"

AMButton.TextColor3 =
	Color3.fromRGB(20, 20, 20)

AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold

AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.ZIndex = 100

AMButton.Parent = ScreenGui

Corner(AMButton, 100)

local AMStroke = Instance.new("UIStroke")

AMStroke.Thickness = 3
AMStroke.ApplyStrokeMode =
	Enum.ApplyStrokeMode.Border

AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")

AMGradient.Color = Rainbow
AMGradient.Parent = AMStroke

--==================================================
-- 主菜单
--==================================================

local Menu = Instance.new("Frame")

Menu.Name = "Menu"

Menu.Size =
	UDim2.fromOffset(
		MENU_WIDTH,
		MENU_HEIGHT
	)

Menu.Position =
	UDim2.new(
		0,
		88,
		0.5,
		-MENU_HEIGHT / 2
	)

Menu.BackgroundColor3 =
	Color3.fromRGB(255, 255, 255)

Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true

Menu.ZIndex = 10
Menu.Parent = ScreenGui

Corner(Menu, 16)

local MenuStroke = Instance.new("UIStroke")

MenuStroke.Thickness = 3
MenuStroke.ApplyStrokeMode =
	Enum.ApplyStrokeMode.Border

MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")

MenuGradient.Color = Rainbow
MenuGradient.Parent = MenuStroke

--==================================================
-- 标题
--==================================================

local Header = Instance.new("Frame")

Header.Size =
	UDim2.new(
		1,
		0,
		0,
		48
	)

Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 20

Header.Parent = Menu

local Title = Instance.new("TextLabel")

Title.Size =
	UDim2.new(
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
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.ZIndex = 21
Title.Parent = Header

local CloseButton = Instance.new("TextButton")

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
CloseButton.Font = Enum.Font.GothamBold

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

CategoryBar.Size =
	UDim2.new(
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

Corner(CategoryBar, 11)

--==================================================
-- 右侧内容
--==================================================

local Content = Instance.new("ScrollingFrame")

Content.Size =
	UDim2.new(
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
	Color3.fromRGB(150, 150, 150)

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

	Content.CanvasSize =
		UDim2.fromOffset(
			0,
			ContentLayout.AbsoluteContentSize.Y + 15
		)

end)

--==================================================
-- 清除内容
--==================================================

local function ClearContent()

	for _, object in ipairs(
		Content:GetChildren()
	) do

		if not object:IsA("UIListLayout") then
			object:Destroy()
		end

	end

	Content.CanvasPosition =
		Vector2.zero

end

--==================================================
-- 标题
--==================================================

local function Section(text)

	local label = Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-10,
			0,
			30
		)

	label.BackgroundTransparency = 1

	label.Text = text

	label.TextColor3 =
		Color3.fromRGB(20, 20, 20)

	label.TextSize = 17
	label.Font = Enum.Font.GothamBold

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.ZIndex = 20
	label.Parent = Content

	return label

end

--==================================================
-- 按钮
--==================================================

local function Button(text, callback)

	local button = Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-10,
			0,
			42
		)

	button.BackgroundColor3 =
		Color3.fromRGB(245, 245, 245)

	button.BorderSizePixel = 0

	button.Text = text

	button.TextColor3 =
		Color3.fromRGB(25, 25, 25)

	button.TextSize = 14
	button.Font = Enum.Font.Gotham

	button.ZIndex = 20
	button.Parent = Content

	Corner(button, 9)

	Stroke(
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

local function Toggle(text, default, callback)

	local button = Instance.new("TextButton")

	button.Size =
		UDim2.new(
			1,
			-10,
			0,
			42
		)

	button.BorderSizePixel = 0

	button.TextSize = 14
	button.Font = Enum.Font.GothamBold

	button.AutoButtonColor = false
	button.ZIndex = 20

	button.Parent = Content

	Corner(button, 9)

	local state = default or false

	local function Refresh()

		if state then

			button.Text =
				text .. "    ● 开启"

			button.TextColor3 =
				Color3.fromRGB(
					0,
					140,
					80
				)

			button.BackgroundColor3 =
				Color3.fromRGB(
					235,
					250,
					240
				)

		else

			button.Text =
				text .. "    ○ 关闭"

			button.TextColor3 =
				Color3.fromRGB(
					50,
					50,
					50
				)

			button.BackgroundColor3 =
				Color3.fromRGB(
					245,
					245,
					245
				)

		end

	end

	Refresh()

	button.MouseButton1Click:Connect(function()

		state = not state

		Refresh()

		if callback then
			callback(state)
		end

	end)

	return button

end

--==================================================
-- 滑块
--==================================================

local function Slider(
	text,
	minimum,
	maximum,
	default,
	callback
)

	local holder = Instance.new("Frame")

	holder.Size =
		UDim2.new(
			1,
			-10,
			0,
			60
		)

	holder.BackgroundColor3 =
		Color3.fromRGB(245, 245, 245)

	holder.BorderSizePixel = 0
	holder.ZIndex = 20

	holder.Parent = Content

	Corner(holder, 9)

	local label = Instance.new("TextLabel")

	label.Size =
		UDim2.new(
			1,
			-16,
			0,
			24
		)

	label.Position =
		UDim2.fromOffset(8, 3)

	label.BackgroundTransparency = 1

	label.TextColor3 =
		Color3.fromRGB(30, 30, 30)

	label.TextSize = 13
	label.Font = Enum.Font.Gotham

	label.TextXAlignment =
		Enum.TextXAlignment.Left

	label.ZIndex = 21
	label.Parent = holder

	local bar = Instance.new("Frame")

	bar.Size =
		UDim2.new(
			1,
			-20,
			0,
			7
		)

	bar.Position =
		UDim2.fromOffset(10, 38)

	bar.BackgroundColor3 =
		Color3.fromRGB(215, 215, 215)

	bar.BorderSizePixel = 0
	bar.ZIndex = 21

	bar.Parent = holder

	Corner(bar, 10)

	local fill = Instance.new("Frame")

	fill.Size =
		UDim2.fromScale(0, 1)

	fill.BackgroundColor3 =
		Color3.fromRGB(45, 45, 45)

	fill.BorderSizePixel = 0
	fill.ZIndex = 22

	fill.Parent = bar

	Corner(fill, 10)

	local knob = Instance.new("Frame")

	knob.Size =
		UDim2.fromOffset(15, 15)

	knob.AnchorPoint =
		Vector2.new(0.5, 0.5)

	knob.BackgroundColor3 =
		Color3.fromRGB(35, 35, 35)

	knob.BorderSizePixel = 0
	knob.ZIndex = 23

	knob.Parent = bar

	Corner(knob, 20)

	local dragging = false

	local function SetValue(value)

		value = math.clamp(
			value,
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
			text ..
			" : " ..
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
				x /
				bar.AbsoluteSize.X,
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
-- 飞行
--==================================================

local function StopFlight()

	Flying = false

	if FlightConnection then

		FlightConnection:Disconnect()
		FlightConnection = nil

	end

	local humanoid = GetHumanoid()

	if humanoid then

		humanoid.PlatformStand = false

	end

	local root = GetRoot()

	if root then

		root.AssemblyLinearVelocity =
			Vector3.zero

	end

end

local function StartFlight()

	if Flying then
		return
	end

	local humanoid = GetHumanoid()
	local root = GetRoot()

	if not humanoid or not root then
		return
	end

	Flying = true

	humanoid.PlatformStand = true

	FlightConnection =
		RunService.RenderStepped:Connect(
			function()

				if not Flying then
					return
				end

				local currentHumanoid =
					GetHumanoid()

				local currentRoot =
					GetRoot()

				if not currentHumanoid
					or not currentRoot then

					StopFlight()
					return

				end

				local camera =
					workspace.CurrentCamera

				if not camera then
					return
				end

				local move =
					currentHumanoid.MoveDirection

				local velocity =
					Vector3.zero

				if move.Magnitude > 0 then

					velocity =
						move.Unit *
						FlightSpeed

				end

				currentRoot.AssemblyLinearVelocity =
					velocity

			end
		)

end

--==================================================
-- 无限跳跃
--==================================================

InfiniteJumpConnection =
	UserInputService.JumpRequest:Connect(
		function()

			if not InfiniteJump then
				return
			end

			local humanoid =
				GetHumanoid()

			if humanoid then

				humanoid:ChangeState(
					Enum.HumanoidStateType.Jumping
				)

			end

		end
	)

--==================================================
-- 玩家选择器
--==================================================

local PlayerSelector = Instance.new("Frame")

PlayerSelector.Name =
	"PlayerSelector"

PlayerSelector.Size =
	UDim2.fromOffset(
		250,
		300
	)

PlayerSelector.Position =
	UDim2.new(
		0.5,
		-125,
		0.5,
		-150
	)

PlayerSelector.BackgroundColor3 =
	Color3.fromRGB(255, 255, 255)

PlayerSelector.BorderSizePixel = 0

PlayerSelector.Visible = false
PlayerSelector.Active = true

PlayerSelector.ZIndex = 200

PlayerSelector.Parent = ScreenGui

Corner(PlayerSelector, 15)

local SelectorStroke =
	Instance.new("UIStroke")

SelectorStroke.Thickness = 3
SelectorStroke.ApplyStrokeMode =
	Enum.ApplyStrokeMode.Border

SelectorStroke.Parent =
	PlayerSelector

local SelectorGradient =
	Instance.new("UIGradient")

SelectorGradient.Color =
	Rainbow

SelectorGradient.Parent =
	SelectorStroke

--==================================================
-- 玩家选择器标题
--==================================================

local SelectorTitle =
	Instance.new("TextLabel")

SelectorTitle.Size =
	UDim2.new(
		1,
		-55,
		0,
		45
	)

SelectorTitle.Position =
	UDim2.fromOffset(15, 3)

SelectorTitle.BackgroundTransparency = 1

SelectorTitle.Text =
	"选择玩家"

SelectorTitle.TextColor3 =
	Color3.fromRGB(20, 20, 20)

SelectorTitle.TextSize = 18
SelectorTitle.Font =
	Enum.Font.GothamBold

SelectorTitle.TextXAlignment =
	Enum.TextXAlignment.Left

SelectorTitle.ZIndex = 210

SelectorTitle.Parent =
	PlayerSelector

local SelectorClose =
	Instance.new("TextButton")

SelectorClose.Size =
	UDim2.fromOffset(35, 35)

SelectorClose.Position =
	UDim2.new(
		1,
		-40,
		0,
		6
	)

SelectorClose.BackgroundTransparency = 1

SelectorClose.Text = "×"

SelectorClose.TextColor3 =
	Color3.fromRGB(30, 30, 30)

SelectorClose.TextSize = 25
SelectorClose.Font =
	Enum.Font.GothamBold

SelectorClose.ZIndex = 220

SelectorClose.Parent =
	PlayerSelector

SelectorClose.MouseButton1Click:Connect(
	function()

		PlayerSelector.Visible =
			false

	end
)

--==================================================
-- 玩家列表
--==================================================

local PlayerList =
	Instance.new("ScrollingFrame")

PlayerList.Size =
	UDim2.new(
		1,
		-20,
		1,
		-60
	)

PlayerList.Position =
	UDim2.fromOffset(10, 52)

PlayerList.BackgroundTransparency = 1

PlayerList.BorderSizePixel = 0

PlayerList.ScrollBarThickness = 4

PlayerList.ZIndex = 210

PlayerList.Parent =
	PlayerSelector

local PlayerLayout =
	Instance.new("UIListLayout")

PlayerLayout.Padding =
	UDim.new(0, 6)

PlayerLayout.Parent =
	PlayerList

PlayerLayout:GetPropertyChangedSignal(
		"AbsoluteContentSize"
):Connect(
	function()

		PlayerList.CanvasSize =
			UDim2.fromOffset(
				0,
				PlayerLayout.AbsoluteContentSize.Y + 10
			)

	end
)

local function RefreshPlayerList()

	for _, object in ipairs(
		PlayerList:GetChildren()
	) do

		if not object:IsA(
			"UIListLayout"
		) then

			object:Destroy()

		end

	end

	for _, target in ipairs(
		Players:GetPlayers()
	) do

		if target ~= LocalPlayer then

			local button =
				Instance.new("TextButton")

			button.Size =
				UDim2.new(
					1,
					-5,
					0,
					40
				)

			button.BackgroundColor3 =
				Color3.fromRGB(
					245,
					245,
					245
				)

			button.BorderSizePixel = 0

			button.Text =
				target.DisplayName ..
				"  @" ..
				target.Name

			button.TextColor3 =
				Color3.fromRGB(
					25,
					25,
					25
				)

			button.TextSize = 13
			button.Font =
				Enum.Font.Gotham

			button.ZIndex = 220

			button.Parent =
				PlayerList

			Corner(button, 8)

			button.MouseButton1Click:Connect(
				function()

					SelectedPlayer =
						target

					PlayerSelector.Visible =
						false

					print(
						"当前目标：",
						target.Name
					)

				end
			)

		end

	end

end

Players.PlayerRemoving:Connect(
	function(leavingPlayer)

		if SelectedPlayer ==
			leavingPlayer then

			SelectedPlayer = nil

		end

	end
)

--==================================================
-- 信息页面
--==================================================

local function ShowInfo()

	ClearContent()

	Section("信息")

	Button(
		"欢迎使用 AM Hub"
	)

	local age =
		LocalPlayer.AccountAge

	local years =
		math.floor(age / 365)

	local days =
		age % 365

	Button(
		"Roblox 账户：" ..
		years ..
		" 年 " ..
		days ..
		" 天"
	)

	Button(
		"用户名：" ..
		LocalPlayer.Name
	)

	Button(
		"QQ 群：" ..
		QQ_GROUP
	)

end

--==================================================
-- 通用
--==================================================

local function ShowGeneral()

	ClearContent()

	Section("通用")

	Toggle(
		"无限跳跃 FE",
		InfiniteJump,
		function(enabled)

			InfiniteJump = enabled

		end
	)

	Toggle(
		"飞行",
		Flying,
		function(enabled)

			if enabled then
				StartFlight()
			else
				StopFlight()
			end

		end
	)

	Slider(
		"飞行速度",
		1,
		100,
		FlightSpeed,
		function(value)

			FlightSpeed = value

		end
	)

	Toggle(
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

	Slider(
		"移速",
		1,
		300,
		16,
		function(value)

			local humanoid =
				GetHumanoid()

			if humanoid then

				humanoid.WalkSpeed =
					value

			end

		end
	)

	Slider(
		"跳高",
		1,
		300,
		50,
		function(value)

			local humanoid =
				GetHumanoid()

			if humanoid then

				humanoid.JumpPower =
					value

			end

		end
	)

	Slider(
		"重力",
		0,
		300,
		196,
		function(value)

			workspace.Gravity =
				value

		end
	)

	Toggle(
		"点击屏幕瞬移",
		false,
		function(enabled)

			print(
				"点击瞬移：",
				enabled
			)

		end
	)

	Toggle(
		"踏空飞行",
		false,
		function(enabled)

			print(
				"踏空飞行：",
				enabled
			)

		end
	)

	Toggle(
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

	Button(
		"退出当前服务器",
		function()

			-- 只让当前玩家离开
			LocalPlayer:Kick(
				"已离开当前服务器"
			)

		end
	)

	Button(
		"重新选择服务器",
		function()

			-- 自己的游戏可以在这里接服务器选择 UI
			print(
				"打开服务器选择器"
			)

		end
	)

end

--==================================================
-- 战斗
--==================================================

local function ShowCombat()

	ClearContent()

	Section("战斗")

	Toggle(
		"透视",
		false,
		function(enabled)

			print(
				"透视：",
				enabled
			)

		end
	)

	Slider(
		"范围",
		1,
		1500,
		150,
		function(value)

			print(
				"范围：",
				value
			)

		end
	)

	Slider(
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

	Toggle(
		"自瞄",
		false,
		function(enabled)

			-- 接你自己的服务器授权系统
			print(
				"自瞄：",
				enabled
			)

		end
	)

	Toggle(
		"子弹追踪",
		false,
		function(enabled)

			-- 接你自己的服务器投射物系统
			print(
				"子弹追踪：",
				enabled
			)

		end
	)

	Button(
		"敌对颜色：红色"
	)

	Button(
		"我方颜色：蓝色"
	)

	Button(
		"自定义颜色",
		function()

			print(
				"打开颜色选择器"
			)

		end
	)

end

--==================================================
-- 娱乐
--==================================================

local function ShowEntertainment()

	ClearContent()

	Section("娱乐")

	Slider(
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
-- 甩飞
--==================================================

local function ShowFling()

	ClearContent()

	Section("甩飞")

	Button(
		"选择玩家",
		function()

			RefreshPlayerList()

			PlayerSelector.Visible =
				true

		end
	)

	local targetName =
		SelectedPlayer
		and SelectedPlayer.Name
		or "未选择"

	Button(
		"当前目标：" ..
		targetName
	)

	-- 下面都是服务器授权接口
	Button(
		"甩飞",
		function()

			if not SelectedPlayer then

				print(
					"请先选择玩家"
				)

				return

			end

			print(
				"请求甩飞目标：",
				SelectedPlayer.Name
			)

		end
	)

	Button(
		"传送",
		function()

			if not SelectedPlayer then

				print(
					"请先选择玩家"
				)

				return

			end

			print(
				"请求传送目标：",
				SelectedPlayer.Name
			)

		end
	)

	Toggle(
		"环绕",
		false,
		function(enabled)

			if SelectedPlayer then

				print(
					"环绕：",
					enabled,
					SelectedPlayer.Name
				)

			else

				print(
					"请先选择玩家"
				)

			end

		end
	)

	Slider(
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

	Button(
		"客户端传送",
		function()

			if not SelectedPlayer then

				print(
					"请先选择玩家"
				)

				return

			end

			print(
				"客户端传送目标：",
				SelectedPlayer.Name
			)

		end
	)

end

--==================================================
-- 特效
--==================================================

local function ShowEffects()

	ClearContent()

	Section("特效")

	Toggle(
		"AM 使用者",
		false,
		function(enabled)

			print(
				"AM 使用者：",
				enabled
			)

		end
	)

	Toggle(
		"金身",
		false,
		function(enabled)

			local character =
				GetCharacter()

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

					end

				end

			end

		end
	)

	Toggle(
		"头顶火焰",
		false,
		function(enabled)

			local character =
				GetCharacter()

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

	Toggle(
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

	Section("设置")

	Button(
		"退出 AM",
		function()

			if Flying then
				StopFlight()
			end

			if InfiniteJumpConnection then

				InfiniteJumpConnection:Disconnect()

				InfiniteJumpConnection =
					nil

			end

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
	"甩飞",
	"特效",
	"设置"
}

local Pages = {}

Pages["信息"] =
	ShowInfo

Pages["通用"] =
	ShowGeneral

Pages["战斗"] =
	ShowCombat

Pages["娱乐"] =
	ShowEntertainment

Pages["甩飞"] =
	ShowFling

Pages["特效"] =
	ShowEffects

Pages["设置"] =
	ShowSettings

local CategoryButtons = {}

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

	if Pages[name] then

		Pages[name]()

	end

end

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

	Corner(button, 8)

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

local MenuDragging = false
local MenuDragStart
local MenuStartPosition

Header.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		MenuDragging = true

		MenuDragStart =
			input.Position

		MenuStartPosition =
			Menu.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not MenuDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta =
			input.Position -
			MenuDragStart

		Menu.Position =
			UDim2.new(
				MenuStartPosition.X.Scale,
				MenuStartPosition.X.Offset +
					delta.X,

				MenuStartPosition.Y.Scale,
				MenuStartPosition.Y.Offset +
					delta.Y
			)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		MenuDragging = false

	end

end)

--==================================================
-- 悬浮球拖动
--==================================================

local ButtonDragging = false
local ButtonDragStart
local ButtonStartPosition
local ButtonMoved = false

AMButton.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		ButtonDragging = true
		ButtonMoved = false

		ButtonDragStart =
			input.Position

		ButtonStartPosition =
			AMButton.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not ButtonDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta =
			input.Position -
			ButtonDragStart

		if math.abs(delta.X) > 6
			or math.abs(delta.Y) > 6 then

			ButtonMoved = true

		end

		AMButton.Position =
			UDim2.new(
				ButtonStartPosition.X.Scale,
				ButtonStartPosition.X.Offset +
					delta.X,

				ButtonStartPosition.Y.Scale,
				ButtonStartPosition.Y.Offset +
					delta.Y
			)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		if ButtonDragging
			and not ButtonMoved then

			Menu.Visible =
				not Menu.Visible

		end

		ButtonDragging = false

	end

end)

--==================================================
-- 玩家选择器拖动
--==================================================

local SelectorDragging = false
local SelectorDragStart
local SelectorStartPosition

SelectorTitle.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		SelectorDragging = true

		SelectorDragStart =
			input.Position

		SelectorStartPosition =
			PlayerSelector.Position

	end

end)

UserInputService.InputChanged:Connect(function(input)

	if not SelectorDragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local delta =
			input.Position -
			SelectorDragStart

		PlayerSelector.Position =
			UDim2.new(
				SelectorStartPosition.X.Scale,
				SelectorStartPosition.X.Offset +
					delta.X,

				SelectorStartPosition.Y.Scale,
				SelectorStartPosition.Y.Offset +
					delta.Y
			)

	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.Touch
		or input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		SelectorDragging = false

	end

end)

--==================================================
-- 流光
--==================================================

local Rotation = 0

RunService.RenderStepped:Connect(
	function(dt)

		Rotation =
			(Rotation + dt * 100) % 360

		AMGradient.Rotation =
			Rotation

		MenuGradient.Rotation =
			Rotation

		SelectorGradient.Rotation =
			Rotation

	end
)

--==================================================
-- 默认页面
--==================================================

SelectCategory("信息")
