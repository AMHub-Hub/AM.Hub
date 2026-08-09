--//===============================================================\\
--||  San Aurie · 全能Hub（皮脚本风格）
--||  功能: 刷钱 | 战斗(自瞄/ESP) | 传送 | 载具 | 互动
--||  悬浮窗可收可开 · 按 K 开关 · 适配手机/PC
--\\===============================================================//

local Players = game:GetService("Players")
local RunS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Cam = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============ 等待角色 ============
if not LP.Character or not LP.Character:FindFirstChild("Humanoid") then
	LP.CharacterAdded:Wait()
end
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

-- ============ 屏幕GUI ============
local Gui = Instance.new("ScreenGui")
Gui.Name = "SanAurie_Hub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LP:WaitForChild("PlayerGui")

-- ============ 主悬浮窗 ============
local Win = Instance.new("Frame", Gui)
Win.Name = "MainWindow"
Win.Size = UDim2.new(0, 340, 0, 460)
Win.Position = UDim2.new(0.5, -170, 0.5, -230)
Win.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Win.BorderColor3 = Color3.fromRGB(0, 200, 255)
Win.BorderSizePixel = 2
Win.Active = true
Win.Draggable = true
Win.Visible = true

-- 标题栏
local Title = Instance.new("TextLabel", Win)
Title.Size = UDim2.new(1, -35, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
Title.Text = "⚡ San Aurie · 全能Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold

-- 收起/展开按钮
local ToggleBtn = Instance.new("TextButton", Win)
ToggleBtn.Size = UDim2.new(0, 33, 0, 30)
ToggleBtn.Position = UDim2.new(1, -34, 0, 1)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "—"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.SourceSansBold

-- 收起后迷你按钮
local MiniBtn = Instance.new("TextButton", Gui)
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 10, 0, 10)
MiniBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
MiniBtn.Text = "⚡"
MiniBtn.TextColor3 = Color3.new(1, 1, 1)
MiniBtn.TextScaled = true
MiniBtn.Visible = false
MiniBtn.Active = true
MiniBtn.Draggable = true

local collapsed = false
ToggleBtn.MouseButton1Click:Connect(function()
	collapsed = not collapsed
	if collapsed then
		Win.Size = UDim2.new(0, 340, 0, 32)
		ToggleBtn.Text = "+"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		MiniBtn.Visible = true
	else
		Win.Size = UDim2.new(0, 340, 0, 460)
		ToggleBtn.Text = "—"
		ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		MiniBtn.Visible = false
	end
end)

MiniBtn.MouseButton1Click:Connect(function()
	collapsed = false
	Win.Size = UDim2.new(0, 340, 0, 460)
	ToggleBtn.Text = "—"
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	MiniBtn.Visible = false
end)

-- ============ Tab 按钮 ============
local TabNames = {"刷钱", "战斗", "传送", "载具", "互动"}
local TabBtns = {}
local TabPages = {}

for i, name in ipairs(TabNames) do
	local btn = Instance.new("TextButton", Win)
	btn.Size = UDim2.new(0.2, -4, 0, 32)
	btn.Position = UDim2.new((i-1)*0.2, 2, 0, 35)
	btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(30, 30, 42)
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSansBold
	TabBtns[name] = btn

	local page = Instance.new("ScrollingFrame", Win)
	page.Size = UDim2.new(0.96, 0, 0, 380)
	page.Position = UDim2.new(0.02, 0, 0, 72)
	page.BackgroundTransparency = 1
	page.Visible = (i == 1)
	page.Name = name .. "Page"
	page.ScrollBarThickness = 4
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 800)
	TabPages[name] = page
end

local function SwitchTab(name)
	for n, p in pairs(TabPages) do p.Visible = (n == name) end
	for n, b in pairs(TabBtns) do
		b.BackgroundColor3 = (n == name) and Color3.fromRGB(0, 150, 220) or Color3.fromRGB(30, 30, 42)
	end
end

for name, btn in pairs(TabBtns) do
	btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- 快捷键 K 开关整个GUI
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.K then
		Gui.Enabled = not Gui.Enabled
	end
