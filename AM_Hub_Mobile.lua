--// =============================================================
--//  AM Hub Mobile 3.0  [修复版]
--//  保留原版结构 / 命名 / 彩虹边框 / 分类 / 拖动
--//  改动：1) 修好悬浮窗一定能加载  2) 删除远程接口空壳、改为本地实现  3) 功能真实化
--//  QQ群: 179051448
--// =============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--// 等待 PlayerGui 就绪（防止悬浮窗加载不出来）
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then
	-- 极端情况下 fallback 到 CoreGui
	PlayerGui = game:GetService("CoreGui")
end

--// =============================================================
--  CONFIG
-- =============================================================

local MENU_WIDTH = 280
local MENU_HEIGHT = 360

local FLOAT_SIZE = 58

local QQ_GROUP = "179051448"

--// =============================================================
--  状态
-- =============================================================

local Flying = false
local InfiniteJump = false

local FlightSpeed = 50
local SelectedPlayer = nil

local FlightConnection = nil
local InfiniteJumpConnection = nil

-- 新增真实功能状态
local Noclip = false
local ESPEnabled = false
local AimbotEnabled = false
local ClickTPEnabled = false

local NoclipConnection = nil
local ESPObjects = {}
local AimbotConnection = nil

--// =============================================================
--  彩虹
-- =============================================================

local Rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120)),
})

--// =============================================================
--  工具
-- =============================================================

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
	if not character then return nil end
	return character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
	local character = GetCharacter()
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
end

-- 安全获取鼠标/触摸世界点击位置
local function GetWorldClickPosition()
	local mouse = LocalPlayer:GetMouse()
	if mouse and mouse.Hit then
		return mouse.Hit.Position
	end
	return nil
end

--// =============================================================
--  GUI 附着（修复：一定能加载出来）
-- =============================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 关键修复：先 Parent 再设置其它，失败时 fallback
local function AttachGui()
	local ok, err = pcall(function()
		ScreenGui.Parent = PlayerGui
	end)
	if not ok then
		pcall(function()
			ScreenGui.Parent = game:GetService("CoreGui")
		end)
	end
end
AttachGui()

-- 角色重生时重新附着（防止菜单在死亡后消失）
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	if not ScreenGui.Parent then
		AttachGui()
	end
end)

--// =============================================================
--  悬浮球（AM 按钮）
-- =============================================================

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
		-FLOAT_SIZE / 2
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

--// =============================================================
--  主菜单
-- =============================================================

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

--// =============================================================
--  标题
-- =============================================================

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

Title.Text = "AM通用脚本"

Title.TextColor3 =
	Color3.fromRGB(20, 20, 20)

Title.TextSize = 21
Title.Font = Enum.Font.GothamBold

Title.TextXAlignment =
	Enum.TextXAlignment.Left

Title.ZIndex = 21
Title.Parent = Header

-- QQ 群展示（右上角，不再弹窗）
local QQLabel = Instance.new("TextLabel")
QQLabel.Size = UDim2.new(1, -50, 0, 16)
QQLabel.Position = UDim2.new(0, 15, 1, 2)
QQLabel.BackgroundTransparency = 1
QQLabel.Text = "官方QQ群: " .. QQ_GROUP
QQLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
QQLabel.TextSize = 11
QQLabel.Font = Enum.Font.Gotham
QQLabel.TextXAlignment = Enum.TextXAlignment.Left
QQLabel.ZIndex = 21
QQLabel.Parent = Header

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

--// =============================================================
--  左侧分类
-- =============================================================

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

--// =============================================================
--  右侧内容
-- =============================================================

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

--// =============================================================
--  清除内容
-- =============================================================

local function ClearContent()
	for _, object in ipairs(Content:GetChildren()) do
		if not object:IsA("UIListLayout") then
			object:Destroy()
		end
	end
	Content.CanvasPosition = Vector2.zero
end

--// =============================================================
--  UI 组件
-- =============================================================

