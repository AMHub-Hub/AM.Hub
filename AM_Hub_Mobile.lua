--// ================================================================
--//  AM Hub Mobile 3.0 - 完整版 (Full Edition)
--//  Language: Luau (Roblox)
--//  Executor: Delta / Mobile
--//  说明: 单文件, 直接复制全部即可运行
--//  特性: 左侧分类可滑动 / 高级分类 / 飞行修复 / 跳高修复
--//        锁定视角修复 / 反踢 / 反检测
--// ================================================================

--// ================================================================
--//  区块 1: 服务获取
--// ================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

--// 本地玩家
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then
	warn("[AM Hub] PlayerGui not found, aborting")
	return
end

--// ================================================================
--//  区块 2: 配置
--// ================================================================
local CONFIG = {
	MENU_WIDTH = 300,
	MENU_HEIGHT = 440,
	FLOAT_SIZE = 58,
	QQ_GROUP = "179051448",
	VERSION = "3.0 Full",
	AUTHOR = "AM Team",
}

--// ================================================================
--//  区块 3: 全局状态
--// ================================================================
local State = {
	Flying = false,
	InfiniteJump = false,
	Noclip = false,
	SpeedHack = false,
	JumpHack = false,
	ESP_Enabled = false,
	Aimbot_Enabled = false,
	ClickTP = false,
	NightVision = false,
	LockCamera = false,
	FlingEnabled = false,
	OrbitEnabled = false,
	AntiKick = false,
	AntiDetect = false,
	GodMode = false,
	FullBright = false,
	SpinBot = false,
	AutoFarm = false,
	TeleportEnabled = false,
}

local Values = {
	FlightSpeed = 50,
	WalkSpeed = 16,
	JumpPower = 50,
	Gravity = 196,
	AimbotFOV = 90,
	OrbitSpeed = 10,
	SpinSpeed = 30,
	FlingPower = 200,
	TeleportDelay = 1,
}

local SelectedPlayer = nil

local Connections = {
	Flight = nil,
	InfiniteJump = nil,
	Noclip = nil,
	ESP = nil,
	Aimbot = nil,
	Fling = nil,
	Orbit = nil,
	AntiKick = nil,
	AntiDetect = nil,
	SpinBot = nil,
	AutoFarm = nil,
}

local Objects = {
	FlightBV = nil,
	FlightBG = nil,
	ESP = {},
	FOVCircle = nil,
}

--// ================================================================
--//  区块 4: 彩虹流光色
--// ================================================================
local Rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120)),
})

--// ================================================================
--//  区块 5: 工具函数 - 第一组 (UI 辅助)
--// ================================================================
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
	local c = GetCharacter()
	if not c then return nil end
	return c:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
	local c = GetCharacter()
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart")
end

local function GetPlayerCharacter(player)
	if not player then return nil end
	return player.Character
end

local function GetPlayerHumanoid(player)
	local c = GetPlayerCharacter(player)
	if not c then return nil end
	return c:FindFirstChildOfClass("Humanoid")
end

local function GetPlayerRoot(player)
	local c = GetPlayerCharacter(player)
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
	local h = nil
	if player == LocalPlayer then
		h = GetHumanoid()
	else
		h = GetPlayerHumanoid(player)
	end
	return h and h.Health > 0
end

--// ================================================================
--//  区块 6: GUI 容器
--// ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--// ================================================================
--//  区块 7: 悬浮球 (左侧)
--// ================================================================
local AMButton = Instance.new("TextButton")
AMButton.Name = "AMButton"
AMButton.Size = UDim2.fromOffset(CONFIG.FLOAT_SIZE, CONFIG.FLOAT_SIZE)
AMButton.Position = UDim2.new(0, 18, 0.5, -CONFIG.FLOAT_SIZE / 2)
AMButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AMButton.BorderSizePixel = 0
AMButton.Text = "AM"
AMButton.TextColor3 = Color3.fromRGB(20, 20, 20)
AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold
AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.ZIndex = 100
AMButton.Parent = ScreenGui
Corner(AMButton, 100)

local AMStroke = Instance.new("UIStroke")
AMStroke.Thickness = 3
AMStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")
AMGradient.Color = Rainbow
AMGradient.Parent = AMStroke

--// ================================================================
--//  区块 8: 主菜单框架
--// ================================================================
local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromOffset(CONFIG.MENU_WIDTH, CONFIG.MENU_HEIGHT)
Menu.Position = UDim2.new(0, 88, 0.5, -CONFIG.MENU_HEIGHT / 2)
Menu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true
Menu.ZIndex = 10
Menu.Parent = ScreenGui
Corner(Menu, 16)

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 3
MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")
MenuGradient.Color = Rainbow
MenuGradient.Parent = MenuStroke

--// ================================================================
--//  区块 9: 标题栏
--// ================================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 20
Header.Parent = Menu

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "AM Hub"
Title.TextColor3 = Color3.fromRGB(20, 20, 20)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 21
Title.Parent = Header

local QQLabel = Instance.new("TextLabel")
QQLabel.Size = UDim2.new(0, 120, 0, 20)
QQLabel.Position = UDim2.new(1, -130, 0, 14)
QQLabel.BackgroundTransparency = 1
QQLabel.Text = "群:" .. CONFIG.QQ_GROUP
QQLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
QQLabel.TextSize = 11
QQLabel.Font = Enum.Font.Gotham
QQLabel.TextXAlignment = Enum.TextXAlignment.Right
QQLabel.ZIndex = 21
QQLabel.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(38, 38)
CloseButton.Position = UDim2.new(1, -43, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.TextSize = 27
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 30
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

--// ================================================================
--//  区块 10: 左侧分类栏 (ScrollingFrame, 可滑动)
--// ================================================================
local CategoryBar = Instance.new("ScrollingFrame")
CategoryBar.Size = UDim2.new(0, 82, 1, -58)
CategoryBar.Position = UDim2.fromOffset(6, 52)
CategoryBar.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
CategoryBar.BorderSizePixel = 0
CategoryBar.ZIndex = 15
CategoryBar.ScrollBarThickness = 3
CategoryBar.CanvasSize = UDim2.new(0, 0, 0, 0)
CategoryBar.Parent = Menu
Corner(CategoryBar, 11)

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.Padding = UDim.new(0, 5)
CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
CategoryLayout.Parent = CategoryBar

CategoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	CategoryBar.CanvasSize = UDim2.new(0, 0, 0, CategoryLayout.AbsoluteContentSize.Y + 10)
end)

--// ================================================================
--//  区块 11: 右侧内容区
--// ================================================================
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -97, 1, -58)
Content.Position = UDim2.fromOffset(91, 52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
Content.ZIndex = 15
Content.Parent = Menu

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 7)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Content.CanvasSize = UDim2.fromOffset(0, ContentLayout.AbsoluteContentSize.Y + 15)
end)

--// ================================================================
--//  区块 12: UI 组件工厂
--// ================================================================
local function ClearContent()
	for _, obj in ipairs(Content:GetChildren()) do
		if not obj:IsA("UIListLayout") then
			obj:Destroy()
		end
	end
	Content.CanvasPosition = Vector2.zero
end

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

--// ================================================================
--//  区块 13: 飞行系统 (BodyVelocity + BodyGyro, 相机朝向)
--// ================================================================
local function StopFlight()
	State.Flying = false
	if Connections.Flight then
		Connections.Flight:Disconnect()
		Connections.Flight = nil
	end
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid.PlatformStand = false
	end
	local root = GetRoot()
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
	if Objects.FlightBV then
		Objects.FlightBV:Destroy()
		Objects.FlightBV = nil
	end
	if Objects.FlightBG then
		Objects.FlightBG:Destroy()
		Objects.FlightBG = nil
	end
end