end)

-- ============ 通用UI组件 ============
local PageY = {}

local function Label(parent, text)
	PageY[parent] = PageY[parent] or 0
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(0.95, 0, 0, 22)
	lbl.Position = UDim2.new(0.02, 0, 0, PageY[parent])
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(200, 220, 255)
	lbl.TextScaled = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.SourceSans
	PageY[parent] = PageY[parent] + 24
	return lbl
end

local function Btn(parent, text, color, callback)
	PageY[parent] = PageY[parent] or 0
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0.95, 0, 0, 34)
	btn.Position = UDim2.new(0.02, 0, 0, PageY[parent])
	btn.BackgroundColor3 = color or Color3.fromRGB(0, 130, 200)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSansBold
	btn.MouseButton1Click:Connect(function() pcall(callback) end)
	PageY[parent] = PageY[parent] + 38
	return btn
end

local function Tgl(parent, text, callback)
	PageY[parent] = PageY[parent] or 0
	local on = false
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0.95, 0, 0, 34)
	btn.Position = UDim2.new(0.02, 0, 0, PageY[parent])
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	btn.Text = "⚪ " .. text .. ": 关"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSansBold
	btn.MouseButton1Click:Connect(function()
		on = not on
		btn.Text = (on and "🔵 " or "⚪ ") .. text .. ": " .. (on and "开" or "关")
		btn.BackgroundColor3 = on and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(80, 80, 90)
		pcall(function() callback(on) end)
	end)
	PageY[parent] = PageY[parent] + 38
	return btn
end

local function Sld(parent, labelText, min, max, default, onChange)
	PageY[parent] = PageY[parent] or 0
	local val = default
	local lbl = Label(parent, labelText .. ": " .. default)
	local step = math.max(1, math.ceil((max - min) / 20))

	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.95, 0, 0, 18)
	frame.Position = UDim2.new(0.02, 0, 0, PageY[parent])
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	frame.BorderSizePixel = 0

	local fill = Instance.new("Frame", frame)
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
	fill.BorderSizePixel = 0

	local bL = Instance.new("TextButton", parent)
	bL.Size = UDim2.new(0.45, 0, 0, 24)
	bL.Position = UDim2.new(0.02, 0, 0, PageY[parent] + 20)
	bL.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
	bL.Text = "+"
	bL.TextColor3 = Color3.new(1, 1, 1)
	bL.TextScaled = true

	local bR = Instance.new("TextButton", parent)
	bR.Size = UDim2.new(0.45, 0, 0, 24)
	bR.Position = UDim2.new(0.5, 2, 0, PageY[parent] + 20)
	bR.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	bR.Text = "-"
	bR.TextColor3 = Color3.new(1, 1, 1)
	bR.TextScaled = true

	local function update(nv)
		val = math.clamp(nv, min, max)
		fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		lbl.Text = labelText .. ": " .. val
		pcall(function() onChange(val) end)
	end

	bL.MouseButton1Click:Connect(function() update(val + step) end)
	bR.MouseButton1Click:Connect(function() update(val - step) end)

	PageY[parent] = PageY[parent] + 48
	return val
end

--//==========================================================\\
--//                     💰 刷钱页
--\\==========================================================//
local P_Farm = TabPages["刷钱"]

Label(P_Farm, "💰 自动刷钱")

Tgl(P_Farm, "自动捡钱", function(on)
	_G.AutoCollect = on
	if on then
		task.spawn(function()
			while _G.AutoCollect and task.wait(0.3) do
				pcall(function()
					if not LP.Character or not HRP then return end
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj:IsA("Part") or obj:IsA("MeshPart") then
							local n = obj.Name:lower()
							if n:find("cash") or n:find("money") or n:find("orb") or n:find("diamond") then
								if (obj.Position - HRP.Position).Magnitude < 50 then
									HRP.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
									task.wait(0.1)
								end
							end
						end
					end
				end)
			end
		end)
	end
end)

