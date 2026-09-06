--// ================================================================
--// AM Hub - CHAIN 专用 v2
--// Delta Executor | LocalScript
--// 功能：飞行(触屏滑动) / 穿墙强化 / 多方式速度 / ESP(名字过滤) /
--//        爆炸抓包+自动避险 / 自动QTE / 尖叫斩预警 / 反检测
--// ================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)
local Camera = Workspace.CurrentCamera

-- ==================================================
-- CONFIG
-- ==================================================
local QQ_GROUP = "179051448"
local MENU_WIDTH = 300
local MENU_HEIGHT = 420
local FLOAT_SIZE = 58

-- CHAIN 关键字
local EXPLOSION_KEYS = {"Explosion", "Explode", "Boom", "Slam", "SlamGround", "砸"}
local ATTACK_KEYS = {"Attack", "Slash", "Strike", "Hit", "Scream", "Roar", "Screech"}
local QTE_KEYS = {"QTE", "Qte", "QuickTime", "Special"}

-- 安全位置缓存
local SafePosition = Vector3.new(0, 500, 0)

-- ==================================================
-- 状态
-- ==================================================
local Flying = false
local FlightSpeed = 60
local FlyTouchId = nil
local FlyInput = {X = 0, Y = 0}

local Noclip = false
local SpeedEnabled = false
local SpeedMode = "WalkSpeed" -- WalkSpeed / CFrame / Velocity / BodyMover
local SpeedVal = 50

local ESPEnabled = false
local ESPChainName = ""
local ESPObjects = {}

-- 抓包状态
local ChainExplosionPos = nil
local ChainAttacking = false
local ChainScreaming = false
local AutoQTE = false
local AutoEvade = false
local AutoQTE_Enabled = false

-- 反检测
local AntiKick = true
local AntiDetect = true
local RemoteRateLimit = {} -- 限速用
local LastActionTime = 0
local ActionDelay = 0.15 -- 模拟人类延迟

-- 连接
local FlightConnection = nil
local NoclipConnection = nil
local SpeedConnection = nil
local HookConnection = nil

-- ==================================================
-- 彩虹
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
-- 工具
-- ==================================================
local function Corner(obj, r)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = obj return c
end
local function Stroke(obj, color, t)
	local s = Instance.new("UIStroke") s.Color = color s.Thickness = t s.Parent = obj return s
end
local function Make(class, props, parent)
	local i = Instance.new(class)
	if props then for k,v in pairs(props) do pcall(function() i[k]=v end) end end
	if parent then i.Parent = parent end
	return i
end
local function GetChar() return LocalPlayer.Character end
local function GetHum()
	local c = GetChar() if c then return c:FindFirstChildOfClass("Humanoid") end return nil
end
local function GetRoot()
	local c = GetChar() if c then return c:FindFirstChild("HumanoidRootPart") end return nil
end
local function Notify(title, text, dur)
	dur = dur or 3
	pcall(function() StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur}) end)
end

-- 安全延迟（反检测：模拟人类反应时间）
local function SafeDelay(func)
	if not AntiDetect then func() return end
	local now = tick()
	if now - LastActionTime < ActionDelay then return end
	LastActionTime = now
	func()
end

-- 安全 Remote Fire（反检测：限速）
local function SafeFireRemote(remote, ...)
	if not AntiDetect then pcall(function() remote:FireServer(...) end) return end
	local name = remote.Name or "Unknown"
	local now = tick()
	if not RemoteRateLimit[name] then RemoteRateLimit[name] = {} end
	local times = RemoteRateLimit[name]
	-- 保留最近1秒的记录
	for i = #times, 1, -1 do
		if now - times[i] > 1 then table.remove(times, i) end
	end
	-- 超过5次/秒就限速
	if #times >= 5 then return end
	table.insert(times, now)
	pcall(function() remote:FireServer(...) end)
end