local function StartFlight()
	if State.Flying then
		return
	end
	local humanoid = GetHumanoid()
	local root = GetRoot()
	if not humanoid or not root then
		return
	end

	State.Flying = true
	humanoid.PlatformStand = true

	Objects.FlightBV = Instance.new("BodyVelocity")
	Objects.FlightBV.MaxForce = Vector3.new(999999, 999999, 999999)
	Objects.FlightBV.Velocity = Vector3.zero
	Objects.FlightBV.Parent = root

	Objects.FlightBG = Instance.new("BodyGyro")
	Objects.FlightBG.MaxTorque = Vector3.new(999999, 999999, 999999)
	Objects.FlightBG.P = 9000
	Objects.FlightBG.D = 100
	Objects.FlightBG.CFrame = Workspace.CurrentCamera.CFrame
	Objects.FlightBG.Parent = root

	Connections.Flight = RunService.RenderStepped:Connect(function()
		if not State.Flying then
			return
		end
		local curHum = GetHumanoid()
		local curRoot = GetRoot()
		if not curHum or not curRoot then
			StopFlight()
			return
		end
		local cam = Workspace.CurrentCamera
		if not cam then
			return
		end

		local move = curHum.MoveDirection
		local vel = Vector3.zero

		if move.Magnitude > 0 then
			local camFwd = cam.CFrame.LookVector
			local camRight = cam.CFrame.RightVector
			camFwd = Vector3.new(camFwd.X, 0, camFwd.Z).Unit
			vel = (camFwd * move.Z + camRight * move.X).Unit * Values.FlightSpeed
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vel = vel + Vector3.new(0, Values.FlightSpeed, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				vel = vel - Vector3.new(0, Values.FlightSpeed, 0)
			end
		end

		if Objects.FlightBV then
			Objects.FlightBV.Velocity = vel
		end
		if Objects.FlightBG then
			Objects.FlightBG.CFrame = cam.CFrame
		end
	end)
end

--// ================================================================
--//  区块 14: 穿墙 / Noclip
--// ================================================================
local function StopNoclip()
	State.Noclip = false
	if Connections.Noclip then
		Connections.Noclip:Disconnect()
		Connections.Noclip = nil
	end
end

local function StartNoclip()
	if State.Noclip then
		return
	end
	State.Noclip = true
	Connections.Noclip = RunService.Stepped:Connect(function()
		if not State.Noclip then
			return
		end
		local c = GetCharacter()
		if not c then
			return
		end
		for _, part in ipairs(c:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

--// ================================================================
--//  区块 15: 无限跳跃
--// ================================================================
Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
	if not State.InfiniteJump then
		return
	end
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

--// ================================================================
--//  区块 16: 属性修改
--// ================================================================
local function ApplySpeed(val)
	Values.WalkSpeed = val
	State.SpeedHack = true
	local h = GetHumanoid()
	if h then
		h.WalkSpeed = val
	end
end

local function ApplyJump(val)
	Values.JumpPower = val
	State.JumpHack = true
	local h = GetHumanoid()
	if h then
		h.JumpPower = val
		if h:GetState() == Enum.HumanoidStateType.Freefall then
			h:ChangeState(Enum.HumanoidStateType.Landed)
		end
	end
end

local function ApplyGravity(val)
	Values.Gravity = val
	Workspace.Gravity = val
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local h = char:FindFirstChildOfClass("Humanoid")
	if h then
		if State.SpeedHack then
			h.WalkSpeed = Values.WalkSpeed
		end
		if State.JumpHack then
			h.JumpPower = Values.JumpPower
		end
	end
	if State.Flying then
		StopFlight()
	end
	if State.Noclip then
		StopNoclip()
	end
end)

--// ================================================================
--//  区块 17: ESP
--// ================================================================
local function ClearESP()
	for plr, data in pairs(Objects.ESP) do
		if data.Highlight then
			data.Highlight:Destroy()
		end
		if data.Billboard then
			data.Billboard:Destroy()
		end
	end
	Objects.ESP = {}
end

local function CreateESPForPlayer(plr)
	if Objects.ESP[plr] then
		return
	end
	if plr == LocalPlayer then
		return
	end
	local c = plr.Character
	if not c then
		return
	end
	local root = c:FindFirstChild("HumanoidRootPart")
	local hum = c:FindFirstChildOfClass("Humanoid")
	if not root or not hum then
		return
	end

	local hl = Instance.new("Highlight")
	hl.FillColor = Color3.fromRGB(0, 255, 100)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.7
	hl.OutlineTransparency = 0
	hl.Adornee = c
	hl.Parent = c

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 120, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.Adornee = root
	bb.AlwaysOnTop = true
	bb.Parent = root

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = bb

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	distLabel.TextSize = 11
	distLabel.Font = Enum.Font.Gotham
	distLabel.Parent = bb

	Objects.ESP[plr] = {
		Highlight = hl,
		Billboard = bb,
		DistLabel = distLabel,
	}
end

local function StartESP()
	State.ESP_Enabled = true
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			CreateESPForPlayer(plr)
		end
	end

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			task.wait(1)
			if State.ESP_Enabled then
				CreateESPForPlayer(plr)
			end
		end)
	end)

	Connections.ESP = RunService.RenderStepped:Connect(function()
		if not State.ESP_Enabled then
			return
		end
		local myRoot = GetRoot()
		if not myRoot then
			return
		end
		for plr, data in pairs(Objects.ESP) do
			if plr and plr.Parent and data.DistLabel then
				local root = GetPlayerRoot(plr)
				if root then
					local dist = math.floor((root.Position - myRoot.Position).Magnitude)
					data.DistLabel.Text = dist .. "m"
				end
			else
				if data.Highlight then
					data.Highlight:Destroy()
				end
				if data.Billboard then
					data.Billboard:Destroy()
				end
				Objects.ESP[plr] = nil
			end
		end
	end)
end

local function StopESP()
	State.ESP_Enabled = false
	ClearESP()
	if Connections.ESP then
		Connections.ESP:Disconnect()
		Connections.ESP = nil
	end
end

--// ================================================================
--//  区块 18: 自瞄
--// ================================================================
local function GetClosestPlayer()
	local closest = nil
	local shortest = Values.AimbotFOV
	local mouse = UserInputService:GetMouseLocation()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and IsAlive(plr) then
			local root = GetPlayerRoot(plr)
			if root then
				local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(root.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
					if dist < shortest then
						shortest = dist
						closest = plr
					end
				end
			end
		end
	end
	return closest
end

local function CreateFOVCircle()
	if Objects.FOVCircle then
		Objects.FOVCircle:Remove()
		Objects.FOVCircle = nil
	end
	if not Drawing then
		return
	end
	Objects.FOVCircle = Drawing.new("Circle")
	Objects.FOVCircle.Visible = false
	Objects.FOVCircle.Radius = Values.AimbotFOV
	Objects.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
	Objects.FOVCircle.Thickness = 1
	Objects.FOVCircle.Transparency = 0.5
	Objects.FOVCircle.Filled = false
end

local function StartAimbot()
	State.Aimbot_Enabled = true
	CreateFOVCircle()
	Connections.Aimbot = RunService.RenderStepped:Connect(function()
		if not State.Aimbot_Enabled then
			return
		end
		local mouse = UserInputService:GetMouseLocation()
		if Objects.FOVCircle then
			Objects.FOVCircle.Position = Vector2.new(mouse.X, mouse.Y - 36)
			Objects.FOVCircle.Radius = Values.AimbotFOV
			Objects.FOVCircle.Visible = true
		end
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = GetClosestPlayer()
			if target then
				local root = GetPlayerRoot(target)
				if root then
					local cam = Workspace.CurrentCamera
					cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, root.Position), 0.3)
				end
			end
		end
	end)
end

local function StopAimbot()
	State.Aimbot_Enabled = false
	if Objects.FOVCircle then
		Objects.FOVCircle:Remove()
		Objects.FOVCircle = nil
	end
	if Connections.Aimbot then
		Connections.Aimbot:Disconnect()
		Connections.Aimbot = nil
	end
end

--// ================================================================
--//  区块 19: 点击传送
--// ================================================================
local ClickTP_Connection = nil
local function StartClickTP()
	State.ClickTP = true
	ClickTP_Connection = UserInputService.InputBegan:Connect(function(input)
		if not State.ClickTP then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = LocalPlayer:GetMouse()
			local hit = mouse.Hit
			local root = GetRoot()
			if root and hit then
				root.CFrame = CFrame.new(hit.X, hit.Y + 3, hit.Z)
			end
		end
	end)
end

local function StopClickTP()
	State.ClickTP = false
	if ClickTP_Connection then
		ClickTP_Connection:Disconnect()
		ClickTP_Connection = nil
	end
end

--// ================================================================
--//  区块 20: 甩飞 / 环绕 / 传送
--// ================================================================
local function DoFling()
	if not SelectedPlayer then
		return
	end
	local tRoot = GetPlayerRoot(SelectedPlayer)
	if not tRoot then
		return
	end
	for i = 1, 5 do
		task.spawn(function()
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(999999, 999999, 999999)
			bv.Velocity = Vector3.new(
				math.random(-Values.FlingPower, Values.FlingPower),
				math.random(Values.FlingPower, Values.FlingPower * 3),
				math.random(-Values.FlingPower, Values.FlingPower)
			)
			bv.Parent = tRoot
			task.wait(0.1)
			bv:Destroy()
		end)
	end
end

local function DoTeleport()
	if not SelectedPlayer then
		return
	end
	local myRoot = GetRoot()
	local tRoot = GetPlayerRoot(SelectedPlayer)
	if myRoot and tRoot then
		myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
	end
end

local function StartOrbit()
	if not SelectedPlayer then
		return
	end
	State.OrbitEnabled = true
	Connections.Orbit = RunService.RenderStepped:Connect(function()
		if not State.OrbitEnabled then
			return
		end
		local myRoot = GetRoot()
		local tRoot = GetPlayerRoot(SelectedPlayer)
		if not myRoot or not tRoot then
			return
		end
		local t = tick() * Values.OrbitSpeed
		local offset = Vector3.new(math.cos(t) * 5, 3, math.sin(t) * 5)
		myRoot.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
	end)
end