Tgl(P_Farm, "自动ATM", function(on)
	_G.AutoATM = on
	if on then
		task.spawn(function()
			while _G.AutoATM and task.wait(2) do
				pcall(function()
					local atmEvents = {"ATMUse", "UseATM", "ATMInteract", "RobATM", "ATM"}
					for _, ename in ipairs(atmEvents) do
						local ev = RS:FindFirstChild(ename) or (RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(ename))
						if ev and ev:IsA("RemoteEvent") then
							ev:FireServer()
						end
					end
				end)
			end
		end)
	end
end)

Tgl(P_Farm, "自动洗钱", function(on)
	_G.AutoWash = on
	if on then
		task.spawn(function()
			while _G.AutoWash and task.wait(5) do
				pcall(function()
					local washEvents = {"WashMoney", "LaunderMoney", "MoneyWash", "CleanMoney", "Wash"}
					for _, ename in ipairs(washEvents) do
						local ev = RS:FindFirstChild(ename) or (RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(ename))
						if ev and ev:IsA("RemoteEvent") then
							ev:FireServer()
						end
					end
				end)
			end
		end)
	end
end)

Tgl(P_Farm, "卖假钻石", function(on)
	_G.SellFakeDiamond = on
	if on then
		task.spawn(function()
			while _G.SellFakeDiamond and task.wait(1.5) do
				pcall(function()
					local sellEvents = {"SellDiamond", "FakeDiamondSell", "SellItem", "BlackMarketSell", "Sell"}
					for _, ename in ipairs(sellEvents) do
						local ev = RS:FindFirstChild(ename) or (RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(ename))
						if ev and ev:IsA("RemoteEvent") then
							pcall(function() ev:FireServer("Diamond", 1) end)
							pcall(function() ev:FireServer("FakeDiamond", 1) end)
						end
						local func = RS:FindFirstChild(ename) or (RS:FindFirstChild("Functions") and RS.Functions:FindFirstChild(ename))
						if func and func:IsA("RemoteFunction") then
							pcall(function() func:InvokeServer("Diamond", 1) end)
						end
					end
				end)
			end
		end)
	end
end)

Label(P_Farm, "购买次数:")
local buyCount = Sld(P_Farm, "购买次数", 1, 50, 5, function(v) _G.BuyCount = v end)
_G.BuyCount = 5

Btn(P_Farm, "💎 购买假钻石 x" .. tostring(_G.BuyCount), Color3.fromRGB(0, 120, 200), function()
	pcall(function()
		local buyEvents = {"BuyItem", "PurchaseItem", "BlackMarketBuy", "BuyDiamond", "Buy"}
		for _, ename in ipairs(buyEvents) do
			local ev = RS:FindFirstChild(ename) or (RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(ename))
			if ev and ev:IsA("RemoteEvent") then
				for i = 1, _G.BuyCount do
					pcall(function() ev:FireServer("FakeDiamond", 1) end)
					pcall(function() ev:FireServer("Diamond", 1) end)
				end
			end
		end
	end)
end)

Sld(P_Farm, "移动速度(%)", 0, 300, 100, function(v)
	pcall(function() Hum.WalkSpeed = 16 * v / 100 end)
end)

Tgl(P_Farm, "超级跳", function(on)
	pcall(function()
		if on then Hum.JumpPower = 120 else Hum.JumpPower = 50 end
	end)
end)

Tgl(P_Farm, "Noclip(穿墙)", function(on) _G.Noclip = on end)

