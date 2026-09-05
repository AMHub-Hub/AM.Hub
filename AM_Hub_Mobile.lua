-- ============================================================================
-- AM Hub Mobile 3.0 - 修复版 (飞行/跳高/锁定视角)
-- Delta Executor | 纯基础组件 | 不崩
-- ============================================================================
-- QQ群: 179051448
-- ============================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 30)

-- ===================== 全局状态 =====================
local FlyEnabled = false
local FlySpeed = 50
local FlyUpSpeed = 30          -- 升降速度（独立）
local FlyBodyVel = nil
local FlyBodyGyro = nil
local FlyConn = nil

-- 飞行输入（支持触屏 + 键盘双模式）
local FlyInput = {
    Forward = 0,   -- -1 到 1
    Right = 0,
    Up = 0,        -- 升降
}

local SpeedEnabled = false
local SpeedValue = 50
local JumpEnabled = false
local JumpValue = 100
local NoclipEnabled = false
local NoclipConn = nil

local LockCamEnabled = false
local OrigCamType = Camera.CameraType
local OrigCamSubject = Camera.CameraSubject
local LockCamConn = nil

local ESPEnabled = false
local ESPObjects = {}
local GodEnabled = false
local InfJumpEnabled = false
local AutoClickEnabled = false
local AutoClickConn = nil
local SpinEnabled = false
local SpinConn = nil
local SpinSpeed = 50

local FullBrightEnabled = false
local NoFogEnabled = false
local GravityEnabled = false
local GravityValue = 196.2

local AntiKickEnabled = true
local AntiDetectEnabled = true
local AntiKickConn = nil
local AntiDetectConn = nil

local FE_Enabled = false
local FE_FireEnabled = false
local FE_FireMoveEnabled = false
local FE_CrownEnabled = false
local FE_FirePart = nil
local FE_CrownPart = nil
local FE_Conn = nil

local ThrowEnabled = false
local ThrowPower = 200
local ThrowConn = nil

local MenuVisible = false
local CurrentCat = "主页"
local Categories = {"主页", "移动", "视角", "玩家", "世界", "高级"}

-- ===================== 工具函数 =====================
local function GetChar() return LocalPlayer.Character end
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
        StarterGui:SetCore("SendNotification", {Title=title, Text=text, Duration=dur})
    end)
end
local function Make(class, props, parent)
    local i = Instance.new(class)
    if props then
        for k,v in pairs(props) do pcall(function() i[k]=v end) end
    end
    if parent then i.Parent = parent end
    return i
end

-- ============================================================================
-- 【修复1】飞行系统 - 重写：方向 + 升降完全独立
-- ============================================================================
local function StartFly()
    local root = GetRoot()
    if not root then Notify("AM Hub","找不到角色",2) return end
    if FlyEnabled then return end
    FlyEnabled = true

    -- 确保角色能自由移动
    local hum = GetHum()
    if hum then hum.PlatformStand = true end

    FlyBodyVel = Make("BodyVelocity", {
        Velocity = Vector3.new(0,0,0),
        MaxForce = Vector3.new(math.huge, math.huge, math.huge),
        P = 5000
    }, root)

    FlyBodyGyro = Make("BodyGyro", {
        CFrame = root.CFrame,
        MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
        P = 9000,
        D = 100
    }, root)

    if FlyConn then FlyConn:Disconnect() end

    FlyConn = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end
        local root = GetRoot()
        local hum = GetHum()
        if not root or not hum then StopFly() return end

        -- 关键：用相机CFrame直接算方向，不依赖MoveDirection
        local camCF = Camera.CFrame
        local camForward = camCF.LookVector
        local camRight = camCF.RightVector
        -- 水平方向（去掉Y，避免抬头低头影响水平移动）
        camForward = Vector3.new(camForward.X, 0, camForward.Z).Unit
        camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit

        -- 计算速度：前后 + 左右 + 升降
        local vel = Vector3.new(0, 0, 0)
        vel = vel + camForward * FlyInput.Forward
        vel = vel + camRight * FlyInput.Right
        vel = vel + Vector3.new(0, 1, 0) * FlyInput.Up

        if vel.Magnitude > 0 then
            vel = vel.Unit * FlySpeed
        end

        FlyBodyVel.Velocity = vel
        FlyBodyGyro.CFrame = camCF
    end)

    Notify("AM Hub","飞行开启 | 前进/后退/左右/升降",3)
