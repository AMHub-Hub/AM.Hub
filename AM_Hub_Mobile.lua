--// AM HUB | FULL SOURCE
if _G.AM_LOAD then return end _G.AM_LOAD = true
local P = game:GetService("Players").LocalPlayer
local C = P.Character or P.CharacterAdded:Wait()
local H = C:WaitForChild("Humanoid")
local HRP = C:WaitForChild("HumanoidRootPart")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = workspace
local GUI = Instance.new("ScreenGui", game.CoreGui)
GUI.Name = "AM_HUB_MAIN"
GUI.ResetOnSpawn = false
local MAIN = Instance.new("Frame", GUI)
MAIN.Size = UDim2.new(0, 500, 0, 350)
MAIN.Position = UDim2.new(0.5, -250, 0.5, -175)
MAIN.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MAIN.BorderSizePixel = 0
MAIN.Active = true
MAIN.Draggable = true
Instance.new("UICorner", MAIN).CornerRadius = UDim.new(0, 8)
local TAB_F = Instance.new("Frame", MAIN)
TAB_F.Size = UDim2.new(0, 120, 1, 0)
TAB_F.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", TAB_F).CornerRadius = UDim.new(0, 8)
local CONTENT = Instance.new("Frame", MAIN)
CONTENT.Position = UDim2.new(0, 130, 0, 10)
CONTENT.Size = UDim2.new(1, -140, 1, -20)
CONTENT.BackgroundTransparency = 1
local TITLE = Instance.new("TextLabel", MAIN)
TITLE.Size = UDim2.new(1, -40, 0, 30)
TITLE.Position = UDim2.new(0, 10, 0, 5)
TITLE.Text = "AM HUB | 通用"
TITLE.TextColor3 = Color3.new(1,1,1)
TITLE.Font = Enum.Font.GothamBold
TITLE.TextSize = 14
TITLE.BackgroundTransparency = 1
local CLOSE = Instance.new("TextButton", MAIN)
CLOSE.Size = UDim2.new(0, 30, 0, 30)
CLOSE.Position = UDim2.new(1, -35, 0, 5)
CLOSE.Text = "X"
CLOSE.TextColor3 = Color3.fromRGB(255, 50, 50)
CLOSE.BackgroundTransparency = 1
CLOSE.Font = Enum.Font.GothamBold
CLOSE.TextSize = 14
CLOSE.MouseButton1Click:Connect(function() GUI:Destroy() end)
local S = {F = false, N = false, I = false, SP = 16, JP = 50, GR = 196, BV = nil, BG = nil, CONN = nil}
local function BTN(parent, text, y, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.MouseButton1Click:Connect(cb)
    return b
end
BTN(TAB_F, "通用", 10, function() TITLE.Text = "AM HUB | 通用" end)
BTN(TAB_F, "视觉", 45, function() TITLE.Text = "AM HUB | 视觉" end)
BTN(TAB_F, "玩家", 80, function() TITLE.Text = "AM HUB | 玩家" end)
BTN(TAB_F, "ESP", 115, function() TITLE.Text = "AM HUB | ESP" end)
BTN(CONTENT, "飞行: OFF", 10, function(b)
    S.F = not S.F
    b.Text = "飞行: " .. (S.F and "ON" or "OFF")
    if S.F then
        S.BV = Instance.new("BodyVelocity", HRP)
        S.BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        S.BG = Instance.new("BodyGyro", HRP)
        S.BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        H.PlatformStand = true
        S.CONN = RS.Heartbeat:Connect(function()
            local D = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then D += WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then D -= WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then D -= WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then D += WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then D += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then D -= Vector3.new(0,1,0) end
            S.BG.CFrame = CFrame.new(HRP.Position, HRP.Position + WS.CurrentCamera.CFrame.LookVector)
            S.BV.Velocity = (D.Magnitude > 0 and D.Unit or Vector3.zero) * 60
        end)
    else
        if S.CONN then S.CONN:Disconnect() end
        if S.BV then S.BV:Destroy() end
        if S.BG then S.BG:Destroy() end
        H.PlatformStand = false
    end
end)
BTN(CONTENT, "穿墙: OFF", 50, function(b)
    S.N = not S.N
    b.Text = "穿墙: " .. (S.N and "ON" or "OFF")
    if S.N then
        S.NCONN = RS.Stepped:Connect(function()
            for _, p in pairs(C:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    else
        if S.NCONN then S.NCONN:Disconnect() end
    end
end)
BTN(CONTENT, "无限跳: OFF", 90, function(b)
    S.I = not S.I
    b.Text = "无限跳: " .. (S.I and "ON" or "OFF")
    if S.I then
        S.ICONN = UIS.JumpRequest:Connect(function()
            if H:GetState() ~= Enum.HumanoidStateType.Dead then
                H:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if S.ICONN then S.ICONN:Disconnect() end
    end
end)
BTN(CONTENT, "速度: 16", 130, function(b)
    S.SP = S.SP == 16 and 100 or 16
    b.Text = "速度: " .. S.SP
    H.WalkSpeed = S.SP
end)
BTN(CONTENT, "跳力: 50", 170, function(b)
    S.JP = S.JP == 50 and 150 or 50
    b.Text = "跳力: " .. S.JP
    H.JumpPower = S.JP
end)
BTN(CONTENT, "重力: 196", 210, function(b)
    S.GR = S.GR == 196 and 50 or 196
    b.Text = "重力: " .. S.GR
    WS.Gravity = S.GR
end)
BTN(CONTENT, "透视: OFF", 250, function(b)
    S.X = not S.X
    b.Text = "透视: " .. (S.X and "ON" or "OFF")
    if S.X then
        S.XCONN = RS.RenderStepped:Connect(function()
            for _, p in pairs(WS:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent ~= C then
                    p.LocalTransparencyModifier = 0.5
                end
            end
        end)
    else
        if S.XCONN then S.XCONN:Disconnect() end
    end
end)
BTN(CONTENT, "ESP: OFF", 290, function(b)
    S.E = not S.E
    b.Text = "ESP: " .. (S.E and "ON" or "OFF")
    if S.E then
        S.ECONN = RS.RenderStepped:Connect(function()
            for _, pl in pairs(game.Players:GetPlayers()) do
                if pl ~= P and pl.Character and pl.Character:FindFirstChild("Head") then
                    local bb = Instance.new("BillboardGui", WS.CurrentCamera)
                    bb.Name = "ESP_" .. pl.Name
                    bb.Adornee = pl.Character.Head
                    bb.Size = UDim2.new(0, 100, 0, 20)
                    bb.AlwaysOnTop = true
                    local tl = Instance.new("TextLabel", bb)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Text = pl.Name
                    tl.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    tl.TextScaled = true
                end
            end
        end)
    else
        if S.ECONN then S.ECONN:Disconnect() end
        for _, g in pairs(WS.CurrentCamera:GetChildren()) do
            if g.Name:match("^ESP_") then g:Destroy() end
        end
    end
end)
local FLOAT = Instance.new("TextButton", GUI)
FLOAT.Size = UDim2.new(0, 50, 0, 50)
FLOAT.Position = UDim2.new(1, -60, 1, -60)
FLOAT.Text = "AM"
FLOAT.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
FLOAT.TextColor3 = Color3.new(1,1,1)
FLOAT.Font = Enum.Font.GothamBlack
FLOAT.TextSize = 14
Instance.new("UICorner", FLOAT).CornerRadius = UDim.new(1, 0)
FLOAT.Active = true
FLOAT.Draggable = true
FLOAT.MouseButton1Click:Connect(function() MAIN.Visible = not MAIN.Visible end)
spawn(function() while wait(0.1) do FLOAT.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1) end end)
print("[AM Hub] Loaded")
