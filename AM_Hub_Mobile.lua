--[[
    ╔══════════════════════════════════════════════════╗
    ║              AM HUB v3.0 - AM Style                 ║
    ║           QQ群: 179051448                          ║
    ║           Author: AM官方制作                        ║
    ╚══════════════════════════════════════════════════╝
]]

-- ===================== 防重复加载 =====================
if _G.AM_HUB_LOADED then
    _G.AM_HUB_LOADED = nil
    pcall(function() game.CoreGui:FindFirstChild("AM_HUB_SCREEN"):Destroy() end)
    return
end
_G.AM_HUB_LOADED = true

-- ===================== 服务获取 =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = workspace

local LocalPlayer = Players.LocalPlayer

-- ===================== 安全获取函数 =====================
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChildWhichIsA("Humanoid") or char:WaitForChild("Humanoid", 5)
end

local function GetHRP()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
end

-- 缓存原始值
local OriginalValues = {}
local ValuesCached = false
local function CacheOriginalValues()
    if ValuesCached then return end
    pcall(function()
        local hum = GetHumanoid()
        if hum then
            OriginalValues.WalkSpeed = hum.WalkSpeed
            OriginalValues.JumpPower = hum.JumpPower
        end
        OriginalValues.Gravity = Workspace.Gravity
        ValuesCached = true
    end)
end

-- ===================== 加载 WindUI =====================
local WindUI
pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end)
if not WindUI then
    pcall(function()
        WindUI = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/main.lua"))()
    end)
end

-- ===================== 状态管理 =====================
local States = {
    SpeedEnabled = false, SpeedValue = 16,
    JumpEnabled = false, JumpValue = 50,
    GravityEnabled = false, GravityValue = 196,
    InfiniteJump = false, FlyEnabled = false, FlySpeed = 50,
    Noclip = false, Invisible = false,
    NightVision = false, NoFog = false, BrightMap = false,
    ESPEnabled = false, AimbotEnabled = false, AimbotRange = 100, AimbotHead = true,
    FOVEnabled = false, FOVValue = 70,
}

local Connections = {}
local Instances = {}

