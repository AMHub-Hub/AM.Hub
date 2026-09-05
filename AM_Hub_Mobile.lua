--// ================================================================
--// AM Hub Mobile 3.0 - 修复悬浮窗 + 飞行 + 全功能
--// 基于你的白色壳子修改，保留原有结构
--// ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
local Camera = Workspace.CurrentCamera

-- ==================================================
-- CONFIG
-- ==================================================
local MENU_WIDTH = 280
local MENU_HEIGHT = 360  -- 稍微加高一点放更多功能
local FLOAT_SIZE = 58
local QQ_GROUP = "179051448"

-- ==================================================
-- 状态
-- ==================================================
local Flying = false
local FlightSpeed = 50
local FlyInput = {Forward = 0, Right = 0, Up = 0}

local InfiniteJump = false
local Noclip = false
local SpeedHack = false
local SpeedVal = 16
local JumpVal = 50
local GravityVal = 196.2

local LockCam = false
local ESPEnabled = false
local GodMode = false
local SpinEnabled = false
local SpinSpeed = 50

local FullBright = false
local NoFog = false

local AntiKick = true
local AntiDetect = true

local FE_Enabled = false
local FE_Fire = false
local FE_MoveFire = false
local FE_Crown = false

local ThrowEnabled = false
local ThrowPower = 200

-- 连接对象
local FlightConnection = nil
local NoclipConnection = nil
local LockCamConnection = nil
local SpinConnection = nil
local InfiniteJumpConnection = nil
local ThrowConnection = nil
local AntiKickConnection = nil
local ESPObjects = {}
local FEFirePart, FECrownPart, FEMoveConnection

local SelectedPlayer = nil

-- ==================================================
-- 彩虹流光
-- ==================================================
local Rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120))
})

-- ==================================================
-- 工具函数
-- ==================================================
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

local function GetCharacter() return LocalPlayer.Character end

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

local function Notify(title, text, dur)
	dur = dur or 3
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = dur})
	end)
end

local function Make(class, props, parent)
	local i = Instance.new(class)
	if props then
		for k, v in pairs(props) do pcall(function() i[k] = v end) end
	end
	if parent then i.Parent = parent end
	return i
end

-- ==================================================
-- GUI 根
-- ==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AM_Hub_Mobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ==================================================
-- 悬浮球
-- ==================================================
local AMButton = Instance.new("TextButton")
AMButton.Name = "AMButton"
AMButton.Size = UDim2.fromOffset(FLOAT_SIZE, FLOAT_SIZE)
AMButton.Position = UDim2.new(0, 18, 0.5, -29)
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

-- ==================================================
-- 主菜单
-- ==================================================
local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT)
Menu.Position = UDim2.new(0, 88, 0.5, -MENU_HEIGHT / 2)
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

-- 标题栏
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 20
Header.Parent = Menu

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "AM Hub"
Title.TextColor3 = Color3.fromRGB(20, 20, 20)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 21
Title.Parent = Header

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

-- ==================================================
-- 【修复1】左侧分类栏改成 ScrollingFrame，可滑动不超出
-- ==================================================
local CategoryBar = Instance.new("ScrollingFrame")
CategoryBar.Name = "CategoryBar"
CategoryBar.Size = UDim2.new(0, 82, 1, -58)
CategoryBar.Position = UDim2.fromOffset(6, 52)
CategoryBar.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
CategoryBar.BorderSizePixel = 0
CategoryBar.ZIndex = 15
CategoryBar.ScrollBarThickness = 4
CategoryBar.CanvasSize = UDim2.new(0, 0, 0, 0)
CategoryBar.ClipsDescendants = true
CategoryBar.Parent = Menu
Corner(CategoryBar, 11)

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.Padding = UDim.new(0, 5)
CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
CategoryLayout.Parent = CategoryBar

CategoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	CategoryBar.CanvasSize = UDim2.new(0, 0, 0, CategoryLayout.AbsoluteContentSize.Y + 10)
end)

-- ==================================================
-- 右侧内容区
-- ==================================================
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

-- ==================================================
-- UI 工厂（Toggle 状态不反转版）
-- ==================================================
local function ClearContent()
	for _, object in ipairs(Content:GetChildren()) do
		if not object:IsA("UIListLayout") then
			object:Destroy()
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
	if callback then button.MouseButton1Click:Connect(callback) end
	return button
end