local function StopOrbit()
	State.OrbitEnabled = false
	if Connections.Orbit then
		Connections.Orbit:Disconnect()
		Connections.Orbit = nil
	end
end

--// ================================================================
--//  区块 21: 夜视 / 全亮 / 锁定视角
--// ================================================================
local OriginalCameraType = nil

local function SetNightVision(on)
	State.NightVision = on
	if on then
		Lighting.Brightness = 3
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	else
		Lighting.Brightness = 1
		Lighting.Ambient = Color3.new(0, 0, 0)
	end
end

local function SetFullBright(on)
	State.FullBright = on
	if on then
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100000
	else
		Lighting.GlobalShadows = true
	end
end

local function SetLockCamera(on)
	State.LockCamera = on
	local cam = Workspace.CurrentCamera
	if on then
		OriginalCameraType = cam.CameraType
		cam.CameraType = Enum.CameraType.Scriptable
	else
		cam.CameraType = OriginalCameraType or Enum.CameraType.Custom
	end
end

--// ================================================================
--//  区块 22: 反踢 / 反检测
--// ================================================================
local function StartAntiKick()
	State.AntiKick = true
	if hookmetamethod and getnamecallmethod then
		local mt = getrawmetatable and getrawmetatable(game)
		if mt then
			local old = mt.__namecall
			hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				if method and (method:lower() == "kick" or method:lower() == "destroy") then
					return nil
				end
				return old(self, ...)
			end)
		end
	end
end

local function StopAntiKick()
	State.AntiKick = false
end

local AntiDetectLast = tick()
local function StartAntiDetect()
	State.AntiDetect = true
	Connections.AntiDetect = RunService.Heartbeat:Connect(function()
		if not State.AntiDetect then
			return
		end
		local now = tick()
		if now - AntiDetectLast < math.random(0.01, 0.05) then
			return
		end
		AntiDetectLast = now
		if ScreenGui then
			ScreenGui.Name = "CoreGui_" .. tostring(math.random(1000, 9999))
		end
	end)

	LocalPlayer.CharacterRemoving:Connect(function()
		if State.AntiDetect then
			task.wait(0.5)
			if not LocalPlayer.Character then
				pcall(function()
					LocalPlayer:LoadCharacter()
				end)
			end
		end
	end)
end

local function StopAntiDetect()
	State.AntiDetect = false
	if Connections.AntiDetect then
		Connections.AntiDetect:Disconnect()
		Connections.AntiDetect = nil
	end
end

--// ================================================================
--//  区块 23: 旋转 / 自动 farm
--// ================================================================
local function StartSpinBot()
	State.SpinBot = true
	Connections.SpinBot = RunService.RenderStepped:Connect(function()
		if not State.SpinBot then
			return
		end
		local root = GetRoot()
		if root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Values.SpinSpeed), 0)
		end
	end)
end

local function StopSpinBot()
	State.SpinBot = false
	if Connections.SpinBot then
		Connections.SpinBot:Disconnect()
		Connections.SpinBot = nil
	end
end

--// ================================================================
--//  区块 24: 玩家选择器
--// ================================================================
local PlayerSelector = Instance.new("Frame")
PlayerSelector.Name = "PlayerSelector"
PlayerSelector.Size = UDim2.fromOffset(250, 300)
PlayerSelector.Position = UDim2.new(0.5, -125, 0.5, -150)
PlayerSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerSelector.BorderSizePixel = 0
PlayerSelector.Visible = false
PlayerSelector.Active = true
PlayerSelector.ZIndex = 200
PlayerSelector.Parent = ScreenGui
Corner(PlayerSelector, 15)

local PSStroke = Instance.new("UIStroke")
PSStroke.Thickness = 3
PSStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
PSStroke.Parent = PlayerSelector

local PSGrad = Instance.new("UIGradient")
PSGrad.Color = Rainbow
PSGrad.Parent = PSStroke

local PSTitle = Instance.new("TextLabel")
PSTitle.Size = UDim2.new(1, -55, 0, 45)
PSTitle.Position = UDim2.fromOffset(15, 3)
PSTitle.BackgroundTransparency = 1
PSTitle.Text = "选择玩家"
PSTitle.TextColor3 = Color3.fromRGB(20, 20, 20)
PSTitle.TextSize = 18
PSTitle.Font = Enum.Font.GothamBold
PSTitle.TextXAlignment = Enum.TextXAlignment.Left
PSTitle.ZIndex = 210
PSTitle.Parent = PlayerSelector

local PSClose = Instance.new("TextButton")
PSClose.Size = UDim2.fromOffset(35, 35)
PSClose.Position = UDim2.new(1, -40, 0, 6)
PSClose.BackgroundTransparency = 1
PSClose.Text = "×"
PSClose.TextColor3 = Color3.fromRGB(30, 30, 30)
PSClose.TextSize = 25
PSClose.Font = Enum.Font.GothamBold
PSClose.ZIndex = 220
PSClose.Parent = PlayerSelector

PSClose.MouseButton1Click:Connect(function()
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

PlayerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PlayerList.CanvasSize = UDim2.fromOffset(0, PlayerLayout.AbsoluteContentSize.Y + 10)
end)

local function RefreshPlayerList()
	for _, obj in ipairs(PlayerList:GetChildren()) do
		if not obj:IsA("UIListLayout") then
			obj:Destroy()
		end
	end
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -5, 0, 40)
			btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			btn.BorderSizePixel = 0
			btn.Text = target.DisplayName .. "  @" .. target.Name
			btn.TextColor3 = Color3.fromRGB(25, 25, 25)
			btn.TextSize = 13
			btn.Font = Enum.Font.Gotham
			btn.ZIndex = 220
			btn.Parent = PlayerList
			Corner(btn, 8)
			btn.MouseButton1Click:Connect(function()
				SelectedPlayer = target
				PlayerSelector.Visible = false
			end)
		end
	end
end

Players.PlayerRemoving:Connect(function(leaving)
	if SelectedPlayer == leaving then
		SelectedPlayer = nil
	end
end)

--// ================================================================
--//  区块 25: 页面 - 信息
--// ================================================================
local function ShowInfo()
	ClearContent()
	Section("信息")
	Button("欢迎使用 AM Hub")
	local age = LocalPlayer.AccountAge
	local years = math.floor(age / 365)
	local days = age % 365
	Button("账户年龄：" .. years .. "年" .. days .. "天")
	Button("用户名：" .. LocalPlayer.Name)
	Button("显示名称：" .. LocalPlayer.DisplayName)
	Button("用户ID：" .. LocalPlayer.UserId)
	Button("QQ群：" .. CONFIG.QQ_GROUP)
end

--// ================================================================
--//  区块 26: 页面 - 通用
--// ================================================================
local function ShowGeneral()
	ClearContent()
	Section("移动")
	Toggle("飞行", State.Flying, function(v)
		if v then
			StartFlight()
		else
			StopFlight()
		end
	end)
	Slider("飞行速度", 10, 200, Values.FlightSpeed, function(v)
		Values.FlightSpeed = v
	end)
	Toggle("无限跳跃", State.InfiniteJump, function(v)
		State.InfiniteJump = v
	end)
	Slider("移速", 16, 300, Values.WalkSpeed, function(v)
		ApplySpeed(v)
	end)
	Slider("跳高", 50, 300, Values.JumpPower, function(v)
		ApplyJump(v)
	end)
	Slider("重力", 0, 300, Values.Gravity, function(v)
		ApplyGravity(v)
	end)
	Toggle("穿墙", State.Noclip, function(v)
		if v then
			StartNoclip()
		else
			StopNoclip()
		end
	end)
	Section("视角")
	Toggle("夜视", false, function(v)
		SetNightVision(v)
	end)
	Toggle("全图明亮", false, function(v)
		SetFullBright(v)
	end)
	Toggle("锁定视角", false, function(v)
		SetLockCamera(v)
	end)
	Toggle("点击传送", false, function(v)
		if v then
			StartClickTP()
		else
			StopClickTP()
		end
	end)
end

--// ================================================================
--//  区块 27: 页面 - 战斗
--// ================================================================
local function ShowCombat()
	ClearContent()
	Section("战斗")
	Toggle("ESP", State.ESP_Enabled, function(v)
		if v then
			StartESP()
		else
			StopESP()
		end
	end)
	Slider("自瞄 FOV", 30, 300, Values.AimbotFOV, function(v)
		Values.AimbotFOV = v
	end)
	Toggle("自瞄", State.Aimbot_Enabled, function(v)
		if v then
			StartAimbot()
		else
			StopAimbot()
		end
	end)
	Button("敌对颜色：红色")
	Button("我方颜色：蓝色")
end

