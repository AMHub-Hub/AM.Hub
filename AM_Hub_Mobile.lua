--[[
    AM Hub v5.0 - 中文深色风格
    作者: AM官方制作
    QQ群: 179051448
    修复: 飞行 + ESP 功能
    全部功能真开关
]]

-- ============ 防重复 ============
if _G.AM_V5 then return end
_G.AM_V5 = true

-- ============ 服务 ============
local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")
local LP = P.LocalPlayer

-- ============ 安全获取 ============
local function GetChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetHum()
    local c = GetChar()
    return c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid", 10)
end

local function GetHRP()
    local c = GetChar()
    return c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart", 10)
end

-- ============ 原始值缓存 ============
local OV = {}
local OVC = false
local function Cache()
    if OVC then return end
    pcall(function()
        local h = GetHum()
        OV.W = h.WalkSpeed
        OV.J = h.JumpPower
        OV.G = WS.Gravity
        OV.FOV = WS.CurrentCamera.FieldOfView
        OV.B = WS:FindFirstChildOfClass("Lighting").Brightness
        OVC = true
    end)
end

-- ============ 创建 GUI ============
local SG = Instance.new("ScreenGui")
SG.Name = "AM_Hub_v5"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = CG

-- ============ 悬浮按钮 ============
local FB = Instance.new("TextButton")
FB.Name = "AM_Float"
FB.Size = UDim2.new(0, 52, 0, 52)
FB.Position = UDim2.new(1, -62, 1, -62)
FB.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FB.Text = "AM"
FB.TextColor3 = Color3.fromRGB(255, 255, 255)
FB.TextSize = 16
FB.Font = Enum.Font.GothamBold
FB.Draggable = true
FB.Active = true
FB.Parent = SG

local FBC = Instance.new("UICorner")
FBC.CornerRadius = UDim.new(1, 0)
FBC.Parent = FB

local FBS = Instance.new("UIStroke")
FBS.Thickness = 2
FBS.Parent = FB

spawn(function()
    while _G.AM_V5 do
        pcall(function() FBS.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)
        wait(0.1)
    end
end)

-- ============ 主面板 ============
local MF = Instance.new("Frame")
MF.Name = "MainPanel"
MF.Size = UDim2.new(0, 560, 0, 360)
MF.Position = UDim2.new(0.5, -280, 0.5, -180)
MF.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MF.Visible = false
MF.Active = true
MF.Draggable = true
MF.Parent = SG

local MFC = Instance.new("UICorner")
MFC.CornerRadius = UDim.new(0, 10)
MFC.Parent = MF

local MFS = Instance.new("UIStroke")
MFS.Thickness = 2
MFS.Color = Color3.fromRGB(60, 60, 60)
MFS.Parent = MF

spawn(function()
    while _G.AM_V5 do
        pcall(function() MFS.Color = Color3.fromHSV(tick() % 5 / 5, 0.7, 1) end)
        wait(0.1)
    end
end)

-- ============ 标题栏 ============
local TB = Instance.new("Frame")
TB.Size = UDim2.new(1, 0, 0, 32)
TB.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TB.Parent = MF

local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 10)
TBC.Parent = TB

local TL = Instance.new("TextLabel")
TL.Size = UDim2.new(0.7, 0, 1, 0)
TL.Position = UDim2.new(0, 10, 0, 0)
TL.BackgroundTransparency = 1
TL.Text = "AM Hub v5.0  |  QQ群: 179051448"
TL.TextColor3 = Color3.fromRGB(255, 255, 255)
TL.TextSize = 13
TL.Font = Enum.Font.GothamBold
TL.TextXAlignment = Enum.TextXAlignment.Left
TL.Parent = TB

local XB = Instance.new("TextButton")
XB.Size = UDim2.new(0, 28, 0, 28)
XB.Position = UDim2.new(1, -32, 0, 2)
XB.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
XB.Text = "X"
XB.TextColor3 = Color3.fromRGB(255, 255, 255)
XB.TextSize = 13
XB.Font = Enum.Font.GothamBold
XB.Parent = TB

local XBC = Instance.new("UICorner")
XBC.CornerRadius = UDim.new(0, 6)
XBC.Parent = XB

XB.MouseButton1Click:Connect(function()
    MF.Visible = false
end)

-- ============ 左侧 Tab 栏 ============
local TBar = Instance.new("Frame")
TBar.Size = UDim2.new(0, 110, 1, -36)
TBar.Position = UDim2.new(0, 0, 0, 34)
TBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TBar.Parent = MF