-- ==================================================
-- 反检测系统
-- ==================================================
local function StartAntiDetect()
	-- Hook __namecall 拦截 Kick/Remove
	pcall(function()
		local mt = getrawmetatable and getrawmetatable(game)
		if mt then
			local old = mt.__namecall
			if old then
				setreadonly(mt, false)
				mt.__namecall = newcclosure(function(self, ...)
					local method = getnamecallmethod and getnamecallmethod()
					if method and (method:lower() == "kick" or method:lower() == "remove") then
						if self == LocalPlayer or self == GetChar() then
							return nil -- 拦截踢出
						end
					end
					return old(self, ...)
				end)
				setreadonly(mt, true)
			end
		end
	end)

	-- Hook RemoteEvent.FireServer（监控链条事件）
	pcall(function()
		for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("RemoteEvent") then
				local oldFire = obj.FireServer
				if oldFire then
					hookfunction(obj.FireServer, newcclosure(function(self, ...)
						local args = {...}
						local name = self.Name or ""

						-- 检查爆炸事件
						for _, key in ipairs(EXPLOSION_KEYS) do
							if name:find(key) then
								ChainExplosionPos = Camera.CFrame.Position
								Notify("⚠️ 链条爆炸!", "检测到爆炸事件，准备避险", 4)
								if AutoEvade then
									SafeDelay(function()
										local root = GetRoot()
										if root then
											root.CFrame = CFrame.new(SafePosition)
										end
									end)
								end
								break
							end
						end

						-- 检查攻击事件
						for _, key in ipairs(ATTACK_KEYS) do
							if name:find(key) then
								ChainAttacking = true
								Notify("⚔️ 链条攻击!", "链条正在攻击你", 3)

								-- 自动QTE
								if AutoQTE_Enabled then
									SafeDelay(function()
										-- 找链条的QTE Remote并触发
										for _, r in pairs(ReplicatedStorage:GetDescendants()) do
											if r:IsA("RemoteEvent") then
												for _, qk in ipairs(QTE_KEYS) do
													if r.Name:find(qk) then
														SafeFireRemote(r, "SpecialQTE", LocalPlayer)
														Notify("🎯 自动QTE!", "已释放特殊QTE砸向链条", 3)
														break
													end
												end
											end
										end
									end)
								end
								break
							end
						end

						-- 检查尖叫
						if name:find("Scream") or name:find("Roar") or name:find("Screech") then
							ChainScreaming = true
							Notify("🚨 尖叫斩预警!", "链条尖叫了！即将冲过来！", 5)
							if AutoEvade then
								SafeDelay(function()
									local root = GetRoot()
									if root then
										root.CFrame = CFrame.new(SafePosition)
									end
								end)
							end
						end

						return oldFire(self, ...)
					end))
				end
			end
		end
	end)

	Notify("AM Hub", "反检测系统已启动", 3)
end

-- ==================================================
-- 飞行系统（触屏滑动驱动）
-- ==================================================
local FlightBV, FlightBG

local function StopFlight()
	Flying = false
	FlyTouchId = nil
	FlyInput.X = 0 FlyInput.Y = 0
	if FlightConnection then FlightConnection:Disconnect() FlightConnection = nil end
	local hum = GetHum()
	if hum then hum.PlatformStand = false end
	local root = GetRoot()
	if root then root.AssemblyLinearVelocity = Vector3.zero end
	if FlightBV then FlightBV:Destroy() FlightBV = nil end
	if FlightBG then FlightBG:Destroy() FlightBG = nil end
end

local function StartFlight()
	if Flying then return end
	local root = GetRoot()
	local hum = GetHum()
	if not root or not hum then Notify("AM Hub", "找不到角色", 2) return end
	Flying = true
	hum.PlatformStand = true

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
		if fwd.Magnitude > 0 then fwd = fwd.Unit else fwd = Vector3.new(0,0,1) end
		local rgt = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
		if rgt.Magnitude > 0 then rgt = rgt.Unit else rgt = Vector3.new(1,0,0) end

		-- 触屏滑动输入
		local vel = fwd * FlyInput.Y + rgt * FlyInput.X
		if vel.Magnitude > 0 then
			vel = vel.Unit * FlightSpeed
		end

		FlightBV.Velocity = vel
		FlightBG.CFrame = cf
	end)
	Notify("AM Hub", "飞行开启 - 滑动屏幕移动", 3)
end

-- 触屏滑动输入
UserInputService.TouchMoved:Connect(function(touch, gp)
	if not Flying or FlyTouchId ~= touch.UserInputId then return end
	local delta = touch.Delta
	-- 转成飞行方向（灵敏度可调）
	FlyInput.X = math.clamp(delta.X / 10, -1, 1)
	FlyInput.Y = math.clamp(-delta.Y / 10, -1, 1)
end)

UserInputService.TouchStarted:Connect(function(touch, gp)
	if not Flying then return end
	if not FlyTouchId then
		FlyTouchId = touch.UserInputId
	end
end)