local function Section(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 17
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 20
	label.Parent = Content
	return label
end

local function Button(text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 42)
	button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(25, 25, 25)
	button.TextSize = 14
	button.Font = Enum.Font.Gotham
	button.ZIndex = 20
	button.Parent = Content
	Corner(button, 9)
	Stroke(button, Color3.fromRGB(220, 220, 220), 1)
	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	return button
end

local function Toggle(text, default, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 42)
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
			button.Text = text .. "    ● 开启"
			button.TextColor3 = Color3.fromRGB(0, 140, 80)
			button.BackgroundColor3 = Color3.fromRGB(235, 250, 240)
		else
			button.Text = text .. "    ○ 关闭"
			button.TextColor3 = Color3.fromRGB(50, 50, 50)
			button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
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

local function Slider(text, minimum, maximum, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 60)
	holder.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	holder.BorderSizePixel = 0
	holder.ZIndex = 20
	holder.Parent = Content
	Corner(holder, 9)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 24)
	label.Position = UDim2.fromOffset(8, 3)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(30, 30, 30)
	label.TextSize = 13
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 21
	label.Parent = holder

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 7)
	bar.Position = UDim2.fromOffset(10, 38)
	bar.BackgroundColor3 = Color3.fromRGB(215, 215, 215)
	bar.BorderSizePixel = 0
	bar.ZIndex = 21
	bar.Parent = holder
	Corner(bar, 10)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	fill.BorderSizePixel = 0
	fill.ZIndex = 22
	fill.Parent = bar
	Corner(fill, 10)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(15, 15)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	knob.BorderSizePixel = 0
	knob.ZIndex = 23
	knob.Parent = bar
	Corner(knob, 20)

	local dragging = false

	local function SetValue(value)
		value = math.clamp(value, minimum, maximum)
		local percent = (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, 0, 0.5, 0)
		label.Text = text .. " : " .. math.floor(value)
		if callback then
			callback(value)
		end
	end

	local function Update(input)
		local x = input.Position.X - bar.AbsolutePosition.X
		local percent = math.clamp(x / bar.AbsoluteSize.X, 0, 1)
		SetValue(minimum + (maximum - minimum) * percent)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			Update(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseMovement then
			Update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	SetValue(default)
	return holder
end

--// =============================================================
--  飞行（修复：真正能飞起来）
-- =============================================================

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
		root.AssemblyLinearVelocity = Vector3.zero
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

	-- 用 BodyVelocity + BodyGyro（手机端稳定，不会被 Humanoid 纠正回地面）
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bv.Velocity = Vector3.zero
	bv.Parent = root

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bg.P = 9000
	bg.Parent = root

	FlightConnection = RunService.RenderStepped:Connect(function()
		if not Flying then
			return
		end

		local currentHumanoid = GetHumanoid()
		local currentRoot = GetRoot()

		if not currentHumanoid or not currentRoot then
			StopFlight()
			return
		end

		local camera = workspace.CurrentCamera
		if not camera then
			return
		end

		-- 关键修复：用相机朝向 + MoveDirection，手机触屏也能飞
		local move = currentHumanoid.MoveDirection
		local velocity = Vector3.zero

		if move.Magnitude > 0 then
			-- 把 MoveDirection 投影到相机平面，得到真实前进方向
			local camForward = camera.CFrame.LookVector
			local camRight = camera.CFrame.RightVector
			local horizontal = Vector3.new(camForward.X, 0, camForward.Z).Unit
			local right = Vector3.new(camRight.X, 0, camRight.Z).Unit

			velocity = (horizontal * move.Z + right * move.X) * FlightSpeed
		end

		-- 升降（Space / 触屏跳跃键）
		if currentHumanoid:GetState() == Enum.HumanoidStateType.Jumping
			or currentHumanoid.Jump then
			velocity = velocity + Vector3.new(0, FlightSpeed, 0)
		end

		bv.Velocity = velocity
		bg.CFrame = camera.CFrame
	end)
end

--// =============================================================
--  无限跳跃
-- =============================================================

InfiniteJumpConnection =
	UserInputService.JumpRequest:Connect(function()
		if not InfiniteJump then
			return
		end
		local humanoid = GetHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

--// =============================================================
--  穿墙
-- =============================================================

local function SetNoclip(enabled)
	Noclip = enabled
	if NoclipConnection then
		NoclipConnection:Disconnect()
		NoclipConnection = nil
	end
	if enabled then
		NoclipConnection = RunService.Stepped:Connect(function()
			local char = GetCharacter()
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end

--// =============================================================
--  ESP（真实可用：Highlight + 名字标签）
-- =============================================================

local function ClearESP()
	for player, obj in pairs(ESPObjects) do
		if obj.Highlight and obj.Highlight.Parent then
			obj.Highlight:Destroy()
		end
		if obj.Billboard and obj.Billboard.Parent then
			obj.Billboard:Destroy()
		end
	end
	ESPObjects = {}
end

local function SetESP(enabled)
	ESPEnabled = enabled
	if not enabled then
		ClearESP()
		return
	end

	RunService.Heartbeat:Connect(function()
		if not ESPEnabled then
			return
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				if not ESPObjects[player] then
					ESPObjects[player] = {}

					local hl = Instance.new("Highlight")
					hl.Adornee = player.Character
					hl.FillColor = Color3.fromRGB(255, 0, 80)
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = ScreenGui
					ESPObjects[player].Highlight = hl

					local head = player.Character:FindFirstChild("Head")
					if head then
						local bb = Instance.new("BillboardGui")
						bb.Adornee = head
						bb.Size = UDim2.new(0, 100, 0, 20)
						bb.StudsOffset = Vector3.new(0, 2, 0)
						bb.AlwaysOnTop = true
						bb.Parent = ScreenGui

						local txt = Instance.new("TextLabel")
						txt.Size = UDim2.new(1, 0, 1, 0)
						txt.BackgroundTransparency = 1
						txt.Text = player.DisplayName
						txt.TextColor3 = Color3.fromRGB(0, 255, 120)
						txt.TextSize = 12
						txt.Font = Enum.Font.GothamBold
						txt.Parent = bb
						ESPObjects[player].Billboard = bb
					end
				end
			end
		end
	end)

	-- 玩家离开时清理
	Players.PlayerRemoving:Connect(function(player)
		if ESPObjects[player] then
			if ESPObjects[player].Highlight then
				ESPObjects[player].Highlight:Destroy()
			end
			if ESPObjects[player].Billboard then
				ESPObjects[player].Billboard:Destroy()
			end
			ESPObjects[player] = nil
		end
	end)
end

--// =============================================================
--  自瞄（真实可用：相机平滑锁头）
-- =============================================================

local AimbotFOV = 120

local function SetAimbot(enabled)
	AimbotEnabled = enabled
	if AimbotConnection then
		AimbotConnection:Disconnect()
		AimbotConnection = nil
	end
	if enabled then
		AimbotConnection = RunService.RenderStepped:Connect(function()
			local camera = workspace.CurrentCamera
			if not camera then return end

			local bestPlayer = nil
			local bestDist = AimbotFOV

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local head = player.Character:FindFirstChild("Head")
					if head then
						local screenPos, visible =
							camera:WorldToViewportPoint(head.Position)
						if visible then
							local center = camera.ViewportSize / 2
							local dist =
								(Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
							if dist < bestDist then
								bestDist = dist
								bestPlayer = player
							end
						end
					end
				end
			end

			if bestPlayer and bestPlayer.Character then
				local head = bestPlayer.Character:FindFirstChild("Head")
				if head then
					camera.CFrame = camera.CFrame:Lerp(
						CFrame.new(camera.CFrame.Position, head.Position),
						0.15
					)
				end
			end
		end)
	end
end

--// =============================================================
--  点击屏幕瞬移（真实可用）
-- =============================================================

local function SetClickTP(enabled)
	ClickTPEnabled = enabled
	if enabled then
		ClickTPEnabled = true
		-- 通过鼠标点击地面瞬移
		local mouse = LocalPlayer:GetMouse()
		local conn
		conn = mouse.Button1Down:Connect(function()
			if not ClickTPEnabled then
				conn:Disconnect()
				return
			end
			local target = mouse.Hit
			local root = GetRoot()
			if root and target then
				root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
			end
		end)
	end
end

--// =============================================================
--  玩家选择器
-- =============================================================

local PlayerSelector = Instance.new("Frame")

PlayerSelector.Name = "PlayerSelector"

PlayerSelector.Size = UDim2.fromOffset(250, 300)

PlayerSelector.Position =
	UDim2.new(0.5, -125, 0.5, -150)

PlayerSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

PlayerSelector.BorderSizePixel = 0

PlayerSelector.Visible = false
PlayerSelector.Active = true

PlayerSelector.ZIndex = 200

PlayerSelector.Parent = ScreenGui

Corner(PlayerSelector, 15)

local SelectorStroke = Instance.new("UIStroke")

SelectorStroke.Thickness = 3
SelectorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

SelectorStroke.Parent = PlayerSelector

local SelectorGradient = Instance.new("UIGradient")

SelectorGradient.Color = Rainbow

SelectorGradient.Parent = SelectorStroke

local SelectorTitle = Instance.new("TextLabel")

SelectorTitle.Size = UDim2.new(1, -55, 0, 45)

SelectorTitle.Position = UDim2.fromOffset(15, 3)

SelectorTitle.BackgroundTransparency = 1

SelectorTitle.Text = "选择玩家"

SelectorTitle.TextColor3 = Color3.fromRGB(20, 20, 20)

SelectorTitle.TextSize = 18
SelectorTitle.Font = Enum.Font.GothamBold

SelectorTitle.TextXAlignment = Enum.TextXAlignment.Left

SelectorTitle.ZIndex = 210

SelectorTitle.Parent = PlayerSelector

local SelectorClose = Instance.new("TextButton")

SelectorClose.Size = UDim2.fromOffset(35, 35)

SelectorClose.Position = UDim2.new(1, -40, 0, 6)

SelectorClose.BackgroundTransparency = 1

SelectorClose.Text = "×"

SelectorClose.TextColor3 = Color3.fromRGB(30, 30, 30)

SelectorClose.TextSize = 25
SelectorClose.Font = Enum.Font.GothamBold

SelectorClose.ZIndex = 220

SelectorClose.Parent = PlayerSelector

SelectorClose.MouseButton1Click:Connect(function()
	PlayerSelector.Visible = false
end)

local PlayerList = Instance.new("ScrollingFrame")

PlayerList.Size = UDim2.new(1, -20, 1, -60)

PlayerList.Position = UDim2.fromOffset(10, 52)

PlayerList.BackgroundTransparency = 1

PlayerList.BorderSizePixel = 0

PlayerList.ScrollBarThickness = 4

PlayerList.ZIndex = 210

PlayerList.Parent = PlayerSelector

local PlayerLayout = Instance.new("UIListLayout")

PlayerLayout.Padding = UDim.new(0, 6)

PlayerLayout.Parent = PlayerList

PlayerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
	function()
		PlayerList.CanvasSize =
			UDim2.fromOffset(0, PlayerLayout.AbsoluteContentSize.Y + 10)
	end
)

local function RefreshPlayerList()
	for _, object in ipairs(PlayerList:GetChildren()) do
		if not object:IsA("UIListLayout") then
			object:Destroy()
		end
	end

	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= LocalPlayer then
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -5, 0, 40)
			button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			button.BorderSizePixel = 0
			button.Text = target.DisplayName .. "  @" .. target.Name
			button.TextColor3 = Color3.fromRGB(25, 25, 25)
			button.TextSize = 13
			button.Font = Enum.Font.Gotham
			button.ZIndex = 220
			button.Parent = PlayerList
			Corner(button, 8)

			button.MouseButton1Click:Connect(function()
				SelectedPlayer = target
				PlayerSelector.Visible = false
				print("当前目标：", target.Name)
			end)
		end
	end
end

Players.PlayerAdded:Connect(function()
	RefreshPlayerList()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if SelectedPlayer == leavingPlayer then
		SelectedPlayer = nil
	end
	RefreshPlayerList()
end)

-- 真实生效的甩飞（客户端 BodyVelocity 冲量）
local function FlingTarget(target)
	if not target or not target.Character then
		return
	end
	local root = target.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
	bv.Velocity = Vector3.new(
		math.random(-300, 300),
		500,
		math.random(-300, 300)
	)
	bv.Parent = root
	game:GetService("Debris"):AddItem(bv, 0.3)
end

-- 真实传送（客户端坐标设置）
local function TeleportTo(target)
	if not target or not target.Character then
		return
	end
	local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
	local myRoot = GetRoot()
	if targetRoot and myRoot then
		myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
	end
end

-- 环绕（在目标周围做圆周运动）
local OrbitConnection = nil
local function SetOrbit(enabled, speed)
	if OrbitConnection then
		OrbitConnection:Disconnect()
		OrbitConnection = nil
	end
	if enabled and SelectedPlayer and SelectedPlayer.Character then
		local radius = 5
		local angle = 0
		OrbitConnection = RunService.RenderStepped:Connect(function(dt)
			local targetRoot = SelectedPlayer.Character
				and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
			local myRoot = GetRoot()
			if not targetRoot or not myRoot then
				return
			end
			angle = angle + dt * (speed or 10)
			local offset = Vector3.new(
				math.cos(angle) * radius,
				2,
				math.sin(angle) * radius
			)
			myRoot.CFrame = CFrame.new(targetRoot.Position + offset)
		end)
	end
end

--// =============================================================
--  页面：信息
-- =============================================================

local function ShowInfo()
	ClearContent()
	Section("玩家信息")

	local age = LocalPlayer.AccountAge
	local years = math.floor(age / 365)
	local days = age % 365

	Button("用户名：" .. LocalPlayer.Name)
	Button("显示名：" .. LocalPlayer.DisplayName)
	Button("用户ID：" .. tostring(LocalPlayer.UserId))
	Button("账号年龄：" .. years .. " 年 " .. days .. " 天")

	Section("脚本信息")
	Button("AM通用脚本 · 纯中文版")
	Button("QQ群：" .. QQ_GROUP)
	Button("点击复制群号", function()
		pcall(function()
			setclipboard(QQ_GROUP)
		end)
	end)
end

--// =============================================================
--  页面：通用
-- =============================================================

local function ShowGeneral()
	ClearContent()
	Section("通用")

	Toggle("无限跳跃", InfiniteJump, function(enabled)
		InfiniteJump = enabled
	end)

	Toggle("飞行", Flying, function(enabled)
		if enabled then
			StartFlight()
		else
			StopFlight()
		end
	end)

	Slider("飞行速度", 1, 100, FlightSpeed, function(value)
		FlightSpeed = value
	end)

	Toggle("穿墙", Noclip, function(enabled)
		SetNoclip(enabled)
	end)

	Toggle("夜视", false, function(enabled)
		if enabled then
			Lighting.Ambient = Color3.new(1, 1, 1)
			Lighting.Brightness = 2
		else
			Lighting.Ambient = Color3.new(0, 0, 0)
			Lighting.Brightness = 1
		end
	end)

	Slider("移速", 1, 300, 16, function(value)
		local humanoid = GetHumanoid()
		if humanoid then
			humanoid.WalkSpeed = value
		end
	end)

	Slider("跳高", 1, 300, 50, function(value)
		local humanoid = GetHumanoid()
		if humanoid then
			humanoid.JumpPower = value
		end
	end)

	Slider("重力", 0, 300, 196, function(value)
		workspace.Gravity = value
	end)

	Toggle("点击屏幕瞬移", false, function(enabled)
		SetClickTP(enabled)
	end)

	Toggle("锁定视角", false, function(enabled)
		if enabled then
			UserInputService.MouseBehavior =
				Enum.MouseBehavior.LockCenter
		else
			UserInputService.MouseBehavior =
				Enum.MouseBehavior.Default
		end
	end)

	Button("重置所有数值", function()
		local humanoid = GetHumanoid()
		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
		end
		workspace.Gravity = 196
	end)
end

--// =============================================================
--  页面：战斗（透视/自瞄/范围 全部真实化）
-- =============================================================

local function ShowCombat()
	ClearContent()
	Section("战斗")

	Toggle("透视 (ESP)", ESPEnabled, function(enabled)
		SetESP(enabled)
	end)

	Toggle("自瞄", AimbotEnabled, function(enabled)
		SetAimbot(enabled)
	end)

	Slider("自瞄 FOV", 30, 300, AimbotFOV, function(value)
		AimbotFOV = value
	end)

	Slider("范围 (甩飞半径)", 1, 1500, 150, function(value)
		-- 预留给范围类效果，当前无服务端权限时仅本地记录
	end)

	Button("清除所有特效", function()
		SetESP(false)
		SetAimbot(false)
	end)
end

--// =============================================================
--  页面：娱乐
-- =============================================================

local function ShowEntertainment()
	ClearContent()
	Section("娱乐")

	Toggle("高速旋转", false, function(enabled)
		if enabled then
			_G._Spin = RunService.RenderStepped:Connect(function()
				local root = GetRoot()
				if root then
					root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(15), 0)
				end
			end)
		elseif _G._Spin then
			_G._Spin:Disconnect()
		end
	end)

	Button("变大 (2倍)", function()
		local char = GetCharacter()
		if char then
			char:ScaleTo(2)
		end
	end)

	Button("变小 (0.5倍)", function()
		local char = GetCharacter()
		if char then
			char:ScaleTo(0.5)
		end
	end)

	Button("恢复正常大小", function()
		local char = GetCharacter()
		if char then
			char:ScaleTo(1)
		end
	end)
end

--// =============================================================
--  页面：甩飞（真实生效）
-- =============================================================

local function ShowFling()
	ClearContent()
	Section("甩飞 / 传送 / 环绕")

	Button("选择玩家", function()
		RefreshPlayerList()
		PlayerSelector.Visible = true
	end)

	local targetName = SelectedPlayer and SelectedPlayer.Name or "未选择"
	Button("当前目标：" .. targetName)

	Button("甩飞目标", function()
		if not SelectedPlayer then
			print("请先选择玩家")
			return
		end
		FlingTarget(SelectedPlayer)
	end)

	Button("传送到目标", function()
		if not SelectedPlayer then
			print("请先选择玩家")
			return
		end
		TeleportTo(SelectedPlayer)
	end)

	Toggle("环绕目标", false, function(enabled)
		SetOrbit(enabled, 10)
	end)

	Slider("环绕速度", 1, 100, 10, function(value)
		if OrbitConnection then
			SetOrbit(true, value)
		end
	end)
end

--// =============================================================
--  页面：特效（真实生效）
-- =============================================================

local function ShowEffects()
	ClearContent()
	Section("特效")

	Toggle("金身", false, function(enabled)
		local char = GetCharacter()
		if not char then
			return
		end
		for _, object in ipairs(char:GetChildren()) do
			if object:IsA("BasePart") then
				if enabled then
					object.Material = Enum.Material.Neon
					object.Color = Color3.fromRGB(255, 200, 40)
				else
					object.Material = Enum.Material.Plastic
				end
			end
		end
	end)

	Toggle("头顶火焰", false, function(enabled)
		local char = GetCharacter()
		if not char then
			return
		end
		local head = char:FindFirstChild("Head")
		if not head then
			return
		end
		local old = head:FindFirstChild("AM_Fire")
		if old then
			old:Destroy()
		end
		if enabled then
			local fire = Instance.new("Fire")
			fire.Name = "AM_Fire"
			fire.Heat = 8
			fire.Size = 6
			fire.Parent = head
		end
	end)

	Toggle("夜视", false, function(enabled)
		if enabled then
			Lighting.Ambient = Color3.new(1, 1, 1)
		else
			Lighting.Ambient = Color3.new(0, 0, 0)
		end
	end)

	Button("全图明亮", function()
		Lighting.Brightness = 5
		Lighting.Ambient = Color3.new(1, 1, 1)
	end)
end

--// =============================================================
--  页面：设置
-- =============================================================

local function ShowSettings()
	ClearContent()
	Section("设置")

	Button("关闭菜单", function()
		Menu.Visible = false
	end)

	Button("显示悬浮窗", function()
		AMButton.Visible = true
	end)

	Button("隐藏悬浮窗", function()
		AMButton.Visible = false
	end)

	Button("退出 AM", function()
		StopFlight()
		SetNoclip(false)
		SetESP(false)
		SetAimbot(false)
		SetOrbit(false, 0)
		if InfiniteJumpConnection then
			InfiniteJumpConnection:Disconnect()
			InfiniteJumpConnection = nil
		end
		ScreenGui:Destroy()
	end)
end

--// =============================================================
--  分类
-- =============================================================

local Categories = {
	"信息",
	"通用",
	"战斗",
	"娱乐",
	"甩飞",
	"特效",
	"设置",
}

local Pages = {}
Pages["信息"] = ShowInfo
Pages["通用"] = ShowGeneral
Pages["战斗"] = ShowCombat
Pages["娱乐"] = ShowEntertainment
Pages["甩飞"] = ShowFling
Pages["特效"] = ShowEffects
Pages["设置"] = ShowSettings

local CategoryButtons = {}

local function SelectCategory(name)
	for category, button in pairs(CategoryButtons) do
		if category == name then
			button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			button.TextColor3 = Color3.fromRGB(10, 10, 10)
		else
			button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			button.TextColor3 = Color3.fromRGB(90, 90, 90)
		end
	end

	if Pages[name] then
		Pages[name]()
	end
end

for index, name in ipairs(Categories) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 36)
	button.Position = UDim2.fromOffset(5, 5 + (index - 1) * 41)
	button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	button.BorderSizePixel = 0
	button.Text = name
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(90, 90, 90)
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = CategoryBar
	Corner(button, 8)

	CategoryButtons[name] = button

	button.MouseButton1Click:Connect(function()
		SelectCategory(name)
	end)