end

local function StopFly()
    if not FlyEnabled then return end
    FlyEnabled = false
    -- 重置输入
    FlyInput.Forward = 0
    FlyInput.Right = 0
    FlyInput.Up = 0
    -- 恢复
    local hum = GetHum()
    if hum then hum.PlatformStand = false end
    local root = GetRoot()
    if root then root.AssemblyLinearVelocity = Vector3.zero end
    if FlyBodyVel then FlyBodyVel:Destroy() FlyBodyVel = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    Notify("AM Hub","飞行关闭",2)
end

-- 设置飞行输入（供摇杆/按钮调用）
local function SetFlyInput(forward, right, up)
    FlyInput.Forward = forward or 0
    FlyInput.Right = right or 0
    FlyInput.Up = up or 0
end

-- ============================================================================
-- 【修复2】跳高 - 重写：JumpPower + JumpHeight 双设 + 状态刷新
-- ============================================================================
local function SetJump(enabled, value)
    JumpEnabled = enabled
    JumpValue = value or JumpValue
    local hum = GetHum()
    if not hum then return end

    if JumpEnabled then
        -- 两个属性都设（兼容新旧版Roblox）
        hum.JumpPower = JumpValue
        hum.JumpHeight = JumpValue / 10  -- JumpHeight = JumpPower/10 约等于
        -- 强制刷新状态，确保立即生效
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    else
        hum.JumpPower = 50
        hum.JumpHeight = 7.2
    end
    Notify("AM Hub", "跳高: " .. tostring(enabled) .. " | " .. tostring(JumpValue), 2)
end

