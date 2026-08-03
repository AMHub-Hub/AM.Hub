--// AM Hub | Floating Window | All Functions Fixed
if _G.AM_FLOAT then return end _G.AM_FLOAT = true

local P = game:GetService("Players")
local LP = P.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = workspace
local Cam = WS.CurrentCamera
local LT = game:GetService("Lighting")

local C, H, HRP
local Conns = {}
local S = {
    Fly=false, Noclip=false, InfJump=false,
    ESP=false, XRay=false, Aimbot=false,
    Night=false, NoFog=false, Bright=false,
    Speed=16, Jump=50, Grav=196, FOV=70, AimRng=200, FlySpd=60
}

local function bindChar()
    C = LP.Character or LP.CharacterAdded:Wait()
    H = C:WaitForChild("Humanoid")
    HRP = C:WaitForChild("HumanoidRootPart")
end
bindChar()
LP.CharacterAdded:Connect(function()
    for _,c in pairs(Conns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end
    Conns = {}
    bindChar()
    S.Fly=false S.Noclip=false S.InfJump=false S.ESP=false S.XRay=false S.Aimbot=false
    -- 重生后重建 UI 状态你自己决定，这里只保证不死
end)

-- GUI
local SG = Instance.new("ScreenGui", game.CoreGui)
SG.Name = "AM_Float"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 主悬浮窗
local Win = Instance.new("Frame", SG)
Win.Size = UDim2.new(0, 320, 0, 420)
Win.Position = UDim2.new(0.5, -160, 0.5, -210)
Win.BackgroundColor3 = Color3.fromRGB(20,20,25)
Win.BackgroundTransparency = 0.15
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 8)

-- 标题栏
local Title = Instance.new("TextLabel", Win)
Title.Size = UDim2.new(1, -60, 0, 28)
Title.Position = UDim2.new(0, 8, 0, 4)
Title.Text = "⚙ AM 悬浮窗"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1

local Min = Instance.new("TextButton", Win)
Min.Size = UDim2.new(0,26,0,26) Min.Position = UDim2.new(1,-56,0,4)
Min.Text = "－" Min.TextColor3 = Color3.new(1,1,1) Min.BackgroundTransparency = 1
local Cls = Instance.new("TextButton", Win)
Cls.Size = UDim2.new(0,26,0,26) Cls.Position = UDim2.new(1,-28,0,4)
Cls.Text = "×" Cls.TextColor3 = Color3.fromRGB(255,80,80) Cls.BackgroundTransparency = 1

local Body = Instance.new("ScrollingFrame", Win)
Body.Position = UDim2.new(0,6,0,34)
Body.Size = UDim2.new(1,-12,1,-40)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ScrollBarThickness = 4
Body.CanvasSize = UDim2.new(0,0,0,700)
local Layout = Instance.new("UIListLayout", Body)
Layout.Padding = UDim.new(0,4)

-- 工具函数
local function Row(h)
    local f = Instance.new("Frame", Body)
    f.Size = UDim2.new(1,-4,0,h or 30)
    f.BackgroundTransparency = 1
    return f
end
local function Label(f, txt, x)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0, 140, 1, 0) l.Position = UDim2.new(0,x or 0,0,0)
    l.Text = txt l.TextColor3 = Color3.new(1,1,1) l.Font = Enum.Font.Gotham l.TextSize = 11
    l.BackgroundTransparency = 1 l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end
local function Toggle(f, y, cb)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0,50,0,22) b.Position = UDim2.new(1,-56,0,y or 4)
    b.Text = "OFF" b.TextColor3 = Color3.new(1,1,1) b.Font = Enum.Font.Gotham b.TextSize = 11
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        b.Text = on and "ON" or "OFF"
        b.BackgroundColor3 = on and Color3.fromRGB(50,160,50) or Color3.fromRGB(60,60,60)
        cb(on, b)
    end)
end
local function Slider(f, y, min, max, def, cb)
    local s = Instance.new("TextButton", f)
    s.Size = UDim2.new(0,100,0,18) s.Position = UDim2.new(1,-106,0,y or 6)
    s.Text = tostring(def) s.TextColor3 = Color3.new(1,1,1) s.Font = Enum.Font.Gotham s.TextSize = 11
    s.BackgroundColor3 = Color3.fromRGB(50,50,55)
    local drag = false
    s.MouseButton1Down:Connect(function() drag = true end)
    UIS.MouseButton1Up:Connect(function() drag = false end)
    RS.RenderStepped:Connect(function()
        if drag then
            local mp = UIS:GetMouseLocation()
            local sp = s.AbsolutePosition; local sz = s.AbsoluteSize
            local pct = math.clamp((mp.X - sp.X)/sz.X, 0, 1)
            local v = math.floor(min + pct*(max-min))
            s.Text = tostring(v)
            cb(v)
        end
    end)