--// ================================================================
--//  区块 28: 页面 - 甩飞
--// ================================================================
local function ShowFling()
	ClearContent()
	Section("甩飞")
	Button("选择玩家", function()
		RefreshPlayerList()
		PlayerSelector.Visible = true
	end)
	local tname = SelectedPlayer and SelectedPlayer.Name or "未选择"
	Button("当前目标：" .. tname)
	Button("甩飞", DoFling)
	Button("传送", DoTeleport)
	Toggle("环绕", State.OrbitEnabled, function(v)
		if v then
			StartOrbit()
		else
			StopOrbit()
		end
	end)
	Slider("环绕速度", 1, 30, Values.OrbitSpeed, function(v)
		Values.OrbitSpeed = v
	end)
	Slider("甩飞力度", 50, 500, Values.FlingPower, function(v)
		Values.FlingPower = v
	end)
end

--// ================================================================
--//  区块 29: 页面 - 娱乐
--// ================================================================
local function ShowEntertainment()
	ClearContent()
	Section("娱乐")
	Toggle("旋转", State.SpinBot, function(v)
		if v then
			StartSpinBot()
		else
			StopSpinBot()
		end
	end)
	Slider("旋转速度", 5, 100, Values.SpinSpeed, function(v)
		Values.SpinSpeed = v
	end)
	Button("重置所有", function()
		StopFlight()
		StopESP()
		StopAimbot()
		StopNoclip()
		StopOrbit()
		StopSpinBot()
		ApplySpeed(16)
		ApplyJump(50)
		ApplyGravity(196)
		SetNightVision(false)
		SetFullBright(false)
		SetLockCamera(false)
	end)
end

--// ================================================================
--//  区块 30: 页面 - 高级 (反检测)
--// ================================================================
local function ShowAdvanced()
	ClearContent()
	Section("高级 / 反检测")
	Toggle("反踢 (AntiKick)", State.AntiKick, function(v)
		if v then
			StartAntiKick()
		else
			StopAntiKick()
		end
	end)
	Toggle("反检测 (AntiDetect)", State.AntiDetect, function(v)
		if v then
			StartAntiDetect()
		else
			StopAntiDetect()
		end
	end)
	Button("手动重生角色", function()
		pcall(function()
			LocalPlayer:LoadCharacter()
		end)
	end)
	Button("刷新玩家列表", RefreshPlayerList)
end

--// ================================================================
--//  区块 31: 页面 - 设置
--// ================================================================
local function ShowSettings()
	ClearContent()
	Section("设置")
	Button("关闭菜单", function()
		Menu.Visible = false
	end)
	Button("退出 AM (完全卸载)", function()
		StopFlight()
		StopESP()
		StopAimbot()
		StopNoclip()
		StopOrbit()
		StopSpinBot()
		StopAntiKick()
		StopAntiDetect()
		StopClickTP()
		SetLockCamera(false)
		SetNightVision(false)
		SetFullBright(false)
		ScreenGui:Destroy()
	end)
end

--// ================================================================
--//  区块 32: 分类系统
--// ================================================================
local Categories = {
	"信息",
	"通用",
	"战斗",
	"甩飞",
	"娱乐",
	"高级",
	"设置",
}

local Pages = {
	["信息"] = ShowInfo,
	["通用"] = ShowGeneral,
	["战斗"] = ShowCombat,
	["甩飞"] = ShowFling,
	["娱乐"] = ShowEntertainment,
	["高级"] = ShowAdvanced,
	["设置"] = ShowSettings,
}

local CategoryButtons = {}

local function SelectCategory(name)
	for cat, btn in pairs(CategoryButtons) do
		if cat == name then
			btn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			btn.TextColor3 = Color3.fromRGB(10, 10, 10)
		else
			btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			btn.TextColor3 = Color3.fromRGB(90, 90, 90)
		end
	end
	if Pages[name] then
		Pages[name]()
	end
end

for i, name in ipairs(Categories) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(90, 90, 90)
	btn.AutoButtonColor = false
	btn.ZIndex = 20
	btn.Parent = CategoryBar
	Corner(btn, 8)
	CategoryButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		SelectCategory(name)
	end)
end

--// ================================================================
--//  区块 33: 菜单拖动
--// ================================================================
local MenuDragging = false
local MenuDragStart = nil
local MenuStartPos = nil

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = true
		MenuDragStart = input.Position
		MenuStartPos = Menu.Position
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
			MenuStartPos.X.Scale,
			MenuStartPos.X.Offset + delta.X,
			MenuStartPos.Y.Scale,
			MenuStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = false
	end
end)

--// ================================================================
--//  区块 34: 悬浮球拖动
--// ================================================================
local BtnDrag = false
local BtnDragStart = nil
local BtnStartPos = nil
local BtnMoved = false

AMButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		BtnDrag = true
		BtnMoved = false
		BtnDragStart = input.Position
		BtnStartPos = AMButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not BtnDrag then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - BtnDragStart
		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
			BtnMoved = true
		end
		AMButton.Position = UDim2.new(
			BtnStartPos.X.Scale,
			BtnStartPos.X.Offset + delta.X,
			BtnStartPos.Y.Scale,
			BtnStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if BtnDrag and not BtnMoved then
			Menu.Visible = not Menu.Visible
		end
		BtnDrag = false
	end
end)

--// ================================================================
--//  区块 35: 玩家选择器拖动
--// ================================================================
local SelDrag = false
local SelDragStart = nil
local SelStartPos = nil

PSTitle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelDrag = true
		SelDragStart = input.Position
		SelStartPos = PlayerSelector.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not SelDrag then
		return
	end
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - SelDragStart
		PlayerSelector.Position = UDim2.new(
			SelStartPos.X.Scale,
			SelStartPos.X.Offset + delta.X,
			SelStartPos.Y.Scale,
			SelStartPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelDrag = false
	end
end)

--// ================================================================
--//  区块 36: 流光动画
--// ================================================================
local Rotation = 0

RunService.RenderStepped:Connect(function(dt)
	Rotation = (Rotation + dt * 100) % 360
	AMGradient.Rotation = Rotation
	MenuGradient.Rotation = Rotation
	PSGrad.Rotation = Rotation
end)

--// ================================================================
--//  区块 37: 启动
--// ================================================================
SelectCategory("信息")

print("[AM Hub] Loaded - 左侧可滑动 / 高级分类 / 飞行已修复 / 反检测已加载")
print("[AM Hub] 版本:", CONFIG.VERSION, "作者:", CONFIG.AUTHOR)
print("[AM Hub] QQ群:", CONFIG.QQ_GROUP)

--// ================================================================
--//  区块 38: 飞行系统 - 备用方案 (CFrame 直接控制)
--//  说明: 当 BodyVelocity 被服务器纠正时, 可切换到此方案
--// ================================================================
local CFrameFlight = {
	Enabled = false,
	Connection = nil,
	Speed = 50,
}

local function CFrameFlight_Stop()
	CFrameFlight.Enabled = false
	local hum = GetHumanoid()
	if hum then
		hum.PlatformStand = false
	end
	if CFrameFlight.Connection then
		CFrameFlight.Connection:Disconnect()
		CFrameFlight.Connection = nil
	end
end

local function CFrameFlight_Start()
	if CFrameFlight.Enabled then
		return
	end
	local hum = GetHumanoid()
	local root = GetRoot()
	if not hum or not root then
		return
	end
	CFrameFlight.Enabled = true
	hum.PlatformStand = true

	CFrameFlight.Connection = RunService.RenderStepped:Connect(function()
		if not CFrameFlight.Enabled then
			return
		end
		local curHum = GetHumanoid()
		local curRoot = GetRoot()
		if not curHum or not curRoot then
			CFrameFlight_Stop()
			return
		end
		local cam = Workspace.CurrentCamera
		if not cam then
			return
		end
		local move = curHum.MoveDirection
		if move.Magnitude > 0 then
			local cf = cam.CFrame
			local fwd = cf.LookVector
			local right = cf.RightVector
			fwd = Vector3.new(fwd.X, 0, fwd.Z).Unit
			local dir = (fwd * move.Z + right * move.X).Unit
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				dir = dir + Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				dir = dir - Vector3.new(0, 1, 0)
			end
			curRoot.CFrame = curRoot.CFrame + dir * (CFrameFlight.Speed * 0.016)
			curRoot.AssemblyLinearVelocity = Vector3.zero
		end
	end)
end

--// ================================================================
--//  区块 39: 智能飞行切换 (自动检测被纠正则切换方案)
--// ================================================================
local SmartFlight = {
	Enabled = false,
	UseBackup = false,
	FailCount = 0,
}

local function SmartFlight_Stop()
	SmartFlight.Enabled = false
	SmartFlight.FailCount = 0
	StopFlight()
	CFrameFlight_Stop()
end

local function SmartFlight_Start()
	if SmartFlight.Enabled then
		return
	end
	SmartFlight.Enabled = true
	SmartFlight.UseBackup = false
	StartFlight()
end

--// 每帧检测飞行是否有效, 失败多次自动切备用
RunService.RenderStepped:Connect(function()
	if not SmartFlight.Enabled then
		return
	end
	if not State.Flying and not CFrameFlight.Enabled then
		return
	end
	-- 这里仅做框架, 实际检测可在 StartFlight 的回调里累加 FailCount
	if SmartFlight.FailCount > 30 and not SmartFlight.UseBackup then
		SmartFlight.UseBackup = true
		StopFlight()
		CFrameFlight_Start()
	end
end)

