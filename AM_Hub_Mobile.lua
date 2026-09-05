--// AM Hub Mobile 3.0 - Fixed 悬浮球
--// Luau / Delta

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
if not PlayerGui then
	warn("[AM Hub] PlayerGui not found!")
	return
end

print("[AM Hub] PlayerGui found, loading...")

-- CONFIG
local MENU_WIDTH = 300
local MENU_HEIGHT = 440
local FLOAT_SIZE = 58
local QQ_GROUP = "179051448"

-- 状态
local Flying = false
local InfiniteJump = false
local Noclip = false
local SpeedHack = false
local JumpHack = false
local ESP_Enabled = false
local Aimbot_Enabled = false
local ClickTP = false
local NightVision = false
local LockCamera = false
local FlingEnabled = false
local OrbitEnabled = false
local AntiKick = false
local AntiDetect = false
local GodMode = false

local FlightSpeed = 50
local WalkSpeedVal = 16
local JumpPowerVal = 50
local GravityVal = 196
local AimbotFOV = 90
local OrbitSpeed = 10
local SpinSpeed = 30

local SelectedPlayer = nil

local FlightConnection = nil
local InfiniteJumpConnection = nil
local NoclipConnection = nil
local ESP_Connection = nil
local AimbotConnection = nil
local FlingConnection = nil
local OrbitConnection = nil
local AntiKickConnection = nil
local AntiDetectConnection = nil
local SpinConnection = nil

local ESP_Objects = {}
local FlightBV = nil
local FlightBG = nil
local OriginalCameraType = nil

-- 彩虹
local Rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120)),
})

-- 工具
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

local function GetPlayerRoot(player)
	if not player then return nil end
	local c = player.Character
	if not c then return nil end
	return c:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(player)
	local h = nil
	if player == LocalPlayer then
		h = GetHumanoid()
	else
		local c = player.Character
		if c then h = c:FindFirstChildOfClass("Humanoid") end
	end
	return h and h.Health > 0
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

print("[AM Hub] ScreenGui created")

-- 悬浮球
local AMButton = Instance.new("TextButton")
AMButton.Name = "AMButton"
AMButton.Size = UDim2.fromOffset(FLOAT_SIZE, FLOAT_SIZE)
AMButton.Position = UDim2.new(0, 18, 0.5, -FLOAT_SIZE/2)
AMButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AMButton.BorderSizePixel = 0
AMButton.Text = "AM"
AMButton.TextColor3 = Color3.fromRGB(20, 20, 20)
AMButton.TextSize = 19
AMButton.Font = Enum.Font.GothamBold
AMButton.AutoButtonColor = false
AMButton.Active = true
AMButton.ZIndex = 9999
AMButton.Parent = ScreenGui
Corner(AMButton, 100)

local AMStroke = Instance.new("UIStroke")
AMStroke.Thickness = 3
AMStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
AMStroke.Parent = AMButton

local AMGradient = Instance.new("UIGradient")
AMGradient.Color = Rainbow
AMGradient.Parent = AMStroke

print("[AM Hub] Float button created")

-- 主菜单
local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT)
Menu.Position = UDim2.new(0, 88, 0.5, -MENU_HEIGHT/2)
Menu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Active = true
Menu.ZIndex = 100
Menu.Parent = ScreenGui
Corner(Menu, 16)

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Thickness = 3
MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuStroke.Parent = Menu

local MenuGradient = Instance.new("UIGradient")
MenuGradient.Color = Rainbow
MenuGradient.Parent = MenuStroke

-- 标题栏
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 120
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
Title.ZIndex = 121
Title.Parent = Header

local QQLabel = Instance.new("TextLabel")
QQLabel.Size = UDim2.new(0, 120, 0, 20)
QQLabel.Position = UDim2.new(1, -130, 0, 14)
QQLabel.BackgroundTransparency = 1
QQLabel.Text = "群:" .. QQ_GROUP
QQLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
QQLabel.TextSize = 11
QQLabel.Font = Enum.Font.Gotham
QQLabel.TextXAlignment = Enum.TextXAlignment.Right
QQLabel.ZIndex = 121
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
CloseButton.ZIndex = 130
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

-- 左侧分类栏（ScrollingFrame 可滑动）
local CategoryBar = Instance.new("ScrollingFrame")
CategoryBar.Size = UDim2.new(0, 82, 1, -58)
CategoryBar.Position = UDim2.fromOffset(6, 52)
CategoryBar.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
CategoryBar.BorderSizePixel = 0
CategoryBar.ZIndex = 110
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