UserInputService.TouchEnded:Connect(function(touch, gp)
	if touch.UserInputId == FlyTouchId then
		FlyTouchId = nil
		FlyInput.X = 0
		FlyInput.Y = 0
	end
end)

-- ==================================================
-- 穿墙强化版
-- ==================================================
local function SetNoclip(on)
	Noclip = on
	if NoclipConnection then NoclipConnection:Disconnect() end
	if on then
		NoclipConnection = RunService.Stepped:Connect(function()
			local c = GetChar()
			if c then
				for _, p in pairs(c:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = false
						-- 尝试设置 CollisionGroup
						pcall(function() p.CollisionGroupId = 0 end)
					end
				end
			end
		end)
		Notify("AM Hub", "穿墙已开启", 2)
	end
end

-- ==================================================
-- 多方式速度
-- ==================================================
local SpeedBV
local function SetSpeed(on)
	SpeedEnabled = on
	if SpeedConnection then SpeedConnection:Disconnect() end
	if SpeedBV then SpeedBV:Destroy() SpeedBV = nil end

	if on then
		if SpeedMode == "WalkSpeed" then
			SpeedConnection = RunService.Heartbeat:Connect(function()
				local h = GetHum()
				if h then h.WalkSpeed = SpeedVal end
			end)
		elseif SpeedMode == "CFrame" then
			SpeedConnection = RunService.Heartbeat:Connect(function()
				local root = GetRoot()
				local h = GetHum()
				if root and h and h.MoveDirection.Magnitude > 0 then
					root.CFrame = root.CFrame + h.MoveDirection.Unit * (SpeedVal / 50)
				end
			end)
		elseif SpeedMode == "Velocity" then
			SpeedConnection = RunService.Heartbeat:Connect(function()
				local root = GetRoot()
				local h = GetHum()
				if root and h and h.MoveDirection.Magnitude > 0 then
					root.AssemblyLinearVelocity = h.MoveDirection.Unit * SpeedVal
				end
			end)
		elseif SpeedMode == "BodyMover" then
			local root = GetRoot()
			if root then
				SpeedBV = Make("BodyVelocity", {
					MaxForce = Vector3.new(math.huge, 0, math.huge),
					Velocity = Vector3.zero, P = 1000
				}, root)
				SpeedConnection = RunService.Heartbeat:Connect(function()
					local h = GetHum()
					if h and h.MoveDirection.Magnitude > 0 then
						SpeedBV.Velocity = h.MoveDirection.Unit * SpeedVal
					else
						SpeedBV.Velocity = Vector3.zero
					end
				end)
			end
		end
		Notify("AM Hub", "速度已开启: " .. SpeedMode, 2)
	end
end

-- ==================================================
-- ESP（输入名字过滤）
-- ==================================================
local function ClearESP()
	for _, o in pairs(ESPObjects) do if o then o:Destroy() end end
	ESPObjects = {}
end

local function UpdateESP()
	ClearESP()
	if not ESPEnabled then return end
	for _, model in pairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name:lower():find(ESPChainName:lower()) then
			local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
			if root then
				local bg = Make("BillboardGui", {
					Size = UDim2.new(0, 120, 0, 40),
					StudsOffset = Vector3.new(0, 3, 0),
					AlwaysOnTop = true, Adornee = root
				}, root)
				Make("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(255, 0, 0),
					BackgroundTransparency = 0.3,
					Text = "⛓️ " .. model.Name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14, Font = Enum.Font.GothamBold
				}, bg)
				table.insert(ESPObjects, bg)
			end
		end
	end
end

-- ==================================================
-- GUI 构建
-- ==================================================
local ScreenGui = Make("ScreenGui", {
	Name = "AM_Chain_Hub", ResetOnSpawn = false, IgnoreGuiInset = true
}, PlayerGui)