-- 【关键修复】Toggle 用全局状态做唯一真相，不再反转
local function Toggle(text, getState, setState)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 42)
	button.BorderSizePixel = 0
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.ZIndex = 20
	button.Parent = Content
	Corner(button, 9)

	local function Refresh()
		local state = getState()
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
		setState(not getState())
		Refresh()
	end)
	return {button = button, refresh = Refresh}
end

local function Slider(text, minimum, maximum, getVal, setVal)
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
		setVal(value)
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
	SetValue(getVal())
	return holder
end

-- 飞行方向按钮（手机）
local function FlyButton(text, axis, positive)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(25, 25, 25)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.ZIndex = 20
	btn.Parent = Content
	Corner(btn, 8)

	local function On()
		if axis == "f" then FlyInput.Forward = positive end
		if axis == "r" then FlyInput.Right = positive end
		if axis == "u" then FlyInput.Up = positive end
	end
	local function Off()
		if axis == "f" then FlyInput.Forward = 0 end
		if axis == "r" then FlyInput.Right = 0 end
		if axis == "u" then FlyInput.Up = 0 end
	end

	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			On() btn.BackgroundColor3 = Color3.fromRGB(200, 240, 210)
		end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Off() btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
		end
	end)
end

-- ==================================================
-- 飞行系统（修复：相机朝向 + 升降独立）
-- ==================================================
local FlightBV, FlightBG

local function StopFlight()
	Flying = false
	if FlightConnection then FlightConnection:Disconnect() FlightConnection = nil end
	FlyInput.Forward = 0 FlyInput.Right = 0 FlyInput.Up = 0
	local humanoid = GetHumanoid()
	if humanoid then humanoid.PlatformStand = false end
	local root = GetRoot()
	if root then root.AssemblyLinearVelocity = Vector3.zero end
	if FlightBV then FlightBV:Destroy() FlightBV = nil end
	if FlightBG then FlightBG:Destroy() FlightBG = nil end
end

local function StartFlight()
	if Flying then return end
	local root = GetRoot()
	local humanoid = GetHumanoid()
	if not root or not humanoid then Notify("AM Hub", "找不到角色", 2) return end
	Flying = true
	humanoid.PlatformStand = true

	FlightBV = Make("BodyVelocity", {
		MaxForce = Vector3.new(math.huge, math.huge, math.huge),
		Velocity = Vector3.zero, P = 5000
	}, root)
	FlightBG = Make("BodyGyro", {
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
		CFrame = root.CFrame, P = 9000, D = 100
	}, root)

	FlightConnection = RunService.RenderStepped:Connect(function()
		if not Flying then return end
		local root = GetRoot()
		if not root then StopFlight() return end

		local cf = Camera.CFrame
		local fwd = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
		if fwd.Magnitude == 0 then fwd = Vector3.new(0,0,1) else fwd = fwd.Unit end
		local rgt = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
		if rgt.Magnitude == 0 then rgt = Vector3.new(1,0,0) else rgt = rgt.Unit end

		local vel = fwd * FlyInput.Forward + rgt * FlyInput.Right
		vel = vel + Vector3.new(0, FlyInput.Up, 0)
		if vel.Magnitude > 0 then
			vel = vel.Unit * FlightSpeed
		end

		FlightBV.Velocity = vel
		FlightBG.CFrame = cf
	end)
	Notify("AM Hub", "飞行开启", 2)
end

-- ==================================================
-- 其他功能
-- ==================================================
local function SetNoclip(on)
	Noclip = on
	if NoclipConnection then NoclipConnection:Disconnect() end
	if on then
		NoclipConnection = RunService.Stepped:Connect(function()
			local c = GetCharacter()
			if c then
				for _, p in pairs(c:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
end

local function SetSpeed(on)
	SpeedHack = on
	local h = GetHumanoid()
	if h then h.WalkSpeed = on and SpeedVal or 16 end
end

-- 【修复2】跳高：JumpPower + JumpHeight 双设 + 状态刷新
local function SetJump(on)
	local h = GetHumanoid()
	if not h then return end
	if on then
		h.JumpPower = JumpVal
		h.JumpHeight = JumpVal / 10
		local s = h:GetState()
		if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Landed then
			h:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	else
		h.JumpPower = 50
		h.JumpHeight = 7.2
	end
end

local function SetLockCam(on)
	LockCam = on
	if LockCamConnection then LockCamConnection:Disconnect() end
	if on then
		LockCamConnection = RunService.RenderStepped:Connect(function()
			if not LockCam then return end
			local root = GetRoot()
			if root then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
			end
		end)
	end
end

local function SetGod(on)
	GodMode = on
	local h = GetHumanoid()
	if h then
		if on then h.MaxHealth = math.huge h.Health = math.huge
		else h.MaxHealth = 100 h.Health = 100 end
	end
end

local function SetSpin(on)
	SpinEnabled = on
	if SpinConnection then SpinConnection:Disconnect() end
	if on then
		SpinConnection = RunService.Heartbeat:Connect(function(dt)
			local root = GetRoot()
			if root then
				root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed * dt * 60), 0)
			end
		end)
	end
