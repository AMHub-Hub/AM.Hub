--// ================================================================
--// AM Hub Mobile - 完整功能版
--// Luau / LocalScript / Delta Executor
--// 风格：深色玻璃 + 流光描边（按你的壳子）
--// ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 30)
local Camera = Workspace.CurrentCamera

-- ==================================================
-- 流光色
-- ==================================================
local rainbow = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 80)),
	ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 150, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 100)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 80, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(180, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 120))
})

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

-- ==================================================
-- 主菜单
-- ==================================================
local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.fromOffset(340, 460)
Menu.Position = UDim2.new(0, 95, 0.5, -230)
Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Menu.BackgroundTransparency = 0.12
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.ClipsDescendants = true
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

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 0, 45)
Title.Position = UDim2.fromOffset(15, 8)
Title.BackgroundTransparency = 1
Title.Text = "AM Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Menu

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(35, 35)
CloseButton.Position = UDim2.new(1, -42, 0, 8)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Menu

CloseButton.MouseButton1Click:Connect(function()
	Menu.Visible = false
end)

-- ==================================================
-- 左侧分类栏（ScrollingFrame，可滑动，不超出）
-- ==================================================
local CategoryBar = Instance.new("ScrollingFrame")
CategoryBar.Size = UDim2.new(0, 88, 1, -55)
CategoryBar.Position = UDim2.fromOffset(8, 50)
CategoryBar.BackgroundTransparency = 1
CategoryBar.BorderSizePixel = 0
CategoryBar.ScrollBarThickness = 4
CategoryBar.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
CategoryBar.CanvasSize = UDim2.new(0, 0, 0, 0)
CategoryBar.ClipsDescendants = true
CategoryBar.Parent = Menu

local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.Padding = UDim.new(0, 6)
CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
CategoryLayout.Parent = CategoryBar

CategoryLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	CategoryBar.CanvasSize = UDim2.new(0, 0, 0, CategoryLayout.AbsoluteContentSize.Y + 10)
end)

-- 右侧内容区
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -102, 1, -55)
Content.Position = UDim2.fromOffset(96, 50)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 140)
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.ClipsDescendants = true
Content.Parent = Menu

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = Content

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 15)
end)

-- ==================================================
-- 工具函数
-- ==================================================
local function GetChar() return player.Character end
local function GetHum()
	local c = GetChar()
	if c then return c:FindFirstChildOfClass("Humanoid") end
	return nil
end
local function GetRoot()
	local c = GetChar()
	if c then return c:FindFirstChild("HumanoidRootPart") end
	return nil
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
local function Corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

-- ==================================================
-- 全局状态（唯一真相源）
-- ==================================================
local State = {
	Fly = false,
	Speed = false,
	Jump = false,
	Noclip = false,
	LockCam = false,
	ESP = false,
	God = false,
	InfJump = false,
	Spin = false,
	FullBright = false,
	NoFog = false,
	AntiKick = true,
	AntiDetect = true,
	FE = false,
	FE_Fire = false,
	FE_MoveFire = false,
	FE_Crown = false,
	Throw = false,
}
local Values = {
	FlySpeed = 50,
	Speed = 50,
	Jump = 100,
	Spin = 50,
	Gravity = 196.2,
	ThrowPower = 200,
}
local FlyInput = {Forward = 0, Right = 0, Up = 0}