-- 无限跳跃
local InfJumpConn = nil
local function SetInfiniteJump(enabled)
    InfJumpEnabled = enabled
    if InfJumpConn then InfJumpConn:Disconnect() end
    if InfJumpEnabled then
        InfJumpConn = UserInputService.JumpRequest:Connect(function()
            if not InfJumpEnabled then return end
            local hum = GetHum()
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        Notify("AM Hub","无限跳跃开启",2)
    else
        Notify("AM Hub","无限跳跃关闭",2)
    end
end

-- ============================================================================
-- 【修复3】锁定视角 - 重写：CameraSubject + CFrame 双保险
-- ============================================================================
local function SetLockCamera(enabled)
    LockCamEnabled = enabled
    if LockCamEnabled then
        -- 保存原始状态
        OrigCamType = Camera.CameraType
        OrigCamSubject = Camera.CameraSubject
        -- 锁定1：CameraType
        Camera.CameraType = Enum.CameraType.Scriptable
        -- 锁定2：每帧固定CFrame（防被覆盖）
        if LockCamConn then LockCamConn:Disconnect() end
        LockCamConn = RunService.RenderStepped:Connect(function()
            if not LockCamEnabled then return end
            -- 保持当前视角不动，忽略鼠标/触摸旋转
            local root = GetRoot()
            if root then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
            end
        end)
        Notify("AM Hub","锁定视角开启",2)
    else
        if LockCamConn then LockCamConn:Disconnect() LockCamConn = nil end
        Camera.CameraType = OrigCamType or Enum.CameraType.Custom
        Camera.CameraSubject = OrigCamSubject
        Notify("AM Hub","锁定视角关闭",2)
    end
end

-- ============================================================================
-- 移动系统
-- ============================================================================
local function SetSpeed(enabled, value)
    SpeedEnabled = enabled
    SpeedValue = value or SpeedValue
    local hum = GetHum()
    if hum then hum.WalkSpeed = SpeedEnabled and SpeedValue or 16 end
end

local function SetNoclip(enabled)
    NoclipEnabled = enabled
    if NoclipConn then NoclipConn:Disconnect() end
    if NoclipEnabled then
        NoclipConn = RunService.Stepped:Connect(function()
            local c = GetChar()
            if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end)
        Notify("AM Hub","穿墙开启",2)
    else
        Notify("AM Hub","穿墙关闭",2)
    end
end

-- ============================================================================
-- 反作弊
-- ============================================================================
local function StartAntiKick()
    if AntiKickConn then AntiKickConn:Disconnect() end
    AntiKickConn = RunService.Heartbeat:Connect(function()
        if not AntiKickEnabled then return end
        pcall(function()
            local mt = getrawmetatable and getrawmetatable(game)
            if mt then
                local oldnc = mt.__namecall
                if oldnc then
                    setreadonly(mt, false)
                    mt.__namecall = newcclosure(function(self, ...)
                        local m = getnamecallmethod and getnamecallmethod()
                        if m and (m:lower()=="kick" or m:lower()=="remove") then
                            if self == LocalPlayer or self == GetChar() then return nil end
                        end
                        return oldnc(self, ...)
                    end)
                    setreadonly(mt, true)
                end
            end
        end)
    end)
end

local function StartAntiDetect()
    if AntiDetectConn then AntiDetectConn:Disconnect() end
    AntiDetectConn = RunService.Stepped:Connect(function()
        if not AntiDetectEnabled then return end
        pcall(function()
            local c = GetChar()
            if c then
                for _,p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = true
                        p.Anchored = false
                    end
                end
            end
        end)
    end)
end

-- ============================================================================
-- FE系统
-- ============================================================================
local function ClearFE()
    if FE_FirePart then FE_FirePart:Destroy() FE_FirePart=nil end
    if FE_CrownPart then FE_CrownPart:Destroy() FE_CrownPart=nil end
    if FE_Conn then FE_Conn:Disconnect() FE_Conn=nil end
end

local function StartFE()
    if FE_Enabled then return end
    FE_Enabled = true
    local char = GetChar()
    local head = char and char:FindFirstChild("Head")
    if not head then Notify("AM Hub","找不到头部",2) return end

    if FE_FireEnabled then
        FE_FirePart = Make("Fire", {
            Size = 5, Heat = 5,
            Color = Color3.fromRGB(255,100,0),
            SecondaryColor = Color3.fromRGB(255,200,0)
        }, head)
    end

    if FE_CrownEnabled then
        FE_CrownPart = Make("Part", {
            Size = Vector3.new(1.5, 0.8, 1.5),
            Anchored = false, CanCollide = false,
            Transparency = 0.3, Material = Enum.Material.Neon,
            Color = Color3.fromRGB(255,215,0),
            Shape = Enum.PartType.Block
        }, head)
        local weld = Make("WeldConstraint", {}, FE_CrownPart)
        weld.Part0 = FE_CrownPart
        weld.Part1 = head
        FE_CrownPart.CFrame = head.CFrame * CFrame.new(0, 1.2, 0)
    end

    if FE_FireMoveEnabled then
        FE_Conn = RunService.Heartbeat:Connect(function()
            local root = GetRoot()
            if root and root.Velocity.Magnitude > 5 then
                local spark = Make("Fire", {
                    Size = 3, Heat = 3,
                    Color = Color3.fromRGB(255,150,0),
                    SecondaryColor = Color3.fromRGB(255,255,0)
                }, root)
                game:GetService("Debris"):AddItem(spark, 0.3)
            end
        end)
    end
    Notify("AM Hub","FE已开启",2)
end

local function StopFE()
    if not FE_Enabled then return end
    FE_Enabled = false
    ClearFE()
    Notify("AM Hub","FE已关闭",2)
end

-- ============================================================================
-- 甩飞
-- ============================================================================
local function StartThrow()
    if ThrowConn then ThrowConn:Disconnect() end
    ThrowConn = RunService.Heartbeat:Connect(function()
        if not ThrowEnabled then return end
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Target then
            local model = mouse.Target:FindFirstAncestorOfClass("Model")
            if model and model ~= GetChar() then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bv = Make("BodyVelocity", {
                        Velocity = Camera.CFrame.LookVector * ThrowPower,
                        MaxForce = Vector3.new(math.huge, math.huge, math.huge),
                        P = 5000
                    }, hrp)
                    game:GetService("Debris"):AddItem(bv, 0.2)
                end
            end
        end
    end)
    Notify("AM Hub","甩飞开启 - 对准目标",3)
end

local function StopThrow()
    ThrowEnabled = false
    if ThrowConn then ThrowConn:Disconnect() ThrowConn=nil end
    Notify("AM Hub","甩飞关闭",2)
end

-- ============================================================================
-- UI
-- ============================================================================
local ScreenGui = Make("ScreenGui", {
    Name = "AM_Hub", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Ball = Make("TextButton", {
    Size = UDim2.new(0,58,0,58),
    Position = UDim2.new(0,18,0.5,-29),
    BackgroundColor3 = Color3.fromRGB(255,0,80),
    BorderSizePixel = 3, BorderColor3 = Color3.new(1,1,1),
    Text = "AM", TextColor3 = Color3.new(1,1,1),
    TextSize = 22, Font = Enum.Font.GothamBold,
    ZIndex = 9999
}, ScreenGui)

local Main = Make("Frame", {
    Size = UDim2.new(0,360,0,480),
    Position = UDim2.new(0,88,0.5,-240),
    BackgroundColor3 = Color3.fromRGB(30,30,30),
    BorderSizePixel = 2, BorderColor3 = Color3.fromRGB(255,0,80),
    Visible = false, Active = true, ZIndex = 9998
}, ScreenGui)

local TitleBar = Make("Frame", {
    Size = UDim2.new(1,0,0,45),
    BackgroundColor3 = Color3.fromRGB(255,0,80),
    BorderSizePixel = 0
}, Main)

Make("TextLabel", {
    Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,10,0,0),
    BackgroundColor3 = Color3.fromRGB(255,0,80), BorderSizePixel = 0,
    Text = "AM Hub Mobile 3.0", TextColor3 = Color3.new(1,1,1),
    TextSize = 20, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, TitleBar)

local CloseBtn = Make("TextButton", {
    Size = UDim2.new(0,40,0,40), Position = UDim2.new(1,-42,0,3),
    BackgroundColor3 = Color3.fromRGB(200,0,0), BorderSizePixel = 1,
    BorderColor3 = Color3.new(1,1,1), Text = "X",
    TextColor3 = Color3.new(1,1,1), TextSize = 20, Font = Enum.Font.GothamBold
}, TitleBar)

-- 左侧分类栏（可滑动）
local CatScroll = Make("ScrollingFrame", {
    Size = UDim2.new(0,90,1,-50), Position = UDim2.new(0,5,0,50),
    BackgroundColor3 = Color3.fromRGB(50,50,50), BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(100,100,100),
    ScrollBarThickness = 6, ScrollBarImageColor3 = Color3.fromRGB(255,0,80),
    CanvasSize = UDim2.new(0,0,0,0)
}, Main)

local CatLayout = Make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)
}, CatScroll)