RunS.Stepped:Connect(function()
	if _G.Noclip and Char then
		pcall(function()
			for _, v in ipairs(Char:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		end)
	end
end)

--//==========================================================\\
--//                     🎯 战斗页
--\\==========================================================//
local P_Combat = TabPages["战斗"]

Label(P_Combat, "🎯 自瞄 & 战斗")

Tgl(P_Combat, "启用自瞄", function(on) _G.Aimbot = on end)

Sld(P_Combat, "自瞄距离(米)", 0, 1000, 300, function(v) _G.AimDist = v end)
_G.AimDist = 300

Sld(P_Combat, "FOV视角", 70, 120, 90, function(v)
	pcall(function() Cam.FieldOfView = v end)
end)

Tgl(P_Combat, "自瞄头部", function(on) _G.AimHead = on end)
_G.AimHead = true

Tgl(P_Combat, "自瞄轮胎", function(on) _G.AimTire = on end)

Tgl(P_Combat, "墙后不瞄", function(on) _G.WallCheck = on end)
_G.WallCheck = true

Tgl(P_Combat, "自动开火", function(on) _G.AutoShoot = on end)

Sld(P_Combat, "开火速率(ms)", 10, 500, 100, function(v) _G.FireRate = v end)
_G.FireRate = 100

-- 自瞄逻辑
local function GetClosestTarget()
	local closest = nil
	local minDist = _G.AimDist or 300
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			local dist = (hrp.Position - HRP.Position).Magnitude
			if dist < minDist then
				local valid = true
				if _G.WallCheck then
					local ray = Ray.new(Cam.CFrame.Position, (hrp.Position - Cam.CFrame.Position).Unit * dist)
					local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Char, plr.Character})
					if hit then valid = false end
				end
				if valid then
					minDist = dist
					closest = plr
				end
			end
		end
	end
	return closest
end

RunS.RenderStepped:Connect(function()
	if not _G.Aimbot then return end
	pcall(function()
		local target = GetClosestTarget()
		if target and target.Character then
			local aimPart = _G.AimHead and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
			if not aimPart then aimPart = target.Character.HumanoidRootPart end
			if aimPart then
				local screenPos, onScreen = Cam:WorldToScreenPoint(aimPart.Position)
				if onScreen then
					Mouse.X = screenPos.X
					Mouse.Y = screenPos.Y
					if _G.AutoShoot then
						UIS:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
						task.wait((_G.FireRate or 100) / 1000)
						UIS:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
					end
				end
			end
		end
	end)
end)

Label(P_Combat, "")
Label(P_Combat, "🔫 武器增强")

Tgl(P_Combat, "无限子弹", function(on) _G.InfAmmo = on end)
Tgl(P_Combat, "无后坐力", function(on) _G.NoRecoil = on end)
Tgl(P_Combat, "快速射击", function(on) _G.RapidFire = on end)

RunS.Heartbeat:Connect(function()
	if not _G.InfAmmo and not _G.NoRecoil and not _G.RapidFire then return end
	pcall(function()
		local tool = nil
		if LP.Character then tool = LP.Character:FindFirstChildOfClass("Tool") end
		if not tool then return end
		local cfg = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Config")
		local items = cfg and cfg:GetChildren() or tool:GetChildren()
		for _, v in ipairs(items) do
			local n = v.Name:lower()
			if _G.InfAmmo then
				if n:find("ammo") or n:find("bullet") then
					if v:IsA("IntValue") or v:IsA("NumberValue") then v.Value = 9999 end
				end
			end
			if _G.NoRecoil then
				if n:find("recoil") then
					if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 0 end
				end
			end
			if _G.RapidFire then
				if n:find("firerate") or n:find("firespeed") or n:find("fire_delay") then
					if v:IsA("NumberValue") or v:IsA("IntValue") then
						v.Value = math.max(0.05, v.Value * 0.3)
					end
				end
			end
		end
	end)
end)

Label(P_Combat, "")
Label(P_Combat, "👁️ ESP")

Tgl(P_Combat, "玩家ESP", function(on) _G.ESP = on end)
Tgl(P_Combat, "显示名字", function(on) _G.ESPName = on end)
_G.ESPName = true
Tgl(P_Combat, "显示距离", function(on) _G.ESPDist = on end)
Tgl(P_Combat, "显示血量", function(on) _G.ESPHP = on end)
Tgl(P_Combat, "只显示警察", function(on) _G.ESPCop = on end)

-- ESP 绘制
local espObjects = {}

local function ClearESP()
	for _, v in pairs(espObjects) do
		if v and v.Destroy then pcall(function() v:Destroy() end) end
	end
	espObjects = {}