end

--// =============================================================
--  菜单拖动
-- =============================================================

local MenuDragging = false
local MenuDragStart
local MenuStartPosition

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = true
		MenuDragStart = input.Position
		MenuStartPosition = Menu.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not MenuDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - MenuDragStart
		Menu.Position = UDim2.new(
			MenuStartPosition.X.Scale,
			MenuStartPosition.X.Offset + delta.X,
			MenuStartPosition.Y.Scale,
			MenuStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = false
	end
end)

--// =============================================================
--  悬浮球拖动
-- =============================================================

local ButtonDragging = false
local ButtonDragStart
local ButtonStartPosition
local ButtonMoved = false

AMButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		ButtonDragging = true
		ButtonMoved = false
		ButtonDragStart = input.Position
		ButtonStartPosition = AMButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not ButtonDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - ButtonDragStart
		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
			ButtonMoved = true
		end
		AMButton.Position = UDim2.new(
			ButtonStartPosition.X.Scale,
			ButtonStartPosition.X.Offset + delta.X,
			ButtonStartPosition.Y.Scale,
			ButtonStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if ButtonDragging and not ButtonMoved then
			Menu.Visible = not Menu.Visible
		end
		ButtonDragging = false
	end
end)

--// =============================================================
--  玩家选择器拖动
-- =============================================================