end

-- 通用
Label(Row(26),"【通用】",0)
local r = Row(28)
Label(r,"飞行")
Toggle(r,4,function(v)
    S.Fly = v
    if v then
        S.BV = Instance.new("BodyVelocity", HRP) S.BV.MaxForce = Vector3.new(1e6,1e6,1e6)
        S.BG = Instance.new("BodyGyro", HRP) S.BG.MaxTorque = Vector3.new(1e6,1e6,1e6)
        H.PlatformStand = true
        Conns.Fly = RS.Heartbeat:Connect(function()
            local D = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then D += Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then D -= Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then D -= Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then D += Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then D += Vector3.new(0,1,0) end
            S.BG.CFrame = CFrame.new(HRP.Position, HRP.Position + Cam.CFrame.LookVector)
            S.BV.Velocity = (D.Magnitude>0 and D.Unit or Vector3.zero)*S.FlySpd
        end)
    else
        if Conns.Fly then Conns.Fly:Disconnect() end
        if S.BV then S.BV:Destroy() end
        if S.BG then S.BG:Destroy() end
        H.PlatformStand = false
    end
end)
Slider(r,5,10,200,60,function(v) S.FlySpd = v end)

local r2 = Row(28)
Label(r2,"穿墙")
Toggle(r2,4,function(v)
    S.Noclip = v
    if v then
        Conns.NC = RS.Stepped:Connect(function()
            for _,p in pairs(C:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else
        if Conns.NC then Conns.NC:Disconnect() end
    end
end)

local r3 = Row(28)
Label(r3,"无限跳")
Toggle(r3,4,function(v)
    S.InfJump = v
    if v then
        Conns.IJ = UIS.JumpRequest:Connect(function()
            if H:GetState()~=Enum.HumanoidStateType.Dead then H:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if Conns.IJ then Conns.IJ:Disconnect() end
    end
end)

local r4 = Row(28)
Label(r4,"步行速度")
Slider(r4,6,16,600,16,function(v) S.Speed=v H.WalkSpeed=v end)

local r5 = Row(28)
Label(r5,"跳跃高度")
Slider(r5,6,50,600,50,function(v) S.Jump=v H.JumpPower=v end)

local r6 = Row(28)
Label(r6,"重力")
Slider(r6,6,1,500,196,function(v) S.Grav=v WS.Gravity=v end)

-- 视觉
Label(Row(26),"【视觉】",0)
local r7 = Row(28)
Label(r7,"夜视")
Toggle(r7,4,function(v) S.Night=v LT.Brightness=v and 5 or 2 end)
local r8 = Row(28)
Label(r8,"去雾")
Toggle(r8,4,function(v) S.NoFog=v LT.FogEnd=v and 999999 or 1000 end)
local r9 = Row(28)
Label(r9,"全图明亮")
Toggle(r9,4,function(v) S.Bright=v LT.Ambient=v and Color3.new(1,1,1) or Color3.new(0,0,0) end)
local r10 = Row(28)
Label(r10,"FOV")
Slider(r10,6,50,120,70,function(v) S.FOV=v Cam.FieldOfView=v end)

-- ESP
Label(Row(26),"【ESP】",0)
local r11 = Row(28)
Label(r11,"名称ESP")
Toggle(r11,4,function(v)
    S.ESP = v
    if v then
        local folder = Instance.new("Folder", game.StarterGui) folder.Name = "AM_ESP"
        Conns.ESP = RS.RenderStepped:Connect(function()
            for _,pl in pairs(P:GetPlayers()) do
                if pl~=LP and pl.Character and pl.Character:FindFirstChild("Head") then
                    local tag = "ESP_"..pl.Name
                    if not folder:FindFirstChild(tag) then
                        local bb = Instance.new("BillboardGui", folder)
                        bb.Name = tag bb.Adornee = pl.Character.Head
                        bb.Size = UDim2.new(0,100,0,20) bb.AlwaysOnTop = true
                        local tl = Instance.new("TextLabel", bb)
                        tl.Size = UDim2.new(1,0,1,0) tl.BackgroundTransparency = 1
                        tl.TextColor3 = Color3.fromHSV(tick()%5/5,1,1)
                        tl.TextScaled = true tl.Text = pl.Name
                    end
                end
            end
        end)
    else
        if Conns.ESP then Conns.ESP:Disconnect() end
        local f = game.StarterGui:FindFirstChild("AM_ESP")
        if f then f:Destroy() end
    end
end)

local r12 = Row(28)
Label(r12,"透视XRay")
Toggle(r12,4,function(v)
    S.XRay = v
    if v then
        Conns.XR = RS.RenderStepped:Connect(function()
            for _,p in pairs(WS:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent~=C then p.LocalTransparencyModifier=0.5 end
            end
        end)
    else
        if Conns.XR then Conns.XR:Disconnect() end
    end
end)

-- 自瞄（修好相机）
Label(Row(26),"【自瞄】",0)
local r13 = Row(28)
Label(r13,"自瞄开关")
Toggle(r13,4,function(v)
    S.Aimbot = v
    if v then
        Cam.CameraType = Enum.CameraType.Scriptable
        Conns.Aim = RS.RenderStepped:Connect(function()
            local tg = nil; local md = math.huge
            for _,pl in pairs(P:GetPlayers()) do
                if pl~=LP and pl.Character and pl.Character:FindFirstChild("Head") then
                    local d = (pl.Character.Head.Position - HRP.Position).Magnitude
                    if d<S.AimRng and d<md then md=d tg=pl.Character.Head end
                end
            end
            if tg then Cam.CFrame = CFrame.new(Cam.CFrame.Position, tg.Position) end
        end)
    else
        if Conns.Aim then Conns.Aim:Disconnect() end
        Cam.CameraType = Enum.CameraType.Custom
    end
end)
local r14 = Row(28)
Label(r14,"自瞄范围")
Slider(r14,6,10,1000,200,function(v) S.AimRng=v end)

-- 设置
Label(Row(26),"【设置】",0)
local r15 = Row(28)
Label(r15,"全局关")
Toggle(r15,4,function(v)
    if v then
        for _,c in pairs(Conns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end
        Conns = {}
        if S.BV then S.BV:Destroy() end
        if S.BG then S.BG:Destroy() end
        H.WalkSpeed=16 H.JumpPower=50 WS.Gravity=196
        Cam.FieldOfView=70 Cam.CameraType=Enum.CameraType.Custom
        LT.Brightness=2 LT.FogEnd=1000 LT.Ambient=Color3.new(0,0,0)
        local f = game.StarterGui:FindFirstChild("AM_ESP")
        if f then f:Destroy() end
    end
end)

local r16 = Row(28)
Label(r16,"销毁脚本")
local dst = Instance.new("TextButton", r16)
dst.Size = UDim2.new(0,60,0,22) dst.Position = UDim2.new(1,-66,0,4)
dst.Text = "DESTROY" dst.TextColor3 = Color3.new(1,0.3,0.3) dst.BackgroundColor3 = Color3.fromRGB(60,30,30)
dst.Font = Enum.Font.Gotham dst.TextSize = 11
dst.MouseButton1Click:Connect(function()
    for _,c in pairs(Conns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end
    SG:Destroy() _G.AM_FLOAT = false
end)

-- 标题栏按钮
local mini = false
Min.MouseButton1Click:Connect(function()
    mini = not mini
    Body.Visible = not mini
    Win.Size = mini and UDim2.new(0,320,0,32) or UDim2.new(0,320,0,420)
end)
Cls.MouseButton1Click:Connect(function() SG:Destroy() _G.AM_FLOAT = false end)

-- 右下角悬浮按钮
local FL = Instance.new("TextButton", SG)
FL.Size = UDim2.new(0,48,0,48) FL.Position = UDim2.new(1,-56,1,-56)
FL.Text = "AM" FL.TextColor3 = Color3.new(1,1,1) FL.Font = Enum.Font.GothamBlack FL.TextSize = 14
FL.BackgroundColor3 = Color3.fromHSV(tick()%5/5,1,1) FL.Draggable = true
Instance.new("UICorner", FL).CornerRadius = UDim.new(1,0)
FL.MouseButton1Click:Connect(function() Win.Visible = not Win.Visible end)
spawn(function() while _G.AM_FLOAT do pcall(function() FL.BackgroundColor3 = Color3.fromHSV(tick()%5/5,1,1) end) wait(0.1) end end)

print("[AM] Floating Window Loaded")
