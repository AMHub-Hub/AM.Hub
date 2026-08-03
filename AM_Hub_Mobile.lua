--// AM Hub | XK Style | Full Source
--// Made by AM Official | QQ Group: 179051448

if _G.AM_HUB_LOADED then return end
_G.AM_HUB_LOADED = true

--// Services
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = workspace

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

--// State
local S = {
    Fly = false, Noclip = false, InfJump = false,
    ESP = false, Aimbot = false, XRay = false,
    SpeedVal = 16, JumpVal = 50, GravVal = 196,
    FlySpeed = 60, AimRange = 200,
    BV = nil, BG = nil, Conns = {}
}

--// GUI
local Screen = Instance.new("ScreenGui", game.CoreGui)
Screen.Name = "AM_Hub_GUI"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Main = Instance.new("Frame", Screen)
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Top Bar
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1, 0, 0, 32)
Top.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Top.BorderSizePixel = 0
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "AM Hub | 通用"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Top)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 1)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.MouseButton1Click:Connect(function()
    Screen:Destroy()
    _G.AM_HUB_LOADED = false
end)

-- Left Tab Bar
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0, 120, 1, -36)
TabBar.Position = UDim2.new(0, 0, 0, 34)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TabBar.BorderSizePixel = 0
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

-- Content Area
local Content = Instance.new("ScrollingFrame", Main)
Content.Position = UDim2.new(0, 130, 0, 38)
Content.Size = UDim2.new(1, -140, 1, -46)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 600)

local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

--// Helper Functions
local function CreateTab(name, ypos)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, ypos)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(function()
        Title.Text = "AM Hub | " .. name
    end)
    return btn
end

local function CreateToggle(parent, text, ypos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Position = UDim2.new(0, 5, 0, ypos)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and ": ON" or ": OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(35, 35, 40)
        callback(state, btn)
    end)
    return btn
end