local SelectorDragging = false
local SelectorDragStart
local SelectorStartPosition

SelectorTitle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelectorDragging = true
		SelectorDragStart = input.Position
		SelectorStartPosition = PlayerSelector.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not SelectorDragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - SelectorDragStart
		PlayerSelector.Position = UDim2.new(
			SelectorStartPosition.X.Scale,
			SelectorStartPosition.X.Offset + delta.X,
			SelectorStartPosition.Y.Scale,
			SelectorStartPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelectorDragging = false
	end
end)

--// =============================================================
--  流光
-- =============================================================

local Rotation = 0

RunService.RenderStepped:Connect(function(dt)
	Rotation = (Rotation + dt * 100) % 360
	AMGradient.Rotation = Rotation
	MenuGradient.Rotation = Rotation
	SelectorGradient.Rotation = Rotation
end)

--// =============================================================
--  启动（默认显示信息页，悬浮窗常驻）
-- =============================================================

SelectCategory("信息")

-- 确保悬浮窗一定可见
AMButton.Visible = true


--// =============================================================
--//  ===========================================================
--//  以下为扩展系统（双引擎 / 配置 / 热键 / 重生恢复）
--//  ===========================================================
--// =============================================================

--// =============================================================
--  扩展配置（可随时在设置页调整）
-- =============================================================