-- 悬浮球
local AMButton = Make("TextButton", {
	Name = "AMButton", Size = UDim2.fromOffset(FLOAT_SIZE, FLOAT_SIZE),
	Position = UDim2.new(0, 18, 0.5, -29),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
	Text = "AM", TextColor3 = Color3.fromRGB(20, 20, 20),
	TextSize = 19, Font = Enum.Font.GothamBold,
	AutoButtonColor = false, Active = true, ZIndex = 100
}, ScreenGui)
Corner(AMButton, 100)
local AMStroke = Make("UIStroke", {Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, AMButton)
local AMGrad = Make("UIGradient", {Color = Rainbow}, AMStroke)

-- 主菜单
local Menu = Make("Frame", {
	Name = "Menu", Size = UDim2.fromOffset(MENU_WIDTH, MENU_HEIGHT),
	Position = UDim2.new(0, 88, 0.5, -MENU_HEIGHT/2),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
	Visible = false, Active = true, ZIndex = 10
}, ScreenGui)
Corner(Menu, 16)
local MenuStroke = Make("UIStroke", {Thickness = 3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, Menu)
local MenuGrad = Make("UIGradient", {Color = Rainbow}, MenuStroke)

-- 标题
local Header = Make("Frame", {
	Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Active = true, ZIndex = 20
}, Menu)
local Title = Make("TextLabel", {
	Size = UDim2.new(1, -55, 1, 0), Position = UDim2.fromOffset(15, 0),
	BackgroundTransparency = 1, Text = "AM Hub - CHAIN",
	TextColor3 = Color3.fromRGB(20, 20, 20), TextSize = 21,
	Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21
}, Header)
local CloseBtn = Make("TextButton", {
	Size = UDim2.fromOffset(38, 38), Position = UDim2.new(1, -43, 0, 5),
	BackgroundTransparency = 1, Text = "×", TextColor3 = Color3.fromRGB(30, 30, 30),
	TextSize = 27, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 30
}, Header)
CloseBtn.MouseButton1Click:Connect(function() Menu.Visible = false end)

-- 左侧分类栏
local CatBar = Make("ScrollingFrame", {
	Size = UDim2.new(0, 85, 1, -58), Position = UDim2.fromOffset(6, 52),
	BackgroundColor3 = Color3.fromRGB(245, 245, 245), BorderSizePixel = 0,
	ZIndex = 15, ScrollBarThickness = 4, CanvasSize = UDim2.new(0, 0, 0, 0)
}, Menu)
Corner(CatBar, 11)
local CatLayout = Make("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, CatBar)
CatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	CatBar.CanvasSize = UDim2.new(0, 0, 0, CatLayout.AbsoluteContentSize.Y + 10)
end)

-- 右侧内容
local Content = Make("ScrollingFrame", {
	Size = UDim2.new(1, -100, 1, -58), Position = UDim2.fromOffset(94, 52),
	BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
	ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150), ZIndex = 15
}, Menu)
local ConLayout = Make("UIListLayout", {Padding = UDim.new(0, 7), HorizontalAlignment = Enum.HorizontalAlignment.Center}, Content)
ConLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Content.CanvasSize = UDim2.fromOffset(0, ConLayout.AbsoluteContentSize.Y + 15)
end)

-- UI 工厂
local function ClearContent()
	for _, o in ipairs(Content:GetChildren()) do
		if not o:IsA("UIListLayout") then o:Destroy() end
	end
	Content.CanvasPosition = Vector2.zero
end

local function Section(text)
	local l = Make("TextLabel", {
		Size = UDim2.new(1, -10, 0, 30), BackgroundTransparency = 1,
		Text = text, TextColor3 = Color3.fromRGB(20, 20, 20),
		TextSize = 17, Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 20
	}, Content)
	return l
end

local function Button(text, cb)
	local b = Make("TextButton", {
		Size = UDim2.new(1, -10, 0, 42), BackgroundColor3 = Color3.fromRGB(245, 245, 245),
		BorderSizePixel = 0, Text = text, TextColor3 = Color3.fromRGB(25, 25, 25),
		TextSize = 14, Font = Enum.Font.Gotham, ZIndex = 20
	}, Content)
	Corner(b, 9)
	Stroke(b, Color3.fromRGB(220, 220, 220), 1)
	if cb then b.MouseButton1Click:Connect(cb) end
	return b
end

local function Toggle(text, getState, setState)
	local btn = Make("TextButton", {
		Size = UDim2.new(1, -10, 0, 42), BorderSizePixel = 0,
		TextSize = 14, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 20
	}, Content)
	Corner(btn, 9)
	local function Refresh()
		if getState() then
			btn.Text = text .. "    ● 开启"
			btn.TextColor3 = Color3.fromRGB(0, 140, 80)
			btn.BackgroundColor3 = Color3.fromRGB(235, 250, 240)
		else
			btn.Text = text .. "    ○ 关闭"
			btn.TextColor3 = Color3.fromRGB(50, 50, 50)
			btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
		end
	end
	Refresh()
	btn.MouseButton1Click:Connect(function()
		setState(not getState())
		Refresh()
	end)
	return btn
