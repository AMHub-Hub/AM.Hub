
--// ============================================
--//  AM.Hub · 手机通用版
--//  全中文 / 无限跳 / FPS·Ping / 保存设置
--//  适配: Delta / Arceus X / Codex
--//  FE Safe
--// ============================================

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ws = workspace
local http = game:GetService("HttpService")

local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

------------------------------------------------
-- 保存设置（DataStore 用 HttpService 本地存档）
------------------------------------------------
local saveKey = "AM_Hub_Settings"
local defaultSettings = {
	walkspeed = 32,
	jumppower = 50,
	gravity = ws.Gravity,
	infjump = false,
	fly = false
}

local function loadSettings()
	local ok, data = pcall(function()
		return http:JSONDecode(readfile(saveKey))
	end)
	if ok and data then
		for k,v in pairs(data) do
			defaultSettings[k] = v
		end
	end
end

local function saveSettings()
	pcall(function()
		writefile(saveKey, http:JSONEncode(defaultSettings))
	end)
end

loadSettings()

------------------------------------------------
-- UI 框架
------------------------------------------------
local sg = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
sg.Name = "AM_Hub"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 460)
main.Position = UDim2.new(0, 20, 0, 80)
main.BackgroundColor3 = Color3.fromRGB(8,8,8)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

-- 彩虹边框
local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

task.spawn(function()
	local h = 0
	while rs.Heartbeat:Wait() do
		h = (h + 0.004) % 1
		stroke.Color = Color3.fromHSV(h, 1, 1)
	end
end)

-- 标题
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,32)
title.Text = "AM.Hub · 通用版"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

------------------------------------------------
-- 工具函数
------------------------------------------------
local y = 42
local function newBtn(text, cb)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,-20,0,30)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(18,18,18)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.MouseButton1Click:Connect(cb)
	y = y + 36
	return b
end

local function newSlider(name, min, max, def, cb)
	local lbl = Instance.new("TextLabel", main)
	lbl.Size = UDim2.new(1,-20,0,16)
	lbl.Position = UDim2.new(0,10,0,y)
	lbl.Text = name..": "..def
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12

	local box = Instance.new("TextBox", main)
	box.Size = UDim2.new(1,-20,0,24)
	box.Position = UDim2.new(0,10,0,y+18)
	box.Text = tostring(def)
	box.BackgroundColor3 = Color3.fromRGB(22,22,22)
	box.TextColor3 = Color3.new(1,1,1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 12

	box.FocusLost:Connect(function()
		local v = tonumber(box.Text)
		if v and v>=min and v<=max then
			lbl.Text = name..": "..v
			defaultSettings[name] = v
			saveSettings()
			cb(v)
		end
	end)
	y = y + 50
end

------------------------------------------------
-- 功能模块
------------------------------------------------

-- 移速
newSlider("移速", 16, 200, defaultSettings.walkspeed, function(v)
	hum.WalkSpeed = v
end)

-- 跳高
newSlider("跳高", 50, 300, defaultSettings.jumppower, function(v)
	hum.JumpPower = v
end)

-- 重力
newSlider("重力", 0, 500, defaultSettings.gravity, function(v)
	ws.Gravity = v
end)

-- 无限跳
local infJumpBtn = newBtn("无限跳: 关", function()
	defaultSettings.infjump = not defaultSettings.infjump
	infJumpBtn.Text = defaultSettings.infjump and "无限跳: 开" or "无限跳: 关"
	saveSettings()
end)
if defaultSettings.infjump then infJumpBtn.Text = "无限跳: 开" end

uis.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.Space and defaultSettings.infjump then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- 飞行
local flying = defaultSettings.fly
local bv
local flyBtn = newBtn("飞行: 关", function()
	flying = not flying
	defaultSettings.fly = flying
	flyBtn.Text = flying and "飞行: 开" or "飞行: 关"
	saveSettings()
	if flying then
		bv = Instance.new("BodyVelocity", hrp)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bv.Velocity = Vector3.zero
	else
		bv:Destroy()
	end
end)
if flying then flyBtn.Text = "飞行: 开" end

rs.Heartbeat:Connect(function()
	if flying and bv then
		local d = Vector3.zero
		if uis:IsKeyDown(Enum.KeyCode.W) then d += workspace.CurrentCamera.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.S) then d -= workspace.CurrentCamera.CFrame.LookVector end
		if uis:IsKeyDown(Enum.KeyCode.A) then d -= workspace.CurrentCamera.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.D) then d += workspace.CurrentCamera.CFrame.RightVector end
		if uis:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
		if uis:IsKeyDown(Enum.KeyCode.C) then d -= Vector3.yAxis end
		bv.Velocity = d * 60
	end
end)

------------------------------------------------
-- FPS / Ping 显示
------------------------------------------------
y = y + 10
local statLbl = Instance.new("TextLabel", main)
statLbl.Size = UDim2.new(1,-20,0,32)
statLbl.Position = UDim2.new(0,10,0,y)
statLbl.TextColor3 = Color3.fromRGB(150,255,150)
statLbl.BackgroundTransparency = 1
statLbl.Font = Enum.Font.Gotham
statLbl.TextSize = 12
statLbl.Text = "FPS: -- | Ping: --"

local fps = 0
local frames = 0
local last = tick()
rs.RenderStepped:Connect(function()
	frames += 1
	if tick() - last >= 1 then
		fps = frames
		frames = 0
		last = tick()
		local ping = math.floor((tick() - last) * 1000) -- 粗略
		statLbl.Text = "FPS: "..fps.." | Ping: "..ping.."ms"
	end
end)

------------------------------------------------
-- 其他脚本执行区
------------------------------------------------
y = y + 40
local box = Instance.new("TextBox", main)
box.Size = UDim2.new(1,-20,0,50)
box.Position = UDim2.new(0,10,0,y)
box.Text = "-- 在此粘贴其他脚本\n-- 例: loadstring(game:HttpGet('...'))()"
box.BackgroundColor3 = Color3.fromRGB(20,20,20)
box.TextColor3 = Color3.fromRGB(200,200,200)
box.Font = Enum.Font.Code
box.TextSize = 11
box.MultiLine = true
box.ClearTextOnFocus = false

newBtn("执行脚本", function()
	pcall(function()
		loadstring(box.Text)()
	end)
end)

------------------------------------------------
-- 初始化
------------------------------------------------
hum.WalkSpeed = defaultSettings.walkspeed
hum.JumpPower = defaultSettings.jumppower
ws.Gravity = defaultSettings.gravity

print("✅ AM.Hub 手机通用版已加载 | 中文 | 已保存设置")