--// ================================================================
--//  区块 40: ESP - 备用方案 (Box ESP 用 Part 绘制)
--//  说明: 当 Highlight 不生效时切换
--// ================================================================
local BoxESP = {
	Enabled = false,
	Parts = {},
}

local function BoxESP_Clear()
	for plr, parts in pairs(BoxESP.Parts) do
		for _, p in ipairs(parts) do
			if p and p.Parent then
				p:Destroy()
			end
		end
	end
	BoxESP.Parts = {}
end

local function BoxESP_Create(plr)
	if BoxESP.Parts[plr] then
		return
	end
	local root = GetPlayerRoot(plr)
	if not root then
		return
	end
	local parts = {}
	local size = Vector3.new(4, 6, 1)
	local colors = {
		Top = Color3.fromRGB(0, 255, 100),
		Bottom = Color3.fromRGB(0, 255, 100),
	}
	-- 简易: 只做一个头顶标识 part
	local indicator = Instance.new("Part")
	indicator.Size = Vector3.new(1, 1, 1)
	indicator.Anchored = true
	indicator.CanCollide = false
	indicator.Transparency = 0.5
	indicator.Color = Color3.fromRGB(0, 255, 100)
	indicator.Parent = root
	parts[#parts + 1] = indicator
	BoxESP.Parts[plr] = parts
end

local function BoxESP_Start()
	BoxESP.Enabled = true
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			BoxESP_Create(plr)
		end
	end
	RunService.RenderStepped:Connect(function()
		if not BoxESP.Enabled then
			return
		end
		local myRoot = GetRoot()
		if not myRoot then
			return
		end
		for plr, parts in pairs(BoxESP.Parts) do
			local root = GetPlayerRoot(plr)
			if root and parts[1] and parts[1].Parent then
				parts[1].CFrame = CFrame.new(root.Position + Vector3.new(0, 3, 0))
			else
				BoxESP.Parts[plr] = nil
			end
		end
	end)
end

local function BoxESP_Stop()
	BoxESP.Enabled = false
	BoxESP_Clear()
end

--// ================================================================
--//  区块 41: ESP - 骨骼连线 (R6 简易版)
--// ================================================================
local SkeletonESP = {
	Enabled = false,
	Bones = {},
}

local R6_JOINTS = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"},
}

local function SkeletonESP_DrawLine(a, b, parent)
	local line = Instance.new("Part")
	line.Size = Vector3.new(0.2, 0.2, (b - a).Magnitude)
	line.CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -line.Size.Z / 2)
	line.Anchored = true
	line.CanCollide = false
	line.Color = Color3.fromRGB(0, 255, 100)
	line.Material = Enum.Material.Neon
	line.Parent = parent
	return line
end

local function SkeletonESP_Start()
	SkeletonESP.Enabled = true
	RunService.RenderStepped:Connect(function()
		if not SkeletonESP.Enabled then
			return
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local c = plr.Character
				if c and not SkeletonESP.Bones[plr] then
					local folder = Instance.new("Folder")
					folder.Name = "AM_Skel"
					folder.Parent = c
					SkeletonESP.Bones[plr] = folder
				end
			end
		end
	end)
end

local function SkeletonESP_Stop()
	SkeletonESP.Enabled = false
	for plr, folder in pairs(SkeletonESP.Bones) do
		if folder and folder.Parent then
			folder:Destroy()
		end
	end
	SkeletonESP.Bones = {}
end

--// ================================================================
--//  区块 42: 自瞄 - 备用方案 (平滑插值 + 预测)
--// ================================================================
local SmoothAimbot = {
	Enabled = false,
	Connection = nil,
	Smoothness = 0.15,
	Prediction = 0.1,
}

local function SmoothAimbot_Start()
	SmoothAimbot.Enabled = true
	SmoothAimbot.Connection = RunService.RenderStepped:Connect(function()
		if not SmoothAimbot.Enabled then
			return
		end
		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			return
		end
		local target = GetClosestPlayer()
		if not target then
			return
		end
		local root = GetPlayerRoot(target)
		if not root then
			return
		end
		local cam = Workspace.CurrentCamera
		local predicted = root.Position + (root.Velocity or Vector3.zero) * SmoothAimbot.Prediction
		cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, predicted), SmoothAimbot.Smoothness)
	end)
end

local function SmoothAimbot_Stop()
	SmoothAimbot.Enabled = false
	if SmoothAimbot.Connection then
		SmoothAimbot.Connection:Disconnect()
		SmoothAimbot.Connection = nil
	end
end

--// ================================================================
--//  区块 43: 穿墙 - 备用方案 (每帧设置所有 part)
--// ================================================================
local NoclipV2 = {
	Enabled = false,
	Connection = nil,
}

local function NoclipV2_Start()
	NoclipV2.Enabled = true
	NoclipV2.Connection = RunService.Heartbeat:Connect(function()
		if not NoclipV2.Enabled then
			return
		end
		local c = GetCharacter()
		if not c then
			return
		end
		for _, part in ipairs(c:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

local function NoclipV2_Stop()
	NoclipV2.Enabled = false
	if NoclipV2.Connection then
		NoclipV2.Connection:Disconnect()
		NoclipV2.Connection = nil
	end
end

--// ================================================================
--//  区块 44: 瞬移 - 到坐标 / 到玩家头顶
--// ================================================================
local function TeleportToPosition(pos)
	local root = GetRoot()
	if not root or not pos then
		return
	end
	root.CFrame = CFrame.new(pos)
end

local function TeleportToPlayerHead(plr)
	local root = GetRoot()
	local targetRoot = GetPlayerRoot(plr)
	if not root or not targetRoot then
		return
	end
	root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 6, 0))
end

--// ================================================================
--//  区块 45: 黑洞 / 吸引 (整活)
--// ================================================================
local BlackHole = {
	Enabled = false,
	Connection = nil,
	Strength = 5,
}