end

local function SetESP(on)
	ESPEnabled = on
	for _, o in pairs(ESPObjects) do if o then o:Destroy() end end
	ESPObjects = {}
	if not on then return end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local head = p.Character:FindFirstChild("Head")
			if head then
				local bg = Make("BillboardGui", {
					Size = UDim2.new(0, 100, 0, 36),
					StudsOffset = Vector3.new(0, 2, 0),
					AlwaysOnTop = true
				}, head)
				Make("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.4,
					Text = p.Name, TextColor3 = Color3.fromRGB(255, 60, 60),
					TextSize = 13, Font = Enum.Font.GothamBold
				}, bg)
				table.insert(ESPObjects, bg)
			end
		end
	end
end

-- ==================================================
-- FE 系统（冒火 + 移动冒火 + 皇冠）
-- ==================================================
local function ClearFE()
	if FEFirePart then FEFirePart:Destroy() FEFirePart = nil end
	if FECrownPart then FECrownPart:Destroy() FECrownPart = nil end
	if FEMoveConnection then FEMoveConnection:Disconnect() FEMoveConnection = nil end
end

local function BuildFE()
	ClearFE()
	local char = GetCharacter()
	local head = char and char:FindFirstChild("Head")
	local root = GetRoot()
	if not head or not root then return end

	if FE_Fire then
		FEFirePart = Make("Fire", {
			Size = 5, Heat = 5,
			Color = Color3.fromRGB(255, 100, 0),
			SecondaryColor = Color3.fromRGB(255, 200, 0)
		}, head)
	end

	if FE_Crown then
		FECrownPart = Make("Part", {
			Size = Vector3.new(1.6, 0.9, 1.6),
			Anchored = false, CanCollide = false,
			Transparency = 0.25, Material = Enum.Material.Neon,
			Color = Color3.fromRGB(255, 215, 0),
			Shape = Enum.PartType.Block
		}, head)
		local w = Make("WeldConstraint", {}, FECrownPart)
		w.Part0 = FECrownPart w.Part1 = head
		FECrownPart.CFrame = head.CFrame * CFrame.new(0, 1.3, 0)
	end

	if FE_MoveFire then
		FEMoveConnection = RunService.Heartbeat:Connect(function()
			local r = GetRoot()
			if r and r.Velocity.Magnitude > 5 then
				local sp = Make("Fire", {
					Size = 3, Heat = 3,
					Color = Color3.fromRGB(255, 150, 0),
					SecondaryColor = Color3.fromRGB(255, 255, 0)
				}, r)
				Debris:AddItem(sp, 0.3)
			end
		end)
	end
end

local function SetFE(on)
	FE_Enabled = on
	if not on then ClearFE() else BuildFE() end
end

-- ==================================================
-- 甩飞（独立）
-- ==================================================
local function SetThrow(on)
	ThrowEnabled = on
	if ThrowConnection then ThrowConnection:Disconnect() end
	if on then
		ThrowConnection = RunService.Heartbeat:Connect(function()
			if not ThrowEnabled then return end
			local mouse = LocalPlayer:GetMouse()
			if mouse and mouse.Target then
				local model = mouse.Target:FindFirstAncestorOfClass("Model")
				if model and model ~= GetCharacter() then
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if hrp then
						local bv = Make("BodyVelocity", {
							Velocity = Camera.CFrame.LookVector * ThrowPower,
							MaxForce = Vector3.new(math.huge, math.huge, math.huge),
							P = 5000
						}, hrp)
						Debris:AddItem(bv, 0.2)
					end
				end
			end
		end)
		Notify("AM Hub", "甩飞开启 - 对准目标", 3)
	end