-- ===================== 清理函数 =====================
local function CleanupAll()
    -- 断开所有连接
    for name, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
        Connections[name] = nil
    end
    -- 销毁所有实例
    for name, inst in pairs(Instances) do
        pcall(function() inst:Destroy() end)
        Instances[name] = nil
    end
    -- 还原原始值
    pcall(function()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = OriginalValues.WalkSpeed or 16
            hum.JumpPower = OriginalValues.JumpPower or 50
            hum.PlatformStand = false
        end
    end)
    Workspace.Gravity = OriginalValues.Gravity or 196.2
    -- 还原 Lighting
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(50, 50, 50)
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
    end)
    -- 还原角色透明度
    pcall(function()
        for _, part in pairs(GetCharacter():GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end)
end

-- ===================== 如果没有 WindUI，用原生 UI 兜底 =====================
if not WindUI then
    -- ========== 原生 UI 兜底版本 ==========
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AM_HUB_SCREEN"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.fromOffset(300, 500)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 3
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 3
    Stroke.Parent = MainFrame

    spawn(function()
        while _G.AM_HUB_LOADED do
            pcall(function() Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end)
            wait(0.1)
        end
    end)

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 28)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Text = "AM Hub | QQ: 179051448"
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 13
    TitleBar.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 1, 0)
    CloseBtn.Position = UDim2.new(1, -28, 0, 0)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        _G.AM_HUB_LOADED = false
        CleanupAll()
        ScreenGui:Destroy()
    end)

    local YPos = 34
    local function CreateToggle(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 26)
        btn.Position = UDim2.new(0, 8, 0, YPos)
        YPos = YPos + 28
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Text = name .. ": OFF"
        btn.Parent = MainFrame
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = name .. (state and ": ON" or ": OFF")
            callback(state, btn)
        end)
        return btn
    end

    local function CreateSlider(name, min, max, default, callback)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -16, 0, 14)
        label.Position = UDim2.new(0, 8, 0, YPos)
        YPos = YPos + 14
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.Text = name .. ": " .. default
        label.Parent = MainFrame

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -16, 0, 20)
        box.Position = UDim2.new(0, 8, 0, YPos)
        YPos = YPos + 22
        box.Text = tostring(default)
        box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.Gotham
        box.TextSize = 11
        box.Parent = MainFrame
        box.FocusLost:Connect(function()
            local val = tonumber(box.Text) or default
            val = math.clamp(val, min, max)
            box.Text = val
            label.Text = name .. ": " .. val
            callback(val)
        end)
    end

    local function CreateButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 26)
        btn.Position = UDim2.new(0, 8, 0, YPos)
        YPos = YPos + 28
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Text = name
        btn.Parent = MainFrame
        btn.MouseButton1Click:Connect(callback)
    end

    -- 信息显示
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -16, 0, 28)
    info.Position = UDim2.new(0, 8, 0, YPos)
    YPos = YPos + 30
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(0, 200, 255)
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.Text = "玩家: " .. LocalPlayer.Name .. " | ID: " .. LocalPlayer.UserId .. "\n年龄: " .. LocalPlayer.AccountAge .. "天"
    info.Parent = MainFrame

    -- ===== 通用功能 =====
    CreateToggle("移速修改", function(v)
        CacheOriginalValues()
        States.SpeedEnabled = v
        pcall(function()
            GetHumanoid().WalkSpeed = v and States.SpeedValue or (OriginalValues.WalkSpeed or 16)
        end)
    end)

    CreateSlider("移速值 (1-600)", 1, 600, 16, function(v)
        States.SpeedValue = v
        if States.SpeedEnabled then
            pcall(function() GetHumanoid().WalkSpeed = v end)
        end
    end)

    CreateToggle("跳力修改", function(v)
        CacheOriginalValues()
        States.JumpEnabled = v
        pcall(function()
            GetHumanoid().JumpPower = v and States.JumpValue or (OriginalValues.JumpPower or 50)
        end)
    end)

    CreateSlider("跳力值 (1-600)", 1, 600, 50, function(v)
        States.JumpValue = v
        if States.JumpEnabled then
            pcall(function() GetHumanoid().JumpPower = v end)
        end
    end)

    CreateToggle("重力修改", function(v)
        CacheOriginalValues()
        States.GravityEnabled = v
        Workspace.Gravity = v and States.GravityValue or (OriginalValues.Gravity or 196.2)
    end)

    CreateSlider("重力值 (1-500)", 1, 500, 196, function(v)
        States.GravityValue = v
        if States.GravityEnabled then Workspace.Gravity = v end
    end)

    CreateToggle("无限跳跃", function(v)
        States.InfiniteJump = v
        if v then
            Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                pcall(function()
                    local h = GetHumanoid()
                    if h and h:GetState() ~= Enum.HumanoidStateType.Dead then
                        h:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end)
        else
            if Connections.InfiniteJump then
                Connections.InfiniteJump:Disconnect()
                Connections.InfiniteJump = nil
            end
        end
    end)

    CreateToggle("穿墙模式", function(v)
        States.Noclip = v
        if v then
            Instances.NoclipOriginal = {}
            for _, part in pairs(GetCharacter():GetDescendants()) do
                if part:IsA("BasePart") then
                    Instances.NoclipOriginal[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
            Connections.Noclip = RunService.Stepped:Connect(function()
                for part, _ in pairs(Instances.NoclipOriginal) do
                    if part and part.Parent then part.CanCollide = false end
                end
            end)
        else
            if Connections.Noclip then
                Connections.Noclip:Disconnect()
                Connections.Noclip = nil
            end
            for part, origVal in pairs(Instances.NoclipOriginal or {}) do
                if part and part.Parent then part.CanCollide = origVal end
            end
            Instances.NoclipOriginal = {}
        end
    end)

    CreateToggle("飞行模式", function(v)
        States.FlyEnabled = v
        if v then
            local hrp = GetHRP()
            if not hrp then
                States.FlyEnabled = false
                return
            end
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1000000, 1000000, 1000000)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            Instances.BodyVelocity = bv

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
            bg.P = 3000
            bg.Parent = hrp
            Instances.BodyGyro = bg

            pcall(function() GetHumanoid().PlatformStand = true end)

            local cam = Workspace.CurrentCamera
            Connections.Fly = RunService.Heartbeat:Connect(function()
                if not Instances.BodyVelocity or not Instances.BodyVelocity.Parent then return end
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
                bv.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.zero) * States.FlySpeed
            end)
        else
            if Connections.Fly then
                Connections.Fly:Disconnect()
                Connections.Fly = nil
            end
            if Instances.BodyVelocity then
                pcall(function() Instances.BodyVelocity:Destroy() end)
                Instances.BodyVelocity = nil
            end
            if Instances.BodyGyro then
                pcall(function() Instances.BodyGyro:Destroy() end)
                Instances.BodyGyro = nil
            end
            pcall(function() GetHumanoid().PlatformStand = false end)
        end
    end)

    CreateSlider("飞行速度 (10-500)", 10, 500, 50, function(v)
        States.FlySpeed = v
    end)

    CreateToggle("隐身透明", function(v)
        States.Invisible = v
        pcall(function()
            for _, part in pairs(GetCharacter():GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = v and 0.9 or 0
                end
            end
        end)
    end)

    -- ===== 视觉 =====
    CreateSlider("FOV视野 (50-120)", 50, 120, 70, function(v)
        States.FOVValue = v
        pcall(function() Workspace.CurrentCamera.FieldOfView = v end)
    end)

    CreateToggle("夜视模式", function(v)
        States.NightVision = v
        if v then
            spawn(function()
                while v and _G.AM_HUB_LOADED do
                    pcall(function()
                        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
                        Lighting.Brightness = 2
                    end)
                    wait(0.2)
                end
            end)
        else
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(50, 50, 50)
                Lighting.Brightness = 1
            end)
        end
    end)

    CreateToggle("去除雾效", function(v)
        States.NoFog = v
        pcall(function() Lighting.FogEnd = v and 999999 or 1000 end)
    end)

    CreateToggle("全图明亮", function(v)
        States.BrightMap = v
        pcall(function()
            if v then
                Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
                Lighting.Brightness = 3
            else
                Lighting.Ambient = Color3.fromRGB(50, 50, 50)
                Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
                Lighting.Brightness = 1
            end
        end)
    end)

    -- ===== ESP =====
    CreateToggle("玩家ESP", function(v)
        States.ESPEnabled = v
        if v then
            Instances.ESPFolder = Instance.new("Folder")
            Instances.ESPFolder.Name = "AM_ESP"
            Instances.ESPFolder.Parent = game.CoreGui
            Connections.ESP = RunService.RenderStepped:Connect(function()
                pcall(function()
                    Instances.ESPFolder:ClearAllChildren()
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                            local bg = Instance.new("BillboardGui")
                            bg.Adornee = plr.Character.Head
                            bg.Size = UDim2.new(0, 100, 0, 20)
                            bg.AlwaysOnTop = true
                            bg.Parent = Instances.ESPFolder
                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = plr.Name
                            lbl.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                            lbl.TextScaled = true
                            lbl.Parent = bg
                        end
                    end
                end)
            end)
        else
            if Connections.ESP then
                Connections.ESP:Disconnect()
                Connections.ESP = nil
            end
            if Instances.ESPFolder then
                pcall(function() Instances.ESPFolder:Destroy() end)
                Instances.ESPFolder = nil
            end
        end
    end)

    -- ===== 自瞄 =====
    CreateToggle("自瞄开关", function(v)
        States.AimbotEnabled = v
        if v then
            Connections.Aimbot = RunService.RenderStepped:Connect(function()
                if not States.AimbotEnabled then return end
                local cam = Workspace.CurrentCamera
                local bestTarget = nil
                local bestDist = States.AimbotRange
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local screenPos, onScreen = cam:WorldToScreenPoint(head.Position)
                        local dist = (head.Position - cam.CFrame.Position).Magnitude
                        if onScreen and dist < bestDist then
                            bestDist = dist
                            bestTarget = head
                        end
                    end
                end
                if bestTarget then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, bestTarget.Position)
                end
            end)
        else
            if Connections.Aimbot then
                Connections.Aimbot:Disconnect()
                Connections.Aimbot = nil
            end
        end
    end)

    CreateSlider("自瞄范围 (10-1000)", 10, 1000, 100, function(v)
        States.AimbotRange = v
    end)

    -- ===== 设置 =====
    CreateButton("复制QQ群: 179051448", function()
        pcall(function() (setclipboard or function() end)("179051448") end)
    end)

    CreateButton("全局关闭所有功能", function()
        States.SpeedEnabled = false
        States.JumpEnabled = false
        States.GravityEnabled = false
        States.InfiniteJump = false
        States.FlyEnabled = false
        States.Noclip = false
        States.Invisible = false
        States.NightVision = false
        States.NoFog = false
        States.BrightMap = false
        States.ESPEnabled = false
        States.AimbotEnabled = false
        CleanupAll()
        -- 重建UI
        ScreenGui:Destroy()
        _G.AM_HUB_LOADED = false
        wait(0.1)
        _G.AM_HUB_LOADED = true
        -- 简单通知
        local notif = Instance.new("ScreenGui")
        notif.Parent = game.CoreGui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 300, 0, 40)
        lbl.Position = UDim2.new(0.5, -150, 0, 20)
        lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        lbl.TextColor3 = Color3.fromRGB(0, 255, 0)
        lbl.Text = "所有功能已关闭并重置"
        lbl.Parent = notif
        spawn(function() wait(3); notif:Destroy() end)
    end)

    CreateButton("彻底销毁脚本", function()
        _G.AM_HUB_LOADED = false
        CleanupAll()
        ScreenGui:Destroy()
    end)

    print("[AM Hub v3.0] 原生UI模式加载完成 ✅ | QQ群: 179051448")
    return