-- 右侧内容区
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -97, 1, -58)
Content.Position = UDim2.fromOffset(91, 52)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
Content.ZIndex = 110
Content.Parent = Menu

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 7)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Content.CanvasSize = UDim2.fromOffset(0, ContentLayout.AbsoluteContentSize.Y + 15)
end)

-- UI工厂
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
	label.ZIndex = 120
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
	button.ZIndex = 120
	button.Parent = Content
	Corner(button, 9)
	Stroke(button, Color3.fromRGB(220, 220, 220), 1)
	if callback then button.MouseButton1Click:Connect(callback) end
	return button
end

local function Toggle(text, default, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 42)
	button.BorderSizePixel = 0
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.ZIndex = 120
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
		if callback then callback(state) end
	end)
	return button
end

local function Slider(text, minimum, maximum, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, 60)
	holder.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	holder.BorderSizePixel = 0
	holder.ZIndex = 120
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
	label.ZIndex = 121
	label.Parent = holder

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 7)
	bar.Position = UDim2.fromOffset(10, 38)
	bar.BackgroundColor3 = Color3.fromRGB(215, 215, 215)
	bar.BorderSizePixel = 0
	bar.ZIndex = 121
	bar.Parent = holder
	Corner(bar, 10)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	fill.BorderSizePixel = 0
	fill.ZIndex = 122
	fill.Parent = bar
	Corner(fill, 10)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(15, 15)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	knob.BorderSizePixel = 0
	knob.ZIndex = 123
	knob.Parent = bar
	Corner(knob, 20)

	local dragging = false
	local function SetValue(value)
		value = math.clamp(value, minimum, maximum)
		local percent = (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, 0, 0.5, 0)
		label.Text = text .. " : " .. math.floor(value)
		if callback then callback(value) end
	end

	local function Update(input)
		local x = input.Position.X - bar.AbsolutePosition.X
		local percent = math.clamp(x / bar.AbsoluteSize.X, 0, 1)
		SetValue(minimum + (maximum - minimum) * percent)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			Update(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
			Update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	SetValue(default)
	return holder
end

-- 飞行
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
	if FlightBV then FlightBV:Destroy() FlightBV = nil end
	if FlightBG then FlightBG:Destroy() FlightBG = nil end
end

local function StartFlight()
	if Flying then return end
	local humanoid = GetHumanoid()
	local root = GetRoot()
	if not humanoid or not root then return end

	Flying = true
	humanoid.PlatformStand = true

	FlightBV = Instance.new("BodyVelocity")
	FlightBV.MaxForce = Vector3.new(999999, 999999, 999999)
	FlightBV.Velocity = Vector3.zero
	FlightBV.Parent = root

	FlightBG = Instance.new("BodyGyro")
	FlightBG.MaxTorque = Vector3.new(999999, 999999, 999999)
	FlightBG.P = 9000
	FlightBG.D = 100
	FlightBG.CFrame = Workspace.CurrentCamera.CFrame
	FlightBG.Parent = root

	FlightConnection = RunService.RenderStepped:Connect(function()
		if not Flying then return end
		local curHum = GetHumanoid()
		local curRoot = GetRoot()
		if not curHum or not curRoot then StopFlight() return end

		local cam = Workspace.CurrentCamera
		if not cam then return end

		local move = curHum.MoveDirection
		local vel = Vector3.zero

		if move.Magnitude > 0 then
			local camFwd = cam.CFrame.LookVector
			local camRight = cam.CFrame.RightVector
			camFwd = Vector3.new(camFwd.X, 0, camFwd.Z).Unit
			vel = (camFwd * move.Z + camRight * move.X).Unit * FlightSpeed
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vel = vel + Vector3.new(0, FlightSpeed, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				vel = vel - Vector3.new(0, FlightSpeed, 0)
			end
		end

		if FlightBV then FlightBV.Velocity = vel end
		if FlightBG then FlightBG.CFrame = cam.CFrame end
	end)
end

-- 穿墙
local function StopNoclip()
	Noclip = false
	if NoclipConnection then
		NoclipConnection:Disconnect()
		NoclipConnection = nil
	end
end

local function StartNoclip()
	if Noclip then return end
	Noclip = true
	NoclipConnection = RunService.Stepped:Connect(function()
		if not Noclip then return end
		local c = GetCharacter()
		if not c then return end
		for _, part in ipairs(c:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)
end

-- 无限跳
InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
	if not InfiniteJump then return end
	local humanoid = GetHumanoid()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- 属性
local function ApplySpeed(val)
	WalkSpeedVal = val
	local h = GetHumanoid()
	if h then h.WalkSpeed = val end
end

local function ApplyJump(val)
	JumpPowerVal = val
	local h = GetHumanoid()
	if h then
		h.JumpPower = val
		if h:GetState() == Enum.HumanoidStateType.Freefall then
			h:ChangeState(Enum.HumanoidStateType.Landed)
		end
	end
end

local function ApplyGravity(val)
	GravityVal = val
	Workspace.Gravity = val
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local h = char:FindFirstChildOfClass("Humanoid")
	if h then
		if SpeedHack then h.WalkSpeed = WalkSpeedVal end
		if JumpHack then h.JumpPower = JumpPowerVal end
	end
	if Flying then StopFlight() end
	if Noclip then StopNoclip() end
end)

-- ESP
local function ClearESP()
	for plr, data in pairs(ESP_Objects) do
		if data.Highlight then data.Highlight:Destroy() end
		if data.Billboard then data.Billboard:Destroy() end
	end
	ESP_Objects = {}
end

local function CreateESPForPlayer(plr)
	if ESP_Objects[plr] then return end
	if plr == LocalPlayer then return end
	local c = plr.Character
	if not c then return end
	local root = c:FindFirstChild("HumanoidRootPart")
	local hum = c:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

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

	ESP_Objects[plr] = {Highlight = hl, Billboard = bb, DistLabel = distLabel}
end

local function StartESP()
	ESP_Enabled = true
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			CreateESPForPlayer(plr)
		end
	end

	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			task.wait(1)
			if ESP_Enabled then CreateESPForPlayer(plr) end
		end)
	end)

	ESP_Connection = RunService.RenderStepped:Connect(function()
		if not ESP_Enabled then return end
		local myRoot = GetRoot()
		if not myRoot then return end
		for plr, data in pairs(ESP_Objects) do
			if plr and plr.Parent and data.DistLabel then
				local root = GetPlayerRoot(plr)
				if root then
					local dist = math.floor((root.Position - myRoot.Position).Magnitude)
					data.DistLabel.Text = dist .. "m"
				end
			else
				if data.Highlight then data.Highlight:Destroy() end
				if data.Billboard then data.Billboard:Destroy() end
				ESP_Objects[plr] = nil
			end
		end
	end)