local TBarC = Instance.new("UICorner")
TBarC.CornerRadius = UDim.new(0, 8)
TBarC.Parent = TBar

local TBarL = Instance.new("UIListLayout")
TBarL.SortOrder = Enum.SortOrder.LayoutOrder
TBarL.Padding = UDim.new(0, 2)
TBarL.Parent = TBar

-- ============ 内容容器 ============
local ContentParent = Instance.new("Frame")
ContentParent.Size = UDim2.new(1, -118, 1, -42)
ContentParent.Position = UDim2.new(0, 116, 0, 38)
ContentParent.BackgroundTransparency = 1
ContentParent.Parent = MF

local TabBtns = {}
local TabFrames = {}
local CurTab = nil

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = (icon or "") .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Parent = TBar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local cf = Instance.new("ScrollingFrame")
    cf.Size = UDim2.new(1, 0, 1, 0)
    cf.BackgroundTransparency = 1
    cf.ScrollBarThickness = 4
    cf.CanvasSize = UDim2.new(0, 0, 0, 0)
    cf.Visible = false
    cf.Parent = ContentParent

    local cl = Instance.new("UIListLayout")
    cl.SortOrder = Enum.SortOrder.LayoutOrder
    cl.Padding = UDim.new(0, 3)
    cl.Parent = cf

    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(TabFrames) do f.Visible = false end
        for _, b in pairs(TabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        cf.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CurTab = name
        spawn(function()
            wait(0.05)
            pcall(function()
                cf.CanvasSize = UDim2.new(0, 0, 0, cl.AbsoluteContentSize.Y + 8)
            end)
        end)
    end)

    TabBtns[name] = btn
    TabFrames[name] = cf
    return cf
end

-- ============ UI 组件 ============
local function AddToggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 28)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    f.Parent = parent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, 40, 0, 18)
    tb.Position = UDim2.new(1, -46, 0.5, -9)
    tb.BackgroundColor3 = default and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(80, 80, 80)
    tb.Text = default and "ON" or "OFF"
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.TextSize = 10
    tb.Font = Enum.Font.GothamBold
    tb.Parent = f

    local tbc = Instance.new("UICorner")
    tbc.CornerRadius = UDim.new(0, 9)
    tbc.Parent = tb

    local state = default or false
    tb.MouseButton1Click:Connect(function()
        state = not state
        tb.Text = state and "ON" or "OFF"
        tb.BackgroundColor3 = state and Color3.fromRGB(50, 160, 50) or Color3.fromRGB(80, 80, 80)
        pcall(function() callback(state) end)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 46)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    f.Parent = parent

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 6)
    fc.Parent = f

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 16)
    lbl.Position = UDim2.new(0, 6, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -12, 0, 20)
    box.Position = UDim2.new(0, 6, 0, 20)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    box.Text = tostring(default)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.Parent = f

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = box

    box.FocusLost:Connect(function()
        local v = tonumber(box.Text) or default
        v = math.max(min, math.min(max, v))
        box.Text = tostring(v)
        lbl.Text = text .. ": " .. v
        pcall(function() callback(v) end)
    end)
end

local function AddButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.Gotham
    b.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = b

    b.MouseButton1Click:Connect(function()
        pcall(function() callback() end)
    end)
end

local function AddLabel(parent, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(160, 160, 160)
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
end

-- ============ 悬浮按钮控制 ============
FB.MouseButton1Click:Connect(function()
    MF.Visible = not MF.Visible
    if MF.Visible and CurTab then
        spawn(function()
            wait(0.05)
            pcall(function()
                local cf = TabFrames[CurTab]
                local lay = cf:FindFirstChildOfClass("UIListLayout")
                if cf and lay then
                    cf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8)
                end
            end)
        end)
    end
end)

-- ========================================================
--                     首页 Tab
-- ========================================================
local TabHome = CreateTab("首页", "🏠")