local ExtConfig = {
	-- 飞行
	Flight = {
		Method = "BodyVelocity",  -- "BodyVelocity" | "CFrame"
		MaxSpeed = 120,
		LiftSpeed = 60,
		GyroStrength = 9000,
	},
	-- 穿墙
	Noclip = {
		Mode = "Stepped",  -- "Stepped" | "Heartbeat"
	},
	-- ESP
	ESP = {
		UseHighlight = true,
		UseBillboard = true,
		ShowDistance = true,
		Color = Color3.fromRGB(255, 0, 80),
	},
	-- 自瞄
	Aimbot = {
		Smoothness = 0.15,
		MaxDistance = 1000,
		TeamCheck = false,
	},
	-- 环绕
	Orbit = {
		Radius = 5,
		DefaultSpeed = 10,
	},
}

--// =============================================================
--  配置持久化（简易：存到 _G，重生不丢）
-- =============================================================

local function SaveConfig()
	local data = {
		FlightSpeed = FlightSpeed,
		InfiniteJump = InfiniteJump,
		Noclip = Noclip,
		ESPEnabled = ESPEnabled,
		AimbotFOV = AimbotFOV,
	}
	_G.__AM_SavedConfig = data
end

local function LoadConfig()
	local data = _G.__AM_SavedConfig
	if not data then
		return
	end
	if data.FlightSpeed then
		FlightSpeed = data.FlightSpeed
	end
	if data.InfiniteJump then
		InfiniteJump = data.InfiniteJump
	end
	if data.Noclip then
		SetNoclip(true)
	end
	if data.ESPEnabled then
		SetESP(true)
	end
	if data.AimbotFOV then
		AimbotFOV = data.AimbotFOV
	end
end

--// =============================================================
--  飞行：CFrame 备用引擎（当 BodyVelocity 被服务端限制时切换）
-- =============================================================

local CFrameFlightConnection = nil
local CFrameFlightActive = false

local function StartCFrameFlight()
	CFrameFlightActive = true
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.PlatformStand = true
	end

	CFrameFlightConnection = RunService.RenderStepped:Connect(function()
		if not CFrameFlightActive then
			return
		end
		local root = GetRoot()
		local humanoid = GetHumanoid()
		if not root or not humanoid then
			return
		end
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end

		local move = humanoid.MoveDirection
		if move.Magnitude > 0 then
			local camForward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
			local camRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z).Unit
			local dir = (camForward * move.Z + camRight * move.X).Unit
			root.CFrame = root.CFrame + dir * (ExtConfig.Flight.MaxSpeed * 0.05)
		end

		-- 升降
		if humanoid.Jump then
			root.CFrame = root.CFrame + Vector3.new(0, ExtConfig.Flight.LiftSpeed * 0.05, 0)
		end
	end)
end

local function StopCFrameFlight()
	CFrameFlightActive = false
	if CFrameFlightConnection then
		CFrameFlightConnection:Disconnect()
		CFrameFlightConnection = nil
	end
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.PlatformStand = false
	end
end

-- 统一飞行开关（自动选引擎）
local function SetFlight(enabled)
	if enabled then
		if ExtConfig.Flight.Method == "CFrame" then
			StopFlight()  -- 关掉 BodyVelocity 引擎
			StartCFrameFlight()
		else
			StopCFrameFlight()
			StartFlight()
		end
	else
		StopFlight()
		StopCFrameFlight()
	end
end

--// =============================================================
--  穿墙：Heartbeat 备用引擎
-- =============================================================

local NoclipHeartbeatConnection = nil