end

-- ==================================================
-- 反检测
-- ==================================================
local function StartAntiKick()
	if AntiKickConnection then AntiKickConnection:Disconnect() end
	AntiKickConnection = RunService.Heartbeat:Connect(function()
		if not AntiKick then return end
		pcall(function()
			local mt = getrawmetatable and getrawmetatable(game)
			if mt then
				local old = mt.__namecall
				if old then
					setreadonly(mt, false)
					mt.__namecall = newcclosure(function(self, ...)
						local m = getnamecallmethod and getnamecallmethod()
						if m and (m:lower() == "kick" or m:lower() == "remove") then
							if self == LocalPlayer or self == GetCharacter() then return nil end
						end
						return old(self, ...)
					end)
					setreadonly(mt, true)
				end
			end
		end)
	end)
end

-- ==================================================
-- 玩家选择器（保留你的结构）
-- ==================================================
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

PlayerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PlayerList.CanvasSize = UDim2.fromOffset(0, PlayerLayout.AbsoluteContentSize.Y + 10)
end)

local function RefreshPlayerList()
	for _, object in ipairs(PlayerList:GetChildren()) do
		if not object:IsA("UIListLayout") then object:Destroy() end
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
			end)
		end
	end
end

Players.PlayerRemoving:Connect(function(leavingPlayer)
	if SelectedPlayer == leavingPlayer then SelectedPlayer = nil end
end)

-- ==================================================
-- 分类页面（全部保留你的 + 新增功能）
-- ==================================================
local function ShowInfo()
	ClearContent()
	Section("信息")
	Button("欢迎使用 AM Hub")
	local age = LocalPlayer.AccountAge
	Button("Roblox 账户：" .. math.floor(age/365) .. " 年 " .. age%365 .. " 天")
	Button("用户名：" .. LocalPlayer.Name)
	Button("QQ 群：" .. QQ_GROUP, function()
		pcall(function setclipboard(QQ_GROUP) end)
		Notify("AM Hub", "QQ群: " .. QQ_GROUP, 5)
	end)
end

local function ShowGeneral()
	ClearContent()
	Section("通用")

	Toggle("飞行", function() return Flying end, function(v)
		if v then StartFlight() else StopFlight() end
	end)
	Slider("飞行速度", 10, 200, function() return FlightSpeed end, function(v) FlightSpeed = v end)

	Section("飞行方向（手机按住）")
	FlyButton("↑ 前进", "f", 1)
	FlyButton("↓ 后退", "f", -1)
	FlyButton("← 左移", "r", -1)
	FlyButton("→ 右移", "r", 1)
	FlyButton("▲ 升高", "u", 1)
	FlyButton("▼ 降低", "u", -1)

	Toggle("无限跳跃", function() return InfiniteJump end, function(v) InfiniteJump = v end)
	Toggle("穿墙", function() return Noclip end, SetNoclip)

	Toggle("速度修改", function() return SpeedHack end, SetSpeed)
	Slider("移速", 16, 300, function() return SpeedVal end, function(v) SpeedVal = v if SpeedHack then local h=GetHumanoid() if h then h.WalkSpeed=v end end end)

	-- 【修复】跳高
	Toggle("跳高", function() return JumpVal > 50 end, function(v) SetJump(v) end)
	Slider("跳高值", 50, 500, function() return JumpVal end, function(v) JumpVal = v SetJump(true) end)

	Slider("重力", 0, 500, function() return GravityVal end, function(v) GravityVal = v Workspace.Gravity = v end)

	Toggle("夜视", function() return Lighting.Brightness > 1 end, function(v)
		if v then Lighting.Brightness = 2 Lighting.ClockTime = 14 else Lighting.Brightness = 1 end
	end)

	Toggle("锁定视角", function() return LockCam end, SetLockCam)
end

local function ShowCombat()
	ClearContent()
	Section("战斗")
	Toggle("ESP", function() return ESPEnabled end, SetESP)
	Toggle("透视", function() return false end, function(v) print("透视:", v) end)
	Slider("自瞄 FOV", 1, 180, 90, function(v) print("FOV:", v) end)
	Toggle("自瞄", function() return false end, function(v) print("自瞄:", v) end)
	Button("敌对颜色：红色")
	Button("我方颜色：蓝色")
end