end

-- ===================== WindUI 模式（XK风格） =====================
WindUI.TransparencyValue = 0.15
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "AM Hub",
    Icon = "crown",
    Author = "AM官方制作",
    AuthorImage = 90840643379863,
    Folder = "AMHub",
    Size = UDim2.fromOffset(560, 400),
    Transparent = true,
    User = {
        Enabled = true,
        Callback = function()
            print("AM Hub - 用户按钮点击")
        end,
        Anonymous = false
    },
})

-- 彩虹边框
spawn(function()
    while _G.AM_HUB_LOADED do
        pcall(function()
            Window:SetBorderColor(Color3.fromHSV(tick() % 5 / 5, 1, 1))
        end)
        wait(0.1)
    end
end)

-- 打开按钮（彩虹色）
Window:EditOpenButton({
    Title = "AM",
    Icon = "crown",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 3,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
    }),
    Draggable = true
})

-- ===================== Tab 封装 =====================
local function CreateTab(name, icon)
    return Window:Tab({ Title = name, Icon = icon or "eye" })
end

local TabHome = CreateTab("首页", "home")
local TabGeneral = CreateTab("通用", "settings")
local TabPlayer = CreateTab("玩家", "user")
local TabVisual = CreateTab("视觉", "eye")
local TabESP = CreateTab("ESP", "scan")
local TabAimbot = CreateTab("自瞄", "crosshair")
local TabFE = CreateTab("FE", "shield")
local TabFun = CreateTab("娱乐", "smile")
local TabSettings = CreateTab("设置", "settings")