local function CreateSlider(parent, text, ypos, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, ypos)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.BackgroundTransparency = 1

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1, -10, 0, 16)
    slider.Position = UDim2.new(0, 5, 0, 28)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slider.Text = ""
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 8)

    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

    local dragging = false
    slider.MouseButton1Down:Connect(function() dragging = true end)
    UIS.MouseButton1Up:Connect(function() dragging = false end)
    RS.RenderStepped:Connect(function()
        if dragging then
            local mp = UIS:GetMouseLocation()
            local sp = slider.AbsolutePosition
            local sz = slider.AbsoluteSize
            local pct = math.clamp((mp.X - sp.X) / sz.X, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = math.floor(min + pct * (max - min))
            label.Text = text .. ": " .. val
            callback(val)
        end
    end)
end

local function CreateButton(parent, text, ypos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, ypos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

--// Tabs
CreateTab("通用", 10)
CreateTab("视觉", 45)
CreateTab("ESP", 80)
CreateTab("自瞄", 115)
CreateTab("玩家", 150)
CreateTab("设置", 185)

--// 通用 Tab Content
CreateToggle(Content, "飞行", 5, function(v)
    S.Fly = v
    if v then
        S.BV = Instance.new("BodyVelocity", HRP)
        S.BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        S.BG = Instance.new("BodyGyro", HRP)
        S.BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        Hum.PlatformStand = true
        S.Conns.Fly = RS.Heartbeat:Connect(function()
            local D = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then D += WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then D -= WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then D -= WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then D += WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then D += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then D -= Vector3.new(0, 1, 0) end
            S.BG.CFrame = CFrame.new(HRP.Position, HRP.Position + WS.CurrentCamera.CFrame.LookVector)
            S.BV.Velocity = (D.Magnitude > 0 and D.Unit or Vector3.zero) * S.FlySpeed
        end)
    else
        if S.Conns.Fly then S.Conns.Fly:Disconnect() end
        if S.BV then S.BV:Destroy() end
        if S.BG then S.BG:Destroy() end
        Hum.PlatformStand = false
    end
end)

CreateToggle(Content, "穿墙", 45, function(v)
    S.Noclip = v
    if v then
        S.Conns.Noclip = RS.Stepped:Connect(function()
            for _, p in pairs(Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if S.Conns.Noclip then S.Conns.Noclip:Disconnect() end
    end
end)

CreateToggle(Content, "无限跳", 85, function(v)
    S.InfJump = v
    if v then
        S.Conns.IJ = UIS.JumpRequest:Connect(function()
            if Hum:GetState() ~= Enum.HumanoidStateType.Dead then
                Hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if S.Conns.IJ then S.Conns.IJ:Disconnect() end
    end
end)

CreateSlider(Content, "移速", 130, 16, 600, 16, function(v)
    S.SpeedVal = v
    Hum.WalkSpeed = v
end)

CreateSlider(Content, "跳力", 190, 50, 600, 50, function(v)
    S.JumpVal = v
    Hum.JumpPower = v
end)

CreateSlider(Content, "重力", 250, 1, 500, 196, function(v)
    S.GravVal = v
    WS.Gravity = v
end)

CreateSlider(Content, "飞行速度", 310, 10, 500, 60, function(v)
    S.FlySpeed = v
end)

--// 视觉 Tab Content
CreateToggle(Content, "夜视", 370, function(v)
    game:GetService("Lighting").Brightness = v and 5 or 2
end)

CreateToggle(Content, "去雾", 410, function(v)
    game:GetService("Lighting").FogEnd = v and 999999 or 1000
end)

CreateToggle(Content, "全图明亮", 450, function(v)
    game:GetService("Lighting").Ambient = v and Color3.new(1,1,1) or Color3.new(0,0,0)
end)

CreateSlider(Content, "FOV", 490, 50, 120, 70, function(v)
    WS.CurrentCamera.FieldOfView = v
end)

--// ESP Tab Content
CreateToggle(Content, "名称ESP", 550, function(v)
    S.ESP = v
    if v then
        S.Conns.ESP = RS.RenderStepped:Connect(function()
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character and pl.Character:FindFirstChild("Head") then
                    local tag = "ESP_" .. pl.Name
                    if not game.CoreGui:FindFirstChild(tag) then
                        local bb = Instance.new("BillboardGui", game.CoreGui)
                        bb.Name = tag
                        bb.Adornee = pl.Character.Head
                        bb.Size = UDim2.new(0, 100, 0, 20)
                        bb.AlwaysOnTop = true
                        local tl = Instance.new("TextLabel", bb)
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        tl.TextScaled = true
                        tl.Text = pl.Name
                    end
                end
            end
        end)
    else
        if S.Conns.ESP then S.Conns.ESP:Disconnect() end
        for _, g in pairs(game.CoreGui:GetChildren()) do
            if g.Name:match("^ESP_") then g:Destroy() end
        end
    end
end)

CreateToggle(Content, "透视XRay", 590, function(v)
    S.XRay = v
    if v then
        S.Conns.XRay = RS.RenderStepped:Connect(function()
            for _, p in pairs(WS:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent ~= Char then
                    p.LocalTransparencyModifier = 0.5
                end
            end
        end)
    else
        if S.Conns.XRay then S.Conns.XRay:Disconnect() end
    end
end)

--// 自瞄 Tab Content
CreateToggle(Content, "自瞄", 650, function(v)
    S.Aimbot = v
    if v then
        S.Conns.Aim = RS.RenderStepped:Connect(function()
            local target = nil
            local dist = math.huge
            for _, pl in pairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character and pl.Character:FindFirstChild("Head") then
                    local d = (pl.Character.Head.Position - HRP.Position).Magnitude
                    if d < S.AimRange and d < dist then
                        dist = d
                        target = pl.Character.Head
                    end
                end
            end
            if target then
                WS.CurrentCamera.CFrame = CFrame.new(WS.CurrentCamera.CFrame.Position, target.Position)
            end
        end)
    else
        if S.Conns.Aim then S.Conns.Aim:Disconnect() end
    end
end)

CreateSlider(Content, "自瞄范围", 690, 10, 1000, 200, function(v)
    S.AimRange = v
end)

--// 玩家 Tab Content
CreateButton(Content, "传送至鼠标", 750, function()
    local mp = UIS:GetMouseLocation()
    local ray = WS.CurrentCamera:ScreenPointToRay(mp.X, mp.Y)
    local hit = WS:Raycast(ray.Origin, ray.Direction * 1000)
    if hit then
        HRP.CFrame = CFrame.new(hit.Position + Vector3.new(0, 5, 0))
    end
end)

CreateButton(Content, "坐下", 790, function()
    Hum:ChangeState(Enum.HumanoidStateType.Seated)
end)

CreateButton(Content, "跳一下", 830, function()
    Hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

--// 设置 Tab Content
CreateButton(Content, "复制QQ群: 179051448", 890, function()
    pcall(function() setclipboard("179051448") end)
end)

CreateToggle(Content, "全局总开关", 930, function(v)
    if not v then
        -- 关所有
        for k, conn in pairs(S.Conns) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        S.Conns = {}
        if S.BV then S.BV:Destroy() end
        if S.BG then S.BG:Destroy() end
        Hum.WalkSpeed = 16
        Hum.JumpPower = 50
        WS.Gravity = 196
        for _, g in pairs(game.CoreGui:GetChildren()) do
            if g.Name:match("^ESP_") then g:Destroy() end
        end
    end
end)

CreateButton(Content, "销毁脚本", 970, function()
    Screen:Destroy()
    _G.AM_HUB_LOADED = false
    for k, conn in pairs(S.Conns) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
end)

--// Floating Button
local Float = Instance.new("TextButton", Screen)
Float.Size = UDim2.new(0, 52, 0, 52)
Float.Position = UDim2.new(1, -62, 1, -62)
Float.Text = "AM"
Float.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
Float.TextColor3 = Color3.new(1, 1, 1)
Float.Font = Enum.Font.GothamBlack
Float.TextSize = 15
Float.Draggable = true
Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)
Float.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

spawn(function()
    while _G.AM_HUB_LOADED do
        pcall(function()
            Float.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end)
        wait(0.1)
    end
end)

print("[AM Hub] Loaded | XK Style | Made by AM Official")