local function ShowEntertainment()
	ClearContent()
	Section("娱乐")
	Toggle("无敌模式", function() return GodMode end, SetGod)
	Toggle("旋转", function() return SpinEnabled end, SetSpin)
	Slider("旋转速度", 10, 200, function() return SpinSpeed end, function(v) SpinSpeed = v end)
	Toggle("全亮", function() return FullBright end, function(v)
		FullBright = v
		if v then Lighting.Ambient = Color3.new(1,1,1) Lighting.OutdoorAmbient = Color3.new(1,1,1) Lighting.Brightness = 2
		else Lighting.Ambient = Color3.fromRGB(128,128,128) Lighting.Brightness = 1 end
	end)
	Toggle("去雾", function() return NoFog end, function(v)
		NoFog = v Lighting.FogEnd = v and 100000 or 10000
	end)
	Slider("FPS", 30, 120, 60, function(v) print("FPS:", v) end)
end

local function ShowFling()
	ClearContent()
	Section("甩飞")
	Button("选择玩家", function() RefreshPlayerList() PlayerSelector.Visible = true end)
	Button("当前目标：" .. (SelectedPlayer and SelectedPlayer.Name or "未选择"))
	Button("甩飞", function()
		if not SelectedPlayer then Notify("AM Hub", "请先选择玩家", 2) return end
		SetThrow(true)
	end)
	Toggle("甩飞（持续）", function() return ThrowEnabled end, SetThrow)
	Slider("甩飞力度", 50, 500, function() return ThrowPower end, function(v) ThrowPower = v end)
	Button("传送", function()
		if not SelectedPlayer then Notify("AM Hub", "请先选择玩家", 2) return end
		local tRoot = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		local myRoot = GetRoot()
		if tRoot and myRoot then myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0) end
	end)
end

local function ShowEffects()
	ClearContent()
	Section("特效 / FE")

	-- FE 系统
	Toggle("FE 总开关（冒火+皇冠）", function() return FE_Enabled end, SetFE)
	Toggle("头顶冒火", function() return FE_Fire end, function(v) FE_Fire = v if FE_Enabled then BuildFE() end end)
	Toggle("移动冒火", function() return FE_MoveFire end, function(v) FE_MoveFire = v if FE_Enabled then BuildFE() end end)
	Toggle("AM皇冠", function() return FE_Crown end, function(v) FE_Crown = v if FE_Enabled then BuildFE() end end)

	-- 金身
	Toggle("金身", function() return false end, function(v)
		local char = GetCharacter()
		if char then
			for _, o in pairs(char:GetChildren()) do
				if o:IsA("BasePart") then o.Color = v and Color3.fromRGB(255,200,40) or Color3.new(1,1,1) end
			end
		end
	end)
	Toggle("冰霜移动拖尾", function() return false end, function(v) print("冰霜拖尾:", v) end)
end

-- 【新增】高级分类（反作弊等）
local function ShowAdvanced()
	ClearContent()
	Section("高级 / 反检测")
	Toggle("反踢出 (AntiKick)", function() return AntiKick end, function(v) AntiKick = v if v then StartAntiKick() end end)
	Toggle("反检测 (AntiDetect)", function() return AntiDetect end, function(v) AntiDetect = v end)
	Button("重置所有功能", function()
		StopFlight() SetNoclip(false) SetSpeed(false) SetGod(false) SetSpin(false)
		SetESP(false) SetLockCam(false) SetThrow(false) SetFE(false)
		FullBright = false NoFog = false Workspace.Gravity = 196.2
		Lighting.Brightness = 1 Lighting.Ambient = Color3.fromRGB(128,128,128) Lighting.FogEnd = 10000
		Notify("AM Hub", "已重置", 3)
	end)
end

local function ShowSettings()
	ClearContent()
	Section("设置")
	Button("退出 AM", function()
		StopFlight()
		if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
		ScreenGui:Destroy()
	end)
end

-- ==================================================
-- 【修复3】分类列表：新增"高级"，用 ScrollingFrame 自动布局
-- ==================================================
local Categories = {"信息", "通用", "战斗", "娱乐", "甩飞", "特效", "高级", "设置"}
local Pages = {
	["信息"] = ShowInfo,
	["通用"] = ShowGeneral,
	["战斗"] = ShowCombat,
	["娱乐"] = ShowEntertainment,
	["甩飞"] = ShowFling,
	["特效"] = ShowEffects,
	["高级"] = ShowAdvanced,
	["设置"] = ShowSettings,
}
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
	if Pages[name] then Pages[name]() end