local CatBtns = {}
for i, cat in pairs(Categories) do
    local btn = Make("TextButton", {
        Size = UDim2.new(1,-8,0,36),
        BackgroundColor3 = Color3.fromRGB(80,80,80),
        BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(120,120,120),
        Text = cat, TextColor3 = Color3.new(1,1,1),
        TextSize = 14, Font = Enum.Font.GothamBold,
        LayoutOrder = i
    }, CatScroll)
    CatBtns[cat] = btn
end
CatScroll.CanvasSize = UDim2.new(0,0,0,#Categories*40+10)

-- 右侧内容区
local Content = Make("ScrollingFrame", {
    Size = UDim2.new(1,-100,1,-50), Position = UDim2.new(0,98,0,50),
    BackgroundColor3 = Color3.fromRGB(40,40,40), BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(100,100,100),
    ScrollBarThickness = 6, ScrollBarImageColor3 = Color3.fromRGB(255,0,80),
    CanvasSize = UDim2.new(0,0,0,0)
}, Main)

local ContentLayout = Make("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)
}, Content)

-- ============================================================================
-- UI组件工厂
-- ============================================================================
local function Toggle(text, desc, callback, parent)
    parent = parent or Content
    local frame = Make("Frame", {
        Size = UDim2.new(1,-10,0,50),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(100,100,100)
    }, parent)
    Make("TextLabel", {
        Size = UDim2.new(1,-70,0,20), Position = UDim2.new(0,8,0,4),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = text, TextColor3 = Color3.new(1,1,1),
        TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    Make("TextLabel", {
        Size = UDim2.new(1,-70,0,16), Position = UDim2.new(0,8,0,26),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = desc, TextColor3 = Color3.fromRGB(180,180,180),
        TextSize = 11, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    local btn = Make("TextButton", {
        Size = UDim2.new(0,50,0,30), Position = UDim2.new(1,-58,0,10),
        BackgroundColor3 = Color3.fromRGB(100,100,100), BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(150,150,150),
        Text = "关", TextColor3 = Color3.new(1,1,1),
        TextSize = 14, Font = Enum.Font.GothamBold
    }, frame)
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "开" or "关"
        btn.BackgroundColor3 = on and Color3.fromRGB(0,200,0) or Color3.fromRGB(100,100,100)
        pcall(callback, on)
    end)
end

local function Slider(text, desc, minV, maxV, defV, callback, parent)
    parent = parent or Content
    local frame = Make("Frame", {
        Size = UDim2.new(1,-10,0,70),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(100,100,100)
    }, parent)
    Make("TextLabel", {
        Size = UDim2.new(1,-70,0,20), Position = UDim2.new(0,8,0,4),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = text, TextColor3 = Color3.new(1,1,1),
        TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    Make("TextLabel", {
        Size = UDim2.new(1,-70,0,16), Position = UDim2.new(0,8,0,24),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = desc, TextColor3 = Color3.fromRGB(180,180,180),
        TextSize = 11, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    local valLabel = Make("TextLabel", {
        Size = UDim2.new(0,50,0,20), Position = UDim2.new(1,-58,0,4),
        BackgroundColor3 = Color3.fromRGB(80,80,80), BorderSizePixel = 1,
        Text = tostring(defV), TextColor3 = Color3.new(1,1,1),
        TextSize = 12, Font = Enum.Font.GothamBold
    }, frame)
    local btn = Make("TextButton", {
        Size = UDim2.new(1,-16,0,24), Position = UDim2.new(0,8,0,44),
        BackgroundColor3 = Color3.fromRGB(80,80,80), BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(120,120,120),
        Text = "点击增加", TextColor3 = Color3.new(1,1,1),
        TextSize = 12, Font = Enum.Font.Gotham
    }, frame)
    local cur = defV
    btn.MouseButton1Click:Connect(function()
        cur = cur + 1
        if cur > maxV then cur = minV end
        valLabel.Text = tostring(cur)
        pcall(callback, cur)
    end)
end

local function Button(text, desc, callback, parent)
    parent = parent or Content
    local frame = Make("Frame", {
        Size = UDim2.new(1,-10,0,50),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(100,100,100)
    }, parent)
    Make("TextLabel", {
        Size = UDim2.new(1,-70,0,20), Position = UDim2.new(0,8,0,4),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = text, TextColor3 = Color3.new(1,1,1),
        TextSize = 14, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    Make("TextLabel", {
        Size = UDim2.new(1,-70,0,16), Position = UDim2.new(0,8,0,26),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = desc, TextColor3 = Color3.new(1,1,1),
        TextSize = 11, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    local btn = Make("TextButton", {
        Size = UDim2.new(0,50,0,30), Position = UDim2.new(1,-58,0,10),
        BackgroundColor3 = Color3.fromRGB(0,100,200), BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(150,150,150),
        Text = "执行", TextColor3 = Color3.new(1,1,1),
        TextSize = 14, Font = Enum.Font.GothamBold
    }, frame)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

-- ============================================================================
-- 【新增】飞行控制按钮（手机触屏专用：前/后/左/右/升/降）
-- ============================================================================
local function FlyControlButton(text, desc, parent)
    parent = parent or Content
    local frame = Make("Frame", {
        Size = UDim2.new(1,-10,0,40),
        BackgroundColor3 = Color3.fromRGB(60,60,60),
        BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(100,100,100)
    }, parent)
    Make("TextLabel", {
        Size = UDim2.new(1,-10,0,16), Position = UDim2.new(0,8,0,4),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = text, TextColor3 = Color3.new(1,1,1),
        TextSize = 13, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    Make("TextLabel", {
        Size = UDim2.new(1,-10,0,14), Position = UDim2.new(0,8,0,22),
        BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0,
        Text = desc, TextColor3 = Color3.fromRGB(180,180,180),
        TextSize = 10, Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, frame)
    -- 按住移动，松开停止
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            frame.BackgroundColor3 = Color3.fromRGB(100,100,200)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            frame.BackgroundColor3 = Color3.fromRGB(60,60,60)
        end
    end)
    return frame
end

-- ============================================================================
-- 分类内容
-- ============================================================================
local function ShowCat(cat)
    CurrentCat = cat
    for _, child in pairs(Content:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for name, btn in pairs(CatBtns) do
        btn.BackgroundColor3 = (name == cat) and Color3.fromRGB(255,0,80) or Color3.fromRGB(80,80,80)
    end

    -- 主页
    if cat == "主页" then
        Button("QQ群", "179051448", function()
            Notify("AM Hub","QQ群: 179051448",5)
        end)
        Toggle("反踢出", "防止被踢", function(on) AntiKickEnabled=on if on then StartAntiKick() end end)
        Toggle("反检测", "降低检测风险", function(on) AntiDetectEnabled=on if on then StartAntiDetect() end end)
        Button("版本信息", "AM Hub Mobile 3.0", function()
            Notify("AM Hub","AM Hub Mobile 3.0 | Delta专用",3)
        end)
    end

    -- 移动（飞行修复 + 手机控制按钮）
    if cat == "移动" then
        Toggle("飞行", "WASD飞行（键盘）", function(on) if on then StartFly() else StopFly() end end)
        Slider("飞行速度", "10-200", 10, 200, 50, function(v) FlySpeed=v end)

        -- 手机触屏飞行控制
        Make("TextLabel", {
            Size = UDim2.new(1,-10,0,20), Position = UDim2.new(0,5,0,0),
            BackgroundTransparency = 1, Text = "【手机飞行控制 - 按住移动】",
            TextColor3 = Color3.fromRGB(255,200,0), TextSize = 12,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
        }, Content)

        local btnF = FlyControlButton("↑ 前进", "向前飞", Content)
        btnF.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(1,0,0) end end)
        btnF.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,0) end end)

        local btnB = FlyControlButton("↓ 后退", "向后飞", Content)
        btnB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(-1,0,0) end end)
        btnB.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,0) end end)

        local btnR = FlyControlButton("→ 右移", "向右飞", Content)
        btnR.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,1,0) end end)
        btnR.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,0) end end)

        local btnL = FlyControlButton("← 左移", "向左飞", Content)
        btnL.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,-1,0) end end)
        btnL.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,0) end end)

        local btnU = FlyControlButton("▲ 升高", "向上飞", Content)
        btnU.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,1) end end)
        btnU.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,0) end end)

        local btnD = FlyControlButton("▼ 降低", "向下飞", Content)
        btnD.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,-1) end end)
        btnD.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then SetFlyInput(0,0,0) end end)

        Toggle("速度", "修改移动速度", function(on)
            SpeedEnabled=on
            local h=GetHum() if h then h.WalkSpeed=on and SpeedValue or 16 end
        end)
        Slider("速度值", "16-200", 16, 200, 50, function(v)
            SpeedValue=v if SpeedEnabled then local h=GetHum() if h then h.WalkSpeed=v end end
        end)

        -- 【修复】跳高
        Toggle("跳高", "修改跳跃高度（修复版）", function(on)
            SetJump(on, JumpValue)
        end)
        Slider("跳高值", "50-500", 50, 500, 100, function(v)
            SetJump(JumpEnabled, v)
        end)

        Toggle("无限跳跃", "无限次跳跃", function(on) SetInfiniteJump(on) end)

        Toggle("穿墙", "穿墙模式", function(on) SetNoclip(on) end)
    end

    -- 视角（锁定视角修复）
    if cat == "视角" then
        Toggle("锁定视角", "锁定当前视角（修复版）", function(on) SetLockCamera(on) end)
        Toggle("ESP", "显示玩家名称", function(on)
            ESPEnabled=on
            for _,o in pairs(ESPObjects) do if o then o:Destroy() end end ESPObjects={}
            if on then
                for _,p in pairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        local head=p.Character:FindFirstChild("Head")
                        if head then
                            local bg=Make("BillboardGui",{Size=UDim2.new(0,100,0,40),StudsOffset=Vector3.new(0,2,0),AlwaysOnTop=true},head)
                            Make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,Text=p.Name,TextColor3=Color3.fromRGB(255,0,0),TextSize=14,Font=Enum.Font.GothamBold},bg)
                            table.insert(ESPObjects,bg)
                        end
                    end
                end
            end
        end)
    end

    -- 玩家
    if cat == "玩家" then
        Toggle("无敌模式", "无限生命", function(on)
            GodEnabled=on
            local h=GetHum() if h then if on then h.MaxHealth=math.huge h.Health=math.huge else h.MaxHealth=100 h.Health=100 end end
        end)
        Toggle("自动点击", "自动点击", function(on)
            AutoClickEnabled=on
            if AutoClickConn then AutoClickConn:Disconnect() end
            if on then
                AutoClickConn=RunService.Heartbeat:Connect(function()
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                    wait(0.1)
                end)
            end
        end)
        Toggle("旋转", "角色旋转", function(on)
            SpinEnabled=on
            if SpinConn then SpinConn:Disconnect() end
            if on then
                SpinConn=RunService.Heartbeat:Connect(function(dt)
                    local r=GetRoot() if r then r.CFrame=r.CFrame*CFrame.Angles(0,math.rad(SpinSpeed*dt*60),0) end
                end)
            end
        end)
    end

    -- 世界
    if cat == "世界" then
        Toggle("全亮", "最大亮度", function(on)
            FullBrightEnabled=on
            if on then Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1) Lighting.Brightness=2
            else Lighting.Ambient=Color3.fromRGB(128,128,128) Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128) Lighting.Brightness=1 end
        end)
        Toggle("去雾", "移除雾效", function(on)
            NoFogEnabled=on
            Lighting.FogEnd=on and 100000 or 10000
        end)
        Toggle("重力修改", "修改重力", function(on)
            GravityEnabled=on
            Workspace.Gravity=on and GravityValue or 196.2
        end)
        Slider("重力值", "0-500", 0, 500, 196, function(v)
            GravityValue=v if GravityEnabled then Workspace.Gravity=v end
        end)
    end

    -- 高级（FE + 甩飞 分开）
    if cat == "高级" then
        -- FE系统
        Make("TextLabel", {
            Size = UDim2.new(1,-10,0,20), Position = UDim2.new(0,5,0,0),
            BackgroundTransparency = 1, Text = "── FE系统 ──",
            TextColor3 = Color3.fromRGB(255,200,0), TextSize = 13,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
        }, Content)

        Toggle("FE总开关", "开启FE系统", function(on) if on then StartFE() else StopFE() end end)
        Toggle("FE-头顶冒火", "头部火焰效果", function(on)
            FE_FireEnabled=on if FE_Enabled then StopFE() StartFE() end
        end)
        Toggle("FE-移动冒火", "移动时脚下冒火", function(on)
            FE_FireMoveEnabled=on if FE_Enabled then StopFE() StartFE() end
        end)
        Toggle("FE-皇冠", "AM使用者头顶皇冠", function(on)
            FE_CrownEnabled=on if FE_Enabled then StopFE() StartFE() end
        end)

        -- 甩飞（独立）
        Make("TextLabel", {
            Size = UDim2.new(1,-10,0,20), Position = UDim2.new(0,5,0,0),
            BackgroundTransparency = 1, Text = "── 甩飞（独立）──",
            TextColor3 = Color3.fromRGB(0,200,255), TextSize = 13,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
        }, Content)

        Toggle("甩飞开关", "对准目标甩飞", function(on) if on then StartThrow() else StopThrow() end end)
        Slider("甩飞力度", "50-500", 50, 500, 200, function(v) ThrowPower=v end)

        -- 反作弊
        Make("TextLabel", {
            Size = UDim2.new(1,-10,0,20), Position = UDim2.new(0,5,0,0),
            BackgroundTransparency = 1, Text = "── 反作弊 ──",
            TextColor3 = Color3.fromRGB(0,255,100), TextSize = 13,
            Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
        }, Content)

        Toggle("反踢出(高级)", "高级反踢出", function(on) AntiKickEnabled=on if on then StartAntiKick() end end)
        Toggle("反检测(高级)", "高级反检测", function(on) AntiDetectEnabled=on if on then StartAntiDetect() end end)

        Button("重置所有", "关闭所有功能", function()
            StopFly() StopFE() StopThrow()
            SpeedEnabled=false JumpEnabled=false NoclipEnabled=false LockCamEnabled=false
            ESPEnabled=false GodEnabled=false InfJumpEnabled=false AutoClickEnabled=false SpinEnabled=false
            FullBrightEnabled=false NoFogEnabled=false GravityEnabled=false
            SetLockCamera(false)
            Notify("AM Hub","所有功能已重置",3)
        end)
    end

    wait()
    local cs = ContentLayout.AbsoluteContentSize
    Content.CanvasSize = UDim2.new(0,0,0,cs.Y+20)