end

RunS.RenderStepped:Connect(function()
	pcall(function()
		if not _G.ESP then
			if #espObjects > 0 then ClearESP() end
			return
		end
		-- 清理断开的
		for i = #espObjects, 1, -1 do
			local obj = espObjects[i]
			if not obj or not obj.Parent or not obj.Adornee or not obj.Adornee.Parent then
				if obj and obj.Destroy then pcall(function() obj:Destroy() end) end
				table.remove(espObjects, i)
			end
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local showPlr = true
				if _G.ESPCop then
					local team = plr.Team and plr.Team.Name or ""
					local tl = team:lower()
					if not tl:find("police") and not tl:find("cop") and not tl:find("sheriff") then
						showPlr = false
					end
				end
				if showPlr then
					local hrp = plr.Character.HumanoidRootPart
					local screenPos, onScreen = Cam:WorldToScreenPoint(hrp.Position)
					if onScreen then
						local existing = nil
						for _, v in ipairs(espObjects) do
							if v.Adornee == hrp then existing = v; break end
						end
						if not existing then
							local bb = Instance.new("BillboardGui")
							bb.Size = UDim2.new(0, 120, 0, 50)
							bb.Adornee = hrp
							bb.AlwaysOnTop = true
							bb.Parent = Gui
							local txt = Instance.new("TextLabel", bb)
							txt.Size = UDim2.new(1, 0, 1, 0)
							txt.BackgroundTransparency = 1
							txt.TextColor3 = Color3.fromRGB(255, 50, 50)
							txt.TextScaled = true
							txt.Font = Enum.Font.SourceSansBold
							txt.Name = "ESPText"
							table.insert(espObjects, bb)
							existing = bb
						end
						local txt = existing:FindFirstChild("ESPText")
						if txt then
							local dist = math.floor((hrp.Position - HRP.Position).Magnitude)
							local info = plr.Name
							if _G.ESPDist then info = info .. " [" .. dist .. "m]" end
							if _G.ESPHP and plr.Character:FindFirstChildOfClass("Humanoid") then
								info = info .. " HP:" .. math.floor(plr.Character.Humanoid.Health)
							end
							txt.Text = info
						end
					end
				end
			end
		end
	end)
end)

--//==========================================================\\
--//                     🗺️ 传送页
--\\==========================================================//
local P_Tp = TabPages["传送"]

Label(P_Tp, "🗺️ 传送地点")

-- 传送点定义
local TpSpots = {
	{name = "🏦 大银行", keywords = {"BigBank", "MainBank", "Bank", "大银行", "bank"}},
	{name = "🏧 小银行/ATM区", keywords = {"SmallBank", "ATMArea", "LocalBank", "小银行", "atm"}},
	{name = "🎮 游戏厅", keywords = {"Arcade", "GameHall", "GameRoom", "游戏厅", "游戏中心", "arcade"}},
	{name = "🏠 出生点", keywords = {"Spawn", "Lobby", "出生点", "spawn"}},
	{name = "🚗 车库", keywords = {"Garage", "CarShop", "车库", "车店", "garage"}},
	{name = "🏥 医院", keywords = {"Hospital", "Clinic", "医院", "hospital"}},
	{name = "🏪 便利店", keywords = {"Store", "Shop", "Convenience", "便利店", "store"}},
	{name = "💎 黑市/钻石店", keywords = {"BlackMarket", "DiamondShop", "黑市", "钻石", "blackmarket"}},
	{name = "👮 警察局", keywords = {"PoliceStation", "Police", "警局", "police"}},
	{name = "✈️ 机场", keywords = {"Airport", "Airstrip", "机场", "airport"}},
}