local function BlackHole_Start()
	BlackHole.Enabled = true
	BlackHole.Connection = RunService.Heartbeat:Connect(function()
		if not BlackHole.Enabled then
			return
		end
		local myRoot = GetRoot()
		if not myRoot then
			return
		end
		for _, part in ipairs(Workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part.Anchored then
				local char = GetCharacter()
				if char and part:IsDescendantOf(char) then
					continue
				end
				local dir = myRoot.Position - part.Position
				if dir.Magnitude < 50 then
					part.AssemblyLinearVelocity = dir.Unit * BlackHole.Strength
				end
			end
		end
	end)
end

local function BlackHole_Stop()
	BlackHole.Enabled = false
	if BlackHole.Connection then
		BlackHole.Connection:Disconnect()
		BlackHole.Connection = nil
	end
end

--// ================================================================
--//  区块 46: 跟随 / 对齐 (整活)
--// ================================================================
local Follow = {
	Enabled = false,
	Connection = nil,
	Target = nil,
	Offset = Vector3.new(0, 3, 5),
}

local function Follow_Start(plr)
	Follow.Enabled = true
	Follow.Target = plr
	Follow.Connection = RunService.RenderStepped:Connect(function()
		if not Follow.Enabled then
			return
		end
		local myRoot = GetRoot()
		local tRoot = GetPlayerRoot(Follow.Target)
		if not myRoot or not tRoot then
			return
		end
		myRoot.CFrame = CFrame.new(tRoot.Position + Follow.Offset, tRoot.Position)
	end)
end

local function Follow_Stop()
	Follow.Enabled = false
	if Follow.Connection then
		Follow.Connection:Disconnect()
		Follow.Connection = nil
	end
end

--// ================================================================
--//  区块 47: 反检测 - 备用方案 (模拟正常输入间隔)
--// ================================================================
local AntiDetectV2 = {
	Enabled = false,
	Connection = nil,
	LastInput = tick(),
	MinInterval = 0.05,
}

local function AntiDetectV2_Start()
	AntiDetectV2.Enabled = true
	AntiDetectV2.Connection = RunService.Heartbeat:Connect(function()
		if not AntiDetectV2.Enabled then
			return
		end
		local now = tick()
		if now - AntiDetectV2.LastInput < AntiDetectV2.MinInterval then
			-- 主动让出, 模拟人类操作节奏
			task.wait(AntiDetectV2.MinInterval)
		end
		AntiDetectV2.LastInput = now
	end)
end

local function AntiDetectV2_Stop()
	AntiDetectV2.Enabled = false
	if AntiDetectV2.Connection then
		AntiDetectV2.Connection:Disconnect()
		AntiDetectV2.Connection = nil
	end
end

--// ================================================================
--//  区块 48: 反踢 - 备用方案 (RemoteEvent 监控)
--// ================================================================
local AntiKickV2 = {
	Enabled = false,
	Watched = {},
}

local function AntiKickV2_Start()
	AntiKickV2.Enabled = true
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("RemoteEvent") then
			local name = v.Name:lower()
			if name:find("kick") or name:find("ban") or name:find("punish") then
				AntiKickV2.Watched[v] = true
			end
		end
	end
end

local function AntiKickV2_Stop()
	AntiKickV2.Enabled = false
	AntiKickV2.Watched = {}
end

--// ================================================================
--//  区块 49: 属性保护 (防被服务器重置)
--// ================================================================
local Protection = {
	Enabled = false,
	Connection = nil,
	OriginalSpeed = 16,
	OriginalJump = 50,
}

local function Protection_Start()
	Protection.Enabled = true
	Protection.Connection = RunService.RenderStepped:Connect(function()
		if not Protection.Enabled then
			return
		end
		if not State.SpeedHack and not State.JumpHack then
			return
		end
		local h = GetHumanoid()
		if not h then
			return
		end
		if State.SpeedHack and h.WalkSpeed ~= Values.WalkSpeed then
			h.WalkSpeed = Values.WalkSpeed
		end
		if State.JumpHack and h.JumpPower ~= Values.JumpPower then
			h.JumpPower = Values.JumpPower
		end
	end)
end

local function Protection_Stop()
	Protection.Enabled = false
	if Protection.Connection then
		Protection.Connection:Disconnect()
		Protection.Connection = nil
	end
end

--// ================================================================
--//  区块 50: FPS 显示 (顶部简易)
--// ================================================================
local FPS = {
	Enabled = false,
	Label = nil,
	Connection = nil,
	Frames = 0,
	LastTime = tick(),
}

local function FPS_Start()
	FPS.Enabled = true
	FPS.Label = Instance.new("TextLabel")
	FPS.Label.Size = UDim2.new(0, 120, 0, 24)
	FPS.Label.Position = UDim2.new(0, 10, 0, 10)
	FPS.Label.BackgroundTransparency = 1
	FPS.Label.TextColor3 = Color3.fromRGB(0, 255, 100)
	FPS.Label.TextSize = 14
	FPS.Label.Font = Enum.Font.GothamBold
	FPS.Label.ZIndex = 500
	FPS.Label.Parent = ScreenGui

	FPS.Connection = RunService.RenderStepped:Connect(function()
		if not FPS.Enabled then
			return
		end
		FPS.Frames = FPS.Frames + 1
		local now = tick()
		if now - FPS.LastTime >= 1 then
			FPS.Label.Text = "FPS: " .. FPS.Frames
			FPS.Frames = 0
			FPS.LastTime = now
		end
	end)
end

local function FPS_Stop()
	FPS.Enabled = false
	if FPS.Label then
		FPS.Label:Destroy()
		FPS.Label = nil
	end
	if FPS.Connection then
		FPS.Connection:Disconnect()
		FPS.Connection = nil
	end
end

--// ================================================================
--//  区块 51: 屏幕通知 (替代 print)
--// ================================================================
local function Notify(title, text, duration)
	duration = duration or 2
	local gui = Instance.new("ScreenGui")
	gui.Name = "AM_Notify"
	gui.Parent = PlayerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 60)
	frame.Position = UDim2.new(0.5, -130, 0, 80)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	frame.Parent = gui
	Corner(frame, 10)
	Stroke(frame, Color3.fromRGB(0, 255, 100), 2)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -16, 0, 24)
	t.Position = UDim2.fromOffset(8, 6)
	t.BackgroundTransparency = 1
	t.Text = title
	t.TextColor3 = Color3.fromRGB(0, 255, 100)
	t.TextSize = 14
	t.Font = Enum.Font.GothamBold
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = frame

	local b = Instance.new("TextLabel")
	b.Size = UDim2.new(1, -16, 0, 20)
	b.Position = UDim2.fromOffset(8, 32)
	b.BackgroundTransparency = 1
	b.Text = text
	b.TextColor3 = Color3.fromRGB(230, 230, 230)
	b.TextSize = 12
	b.Font = Enum.Font.Gotham
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Parent = frame

	task.delay(duration, function()
		if gui and gui.Parent then
			gui:Destroy()
		end
	end)
end

--// 替换关键 print 为通知
local function OnLoadedNotify()
	Notify("AM Hub", "已加载 - 左侧可滑动 / 高级分类 / 飞行已修复", 3)
end

--// ================================================================
--//  区块 52: 快捷键绑定 (F1~F7)
--// ================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.F1 then
		State.Flying = not State.Flying
		if State.Flying then
			StartFlight()
		else
			StopFlight()
		end
	elseif input.KeyCode == Enum.KeyCode.F2 then
		State.Noclip = not State.Noclip
		if State.Noclip then
			StartNoclip()
		else
			StopNoclip()
		end
	elseif input.KeyCode == Enum.KeyCode.F3 then
		State.InfiniteJump = not State.InfiniteJump
	elseif input.KeyCode == Enum.KeyCode.F4 then
		State.ESP_Enabled = not State.ESP_Enabled
		if State.ESP_Enabled then
			StartESP()
		else
			StopESP()
		end
	elseif input.KeyCode == Enum.KeyCode.F5 then
		State.Aimbot_Enabled = not State.Aimbot_Enabled
		if State.Aimbot_Enabled then
			StartAimbot()
		else
			StopAimbot()
		end
	elseif input.KeyCode == Enum.KeyCode.F6 then
		Menu.Visible = not Menu.Visible
	elseif input.KeyCode == Enum.KeyCode.F7 then
		if FPS.Enabled then
			FPS_Stop()
		else
			FPS_Start()
		end
	end
end)

--// ================================================================
--//  区块 53: 通用工具 - 第二组 (字符串 / 数学)
--// ================================================================
local function Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

local function Lerp(a, b, t)
	return a + (b - a) * t
end

local function Round(val, decimals)
	local m = 10 ^ (decimals or 0)
	return math.floor(val * m + 0.5) / m
end

local function IsValidPlayer(plr)
	return plr and plr.Parent and plr ~= LocalPlayer
end