-- ===================== 首页 =====================
TabHome:Paragraph({
    Title = "玩家信息",
    Desc = string.format("用户名: %s\n显示名: %s\n用户ID: %d\n账号年龄: %d天\n会员类型: %s",
        LocalPlayer.Name, LocalPlayer.DisplayName, LocalPlayer.UserId,
        LocalPlayer.AccountAge, LocalPlayer.MembershipType.Name),
    Image = "info",
    ImageSize = 20,
    Color = Color3.fromHex("#00CCFF")
})

-- FPS 计数器
local fpsText = "计算中..."
spawn(function()
    local count = 0
    local lastTime = tick()
    while _G.AM_HUB_LOADED do
        count = count + 1
        if tick() - lastTime >= 1 then
            fpsText = string.format("%.1f FPS", count)
            count = 0
            lastTime = tick()
        end
        wait()
    end
end)

spawn(function()
    while _G.AM_HUB_LOADED do
        wait(2)
        pcall(function()
            TabHome:Paragraph({
                Title = "性能信息",
                Desc = fpsText,
                Image = "bar-chart",
                ImageSize = 20,
                Color = Color3.fromHex("#00A2FF")
            })
        end)
    end
end)

TabHome:Paragraph({
    Title = "AM温馨提示",
    Desc = "玩挂要有心，不要乱打人 ❤️",
    Image = "heart",
    ImageSize = 20,
    Color = Color3.fromHex("#FF69B4")
})

TabHome:Paragraph({
    Title = "最大贡献者",
    Desc = "AM独自制作 | Cappo协助",
    Image = "star",
    ImageSize = 20,
    Color = Color3.fromHex("#FFD700")
})