Btn(P_Tp, "🔍 扫描地图传送点", Color3.fromRGB(150, 0, 200), function()
	pcall(function()
		local found = 0
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Part") or obj:IsA("MeshPart") then
				local n = obj.Name:lower()
				for _, spot in ipairs(TpSpots) do
					for _, kw in ipairs(spot.keywords) do
						if n:find(kw:lower()) then
							obj.BrickColor = BrickColor.new("Bright red")
							obj.Transparency = 0.4
							found = found + 1
							break
						end
					end
				end
			end
		end
		-- 扫描RS传送事件
		for _, ev in ipairs(RS:GetDescendants()) do
			if ev:IsA("RemoteEvent") or ev:IsA("RemoteFunction") then
				local n = ev.Name:lower()
				if n:find("teleport") or n:find("tp") or n:find("warp") or n:find("spawn") then
					found = found + 1
				end
			end
		end
	end)
end)

Label(P_Tp, "— 快速传送 —")

for _, spot in ipairs(TpSpots) do
	Btn(P_Tp, spot.name, Color3.fromRGB(0, 100, 180), function()
		pcall(function()
			local teleported = false
			-- 方式1: 找地图里的对应Part
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					local n = obj.Name:lower()
					for _, kw in ipairs(spot.keywords) do
						if n:find(kw:lower()) then
							HRP.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
							teleported = true
							break
						end
					end
					if teleported then break end
				end
			end
			-- 方式2: 调RemoteEvent
			if not teleported then
				for _, ev in ipairs(RS:GetDescendants()) do
					if ev:IsA("RemoteEvent") then
						local n = ev.Name:lower()
						if n:find("teleport") or n:find("warp") or n:find("tpspot") or n:find("tp") then
							for _, kw in ipairs(spot.keywords) do
								pcall(function() ev:FireServer(kw) end)
								pcall(function() ev:FireServer(spot.name) end)
							end
						end
					end
				end
			end
		end)
	end)
end

Label(P_Tp, "")
Label(P_Tp, "— 自定义传送 —")

Btn(P_Tp, "📍 传送到准星位置", Color3.fromRGB(200, 100, 0), function()
	pcall(function()
		local unit = Cam.CFrame.LookVector
		local ray = Ray.new(Cam.CFrame.Position, unit * 500)
		local hit, pos = workspace:FindPartOnRay(ray, Char)
		if hit and pos then
			HRP.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
		else
			HRP.CFrame = CFrame.new(HRP.Position + unit * 50)
		end
	end)
end)

Btn(P_Tp, "⬆️ 升高50米", Color3.fromRGB(80, 80, 160), function()
	pcall(function() HRP.CFrame = HRP.CFrame + Vector3.new(0, 50, 0) end)
end)

Btn(P_Tp, "⬇️ 回到地面", Color3.fromRGB(80, 80, 160), function()
	pcall(function()
		local ray = Ray.new(HRP.Position, Vector3.new(0, -500, 0))
		local hit, pos = workspace:FindPartOnRay(ray, Char)
		if hit and pos then
			HRP.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
		end
	end)
end)

--//==========================================================\\
--//                     🚗 载具页
--\\==========================================================//
local P_Veh = TabPages["载具"]

Label(P_Veh, "🚗 载具控制")

Tgl(P_Veh, "无限油量", function(on) _G.InfFuel = on end)
Tgl(P_Veh, "载具无敌", function(on) _G.VehGod = on end)

Sld(P_Veh, "载具速度(%)", 100, 500, 200, function(v) _G.VehSpeed = v end)
_G.VehSpeed = 200

Sld(P_Veh, "载具加速度", 1, 100, 30, function(v) _G.VehAccel = v end)
_G.VehAccel = 30

Tgl(P_Veh, "飞行载具", function(on) _G.FlyVeh = on end)