spawn(function()
    wait(0.5)
    pcall(function()
        local c = GetChar()
        local h = GetHum()
        AddLabel(TabHome, "━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 60))
        AddLabel(TabHome, "用户名: " .. LP.Name, Color3.fromRGB(200, 200, 200))
        AddLabel(TabHome, "显示名: " .. LP.DisplayName, Color3.fromRGB(200, 200, 200))
        AddLabel(TabHome, "用户ID: " .. LP.UserId, Color3.fromRGB(200, 200, 200))
        AddLabel(TabHome, "账号年龄: " .. LP.AccountAge .. "天", Color3.fromRGB(200, 200, 200))
        AddLabel(TabHome, "━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 60))
        local cf = TabFrames["首页"]
        if cf then
            local lay = cf:FindFirstChildOfClass("UIListLayout")
            if lay then cf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8) end
        end
    end)
end)

spawn(function()
    local cnt = 0
    local t0 = tick()
    wait(1)
    local fpsLbl = Instance.new("TextLabel")
    fpsLbl.Size = UDim2.new(1, -4, 0, 20)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS: ..."
    fpsLbl.TextColor3 = Color3.fromRGB(100, 255, 100))
    fpsLbl.TextSize = 11
    fpsLbl.Font = Enum.Font.GothamBold
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    fpsLbl.Parent = TabHome
    pcall(function()
        local cf = TabFrames["首页"]
        if cf then
            local lay = cf:FindFirstChildOfClass("UIListLayout")
            if lay then cf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8) end
        end
    end)
    while _G.AM_V5 do
        cnt = cnt + 1
        if tick() - t0 >= 1 then
            fpsLbl.Text = "FPS: " .. cnt
            cnt = 0
            t0 = tick()
        end
        wait()
    end
end)