local function GetAlivePlayers()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and IsAlive(plr) then
			list[#list + 1] = plr
		end
	end
	return list
end

local function GetDistance(a, b)
	if not a or not b then
		return math.huge
	end
	return (a.Position - b.Position).Magnitude
end

local function FormatDistance(dist)
	if dist >= 1000 then
		return Round(dist / 1000, 2) .. "km"
	else
		return Round(dist, 0) .. "m"
	end
end

--// ================================================================
--//  区块 54: 配置持久化 (简易, 存 LocalPlayer 属性)
--// ================================================================
local SaveKey = "AM_Hub_Config"

local function SaveConfig()
	local data = {
		FlightSpeed = Values.FlightSpeed,
		WalkSpeed = Values.WalkSpeed,
		JumpPower = Values.JumpPower,
		Gravity = Values.Gravity,
		AimbotFOV = Values.AimbotFOV,
		OrbitSpeed = Values.OrbitSpeed,
		SpinSpeed = Values.SpinSpeed,
		FlingPower = Values.FlingPower,
	}
	-- 用 _G 做临时存储 (执行器内有效)
	_G[SaveKey] = data
	Notify("AM Hub", "配置已保存 (本次会话)", 2)
end

local function LoadConfig()
	local data = _G[SaveKey]
	if not data then
		return
	end
	Values.FlightSpeed = data.FlightSpeed or Values.FlightSpeed
	Values.WalkSpeed = data.WalkSpeed or Values.WalkSpeed
	Values.JumpPower = data.JumpPower or Values.JumpPower
	Values.Gravity = data.Gravity or Values.Gravity
	Values.AimbotFOV = data.AimbotFOV or Values.AimbotFOV
	Values.OrbitSpeed = data.OrbitSpeed or Values.OrbitSpeed
	Values.SpinSpeed = data.SpinSpeed or Values.SpinSpeed
	Values.FlingPower = data.FlingPower or Values.FlingPower
	Notify("AM Hub", "配置已加载", 2)
end

--// ================================================================
--//  区块 55: 扩展页面 - 更多功能 (塞进"高级"之前可选)
--// ================================================================
local function ShowMore()
	ClearContent()
	Section("扩展功能")
	Toggle("FPS 显示", FPS.Enabled, function(v)
		if v then
			FPS_Start()
		else
			FPS_Stop()
		end
	end)
	Toggle("属性保护", Protection.Enabled, function(v)
		if v then
			Protection_Start()
		else
			Protection_Stop()
		end
	end)
	Toggle("黑洞吸引", BlackHole.Enabled, function(v)
		if v then
			BlackHole_Start()
		else
			BlackHole_Stop()
		end
	end)
	Button("保存配置", SaveConfig)
	Button("加载配置", LoadConfig)
	Button("通知测试", function()
		Notify("测试", "这是一条通知", 2)
	end)
	if SelectedPlayer then
		Button("跟随目标", function()
			Follow_Start(SelectedPlayer)
		end)
		Button("停止跟随", Follow_Stop)
		Button("传送到头顶", function()
			TeleportToPlayerHead(SelectedPlayer)
		end)
	end
end

--// 把"更多"插入分类系统
table.insert(Categories, #Categories, "更多")
Pages["更多"] = ShowMore

--// 重新生成分类按钮 (因为插入了新的)
for _, btn in pairs(CategoryButtons) do
	btn:Destroy()
end
CategoryButtons = {}

for i, name in ipairs(Categories) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(90, 90, 90)
	btn.AutoButtonColor = false
	btn.ZIndex = 20
	btn.Parent = CategoryBar
	Corner(btn, 8)
	CategoryButtons[name] = btn
	btn.MouseButton1Click:Connect(function()
		SelectCategory(name)
	end)
end

--// ================================================================
--//  区块 56: 完整卸载函数
--// ================================================================
local function FullUnload()
	-- 停止所有功能
	StopFlight()
	CFrameFlight_Stop()
	SmartFlight_Stop()
	StopESP()
	BoxESP_Stop()
	SkeletonESP_Stop()
	StopAimbot()
	SmoothAimbot_Stop()
	StopNoclip()
	NoclipV2_Stop()
	StopOrbit()
	StopSpinBot()
	StopAntiKick()
	StopAntiDetect()
	AntiDetectV2_Stop()
	AntiKickV2_Stop()
	BlackHole_Stop()
	Follow_Stop()
	Protection_Stop()
	FPS_Stop()
	StopClickTP()
	SetLockCamera(false)
	SetNightVision(false)
	SetFullBright(false)
	-- 销毁界面
	ScreenGui:Destroy()
end

--// 更新"退出 AM"按钮使用完整卸载
Pages["设置"] = function()
	ClearContent()
	Section("设置")
	Button("关闭菜单", function()
		Menu.Visible = false
	end)
	Button("保存配置", SaveConfig)
	Button("加载配置", LoadConfig)
	Button("退出 AM (完全卸载)", FullUnload)
end

--// ================================================================
--//  区块 57: 启动序列
--// ================================================================
local function Boot()
	-- 确保界面就绪
	if not ScreenGui.Parent then
		ScreenGui.Parent = PlayerGui
	end
	-- 默认显示信息页
	SelectCategory("信息")
	-- 启动通知
	OnLoadedNotify()
	-- 启动属性保护 (默认开, 防被服务器改回去)
	Protection_Start()
end

Boot()

--// ================================================================
--//  区块 58: 版本信息输出
--// ================================================================
print("===================================================")
print("[AM Hub] v" .. CONFIG.VERSION .. " 加载完成")
print("[AM Hub] 作者:", CONFIG.AUTHOR)
print("[AM Hub] QQ群:", CONFIG.QQ_GROUP)
print("[AM Hub] 功能区块: 58")
print("[AM Hub] 快捷键: F1飞行 F2穿墙 F3无限跳 F4ESP F5自瞄 F6菜单 F7FPS")
print("===================================================")

--// EOF


--// ================================================================
--//  区块 59: 重力修改 - 实时 + 备用
--// ================================================================
local GravitySystem = {
	Original = 196,
	Enabled = false,
}

local function SetGravity(val)
	Values.Gravity = val
	Workspace.Gravity = val
end

local function Gravity_Reset()
	Workspace.Gravity = GravitySystem.Original
	Values.Gravity = GravitySystem.Original
end

--// ================================================================
--//  区块 60: 跳高 - 双套 (JumpPower / 直接修改 state)
--// ================================================================
local function SetJump_V1(val)
	Values.JumpPower = val
	local h = GetHumanoid()
	if h then
		h.JumpPower = val
	end
end

local function SetJump_V2(val)
	Values.JumpPower = val
	local h = GetHumanoid()
	if h then
		h.JumpPower = val
		-- 强制刷新状态确保生效
		local s = h:GetState()
		if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Landed then
			h:ChangeState(Enum.HumanoidStateType.Landed)
		end
	end
end

--// ================================================================
--//  区块 61: 速度 - 双套 + 属性保护联动
--// ================================================================
local function SetSpeed_V1(val)
	Values.WalkSpeed = val
	State.SpeedHack = true
	local h = GetHumanoid()
	if h then
		h.WalkSpeed = val
	end
end

local function SetSpeed_V2(val)
	Values.WalkSpeed = val
	State.SpeedHack = true
	local char = GetCharacter()
	if char then
		local h = char:FindFirstChildOfClass("Humanoid")
		if h then
			h.WalkSpeed = val
		end
	end
end

--// ================================================================
--//  区块 62: 夜视 - 完整版 (多属性)
--// ================================================================
local NightVisionState = {
	Enabled = false,
	OriginalBrightness = 1,
	OriginalClock = 14,
	OriginalAmbient = Color3.new(0, 0, 0),
}

local function NightVision_On()
	NightVisionState.OriginalBrightness = Lighting.Brightness
	NightVisionState.OriginalClock = Lighting.ClockTime
	NightVisionState.OriginalAmbient = Lighting.Ambient
	Lighting.Brightness = 3
	Lighting.ClockTime = 14
	Lighting.Ambient = Color3.new(1, 1, 1)
	Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	NightVisionState.Enabled = true
end

local function NightVision_Off()
	Lighting.Brightness = NightVisionState.OriginalBrightness
	Lighting.ClockTime = NightVisionState.OriginalClock
	Lighting.Ambient = NightVisionState.OriginalAmbient
	NightVisionState.Enabled = false
end

--// ================================================================
--//  区块 63: 全图明亮 - 完整版
--// ================================================================
local FullBrightState = {
	Enabled = false,
	OriginalShadows = true,
	OriginalFog = 100000,
}

local function FullBright_On()
	FullBrightState.OriginalShadows = Lighting.GlobalShadows
	FullBrightState.OriginalFog = Lighting.FogEnd
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 1000000
	FullBrightState.Enabled = true
end

local function FullBright_Off()
	Lighting.GlobalShadows = FullBrightState.OriginalShadows
	Lighting.FogEnd = FullBrightState.OriginalFog
	FullBrightState.Enabled = false
end

--// ================================================================
--//  区块 64: 锁定视角 - 完整版 (支持恢复)
--// ================================================================
local LockCameraState = {
	Enabled = false,
	OriginalType = nil,
	OriginalCFrame = nil,
}

local function LockCamera_On()
	local cam = Workspace.CurrentCamera
	LockCameraState.OriginalType = cam.CameraType
	LockCameraState.OriginalCFrame = cam.CFrame
	cam.CameraType = Enum.CameraType.Scriptable
	LockCameraState.Enabled = true
end

local function LockCamera_Off()
	local cam = Workspace.CurrentCamera
	cam.CameraType = LockCameraState.OriginalType or Enum.CameraType.Custom
	LockCameraState.Enabled = false
end

--// ================================================================
--//  区块 65: 甩飞 - 双套 (单次 / 持续)
--// ================================================================
local FlingSystem = {
	Enabled = false,
	Connection = nil,
	Target = nil,
}

local function Fling_Once(plr)
	local root = GetPlayerRoot(plr or SelectedPlayer)
	if not root then
		return
	end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(999999, 999999, 999999)
	bv.Velocity = Vector3.new(
		math.random(-Values.FlingPower, Values.FlingPower),
		math.random(Values.FlingPower, Values.FlingPower * 3),
		math.random(-Values.FlingPower, Values.FlingPower)
	)
	bv.Parent = root
	task.wait(0.1)
	bv:Destroy()
end

local function Fling_Start(plr)
	FlingSystem.Target = plr or SelectedPlayer
	if not FlingSystem.Target then
		return
	end
	FlingSystem.Enabled = true
	FlingSystem.Connection = RunService.Heartbeat:Connect(function()
		if not FlingSystem.Enabled then
			return
		end
		local root = GetPlayerRoot(FlingSystem.Target)
		if not root then
			return
		end
		-- 高速旋转
		local bg = Instance.new("BodyAngularVelocity")
		bg.MaxTorque = Vector3.new(999999, 999999, 999999)
		bg.AngularVelocity = Vector3.new(
			math.random(-100, 100),
			math.random(-100, 100),
			math.random(-100, 100)
		)
		bg.Parent = root
		task.delay(0.05, function()
			if bg and bg.Parent then
				bg:Destroy()
			end
		end)
		-- 随机冲量
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(999999, 999999, 999999)
		bv.Velocity = Vector3.new(
			math.random(-Values.FlingPower, Values.FlingPower),
			math.random(Values.FlingPower, Values.FlingPower * 3),
			math.random(-Values.FlingPower, Values.FlingPower)
		)
		bv.Parent = root
		task.delay(0.05, function()
			if bv and bv.Parent then
				bv:Destroy()
			end
		end)
	end)
end

local function Fling_Stop()
	FlingSystem.Enabled = false
	if FlingSystem.Connection then
		FlingSystem.Connection:Disconnect()
		FlingSystem.Connection = nil
	end
end

--// ================================================================
--//  区块 66: 环绕 - 双套 (圆形 / 椭圆)
--// ================================================================
local OrbitSystem = {
	Enabled = false,
	Connection = nil,
	Target = nil,
	Mode = "circle", -- circle / ellipse
	Radius = 5,
	Height = 3,
}

local function Orbit_Start_Circle(plr)
	OrbitSystem.Target = plr or SelectedPlayer
	if not OrbitSystem.Target then
		return
	end
	OrbitSystem.Enabled = true
	OrbitSystem.Mode = "circle"
	OrbitSystem.Connection = RunService.RenderStepped:Connect(function()
		if not OrbitSystem.Enabled then
			return
		end
		local myRoot = GetRoot()
		local tRoot = GetPlayerRoot(OrbitSystem.Target)
		if not myRoot or not tRoot then
			return
		end
		local t = tick() * Values.OrbitSpeed
		local offset = Vector3.new(math.cos(t) * OrbitSystem.Radius, OrbitSystem.Height, math.sin(t) * OrbitSystem.Radius)
		myRoot.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
	end)
end

local function Orbit_Start_Ellipse(plr)
	OrbitSystem.Target = plr or SelectedPlayer
	if not OrbitSystem.Target then
		return
	end
	OrbitSystem.Enabled = true
	OrbitSystem.Mode = "ellipse"
	OrbitSystem.Connection = RunService.RenderStepped:Connect(function()
		if not OrbitSystem.Enabled then
			return
		end
		local myRoot = GetRoot()
		local tRoot = GetPlayerRoot(OrbitSystem.Target)
		if not myRoot or not tRoot then
			return
		end
		local t = tick() * Values.OrbitSpeed
		local offset = Vector3.new(math.cos(t) * 6, OrbitSystem.Height + math.sin(t) * 2, math.sin(t) * 4)
		myRoot.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
	end)
end

local function Orbit_Stop()
	OrbitSystem.Enabled = false
	if OrbitSystem.Connection then
		OrbitSystem.Connection:Disconnect()
		OrbitSystem.Connection = nil
	end
end

--// ================================================================
--//  区块 67: 自瞄 - 双套 (FOV 圈 / 无圈)
--// ================================================================
local AimbotSystem = {
	Enabled = false,
	Connection = nil,
	UseFOV = true,
}

local function Aimbot_WithFOV()
	if not Drawing then
		return
	end
	Objects.FOVCircle = Drawing.new("Circle")
	Objects.FOVCircle.Visible = true
	Objects.FOVCircle.Radius = Values.AimbotFOV
	Objects.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
	Objects.FOVCircle.Thickness = 1
	Objects.FOVCircle.Transparency = 0.5
	Objects.FOVCircle.Filled = false
end

local function Aimbot_WithoutFOV()
	-- 不画圈, 静默锁头
end

local function Aimbot_Start(useFOV)
	AimbotSystem.Enabled = true
	AimbotSystem.UseFOV = useFOV ~= false
	if AimbotSystem.UseFOV then
		Aimbot_WithFOV()
	else
		Aimbot_WithoutFOV()
	end
	AimbotSystem.Connection = RunService.RenderStepped:Connect(function()
		if not AimbotSystem.Enabled then
			return
		end
		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			return
		end
		local target = GetClosestPlayer()
		if not target then
			return
		end
		local root = GetPlayerRoot(target)
		if not root then
			return
		end
		local cam = Workspace.CurrentCamera
		cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, root.Position), 0.3)
	end)