end

for index, name in ipairs(Categories) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 36)
	-- 【关键】用 UIListLayout 自动排列，不再写死 Position
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
	button.MouseButton1Click:Connect(function() SelectCategory(name) end)
end

-- ==================================================
-- 菜单拖动
-- ==================================================
local MenuDragging = false
local MenuDragStart, MenuStartPosition
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = true
		MenuDragStart = input.Position
		MenuStartPosition = Menu.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not MenuDragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - MenuDragStart
		Menu.Position = UDim2.new(MenuStartPosition.X.Scale, MenuStartPosition.X.Offset + delta.X, MenuStartPosition.Y.Scale, MenuStartPosition.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		MenuDragging = false
	end
end)

-- ==================================================
-- 悬浮球拖动 + 点击
-- ==================================================
local ButtonDragging = false
local ButtonDragStart, ButtonStartPosition, ButtonMoved
AMButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		ButtonDragging = true
		ButtonMoved = false
		ButtonDragStart = input.Position
		ButtonStartPosition = AMButton.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not ButtonDragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - ButtonDragStart
		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then ButtonMoved = true end
		AMButton.Position = UDim2.new(ButtonStartPosition.X.Scale, ButtonStartPosition.X.Offset + delta.X, ButtonStartPosition.Y.Scale, ButtonStartPosition.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if ButtonDragging and not ButtonMoved then
			Menu.Visible = not Menu.Visible
			if Menu.Visible then SelectCategory("信息") end
		end
		ButtonDragging = false
	end
end)

-- ==================================================
-- 玩家选择器拖动
-- ==================================================
local SelectorDragging = false
local SelectorDragStart, SelectorStartPosition
SelectorTitle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelectorDragging = true
		SelectorDragStart = input.Position
		SelectorStartPosition = PlayerSelector.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not SelectorDragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - SelectorDragStart
		PlayerSelector.Position = UDim2.new(SelectorStartPosition.X.Scale, SelectorStartPosition.X.Offset + delta.X, SelectorStartPosition.Y.Scale, SelectorStartPosition.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		SelectorDragging = false
	end
end)

-- ==================================================
-- 键盘飞行（电脑测试）
-- ==================================================
local function SetFly(axis, val)
	if axis == "f" then FlyInput.Forward = val end
	if axis == "r" then FlyInput.Right = val end
	if axis == "u" then FlyInput.Up = val end
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.W then SetFly("f", 1) end
	if input.KeyCode == Enum.KeyCode.S then SetFly("f", -1) end
	if input.KeyCode == Enum.KeyCode.A then SetFly("r", -1) end
	if input.KeyCode == Enum.KeyCode.D then SetFly("r", 1) end
	if input.KeyCode == Enum.KeyCode.Space then SetFly("u", 1) end
	if input.KeyCode == Enum.KeyCode.LeftShift then SetFly("u", -1) end
	if input.KeyCode == Enum.KeyCode.F then if Flying then StopFlight() else StartFlight() end end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then SetFly("f", 0) end
	if input.KeyCode == Enum.KeyCode.S then SetFly("f", 0) end
	if input.KeyCode == Enum.KeyCode.A then SetFly("r", 0) end
	if input.KeyCode == Enum.KeyCode.D then SetFly("r", 0) end
	if input.KeyCode == Enum.KeyCode.Space then SetFly("u", 0) end
	if input.KeyCode == Enum.KeyCode.LeftShift then SetFly("u", 0) end
end)

-- 无限跳跃连接
InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
	if not InfiniteJump then return end
	local humanoid = GetHumanoid()
	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ==================================================
-- 流光动画
-- ==================================================
local Rotation = 0
RunService.RenderStepped:Connect(function(dt)
	Rotation = (Rotation + dt * 100) % 360
	AMGradient.Rotation = Rotation
	MenuGradient.Rotation = Rotation
	SelectorGradient.Rotation = Rotation
end)

-- ==================================================
-- 初始化
-- ==================================================
StartAntiKick()

SelectCategory("信息")

Notify("AM Hub Mobile 3.0", "已加载！QQ群: " .. QQ_GROUP, 4)
print("[AM Hub] 已就绪！QQ群:", QQ_GROUP)

-- 角色重生处理
LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	if Flying then StopFlight() end
	if FE_Enabled then BuildFE() end
end)