TabHome:Paragraph({
    Title = "脚本声明",
    Desc = "本脚本为通用缝合脚本，不买卖、不倒卖",
    Image = "shield",
    ImageSize = 20,
    Color = Color3.fromHex("#FFFFFF")
})

-- ===================== 通用 Tab =====================
TabGeneral:Paragraph({
    Title = "移动修改",
    Desc = "以下为角色移动相关功能",
    Color = Color3.fromHex("#AAAAAA")
})

TabGeneral:Toggle({
    Title = "启用移速修改",
    Value = false,
    Callback = function(v)
        CacheOriginalValues()
        States.SpeedEnabled = v
        pcall(function()
            GetHumanoid().WalkSpeed = v and States.SpeedValue or (OriginalValues.WalkSpeed or 16)
        end)
    end
})

TabGeneral:Slider({
    Title = "移速值",
    Step = 1,
    Value = { Min = 1, Max = 600, Default = 16 },
    Callback = function(v)
        States.SpeedValue = v
        if States.SpeedEnabled then
            pcall(function() GetHumanoid().WalkSpeed = v end)
        end
    end
})

TabGeneral:Toggle({
    Title = "启用跳力修改",
    Value = false,
    Callback = function(v)
        CacheOriginalValues()
        States.JumpEnabled = v
        pcall(function()
            GetHumanoid().JumpPower = v and States.JumpValue or (OriginalValues.JumpPower or 50)
        end)
    end
})

TabGeneral:Slider({
    Title = "跳力值",
    Step = 1,
    Value = { Min = 1, Max = 600, Default = 50 },
    Callback = function(v)
        States.JumpValue = v
        if States.JumpEnabled then
            pcall(function() GetHumanoid().JumpPower = v end)
        end
    end
})

TabGeneral:Toggle({
    Title = "启用重力修改",
    Value = false,
    Callback = function(v)
        CacheOriginalValues()
        States.GravityEnabled = v
        Workspace.Gravity = v and States.GravityValue or (OriginalValues.Gravity or 196.2)
    end
})

TabGeneral:Slider({
    Title = "重力值",
    Step = 1,
    Value = { Min = 1, Max = 500, Default = 196 },
    Callback = function(v)
        States.GravityValue = v
        if States.GravityEnabled then Workspace.Gravity = v end
    end
})

TabGeneral:Toggle({
    Title = "无限跳跃",
    Value = false,
    Callback = function(v)
        States.InfiniteJump = v
        if v then
            Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
                pcall(function()
                    local h = GetHumanoid()
                    if h and h:GetState() ~= Enum.HumanoidStateType.Dead then
                        h:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end)
        else
            if Connections.InfiniteJump then
                Connections.InfiniteJump:Disconnect()
                Connections.InfiniteJump = nil
            end
        end
    end
})