end

local function Slider(text, min, max, getVal, setVal)
	local holder = Make("Frame", {
		Size = UDim2.new(1, -10, 0, 60), BackgroundColor3 = Color3.fromRGB(245, 245, 245),
		BorderSizePixel = 0, ZIndex = 20
	}, Content)
	Corner(holder, 9)
	local label = Make("TextLabel", {
		Size = UDim2.new(1, -16, 0, 24), Position = UDim2.fromOffset(8, 3),
		BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(30, 30, 30),
		TextSize = 13, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21
	}, holder)
	local bar = Make("Frame", {
		Size = UDim2.new(1, -20, 0, 7), Position = UDim2.fromOffset(10, 38),
		BackgroundColor3 = Color3.fromRGB(215, 215, 215), BorderSizePixel = 0, ZIndex = 21
	}, holder)
	Corner(bar, 10)
	local fill = Make("Frame", {
		Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		BorderSizePixel = 0, ZIndex = 22
	}, bar)
	Corner(fill, 10)
	local knob = Make("Frame", {
		Size = UDim2.fromOffset(15, 15), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35), BorderSizePixel = 0, ZIndex = 23
	}, bar)
	Corner(knob, 20)

	local dragging = false
	local function SetValue(v)
		v = math.clamp(v, min, max)
		local p = (v - min) / (max - min)
		fill.Size = UDim2.new(p, 0, 1, 0)
		knob.Position = UDim2.new(p, 0, 0.5, 0)
		label.Text = text .. " : " .. math.floor(v)
		setVal(v)
	end
	local function Update(input)
		local x = input.Position.X - bar.AbsolutePosition.X
		SetValue(min + (max - min) * math.clamp(x / bar.AbsoluteSize.X, 0, 1))
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true Update(i)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
			Update(i)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	SetValue(getVal())
	return holder
end

-- 输入框
local function Input(text, placeholder, callback)
	local holder = Make("Frame", {
		Size = UDim2.new(1, -10, 0, 42), BackgroundColor3 = Color3.fromRGB(245, 245, 245),
		BorderSizePixel = 0, ZIndex = 20
	}, Content)
	Corner(holder, 9)
	local box = Make("TextBox", {
		Size = UDim2.new(1, -10, 1, 0), Position = UDim2.fromOffset(5, 0),
		BackgroundTransparency = 1, Text = "", PlaceholderText = placeholder,
		TextColor3 = Color3.fromRGB(20, 20, 20), PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		TextSize = 13, Font = Enum.Font.Gotham, ZIndex = 21
	}, holder)
	box.FocusLost:Connect(function(enter)
		if enter and callback then callback(box.Text) end
	end)
	return holder
end

-- ==================================================
-- 页面
-- ==================================================
local function ShowMain()
	ClearContent()
	Section("飞行（触屏滑动）")
	Toggle("飞行", function() return Flying end, function(v)
		if v then StartFlight() else StopFlight() end
	end)
	Slider("飞行速度", 10, 200, function() return FlightSpeed end, function(v) FlightSpeed = v end)
	Button("停止飞行", StopFlight)
	Section("移动")
	Toggle("穿墙（强化）", function() return Noclip end, SetNoclip)

	Section("速度模式")
	local modes = {"WalkSpeed", "CFrame", "Velocity", "BodyMover"}
	for _, m in ipairs(modes) do
		Button("模式: " .. m, function()
			SpeedMode = m
			if SpeedEnabled then SetSpeed(true) end
			Notify("AM Hub", "速度模式: " .. m, 2)
		end)
	end
	Toggle("速度", function() return SpeedEnabled end, SetSpeed)
	Slider("速度值", 16, 300, function() return SpeedVal end, function(v) SpeedVal = v end)
end

local function ShowESP()
	ClearContent()
	Section("ESP - 链条")
	Input("链条名字过滤", "输入链条名字...", function(text)
		ESPChainName = text
		UpdateESP()
	end)
	Toggle("ESP 显示", function() return ESPEnabled end, function(v)
		ESPEnabled = v
		if v then UpdateESP() else ClearESP() end
	end)
	Button("刷新ESP", function() if ESPEnabled then UpdateESP() end end)
end