end

local function StopESP()
	ESP_Enabled = false
	ClearESP()
	if ESP_Connection then ESP_Connection:Disconnect() ESP_Connection = nil end
end

-- 自瞄
local function GetClosestPlayer()
	local closest = nil
	local shortest = AimbotFOV
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

local function StartAimbot()
	Aimbot_Enabled = true
	AimbotConnection = RunService.RenderStepped:Connect(function()
		if not Aimbot_Enabled then return end
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
	Aimbot_Enabled = false
	if AimbotConnection then AimbotConnection:Disconnect() AimbotConnection = nil end
end

-- 点击传送
local function StartClickTP()
	ClickTP = true
	ClickTP_Connection = UserInputService.InputBegan:Connect(function(input)
		if not ClickTP then return end
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
	ClickTP = false
	if ClickTP_Connection then ClickTP_Connection:Disconnect() ClickTP_Connection = nil end
end

-- 甩飞
local function DoFling()
	if not SelectedPlayer then return end
	local tRoot = GetPlayerRoot(SelectedPlayer)
	if not tRoot then return end
	for i = 1, 5 do
		task.spawn(function()
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(999999, 999999, 999999)
			bv.Velocity = Vector3.new(math.random(-300,300), math.random(300,600), math.random(-300,300))
			bv.Parent = tRoot
			task.wait(0.1)
			bv:Destroy()
		end)
	end
end

local function DoTeleport()
	if not SelectedPlayer then return end
	local myRoot = GetRoot()
	local tRoot = GetPlayerRoot(SelectedPlayer)
	if myRoot and tRoot then
		myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
	end
end

local function StartOrbit()
	if not SelectedPlayer then return end
	OrbitEnabled = true
	OrbitConnection = RunService.RenderStepped:Connect(function()
		if not OrbitEnabled then return end
		local myRoot = GetRoot()
		local tRoot = GetPlayerRoot(SelectedPlayer)
		if not myRoot or not tRoot then return end
		local t = tick() * OrbitSpeed
		local offset = Vector3.new(math.cos(t)*5, 3, math.sin(t)*5)
		myRoot.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
	end)
end

local function StopOrbit()
	OrbitEnabled = false
	if OrbitConnection then OrbitConnection:Disconnect() OrbitConnection = nil end
end

-- 夜视
local function SetNightVision(on)
	NightVision = on
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

-- 锁定视角
local function SetLockCamera(on)
	LockCamera = on
	local cam = Workspace.CurrentCamera
	if on then
		OriginalCameraType = cam.CameraType
		cam.CameraType = Enum.CameraType.Scriptable
	else
		cam.CameraType = OriginalCameraType or Enum.CameraType.Custom
	end
end

-- 反踢
local function StartAntiKick()
	AntiKick = true
	local mt = getrawmetatable and getrawmetatable(game) or nil
	if mt then
		local old = mt.__namecall
		if hookmetamethod then
			hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod and getnamecallmethod() or ""
				if method:lower() == "kick" or method:lower() == "destroy" then
					return nil
				end
				return old(self, ...)
			end)
		end
	end
	AntiKickConnection = RunService.Heartbeat:Connect(function()
		if not AntiKick then return end
		for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
			if v:IsA("RemoteEvent") and (v.Name:lower():find("kick") or v.Name:lower():find("ban")) then
				-- 监控
			end
		end
	end)
end

local function StopAntiKick()
	AntiKick = false
	if AntiKickConnection then AntiKickConnection:Disconnect() AntiKickConnection = nil end
end

-- 反检测
local function StartAntiDetect()
	AntiDetect = true
	local last = tick()
	AntiDetectConnection = RunService.Heartbeat:Connect(function()
		if not AntiDetect then return end
		local now = tick()
		if now - last < math.random(0.01, 0.05) then
			return
		end
		last = now
		if ScreenGui then
			ScreenGui.Name = "CoreGui_" .. tostring(math.random(1000,9999))
		end
	end)

	LocalPlayer.CharacterRemoving:Connect(function()
		if AntiDetect then
			task.wait(0.5)
			if not LocalPlayer.Character then
				LocalPlayer:LoadCharacter()
			end
		end
	end)
end

local function StopAntiDetect()
	AntiDetect = false
	if AntiDetectConnection then AntiDetectConnection:Disconnect() AntiDetectConnection = nil end
end

-- 玩家选择器
local PlayerSelector = Instance.new("Frame")
PlayerSelector.Name = "PlayerSelector"
PlayerSelector.Size = UDim2.fromOffset(250, 300)
PlayerSelector.Position = UDim2.new(0.5, -125, 0.5, -150)
PlayerSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PlayerSelector.BorderSizePixel = 0
PlayerSelector.Visible = false
PlayerSelector.Active = true
PlayerSelector.ZIndex = 500
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
PSTitle.ZIndex = 510
PSTitle.Parent = PlayerSelector

local PSClose = Instance.new("TextButton")
PSClose.Size = UDim2.fromOffset(35, 35)
PSClose.Position = UDim2.new(1, -40, 0, 6)
PSClose.BackgroundTransparency = 1
PSClose.Text = "×"
PSClose.TextColor3 = Color3.fromRGB(30, 30, 30)
PSClose.TextSize = 25
PSClose.Font = Enum.Font.GothamBold
PSClose.ZIndex = 520
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
PlayerList.ZIndex = 510
PlayerList.Parent = PlayerSelector

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Padding = UDim.new(0, 6)
PlayerLayout.Parent = PlayerList

PlayerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PlayerList.CanvasSize = UDim2.fromOffset(0, PlayerLayout.AbsoluteContentSize.Y + 10)
end)