TabGeneral:Toggle({
    Title = "穿墙模式",
    Value = false,
    Callback = function(v)
        States.Noclip = v
        if v then
            Instances.NoclipOrig = {}
            for _, part in pairs(GetCharacter():GetDescendants()) do
                if part:IsA("BasePart") then
                    Instances.NoclipOrig[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
            Connections.Noclip = RunService.Stepped:Connect(function()
                for part, _ in pairs(Instances.NoclipOrig) do
                    if part and part.Parent then part.CanCollide = false end
                end
            end)
        else
            if Connections.Noclip then
                Connections.Noclip:Disconnect()
                Connections.Noclip = nil
            end
            for part, ov in pairs(Instances.NoclipOrig or {}) do
                if part and part.Parent then part.CanCollide = ov end
            end
            Instances.NoclipOrig = {}
        end
    end
})

TabGeneral:Toggle({
    Title = "飞行模式",
    Value = false,
    Callback = function(v)
        States.FlyEnabled = v
        if v then
            local hrp = GetHRP()
            if not hrp then return end
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            Instances.BodyVelocity = bv
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            bg.P = 3000
            bg.Parent = hrp
            Instances.BodyGyro = bg
            pcall(function() GetHumanoid().PlatformStand = true end)
            local cam = Workspace.CurrentCamera
            Connections.Fly = RunService.Heartbeat:Connect(function()
                if not Instances.BodyVelocity or not Instances.BodyVelocity.Parent then return end
                local m = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then m = m + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then m = m - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then m = m - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then m = m + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m = m + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then m = m - Vector3.new(0, 1, 0) end
                bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
                bv.Velocity = (m.Magnitude > 0 and m.Unit or Vector3.zero) * States.FlySpeed
            end)
        else
            if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly = nil end
            if Instances.BodyVelocity then pcall(function() Instances.BodyVelocity:Destroy() end) Instances.BodyVelocity = nil end
            if Instances.BodyGyro then pcall(function() Instances.BodyGyro:Destroy() end) Instances.BodyGyro = nil end
            pcall(function() GetHumanoid().PlatformStand = false end)
        end
    end
})

TabGeneral:Slider({
    Title = "飞行速度",
    Step = 5,
    Value = { Min = 10, Max = 500, Default = 50 },
    Callback = function(v) States.FlySpeed = v end
})

TabGeneral:Toggle({
    Title = "隐身透明",
    Value = false,
    Callback = function(v)
        States.Invisible = v
        pcall(function()
            for _, part in pairs(GetCharacter():GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = v and 0.9 or 0 end
            end
        end)
    end
})

-- ===================== 玩家 Tab =====================
TabPlayer:Paragraph({
    Title = "玩家交互",
    Desc = "传送/跟随/注视目标玩家",
    Color = Color3.fromHex("#AAAAAA")
})

local PlayerList = {}
spawn(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(PlayerList, p.Name) end
    end
end)

local SelectedPlayer = nil

TabPlayer:Dropdown({
    Title = "选择目标玩家",
    Values = PlayerList,
    Value = "",
    Callback = function(selection)
        SelectedPlayer = selection
    end
})

TabPlayer:Button({
    Title = "传送到目标",
    Callback = function()
        pcall(function()
            if not SelectedPlayer then return end
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                GetHRP().CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
})

TabPlayer:Button({
    Title = "目标传送给我",
    Callback = function()
        pcall(function()
            if not SelectedPlayer then return end
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                target.Character.HumanoidRootPart.CFrame = GetHRP().CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
})

TabPlayer:Button({
    Title = "跟随目标",
    Callback = function()
        pcall(function()
            if not SelectedPlayer then return end
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                Connections.Follow = RunService.Heartbeat:Connect(function()
                    if not SelectedPlayer then return end
                    local t = Players:FindFirstChild(SelectedPlayer)
                    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                        GetHRP().CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(3, 0, 3)
                    end
                end)
            end
        end)
    end
})

TabPlayer:Button({
    Title = "停止跟随",
    Callback = function()
        if Connections.Follow then
            Connections.Follow:Disconnect()
            Connections.Follow = nil
        end
    end
})

-- ===================== 视觉 Tab =====================
TabVisual:Slider({
    Title = "FOV视野",
    Step = 1,
    Value = { Min = 50, Max = 120, Default = 70 },
    Callback = function(v)
        States.FOVValue = v
        pcall(function() Workspace.CurrentCamera.FieldOfView = v end)
    end
})

TabVisual:Toggle({
    Title = "夜视模式",
    Value = false,
    Callback = function(v)
        States.NightVision = v
        if v then
            spawn(function()
                while v and _G.AM_HUB_LOADED do
                    pcall(function()
                        Lighting.Ambient = Color3.fromRGB(150, 150, 150)
                        Lighting.Brightness = 2
                    end)
                    wait(0.2)
                end
            end)
        else
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(50, 50, 50)
                Lighting.Brightness = 1
            end)
        end
    end
})

TabVisual:Toggle({
    Title = "全图明亮",
    Value = false,
    Callback = function(v)
        States.BrightMap = v
        pcall(function()
            if v then
                Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
                Lighting.Brightness = 3
            else
                Lighting.Ambient = Color3.fromRGB(50, 50, 50)
                Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
                Lighting.Brightness = 1
            end
        end)
    end
})

TabVisual:Toggle({
    Title = "去除雾效",
    Value = false,
    Callback = function(v)
        States.NoFog = v
        pcall(function() Lighting.FogEnd = v and 999999 or 1000 end)
    end
})

TabVisual:Toggle({
    Title = "高饱和度",
    Value = false,
    Callback = function(v)
        pcall(function()
            if v then
                Lighting.ColorSaturation = 1.5
            else
                Lighting.ColorSaturation = 0
            end
        end)
    end
})

-- ===================== ESP Tab =====================
TabESP:Toggle({
    Title = "玩家名称ESP",
    Value = false,
    Callback = function(v)
        States.ESPEnabled = v
        if v then
            Instances.ESPFolder = Instance.new("Folder")
            Instances.ESPFolder.Name = "AM_ESP"
            Instances.ESPFolder.Parent = game.CoreGui
            Connections.ESP = RunService.RenderStepped:Connect(function()
                pcall(function()
                    Instances.ESPFolder:ClearAllChildren()
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                            local bg = Instance.new("BillboardGui")
                            bg.Adornee = plr.Character.Head
                            bg.Size = UDim2.new(0, 120, 0, 22)
                            bg.AlwaysOnTop = true
                            bg.Parent = Instances.ESPFolder
                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = plr.Name
                            lbl.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                            lbl.TextScaled = true
                            lbl.Font = Enum.Font.GothamBold
                            lbl.Parent = bg
                            -- 距离显示
                            local dist = (plr.Character.Head.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
                            lbl.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"
                        end
                    end
                end)
            end)
        else
            if Connections.ESP then Connections.ESP:Disconnect() Connections.ESP = nil end
            if Instances.ESPFolder then pcall(function() Instances.ESPFolder:Destroy() end) Instances.ESPFolder = nil end
        end
    end
})

TabESP:Toggle({
    Title = "血条ESP",
    Value = false,
    Callback = function(v)
        States.HealthESP = v
        if v then
            Instances.HealthESPFolder = Instance.new("Folder")
            Instances.HealthESPFolder.Name = "AM_HealthESP"
            Instances.HealthESPFolder.Parent = game.CoreGui
            Connections.HealthESP = RunService.RenderStepped:Connect(function()
                pcall(function()
                    Instances.HealthESPFolder:ClearAllChildren()
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                            local h = plr.Character:FindFirstChildWhichIsA("Humanoid")
                            if h then
                                local bg = Instance.new("BillboardGui")
                                bg.Adornee = plr.Character.Head
                                bg.Size = UDim2.new(0, 80, 0, 8)
                                bg.AlwaysOnTop = true
                                bg.Parent = Instances.HealthESPFolder
                                local frame = Instance.new("Frame")
                                frame.Size = UDim2.new(h.Health / h.MaxHealth, 0, 1, 0)
                                frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                                frame.Parent = bg
                            end
                        end
                    end
                end)
            end)
        else
            if Connections.HealthESP then Connections.HealthESP:Disconnect() Connections.HealthESP = nil end
            if Instances.HealthESPFolder then pcall(function() Instances.HealthESPFolder:Destroy() end) end
        end
    end
})

TabESP:Toggle({
    Title = "XRay穿墙透视",
    Value = false,
    Callback = function(v)
        States.XRay = v
        pcall(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    for _, part in pairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = v and 0.5 or 0
                            part.LocalTransparencyModifier = v and 0.5 or 0
                        end
                    end
                end
            end
        end)
    end
})

-- ===================== 自瞄 Tab =====================
TabAimbot:Toggle({
    Title = "自瞄开关",
    Value = false,
    Callback = function(v)
        States.AimbotEnabled = v
        if v then
            Connections.Aimbot = RunService.RenderStepped:Connect(function()
                if not States.AimbotEnabled then return end
                local cam = Workspace.CurrentCamera
                local bestTarget = nil
                local bestDist = States.AimbotRange
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                        local head = plr.Character.Head
                        local onScreen = cam:WorldToScreenPoint(head.Position)
                        local dist = (head.Position - cam.CFrame.Position).Magnitude
                        if onScreen and dist < bestDist then
                            bestDist = dist
                            bestTarget = head
                        end
                    end
                end
                if bestTarget then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, bestTarget.Position)
                end
            end)
        else
            if Connections.Aimbot then Connections.Aimbot:Disconnect() Connections.Aimbot = nil end
        end
    end
})

TabAimbot:Slider({
    Title = "自瞄范围",
    Step = 10,
    Value = { Min = 10, Max = 1000, Default = 100 },
    Callback = function(v) States.AimbotRange = v end
})

TabAimbot:Toggle({
    Title = "瞄准头部(关=瞄准身体)",
    Value = true,
    Callback = function(v) States.AimbotHead = v end
})

-- ===================== FE Tab =====================
TabFE:Paragraph({
    Title = "FE工具集",
    Desc = "FE = FilteringEnabled 绕过工具",
    Color = Color3.fromHex("#FFAA00")
})

TabFE:Button({
    Title = "Adonis反作弊绕过",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua"))()
        end)
    end
})

TabFE:Button({
    Title = "Infinite Yield (FE命令)",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
    end
})

TabFE:Toggle({
    Title = "FE传送(滑步)",
    Value = false,
    Callback = function(v)
        States.FETeleport = v
        if v then
            Connections.FETP = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local hrp = GetHRP()
                    if hrp then
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.5, 0)
                    end
                end)
            end)
        else
            if Connections.FETP then Connections.FETP:Disconnect() Connections.FETP = nil end
        end
    end
})