AddLabel(TabHome, "━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 60))
AddLabel(TabHome, "温馨提示: 玩挂要有心，不要乱打人 ❤️", Color3.fromRGB(255, 150, 200))
AddLabel(TabHome, "最大贡献者: AM独自制作", Color3.fromRGB(255, 215, 0))
AddLabel(TabHome, "QQ群: 179051448", Color3.fromRGB(100, 200, 255))

-- ========================================================
--                     通用 Tab
-- ========================================================
local TabGen = CreateTab("通用", "⚙")

-- 移速
local spdOn, spdVal = false, 16
AddToggle(TabGen, "启用移速修改", false, function(v)
    Cache()
    spdOn = v
    pcall(function() GetHum().WalkSpeed = v and spdVal or (OV.W or 16) end)
end)

AddSlider(TabGen, "移速值", 1, 600, 16, function(v)
    spdVal = v
    if spdOn then pcall(function() GetHum().WalkSpeed = v end) end
end)

-- 跳力
local jmpOn, jmpVal = false, 50
AddToggle(TabGen, "启用跳力修改", false, function(v)
    Cache()
    jmpOn = v
    pcall(function() GetHum().JumpPower = v and jmpVal or (OV.J or 50) end)
end)

AddSlider(TabGen, "跳力值", 1, 600, 50, function(v)
    jmpVal = v
    if jmpOn then pcall(function() GetHum().JumpPower = v end) end
end)

-- 重力
local grvOn, grvVal = false, 196
AddToggle(TabGen, "启用重力修改", false, function(v)
    Cache()
    grvOn = v
    WS.Gravity = v and grvVal or (OV.G or 196.2)
end)

AddSlider(TabGen, "重力值", 1, 500, 196, function(v)
    grvVal = v
    if grvOn then WS.Gravity = v end
end)

-- ★★★ 飞行 - 修复版 ★★★
local FlyOn = false
local FlySpeed = 60
local FlyBV = nil
local FlyBG = nil
local FlyConn = nil

local function StopFly()
    FlyOn = false
    if FlyConn then pcall(function() FlyConn:Disconnect() end) FlyConn = nil end
    if FlyBV then pcall(function() FlyBV:Destroy() end) FlyBV = nil end
    if FlyBG then pcall(function() FlyBG:Destroy() end) FlyBG = nil end
    pcall(function() GetHum().PlatformStand = false end)
end

local function StartFly()
    local hrp = GetHRP()
    if not hrp then return end
    -- BodyVelocity
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "AM_FlyBV"
    FlyBV.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyBV.Velocity = Vector3.new(0, 0, 0)
    FlyBV.Parent = hrp
    -- BodyGyro
    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "AM_FlyBG"
    FlyBG.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyBG.P = 3000
    FlyBG.Parent = hrp
    -- PlatformStand
    pcall(function() GetHum().PlatformStand = true end)
    -- Heartbeat
    FlyConn = RS.Heartbeat:Connect(function()
        if not FlyOn then return end
        if not FlyBV or not FlyBV.Parent then return end
        local cam = WS.CurrentCamera
        if not cam then return end
        local mv = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            local lv = cam.CFrame.LookVector
            mv = mv + Vector3.new(lv.X, 0, lv.Z).Unit
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            local lv = cam.CFrame.LookVector
            mv = mv - Vector3.new(lv.X, 0, lv.Z).Unit
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            mv = mv - cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            mv = mv + cam.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            mv = mv + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            mv = mv - Vector3.new(0, 1, 0)
        end
        if FlyBG and FlyBG.Parent and hrp then
            FlyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
        end
        local spd = mv.Magnitude > 0 and mv.Unit or Vector3.new(0, 0, 0)
        FlyBV.Velocity = spd * FlySpeed
    end)
end

AddToggle(TabGen, "飞行模式", false, function(v)
    if v then
        FlyOn = true
        StartFly()
    else
        StopFly()
    end
end)

AddSlider(TabGen, "飞行速度", 10, 500, 60, function(v)
    FlySpeed = v
end)

-- 无限跳
local IJConn = nil
AddToggle(TabGen, "无限跳跃", false, function(v)
    if v then
        IJConn = UIS.JumpRequest:Connect(function()
            pcall(function()
                local h = GetHum()
                if h and h:GetState() ~= Enum.HumanoidStateType.Dead then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
    else
        if IJConn then pcall(function() IJConn:Disconnect() end) IJConn = nil end
    end
end)

-- ★★★ 穿墙 - 修复版 ★★★
local NCConn = nil
local NCOri = {}

AddToggle(TabGen, "穿墙模式", false, function(v)
    if v then
        pcall(function()
            local char = GetChar()
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    NCOri[p] = p.CanCollide
                    p.CanCollide = false
                end
            end
            NCConn = RS.Stepped:Connect(function()
                local char2 = LP.Character
                if not char2 then return end
                for _, p in pairs(char2:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false
                    end
                end
            end)
        end)
    else
        if NCConn then pcall(function() NCConn:Disconnect() end) NCConn = nil end
        for p, o in pairs(NCOri) do
            if p and p.Parent then p.CanCollide = o end
        end
        NCOri = {}
    end
end)

-- 隐身
AddToggle(TabGen, "隐身透明", false, function(v)
    pcall(function()
        for _, p in pairs(GetChar():GetDescendants()) do
            if p:IsA("BasePart") then
                p.Transparency = v and 1 or 0
            elseif p:IsA("Decal") or p:IsA("Texture") then
                p.Transparency = v and 1 or 0
            end
        end
    end)
end)

-- ========================================================
--                     视觉 Tab
-- ========================================================
local TabVis = CreateTab("视觉", "👁")

AddSlider(TabVis, "FOV视野", 50, 120, 70, function(v)
    Cache()
    pcall(function() WS.CurrentCamera.FieldOfView = v end)
end)

AddToggle(TabVis, "夜视模式", false, function(v)
    Cache()
    pcall(function()
        WS:FindFirstChildOfClass("Lighting").Brightness = v and 5 or (OV.B or 2)
    end)
end)

AddToggle(TabVis, "去除雾效", false, function(v)
    pcall(function()
        WS:FindFirstChildOfClass("Lighting").FogEnd = v and 999999 or 1000
    end)
end)

AddToggle(TabVis, "全图明亮", false, function(v)
    pcall(function()
        local L = WS:FindFirstChildOfClass("Lighting")
        L.Brightness = v and 10 or 2
        L.Ambient = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(127, 127, 127)
    end)
end)

-- ========================================================
--                     ★★★ ESP Tab - 修复版 ★★★
-- ========================================================
local TabESP = CreateTab("ESP", "🎯")

local ESPC = nil
local ESPFolder = nil
local ESPOn = false

local function MakeESPForPlayer(plr)
    if not ESPOn then return end
    if plr == LP then return end
    pcall(function()
        if not plr.Character then return end
        local head = plr.Character:FindFirstChild("Head")
        if not head then return end
        if not ESPFolder then return end
        -- 不要重复创建
        if ESPFolder:FindFirstChild(plr.Name) then return end
        local bg = Instance.new("BillboardGui")
        bg.Name = plr.Name
        bg.Adornee = head
        bg.Size = UDim2.new(0, 140, 0, 28)
        bg.AlwaysOnTop = true
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.Parent = ESPFolder
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.Parent = bg
        -- 初始文字
        local myHead = LP.Character and LP.Character:FindFirstChild("Head")
        if myHead then
            local d = math.floor((head.Position - myHead.Position).Magnitude)
            lbl.Text = plr.Name .. " [" .. d .. "m]"
        else
            lbl.Text = plr.Name
        end
        lbl.TextColor3 = Color3.fromHSV((tick() + (plr.UserId % 100)) % 5 / 5, 1, 1)
    end)
end

local function UpdateESP()
    if not ESPOn or not ESPFolder then return end
    pcall(function()
        local myChar = LP.Character
        local myHead = myChar and myChar:FindFirstChild("Head")
        for _, child in pairs(ESPFolder:GetChildren()) do
            if child:IsA("BillboardGui") then
                local plr = P:FindFirstChild(child.Name)
                local head = plr and plr.Character and plr.Character:FindFirstChild("Head")
                if not plr or not head then
                    child:Destroy()
                else
                    local lbl = child:FindFirstChildOfClass("TextLabel")
                    if lbl and myHead then
                        local d = math.floor((head.Position - myHead.Position).Magnitude)
                        lbl.Text = plr.Name .. " [" .. d .. "m]"
                        lbl.TextColor3 = Color3.fromHSV((tick() + (plr.UserId % 100)) % 5 / 5, 1, 1)
                    end
                end
            end
        end
        -- 新建
        for _, plr in pairs(P:GetPlayers()) do
            if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Head") then
                if not ESPFolder:FindFirstChild(plr.Name) then
                    MakeESPForPlayer(plr)
                end
            end
        end
    end)
end

AddToggle(TabESP, "玩家名称ESP", false, function(v)
    ESPOn = v
    if v then
        ESPFolder = ESPFolder or Instance.new("Folder")
        ESPFolder.Name = "AM_ESP"
        ESPFolder.Parent = CG
        -- 立即扫描一次
        for _, plr in pairs(P:GetPlayers()) do
            MakeESPForPlayer(plr)
        end
        ESPC = RS.RenderStepped:Connect(function()
            UpdateESP()
        end)
        -- 玩家加入/离开
        P.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                wait(1)
                MakeESPForPlayer(plr)
            end)
        end)
    else
        if ESPC then pcall(function() ESPC:Disconnect() end) ESPC = nil end
        if ESPFolder then pcall(function() ESPFolder:Destroy() end) ESPFolder = nil end
    end
end)

AddToggle(TabESP, "XRay穿墙透视", false, function(v)
    pcall(function()
        for _, plr in pairs(P:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = v and 0.5 or 0
                    end
                end
            end
        end
    end)
end)

-- ========================================================
--                     玩家 Tab
-- ========================================================
local TabPlr = CreateTab("玩家", "👥")

AddLabel(TabPlr, "输入目标用户名:", Color3.fromRGB(180, 180, 180))

local TgtInp = Instance.new("TextBox")
TgtInp.Size = UDim2.new(1, -4, 0, 26)
TgtInp.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TgtInp.Text = ""
TgtInp.PlaceholderText = "玩家名字..."
TgtInp.TextColor3 = Color3.fromRGB(255, 255, 255)
TgtInp.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
TgtInp.TextSize = 12
TgtInp.Font = Enum.Font.Gotham
TgtInp.Parent = TabPlr

local tic = Instance.new("UICorner")
tic.CornerRadius = UDim.new(0, 4)
tic.Parent = TgtInp

local TgtPlr = nil
TgtInp.FocusLost:Connect(function()
    local nm = TgtInp.Text
    for _, p in pairs(P:GetPlayers()) do
        if p.Name:lower() == nm:lower() or p.DisplayName:lower() == nm:lower() then
            TgtPlr = p
            pcall(function()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "AM脚本";
                    Text = "目标: " .. p.Name;
                    Duration = 2;
                })
            end)
            break
        end
    end
end)

AddButton(TabPlr, "传送到目标", function()
    pcall(function()
        if TgtPlr and TgtPlr.Character and TgtPlr.Character:FindFirstChild("HumanoidRootPart") then
            GetHRP().CFrame = TgtPlr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end)

AddButton(TabPlr, "目标传送给我", function()
    pcall(function()
        if TgtPlr and TgtPlr.Character and TgtPlr.Character:FindFirstChild("HumanoidRootPart") then
            TgtPlr.Character.HumanoidRootPart.CFrame = GetHRP().CFrame + Vector3.new(0, 3, 0)
        end
    end)
end)

-- ========================================================
--                     娱乐 Tab
-- ========================================================
local TabFun = CreateTab("娱乐", "🎮")

AddButton(TabFun, "坐下", function()
    pcall(function() GetHum().Sit = true end)
end)

AddButton(TabFun, "跳一下", function()
    pcall(function() GetHum():ChangeState(Enum.HumanoidStateType.Jumping) end)
end)

AddButton(TabFun, "倒地", function()
    pcall(function() GetHum():ChangeState(Enum.HumanoidStateType.Physics) end)
end)

local SpinC = nil
local SpinS = 50
AddToggle(TabFun, "自动旋转", false, function(v)
    if v then
        SpinC = RS.Heartbeat:Connect(function()
            pcall(function()
                local hrp = GetHRP()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinS), 0)
            end)
        end)
    else
        if SpinC then pcall(function() SpinC:Disconnect() end) SpinC = nil end
    end
end)