end

-- ============================================================================
-- 按钮事件
-- ============================================================================
Ball.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    Main.Visible = MenuVisible
    if MenuVisible then ShowCat("主页") end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MenuVisible = false
    Main.Visible = false
end)

for name, btn in pairs(CatBtns) do
    btn.MouseButton1Click:Connect(function() ShowCat(name) end)
end

-- ============================================================================
-- 键盘（电脑测试用）
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.W then SetFlyInput(1,0,0) end
    if input.KeyCode==Enum.KeyCode.S then SetFlyInput(-1,0,0) end
    if input.KeyCode==Enum.KeyCode.A then SetFlyInput(0,-1,0) end
    if input.KeyCode==Enum.KeyCode.D then SetFlyInput(0,1,0) end
    if input.KeyCode==Enum.KeyCode.Space then SetFlyInput(0,0,1) end
    if input.KeyCode==Enum.KeyCode.LeftShift then SetFlyInput(0,0,-1) end
    if input.KeyCode==Enum.KeyCode.F then if FlyEnabled then StopFly() else StartFly() end end
    if input.KeyCode==Enum.KeyCode.P then
        MenuVisible=not MenuVisible Main.Visible=MenuVisible
        if MenuVisible then ShowCat(CurrentCat) end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode==Enum.KeyCode.W then SetFlyInput(0,0,0) end
    if input.KeyCode==Enum.KeyCode.S then SetFlyInput(0,0,0) end
    if input.KeyCode==Enum.KeyCode.A then SetFlyInput(0,0,0) end
    if input.KeyCode==Enum.KeyCode.D then SetFlyInput(0,0,0) end
    if input.KeyCode==Enum.KeyCode.Space then SetFlyInput(0,0,0) end
    if input.KeyCode==Enum.KeyCode.LeftShift then SetFlyInput(0,0,0) end
end)

-- ============================================================================
-- 初始化
-- ============================================================================
spawn(function()
    wait(2)
    StartAntiKick()
    StartAntiDetect()
    Notify("AM Hub Mobile 3.0","脚本已加载！QQ群:179051448",5)
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if FlyEnabled then StopFly() end
    if FE_Enabled then StopFE() end
end)

print("[AM Hub] 脚本已就绪！QQ群: 179051448")