local function ShowAuto()
	ClearContent()
	Section("自动系统")
	Toggle("自动QTE（砸链条）", function() return AutoQTE_Enabled end, function(v)
		AutoQTE_Enabled = v
		Notify("AM Hub", v and "自动QTE已开启" or "自动QTE已关闭", 2)
	end)
	Toggle("自动避险（爆炸/尖叫）", function() return AutoEvade end, function(v)
		AutoEvade = v
		Notify("AM Hub", v and "自动避险已开启" or "自动避险已关闭", 2)
	end)
	Section("状态")
	Button("链条攻击中: " .. (ChainAttacking and "是" or "否"))
	Button("链条尖叫中: " .. (ChainScreaming and "是" or "否"))
	Button("爆炸位置: " .. (ChainExplosionPos and "已记录" or "无"))
	Button("重置状态", function()
		ChainAttacking = false
		ChainScreaming = false
		ChainExplosionPos = nil
		Notify("AM Hub", "状态已重置", 2)
	end)
end

local function ShowAnti()
	ClearContent()
	Section("反检测")
	Toggle("反踢出 (AntiKick)", function() return AntiKick end, function(v)
		AntiKick = v
		Notify("AM Hub", v and "AntiKick 已开启" or "AntiKick 已关闭", 2)
	end)
	Toggle("反检测 (AntiDetect)", function() return AntiDetect end, function(v)
		AntiDetect = v
		Notify("AM Hub", v and "AntiDetect 已开启" or "AntiDetect 已关闭", 2)
	end)
	Slider("动作延迟(秒)", 0.05, 1, function() return ActionDelay end, function(v) ActionDelay = v end)
	Button("重新启动反检测", function()
		StartAntiDetect()
	end)
	Section("信息")
	Button("QQ群: " .. QQ_GROUP)
	Button("退出AM", function()
		StopFlight()
		SetNoclip(false)
		SetSpeed(false)
		ClearESP()
		ScreenGui:Destroy()
	end)
end

-- ==================================================
-- 分类
-- ==================================================
local Categories = {"飞行/移动", "ESP", "自动", "反检测"}
local Pages = {
	["飞行/移动"] = ShowMain,
	["ESP"] = ShowESP,
	["自动"] = ShowAuto,
	["反检测"] = ShowAnti,
}
local CatBtns = {}

local function SelectCat(name)
	for k, b in pairs(CatBtns) do
		if k == name then
			b.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
			b.TextColor3 = Color3.fromRGB(10, 10, 10)
		else
			b.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
			b.TextColor3 = Color3.fromRGB(90, 90, 90)
		end
	end
	if Pages[name] then Pages[name]() end
end

for i, name in ipairs(Categories) do
	local b = Make("TextButton", {
		Size = UDim2.new(1, -10, 0, 36), BackgroundColor3 = Color3.fromRGB(245, 245, 245),
		BorderSizePixel = 0, Text = name, TextSize = 12, Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(90, 90, 90), AutoButtonColor = false, ZIndex = 20
	}, CatBar)
	Corner(b, 8)
	CatBtns[name] = b
	b.MouseButton1Click:Connect(function() SelectCat(name) end)
end

-- ==================================================
-- 拖动
-- ==================================================
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true dragStart = i.Position startPos = Menu.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if not dragging then return end
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - dragStart
		Menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- 悬浮球拖动+点击
local btnDrag, btnStart, btnMoved
AMButton.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		btnDrag = true btnMoved = false btnStart = i.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if not btnDrag then return end
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
		local d = i.Position - btnStart
		if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then btnMoved = true end
		AMButton.Position = UDim2.new(0, 18 + d.X, 0.5, -29 + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
		if btnDrag and not btnMoved then
			Menu.Visible = not Menu.Visible
			if Menu.Visible then SelectCat("飞行/移动") end
		end
		btnDrag = false
	end
end)

-- ==================================================
-- 流光
-- ==================================================
local Rot = 0
RunService.RenderStepped:Connect(function(dt)
	Rot = (Rot + dt * 100) % 360
	AMGrad.Rotation = Rot
	MenuGrad.Rotation = Rot
end)

-- ==================================================
-- 初始化
-- ==================================================
StartAntiDetect()
SelectCat("飞行/移动")

Notify("AM Hub - CHAIN", "已加载！QQ群: " .. QQ_GROUP, 4)

-- 角色重生
LocalPlayer.CharacterAdded:Connect(function()
	wait(1)
	if Flying then StopFlight() end
	if Noclip then SetNoclip(true) end
	if SpeedEnabled then SetSpeed(true) end
end)