-- ==================================================
-- UI 组件工厂（状态不反转版）
-- ==================================================
local function Section(text)
	local lbl = Make("TextLabel", {
		Size = UDim2.new(1, -10, 0, 26),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Color3.fromRGB(180, 180, 200),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, Content)
	return lbl
end

local function Toggle(text, desc, getState, setState)
	local frame = Make("Frame", {
		Size = UDim2.new(1, -10, 0, 52),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BackgroundTransparency = 0.2,
	}, Content)
	Corner(frame, 10)
	Make("UIStroke", {Thickness = 1, Color = Color3.fromRGB(80, 80, 100)}, frame)

	Make("TextLabel", {
		Size = UDim2.new(1, -75, 0, 20), Position = UDim2.fromOffset(10, 6),
		BackgroundTransparency = 1, Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	Make("TextLabel", {
		Size = UDim2.new(1, -75, 0, 16), Position = UDim2.fromOffset(10, 28),
		BackgroundTransparency = 1, Text = desc,
		TextColor3 = Color3.fromRGB(150, 150, 170), TextSize = 11,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local btn = Make("TextButton", {
		Size = UDim2.new(0, 52, 0, 30), Position = UDim2.new(1, -62, 0, 11),
		BackgroundColor3 = Color3.fromRGB(200, 200, 200), BorderSizePixel = 0,
		Text = "关", TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13, Font = Enum.Font.GothamBold,
	}, frame)
	Corner(btn, 8)

	local function Refresh()
		local on = getState()
		btn.Text = on and "开" or "关"
		btn.BackgroundColor3 = on and Color3.fromRGB(0, 200, 83) or Color3.fromRGB(90, 90, 110)
	end
	Refresh()

	btn.MouseButton1Click:Connect(function()
		setState(not getState())
		Refresh()
	end)

	return {frame = frame, refresh = Refresh}
end

local function Slider(text, desc, minV, maxV, getVal, setVal)
	local frame = Make("Frame", {
		Size = UDim2.new(1, -10, 0, 68),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BackgroundTransparency = 0.2,
	}, Content)
	Corner(frame, 10)
	Make("UIStroke", {Thickness = 1, Color = Color3.fromRGB(80, 80, 100)}, frame)

	local valLabel = Make("TextLabel", {
		Size = UDim2.new(0, 55, 0, 20), Position = UDim2.new(1, -62, 0, 6),
		BackgroundColor3 = Color3.fromRGB(60, 60, 75), BorderSizePixel = 0,
		Text = tostring(getVal()), TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12, Font = Enum.Font.GothamBold,
	}, frame)
	Corner(valLabel, 5)

	Make("TextLabel", {
		Size = UDim2.new(1, -75, 0, 20), Position = UDim2.fromOffset(10, 6),
		BackgroundTransparency = 1, Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)
	Make("TextLabel", {
		Size = UDim2.new(1, -75, 0, 16), Position = UDim2.fromOffset(10, 26),
		BackgroundTransparency = 1, Text = desc,
		TextColor3 = Color3.fromRGB(150, 150, 170), TextSize = 11,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local bar = Make("Frame", {
		Size = UDim2.new(1, -20, 0, 6), Position = UDim2.fromOffset(10, 50),
		BackgroundColor3 = Color3.fromRGB(70, 70, 85), BorderSizePixel = 0,
	}, frame)
	Corner(bar, 3)

	local fill = Make("Frame", {
		Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 200, 130),
		BorderSizePixel = 0,
	}, bar)
	Corner(fill, 3)

	local knob = Make("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, bar)
	Corner(knob, 7)

	local dragging = false
	local function Update(input)
		local x = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
		x = math.clamp(x, 0, 1)
		local v = minV + (maxV - minV) * x
		setVal(v)
		valLabel.Text = tostring(math.floor(v))
		fill.Size = UDim2.new(x, 0, 1, 0)
		knob.Position = UDim2.new(x, 0, 0.5, 0)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			Update(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			Update(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- 初始值
	Update({Position = {X = bar.AbsolutePosition.X + (getVal() - minV) / (maxV - minV) * bar.AbsoluteSize.X}})
end

local function ActionButton(text, desc, callback)
	local frame = Make("Frame", {
		Size = UDim2.new(1, -10, 0, 52),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BackgroundTransparency = 0.2,
	}, Content)
	Corner(frame, 10)
	Make("UIStroke", {Thickness = 1, Color = Color3.fromRGB(80, 80, 100)}, frame)

	Make("TextLabel", {
		Size = UDim2.new(1, -75, 0, 20), Position = UDim2.fromOffset(10, 6),
		BackgroundTransparency = 1, Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)
	Make("TextLabel", {
		Size = UDim2.new(1, -75, 0, 16), Position = UDim2.fromOffset(10, 28),
		BackgroundTransparency = 1, Text = desc,
		TextColor3 = Color3.fromRGB(150, 150, 170), TextSize = 11,
		Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local btn = Make("TextButton", {
		Size = UDim2.new(0, 52, 0, 30), Position = UDim2.new(1, -62, 0, 11),
		BackgroundColor3 = Color3.fromRGB(0, 130, 220), BorderSizePixel = 0,
		Text = "执行", TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13, Font = Enum.Font.GothamBold,
	}, frame)
	Corner(btn, 8)

	btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

-- 飞行方向按钮（手机触屏）
local function FlyBtn(text, getAxis, setAxis)
	local frame = Make("Frame", {
		Size = UDim2.new(1, -10, 0, 40),
		BackgroundColor3 = Color3.fromRGB(45, 45, 60),
		BackgroundTransparency = 0.2,
	}, Content)
	Corner(frame, 9)

	local lbl = Make("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0), Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1, Text = text,
		TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 13,
		Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
	}, frame)

	local btn = Make("TextButton", {
		Size = UDim2.new(0, 52, 0, 30), Position = UDim2.new(1, -62, 0, 5),
		BackgroundColor3 = Color3.fromRGB(70, 70, 90), BorderSizePixel = 0,
		Text = "按住", TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12, Font = Enum.Font.GothamBold,
	}, frame)
	Corner(btn, 8)

	local function On() setAxis(getAxis() + 1) end
	local function Off() setAxis(getAxis() - 1) end

	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			On() btn.BackgroundColor3 = Color3.fromRGB(0, 200, 83)
		end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			Off() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
		end
	end)
end

-- ==================================================
-- 飞行系统（能转 + 升降）
-- ==================================================
local FlyBV, FlyBG, FlyConn

local function StartFly()
	if State.Fly then return end
	local root = GetRoot()
	if not root then Notify("AM Hub", "找不到角色", 2) return end
	State.Fly = true

	local hum = GetHum()
	if hum then hum.PlatformStand = true end

	FlyBV = Make("BodyVelocity", {
		MaxForce = Vector3.new(math.huge, math.huge, math.huge),
		Velocity = Vector3.zero, P = 5000,
	}, root)
	FlyBG = Make("BodyGyro", {
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
		CFrame = root.CFrame, P = 9000, D = 100,
	}, root)

	FlyConn = RunService.RenderStepped:Connect(function()
		if not State.Fly then return end
		local root = GetRoot()
		if not root then StopFly() return end

		local cf = Camera.CFrame
		local fwd = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
		local rgt = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit

		local vel = fwd * FlyInput.Forward + rgt * FlyInput.Right
		vel = vel + Vector3.new(0, FlyInput.Up, 0)
		if vel.Magnitude > 0 then
			vel = vel.Unit * Values.FlySpeed
		end

		FlyBV.Velocity = vel
		FlyBG.CFrame = cf
	end)
	Notify("AM Hub", "飞行开启", 2)
end

local function StopFly()
	if not State.Fly then return end
	State.Fly = false
	FlyInput.Forward = 0
	FlyInput.Right = 0
	FlyInput.Up = 0
	local hum = GetHum()
	if hum then hum.PlatformStand = false end
	local root = GetRoot()
	if root then root.AssemblyLinearVelocity = Vector3.zero end
	if FlyBV then FlyBV:Destroy() FlyBV = nil end
	if FlyBG then FlyBG:Destroy() FlyBG = nil end
	if FlyConn then FlyConn:Disconnect() FlyConn = nil end
	Notify("AM Hub", "飞行关闭", 2)
end

-- ==================================================
-- 移动 / 跳高 / 锁定视角
-- ==================================================
local NoclipConn, LockCamConn, SpinConn, AutoClickConn, ThrowConn

local function ApplySpeed(v)
	Values.Speed = v
	local h = GetHum()
	if h then h.WalkSpeed = State.Speed and v or 16 end
end

local function SetSpeed(on)
	State.Speed = on
	local h = GetHum()
	if h then h.WalkSpeed = on and Values.Speed or 16 end
end

local function SetJump(on)
	State.Jump = on
	local h = GetHum()
	if h then
		if on then
			h.JumpPower = Values.Jump
			h.JumpHeight = Values.Jump / 10
			local s = h:GetState()
			if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Landed then
				h:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		else
			h.JumpPower = 50
			h.JumpHeight = 7.2
		end
	end
end

local function SetNoclip(on)
	State.Noclip = on
	if NoclipConn then NoclipConn:Disconnect() end
	if on then
		NoclipConn = RunService.Stepped:Connect(function()
			local c = GetChar()
			if c then
				for _, p in pairs(c:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
end

local function SetLockCam(on)
	State.LockCam = on
	if LockCamConn then LockCamConn:Disconnect() end
	if on then
		LockCamConn = RunService.RenderStepped:Connect(function()
			if not State.LockCam then return end
			local root = GetRoot()
			if root then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
			end
		end)
	else
		Camera.CameraType = Enum.CameraType.Custom
	end
end

local function SetGod(on)
	State.God = on
	local h = GetHum()
	if h then
		if on then h.MaxHealth = math.huge h.Health = math.huge
		else h.MaxHealth = 100 h.Health = 100 end
	end
end

local function SetInfJump(on)
	State.InfJump = on
end
UserInputService.JumpRequest:Connect(function()
	if State.InfJump and not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		local h = GetHum()
		if h and h:GetState() ~= Enum.HumanoidStateType.Dead then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

local function SetSpin(on)
	State.Spin = on
	if SpinConn then SpinConn:Disconnect() end
	if on then
		SpinConn = RunService.Heartbeat:Connect(function(dt)
			local root = GetRoot()
			if root then
				root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Values.Spin * dt * 60), 0)
			end
		end)
	end
end

-- ==================================================
-- ESP
-- ==================================================
local ESPObjects = {}
local function SetESP(on)
	State.ESP = on
	for _, o in pairs(ESPObjects) do if o then o:Destroy() end end
	ESPObjects = {}
	if not on then return end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local head = p.Character:FindFirstChild("Head")
			if head then
				local bg = Make("BillboardGui", {
					Size = UDim2.new(0, 100, 0, 36),
					StudsOffset = Vector3.new(0, 2, 0),
					AlwaysOnTop = true,
				}, head)
				Make("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.4,
					Text = p.Name, TextColor3 = Color3.fromRGB(255, 60, 60),
					TextSize = 13, Font = Enum.Font.GothamBold,
				}, bg)
				table.insert(ESPObjects, bg)
			end
		end
	end
end

-- ==================================================
-- FE 系统（冒火 + 移动冒火 + 皇冠）
-- ==================================================
local FEFire, FECrown, FEMoveConn

local function RebuildFE()
	-- 清掉旧的
	if FEFire then FEFire:Destroy() FEFire = nil end
	if FECrown then FECrown:Destroy() FECrown = nil end
	if FEMoveConn then FEMoveConn:Disconnect() FEMoveConn = nil end

	local head = GetChar() and GetChar():FindFirstChild("Head")
	local root = GetRoot()
	if not head or not root then return end

	if State.FE_Fire or State.FE then
		FEFire = Make("Fire", {
			Size = 5, Heat = 5,
			Color = Color3.fromRGB(255, 100, 0),
			SecondaryColor = Color3.fromRGB(255, 200, 0),
		}, head)
	end

	if State.FE_Crown or State.FE then
		FECrown = Make("Part", {
			Size = Vector3.new(1.6, 0.9, 1.6),
			Anchored = false, CanCollide = false,
			Transparency = 0.25, Material = Enum.Material.Neon,
			Color = Color3.fromRGB(255, 215, 0),
			Shape = Enum.PartType.Block,
		}, head)
		local w = Make("WeldConstraint", {}, FECrown)
		w.Part0 = FECrown w.Part1 = head
		FECrown.CFrame = head.CFrame * CFrame.new(0, 1.3, 0)
	end

	if State.FE_MoveFire or State.FE then
		FEMoveConn = RunService.Heartbeat:Connect(function()
			local r = GetRoot()
			if r and r.Velocity.Magnitude > 5 then
				local sp = Make("Fire", {
					Size = 3, Heat = 3,
					Color = Color3.fromRGB(255, 150, 0),
					SecondaryColor = Color3.fromRGB(255, 255, 0),
				}, r)
				Debris:AddItem(sp, 0.3)
			end
		end)
	end
end

local function SetFE(on)
	State.FE = on
	if not on then
		if FEFire then FEFire:Destroy() FEFire = nil end
		if FECrown then FECrown:Destroy() FECrown = nil end
		if FEMoveConn then FEMoveConn:Disconnect() FEMoveConn = nil end
	else
		RebuildFE()
	end
end

-- ==================================================
-- 甩飞（独立于FE）
-- ==================================================
local function SetThrow(on)
	State.Throw = on
	if ThrowConn then ThrowConn:Disconnect() end
	if on then
		ThrowConn = RunService.Heartbeat:Connect(function()
			if not State.Throw then return end
			local mouse = player:GetMouse()
			if mouse and mouse.Target then
				local model = mouse.Target:FindFirstAncestorOfClass("Model")
				if model and model ~= GetChar() then
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if hrp then
						local bv = Make("BodyVelocity", {
							Velocity = Camera.CFrame.LookVector * Values.ThrowPower,
							MaxForce = Vector3.new(math.huge, math.huge, math.huge),
							P = 5000,
						}, hrp)
						Debris:AddItem(bv, 0.2)
					end
				end
			end
		end)
		Notify("AM Hub", "甩飞开启 - 对准目标", 3)
	else
		Notify("AM Hub", "甩飞关闭", 2)
	end
end

-- ==================================================
-- 反检测（AntiKick + AntiDetect，降频不卡）
-- ==================================================
local AntiKickConn, AntiDetectConn

local function StartAntiKick()
	if AntiKickConn then AntiKickConn:Disconnect() end
	AntiKickConn = RunService.Heartbeat:Connect(function()
		if not State.AntiKick then return end
		pcall(function()
			local mt = getrawmetatable and getrawmetatable(game)
			if mt then
				local old = mt.__namecall
				if old then
					setreadonly(mt, false)
					mt.__namecall = newcclosure(function(self, ...)
						local m = getnamecallmethod and getnamecallmethod()
						if m and (m:lower() == "kick" or m:lower() == "remove") then
							if self == player or self == GetChar() then return nil end
						end
						return old(self, ...)
					end)
					setreadonly(mt, true)
				end
			end
		end)
	end)
end

local function StartAntiDetect()
	if AntiDetectConn then AntiDetectConn:Disconnect() end
	-- 降频：每 2 秒扫描一次，不每帧跑，避免卡
	task.spawn(function()
		while true do
			if State.AntiDetect then
				pcall(function()
					local c = GetChar()
					if c then
						for _, p in pairs(c:GetChildren()) do
							if p:IsA("BasePart") then
								p.CanCollide = true
							end
						end
					end
				end)
			end
			wait(2)
		end
	end)
end

-- ==================================================
-- 分类内容（一次性建好，切分类只改 Visible，不重建）
-- ==================================================
local CatPages = {}
local CategoryNames = {"主页", "移动", "视角", "玩家", "世界", "高级", "设置"}

local function NewPage(name)
	local container = Make("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = false,
	}, Content)
	CatPages[name] = container
	return container
end

-- 临时把 Content 的 Layout 存起来，每页用自己的
ContentLayout:Destroy()

-- 主页
do
	local p = NewPage("主页")
	Section("欢迎使用 AM Hub"):Parent = p
	ActionButton("QQ群", "179051448（已复制）", function()
		pcall(function setclipboard("179051448") end)
		Notify("AM Hub", "QQ群: 179051448", 5)
	end):Parent = p
	Toggle("反踢出", "拦截踢出/销毁", function() return State.AntiKick end, function(v) State.AntiKick = v if v then StartAntiKick() end end):Parent = p
	Toggle("反检测", "降低被检测风险", function() return State.AntiDetect end, function(v) State.AntiDetect = v if v then StartAntiDetect() end end):Parent = p
	ActionButton("版本信息", "AM Hub Mobile 3.0", function()
		Notify("AM Hub", "AM Hub Mobile 3.0 | Delta专用", 3)
	end):Parent = p
end

-- 移动
do
	local p = NewPage("移动")
	Toggle("飞行", "开启后可用下方方向键", function() return State.Fly end, function(v) if v then StartFly() else StopFly() end end):Parent = p
	Slider("飞行速度", "10-200", 10, 200, function() return Values.FlySpeed end, function(v) Values.FlySpeed = v end):Parent = p

	Section("飞行方向控制（按住移动）"):Parent = p
	FlyBtn("↑ 前进", function() return FlyInput.Forward end, function(v) FlyInput.Forward = v end):Parent = p
	FlyBtn("↓ 后退", function() return -FlyInput.Forward end, function(v) FlyInput.Forward = -v end):Parent = p
	FlyBtn("← 左移", function() return -FlyInput.Right end, function(v) FlyInput.Right = -v end):Parent = p
	FlyBtn("→ 右移", function() return FlyInput.Right end, function(v) FlyInput.Right = v end):Parent = p
	FlyBtn("▲ 升高", function() return FlyInput.Up end, function(v) FlyInput.Up = v end):Parent = p
	FlyBtn("▼ 降低", function() return -FlyInput.Up end, function(v) FlyInput.Up = -v end):Parent = p

	Toggle("速度", "修改移动速度", function() return State.Speed end, SetSpeed):Parent = p
	Slider("速度值", "16-300", 16, 300, function() return Values.Speed end, function(v) ApplySpeed(v) end):Parent = p

	Toggle("跳高", "修改跳跃高度", function() return State.Jump end, SetJump):Parent = p
	Slider("跳高值", "50-500", 50, 500, function() return Values.Jump end, function(v) Values.Jump = v SetJump(true) end):Parent = p

	Toggle("无限跳跃", "无限次跳跃", function() return State.InfJump end, SetInfJump):Parent = p
	Toggle("穿墙", "穿墙模式", function() return State.Noclip end, SetNoclip):Parent = p
end

-- 视角
do
	local p = NewPage("视角")
	Toggle("锁定视角", "锁定当前视角", function() return State.LockCam end, SetLockCam):Parent = p
	Toggle("ESP", "显示玩家名称", function() return State.ESP end, SetESP):Parent = p
end

-- 玩家
do
	local p = NewPage("玩家")
	Toggle("无敌模式", "无限生命", function() return State.God end, SetGod):Parent = p
	Toggle("旋转", "角色自动旋转", function() return State.Spin end, SetSpin):Parent = p
	Slider("旋转速度", "10-200", 10, 200, function() return Values.Spin end, function(v) Values.Spin = v end):Parent = p
end

-- 世界
do
	local p = NewPage("世界")
	Toggle("全亮", "最大亮度", function() return State.FullBright end, function(on)
		State.FullBright = on
		if on then
			Lighting.Ambient = Color3.new(1, 1, 1)
			Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
			Lighting.Brightness = 2
		else
			Lighting.Ambient = Color3.fromRGB(128, 128, 128)
			Lighting.Brightness = 1
		end
	end):Parent = p
	Toggle("去雾", "移除雾效", function() return State.NoFog end, function(on)
		State.NoFog = on
		Lighting.FogEnd = on and 100000 or 10000
	end):Parent = p
	Toggle("重力修改", "修改重力", function() return State.Gravity end, function(on)
		State.Gravity = on
		Workspace.Gravity = on and Values.Gravity or 196.2
	end):Parent = p
	Slider("重力值", "0-500", 0, 500, function() return Values.Gravity end, function(v) Values.Gravity = v if State.Gravity then Workspace.Gravity = v end end):Parent = p
end

-- 高级（FE + 甩飞 分开）
do
	local p = NewPage("高级")

	Section("── FE 系统 ──"):Parent = p
	Toggle("FE 总开关", "头顶冒火+皇冠+移动冒火", function() return State.FE end, SetFE):Parent = p
	Toggle("FE-头顶冒火", "头部火焰", function() return State.FE_Fire end, function(v) State.FE_Fire = v RebuildFE() end):Parent = p
	Toggle("FE-移动冒火", "移动时脚下冒火", function() return State.FE_MoveFire end, function(v) State.FE_MoveFire = v RebuildFE() end):Parent = p
	Toggle("FE-皇冠", "AM使用者头顶皇冠", function() return State.FE_Crown end, function(v) State.FE_Crown = v RebuildFE() end):Parent = p

	Section("── 甩飞（独立）──"):Parent = p
	Toggle("甩飞", "对准目标甩飞", function() return State.Throw end, SetThrow):Parent = p
	Slider("甩飞力度", "50-500", 50, 500, function() return Values.ThrowPower end, function(v) Values.ThrowPower = v end):Parent = p

	Section("── 反作弊 ──"):Parent = p
	Toggle("反踢出(强)", "高级反踢出", function() return State.AntiKick end, function(v) State.AntiKick = v if v then StartAntiKick() end end):Parent = p
	Toggle("反检测(强)", "高级反检测", function() return State.AntiDetect end, function(v) State.AntiDetect = v if v then StartAntiDetect() end end):Parent = p
end

-- 设置
do
	local p = NewPage("设置")
	ActionButton("重置所有", "关闭全部功能", function()
		StopFly() SetSpeed(false) SetJump(false) SetNoclip(false) SetLockCam(false)
		SetESP(false) SetGod(false) SetSpin(false) SetThrow(false) SetFE(false)
		State.FullBright = false State.NoFog = false State.Gravity = false
		Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		Lighting.Brightness = 1
		Lighting.FogEnd = 10000
		Workspace.Gravity = 196.2
		Notify("AM Hub", "所有功能已重置", 3)
	end):Parent = p
	ActionButton("关闭菜单", "隐藏主菜单", function()
		Menu.Visible = false
	end):Parent = p
end

-- ==================================================
-- 分类切换（只改 Visible，不重建）
-- ==================================================
local CategoryButtons = {}

local function ShowCategory(name)
	for n, container in pairs(CatPages) do
		container.Visible = (n == name)
	end
	for n, btn in pairs(CategoryButtons) do
		btn.BackgroundColor3 = (n == name) and Color3.fromRGB(60, 60, 90) or Color3.fromRGB(40, 40, 55)
		btn.TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)
	end
	-- 让 Content 重新布局
	Content.CanvasPosition = Vector2.zero
end

for i, name in ipairs(CategoryNames) do
	local btn = Make("TextButton", {
		Size = UDim2.new(1, -10, 0, 38),
		BackgroundColor3 = Color3.fromRGB(40, 40, 55),
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = Color3.fromRGB(180, 180, 200),
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		LayoutOrder = i,
	}, CategoryBar)
	Corner(btn, 9)
	CategoryButtons[name] = btn
	btn.MouseButton1Click:Connect(function() ShowCategory(name) end)
end

-- 初始化显示主页
ShowCategory("主页")

-- ==================================================
-- 悬浮球拖动 + 点击
-- ==================================================
local dragging = false
local dragStart, startPosition
local moved = false

AMButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		moved = false
		dragStart = input.Position
		startPosition = AMButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
			moved = true
		end
		AMButton.Position = UDim2.new(
			startPosition.X.Scale, startPosition.X.Offset + delta.X,
			startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging and not moved then
			Menu.Visible = not Menu.Visible
		end
		dragging = false
	end
end)

-- ==================================================
-- 键盘（电脑测试：WASD+空格+Shift 控制飞行）
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
	if input.KeyCode == Enum.KeyCode.F then
		if State.Fly then StopFly() else StartFly() end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then SetFly("f", 0) end
	if input.KeyCode == Enum.KeyCode.S then SetFly("f", 0) end
	if input.KeyCode == Enum.KeyCode.A then SetFly("r", 0) end
	if input.KeyCode == Enum.KeyCode.D then SetFly("r", 0) end
	if input.KeyCode == Enum.KeyCode.Space then SetFly("u", 0) end
	if input.KeyCode == Enum.KeyCode.LeftShift then SetFly("u", 0) end
end)

-- ==================================================
-- 流光动画
-- ==================================================
local rotation = 0
RunService.RenderStepped:Connect(function(dt)
	rotation = (rotation + dt * 100) % 360
	AMGradient.Rotation = rotation
	MenuGradient.Rotation = rotation
end)

-- ==================================================
-- 初始化
-- ==================================================
task.spawn(function()
	wait(2)
	StartAntiKick()
	StartAntiDetect()
	Notify("AM Hub Mobile 3.0", "脚本已加载！QQ群: 179051448", 5)
end)

-- 角色重生处理
player.CharacterAdded:Connect(function()
	wait(1)
	if State.Fly then StopFly() end
	if State.FE then RebuildFE() end
end)

print("[AM Hub] 已就绪！QQ群: 179051448")