RunS.Heartbeat:Connect(function()
	pcall(function()
		if not LP.Character then return end
		local veh = nil
		local seat = Hum.SeatPart
		if seat then veh = seat.Parent end
		if not veh then
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("VehicleSeat") and (v.Position - HRP.Position).Magnitude < 10 then
					veh = v.Parent
					break
				end
			end
		end
		if not veh then return end

		if _G.InfFuel then
			for _, child in ipairs(veh:GetDescendants()) do
				if child:IsA("NumberValue") or child:IsA("IntValue") then
					local n = child.Name:lower()
					if n:find("fuel") then
						child.Value = child.MaxValue or 100
					end
				end
			end
		end

		if _G.VehGod then
			for _, part in ipairs(veh:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end

		if _G.VehSpeed and _G.VehSpeed > 100 then
			for _, child in ipairs(veh:GetDescendants()) do
				if child:IsA("NumberValue") or child:IsA("IntValue") then
					local n = child.Name:lower()
					if n:find("maxspeed") or n:find("topspeed") or n:find("speed") then
						child.Value = child.Value * (_G.VehSpeed / 100)
					end
					if n:find("accel") or n:find("engine") then
						child.Value = (_G.VehAccel or 30)
					end
				end
			end
		end

		if _G.FlyVeh then
			local root = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
			if root then
				local move = Vector3.zero
				if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + Cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - Cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - Cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + Cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
				if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
				root.AssemblyLinearVelocity = move * 80
			end
		end
	end)
end)

Label(P_Veh, "")
Btn(P_Veh, "🚗 传送到最近载具", Color3.fromRGB(0, 120, 80), function()
	pcall(function()
		local closest, minDist = nil, 200
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("VehicleSeat") then
				local d = (v.Position - HRP.Position).Magnitude
				if d < minDist then
					minDist = d
					closest = v
				end
			end
		end
		if closest then
			HRP.CFrame = closest.CFrame + Vector3.new(0, 5, 0)
		end
	end)
end)

--//==========================================================\\
--//                     🤝 互动页
--\\==========================================================//
local P_Inter = TabPages["互动"]

Label(P_Inter, "🤝 自动互动")

Sld(P_Inter, "互动距离(米)", 0, 100, 30, function(v) _G.InteractDist = v end)
_G.InteractDist = 30

Sld(P_Inter, "互动速度(%)", 0, 100, 100, function(v) _G.InteractSpeed = v end)
_G.InteractSpeed = 100

Tgl(P_Inter, "自动互动(持续)", function(on)
	_G.AutoInteract = on
	if on then
		task.spawn(function()
			local waitTime = math.max(0.1, (100 - (_G.InteractSpeed or 100)) / 100 + 0.1)
			while _G.AutoInteract and task.wait(waitTime) do
				pcall(function()
					for _, prompt in ipairs(workspace:GetDescendants()) do
						if prompt:IsA("ProximityPrompt") then
							local part = prompt.Parent
							if part and part:IsA("BasePart") then
								local dist = (part.Position - HRP.Position).Magnitude
								if dist <= (_G.InteractDist or 30) then
									prompt:InputHoldBegin()
									task.wait(prompt.HoldDuration + 0.1)
									prompt:InputHoldEnd()
								end
							end
						end
					end
					for _, cd in ipairs(workspace:GetDescendants()) do
						if cd:IsA("ClickDetector") then
							local part = cd.Parent
							if part and part:IsA("BasePart") then
								local dist = (part.Position - HRP.Position).Magnitude
								if dist <= (_G.InteractDist or 30) then
									fireclickdetector(cd)
								end
							end
						end
					end
				end)
			end
		end)
	end
end)

Tgl(P_Inter, "快速互动(瞬间)", function(on) _G.InstantInteract = on end)

RunS.Heartbeat:Connect(function()
	if not _G.InstantInteract then return end
	pcall(function()
		for _, prompt in ipairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				local part = prompt.Parent
				if part and part:IsA("BasePart") then
					local dist = (part.Position - HRP.Position).Magnitude
					if dist <= (_G.InteractDist or 30) then
						prompt.HoldDuration = 0
						prompt.MaxActivationDistance = 100
						prompt:InputHoldBegin()
						task.wait(0.05)
						prompt:InputHoldEnd()
					end
				end
			end
		end
	end)
end)

Label(P_Inter, "")
Label(P_Inter, "— 手动互动 —")

Btn(P_Inter, "🔓 互动最近目标", Color3.fromRGB(180, 120, 0), function()
	pcall(function()
		local closest, minDist = nil, (_G.InteractDist or 30)
		for _, prompt in ipairs(workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				local part = prompt.Parent
				if part and part:IsA("BasePart") then
					local dist = (part.Position - HRP.Position).Magnitude
					if dist < minDist then
						minDist = dist
						closest = prompt
					end
				end
			end
		end
		if closest then
			closest.HoldDuration = 0
			closest:InputHoldBegin()
			task.wait(0.05)
			closest:InputHoldEnd()
		end
	end)
end)

Btn(P_Inter, "🛒 打开黑市商店", Color3.fromRGB(120, 0, 120), function()
	pcall(function()
		local shopEvents = {"OpenShop", "BlackMarket", "OpenBlackMarket", "ShopOpen", "Shop"}
		for _, ename in ipairs(shopEvents) do
			local ev = RS:FindFirstChild(ename) or (RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild(ename))
			if ev and ev:IsA("RemoteEvent") then ev:FireServer() end
		end
	end)
end)

Label(P_Inter, "")
Label(P_Inter, "— 辅助 —")

Tgl(P_Inter, "无限体力", function(on) _G.InfStamina = on end)

RunS.Heartbeat:Connect(function()
	pcall(function()
		if _G.InfStamina and Hum then
			local stamina = Hum:FindFirstChild("Stamina") or (LP.Character and LP.Character:FindFirstChild("Stamina"))
			if not stamina and LP.Character then
				for _, v in ipairs(LP.Character:GetDescendants()) do
					if v:IsA("NumberValue") or v:IsA("IntValue") then
						if v.Name:lower():find("stamina") or v.Name:lower():find("energy") then
							stamina = v
							break
						end
					end
				end
			end
			if stamina and (stamina:IsA("NumberValue") or stamina:IsA("IntValue")) then
				stamina.Value = stamina.MaxValue or 100
			end
		end
	end)
end)

Tgl(P_Inter, "无限饥饿", function(on) _G.InfHunger = on end)

RunS.Heartbeat:Connect(function()
	pcall(function()
		if not _G.InfHunger or not LP.Character then return end
		for _, v in ipairs(LP.Character:GetDescendants()) do
			if v:IsA("NumberValue") or v:IsA("IntValue") then
				local n = v.Name:lower()
				if n:find("hunger") or n:find("food") or n:find("thirst") or n:find("water") then
					v.Value = v.MaxValue or 100
				end
			end
		end
	end)
end)

Btn(P_Inter, "🏠 回出生点", Color3.fromRGB(100, 100, 100), function()
	pcall(function()
		local found = false
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local n = obj.Name:lower()
				if n:find("spawn") or n:find("lobby") or n:find("出生") then
					HRP.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
					found = true
					break
				end
			end
		end
		if not found then
			HRP.CFrame = CFrame.new(0, 5, 0)
		end
	end)
end)

--//==========================================================\\
--//                     ⚙️ 全局保护
--\\==========================================================//

-- 防踢保护
pcall(function()
	local mt = getrawmetatable(game)
	if mt then
		setreadonly(mt, false)
		local oldNamecall = mt.__namecall
		mt.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			local args = {...}
			if method == "Kick" or method == "kick" then return nil end
			local sn = tostring(self)
			if sn:find("Ban") or sn:find("ban") then return nil end
			return oldNamecall(self, ...)
		end)
		setreadonly(mt, true)
	end
end)

-- 防掉线心跳
task.spawn(function()
	while task.wait(60) do
		pcall(function()
			if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
				LP.CharacterAdded:Wait()
				Char = LP.Character
				Hum = Char:WaitForChild("Humanoid")
				HRP = Char:WaitForChild("HumanoidRootPart")
			end
		end)
	end
end)

-- 初始化
SwitchTab("刷钱")
print("[San Aurie Hub] 已加载 | 按 K 开关 | 皮脚本风格")
print("[传送] 大银行/小银行/游戏厅/出生点/车库/医院/便利店/黑市/警局/机场")
print("[提示] 刷钱/自瞄依赖游戏RemoteEvent名称，如失效请用Hydroxide抓包更新")