AddSlider(TabFun, "旋转速度", 10, 200, 50, function(v) SpinS = v end)

-- ========================================================
--                     设置 Tab
-- ========================================================
local TabSet = CreateTab("设置", "⚙")

AddLabel(TabSet, "━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 60))
AddLabel(TabSet, "QQ群: 179051448", Color3.fromRGB(100, 200, 255))
AddLabel(TabSet, "━━━━━━━━━━━━━━━━━━━━", Color3.fromRGB(60, 60, 60))

AddButton(TabSet, "📋 复制QQ群号", function()
    pcall(function()
        (setclipboard or function() end)("179051448")
        game.StarterGui:SetCore("SendNotification", {
            Title = "AM脚本";
            Text = "QQ群号已复制: 179051448";
            Duration = 2;
        })
    end)
end)

AddToggle(TabSet, "🔴 全局总开关(关所有)", true, function(v)
    if not v then
        -- 飞行
        StopFly()
        -- 穿墙
        if NCConn then pcall(function() NCConn:Disconnect() end) NCConn = nil end
        for p, o in pairs(NCOri) do
            if p and p.Parent then p.CanCollide = o end
        end
        NCOri = {}
        -- 无限跳
        if IJConn then pcall(function() IJConn:Disconnect() end) IJConn = nil end
        -- ESP
        ESPOn = false
        if ESPC then pcall(function() ESPC:Disconnect() end) ESPC = nil end
        if ESPFolder then pcall(function() ESPFolder:Destroy() end) ESPFolder = nil end
        -- 旋转
        if SpinC then pcall(function() SpinC:Disconnect() end) SpinC = nil end
        -- 还原数值
        pcall(function()
            local h = GetHum()
            if OV.W then h.WalkSpeed = OV.W end
            if OV.J then h.JumpPower = OV.J end
            if OV.G then WS.Gravity = OV.G end
            if OV.FOV then WS.CurrentCamera.FieldOfView = OV.FOV end
            if OV.B then WS:FindFirstChildOfClass("Lighting").Brightness = OV.B end
        end)
    end
end)

AddButton(TabSet, "💀 彻底销毁脚本", function()
    _G.AM_V5 = false
    StopFly()
    if NCConn then pcall(function() NCConn:Disconnect() end) end
    if IJConn then pcall(function() IJConn:Disconnect() end) end
    if ESPC then pcall(function() ESPC:Disconnect() end) end
    if SpinC then pcall(function() SpinC:Disconnect() end) end
    if ESPFolder then pcall(function() ESPFolder:Destroy() end) end
    pcall(function() SG:Destroy() end)
end)

-- ============ 默认选首页 ============
spawn(function()
    wait(0.3)
    pcall(function()
        TabBtns["首页"].BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        TabBtns["首页"].TextColor3 = Color3.fromRGB(255, 255, 255)
        TabFrames["首页"].Visible = true
        CurTab = "首页"
        local cf = TabFrames["首页"]
        local lay = cf:FindFirstChildOfClass("UIListLayout")
        if lay then cf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 8) end
    end)
end)

-- ============ 完成通知 ============
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "AM Hub v5.0";
        Text = "加载完成 ✅ | 右下角AM按钮打开 | QQ群:179051448";
        Duration = 4;
    })
end)

print("[AM Hub v5.0] 加载完成 ✅")
print("[AM Hub] QQ群: 179051448")
print("[AM Hub] 飞行+ESP已修复")