local function RefreshPlayerList()
	for _, obj in ipairs(PlayerList:GetChildren()) do
		if not obj:IsA("UIListLayout") then obj:Destroy() end
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
			btn.ZIndex = 520
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
	if SelectedPlayer == leaving then SelectedPlayer = nil end
end)

-- 页面
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
	Button("QQ群：" .. QQ_GROUP)
end

local function ShowGeneral()
	ClearContent()
	Section("移动")
	Toggle("飞行", Flying, function(v)
		if v then StartFlight() else StopFlight() end
	end)
	Slider("飞行速度", 10, 200, FlightSpeed, function(v) FlightSpeed = v end)
	Toggle("无限跳跃", InfiniteJump, function(v) InfiniteJump = v end)
	Slider("移速", 16, 300, WalkSpeedVal, function(v)
		SpeedHack = true
		ApplySpeed(v)
	end)
	Slider("跳高", 50, 300, JumpPowerVal, function(v)
		JumpHack = true
		ApplyJump(v)
	end)
	Slider("重力", 0, 300, GravityVal, function(v) ApplyGravity(v) end)
	Toggle("穿墙", Noclip, function(v)
		if v then StartNoclip() else StopNoclip() end
	end)
	Section("视角")
	Toggle("夜视", false, function(v) SetNightVision(v) end)
	Toggle("锁定视角", false, function(v) SetLockCamera(v) end)
	Toggle("点击传送", false, function(v)
		if v then StartClickTP() else StopClickTP() end
	end)