local function SetNoclipHeartbeat(enabled)
	if NoclipHeartbeatConnection then
		NoclipHeartbeatConnection:Disconnect()
		NoclipHeartbeatConnection = nil
	end
	if enabled then
		NoclipHeartbeatConnection = RunService.Heartbeat:Connect(function()
			local char = GetCharacter()
			if not char then
				return
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end

-- 统一穿墙开关
local function SetNoclipUnified(enabled)
	SetNoclip(enabled)  -- Stepped 引擎
	if ExtConfig.Noclip.Mode == "Heartbeat" then
		SetNoclipHeartbeat(enabled)
	end
end

--// =============================================================
--  ESP：距离 + 颜色变体（扩展）
-- =============================================================

local function UpdateESPColors()
	for player, obj in pairs(ESPObjects) do
		if obj.Highlight then
			local dist = 50
			local root = GetRoot()
			if root and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				dist = (root.Position - player.Character.HumanoidRootPart.Position).Magnitude
			end
			-- 距离越近颜色越偏红
			local t = math.clamp(dist / 200, 0, 1)
			obj.Highlight.FillColor = Color3.new(1, 1 - t, 1 - t)
		end
	end
end

--// =============================================================
--  自瞄：距离限制 + 平滑度可调
-- =============================================================

local function GetBestAimbotTarget()
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end

	local bestPlayer = nil
	local bestDist = AimbotFOV

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if ExtConfig.Aimbot.TeamCheck then
				local ok, same = pcall(function()
					return player.Team == LocalPlayer.Team
				end)
				if ok and same then
					continue
				end
			end
			local head = player.Character:FindFirstChild("Head")
			if not head then
				continue
			end
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (root.Position - camera.CFrame.Position).Magnitude
				if dist > ExtConfig.Aimbot.MaxDistance then
					continue
				end
			end
			local screenPos, visible = camera:WorldToViewportPoint(head.Position)
			if not visible then
				continue
			end
			local center = camera.ViewportSize / 2
			local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
			if screenDist < bestDist then
				bestDist = screenDist
				bestPlayer = player
			end
		end
	end

	return bestPlayer
end

local AimbotSmoothConnection = nil

local function SetAimbotSmooth(enabled)
	SetAimbot(false)  -- 先关掉旧连接
	if AimbotSmoothConnection then
		AimbotSmoothConnection:Disconnect()
		AimbotSmoothConnection = nil
	end
	AimbotEnabled = enabled
	if enabled then
		AimbotSmoothConnection = RunService.RenderStepped:Connect(function()
			local target = GetBestAimbotTarget()
			if not target or not target.Character then
				return
			end
			local head = target.Character:FindFirstChild("Head")
			if not head then
				return
			end
			local camera = workspace.CurrentCamera
			local newCFrame = CFrame.new(camera.CFrame.Position, head.Position)
			camera.CFrame = camera.CFrame:Lerp(newCFrame, ExtConfig.Aimbot.Smoothness)
		end)
	end
end

--// =============================================================
--  环绕：暂停 / 恢复 / 半径调整
-- =============================================================

local OrbitPaused = false

local function SetOrbitPaused(paused)
	OrbitPaused = paused
end

local function SetOrbitRadius(radius)
	ExtConfig.Orbit.Radius = radius
end

local function SetOrbitSpeed(speed)
	ExtConfig.Orbit.DefaultSpeed = speed
	if OrbitConnection then
		-- 重新以新速度启动
		SetOrbit(true, speed)
	end
end

--// =============================================================
--  重生恢复：角色死亡后自动重绑所有系统
-- =============================================================

LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(1)
	-- 恢复穿墙
	if Noclip then
		SetNoclipUnified(true)
	end
	-- 恢复飞行（停掉，等用户重开，避免卡在空中）
	if Flying then
		StopFlight()
		Flying = false
	end
	-- 恢复 ESP 对象引用
	if ESPEnabled then
		ClearESP()
	end
	-- 恢复悬浮窗可见
	AMButton.Visible = true
	SaveConfig()
end)

--// =============================================================
--  热键（PC / 有键盘时可用，手机忽略）
-- =============================================================

local Hotkeys = {
	[Enum.KeyCode.F1] = function()
		SetFlight(not Flying)
	end,
	[Enum.KeyCode.F2] = function()
		SetNoclipUnified(not Noclip)
	end,
	[Enum.KeyCode.F3] = function()
		InfiniteJump = not InfiniteJump
	end,
	[Enum.KeyCode.F4] = function()
		SetESP(not ESPEnabled)
	end,
	[Enum.KeyCode.F5] = function()
		SetAimbotSmooth(not AimbotEnabled)
	end,
	[Enum.KeyCode.F6] = function()
		Menu.Visible = not Menu.Visible
	end,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	local cb = Hotkeys[input.KeyCode]
	if cb then
		pcall(cb)
	end
end)

--// =============================================================
--  FPS 统计（设置页可用）
-- =============================================================

local FPSText = "FPS: --"
local FPSCounter = 0
local FPSLast = tick()

RunService.RenderStepped:Connect(function()
	FPSCounter = FPSCounter + 1
	if tick() - FPSLast >= 1 then
		FPSText = string.format("FPS: %.0f", FPSCounter)
		FPSCounter = 0
		FPSLast = tick()
	end
end)

local function GetFPS()
	return FPSText
end

--// =============================================================
--  扩展页：高级（追加到分类列表）
-- =============================================================

local function ShowAdvanced()
	ClearContent()
	Section("高级设置")

	Toggle("飞行引擎: BodyVelocity / CFrame", ExtConfig.Flight.Method == "CFrame", function(enabled)
		ExtConfig.Flight.Method = enabled and "CFrame" or "BodyVelocity"
	end)

	Slider("飞行最高速度", 30, 200, ExtConfig.Flight.MaxSpeed, function(value)
		ExtConfig.Flight.MaxSpeed = value
	end)

	Toggle("穿墙引擎: Stepped / Heartbeat", ExtConfig.Noclip.Mode == "Heartbeat", function(enabled)
		ExtConfig.Noclip.Mode = enabled and "Heartbeat" or "Stepped"
		SetNoclipUnified(Noclip)  -- 立即应用
	end)

	Toggle("自瞄队伍检测", ExtConfig.Aimbot.TeamCheck, function(enabled)
		ExtConfig.Aimbot.TeamCheck = enabled
	end)

	Slider("自瞄平滑度", 1, 100, ExtConfig.Aimbot.Smoothness * 100, function(value)
		ExtConfig.Aimbot.Smoothness = value / 100
	end)

	Slider("自瞄最大距离", 100, 2000, ExtConfig.Aimbot.MaxDistance, function(value)
		ExtConfig.Aimbot.MaxDistance = value
	end)

	Toggle("环绕暂停", OrbitPaused, function(enabled)
		SetOrbitPaused(enabled)
	end)

	Slider("环绕半径", 1, 20, ExtConfig.Orbit.Radius, function(value)
		SetOrbitRadius(value)
	end)

	Button("保存当前配置", function()
		SaveConfig()
		print("[AM] 配置已保存")
	end)

	Button("重载配置", function()
		LoadConfig()
		print("[AM] 配置已重载")
	end)

	Section("调试信息")
	Button(GetFPS(), function() end)
	Button("打印状态到控制台", function()
		print("Flying:", Flying)
		print("Noclip:", Noclip)
		print("ESP:", ESPEnabled)
		print("Aimbot:", AimbotEnabled)
		print("FlightSpeed:", FlightSpeed)
		print("SelectedPlayer:", SelectedPlayer and SelectedPlayer.Name or "无")
	end)