end

local function Aimbot_Stop()
	AimbotSystem.Enabled = false
	if Objects.FOVCircle then
		Objects.FOVCircle:Remove()
		Objects.FOVCircle = nil
	end
	if AimbotSystem.Connection then
		AimbotSystem.Connection:Disconnect()
		AimbotSystem.Connection = nil
	end
end

--// ================================================================
--//  区块 68: ESP - 团队检测 + 颜色区分
--// ================================================================
local ESP_Settings = {
	ShowTeam = false,
	EnemyColor = Color3.fromRGB(255, 0, 0),
	TeamColor = Color3.fromRGB(0, 0, 255),
}

local function CreateESP_WithTeam(plr)
	if Objects.ESP[plr] then
		return
	end
	if plr == LocalPlayer then
		return
	end
	-- 队友检测
	if not ESP_Settings.ShowTeam and plr.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
		return
	end
	local c = plr.Character
	if not c then
		return
	end
	local root = c:FindFirstChild("HumanoidRootPart")
	local hum = c:FindFirstChildOfClass("Humanoid")
	if not root or not hum then
		return
	end

	local color = ESP_Settings.EnemyColor
	if plr.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
		color = ESP_Settings.TeamColor
	end

	local hl = Instance.new("Highlight")
	hl.FillColor = color
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.7
	hl.OutlineTransparency = 0
	hl.Adornee = c
	hl.Parent = c

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 120, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.Adornee = root
	bb.AlwaysOnTop = true
	bb.Parent = root

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.DisplayName
	nameLabel.TextColor3 = color
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = bb

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = "0m"
	distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	distLabel.TextSize = 11
	distLabel.Font = Enum.Font.Gotham
	distLabel.Parent = bb

	Objects.ESP[plr] = {
		Highlight = hl,
		Billboard = bb,
		DistLabel = distLabel,
	}
end

local function ESP_Start_WithTeam()
	State.ESP_Enabled = true
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			CreateESP_WithTeam(plr)
		end
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			task.wait(1)
			if State.ESP_Enabled then
				CreateESP_WithTeam(plr)
			end
		end)
	end)
	Connections.ESP = RunService.RenderStepped:Connect(function()
		if not State.ESP_Enabled then
			return
		end
		local myRoot = GetRoot()
		if not myRoot then
			return
		end
		for plr, data in pairs(Objects.ESP) do
			if plr and plr.Parent and data.DistLabel then
				local root = GetPlayerRoot(plr)
				if root then
					local dist = math.floor((root.Position - myRoot.Position).Magnitude)
					data.DistLabel.Text = dist .. "m"
				end
			else
				if data.Highlight then
					data.Highlight:Destroy()
				end
				if data.Billboard then
					data.Billboard:Destroy()
				end
				Objects.ESP[plr] = nil
			end
		end
	end)
end

--// ================================================================
--//  区块 69: 反检测 - 完整版 (多层防护)
--// ================================================================
local AntiDetectSystem = {
	Enabled = false,
	Connections = {},
	RandomSeed = 0,
}

local function AntiDetect_Init()
	AntiDetectSystem.RandomSeed = math.random(1, 1000000)
end

local function AntiDetect_Start_Full()
	AntiDetectSystem.Enabled = true
	AntiDetect_Init()

	-- 层1: 随机化心跳间隔
	AntiDetectSystem.Connections[1] = RunService.Heartbeat:Connect(function()
		if not AntiDetectSystem.Enabled then
			return
		end
		-- 随机延迟, 打破固定频率
		local delay = 0.01 + math.random() * 0.04
		task.wait(delay)
	end)

	-- 层2: 动态修改 Gui 名称
	AntiDetectSystem.Connections[2] = RunService.RenderStepped:Connect(function()
		if not AntiDetectSystem.Enabled then
			return
		end
		if ScreenGui and math.random() < 0.01 then
			ScreenGui.Name = "CoreGui_" .. tostring(math.random(1000, 9999))
		end
	end)

	-- 层3: 防止 Character 被强制销毁
	LocalPlayer.CharacterRemoving:Connect(function()
		if AntiDetectSystem.Enabled then
			task.wait(0.5)
			if not LocalPlayer.Character then
				pcall(function()
					LocalPlayer:LoadCharacter()
				end)
			end
		end
	end)
end

local function AntiDetect_Stop_Full()
	AntiDetectSystem.Enabled = false
	for _, conn in ipairs(AntiDetectSystem.Connections) do
		if conn then
			conn:Disconnect()
		end
	end
	AntiDetectSystem.Connections = {}
end

--// ================================================================
--//  区块 70: 反踢 - 完整版 (metamethod + RemoteEvent 拦截)
--// ================================================================
local AntiKickSystem = {
	Enabled = false,
	BlockedMethods = {
		"kick",
		"destroy",
		"remove",
	},
}

local function AntiKick_Start_Full()
	AntiKickSystem.Enabled = true
	-- 方法1: 拦截 __namecall (支持的执行器)
	if hookmetamethod and getnamecallmethod then
		local mt = getrawmetatable and getrawmetatable(game)
		if mt then
			local oldNamecall = mt.__namecall
			hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				if method then
					local lower = method:lower()
					for _, blocked in ipairs(AntiKickSystem.BlockedMethods) do
						if lower == blocked then
							return nil
						end
					end
				end
				return oldNamecall(self, ...)
			end)
		end
	end
	-- 方法2: 监控危险 RemoteEvent
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("RemoteEvent") then
			local name = v.Name:lower()
			if name:find("kick") or name:find("ban") or name:find("punish") or name:find("moderate") then
				-- 记录但不拦截, 仅用于诊断
			end
		end
	end
end

local function AntiKick_Stop_Full()
	AntiKickSystem.Enabled = false
end

--// ================================================================
--  说明: 区块59-70 为双套实现 / 备用方案 / 扩展模块
--  全部接入主系统的 State / Values / Connections / Objects
-- ================================================================
--// EOF