end

local function ShowCombat()
	ClearContent()
	Section("战斗")
	Toggle("ESP", ESP_Enabled, function(v)
		if v then StartESP() else StopESP() end
	end)
	Slider("自瞄 FOV", 30, 300, AimbotFOV, function(v) AimbotFOV = v end)
	Toggle("自瞄", Aimbot_Enabled, function(v)
		if v then StartAimbot() else StopAimbot() end
	end)
	Button("敌对颜色：红色")
	Button("我方颜色：蓝色")
end

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
	Toggle("环绕", OrbitEnabled, function(v)
		if v then StartOrbit() else StopOrbit() end
	end)
	Slider("环绕速度", 1, 30, OrbitSpeed, function(v) OrbitSpeed = v end)
end

local function ShowEntertainment()
	ClearContent()
	Section("娱乐")
	Button("FPS：60")
	Toggle("全图明亮", false, function(v)
		if v then
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 100000
		else
			Lighting.GlobalShadows = true
		end
	end)
	Button("重置所有", function()
		StopFlight()
		StopESP()
		StopAimbot()
		StopNoclip()
		StopOrbit()
		ApplySpeed(16)
		ApplyJump(50)
		ApplyGravity(196)
		SetNightVision(false)
		SetLockCamera(false)
	end)
end

local function ShowAdvanced()
	ClearContent()
	Section("高级 / 反检测")
	Toggle("反踢 (AntiKick)", AntiKick, function(v)
		if v then StartAntiKick() else StopAntiKick() end
	end)
	Toggle("反检测 (AntiDetect)", AntiDetect, function(v)
		if v then StartAntiDetect() else StopAntiDetect() end
	end)
	Button("手动重生角色", function()
		LocalPlayer:LoadCharacter()
	end)
	Button("刷新玩家列表", RefreshPlayerList)
end

local function ShowSettings()
	ClearContent()
	Section("设置")
	Button("关闭菜单", function() Menu.Visible = false end)
	Button("退出 AM（完全卸载）", function()
		StopFlight()
		StopESP()
		StopAimbot()
		StopNoclip()
		StopOrbit()
		StopAntiKick()
		StopAntiDetect()
		StopClickTP()
		SetLockCamera(false)
		SetNightVision(false)
		ScreenGui:Destroy()
	end)
end

-- 分类
local Categories = {"信息", "通用", "战斗", "甩飞", "娱乐", "高级", "设置"}
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
	if Pages[name] then Pages[name]() end
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
	btn.ZIndex = 120
	btn.Parent = CategoryBar
	Corner(btn, 8)
	CategoryButtons[name] = btn
	btn.MouseButton1Click:Connect(function() SelectCategory(name) end)
end

-- 拖动
local MenuDragging = false
local MenuDragStart, MenuStartPos
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = true
		MenuDragStart = input.Position
		MenuStartPos = Menu.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not MenuDragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - MenuDragStart
		Menu.Position = UDim2.new(MenuStartPos.X.Scale, MenuStartPos.X.Offset + delta.X, MenuStartPos.Y.Scale, MenuStartPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = false
	end
end)

local BtnDrag = false
local BtnDragStart, BtnStartPos, BtnMoved
AMButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		BtnDrag = true
		BtnMoved = false
		BtnDragStart = input.Position
		BtnStartPos = AMButton.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not BtnDrag then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - BtnDragStart
		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then BtnMoved = true end
		AMButton.Position = UDim2.new(BtnStartPos.X.Scale, BtnStartPos.X.Offset + delta.X, BtnStartPos.Y.Scale, BtnStartPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if BtnDrag and not BtnMoved then
			Menu.Visible = not Menu.Visible
		end
		BtnDrag = false
	end
end)

local SelDrag = false
local SelDragStart, SelStartPos
PSTitle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelDrag = true
		SelDragStart = input.Position
		SelStartPos = PlayerSelector.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not SelDrag then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - SelDragStart
		PlayerSelector.Position = UDim2.new(SelStartPos.X.Scale, SelStartPos.X.Offset + delta.X, SelStartPos.Y.Scale, SelStartPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelDrag = false
	end
end)

-- 流光
local Rotation = 0
RunService.RenderStepped:Connect(function(dt)
	Rotation = (Rotation + dt * 100) % 360
	AMGradient.Rotation = Rotation
	MenuGradient.Rotation = Rotation
	PSGrad.Rotation = Rotation
end)

-- 启动
SelectCategory("信息")

print("[AM Hub] Loaded successfully!")