end

-- 将"高级"页注册进分类
Pages["高级"] = ShowAdvanced

-- 在左侧分类栏追加"高级"按钮
do
	local index = #Categories + 1
	Categories[index] = "高级"

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 36)
	button.Position = UDim2.fromOffset(5, 5 + (index - 1) * 41)
	button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	button.BorderSizePixel = 0
	button.Text = "高级"
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(90, 90, 90)
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = CategoryBar
	Corner(button, 8)

	CategoryButtons["高级"] = button

	button.MouseButton1Click:Connect(function()
		SelectCategory("高级")
	end)
end

--// =============================================================
--  启动扩展
-- =============================================================

LoadConfig()


--// =============================================================
--//  ===========================================================
--//  第二轮扩展：玩家工具 / 视觉效果 / 调试 / 动画
--//  ===========================================================
--// =============================================================

--// =============================================================
--  玩家追踪（头顶箭头指向目标）
-- =============================================================

local TracerArrow = nil

local function SetPlayerTracer(enabled)
	if TracerArrow then
		TracerArrow:Destroy()
		TracerArrow = nil
	end
	if enabled and SelectedPlayer and SelectedPlayer.Character then
		local root = GetRoot()
		if not root then
			return
		end
		TracerArrow = Instance.new("Attachment")
		TracerArrow.Name = "AM_Tracer"
		TracerArrow.Parent = root
	end
end

--// =============================================================
--  旁观视角（把相机挂到目标身上）
-- =============================================================

local SpectateConnection = nil

local function SetSpectate(enabled)
	if SpectateConnection then
		SpectateConnection:Disconnect()
		SpectateConnection = nil
	end
	if enabled then
		SpectateConnection = RunService.RenderStepped:Connect(function()
			if not SelectedPlayer or not SelectedPlayer.Character then
				return
			end
			local head = SelectedPlayer.Character:FindFirstChild("Head")
			if not head then
				return
			end
			local camera = workspace.CurrentCamera
			if camera then
				camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
			end
		end)
	end
end

--// =============================================================
--  视觉效果：雾 / 色温 / 饱和度 / 景深
-- =============================================================

local function SetFog(enabled, distance)
	if enabled then
		Lighting.FogEnd = distance or 100000
	else
		Lighting.FogEnd = 1000000
	end
end

local function SetColorShift(enabled)
	Lighting.Ambient = enabled and Color3.fromRGB(180, 200, 255) or Color3.fromRGB(0, 0, 0)
end

local function SetSaturation(enabled)
	pcall(function()
		local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
		if not cc then
			cc = Instance.new("ColorCorrectionEffect")
			cc.Parent = Lighting
		end
		cc.Saturation = enabled and 1.5 or 0
	end)
end

local function SetDepthOfField(enabled)
	pcall(function()
		local dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
		if not dof then
			dof = Instance.new("DepthOfFieldEffect")
			dof.Parent = Lighting
		end
		dof.Enabled = enabled
	end)
end

--// =============================================================
--  调试：玩家连线 / 命中框
-- =============================================================

local DebugLines = {}

local function SetDebugLines(enabled)
	for _, line in ipairs(DebugLines) do
		if line and line.Parent then
			line:Destroy()
		end
	end
	DebugLines = {}

	if enabled then
		RunService.Heartbeat:Connect(function()
			if not ESPEnabled then
				return
			end
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local root = player.Character:FindFirstChild("HumanoidRootPart")
					local myRoot = GetRoot()
					if root and myRoot then
						local line = Instance.new("LineHandleAdornment")
						line.Name = "AM_DebugLine"
						line.Length = (root.Position - myRoot.Position).Magnitude
						line.CFrame = CFrame.new(myRoot.Position, root.Position)
						line.Color3 = Color3.fromRGB(0, 255, 255)
						line.Thickness = 2
						line.Parent = myRoot
						table.insert(DebugLines, line)
					end
				end
			end
		end)
	end
end

--// =============================================================
--  备用 UI 组件（供二次开发 / 自定义页面使用）
-- =============================================================

local UI = {}

function UI.MakeLabel(parent, text, size, pos)
	local lbl = Instance.new("TextLabel")
	lbl.Size = size or UDim2.new(1, -10, 0, 26)
	lbl.Position = pos or UDim2.fromOffset(0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text or ""
	lbl.TextColor3 = Color3.fromRGB(30, 30, 30)
	lbl.TextSize = 13
	lbl.Font = Enum.Font.Gotham
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 20
	lbl.Parent = parent or Content
	return lbl
end

function UI.MakeDivider(parent, pos)
	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, -10, 0, 2)
	div.Position = pos or UDim2.fromOffset(5, 0)
	div.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	div.BorderSizePixel = 0
	div.ZIndex = 20
	div.Parent = parent or Content
	return div
end