-- ===================== 娱乐 Tab =====================
TabFun:Paragraph({
    Title = "娱乐功能",
    Desc = "搞笑/整蛊功能合集",
    Color = Color3.fromHex("#FF69B4")
})

TabFun:Button({
    Title = "倒地(装死)",
    Callback = function()
        pcall(function() GetHumanoid():ChangeState(Enum.HumanoidStateType.Physics) end)
    end
})

TabFun:Button({
    Title = "坐下",
    Callback = function()
        pcall(function() GetHumanoid():ChangeState(Enum.HumanoidStateType.Seated) end)
    end
})

TabFun:Button({
    Title = "跳一下",
    Callback = function()
        pcall(function() GetHumanoid():ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
})

TabFun:Toggle({
    Title = "自动旋转",
    Value = false,
    Callback = function(v)
        States.AutoRotate = v
        if v then
            Connections.Rotate = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local hrp = GetHRP()
                    if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(5), 0) end
                end)
            end)
        else
            if Connections.Rotate then Connections.Rotate:Disconnect() Connections.Rotate = nil end
        end
    end
})

TabFun:Slider({
    Title = "旋转速度",
    Step = 1,
    Value = { Min = 1, Max = 50, Default = 5 },
    Callback = function(v) States.RotateSpeed = v end
})

-- ===================== 设置 Tab =====================
TabSettings:Paragraph({
    Title = "QQ群: 179051448",
    Desc = "点击按钮复制群号，加入我们获取最新脚本",
    Image = "message-circle",
    ImageSize = 20,
    Color = Color3.fromHex("#00AAFF")
})

TabSettings:Button({
    Title = "复制QQ群号: 179051448",
    Callback = function()
        pcall(function() (setclipboard or function() end)("179051448") end)
        WindUI:Notify({
            Title = "已复制",
            Content = "QQ群号 179051448 已复制到剪贴板",
            Duration = 3
        })
    end
})

TabSettings:Toggle({
    Title = "全局总开关(关闭所有功能)",
    Value = true,
    Callback = function(v)
        if not v then
            -- 关闭所有功能
            for key, val in pairs(States) do
                if type(val) == "boolean" then States[key] = false end
            end
            CleanupAll()
            -- 还原
            pcall(function()
                local h = GetHumanoid()
                if h then
                    h.WalkSpeed = OriginalValues.WalkSpeed or 16
                    h.JumpPower = OriginalValues.JumpPower or 50
                    h.PlatformStand = false
                end
            end)
            Workspace.Gravity = OriginalValues.Gravity or 196.2
            WindUI:Notify({
                Title = "AM Hub",
                Content = "所有功能已关闭并还原",
                Duration = 3
            })
        end
    end
})

TabSettings:Button({
    Title = "🔴 彻底销毁脚本",
    Callback = function()
        _G.AM_HUB_LOADED = false
        CleanupAll()
        pcall(function() Window:Destroy() end)
        WindUI:Notify({
            Title = "AM Hub",
            Content = "脚本已彻底销毁",
            Duration = 2
        })
    end
})

-- ===================== 加载完成通知 =====================
pcall(function()
    WindUI:Notify({
        Title = "AM Hub v3.0",
        Content = "AM加载成功! QQ群: 179051448",
        Icon = "check",
        Duration = 4
    })
end)

print("[AM Hub v3.0] XK风格完整版加载完成 ✅")
print("[AM Hub] QQ群: 179051448")
print("[AM Hub] 功能数: 30+")