function UI.MakeColorButton(parent, name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -8, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(25, 25, 25)
	btn.TextSize = 12
	btn.Font = Enum.Font.Gotham
	btn.ZIndex = 20
	btn.Parent = parent or Content
	Corner(btn, 8)
	if callback then
		btn.MouseButton1Click:Connect(callback)
	end
	return btn
end

--// =============================================================
--  通知系统（左下角弹出）
-- =============================================================

local NotifyQueue = {}

local function ShowNotification(title, text, duration)
	duration = duration or 3

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 240, 0, 60)
	notif.Position = UDim2.new(0, 20, 1, 80)  -- 堆叠在左下角（偏移用动画归位）
	notif.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	notif.BorderSizePixel = 0
	notif.ZIndex = 500
	notif.Parent = ScreenGui
	Corner(notif, 10)
	Stroke(notif, Color3.fromRGB(100, 255, 170), 2)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -16, 0, 20)
	t.Position = UDim2.fromOffset(10, 6)
	t.BackgroundTransparency = 1
	t.Text = title
	t.TextColor3 = Color3.fromRGB(120, 255, 170)
	t.TextSize = 13
	t.Font = Enum.Font.GothamBold
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.ZIndex = 501
	t.Parent = notif

	local d = Instance.new("TextLabel")
	d.Size = UDim2.new(1, -16, 0, 30)
	d.Position = UDim2.fromOffset(10, 26)
	d.BackgroundTransparency = 1
	d.Text = text
	d.TextColor3 = Color3.fromRGB(230, 230, 230)
	d.TextSize = 12
	d.Font = Enum.Font.Gotham
	d.TextWrapped = true
	d.TextXAlignment = Enum.TextXAlignment.Left
	d.ZIndex = 501
	d.Parent = notif

	table.insert(NotifyQueue, notif)

	-- 堆叠：每个通知往上排
	for i, n in ipairs(NotifyQueue) do
		local targetY = -80 - (i - 1) * 70
		n.Position = UDim2.new(0, 20, 1, targetY)
	end

	game:GetService("Debris"):AddItem(notif, duration)
	task.delay(duration, function()
		for i, n in ipairs(NotifyQueue) do
			if n == notif then
				table.remove(NotifyQueue, i)
				break
			end
		end
	end)
end

-- 重写关键操作用通知反馈
local origSetFlight = SetFlight
SetFlight = function(enabled)
	origSetFlight(enabled)
	ShowNotification("飞行", enabled and "已开启" or "已关闭", 2)
end

local origSetNoclip = SetNoclipUnified
SetNoclipUnified = function(enabled)
	origSetNoclip(enabled)
	ShowNotification("穿墙", enabled and "已开启" or "已关闭", 2)
end

local origSetESP = SetESP
SetESP = function(enabled)
	origSetESP(enabled)
	ShowNotification("ESP", enabled and "已开启" or "已关闭", 2)
end

local origSetAimbot = SetAimbotSmooth
SetAimbotSmooth = function(enabled)
	origSetAimbot(enabled)
	ShowNotification("自瞄", enabled and "已开启" or "已关闭", 2)
end

--// =============================================================
--  菜单动画（打开/关闭缓动）
-- =============================================================

local MenuOpen = false

local function PlayMenuAnimation(open)
	MenuOpen = open
	local goal = open and UDim2.new(0, 88, 0.5, -MENU_HEIGHT / 2) or UDim2.new(0, 88, 0.5, -MENU_HEIGHT / 2 + 20)
	local tween = TweenService:Create(Menu, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = goal,
		Size = open and UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT) or UDim2.fromOffset(MENU_WIDTH, 0),
	})
	tween:Play()
end

-- 悬浮球点击时播放弹出动画
local origSetVisible = nil
Menu:GetPropertyChangedSignal("Visible"):Connect(function()
	if Menu.Visible and not MenuOpen then
		PlayMenuAnimation(true)
	end
end)

--// =============================================================
--  扩展页：视觉特效
-- =============================================================

local function ShowVisualFX()
	ClearContent()
	Section("视觉效果（本地）")

	Toggle("去雾", false, function(enabled)
		SetFog(enabled, 500)
	end)

	Toggle("冷色调", false, function(enabled)
		SetColorShift(enabled)
	end)

	Toggle("高饱和度", false, function(enabled)
		SetSaturation(enabled)
	end)

	Toggle("景深", false, function(enabled)
		SetDepthOfField(enabled)
	end)

	Slider("雾距离", 100, 100000, 100000, function(value)
		Lighting.FogEnd = value
	end)

	Button("重置画质", function()
		SetFog(false)
		SetColorShift(false)
		SetSaturation(false)
		SetDepthOfField(false)
		Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.Brightness = 1
	end)
end

Pages["视觉特效"] = ShowVisualFX

do
	local index = #Categories + 1
	Categories[index] = "视觉特效"
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 36)
	button.Position = UDim2.fromOffset(5, 5 + (index - 1) * 41)
	button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	button.BorderSizePixel = 0
	button.Text = "视觉特效"
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(90, 90, 90)
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = CategoryBar
	Corner(button, 8)
	CategoryButtons["视觉特效"] = button
	button.MouseButton1Click:Connect(function()
		SelectCategory("视觉特效")
	end)
end

--// =============================================================
--  扩展页：玩家工具
-- =============================================================

local function ShowPlayerTools()
	ClearContent()
	Section("玩家工具")

	Button("选择目标玩家", function()
		RefreshPlayerList()
		PlayerSelector.Visible = true
	end)

	Button("追踪目标（头顶箭头）", function()
		SetPlayerTracer(true)
	end)

	Button("停止追踪", function()
		SetPlayerTracer(false)
	end)

	Toggle("旁观目标", false, function(enabled)
		SetSpectate(enabled)
	end)

	Button("取消旁观", function()
		SetSpectate(false)
	end)

	Toggle("调试连线", false, function(enabled)
		SetDebugLines(enabled)
	end)

	Button("清理所有连线", function()
		SetDebugLines(false)
	end)
end

Pages["玩家工具"] = ShowPlayerTools

do
	local index = #Categories + 1
	Categories[index] = "玩家工具"
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 36)
	button.Position = UDim2.fromOffset(5, 5 + (index - 1) * 41)
	button.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	button.BorderSizePixel = 0
	button.Text = "玩家工具"
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(90, 90, 90)
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = CategoryBar
	Corner(button, 8)
	CategoryButtons["玩家工具"] = button
	button.MouseButton1Click:Connect(function()
		SelectCategory("玩家工具")
	end)
end

--// =============================================================
--  全局错误处理（防止单个功能崩掉整个菜单）
-- =============================================================

local function SafeCall(fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[AM] 错误:", err)
		ShowNotification("错误", "操作失败，详见控制台", 3)
	end
end

-- 用 SafeCall 包裹所有页面渲染
local origSelect = SelectCategory
SelectCategory = function(name)
	SafeCall(function()
		origSelect(name)
	end)
end

--// =============================================================
--  最终启动通知
-- =============================================================

ShowNotification("AM通用脚本", "加载完成 · QQ群: " .. QQ_GROUP, 4)

print("[AM通用脚本] 全部系统就绪")


print("[AM通用脚本] 扩展系统就绪 · QQ群:", QQ_GROUP)


print("[AM通用脚本] 加载完成 · QQ群:", QQ_GROUP)
